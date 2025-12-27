<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { initiateDiscovery } from '../../sse';
	import type { Discovery } from '../../types/base';
	import { discoveryFields } from '../../store';
	import DiscoveryEditModal from '../DiscoveryModal/DiscoveryEditModal.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import DiscoveryRunCard from '../cards/DiscoveryScheduledCard.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useDiscoveriesQuery,
		useCreateDiscoveryMutation,
		useUpdateDiscoveryMutation,
		useDeleteDiscoveryMutation,
		useBulkDeleteDiscoveriesMutation
	} from '../../queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const discoveriesQuery = useDiscoveriesQuery();
	const daemonsQuery = useDaemonsQuery();
	const hostsQuery = useHostsQuery();

	// Mutations
	const createDiscoveryMutation = useCreateDiscoveryMutation();
	const updateDiscoveryMutation = useUpdateDiscoveryMutation();
	const deleteDiscoveryMutation = useDeleteDiscoveryMutation();
	const bulkDeleteDiscoveriesMutation = useBulkDeleteDiscoveriesMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let discoveriesData = $derived(discoveriesQuery.data ?? []);
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data ?? []);
	let isLoading = $derived(
		discoveriesQuery.isPending || daemonsQuery.isPending || hostsQuery.isPending
	);

	let showDiscoveryModal = $state(false);
	let editingDiscovery: Discovery | null = $state(null);

	function handleCreateDiscovery() {
		editingDiscovery = null;
		showDiscoveryModal = true;
	}

	function handleEditDiscovery(discovery: Discovery) {
		editingDiscovery = discovery;
		showDiscoveryModal = true;
	}

	function handleDeleteDiscovery(discovery: Discovery) {
		if (confirm(`Are you sure you want to delete "${discovery.name}"?`)) {
			deleteDiscoveryMutation.mutate(discovery.id);
		}
	}

	async function handleDiscoveryRun(discovery: Discovery) {
		await initiateDiscovery(discovery.id);
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
		if (confirm(`Are you sure you want to delete ${ids.length} Scheduled Discoveries?`)) {
			await bulkDeleteDiscoveriesMutation.mutateAsync(ids);
		}
	}

	let fields: FieldConfig<Discovery>[] = $derived([
		...discoveryFields(daemonsData),
		{
			key: 'run_type',
			label: 'Run Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => item.run_type.type
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
					.map((id) => tagsData.find((t) => t.id === id)?.name)
					.filter((name): name is string => !!name);
			}
		}
	]);
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Scheduled Discovery" subtitle="Schedule discovery sessions">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" onclick={handleCreateDiscovery}
				><Plus class="h-5 w-5" />Schedule Discovery</button
			>
		</svelte:fragment>
	</TabHeader>

	{#if isLoading}
		<Loading />
	{:else if discoveriesData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No discovery sessions are scheduled"
			subtitle=""
			onClick={handleCreateDiscovery}
			cta="Schedule a discovery session"
		/>
	{:else}
		<DataControls
			items={discoveriesData.filter(
				(d) => d.run_type.type == 'AdHoc' || d.run_type.type == 'Scheduled'
			)}
			{fields}
			onBulkDelete={handleBulkDelete}
			storageKey="scanopy-discovery-scheduled-table-state"
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Discovery,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<DiscoveryRunCard
					discovery={item}
					selected={isSelected}
					{onSelectionChange}
					onDelete={handleDeleteDiscovery}
					onEdit={handleEditDiscovery}
					onRun={handleDiscoveryRun}
					{viewMode}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<DiscoveryEditModal
	isOpen={showDiscoveryModal}
	daemons={daemonsData}
	hosts={hostsData}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
