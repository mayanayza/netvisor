<script lang="ts" context="module">
	import { concepts, serviceDefinitions } from '$lib/shared/stores/metadata';

	interface InterfaceId {
		interfaceId: string | null;
	}

	export const ServiceDisplay: EntityDisplayComponent<Service, InterfaceId> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service, context) => {
			let descriptionItems = [];

			// Filter bindings relevant to the interface(s)
			let bindingsOnInterface = service.bindings.filter((b) =>
				b.interface_id ? context.interfaceId == b.interface_id || context.interfaceId == null : true
			);

			// If specific interface(s) provided, show port details
			if (context.interfaceId && context.interfaceId.length > 0) {
				const portBindings = bindingsOnInterface.filter((b) => b.type === 'Port');

				let bindingDescriptions: string[] = [];

				// Add port bindings
				if (portBindings.length > 0) {
					for (const binding of portBindings) {
						const port = binding.port_id ? get(getPortFromId(binding.port_id)) : null;

						if (port) {
							bindingDescriptions.push(formatPort(port));
						}
					}
				}

				if (bindingDescriptions.length > 0) {
					descriptionItems.push('Listening on ports: ' + bindingDescriptions.join(', '));
				}
			} else {
				// No specific interface - show binding count across all interfaces
				descriptionItems.push(
					`${bindingsOnInterface.length} binding${bindingsOnInterface.length > 1 ? 's' : ''} on all interfaces`
				);
			}

			if (service.source.type == 'DiscoveryWithMatch') {
				const confidence = service.source.details.confidence;
				descriptionItems.push(matchConfidenceLabel(confidence));
			}

			return descriptionItems.join(' · ');
		},
		getIcon: (service: Service) => {
			return serviceDefinitions.getIconComponent(service.service_definition);
		},
		getIconColor: (service: Service) =>
			serviceDefinitions.getColorHelper(service.service_definition).icon,
		getTags: (service: Service) => {
			let tags = [];

			if (service.virtualization) {
				const tag: TagProps = {
					label: service.virtualization.type,
					color: concepts.getColorHelper('Virtualization').string
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
	import type { Service } from '$lib/features/services/types/base';
	import type { TagProps } from '$lib/shared/components/data/types';
	import { matchConfidenceLabel } from '$lib/shared/types';
	import { getPortFromId } from '$lib/features/hosts/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { get } from 'svelte/store';

	export let item: Service;
	export let context: InterfaceId;
</script>

<ListSelectItem {item} {context} displayComponent={ServiceDisplay} />
