<script lang="ts">
	import HostCard from './HostCard.svelte';
	import type {
		Host,
		CreateHostWithServicesRequest,
		UpdateHostWithServicesRequest
	} from '../types/base';
	import { toHostPrimitive } from '../store';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import HostEditor from './HostEditModal/HostEditor.svelte';
	import HostConsolidationModal from './HostConsolidationModal.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { Plus } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import {
		useHostsQuery,
		useCreateHostMutation,
		useUpdateHostMutation,
		useDeleteHostMutation,
		useBulkDeleteHostsMutation,
		useConsolidateHostsMutation
	} from '../queries';
	import { useGroupsQuery } from '$lib/features/groups/queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const hostsQuery = useHostsQuery();
	const groupsQuery = useGroupsQuery();
	const servicesQuery = useServicesQuery();
	const networksQuery = useNetworksQuery();
	useDaemonsQuery();

	// Mutations
	const createHostMutation = useCreateHostMutation();
	const updateHostMutation = useUpdateHostMutation();
	const deleteHostMutation = useDeleteHostMutation();
	const bulkDeleteHostsMutation = useBulkDeleteHostsMutation();
	const consolidateHostsMutation = useConsolidateHostsMutation();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data ?? []);
	let groupsData = $derived(groupsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let isLoading = $derived(hostsQuery.isPending);

	let showHostEditor = $state(false);
	let editingHost = $state<Host | null>(null);

	let otherHost = $state<Host | null>(null);
	let showHostConsolidationModal = $state(false);

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
				if (host.virtualization) {
					const virtualizationService = servicesData.find(
						(s) => s.id === host.virtualization?.details.service_id
					);
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

	let hostGroups = $derived(
		new Map(
			hostsData.map((host) => {
				const foundGroups = groupsData.filter((g) => {
					return (g.binding_ids ?? []).some((b) => {
						// Use servicesData instead of getServiceForBinding to maintain reactivity
						let service = servicesData.find((s) => s.bindings.map((sb) => sb.id).includes(b));
						// Check if the service belongs to this host
						if (service) return service.host_id === host.id;
						return false;
					});
				});

				return [host.id, foundGroups];
			})
		)
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
			deleteHostMutation.mutate(host.id);
		}
	}

	async function handleHostCreate(data: CreateHostWithServicesRequest) {
		try {
			await createHostMutation.mutateAsync(data);
			showHostEditor = false;
			editingHost = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleHostCreateAndContinue(data: CreateHostWithServicesRequest) {
		try {
			const result = await createHostMutation.mutateAsync(data);
			// Keep modal open and switch to edit mode with the created host
			// Extract Host primitive from HostResponse
			editingHost = toHostPrimitive(result);
		} catch {
			// Error handled by mutation
		}
	}

	async function handleHostUpdate(data: UpdateHostWithServicesRequest) {
		try {
			await updateHostMutation.mutateAsync(data);
			showHostEditor = false;
			editingHost = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleConsolidateHosts(destinationHostId: string, otherHostId: string) {
		try {
			await consolidateHostsMutation.mutateAsync({ destinationHostId, otherHostId });
			showHostConsolidationModal = false;
			otherHost = null;
		} catch {
			// Error handled by mutation
		}
	}

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Hosts?`)) {
			await bulkDeleteHostsMutation.mutateAsync(ids);
		}
	}

	async function handleHostHide(host: Host) {
		const updatedHost = { ...host, hidden: !host.hidden };
		await updateHostMutation.mutateAsync({
			host: updatedHost,
			interfaces: null,
			ports: null,
			services: null
		});
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
			<button class="btn-primary flex items-center" onclick={handleCreateHost}
				><Plus class="h-5 w-5" />Create Host</button
			>
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if hostsData.length === 0}
		<!-- Empty state -->
		<EmptyState
			title="No hosts configured yet"
			subtitle=""
			onClick={handleCreateHost}
			cta="Create your first host"
		/>
	{:else}
		<DataControls
			items={hostsData}
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
	onCreateAndContinue={handleHostCreateAndContinue}
	onUpdate={handleHostUpdate}
	onClose={handleCloseHostEditor}
/>

<HostConsolidationModal
	isOpen={showHostConsolidationModal}
	{otherHost}
	onConsolidate={handleConsolidateHosts}
	onClose={() => (showHostConsolidationModal = false)}
/>
