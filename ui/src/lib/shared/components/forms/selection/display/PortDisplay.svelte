<script lang="ts" context="module">
	import { ALL_INTERFACES, type Port } from '$lib/features/hosts/types/base';
	import type { EntityDisplayComponent } from '../types';
	import { entities, ports } from '$lib/shared/stores/metadata';
	import type { Service } from '$lib/features/services/types/base';

	export const PortDisplay: EntityDisplayComponent<Port> = {
		getId: (port: Port) => `${port.id}`,
		getLabel: (port: Port) => {
			let metadata = ports.getMetadata(port.type);
			let name = ports.getName(port.type);
			if (metadata && !metadata.is_custom && name) {
				return name + ` (${port.number}/${port.protocol.toLowerCase()})`;
			}
			return `${port.number}/${port.protocol.toLowerCase()}`;
		},
		getDescription: (port: Port, context: { currentServices: Service[] }) => {
			// Use context services if available, otherwise fall back to store
			let services: Service[] = context.currentServices.filter((s) =>
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
										? get(getInterfaceFromId(b.interface_id))
										: ALL_INTERFACES;
									if (iface) {
										return formatInterface(iface);
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
		getIsDisabled: () => false,
		getCategory: () => null
	};
</script>

<script lang="ts">
	import ListSelectItem from '../ListSelectItem.svelte';
	import { formatInterface, getInterfaceFromId } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';

	export let item: Port;
</script>

<ListSelectItem {item} displayComponent={PortDisplay} />
