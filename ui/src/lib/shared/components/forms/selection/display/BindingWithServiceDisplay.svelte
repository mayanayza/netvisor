<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getServiceForBinding, getServiceHost } from '$lib/features/services/store';

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
					return host.name;
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
		getTags: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return [];

			const tags = [];

			const iface = binding.interface_id
				? get(getInterfaceFromId(binding.interface_id))
				: ALL_INTERFACES;

			if (iface) {
				tags.push({
					label: formatInterface(iface),
					color: entities.getColorHelper('Interface').string
				});
			}

			if (binding.type == 'Port') {
				const port = get(getPortFromId(binding.port_id));

				if (port) {
					tags.push({
						label: formatPort(port),
						color: entities.getColorHelper('Port').string
					});
				}
			}

			return tags;
		},
		getCategory: (binding: Binding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		}
	};
</script>

<script lang="ts">
	import { ALL_INTERFACES } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import { formatInterface, getInterfaceFromId, getPortFromId } from '$lib/features/hosts/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import type { Binding } from '$lib/features/services/types/base';
	import { get } from 'svelte/store';

	export let item: Binding;
	export let context = {};
</script>

<ListSelectItem {context} {item} displayComponent={BindingWithServiceDisplay} />
