<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, subnetTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { isContainerSubnet } from '../queries';
	import type { Subnet } from '../types/base';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useInterfacesQuery } from '$lib/features/interfaces/queries';
	import { toColor } from '$lib/shared/utils/styling';

	// Queries
	const tagsQuery = useTagsQuery();
	const servicesQuery = useServicesQuery();
	const interfacesQuery = useInterfacesQuery();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);
	let interfacesData = $derived(interfacesQuery.data ?? []);

	let {
		subnet,
		onEdit = () => {},
		onDelete = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		subnet: Subnet;
		onEdit?: (subnet: Subnet) => void;
		onDelete?: (subnet: Subnet) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	// Get services for this subnet via interfaces
	let subnetServices = $derived(
		(() => {
			// Get all interfaces on this subnet
			const subnetInterfaces = interfacesData.filter((i) => i.subnet_id === subnet.id);
			const interfaceIds = new Set(subnetInterfaces.map((i) => i.id));
			const hostIds = new Set(subnetInterfaces.map((i) => i.host_id));

			return servicesData.filter((s) =>
				s.bindings.some(
					(b) =>
						(b.interface_id && interfaceIds.has(b.interface_id)) ||
						(hostIds.has(s.host_id) && b.interface_id == null)
				)
			);
		})()
	);

	let serviceLabels = $derived(
		subnetServices.map((s) => {
			const def = serviceDefinitions.getItem(s.service_definition);
			return {
				id: s.id,
				label: def ? `${s.name} (${def.name})` : s.name
			};
		})
	);

	// Build card data
	let cardData = $derived({
		title: subnet.name,
		subtitle: isContainerSubnet(subnet) ? '' : subnet.cidr,
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
			{
				label: 'Services',
				value: serviceLabels.map(({ id, label }) => ({
					id,
					label,
					color: entities.getColorString('Service')
				})),
				emptyText: 'No services'
			},
			{
				label: 'Tags',
				value: subnet.tags.map((t) => {
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
				onClick: () => onDelete(subnet)
			},
			{
				label: 'Edit',
				icon: Edit,
				onClick: () => onEdit(subnet)
			}
		]
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
