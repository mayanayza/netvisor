<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, subnetTypes } from '$lib/shared/stores/metadata';
	import { formatServiceLabels, getServicesForSubnet } from '$lib/features/services/store';
	import { isContainerSubnet } from '../store';
	import type { Subnet } from '../types/base';
	import { get } from 'svelte/store';

	export let subnet: Subnet;
	export let onEdit: (subnet: Subnet) => void = () => {};
	export let onDelete: (subnet: Subnet) => void = () => {};
	export let viewMode: 'card' | 'list';

	$: allServices = getServicesForSubnet(subnet);
	$: serviceLabelsStore = formatServiceLabels($allServices.map((s) => s.id));
	$: serviceLabels = $serviceLabelsStore;

	// Build card data
	$: cardData = {
		title: subnet.name,
		subtitle: get(isContainerSubnet(subnet.id)) ? '' : subnet.cidr,
		iconColor: subnetTypes.getColorHelper(subnet.subnet_type).icon,
		icon: subnetTypes.getIconComponent(subnet.subnet_type),

		sections: subnet.description
			? [
					{
						label: 'Description',
						value: subnet.description
					}
				]
			: [],

		lists: [
			{
				label: 'Network Type',
				items: [
					{
						id: 'type',
						label: subnetTypes.getName(subnet.subnet_type),
						color: subnetTypes.getColorString(subnet.subnet_type)
					}
				],
				emptyText: 'No type specified'
			},
			// {
			// 	label: 'DNS Resolvers',
			// 	items: dnsLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('Dns')
			// 	})),
			// 	emptyText: 'No DNS resolvers'
			// },
			// {
			// 	label: 'Gateways',
			// 	items: gatewayLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('Gateway')
			// 	})),
			// 	emptyText: 'No gateways'
			// },
			// {
			// 	label: 'Reverse Proxies',
			// 	items: reverseProxyLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('ReverseProxy')
			// 	})),
			// 	emptyText: 'No reverse proxies'
			// },
			{
				label: 'Services',
				items: serviceLabels.map(({ id, label }) => ({
					id,
					label,
					color: entities.getColorString('Service')
				})),
				emptyText: 'No services'
			}
		],

		actions: [
			{
				label: 'Delete Subnet',
				icon: Trash2,
				color: 'btn-icon-danger',
				onClick: () => onDelete(subnet)
			},
			{
				label: 'Edit Subnet',
				icon: Edit,
				onClick: () => onEdit(subnet)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
