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

	let apiKeyStore: Writable<string | null> = writable(null)
	$: apiKey = $apiKeyStore;
	$: selectedNetworkId = daemon ? daemon.network_id : $networks[0].id;

	async function handleGenerateApiKey() {
		if (daemon) {
			const generatedKey = await generateApiKey({daemon_id: daemon.id, network_id: daemon.network_id});
			if (generatedKey) {
				apiKeyStore.set(generatedKey)
			} else {
				pushError("Failed to generate API key")
			}
		} else {
			pushError("No daemon provided to generate API key for")
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
	const runCommand = `netvisor-daemon --server-target ${protocol}://${serverTarget} --server-port ${serverPort} --network-id ${selectedNetworkId}`;

	function populateDockerCompose(
		template: string,
		serverTarget: string,
		serverPort: string,
		networkId: string
	): string {
		// Replace lines that contain these env vars
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
	onCancel={onClose}
	showSave={false}
	size="xl"
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.string} />
	</svelte:fragment>

	<div class="space-y-4">
		<h3 class="text-primary text-lg font-medium">Daemon Installation</h3>

		{#if daemon && !daemon?.api_key}
			<InlineWarning 
				title="Daemon missing API key" 
				body="This daemon does not have an API key set in its config file. \
					Please press the button below to generate one, then use the daemon start command or relaunch\
					the docker compose."/>
			<button
				class="btn-primary"
				on:click={handleGenerateApiKey}>
				<RotateCcwKey/>
				<span>Generate Key</span>
			</button>

			{#if apiKey}
				<CodeContainer language="bash" expandable={false} code={apiKey}/>
			{/if}
		{/if}

		<!-- Network Type -->
		{#if false}
			<label for="group_type" class="text-secondary mb-2 block text-sm font-medium">
				Network
			</label>
			<SelectNetwork selectedNetworkId={selectedNetworkId}></SelectNetwork>
			<p class="text-tertiary text-xs">Select the network that this daemon will report data to</p>
		{/if}

		<div class="text-secondary mt-3">Option 1. Run the install script, then start the daemon</div>

		<CodeContainer language="bash" expandable={false} code={installCommand} />

		<CodeContainer language="bash" expandable={false} code={runCommand} />

		<div class="text-secondary mt-3">Option 2. Run this docker-compose</div>

		<CodeContainer
			language="yaml"
			expandable={false}
			code={populateDockerCompose(dockerTemplate, serverTarget, serverPort, selectedNetworkId)}
		/>
	</div>
</EditModal>
