<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { getActiveSessions, sessions } from '../../SSEStore';
	import DiscoverySessionCard from '../cards/DiscoverySessionCard.svelte';
	import { type DiscoveryUpdatePayload } from '../../types/api';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { daemons, getDaemons } from '$lib/features/daemons/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { onMount } from 'svelte';

	const loading = loadData([getDaemons, getActiveSessions]);

	let sessionsList = $state<DiscoveryUpdatePayload[]>([]);

	onMount(() => {
		const unsubscribe = sessions.subscribe((value) => {
			sessionsList = value;
		});

		return unsubscribe;
	});

	let discoveryFields = $derived.by((): FieldConfig<DiscoveryUpdatePayload>[] => [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'discovery_type',
			label: 'Discovery Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => item.discovery_type.type
		},
		{
			key: 'daemon',
			label: 'Daemon',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => {
				const daemon = $daemons.find((d) => d.id == item.daemon_id);
				return daemon ? daemon.ip : 'Unknown Daemon';
			}
		},
		{
			key: 'phase',
			label: 'Phase',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true
		},
		{
			key: 'started_at',
			label: 'Started At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => (item.started_at ? formatTimestamp(item.started_at) : 'Not Started')
		},
		{
			key: 'finished_at',
			label: 'Finished At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => (item.finished_at ? formatTimestamp(item.finished_at) : 'Not Started')
		}
	]);
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Discovery Sessions" subtitle="Monitor active discovery sessions" />
	{#if $loading}
		<Loading />
	{:else if sessionsList.length === 0}
		<!-- Empty state -->
		<EmptyState title="No discovery sessions running" subtitle="" />
	{:else}
		<DataControls
			items={sessionsList}
			fields={discoveryFields}
			storageKey="netvisor-discovery-session-table-state"
		>
			{#snippet children(item: DiscoveryUpdatePayload, viewMode: 'card' | 'list')}
				<DiscoverySessionCard session={item} {viewMode} />
			{/snippet}
		</DataControls>
	{/if}
</div>
