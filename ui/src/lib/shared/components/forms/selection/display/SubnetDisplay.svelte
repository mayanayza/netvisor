<script lang="ts" module>
	import { isContainerSubnet } from '$lib/features/subnets/queries';

	export const SubnetDisplay: EntityDisplayComponent<Subnet, object> = {
		getId: (subnet: Subnet) => subnet.id,
		getLabel: (subnet: Subnet) => subnet.name,
		getDescription: (subnet: Subnet) => {
			if (isContainerSubnet(subnet)) return '';
			return subnet.name == subnet.cidr ? '' : subnet.cidr;
		},
		getIcon: (subnet: Subnet) => subnetTypes.getIconComponent(subnet.subnet_type),
		getIconColor: (subnet: Subnet) => subnetTypes.getColorHelper(subnet.subnet_type).icon,
		getTags: (subnet: Subnet) => [
			{
				label: subnet.subnet_type,
				color: subnetTypes.getColorHelper(subnet.subnet_type).color
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

	interface Props {
		item: Subnet;
		context?: object;
	}

	let { item, context = {} }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={SubnetDisplay} />
