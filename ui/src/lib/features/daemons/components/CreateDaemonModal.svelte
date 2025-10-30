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
	import { generateApiKey } from '../store';
	import type { Daemon } from '../types/base';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import { RotateCcwKey } from 'lucide-svelte';

	export let isOpen = false;
	export let onClose: () => void;
	export let daemon: Daemon | null = null;

	let apiKeyStore: Writable<string | null> = writable(null);
	$: apiKey = $apiKeyStore;
	let selectedNetworkId = daemon ? daemon.network_id : $networks[0].id;

	function handleOnClose() {
		apiKeyStore.set(null);
		onClose();
	}

	async function handleGenerateApiKey() {
		if (daemon) {
			const generatedKey = await generateApiKey({
				daemon_id: daemon.id,
				network_id: daemon.network_id
			});
			if (generatedKey) {
				apiKeyStore.set(generatedKey);
			} else {
				pushError('Failed to generate API key');
			}
		} else {
			pushError('No daemon provided to generate API key for');
		}
	}

	const baseUrl = window.location.origin;
	const parsedUrl = new URL(baseUrl);

	const serverTarget =
		env.PUBLIC_SERVER_HOSTNAME && env.PUBLIC_SERVER_HOSTNAME !== 'default'
			? env.PUBLIC_SERVER_HOSTNAME
			: parsedUrl.hostname;

	const protocol = parsedUrl.protocol === 'https:' ? 'https' : 'http';

	const serverPort = env.PUBLIC_SERVER_PORT || parsedUrl.port || '60072';

	const installCommand = `curl -sSL https://raw.githubusercontent.com/mayanayza/netvisor/refs/heads/main/install.sh | bash`;
	$: runCommand = `netvisor-daemon --server-target ${protocol}://${serverTarget} --server-port ${serverPort} \\ \n--network-id ${selectedNetworkId} ${apiKey ? `--daemon-api-key ${apiKey}` : ''}`;

	function populateDockerCompose(
		template: string,
		serverTarget: string,
		serverPort: string,
		networkId: string,
		apiKey: string | null
	): string {
		// Replace lines that contain env vars

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
	cancelLabel="Cancel"
	onCancel={handleOnClose}
	showSave={false}
	size="xl"
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.string} />
	</svelte:fragment>

	<div class="space-y-4">
		<h3 class="text-primary text-lg font-medium">Daemon Installation</h3>

		{#if daemon && !daemon.api_key}
			<InlineWarning
				title="Daemon missing API key"
				body="This daemon does not have an API key set in its config file. Please press the button below to generate one, then use the daemon start command or relaunch the docker compose."
			/>
			<div class="flex items-center gap-2">
				<button class="btn-primary flex-shrink-0" on:click={handleGenerateApiKey}>
					<RotateCcwKey />
					<span>Generate Key</span>
				</button>

				<div class="flex min-h-[3rem] flex-1 items-center">
					{#if apiKey}
						<div class="w-full">
							<CodeContainer language="bash" expandable={false} code={apiKey} />
						</div>
					{/if}
				</div>
			</div>
			{#if apiKey}
				<span class="text-secondary">This API key will not be available once you close this modal. Please use the provided run command or update your docker compose with the API key as depicted below.</span>
			{/if}
		{/if}

		<!-- Network Type -->
		<SelectNetwork bind:selectedNetworkId></SelectNetwork>

		{#if !daemon}
			<div class="text-secondary mt-3">Option 1. Run the install script, then start the daemon</div>

			<CodeContainer language="bash" expandable={false} code={installCommand} />

			<CodeContainer language="bash" expandable={false} code={runCommand} />

			<div class="text-secondary mt-3">Option 2. Run this docker-compose</div>

			<CodeContainer
				language="yaml"
				expandable={false}
				code={populateDockerCompose(
					dockerTemplate,
					serverTarget,
					serverPort,
					selectedNetworkId,
					apiKey
				)}
			/>
		{:else if apiKey}
			<div class="text-secondary mt-3">Option 1. Stop the daemon process, and use this start command</div>
			<CodeContainer language="bash" expandable={false} code={runCommand} />
			<div class="text-secondary mt-3">Option 2. Stop the daemon container, and add this env var</div>
			<CodeContainer language="bash" expandable={false} code={`- NETVISOR_DAEMON_API_KEY=${apiKey}\n`} />
		{/if}
		
	</div>
</EditModal>
