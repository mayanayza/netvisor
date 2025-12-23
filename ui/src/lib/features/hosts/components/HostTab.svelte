<script lang="ts">
	import HostCard from './HostCard.svelte';
	import type { Host, HostWithServicesRequest } from '../types/base';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { getDaemons } from '$lib/features/daemons/store';
	import HostEditor from './HostEditModal/HostEditor.svelte';
	import HostConsolidationModal from './HostConsolidationModal.svelte';
	import {
		bulkDeleteHosts,
		consolidateHosts,
		createHost,
		deleteHost,
		getHosts,
		hosts,
		updateHost
	} from '../store';
	import { getGroups, groups } from '$lib/features/groups/store';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getServiceById, getServices, services } from '$lib/features/services/store';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { networks } from '$lib/features/networks/store';
	import { get } from 'svelte/store';
	import { Plus } from 'lucide-svelte';
	import { tags } from '$lib/features/tags/store';

	const loading = loadData([getHosts, getGroups, getServices, getDaemons]);

	let showHostEditor = false;
	let editingHost: Host | null = null;

	let otherHost: Host | null = null;
	let showHostConsolidationModal = false;

	// Define field configuration for the DataTableControls
	const hostFields: FieldConfig<Host>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'hostname',
			label: 'Hostname',
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
			key: 'virtualized_by',
			label: 'Virtualized By',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: true,
			getValue: (host) => {
				if (host.virtualization !== null) {
					const virtualizationService = get(getServiceById(host.virtualization.details.service_id));
					if (virtualizationService) {
						return virtualizationService?.name || 'Unknown Service';
					}
				}
				return 'Not Virtualized';
			}
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
			key: 'hidden',
			label: 'Hidden',
			type: 'boolean',
			searchable: false,
			filterable: true,
			sortable: false
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
					.map((id) => $tags.find((t) => t.id === id)?.name)
					.filter((name): name is string => !!name);
			}
		}
	];

	$: hostGroups = new Map(
		$hosts.map((host) => {
			const foundGroups = $groups.filter((g) => {
				return g.service_bindings.some((b) => {
					// Use $services instead of getServiceForBinding to maintain reactivity
					let service = $services.find((s) => s.bindings.map((sb) => sb.id).includes(b));
					if (service) return host.services.some((s) => s.id === service.id);
					return false;
				});
			});

			return [host.id, foundGroups];
		})
	);

	function handleCreateHost() {
		editingHost = null;
		showHostEditor = true;
	}

	function handleEditHost(host: Host) {
		editingHost = host;
		showHostEditor = true;
	}

	function handleStartConsolidate(host: Host) {
		otherHost = host;
		showHostConsolidationModal = true;
	}

	function handleDeleteHost(host: Host) {
		if (confirm(`Are you sure you want to delete "${host.name}"?`)) {
			deleteHost(host.id);
		}
	}

	async function handleHostCreate(data: HostWithServicesRequest) {
		const result = await createHost(data);
		if (result?.success) {
			showHostEditor = false;
			editingHost = null;
		}
	}

	async function handleHostUpdate(data: HostWithServicesRequest) {
		const result = await updateHost(data);
		if (result?.success) {
			showHostEditor = false;
			editingHost = null;
		}
	}

	async function handleConsolidateHosts(destination_host_id: string, other_host_id: string) {
		const result = await consolidateHosts(destination_host_id, other_host_id);
		if (result?.success) {
			showHostConsolidationModal = false;
			otherHost = null;
		}
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Hosts?`)) {
			await bulkDeleteHosts(ids);
		}
	}

	async function handleHostHide(host: Host) {
		host.hidden = !host.hidden;
		await updateHost({ host, services: null });
	}

	function handleCloseHostEditor() {
		showHostEditor = false;
		editingHost = null;
	}
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Hosts" subtitle="Manage hosts on the network">
		<svelte:fragment slot="actions">
			<button class="btn-primary flex items-center" on:click={handleCreateHost}
				><Plus class="h-5 w-5" />Create Host</button
			>
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $hosts.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No hosts configured yet"
			subtitle=""
			onClick={handleCreateHost}
			cta="Create your first host"
		/>
	{:else}
		<DataControls
			items={$hosts}
			fields={hostFields}
			storageKey="scanopy-hosts-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: Host,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				<HostCard
					host={item}
					hostGroups={hostGroups.get(item.id)}
					{viewMode}
					selected={isSelected}
					{onSelectionChange}
					onEdit={handleEditHost}
					onDelete={handleDeleteHost}
					onConsolidate={handleStartConsolidate}
					onHide={handleHostHide}
				/>
			{/snippet}
		</DataControls>
	{/if}
</div>

<HostEditor
	isOpen={showHostEditor}
	host={editingHost}
	onCreate={handleHostCreate}
	onUpdate={handleHostUpdate}
	onClose={handleCloseHostEditor}
/>

<HostConsolidationModal
	isOpen={showHostConsolidationModal}
	{otherHost}
	onConsolidate={handleConsolidateHosts}
	onClose={() => (showHostConsolidationModal = false)}
/>
