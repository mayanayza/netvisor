<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import {
		createNetwork,
		deleteNetwork,
		getNetworks,
		networks,
		updateNetwork
	} from '$lib/features/networks/store';
	import type { Network } from '../types';
	import NetworkCard from './NetworkCard.svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import { getDaemons } from '$lib/features/daemons/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import { getGroups } from '$lib/features/groups/store';
	import NetworkEditModal from './NetworkEditModal.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';

	const loading = loadData([getNetworks, getHosts, getDaemons, getSubnets, getGroups]);

	let showCreateNetworkModal = false;
	let editingNetwork: Network | null = null;

	function handleDeleteNetwork(network: Network) {
		if (
			confirm(
				`Are you sure you want to delete network "${network.name}"? All hosts, groups, and subnets will be deleted along with it.`
			)
		) {
			deleteNetwork(network.id);
		}
	}

	function handleCreateNetwork() {
		editingNetwork = null;
		showCreateNetworkModal = true;
	}

	function handleEditNetwork(network: Network) {
		editingNetwork = network;
		showCreateNetworkModal = true;
	}

	async function handleNetworkCreate(data: Network) {
		const result = await createNetwork(data);
		if (result?.success) {
			showCreateNetworkModal = false;
			editingNetwork = null;
		}
	}

	async function handleNetworkUpdate(id: string, data: Network) {
		const result = await updateNetwork(data);
		if (result?.success) {
			showCreateNetworkModal = false;
			editingNetwork = null;
		}
	}

	function handleCloseNetworkEditor() {
		showCreateNetworkModal = false;
		editingNetwork = null;
	}

	// Define field configuration for the DataTableControls
	const networkFields: FieldConfig<Network>[] = [
		{
			key: 'name',
			label:'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader
		title="Networks"
		subtitle="Manage networks"
		buttons={[
			{
				onClick: handleCreateNetwork,
				cta: 'Create Network'
			}
		]}
	/>

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $networks.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No networks configured yet"
			subtitle=""
			onClick={handleCreateNetwork}
			cta="Create your first network"
		/>
	{:else}
		<DataControls items={$networks} fields={networkFields} storageKey="netvisor-networks-table-state">
			{#snippet children(item: Network, viewMode: 'card' | 'list')}
				<NetworkCard 
					network={item} 
					{viewMode}
					onDelete={handleDeleteNetwork} 
					onEdit={handleEditNetwork} />
			{/snippet}
		</DataControls>
	{/if}
</div>

<NetworkEditModal
	isOpen={showCreateNetworkModal}
	network={editingNetwork}
	onCreate={handleNetworkCreate}
	onUpdate={handleNetworkUpdate}
	onClose={handleCloseNetworkEditor}
/>
