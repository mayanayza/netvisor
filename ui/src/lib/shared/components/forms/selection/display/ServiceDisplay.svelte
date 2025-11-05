<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	export const ServiceDisplay: EntityDisplayComponent<Service, object> = {
		getId: (service: Service) => service.id,
		getLabel: (service: Service) => service.name,
		getDescription: (service: Service) => {
			let descriptionItems = [];
			let binding_count = service.bindings.length;
			descriptionItems.push(binding_count + ' binding' + (binding_count == 1 ? '' : 's'));

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
	import { getPortFromId } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';
	import { formatPort } from '$lib/shared/utils/formatting';

	export let item: Service;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={ServiceDisplay} />
