<script lang="ts" context="module">
	export const SubnetDisplay: EntityDisplayComponent<Subnet, object> = {
		getId: (subnet: Subnet) => subnet.id,
		getLabel: (subnet: Subnet) => subnet.name,
		getDescription: (subnet: Subnet) => (subnet.name == subnet.cidr ? '' : subnet.cidr),
		getIcon: () => entities.getIconComponent('Subnet'),
		getIconColor: () => entities.getColorHelper('Subnet').icon,
		getTags: () => [],
		getIsDisabled: () => false,
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import { entities } from '$lib/shared/stores/metadata';
	import type { Subnet } from '$lib/features/subnets/types/base';

	export let item: Subnet;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={SubnetDisplay} />
