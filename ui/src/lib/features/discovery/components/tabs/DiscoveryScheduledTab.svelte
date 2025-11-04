<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import { initiateDiscovery } from '../../SSEStore';
	import type { Discovery } from '../../types/base';
	import {
		createDiscovery,
		deleteDiscovery,
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
	import DiscoveryRunCard from '../cards/DiscoveryScheduledCard.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';

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

	let fields: FieldConfig<Discovery>[];

	$: fields = [
		...discoveryFields($daemons),
		{
			key: 'run_type',
			label: 'Run Type',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (item) => item.run_type.type
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
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

	{#if $loading}
		<Loading />
	{:else if $discoveries.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No discovery sessions are scheduled"
			subtitle=""
			onClick={handleCreateDiscovery}
			cta="Schedule a discovery session"
		/>
	{:else}
		<DataControls
			items={$discoveries.filter(
				(d) => d.run_type.type == 'AdHoc' || d.run_type.type == 'Scheduled'
			)}
			{fields}
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
	daemons={$daemons}
	hosts={$hosts}
	discovery={editingDiscovery}
	onCreate={handleDiscoveryCreate}
	onUpdate={handleDiscoveryUpdate}
	onClose={handleCloseEditor}
/>
