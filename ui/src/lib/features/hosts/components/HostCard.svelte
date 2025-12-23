<script lang="ts">
	import { Edit, Eye, Replace, Trash2 } from 'lucide-svelte';
	import { formatInterface, hosts } from '../store';
	import type { Host } from '../types/base';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { concepts, entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Group } from '$lib/features/groups/types/base';
	import { getServiceById, getServicesForHost } from '$lib/features/services/store';
	import { daemons } from '$lib/features/daemons/store';
	import { tags } from '$lib/features/tags/store';

	let {
		host,
		hostGroups = [],
		onEdit = () => {},
		onDelete = () => {},
		onHide = () => {},
		onConsolidate = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		host: Host;
		hostGroups?: Group[];
		onEdit?: (host: Host) => void;
		onDelete?: (host: Host) => void;
		onHide?: (host: Host) => void;
		onConsolidate?: (host: Host) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let hasDaemon = $derived($daemons.some((d) => d.host_id == host.id));

	// Get stores at top level
	let hostServicesStore = $derived(getServicesForHost(host.id));
	let virtualizationServiceStore = $derived(
		host.virtualization !== null ? getServiceById(host.virtualization.details.service_id) : null
	);

	// Consolidate all reactive computations into a single derived to prevent cascading updates
	let cardData = $derived.by(() => {
		const hostServices = $hostServicesStore;
		const virtualizationService = virtualizationServiceStore ? $virtualizationServiceStore : null;

		const servicesThatManageVmsIds = hostServices
			.filter(
				(sv) =>
					serviceDefinitions.getItem(sv.service_definition)?.metadata.manages_virtualization ==
					'vms'
			)
			.map((sv) => sv.id);

		const servicesThatManageContainersIds = hostServices
			.filter(
				(sv) =>
					serviceDefinitions.getItem(sv.service_definition)?.metadata.manages_virtualization ==
					'containers'
			)
			.map((sv) => sv.id);

		const vms = $hosts.filter(
			(h) =>
				h.virtualization &&
				h.virtualization?.type == 'Proxmox' &&
				servicesThatManageVmsIds.includes(h.virtualization.details.service_id)
		);

		const containers = hostServices.filter(
			(s) =>
				s.virtualization &&
				s.virtualization?.type == 'Docker' &&
				servicesThatManageContainersIds.includes(s.virtualization.details.service_id)
		);

		const containerIds = containers.map((c) => c.id);

		return {
			title: host.name,
			...(host.virtualization !== null && virtualizationService
				? {
						subtitle: 'VM Managed By ' + virtualizationService.name || 'Unknown Service'
					}
				: {}),
			link: host.hostname ? `http://${host.hostname}` : undefined,
			iconColor: entities.getColorHelper('Host').icon,
			Icon:
				serviceDefinitions.getIconComponent(hostServices[0]?.service_definition) ||
				entities.getIconComponent('Host'),
			fields: [
				{
					label: 'Description',
					value: host.description
				},
				{
					label: 'Groups',
					value: hostGroups.map((group: Group) => ({
						id: group.id,
						label: group.name,
						color: entities.getColorHelper('Group').string
					})),
					emptyText: 'No groups assigned'
				},
				{
					label: 'VMs',
					value: vms.map((h) => {
						return {
							id: h.id,
							label: h.name,
							color: concepts.getColorHelper('Virtualization').string
						};
					}),
					emptyText: 'No VMs assigned'
				},
				{
					label: 'Services',
					value: hostServices
						.filter((sv) => !containerIds.includes(sv.id))
						.map((sv) => {
							return {
								id: sv.id,
								label: sv.name,
								color: entities.getColorHelper('Service').string
							};
						})
						.sort((a) => (containerIds.includes(a.id) ? 1 : -1)),
					emptyText: 'No services assigned'
				},
				{
					label: 'Containers',
					value: containers
						.map((c) => {
							return {
								id: c.id,
								label: c.name,
								color: concepts.getColorHelper('Virtualization').string
							};
						})
						.sort((a) => (containerIds.includes(a.id) ? 1 : -1)),
					emptyText: 'No containers'
				},
				{
					label: 'Interfaces',
					value: host.interfaces.map((i) => {
						return {
							id: i.id,
							label: formatInterface(i),
							color: entities.getColorHelper('Interface').string
						};
					}),
					emptyText: 'No interfaces'
				},
				{
					label: 'Tags',
					value: host.tags.map((t) => {
						const tag = $tags.find((tag) => tag.id == t);
						return tag
							? { id: tag.id, color: tag.color, label: tag.name }
							: { id: t, color: 'gray', label: 'Unknown Tag' };
					})
				}
			],
			actions: [
				{
					label: 'Delete',
					icon: Trash2,
					class: 'btn-icon-danger',
					onClick: () => onDelete(host),
					disabled: hasDaemon
				},
				{
					label: 'Consolidate',
					icon: Replace,
					onClick: () => onConsolidate(host)
				},
				{
					label: 'Hide',
					icon: Eye,
					class: host.hidden ? 'text-blue-400' : '',
					onClick: () => onHide(host)
				},
				{
					label: 'Edit',
					icon: Edit,
					onClick: () => onEdit(host)
				}
			]
		};
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
