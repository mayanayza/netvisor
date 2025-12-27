<script lang="ts">
	import ShareCard from './ShareCard.svelte';
	import type { Share } from '../types/base';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import ShareModal from './ShareModal.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { useTopologiesQuery } from '$lib/features/topology/queries';
	import { useSharesQuery, useDeleteShareMutation, useBulkDeleteSharesMutation } from '../queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	// Queries
	const sharesQuery = useSharesQuery();
	const networksQuery = useNetworksQuery();
	const topologiesQuery = useTopologiesQuery();

	// Mutations
	const deleteShareMutation = useDeleteShareMutation();
	const bulkDeleteSharesMutation = useBulkDeleteSharesMutation();

	// Derived data
	let sharesData = $derived(sharesQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let isLoading = $derived(sharesQuery.isPending);

	let showEditor = $state(false);
	let editingShare = $state<Share | null>(null);

	// Define field configuration for DataControls
	const shareFields: FieldConfig<Share>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'topology_id',
			label: 'Topology',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (share) => {
				return topologiesData.find((t) => t.id === share.topology_id)?.name || 'Unknown Topology';
			}
		},
		{
			key: 'network_id',
			label: 'Network',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: true,
			getValue: (share) => {
				return networksData.find((n) => n.id === share.network_id)?.name || 'Unknown Network';
			}
		},
		{
			key: 'is_enabled',
			label: 'Enabled',
			type: 'boolean',
			searchable: false,
			filterable: true,
			sortable: false
		},
		{
			key: 'expires_at',
			label: 'Expires',
			type: 'date',
			searchable: false,
			filterable: false,
			sortable: true
		},
		{
			key: 'created_at',
			label: 'Created',
			type: 'date',
			searchable: false,
			filterable: false,
			sortable: true
		}
	];

	function handleEdit(share: Share) {
		editingShare = share;
		showEditor = true;
	}

	function handleDelete(share: Share) {
		if (confirm(`Are you sure you want to delete "${share.name}"?`)) {
			deleteShareMutation.mutate(share.id);
		}
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} shares?`)) {
			await bulkDeleteSharesMutation.mutateAsync(ids);
		}
	}

	function handleCloseEditor() {
		showEditor = false;
		editingShare = null;
	}
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Sharing" subtitle="View and manage shared topology links and embeds" />

	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if sharesData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No links or embeds created yet"
			subtitle="Create links or embeds from the Topology tab to share your topologies"
		/>
	{:else}
		<DataControls
			items={sharesData}
			fields={shareFields}
			storageKey="scanopy-shares-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Share,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<ShareCard
					share={item}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
					onEdit={handleEdit}
					onDelete={handleDelete}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<ShareModal isOpen={showEditor} share={editingShare} onClose={handleCloseEditor} />
