<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	interface InterfaceIds {
		interfaceIds: string[];
	}

	export const ServiceDisplay: EntityDisplayComponent<Service, InterfaceIds> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service, context) => {
			console.log(service);
			console.log(context.interfaceIds);
			let descriptionItems = [];

			let bindingsOnInterface = service.bindings.filter((b) =>
				b.interface_id
					? context.interfaceIds.includes(b.interface_id) || context.interfaceIds.length == 0
					: true
			).length;

			descriptionItems.push(`${bindingsOnInterface} binding${bindingsOnInterface > 1 ? 's' : ''} 
			on ${
				context.interfaceIds.length == 0
					? 'all interfaces'
					: context.interfaceIds
							.map((i) => {
								const iface = get(getInterfaceFromId(i));
								return iface ? formatInterface(iface) : 'Unknown Interface';
							})
							.join(', ')
			}`);

			if (service.source.type == 'DiscoveryWithMatch') {
				let confidence = service.source.details.confidence;

				if (confidence != 'Certain' && confidence != 'NotApplicable') {
					descriptionItems.push(matchConfidenceLabel(service.source.details));
				}
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
					color: entities.getColorHelper('Virtualization').string
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
	import { formatInterface, getInterfaceFromId } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';

	export let item: Service;
	export let context: InterfaceIds;
</script>

<ListSelectItem {item} {context} displayComponent={ServiceDisplay} />
