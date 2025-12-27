<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { Network } from '../types';
	import NetworkCard from './NetworkCard.svelte';
	import NetworkEditModal from './NetworkEditModal.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { permissions } from '$lib/shared/stores/metadata';
	import {
		useNetworksQuery,
		useCreateNetworkMutation,
		useUpdateNetworkMutation,
		useDeleteNetworkMutation,
		useBulkDeleteNetworksMutation
	} from '../queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { useGroupsQuery } from '$lib/features/groups/queries';

	// Queries
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const tagsQuery = useTagsQuery();
	const networksQuery = useNetworksQuery();
	// Load related data
	useHostsQuery();
	useDaemonsQuery();
	useSubnetsQuery();
	useGroupsQuery();

	// Mutations
	const createNetworkMutation = useCreateNetworkMutation();
	const updateNetworkMutation = useUpdateNetworkMutation();
	const deleteNetworkMutation = useDeleteNetworkMutation();
	const bulkDeleteNetworksMutation = useBulkDeleteNetworksMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(networksQuery.isPending);

	let showCreateNetworkModal = $state(false);
	let editingNetwork = $state<Network | null>(null);

	let allowBulkDelete = $derived(
		currentUser ? permissions.getMetadata(currentUser.permissions).manage_org_entities : false
	);

	let canManageNetworks = $derived(
		(currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities) || false
	);

	function handleDeleteNetwork(network: Network) {
		if (
			confirm(
				`Are you sure you want to delete network "${network.name}"? All hosts, groups, and subnets will be deleted along with it.`
			)
		) {
			deleteNetworkMutation.mutate(network.id);
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
			await bulkDeleteNetworksMutation.mutateAsync(ids);
		}
	}

	async function handleNetworkCreate(data: Network) {
		try {
			await createNetworkMutation.mutateAsync(data);
			showCreateNetworkModal = false;
			editingNetwork = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleNetworkUpdate(id: string, data: Network) {
		try {
			await updateNetworkMutation.mutateAsync(data);
			showCreateNetworkModal = false;
			editingNetwork = null;
		} catch {
			// Error handled by mutation
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
					.map((id) => tagsData.find((t) => t.id === id)?.name)
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
				<button class="btn-primary flex items-center" onclick={handleCreateNetwork}
					><Plus class="h-5 w-5" />Create Network</button
				>
			{/if}
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if networksData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No networks configured yet"
			subtitle=""
			onClick={handleCreateNetwork}
			cta="Create your first network"
		/>
	{:else}
		<DataControls
			items={networksData}
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
