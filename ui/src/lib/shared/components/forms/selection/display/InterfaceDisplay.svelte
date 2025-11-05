<script lang="ts" context="module">
	import { getSubnetFromId, isContainerSubnet } from '$lib/features/subnets/store';
	import { get } from 'svelte/store';

	export const InterfaceDisplay: EntityDisplayComponent<Interface, object> = {
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
		getTags: (iface: Interface) => {
			const subnet = get(getSubnetFromId(iface.subnet_id));
			const tags = [];
			if (subnet && !get(isContainerSubnet(subnet.id))) {
				tags.push({
					label: subnet.cidr,
					color: entities.getColorHelper('Subnet').string
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

	export let item: Interface;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={InterfaceDisplay} />
