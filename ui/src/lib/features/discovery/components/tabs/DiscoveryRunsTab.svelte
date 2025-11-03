<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { initiateDiscovery } from '../../SSEStore';
	import type { Discovery } from '../../types/base';
	import {
		createDiscovery,
		deleteDiscovery,
		discoveries,
		getDiscoveries,
		updateDiscovery
	} from '../../store';
	import DiscoveryEditModal from '../DiscoveryModal/DiscoveryEditModal.svelte';
	import { daemons, getDaemons } from '$lib/features/daemons/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import DiscoveryHistoryCard from '../cards/DiscoveryHistoryCard.svelte';
	import DiscoveryRunCard from '../cards/DiscoveryRunCard.svelte';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';

	export let runType: 'Historical' | 'Scheduled' = 'Historical';

	const loading = loadData([getDiscoveries, getDaemons, getSubnets, getHosts]);

	let showDiscoveryModal = false;
	let editingDiscovery: Discovery | null = null;

	function handleCreateDiscovery() {
		editingDiscovery = null;
		showDiscoveryModal = true;
	}

	function handleEditDiscovery(discovery: Discovery) {
		editingDiscovery = discovery;
		showDiscoveryModal = true;
	}

	function handleDeleteDiscovery(discovery: Discovery) {
		if (confirm(`Are you sure you want to delete "${discovery.name}"?`)) {
			deleteDiscovery(discovery.id);
		}
	}

	async function handleDiscoveryRun(discovery: Discovery) {
		await initiateDiscovery(discovery.id);
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

	// Define field configuration for the DataTableControls
	const discoveryFields: FieldConfig<Discovery>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
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
			key: 'discovery_type',
			label: 'Discovery Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => item.discovery_type.type
		}
	];

	if (runType == 'Historical') {
		discoveryFields.push({
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
		});
		discoveryFields.push({
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
		});
		discoveryFields.push({
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
		});
	} else {
		discoveryFields.push({
			key: 'run_type',
			label: 'Run Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => item.run_type.type
		});
	}
</script>

<div class="space-y-6">
	<!-- Header -->
	{#if runType == 'Scheduled'}
		<TabHeader
			title="Scheduled Discovery"
			subtitle="Schedule discovery sessions"
			buttons={[
				{
					onClick: handleCreateDiscovery,
					cta: 'Schedule Discovery'
				}
			]}
		/>
	{:else}
		<TabHeader title="Discovery History" subtitle="Review historical discovery sessions" />
	{/if}
	{#if $loading}
		<Loading />
	{:else if $discoveries.length === 0 && runType == 'Scheduled'}
		<!-- Empty state -->
		<EmptyState
			title="No discovery sessions are scheduled"
			subtitle=""
			onClick={handleCreateDiscovery}
			cta="Schedule a discovery session"
		/>
	{:else if $discoveries.length === 0 && runType == 'Historical'}
		<!-- Empty state -->
		<EmptyState title="No discovery sessions have been run" subtitle="" />
	{:else if runType == 'Historical'}
		<DataControls
			items={$discoveries.filter((d) => d.run_type.type == 'Historical')}
			fields={discoveryFields}
			storageKey="netvisor-discovery-historical-table-state"
		>
			{#snippet children(item: Discovery, viewMode: 'card' | 'list')}
				<DiscoveryHistoryCard discovery={item} onView={handleEditDiscovery} {viewMode} />
			{/snippet}
		</DataControls>
	{:else}
		<DataControls
			items={$discoveries.filter(
				(d) => d.run_type.type == 'AdHoc' || d.run_type.type == 'Scheduled'
			)}
			fields={discoveryFields}
			storageKey="netvisor-discovery-scheduled-table-state"
		>
			{#snippet children(item: Discovery, viewMode: 'card' | 'list')}
				<DiscoveryRunCard
					discovery={item}
					onDelete={handleDeleteDiscovery}
					onEdit={handleEditDiscovery}
					onRun={handleDiscoveryRun}
					{viewMode}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<DiscoveryEditModal
	isOpen={showDiscoveryModal}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
