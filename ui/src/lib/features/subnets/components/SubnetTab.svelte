<script lang="ts">
	import { createSubnet, deleteSubnet, getSubnets, subnets, updateSubnet } from '../store';
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
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader
		title="Subnets"
		subtitle="Manage network subnets and IP ranges"
		buttons={[
			{
				onClick: handleCreateSubnet,
				cta: 'Create Subnet'
			}
		]}
	/>

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
		<DataControls items={$subnets} fields={subnetFields} storageKey="netvisor-subnets-table-state">
			{#snippet children(item: Subnet, viewMode: 'card' | 'list')}
				<SubnetCard
					subnet={item}
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
