<script lang="ts" context="module">
	import { ALL_INTERFACES, type Interface, type Port } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import { entities, ports } from '$lib/shared/stores/metadata';
	import type { Service } from '$lib/features/services/types/base';

	// Context for port display - needs access to interfaces for binding display
	export interface PortDisplayContext {
		currentServices: Service[];
		interfaces: Interface[];
		isContainerSubnet: (subnetId: string) => boolean;
	}

	// Helper to format interface for display
	function formatInterfaceForPort(
		iface: Interface | typeof ALL_INTERFACES,
		isContainerSubnet: (subnetId: string) => boolean
	): string {
		if (iface.id == null) return iface.name;
		return isContainerSubnet(iface.subnet_id)
			? (iface.name ?? iface.ip_address)
			: (iface.name ? iface.name + ': ' : '') + iface.ip_address;
	}

	export const PortDisplay: EntityDisplayComponent<Port, PortDisplayContext> = {
		getId: (port: Port) => `${port.id}`,
		getLabel: (port: Port) => {
			let metadata = ports.getMetadata(port.type ?? null);
			let name = ports.getName(port.type ?? null);
			if (metadata && !metadata.is_custom && name) {
				return name + ` (${port.number}/${port.protocol.toLowerCase()})`;
			}
			return `${port.number}/${port.protocol.toLowerCase()}`;
		},
		getDescription: (port: Port, context: PortDisplayContext) => {
			const currentServices = context?.currentServices ?? [];
			const interfacesData = context?.interfaces ?? [];
			const isContainerSubnetFn = context?.isContainerSubnet ?? (() => false);

			// Use context services if available
			let services: Service[] = currentServices.filter((s) =>
				s.bindings.some((b) => b.type === 'Port' && b.port_id === port.id)
			);

			if (services.length > 0) {
				return services
					.flatMap(
						(s) =>
							s.name +
							' on ' +
							s.bindings
								.filter((b) => b.type == 'Port' && b.port_id == port.id)
								.map((b) => {
									let iface = b.interface_id
										? interfacesData.find((i) => i.id === b.interface_id)
										: ALL_INTERFACES;
									if (iface) {
										return formatInterfaceForPort(iface, isContainerSubnetFn);
									} else {
										return 'Unknown Interface';
									}
								})
								.join(', ')
					)
					.join(' • ');
			} else {
				return 'Unassigned';
			}
		},
		getIcon: () => entities.getIconComponent('Port'),
		getIconColor: () => entities.getColorHelper('Port').icon,
		getTags: () => [],
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '../ListSelectItem.svelte';

	export let item: Port;
	export let context: PortDisplayContext = {
		currentServices: [],
		interfaces: [],
		isContainerSubnet: () => false
	};
</script>

<ListSelectItem {item} {context} displayComponent={PortDisplay} />
