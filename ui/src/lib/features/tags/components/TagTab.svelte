<script lang="ts">
	import { bulkDeleteTags, createTag, deleteTag, getTags, tags, updateTag } from '../store';
	import TagCard from './TagCard.svelte';
	import TagEditModal from './TagEditModal.svelte';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import type { Tag } from '../types/base';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';

	let showTagEditor = false;
	let editingTag: Tag | null = null;

	const loading = loadData([getTags]);

	function handleCreateTag() {
		editingTag = null;
		showTagEditor = true;
	}

	function handleEditTag(tag: Tag) {
		editingTag = tag;
		showTagEditor = true;
	}

	function handleDeleteTag(tag: Tag) {
		if (confirm(`Are you sure you want to delete "${tag.name}"?`)) {
			deleteTag(tag.id);
		}
	}

	async function handleTagCreate(data: Tag) {
		const result = await createTag(data);
		if (result?.success) {
			showTagEditor = false;
			editingTag = null;
		}
	}

	async function handleTagUpdate(_id: string, data: Tag) {
		const result = await updateTag(data);
		if (result?.success) {
			showTagEditor = false;
			editingTag = null;
		}
	}

	function handleCloseTagEditor() {
		showTagEditor = false;
		editingTag = null;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} tags?`)) {
			await bulkDeleteTags(ids);
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
			<button class="btn-primary flex items-center" on:click={handleCreateTag}>
				<Plus class="h-5 w-5" />Create Tag
			</button>
		</svelte:fragment>
	</TabHeader>

	{#if $loading}
		<Loading />
	{:else if $tags.length === 0}
		<EmptyState
			title="No tags configured yet"
			subtitle="Tags help you organize and filter hosts, services, and other entities"
			onClick={handleCreateTag}
			cta="Create your first tag"
		/>
	{:else}
		<DataControls
			items={$tags}
			fields={tagFields}
			storageKey="netvisor-tags-table-state"
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
