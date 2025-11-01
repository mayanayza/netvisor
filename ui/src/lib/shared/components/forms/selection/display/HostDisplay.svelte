<script lang="ts" context="module">
	import type { Host } from '$lib/features/hosts/types/base';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';

	export const HostDisplay: EntityDisplayComponent<Host, object> = {
		getId: (host: Host) => host.id,
		getLabel: (host: Host) => host.name,
		getDescription: (host: Host) => get(getHostTargetString(host)) || 'Unknown Host',
		getIcon: (host: Host) => {
			let firstService = host.services.length > 0 ? get(getServiceById(host.services[0])) : null;
			if (firstService) {
				return serviceDefinitions.getIconComponent(firstService.service_definition);
			} else {
				return entities.getIconComponent('Host');
			}
		},
		getIconColor: () => entities.getColorHelper('Host').icon,
		getTags: (host: Host) => {
			let services = get(getServicesForHost(host.id));

			return services.map((service) => ({
				label: serviceDefinitions.getName(service.service_definition),
				color: serviceDefinitions.getColorString(service.service_definition)
			}));
		},
		getIsDisabled: () => false
	};
</script>

<script lang="ts">
	import { getServiceById, getServicesForHost } from '$lib/features/services/store';
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import { getHostTargetString } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';

	export let item: Host;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={HostDisplay} />
