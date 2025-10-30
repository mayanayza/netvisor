<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { daemons, deleteDaemon, getDaemons } from '$lib/features/daemons/store';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { initiateDiscovery, sessions } from '$lib/features/discovery/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getNetworks } from '$lib/features/networks/store';
	import DaemonCard from './DaemonCard.svelte';
	import CreateDaemonModal from './CreateDaemonModal.svelte';
	import { getHosts } from '$lib/features/hosts/store';

	const loading = loadData([getNetworks, getDaemons, getHosts]);

	let showCreateDaemonModal = false;
	let daemon: Daemon | null = null;

	$: discoveryIsRunning = $sessions.size > 0;

	function handleDeleteDaemon(daemon: Daemon) {
		if (confirm(`Are you sure you want to delete daemon @"${daemon.ip}"?`)) {
			deleteDaemon(daemon.id);
		}
	}

	function handleRunDiscovery(daemon: Daemon) {
		initiateDiscovery({ daemon_id: daemon.id });
	}

	function handleCreateDaemon() {
		showCreateDaemonModal = true;
		daemon = null;
	}

	function handleCloseCreateDaemon() {
		showCreateDaemonModal = false;
		daemon = null
	}

	function handleGenerateApiKey(daemon: Daemon) {
		showCreateDaemonModal = true;
		daemon = daemon;

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
			{#each $daemons as daemon (daemon.id)}
				<DaemonCard
					{daemon}
					{discoveryIsRunning}
					onDiscovery={handleRunDiscovery}
					onDelete={handleDeleteDaemon}
					onGenerateApi={handleGenerateApiKey}
				/>
			{/each}
		</div>
	{/if}
</div>

<CreateDaemonModal isOpen={showCreateDaemonModal} onClose={handleCloseCreateDaemon} {daemon}/>
