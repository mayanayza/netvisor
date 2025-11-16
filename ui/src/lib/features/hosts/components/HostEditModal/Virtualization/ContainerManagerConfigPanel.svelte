<script lang="ts">
	import type { Service } from '$lib/features/services/types/base';
	import { getServicesForHost, services } from '$lib/features/services/store';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import { get } from 'svelte/store';
	import type { FormApi } from '$lib/shared/components/forms/types';

	export let service: Service;
	export let onChange: (updatedService: Service) => void;
	export let formApi: FormApi;

	$: serviceMetadata = serviceDefinitions.getItem(service.service_definition);

	$: managedContainers = $services.filter(
		(s) =>
			s.virtualization &&
			s.virtualization?.type == 'Docker' &&
			s.virtualization.details.service_id == service.id
	);
	$: containerIds = managedContainers.map((s) => s.id);

	// Filter out services on other hosts and already managed containers
	$: selectableContainers = $services.filter(
		(s) => s.host_id === service.host_id && s.id !== service.id && !containerIds.includes(s.id)
	);

	function handleAddContainer(serviceId: string) {
		let services = getServicesForHost(service.host_id);
		let containerizedService = get(services).find((s) => s.id == serviceId);

		if (containerizedService) {
			containerizedService.virtualization = {
				type: 'Docker',
				details: {
					container_id: null,
					container_name: null,
					service_id: service.id
				}
			};

			onChange(containerizedService);
		}
	}

	function handleRemoveContainer(index: number) {
		let removedContainer = managedContainers.at(index);

		if (removedContainer) {
			removedContainer.virtualization = null;
			onChange(removedContainer);
		}
	}
</script>

<div class="space-y-6">
	<ListManager
		label="Containers"
		helpText="Manage containers controlled by this {serviceMetadata?.name
			? serviceMetadata.name
			: ''} instance"
		placeholder="Add container service..."
		emptyMessage="No containers managed by this service yet. Add services that run in containers on this host."
		allowReorder={false}
		allowDuplicates={false}
		{formApi}
		allowItemEdit={() => false}
		showSearch={true}
		options={selectableContainers}
		items={managedContainers}
		getItemContext={() => ({})}
		optionDisplayComponent={ServiceDisplay}
		itemDisplayComponent={ServiceDisplay}
		onAdd={handleAddContainer}
		onRemove={handleRemoveContainer}
	/>
</div>
