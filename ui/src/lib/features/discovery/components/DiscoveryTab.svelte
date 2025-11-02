<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { sessions } from '../store';
	import DiscoveryCard from './DiscoveryCard.svelte';
	import { type DiscoveryUpdatePayload } from '../types/api';

	console.log($sessions);

	// Define field configuration for the DataTableControls
	const discoveryFields: FieldConfig<DiscoveryUpdatePayload>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Discovery" subtitle="Run discovery sessions" />

	{#if $sessions.length === 0}
		<!-- Empty state -->
		<EmptyState title="No discovery sessions running" subtitle="" />
	{:else}
		<DataControls
			items={$sessions}
			fields={discoveryFields}
			storageKey="netvisor-discovery-table-state"
		>
			{#snippet children(item: DiscoveryUpdatePayload, viewMode: 'card' | 'list')}
				<DiscoveryCard session={item} {viewMode} />
			{/snippet}
		</DataControls>
	{/if}
</div>
