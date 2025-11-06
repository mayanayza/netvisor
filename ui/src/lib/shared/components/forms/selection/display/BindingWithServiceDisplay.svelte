<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import {
		getBindingDisplayName,
		getServiceForBinding,
		getServiceHost
	} from '$lib/features/services/store';

	export const BindingWithServiceDisplay: EntityDisplayComponent<Binding, object> = {
		getId: (binding: Binding) => binding.id,
		getLabel: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			return service?.name || 'Unknown Service';
		},
		getDescription: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (service) {
				const host = get(getServiceHost(service?.id));
				if (host) {
					return 'Host: ' + host.name;
				}
			}

			return 'Unknown Host';
		},
		getIcon: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return entities.getIconComponent('Service');

			return serviceDefinitions.getIconComponent(service.service_definition);
		},
		getIconColor: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return 'text-secondary';

			return serviceDefinitions.getColorHelper(service.service_definition).icon;
		},
		getTags: (binding: Binding) => [
			{
				label: get(getBindingDisplayName(binding)),
				color: entities.getColorHelper('Interface').string
			}
		],
		getCategory: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import type { Binding } from '$lib/features/services/types/base';
	import { get } from 'svelte/store';

	export let item: Binding;
	export let context = {};
</script>

<ListSelectItem {context} {item} displayComponent={BindingWithServiceDisplay} />
