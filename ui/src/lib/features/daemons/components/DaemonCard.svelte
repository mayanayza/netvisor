<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { getDaemonIsRunningDiscovery } from '$lib/features/daemons/store';
	import { sessions } from '$lib/features/discovery/sse';
	import { concepts, entities } from '$lib/shared/stores/metadata';
	import { networks } from '$lib/features/networks/store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { Trash2 } from 'lucide-svelte';
	import { subnets } from '$lib/features/subnets/store';

	export let daemon: Daemon;
	export let onDelete: (daemon: Daemon) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: hostStore = getHostFromId(daemon.host_id);
	$: host = $hostStore;

	$: daemonIsRunningDiscovery = getDaemonIsRunningDiscovery(daemon.id, $sessions);

	// Build card data
	$: cardData = {
		title: daemon.ip + ':' + daemon.port,
		iconColor: entities.getColorHelper('Daemon').icon,
		Icon: entities.getIconComponent('Daemon'),
		fields: [
			{
				label: 'Network',
				value: $networks.find((n) => n.id == daemon.network_id)?.name || 'Unknown Network'
			},
			{
				label: 'Host',
				value: host ? host.name : 'Unknown Host'
			},
			{
				label: 'Created',
				value: formatTimestamp(daemon.created_at)
			},
			{
				label: 'Last Seen',
				value: formatTimestamp(daemon.last_seen)
			},
			{
				label: 'Mode',
				value: daemon.mode
			},
			{
				label: 'Has Docker Socket',
				value: [
					daemon.capabilities.has_docker_socket
						? {
								id: daemon.id,
								label: 'True',
								color: concepts.getColorHelper('Virtualization').string
							}
						: {
								id: daemon.id,
								label: 'False',
								color: 'gray'
							}
				]
			},
			{
				label: 'Interfaces With',
				value:
					daemon.capabilities.interfaced_subnet_ids.length > 0
						? daemon.capabilities.interfaced_subnet_ids
								.map((s) => $subnets.find((subnet) => subnet.id == s))
								.filter((s) => s != undefined)
								.map((s) => {
									return {
										id: s.id,
										label: s.name,
										color: entities.getColorHelper('Subnet').string
									};
								})
						: [
								{
									id: daemon.id,
									label: 'No subnet interfaces',
									color: 'gray'
								}
							]
			}
		],
		actions: [
			{
				label: 'Delete',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(daemon),
				disabled: daemonIsRunningDiscovery
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
