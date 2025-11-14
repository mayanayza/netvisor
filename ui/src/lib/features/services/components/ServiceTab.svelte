<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import {
		deleteService,
		getServices,
		services,
		updateService
	} from '$lib/features/services/store';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import { networks } from '$lib/features/networks/store';
	import type { Service } from '../types/base';
	import { getHosts, hosts } from '$lib/features/hosts/store';
	import ServiceCard from './ServiceCard.svelte';
	import { matchConfidenceLabel } from '$lib/shared/types';
	import ServiceEditModal from './ServiceEditModal.svelte';

	const loading = loadData([getServices, getHosts]);

	let showServiceEditor = false;
	let editingService: Service | null = null;

	function handleEditService(service: Service) {
		editingService = service;
		showServiceEditor = true;
	}
	function handleCloseServiceEditor() {
		showServiceEditor = false;
		editingService = null;
	}

	$: serviceHosts = new Map(
		$services.map((service) => {
			const foundHost = $hosts.find((h) => {
				return h.id == service.host_id;
			});

			return [service.id, foundHost];
		})
	);

	function handleDeleteService(service: Service) {
		if (confirm(`Are you sure you want to delete "${service.name}"?`)) {
			deleteService(service.id);
		}
	}

	async function handleServiceUpdate(id: string, data: Service) {
		const result = await updateService(data);
		if (result?.success) {
			showServiceEditor = false;
			editingService = null;
		}
	}

	// Define field configuration for the DataTableControls
	const serviceFields: FieldConfig<Service>[] = [
		{
			key: 'name',
			label: 'Name',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true
		},
		{
			key: 'host',
			label: 'Host',
			type: 'string',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue: (service) => serviceHosts.get(service.id)?.name || 'Unknown Host'
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
			key: 'containerized_by',
			type: 'string',
			label: 'Containerized',
			searchable: true,
			filterable: true,
			sortable: true,
			getValue(item) {
				return (
					$services.find((s) => s.id == item.virtualization?.details.service_id)?.name ||
					'Not Containerized'
				);
			}
		},
		{
			key: 'confidence',
			label: 'Match Confidence',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: true,
			getValue(item) {
				return item.source.type == 'DiscoveryWithMatch'
					? matchConfidenceLabel(item.source.details)
					: 'N/A (Not a discovered service)';
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Services" subtitle="Manage services" />

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if $hosts.length === 0}
		<!-- Empty state -->
		<EmptyState title="No services configured yet" subtitle="" />
	{:else}
		<DataControls
			items={$services}
			fields={serviceFields}
			storageKey="netvisor-services-table-state"
		>
			{#snippet children(item: Service, viewMode: 'card' | 'list')}
				{@const host = serviceHosts.get(item.id)}
				{#if host}
					<ServiceCard
						service={item}
						{host}
						{viewMode}
						onDelete={handleDeleteService}
						onEdit={handleEditService}
					/>
				{/if}
			{/snippet}
		</DataControls>
	{/if}
</div>

{#if editingService}
	{@const editingServiceHost = serviceHosts.get(editingService.id)}
	{#if editingServiceHost}
		<ServiceEditModal
			service={editingService}
			host={editingServiceHost}
			isOpen={showServiceEditor}
			onUpdate={handleServiceUpdate}
			onClose={handleCloseServiceEditor}
		/>
	{/if}
{/if}
