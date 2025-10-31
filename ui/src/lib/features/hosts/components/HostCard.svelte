<script lang="ts">
	import { Edit, Eye, Replace, Trash2 } from 'lucide-svelte';
	import { formatInterface, getHostTargetString, hosts } from '../store';
	import type { Host } from '../types/base';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Group } from '$lib/features/groups/types/base';
	import { getServiceById, getServicesForHost } from '$lib/features/services/store';
	import { get } from 'svelte/store';

	export let host: Host;
	export let hostGroups: Group[] = [];
	export let onEdit: (host: Host) => void = () => {};
	export let onDelete: (host: Host) => void = () => {};
	export let onHide: (host: Host) => void = () => {};
	export let onConsolidate: (host: Host) => void = () => {};
	export let viewMode: 'card' | 'list';

	$: hostServicesStore = getServicesForHost(host.id);
	$: hostServices = $hostServicesStore;
	$: servicesThatManageVmsIds = hostServices
		.filter(
			(sv) =>
				serviceDefinitions.getItem(sv.service_definition)?.metadata.manages_virtualization == 'vms'
		)
		.map((sv) => sv.id);
	$: servicesThatManageContainersIds = hostServices
		.filter(
			(sv) =>
				serviceDefinitions.getItem(sv.service_definition)?.metadata.manages_virtualization ==
				'containers'
		)
		.map((sv) => sv.id);

	$: vms = $hosts.filter(
		(h) =>
			h.virtualization &&
			h.virtualization?.type == 'Proxmox' &&
			servicesThatManageVmsIds.includes(h.virtualization.details.service_id)
	);
	$: containers = hostServices.filter(
		(s) =>
			s.virtualization &&
			s.virtualization?.type == 'Docker' &&
			servicesThatManageContainersIds.includes(s.virtualization.details.service_id)
	);
	$: containerIds = containers.map((c) => c.id);

	// Build card data
	$: cardData = {
		title: host.name,
		...(host.virtualization !== null
			? {
					subtitle:
						'VM Managed By ' + get(getServiceById(host.virtualization.details.service_id))?.name ||
						'Unknown Service'
				}
			: {}),
		link: host.target.type != 'None' ? `http://${get(getHostTargetString(host))}` : undefined,
		iconColor: entities.getColorHelper('Host').icon,
		icon:
			serviceDefinitions.getIconComponent(hostServices[0]?.service_definition) ||
			entities.getIconComponent('Host'),
		sections: host.description
			? [
					{
						label: 'Description',
						value: host.description
					}
				]
			: [],
		lists: [
			{
				label: 'Groups',
				items: hostGroups.map((group: Group) => ({
					id: group.id,
					label: group.name,
					color: entities.getColorHelper('Group').string
				})),
				emptyText: 'No groups assigned'
			},
			{
				label: 'VMs',
				items: vms.map((h) => {
					return {
						id: h.id,
						label: h.name,
						color: entities.getColorHelper('Virtualization').string
					};
				}),
				emptyText: 'No VMs assigned'
			},
			{
				label: 'Services',
				items: hostServices
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
				items: containers
					.map((c) => {
						return {
							id: c.id,
							label: c.name,
							color: entities.getColorHelper('Virtualization').string
						};
					})
					.sort((a) => (containerIds.includes(a.id) ? 1 : -1)),
				emptyText: 'No containers'
			},
			{
				label: 'Interfaces',
				items: host.interfaces.map((i) => {
					return {
						id: i.id,
						label: formatInterface(i),
						color: entities.getColorHelper('Interface').string
					};
				}),
				emptyText: 'No interfaces'
			}
		],

		actions: [
			{
				label: 'Delete Host',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(host)
			},
			{
				label: 'Consolidate',
				icon: Replace,
				onClick: () => onConsolidate(host)
			},
			{
				label: 'Hide Host',
				icon: Eye,
				class: host.hidden ? 'text-blue-400' : '',
				onClick: () => onHide(host)
			},
			{
				label: 'Edit Host',
				icon: Edit,
				onClick: () => onEdit(host)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
