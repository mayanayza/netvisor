<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import CreateApiKeyModal from './ApiKeyModal.svelte';
	import type { ApiKey } from '../types/base';
	import ApiKeyCard from './ApiKeyCard.svelte';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useApiKeysQuery,
		useUpdateApiKeyMutation,
		useDeleteApiKeyMutation,
		useBulkDeleteApiKeysMutation
	} from '../queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const apiKeysQuery = useApiKeysQuery();
	const networksQuery = useNetworksQuery();
	// Daemons query to ensure data is loaded (needed for API key display)
	useDaemonsQuery();

	// Mutations
	const updateApiKeyMutation = useUpdateApiKeyMutation();
	const deleteApiKeyMutation = useDeleteApiKeyMutation();
	const bulkDeleteApiKeysMutation = useBulkDeleteApiKeysMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let apiKeysData = $derived(apiKeysQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(apiKeysQuery.isPending);

	let showCreateApiKeyModal = $state(false);
	let editingApiKey = $state<ApiKey | null>(null);

	async function handleDeleteApiKey(apiKey: ApiKey) {
		if (confirm(`Are you sure you want to delete api key "${apiKey.name}"?`)) {
			deleteApiKeyMutation.mutate(apiKey.id);
		}
	}

	async function handleUpdateApiKey(apiKey: ApiKey) {
		await updateApiKeyMutation.mutateAsync(apiKey);
		showCreateApiKeyModal = false;
		editingApiKey = null;
	}

	function handleCreateApiKey() {
		showCreateApiKeyModal = true;
		editingApiKey = null;
	}

	function handleCloseCreateApiKey() {
		showCreateApiKeyModal = false;
		editingApiKey = null;
	}

	function handleEditApiKey(apiKey: ApiKey) {
		showCreateApiKeyModal = true;
		editingApiKey = apiKey;
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Api Keys?`)) {
			await bulkDeleteApiKeysMutation.mutateAsync(ids);
		}
	}

	const apiKeyFields: FieldConfig<ApiKey>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
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
	<TabHeader title="API Keys" subtitle="Manage API Keys">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" onclick={handleCreateApiKey}
				><Plus class="h-5 w-5" />Create API Key</button
			>
		</svelte:fragment>
	</TabHeader>
	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if apiKeysData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No API Keys configured yet"
			subtitle=""
			onClick={handleCreateApiKey}
			cta="Create your first API Key"
		/>
	{:else}
		<DataControls
			items={apiKeysData}
			fields={apiKeyFields}
			onBulkDelete={handleBulkDelete}
			storageKey="scanopy-api-keys-table-state"
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: ApiKey,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<ApiKeyCard
					apiKey={item}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
					onDelete={handleDeleteApiKey}
					onEdit={handleEditApiKey}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<CreateApiKeyModal
	isOpen={showCreateApiKeyModal}
	onClose={handleCloseCreateApiKey}
	onUpdate={handleUpdateApiKey}
	apiKey={editingApiKey}
/>
