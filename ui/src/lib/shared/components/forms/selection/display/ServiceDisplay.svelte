<script lang="ts" module>
	import { concepts, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { useQueryClient } from '@tanstack/svelte-query';
	import { getPortByIdFromCache } from '$lib/features/ports/queries';

	interface InterfaceId {
		interfaceId: string | null;
		queryClient?: ReturnType<typeof useQueryClient>;
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
			if (context.interfaceId && context.interfaceId.length > 0 && context.queryClient) {
				const portBindings = bindingsOnInterface.filter((b) => b.type === 'Port');

				let bindingDescriptions: string[] = [];

				// Add port bindings
				if (portBindings.length > 0) {
					for (const binding of portBindings) {
						const port = binding.port_id
							? getPortByIdFromCache(context.queryClient, binding.port_id)
							: null;

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
	import type { Service } from '$lib/features/services/types/base';
	import type { TagProps } from '$lib/shared/components/data/types';
	import { matchConfidenceLabel } from '$lib/shared/types';
	import { formatPort } from '$lib/shared/utils/formatting';

	interface Props {
		item: Service;
		context: InterfaceId;
	}

	let { item, context }: Props = $props();

	const queryClient = useQueryClient();
	let contextWithQueryClient = $derived({ ...context, queryClient });
</script>

<ListSelectItem {item} context={contextWithQueryClient} displayComponent={ServiceDisplay} />
