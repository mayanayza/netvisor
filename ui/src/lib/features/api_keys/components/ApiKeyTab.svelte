<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { getDaemons } from '$lib/features/daemons/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { networks } from '$lib/features/networks/store';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import CreateApiKeyModal from './ApiKeyModal.svelte';
	import type { ApiKey } from '../types/base';
	import { apiKeys, bulkDeleteApiKeys, deleteApiKey, getApiKeys, updateApiKey } from '../store';
	import ApiKeyCard from './ApiKeyCard.svelte';
	import { Plus } from 'lucide-svelte';

	const loading = loadData([getApiKeys, getDaemons]);

	let showCreateApiKeyModal = false;
	let editingApiKey: ApiKey | null = null;

	async function handleDeleteApiKey(apiKey: ApiKey) {
		if (confirm(`Are you sure you want to delete api key "${apiKey.name}"?`)) {
			deleteApiKey(apiKey.id);
		}
	}

	async function handleUpdateApiKey(apiKey: ApiKey) {
		await updateApiKey(apiKey);
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
			await bulkDeleteApiKeys(ids);
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
				return $networks.find((n) => n.id == item.network_id)?.name || 'Unknown Network';
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="API Keys" subtitle="Manage API Keys">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" on:click={handleCreateApiKey}
				><Plus class="h-5 w-5" />Create API Key</button
			>
		</svelte:fragment>
	</TabHeader>
	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $apiKeys.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No API Keys configured yet"
			subtitle=""
			onClick={handleCreateApiKey}
			cta="Create your first API Key"
		/>
	{:else}
		<DataControls
			items={$apiKeys}
			fields={apiKeyFields}
			onBulkDelete={handleBulkDelete}
			storageKey="netvisor-api-keys-table-state"
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
