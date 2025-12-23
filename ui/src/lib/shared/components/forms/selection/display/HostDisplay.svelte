<script lang="ts" context="module">
	import type { Host } from '$lib/features/hosts/types/base';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	export const HostDisplay: EntityDisplayComponent<Host, object> = {
		getId: (host: Host) => host.id,
		getLabel: (host: Host) => host.name,
		getDescription: (host: Host) => host.hostname || 'No Hostname',
		getIcon: (host: Host) => {
			const firstService = host.services.length > 0 ? host.services[0] : null;
			if (firstService) {
				return serviceDefinitions.getIconComponent(firstService.service_definition);
			} else {
				return entities.getIconComponent('Host');
			}
		},
		getIconColor: () => entities.getColorHelper('Host').icon,
		getTags: (host: Host) => {
			return host.services.map((service) => ({
				label: serviceDefinitions.getName(service.service_definition),
				color: entities.getColorHelper('Service').string
			}));
		}
	};
</script>

<script lang="ts">
	import { getServiceById, getServicesForHost } from '$lib/features/services/store';
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import { get } from 'svelte/store';

	export let item: Host;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={HostDisplay} />
