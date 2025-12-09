<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getBindingDisplayName, getServiceForBinding } from '$lib/features/services/store';

	export const BindingWithServiceDisplay: EntityDisplayComponent<Binding, object> = {
		getId: (binding: Binding) => binding.id,
		getLabel: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			return service?.name || 'Unknown Service';
		},
		getDescription: () => '',
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
			const host = get(getHostFromId(service?.host_id));
			if (!host) return null;

			return host.name;
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import type { Binding } from '$lib/features/services/types/base';
	import { get } from 'svelte/store';
	import { getHostFromId } from '$lib/features/hosts/store';

	export let item: Binding;
	export let context = {};
</script>

<ListSelectItem {context} {item} displayComponent={BindingWithServiceDisplay} />
