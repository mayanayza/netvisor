<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	export const VirtualizationManagerServiceDisplay: EntityDisplayComponent<Service, object> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service) => {
			let container_count = get(services).filter(
				(s) => s.virtualization && s.virtualization.details.service_id == service.id
			).length;
			let vm_count = get(hosts).filter(
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
					color: entities.getColorHelper('Virtualization').string
				};

				tags.push(tag);
			}

			return tags;
		},
		getIsDisabled: () => false,
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import type { Service } from '$lib/features/services/types/base';
	import type { TagProps } from '$lib/shared/components/data/types';
	import { services } from '$lib/features/services/store';
	import { get } from 'svelte/store';
	import { hosts } from '$lib/features/hosts/store';

	export let item: Service;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={VirtualizationManagerServiceDisplay} />
