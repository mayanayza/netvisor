<script lang="ts" module>
	import { isContainerSubnet, getSubnetById } from '$lib/features/subnets/queries';
	import type { Subnet } from '$lib/features/subnets/types/base';

	// Context for interface display - needs access to subnets for lookups
	export interface InterfaceDisplayContext {
		subnets: Subnet[];
	}

	export const InterfaceDisplay: EntityDisplayComponent<Interface, InterfaceDisplayContext> = {
		getId: (iface: Interface) => iface.id,
		getLabel: (iface: Interface) => (iface.name ? iface.name : 'Unnamed Interface'),
		getDescription: (iface: Interface) => {
			const parts = [iface.ip_address];
			if (iface.mac_address) {
				parts.push(iface.mac_address);
			} else {
				parts.push('No MAC');
			}
			return parts.join(' • ');
		},
		getIcon: () => entities.getIconComponent('Interface'),
		getIconColor: () => entities.getColorHelper('Interface').icon,
		getTags: (iface: Interface, context: InterfaceDisplayContext) => {
			const subnetsData = context?.subnets ?? [];
			const subnet = getSubnetById(subnetsData, iface.subnet_id);
			const tags = [];
			if (subnet && !isContainerSubnet(subnet)) {
				tags.push({
					label: subnet.cidr,
					color: entities.getColorHelper('Subnet').color
				});
			}
			return tags;
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import type { Interface } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import { entities } from '$lib/shared/stores/metadata';

	interface Props {
		item: Interface;
		context?: InterfaceDisplayContext;
	}

	let { item, context = { subnets: [] } }: Props = $props();
</script>

<ListSelectItem {item} {context} displayComponent={InterfaceDisplay} />
