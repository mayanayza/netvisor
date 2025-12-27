<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import type { Group } from '../types/base';
	import GroupCard from './GroupCard.svelte';
	import GroupEditModal from './GroupEditModal/GroupEditModal.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useGroupsQuery,
		useCreateGroupMutation,
		useUpdateGroupMutation,
		useDeleteGroupMutation,
		useBulkDeleteGroupsMutation
	} from '../queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const groupsQuery = useGroupsQuery();
	const networksQuery = useNetworksQuery();
	useServicesQuery();

	// Mutations
	const createGroupMutation = useCreateGroupMutation();
	const updateGroupMutation = useUpdateGroupMutation();
	const deleteGroupMutation = useDeleteGroupMutation();
	const bulkDeleteGroupsMutation = useBulkDeleteGroupsMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let groupsData = $derived(groupsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(groupsQuery.isPending);

	let showGroupEditor = $state(false);
	let editingGroup = $state<Group | null>(null);

	function handleCreateGroup() {
		editingGroup = null;
		showGroupEditor = true;
	}

	function handleEditGroup(group: Group) {
		editingGroup = group;
		showGroupEditor = true;
	}

	function handleDeleteGroup(group: Group) {
		if (confirm(`Are you sure you want to delete "${group.name}"?`)) {
			deleteGroupMutation.mutate(group.id);
		}
	}

	async function handleGroupCreate(data: Group) {
		try {
			await createGroupMutation.mutateAsync(data);
			showGroupEditor = false;
			editingGroup = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleGroupUpdate(id: string, data: Group) {
		try {
			await updateGroupMutation.mutateAsync(data);
			showGroupEditor = false;
			editingGroup = null;
		} catch {
			// Error handled by mutation
		}
	}

	function handleCloseGroupEditor() {
		showGroupEditor = false;
		editingGroup = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Groups?`)) {
			await bulkDeleteGroupsMutation.mutateAsync(ids);
		}
	}

	// Define field configuration for the DataTableControls
	const groupFields: FieldConfig<Group>[] = [
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
			key: 'group_type',
			label: 'Group Type',
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
	<TabHeader title="Groups" subtitle="Create custom groups to improve topology visualization">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" onclick={handleCreateGroup}
				><Plus class="h-5 w-5" />Create Group</button
			>
		</svelte:fragment>
	</TabHeader>

	{#if isLoading}
		<Loading />
	{:else if groupsData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No groups configured yet"
			subtitle="Groups define clusters or paths of nodes for visualization"
			onClick={handleCreateGroup}
			cta="Create your first group"
		/>
	{:else}
		<DataControls
			items={groupsData}
			fields={groupFields}
			storageKey="scanopy-groups-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Group,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<GroupCard
					group={item}
					selected={isSelected}
					{onSelectionChange}
					{viewMode}
					onEdit={() => handleEditGroup(item)}
					onDelete={() => handleDeleteGroup(item)}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<!-- Modal -->
<GroupEditModal
	isOpen={showGroupEditor}
	group={editingGroup}
	onCreate={handleGroupCreate}
	onUpdate={handleGroupUpdate}
	onClose={handleCloseGroupEditor}
/>
