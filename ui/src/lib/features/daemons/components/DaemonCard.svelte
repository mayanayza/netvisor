<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { getDaemonIsRunningDiscovery } from '$lib/features/daemons/store';
	import { sessions } from '$lib/features/discovery/store';
	import { entities } from '$lib/shared/stores/metadata';
	import { networks } from '$lib/features/networks/store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { RotateCcwKey, Trash2 } from 'lucide-svelte';

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
