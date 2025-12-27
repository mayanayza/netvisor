<script lang="ts" context="module">
	import { concepts, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Host } from '$lib/features/hosts/types/base';
	import type { Service } from '$lib/features/services/types/base';

	// Context for virtualization manager display - needs access to hosts and services for counts
	export interface VirtualizationManagerContext {
		hosts: Host[];
		services: Service[];
	}

	export const VirtualizationManagerServiceDisplay: EntityDisplayComponent<
		Service,
		VirtualizationManagerContext
	> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service, context: VirtualizationManagerContext) => {
			const hostsData = context?.hosts ?? [];
			const servicesData = context?.services ?? [];
			let container_count = servicesData.filter(
				(s) => s.virtualization && s.virtualization.details.service_id == service.id
			).length;
			let vm_count = hostsData.filter(
				(h) => h.virtualization && h.virtualization.details.service_id == service.id
			).length;
			return container_count > 0
				? container_count + ' container' + (container_count == 1 ? '' : 's')
				: vm_count + ' VM' + (vm_count == 1 ? '' : 's');
		},
		getIcon: (service: Service) => serviceDefinitions.getIconComponent(service.service_definition),
		getIconColor: (service: Service) =>
			serviceDefinitions.getColorHelper(service.service_definition).icon,
		getTags: (service: Service) => {
			let tags = [];

			if (service.virtualization) {
				const tag: TagProps = {
					label: service.virtualization.type,
					color: concepts.getColorHelper('Virtualization').color
				};

				tags.push(tag);
			}

			return tags;
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { TagProps } from '$lib/shared/components/data/types';

	export let item: Service;
	export let context: VirtualizationManagerContext = { hosts: [], services: [] };
</script>

<ListSelectItem {item} {context} displayComponent={VirtualizationManagerServiceDisplay} />
