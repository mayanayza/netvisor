<script lang="ts">
	import { env } from '$env/dynamic/public';
	import { networks } from '$lib/features/networks/store';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { entities } from '$lib/shared/stores/metadata';
	import dockerTemplate from '$lib/templates/docker-compose.daemon.yml?raw';
	import { writable, type Writable } from 'svelte/store';
	import type { Daemon } from '../types/base';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import { RotateCcwKey } from 'lucide-svelte';
	import { createEmptyApiKeyFormData, createNewApiKey } from '$lib/features/api_keys/store';

	export let isOpen = false;
	export let onClose: () => void;
	export let daemon: Daemon | null = null;

	let keyStore: Writable<string | null> = writable(null);
	$: key = $keyStore;
	let selectedNetworkId = daemon ? daemon.network_id : $networks[0].id;

	function handleOnClose() {
		keyStore.set(null);
		onClose();
	}

	async function handleCreateNewApiKey() {
		let newApiKey = createEmptyApiKeyFormData();
		newApiKey.network_id = selectedNetworkId;

		const generatedKey = await createNewApiKey(newApiKey);
		if (generatedKey) {
			keyStore.set(generatedKey);
		} else {
			pushError('Failed to generate API key');
		}
	}

	const baseUrl = window.location.origin;
	const parsedUrl = new URL(baseUrl);

	const serverTarget =
		env.PUBLIC_SERVER_HOSTNAME && env.PUBLIC_SERVER_HOSTNAME !== 'default'
			? env.PUBLIC_SERVER_HOSTNAME
			: parsedUrl.hostname;

	const serverPort =
		env.PUBLIC_SERVER_HOSTNAME === 'default'
			? parsedUrl.port || '60072'
			: env.PUBLIC_SERVER_PORT || parsedUrl.port || '60072';

	const protocol = parsedUrl.protocol === 'https:' ? 'https' : 'http';

	const installCommand = `curl -sSL https://raw.githubusercontent.com/mayanayza/netvisor/refs/heads/main/install.sh | bash`;
	$: runCommand = `netvisor-daemon --server-target ${protocol}://${serverTarget} --server-port ${serverPort} ${!daemon ? `--network-id ${selectedNetworkId}` : ''} ${key ? `--daemon-api-key ${key}` : ''}`;

	let dockerCompose = '';
	$: if (key) {
		dockerCompose = populateDockerCompose(
			dockerTemplate,
			serverTarget,
			serverPort,
			selectedNetworkId,
			key
		);
	}

	function populateDockerCompose(
		template: string,
		serverTarget: string,
		serverPort: string,
		networkId: string,
		key: string
	): string {
		// Replace lines that contain env vars
		let splitString = '# Daemon configuration';
		let [beforeKey, afterKey] = template.split(splitString);
		template = beforeKey + splitString + '\n' + `      - NETVISOR_DAEMON_API_KEY=${key}` + afterKey;

		return template
			.split('\n')
			.map((line) => {
				if (line.includes('NETVISOR_SERVER_TARGET=')) {
					return `      - NETVISOR_SERVER_TARGET=${protocol}://${serverTarget}`;
				}
				if (line.includes('NETVISOR_SERVER_PORT=')) {
					return `      - NETVISOR_SERVER_PORT=${serverPort}`;
				}
				if (line.includes('NETVISOR_NETWORK_ID=')) {
					return `      - NETVISOR_NETWORK_ID=${networkId}`;
				}
				return line;
			})
			.join('\n');
	}

	let colorHelper = entities.getColorHelper('Daemon');
</script>

<EditModal
	{isOpen}
	title="Create Daemon"
	cancelLabel="Close"
	onCancel={handleOnClose}
	showSave={false}
	size="xl"
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.string} />
	</svelte:fragment>

	<div class="space-y-4">
		{#if !daemon}
			<SelectNetwork bind:selectedNetworkId></SelectNetwork>
		{/if}

		<div class="pb-2">
			<div class="flex items-start gap-2">
				<button
					class="btn-primary m-1 flex-shrink-0 self-stretch"
					disabled={!!key}
					on:click={handleCreateNewApiKey}
				>
					<RotateCcwKey />
					<span>Generate Key</span>
				</button>

				<div class="flex-1">
					<CodeContainer
						language="bash"
						expandable={false}
						code={key ? key : 'Press Generate Key...'}
					/>
				</div>
			</div>
			{#if !key}
				<div class="text-secondary mt-3">
					This will create a new API key, which you can manage later in the API Keys tab.
				</div>
			{/if}
		</div>

		{#if !daemon && key}
			<div class="text-secondary mt-3">
				<b>Option 1.</b> Run the install script, then start the daemon
			</div>

			<CodeContainer language="bash" expandable={false} code={installCommand} />

			<CodeContainer language="bash" expandable={false} code={runCommand} />

			<div class="text-secondary mt-3"><b>Option 2.</b> Run this docker-compose</div>

			<CodeContainer language="yaml" expandable={false} code={dockerCompose} />
		{:else if daemon && key && selectedNetworkId}
			<InlineWarning
				title="This API key will not be available once you close this modal. Please use the provided run command or update your docker compose with the API key as depicted below."
			/>

			<div class="text-secondary mt-3">
				<b>Option 1.</b> Stop the daemon process, and use this command to start it
			</div>
			<CodeContainer language="bash" expandable={false} code={runCommand} />
			<div class="text-secondary mt-3">
				<b>Option 2.</b> Stop the daemon container, and add this environment variable
			</div>
			<CodeContainer
				language="bash"
				expandable={false}
				code={`- NETVISOR_DAEMON_API_KEY=${key}\n`}
			/>
		{/if}
	</div>
</EditModal>
