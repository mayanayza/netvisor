<script lang="ts">
	import SubnetCard from './SubnetCard.svelte';
	import SubnetEditModal from './SubnetEditModal/SubnetEditModal.svelte';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { Subnet } from '../types/base';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useSubnetsQuery,
		useCreateSubnetMutation,
		useUpdateSubnetMutation,
		useDeleteSubnetMutation,
		useBulkDeleteSubnetsMutation
	} from '../queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const subnetsQuery = useSubnetsQuery();
	const networksQuery = useNetworksQuery();
	useHostsQuery();
	useServicesQuery();

	// Mutations
	const createSubnetMutation = useCreateSubnetMutation();
	const updateSubnetMutation = useUpdateSubnetMutation();
	const deleteSubnetMutation = useDeleteSubnetMutation();
	const bulkDeleteSubnetsMutation = useBulkDeleteSubnetsMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(subnetsQuery.isPending);

	let showSubnetEditor = $state(false);
	let editingSubnet = $state<Subnet | null>(null);

	function handleCreateSubnet() {
		editingSubnet = null;
		showSubnetEditor = true;
	}

	function handleEditSubnet(subnet: Subnet) {
		editingSubnet = subnet;
		showSubnetEditor = true;
	}

	function handleDeleteSubnet(subnet: Subnet) {
		if (confirm(`Are you sure you want to delete "${subnet.name}"?`)) {
			deleteSubnetMutation.mutate(subnet.id);
		}
	}

	async function handleSubnetCreate(data: Subnet) {
		try {
			await createSubnetMutation.mutateAsync(data);
			showSubnetEditor = false;
			editingSubnet = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleSubnetUpdate(_id: string, data: Subnet) {
		try {
			await updateSubnetMutation.mutateAsync(data);
			showSubnetEditor = false;
			editingSubnet = null;
		} catch {
			// Error handled by mutation
		}
	}

	function handleCloseSubnetEditor() {
		showSubnetEditor = false;
		editingSubnet = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Subnets?`)) {
			await bulkDeleteSubnetsMutation.mutateAsync(ids);
		}
	}

	// Define field configuration for the DataTableControls
	const subnetFields: FieldConfig<Subnet>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'description',
			label: 'Description',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: false
		},
		{
			key: 'created_at',
			label: 'Created',
			type: 'date',
			searchable: false,
			filterable: false,
			sortable: true
		},
		{
			key: 'subnet_type',
			label: 'Subnet Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true
		},
		{
			key: 'network_id',
			type: 'string',
			label: 'Network',
			searchable: false,
			filterable: true,
			sortable: false,
			getValue(item) {
				return networksData.find((n) => n.id == item.network_id)?.name || 'Unknown Network';
			}
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
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Subnets" subtitle="Manage network subnets and IP ranges">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" onclick={handleCreateSubnet}
				><Plus class="h-5 w-5" />Create Subnet</button
			>
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if subnetsData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No subnets configured yet"
			subtitle=""
			onClick={handleCreateSubnet}
			cta="Create your first subnet"
		/>
	{:else}
		<DataControls
			items={subnetsData}
			fields={subnetFields}
			storageKey="scanopy-subnets-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Subnet,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<SubnetCard
					subnet={item}
					selected={isSelected}
					{onSelectionChange}
					{viewMode}
					onEdit={handleEditSubnet}
					onDelete={handleDeleteSubnet}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<SubnetEditModal
	isOpen={showSubnetEditor}
	subnet={editingSubnet}
	onCreate={handleSubnetCreate}
	onUpdate={handleSubnetUpdate}
	onClose={handleCloseSubnetEditor}
/>
