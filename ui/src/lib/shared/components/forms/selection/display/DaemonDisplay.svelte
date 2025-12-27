<script lang="ts" context="module">
	import { entities } from '$lib/shared/stores/metadata';
	import { toColor } from '$lib/shared/utils/styling';
	import type { Host } from '$lib/features/hosts/types/base';
	import type { Subnet } from '$lib/features/subnets/types/base';
	import type { Daemon } from '$lib/features/daemons/types/base';

	// Context for daemon display - needs access to hosts and subnets for lookups
	export interface DaemonDisplayContext {
		hosts: Host[];
		subnets: Subnet[];
	}

	export const DaemonDisplay: EntityDisplayComponent<Daemon, DaemonDisplayContext> = {
		getId: (daemon: Daemon) => daemon.id,
		getLabel: (daemon: Daemon) => daemon.name || 'Unknown Daemon',
		getDescription: (daemon: Daemon, context: DaemonDisplayContext) => {
			const hostsData = context?.hosts ?? [];
			const host = hostsData.find((h) => h.id === daemon.host_id);
			return host?.description || '';
		},
		getIcon: () => entities.getIconComponent('Daemon'),
		getIconColor: () => entities.getColorHelper('Daemon').icon,
		getTags: (daemon: Daemon, context: DaemonDisplayContext) => {
			const subnetsData = context?.subnets ?? [];
			let tags = [];

			tags.push({
				label: 'Docker Socket ' + (daemon.capabilities.has_docker_socket ? '✓' : '✘'),
				color: toColor(daemon.capabilities.has_docker_socket ? 'blue' : 'gray')
			});

			daemon.capabilities.interfaced_subnet_ids.forEach((s) => {
				let subnet = subnetsData.find((sub) => sub.id === s);
				if (subnet) {
					tags.push({
						label: subnet.cidr,
						color: entities.getColorHelper('Subnet').color
					});
				}
			});

			return tags;
		},
		getCategory: () => null
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';

	export let item: Daemon;
	export let context: DaemonDisplayContext = { hosts: [], subnets: [] };
</script>

<ListSelectItem {item} {context} displayComponent={DaemonDisplay} />
