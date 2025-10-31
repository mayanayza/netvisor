<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { daemons, deleteDaemon, getDaemons } from '$lib/features/daemons/store';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { initiateDiscovery, sessions } from '$lib/features/discovery/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getNetworks, networks } from '$lib/features/networks/store';
	import DaemonCard from './DaemonCard.svelte';
	import CreateDaemonModal from './CreateDaemonModal.svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';

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
		daemon = null;
	}

	function handleGenerateApiKey(generateApiDaemon: Daemon) {
		showCreateDaemonModal = true;
		daemon = generateApiDaemon;
	}

	// Define field configuration for the DataTableControls
	const daemonFields: FieldConfig<Daemon>[] = [
		{
			key: 'name',
			label:'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'network_id',
			type: 'string',
			label: "Network",
			searchable: false,
			filterable: true,
			sortable: false,
			getValue(item) {
				return $networks.find(n => n.id == item.network_id)?.name || "Unknown Network"
			},
		}
	];
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
		<DataControls items={$daemons} fields={daemonFields} storageKey="netvisor-daemons-table-state">
			{#snippet children(item: Daemon)}
				<DaemonCard
					daemon={item}
					{discoveryIsRunning}
					onDiscovery={handleRunDiscovery}
					onDelete={handleDeleteDaemon}
					onGenerateApi={handleGenerateApiKey}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<CreateDaemonModal isOpen={showCreateDaemonModal} onClose={handleCloseCreateDaemon} {daemon} />
