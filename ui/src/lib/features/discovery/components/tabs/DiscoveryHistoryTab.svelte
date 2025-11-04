<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { Discovery } from '../../types/base';
	import {
		createDiscovery,
		discoveries,
		discoveryFields,
		getDiscoveries,
		updateDiscovery
	} from '../../store';
	import DiscoveryEditModal from '../DiscoveryModal/DiscoveryEditModal.svelte';
	import { daemons, getDaemons } from '$lib/features/daemons/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { getHosts, hosts } from '$lib/features/hosts/store';
	import DiscoveryHistoryCard from '../cards/DiscoveryHistoryCard.svelte';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';
	import type { FieldConfig } from '$lib/shared/components/data/types';

	const loading = loadData([getDiscoveries, getDaemons, getSubnets, getHosts]);

	let showDiscoveryModal = false;
	let editingDiscovery: Discovery | null = null;

	function handleEditDiscovery(discovery: Discovery) {
		editingDiscovery = discovery;
		showDiscoveryModal = true;
	}

	async function handleDiscoveryCreate(data: Discovery) {
		const result = await createDiscovery(data);
		if (result?.success) {
			showDiscoveryModal = false;
			editingDiscovery = null;
		}
	}

	async function handleDiscoveryUpdate(id: string, data: Discovery) {
		const result = await updateDiscovery(data);
		if (result?.success) {
			showDiscoveryModal = false;
			editingDiscovery = null;
		}
	}

	function handleCloseEditor() {
		showDiscoveryModal = false;
		editingDiscovery = null;
	}

	let fields: FieldConfig<Discovery>[];

	$: fields = [
		...discoveryFields($daemons),
		{
			key: 'started_at',
			label: 'Started At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.started_at ? formatTimestamp(results.started_at) : 'Unknown';
			}
		},
		{
			key: 'finished_at',
			label: 'Finished At',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				return results && results.finished_at ? formatTimestamp(results.finished_at) : 'Unknown';
			}
		},
		{
			key: 'duration',
			label: 'Duration',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue: (item) => {
				const results = item.run_type.type == 'Historical' ? item.run_type.results : null;
				if (results && results.finished_at && results.started_at) {
					return formatDuration(results.started_at, results.finished_at);
				}
				return 'Unknown';
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Discovery History" subtitle="Review historical discovery sessions" />

	{#if $loading}
		<Loading />
	{:else if $discoveries.length === 0}
		<!-- Empty state -->
		<EmptyState title="No discovery sessions have been run" subtitle="" />
	{:else}
		<DataControls
			items={$discoveries.filter((d) => d.run_type.type == 'Historical')}
			{fields}
			storageKey="netvisor-discovery-historical-table-state"
		>
			{#snippet children(item: Discovery, viewMode: 'card' | 'list')}
				<DiscoveryHistoryCard discovery={item} onView={handleEditDiscovery} {viewMode} />
			{/snippet}
		</DataControls>
	{/if}
</div>

<DiscoveryEditModal
	isOpen={showDiscoveryModal}
	hosts={$hosts}
	daemons={$daemons}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
