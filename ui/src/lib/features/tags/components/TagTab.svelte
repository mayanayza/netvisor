<script lang="ts">
	import {
		useTagsQuery,
		useCreateTagMutation,
		useUpdateTagMutation,
		useDeleteTagMutation,
		useBulkDeleteTagsMutation
	} from '../queries';
	import TagCard from './TagCard.svelte';
	import TagEditModal from './TagEditModal.svelte';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { Tag } from '../types/base';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { permissions } from '$lib/shared/stores/metadata';

	let showTagEditor = $state(false);
	let editingTag: Tag | null = $state(null);

	// Queries and mutations
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const tagsQuery = useTagsQuery();
	const createTagMutation = useCreateTagMutation();
	const updateTagMutation = useUpdateTagMutation();
	const deleteTagMutation = useDeleteTagMutation();
	const bulkDeleteTagsMutation = useBulkDeleteTagsMutation();

	// Derived state
	let tags = $derived(tagsQuery.data ?? []);
	let isLoading = $derived(tagsQuery.isLoading);

	let canManageNetworks = $derived(
		(currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities) || false
	);

	let allowBulkDelete = $derived(
		currentUser ? permissions.getMetadata(currentUser.permissions).manage_org_entities : false
	);

	function handleCreateTag() {
		editingTag = null;
		showTagEditor = true;
	}

	function handleEditTag(tag: Tag) {
		editingTag = tag;
		showTagEditor = true;
	}

	async function handleDeleteTag(tag: Tag) {
		if (confirm(`Are you sure you want to delete "${tag.name}"?`)) {
			await deleteTagMutation.mutateAsync(tag.id);
		}
	}

	async function handleTagCreate(data: Tag) {
		await createTagMutation.mutateAsync(data);
		showTagEditor = false;
		editingTag = null;
	}

	async function handleTagUpdate(_id: string, data: Tag) {
		await updateTagMutation.mutateAsync(data);
		showTagEditor = false;
		editingTag = null;
	}

	function handleCloseTagEditor() {
		showTagEditor = false;
		editingTag = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} tags?`)) {
			await bulkDeleteTagsMutation.mutateAsync(ids);
		}
	}

	const tagFields: FieldConfig<Tag>[] = [
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
			key: 'color',
			label: 'Color',
			type: 'string',
			searchable: false,
			filterable: true,
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
</script>

<div class="space-y-6">
	<TabHeader title="Tags" subtitle="Manage organization-wide tags for categorizing entities">
		<svelte:fragment slot="actions">
			{#if canManageNetworks}
				<button class="btn-primary flex items-center" onclick={handleCreateTag}>
					<Plus class="h-5 w-5" />Create Tag
				</button>
			{/if}
		</svelte:fragment>
	</TabHeader>

	{#if isLoading}
		<Loading />
	{:else if tags.length === 0}
		<EmptyState
			title="No tags configured yet"
			subtitle="Tags help you organize and filter hosts, services, and other entities"
			onClick={handleCreateTag}
			cta="Create your first tag"
		/>
	{:else}
		<DataControls
			items={tags}
			fields={tagFields}
			{allowBulkDelete}
			storageKey="scanopy-tags-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Tag,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<TagCard
					tag={item}
					selected={isSelected}
					{onSelectionChange}
					{viewMode}
					onEdit={handleEditTag}
					onDelete={handleDeleteTag}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<TagEditModal
	isOpen={showTagEditor}
	tag={editingTag}
	onCreate={handleTagCreate}
	onUpdate={handleTagUpdate}
	onClose={handleCloseTagEditor}
	onDelete={editingTag ? () => handleDeleteTag(editingTag!) : null}
/>
