<script lang="ts" context="module">
	export const PortTypeDisplay: EntityDisplayComponent<TypeMetadata<PortTypeMetadata>, object> = {
		getId: (portType: TypeMetadata<PortTypeMetadata>) => portType.id,
		getLabel: (portType: TypeMetadata<PortTypeMetadata>) =>
			`${portType.metadata.number}/${portType.metadata.protocol.toLowerCase()} - ${portType.name}`,
		getDescription: (portType: TypeMetadata<PortTypeMetadata>) => portType.description,
		getIcon: (portType: TypeMetadata<PortTypeMetadata>) => createIconComponent(portType.icon),
		getIconColor: () => entities.getColorHelper('Port').icon,
		getTags: () => [],
		getIsDisabled: () => false,
		getCategory: (portType: TypeMetadata<PortTypeMetadata>) => portType.category
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import { entities, type PortTypeMetadata, type TypeMetadata } from '$lib/shared/stores/metadata';
	import { createIconComponent } from '$lib/shared/utils/styling';
	import type { EntityDisplayComponent } from '../types';

	export let item: TypeMetadata<PortTypeMetadata>;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={PortTypeDisplay} />
