<script lang="ts">
	import {
		bulkDeleteSubnets,
		createSubnet,
		deleteSubnet,
		getSubnets,
		subnets,
		updateSubnet
	} from '../store';
	import SubnetCard from './SubnetCard.svelte';
	import SubnetEditModal from './SubnetEditModal/SubnetEditModal.svelte';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getHosts } from '$lib/features/hosts/store';
	import { getServices } from '$lib/features/services/store';
	import type { Subnet } from '../types/base';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { networks } from '$lib/features/networks/store';
	import { Plus } from 'lucide-svelte';
	import { tags } from '$lib/features/tags/store';

	let showSubnetEditor = false;
	let editingSubnet: Subnet | null = null;

	const loading = loadData([getSubnets, getHosts, getServices]);

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
			deleteSubnet(subnet.id);
		}
	}

	async function handleSubnetCreate(data: Subnet) {
		const result = await createSubnet(data);
		if (result?.success) {
			showSubnetEditor = false;
			editingSubnet = null;
		}
	}

	async function handleSubnetUpdate(_id: string, data: Subnet) {
		const result = await updateSubnet(data);
		if (result?.success) {
			showSubnetEditor = false;
			editingSubnet = null;
		}
	}

	function handleCloseSubnetEditor() {
		showSubnetEditor = false;
		editingSubnet = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Subnets?`)) {
			await bulkDeleteSubnets(ids);
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
				return $networks.find((n) => n.id == item.network_id)?.name || 'Unknown Network';
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
					.map((id) => $tags.find((t) => t.id === id)?.name)
					.filter((name): name is string => !!name);
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Subnets" subtitle="Manage network subnets and IP ranges">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" on:click={handleCreateSubnet}
				><Plus class="h-5 w-5" />Create Subnet</button
			>
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $subnets.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No subnets configured yet"
			subtitle=""
			onClick={handleCreateSubnet}
			cta="Create your first subnet"
		/>
	{:else}
		<DataControls
			items={$subnets}
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
