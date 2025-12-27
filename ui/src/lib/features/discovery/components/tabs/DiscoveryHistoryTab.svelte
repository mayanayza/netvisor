<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { Discovery } from '../../types/base';
	import { discoveryFields } from '../../store';
	import DiscoveryEditModal from '../DiscoveryModal/DiscoveryEditModal.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import DiscoveryHistoryCard from '../cards/DiscoveryHistoryCard.svelte';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import {
		useDiscoveriesQuery,
		useCreateDiscoveryMutation,
		useUpdateDiscoveryMutation,
		useBulkDeleteDiscoveriesMutation
	} from '../../queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';

	// Queries
	const discoveriesQuery = useDiscoveriesQuery();
	const daemonsQuery = useDaemonsQuery();
	const hostsQuery = useHostsQuery();

	// Mutations
	const createDiscoveryMutation = useCreateDiscoveryMutation();
	const updateDiscoveryMutation = useUpdateDiscoveryMutation();
	const bulkDeleteDiscoveriesMutation = useBulkDeleteDiscoveriesMutation();

	// Derived data
	let discoveriesData = $derived(discoveriesQuery.data ?? []);
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data ?? []);
	let isLoading = $derived(
		discoveriesQuery.isPending || daemonsQuery.isPending || hostsQuery.isPending
	);

	let showDiscoveryModal = $state(false);
	let editingDiscovery: Discovery | null = $state(null);

	function handleEditDiscovery(discovery: Discovery) {
		editingDiscovery = discovery;
		showDiscoveryModal = true;
	}

	async function handleDiscoveryCreate(data: Discovery) {
		await createDiscoveryMutation.mutateAsync(data);
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	async function handleDiscoveryUpdate(id: string, data: Discovery) {
		await updateDiscoveryMutation.mutateAsync(data);
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	function handleCloseEditor() {
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Historical Discoveries?`)) {
			await bulkDeleteDiscoveriesMutation.mutateAsync(ids);
		}
	}

	let fields: FieldConfig<Discovery>[] = $derived([
		...discoveryFields(daemonsData),
		{
			key: 'started_at',
			label: 'Started At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.started_at ? formatTimestamp(results.started_at) : 'Unknown';
			}
		},
		{
			key: 'finished_at',
			label: 'Finished At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.finished_at ? formatTimestamp(results.finished_at) : 'Unknown';
			}
		},
		{
			key: 'duration',
			label: 'Duration',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				if (results && results.finished_at && results.started_at) {
					return formatDuration(results.started_at, results.finished_at);
				}
				return 'Unknown';
			}
		}
	]);
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Discovery History" subtitle="Review historical discovery sessions" />

	{#if isLoading}
		<Loading />
	{:else if discoveriesData.length === 0}
		<!-- Empty state -->
		<EmptyState title="No discovery sessions have been run" subtitle="" />
	{:else}
		<DataControls
			items={discoveriesData.filter((d) => d.run_type.type == 'Historical')}
			{fields}
			onBulkDelete={handleBulkDelete}
			storageKey="scanopy-discovery-historical-table-state"
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Discovery,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<DiscoveryHistoryCard
					discovery={item}
					onView={handleEditDiscovery}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<DiscoveryEditModal
	isOpen={showDiscoveryModal}
	hosts={hostsData}
	daemons={daemonsData}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
