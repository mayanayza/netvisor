<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import {
		bulkDeleteDaemons,
		daemons,
		deleteDaemon,
		getDaemons
	} from '$lib/features/daemons/store';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getNetworks, networks } from '$lib/features/networks/store';
	import DaemonCard from './DaemonCard.svelte';
	import CreateDaemonModal from './CreateDaemonModal.svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { Plus } from 'lucide-svelte';
	import { tags } from '$lib/features/tags/store';

	const loading = loadData([getNetworks, getDaemons, getHosts]);

	let showCreateDaemonModal = false;
	let daemon: Daemon | null = null;

	function handleDeleteDaemon(daemon: Daemon) {
		if (confirm(`Are you sure you want to delete daemon @"${daemon.name}"?`)) {
			deleteDaemon(daemon.id);
		}
	}

	function handleCreateDaemon() {
		showCreateDaemonModal = true;
		daemon = null;
	}

	function handleCloseCreateDaemon() {
		showCreateDaemonModal = false;
		daemon = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Daemons?`)) {
			await bulkDeleteDaemons(ids);
		}
	}

	const daemonFields: FieldConfig<Daemon>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'tags',
			label: 'Tags',
			type: 'array',
			searchable: true,
			filterable: true,
			sortable: false,
			getValue: (entity) => {
				// Return tag names for search/filter display
				return entity.tags
					.map((id) => $tags.find((t) => t.id === id)?.name)
					.filter((name): name is string => !!name);
			}
		},
		{
			key: 'network_id',
			type: 'string',
			label: 'Network',
			searchable: false,
			filterable: true,
			sortable: false,
			getValue(item) {
				return $networks.find((n) => n.id == item.network_id)?.name || 'Unknown Network';
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Daemons" subtitle="Manage daemons">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" on:click={handleCreateDaemon}
				><Plus class="h-5 w-5" />Create Daemon</button
			>
		</svelte:fragment>
	</TabHeader>

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
		<DataControls
			items={$daemons}
			fields={daemonFields}
			storageKey="scanopy-daemons-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Daemon,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<DaemonCard
					daemon={item}
					{viewMode}
					onDelete={handleDeleteDaemon}
					selected={isSelected}
					{onSelectionChange}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<CreateDaemonModal isOpen={showCreateDaemonModal} onClose={handleCloseCreateDaemon} {daemon} />
