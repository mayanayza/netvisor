<script lang="ts" context="module">
	export const ServiceTypeDisplay: EntityDisplayComponent<
		TypeMetadata<ServicedDefinitionMetadata>,
		object
	> = {
		getId: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) => serviceType.id,
		getLabel: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) => serviceType.name,
		getDescription: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) =>
			serviceType.description,
		getIcon: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) =>
			serviceDefinitions.getIconComponent(serviceType.id),
		getIconColor: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) =>
			serviceDefinitions.getColorHelper(serviceType.id).icon,
		getTags: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) => [
			{
				label: serviceType.category,
				color: serviceType.color
			}
		],
		getIsDisabled: () => false,
		getCategory: (serviceType: TypeMetadata<ServicedDefinitionMetadata>) => serviceType.category
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import {
		serviceDefinitions,
		type ServicedDefinitionMetadata,
		type TypeMetadata
	} from '$lib/shared/stores/metadata';
	import type { EntityDisplayComponent } from '../types';

	export let item: TypeMetadata<ServicedDefinitionMetadata>;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={ServiceTypeDisplay} />
