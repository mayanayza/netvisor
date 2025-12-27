<script lang="ts" context="module">
	import type { Host, Interface, Port, Service } from '$lib/features/hosts/types/base';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	// Context provides the host's children (interfaces, ports, services)
	export interface HostDisplayContext {
		interfaces?: Interface[];
		ports?: Port[];
		services?: Service[];
	}

	export const HostDisplay: EntityDisplayComponent<Host, HostDisplayContext> = {
		getId: (host) => host.id,
		getLabel: (host) => host.name,
		getDescription: (host) => host.hostname || 'No Hostname',
		getIcon: (host, context) => {
			const services = context?.services ?? [];
			const firstService = services.length > 0 ? services[0] : null;
			if (firstService) {
				return serviceDefinitions.getIconComponent(firstService.service_definition);
			} else {
				return entities.getIconComponent('Host');
			}
		},
		getIconColor: () => entities.getColorHelper('Host').icon,
		getTags: (host, context) => {
			const services = context?.services ?? [];
			return services.map((service) => ({
				label: serviceDefinitions.getName(service.service_definition),
				color: entities.getColorHelper('Service').color
			}));
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';

	export let item: Host;
	export let context: HostDisplayContext = {};
</script>

<ListSelectItem {item} {context} displayComponent={HostDisplay} />
