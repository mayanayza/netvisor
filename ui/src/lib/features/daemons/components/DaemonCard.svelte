<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { getDaemonIsRunningDiscovery } from '$lib/features/daemons/queries';
	import { sessions } from '$lib/features/discovery/sse';
	import { concepts, entities } from '$lib/shared/stores/metadata';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { toColor } from '$lib/shared/utils/styling';
	import { Trash2 } from 'lucide-svelte';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';

	// Queries
	const tagsQuery = useTagsQuery();
	const networksQuery = useNetworksQuery();
	const hostsQuery = useHostsQuery();
	const subnetsQuery = useSubnetsQuery();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let networksData = $derived(networksQuery.data ?? []);
	let hostsData = $derived(hostsQuery.data ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);

	let {
		daemon,
		onDelete = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		daemon: Daemon;
		onDelete?: (daemon: Daemon) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let host = $derived(hostsData.find((h) => h.id === daemon.host_id) ?? null);
	let daemonIsRunningDiscovery = $derived(getDaemonIsRunningDiscovery(daemon.id, $sessions));

	// Build card data
	let cardData = $derived({
		title: daemon.name,
		iconColor: entities.getColorHelper('Daemon').icon,
		Icon: entities.getIconComponent('Daemon'),
		fields: [
			{
				label: 'Network',
				value: networksData.find((n) => n.id == daemon.network_id)?.name || 'Unknown Network'
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
								color: concepts.getColorHelper('Virtualization').color
							}
						: {
								id: daemon.id,
								label: 'False',
								color: toColor('gray')
							}
				]
			},
			{
				label: 'Interfaces With',
				value:
					daemon.capabilities.interfaced_subnet_ids.length > 0
						? daemon.capabilities.interfaced_subnet_ids
								.map((s) => subnetsData.find((subnet) => subnet.id == s))
								.filter((s) => s != undefined)
								.map((s) => {
									return {
										id: s.id,
										label: s.name,
										color: entities.getColorHelper('Subnet').color
									};
								})
						: [
								{
									id: daemon.id,
									label: 'No subnet interfaces',
									color: toColor('gray')
								}
							],
				emptyText: 'No subnet interfaces'
			},
			{
				label: 'Tags',
				value: daemon.tags.map((t) => {
					const tag = tagsData.find((tag) => tag.id == t);
					return tag
						? { id: tag.id, color: tag.color, label: tag.name }
						: { id: t, color: toColor('gray'), label: 'Unknown Tag' };
				})
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
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
