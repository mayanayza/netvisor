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
		Icon: subnetTypes.getIconComponent(subnet.subnet_type),
		fields: [
			{
				label: 'Description',
				value: subnet.description
			},
			{
				label: 'Network Type',
				value: [
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
			// 	value: dnsLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('Dns')
			// 	})),
			// 	emptyText: 'No DNS resolvers'
			// },
			// {
			// 	label: 'Gateways',
			// 	value: gatewayLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('Gateway')
			// 	})),
			// 	emptyText: 'No gateways'
			// },
			// {
			// 	label: 'Reverse Proxies',
			// 	value: reverseProxyLabels.map(({ id, label }) => ({
			// 		id,
			// 		label,
			// 		color: entities.getColorString('ReverseProxy')
			// 	})),
			// 	emptyText: 'No reverse proxies'
			// },
			{
				label: 'Services',
				value: serviceLabels.map(({ id, label }) => ({
					id,
					label,
					color: entities.getColorString('Service')
				})),
				emptyText: 'No services'
			}
		],

		actions: [
			{
				label: 'Delete',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(subnet)
			},
			{
				label: 'Edit',
				icon: Edit,
				onClick: () => onEdit(subnet)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
