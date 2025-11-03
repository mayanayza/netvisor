<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { getDaemonIsRunningDiscovery } from '$lib/features/daemons/store';
	import { sessions } from '$lib/features/discovery/SSEStore';
	import { entities } from '$lib/shared/stores/metadata';
	import { networks } from '$lib/features/networks/store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { RotateCcwKey, Trash2 } from 'lucide-svelte';
	import { subnets } from '$lib/features/subnets/store';

	export let daemon: Daemon;
	export let onDelete: (daemon: Daemon) => void = () => {};
	export let onGenerateApi: (daemon: Daemon) => void = () => {};
	export let viewMode: 'card' | 'list';

	$: hostStore = getHostFromId(daemon.host_id);
	$: host = $hostStore;

	$: daemonIsRunningDiscovery = getDaemonIsRunningDiscovery(daemon.id, $sessions);

	// Build card data
	$: cardData = {
		title: daemon.ip + ':' + daemon.port,
		...(!daemon.api_key
			? {
					status: {
						label: '⚠ API key missing',
						color: 'yellow'
					}
				}
			: {}),
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
				label: 'Registered',
				value: formatTimestamp(daemon.registered_at)
			},
			{
				label: 'Last Seen',
				value: formatTimestamp(daemon.last_seen)
			},
			{
				label: 'Has Docker Socket',
				value: [
					daemon.capabilities.has_docker_socket
						? {
								id: daemon.id,
								label: 'True',
								color: entities.getColorHelper('Virtualization').string
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
				value: daemon.capabilities.interfaced_subnet_ids
					.map((s) => $subnets.find((subnet) => subnet.id == s))
					.filter((s) => s != undefined)
					.map((s) => {
						return {
							id: s.id,
							label: s.name,
							color: entities.getColorHelper('Subnet').string
						};
					})
			}
		],
		actions: [
			{
				label: 'Update API Key',
				icon: RotateCcwKey,
				class: `btn-icon ${!daemon.api_key ? 'text-yellow-500' : ''}`,
				onClick: () => onGenerateApi(daemon),
				disabled: daemonIsRunningDiscovery
			},
			{
				label: 'Delete Daemon',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(daemon),
				disabled: daemonIsRunningDiscovery
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
