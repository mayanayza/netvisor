<script lang="ts" context="module">
	export const SubnetDisplay: EntityDisplayComponent<Subnet, object> = {
		getId: (subnet: Subnet) => subnet.id,
		getLabel: (subnet: Subnet) => subnet.name,
		getDescription: (subnet: Subnet) => {
			if (get(isContainerSubnet(subnet.id))) return '';
			return subnet.name == subnet.cidr ? '' : subnet.cidr;
		},
		getIcon: (subnet: Subnet) => subnetTypes.getIconComponent(subnet.subnet_type),
		getIconColor: (subnet: Subnet) => subnetTypes.getColorHelper(subnet.subnet_type).icon,
		getTags: (subnet: Subnet) => [
			{
				label: subnet.subnet_type,
				color: subnetTypes.getColorHelper(subnet.subnet_type).string
			}
		],
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { EntityDisplayComponent } from '../types';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import type { Subnet } from '$lib/features/subnets/types/base';
	import { isContainerSubnet } from '$lib/features/subnets/store';
	import { get } from 'svelte/store';

	export let item: Subnet;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={SubnetDisplay} />
