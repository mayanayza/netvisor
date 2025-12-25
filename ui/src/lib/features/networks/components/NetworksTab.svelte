<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import {
		bulkDeleteNetworks,
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
	import { Plus } from 'lucide-svelte';
	import { tags } from '$lib/features/tags/store';
	import { currentUser } from '$lib/features/auth/store';
	import { permissions } from '$lib/shared/stores/metadata';

	const loading = loadData([getNetworks, getHosts, getDaemons, getSubnets, getGroups]);

	let showCreateNetworkModal = false;
	let editingNetwork: Network | null = null;

	$: allowBulkDelete = $currentUser
		? permissions.getMetadata($currentUser.permissions).manage_org_entities
		: false;

	$: canManageNetworks =
		($currentUser && permissions.getMetadata($currentUser.permissions).manage_org_entities) ||
		false;

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

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Networks?`)) {
			await bulkDeleteNetworks(ids);
		}
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
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Networks" subtitle="Manage networks">
		<svelte:fragment slot="actions">
			{#if canManageNetworks}
				<button class="btn-primary flex items-center" on:click={handleCreateNetwork}
					><Plus class="h-5 w-5" />Create Network</button
				>
			{/if}
		</svelte:fragment>
	</TabHeader>

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
		<DataControls
			items={$networks}
			fields={networkFields}
			onBulkDelete={handleBulkDelete}
			{allowBulkDelete}
			storageKey="scanopy-networks-table-state"
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Network,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<NetworkCard
					network={item}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
					onDelete={handleDeleteNetwork}
					onEdit={handleEditNetwork}
				/>
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
