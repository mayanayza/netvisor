<script lang="ts">
	import type { Service } from '$lib/features/services/types/base';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { FormApi } from '$lib/shared/components/forms/types';

	interface Props {
		service: Service;
		onChange: (updatedService: Service) => void;
		formApi: FormApi;
	}

	let { service, onChange, formApi }: Props = $props();

	// TanStack Query hooks
	const servicesQuery = useServicesQuery();
	let servicesData = $derived(servicesQuery.data ?? []);

	let serviceMetadata = $derived(serviceDefinitions.getItem(service.service_definition));

	let managedContainers = $derived(
		servicesData.filter(
			(s) =>
				s.virtualization &&
				s.virtualization?.type == 'Docker' &&
				s.virtualization.details.service_id == service.id
		)
	);

	let containerIds = $derived(managedContainers.map((s) => s.id));

	// Filter out services on other hosts and already managed containers
	let selectableContainers = $derived(
		servicesData.filter(
			(s) => s.host_id === service.host_id && s.id !== service.id && !containerIds.includes(s.id)
		)
	);

	function handleAddContainer(serviceId: string) {
		const servicesForHost = servicesData.filter((s) => s.host_id === service.host_id);
		const containerizedService = servicesForHost.find((s) => s.id == serviceId);

		if (containerizedService) {
			const updatedService = {
				...containerizedService,
				virtualization: {
					type: 'Docker' as const,
					details: {
						container_id: null,
						container_name: null,
						service_id: service.id
					}
				}
			};

			onChange(updatedService);
		}
	}

	function handleRemoveContainer(index: number) {
		const removedContainer = managedContainers.at(index);

		if (removedContainer) {
			const updatedService = {
				...removedContainer,
				virtualization: null
			};
			onChange(updatedService);
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
