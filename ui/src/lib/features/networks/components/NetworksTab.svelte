<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { daemons, deleteDaemon, getDaemons } from '$lib/features/daemons/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getNetworks, networks } from '$lib/features/networks/store';
	import { getHosts } from '$lib/features/hosts/store';
	import type { Network } from '../types';
	import NetworkCard from './NetworkCard.svelte';

	const loading = loadData([getNetworks, getDaemons, getHosts]);

	let showCreateDaemonModal = false;

	function handleDeleteNetwork(network: Network) {
		if (confirm(`Are you sure you want to delete network "${network.name}"?`)) {
			deleteDaemon(network.id);
		}
	}

	function handleCreateDaemon() {
		showCreateDaemonModal = true;
	}

	function handleCloseCreateDaemon() {
		showCreateDaemonModal = false;
	}
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader
		title="Discovery"
		subtitle="Run discovery and manage daemons"
		buttons={[
			{
				onClick: handleCreateDaemon,
				cta: 'Create Daemon'
			}
		]}
	/>

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $daemons.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No daemons configured yet"
			subtitle=""
			onClick={handleCreateDaemon}
			cta="Create your first daemon"
		/>
	{:else}
		<!-- Daemons grid -->
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
			{#each $networks as network (network.id)}
				<NetworkCard
					{network}
					onDelete={handleDeleteNetwork}
				/>
			{/each}
		</div>
	{/if}
</div>
