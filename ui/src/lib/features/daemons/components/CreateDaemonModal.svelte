<script lang="ts">
	import { env } from '$env/dynamic/public';
	import { networks } from '$lib/features/networks/store';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import dockerTemplate from '$lib/templates/docker-compose.daemon.yml?raw';

	export let isOpen = false;
	export let onClose: () => void;

	let selectedNetworkId: string = $networks[0].id;

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

		<!-- Network Type -->
		{#if false}
			<label for="group_type" class="text-secondary mb-2 block text-sm font-medium">
				Network
			</label>
			<select id="network" bind:value={selectedNetworkId} class="input-field">
				{#each $networks as network (network.id)}
					<option class="select-option" value={network.id}>{network.name}</option>
				{/each}
			</select>
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
