<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Group } from '../types/base';
	import { entities, groupTypes } from '$lib/shared/stores/metadata';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { toColor } from '$lib/shared/utils/styling';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';

	// Queries
	const tagsQuery = useTagsQuery();
	const servicesQuery = useServicesQuery();

	// Derived data
	let tagsData = $derived(tagsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);

	let {
		group,
		onEdit = () => {},
		onDelete = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		group: Group;
		onEdit?: (group: Group) => void;
		onDelete?: (group: Group) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	// Get services for this group via binding_ids
	let groupServices = $derived(
		(() => {
			if (group.group_type === 'RequestPath' || group.group_type === 'HubAndSpoke') {
				const serviceMap = new Map(servicesData.flatMap((s) => s.bindings.map((b) => [b.id, s])));
				return group.binding_ids
					.map((bindingId) => serviceMap.get(bindingId))
					.filter((s): s is NonNullable<typeof s> => s !== null && s !== undefined);
			}
			return [];
		})()
	);

	let groupServiceLabels = $derived(
		groupServices.map((s) => {
			const def = serviceDefinitions.getItem(s.service_definition);
			return {
				id: s.id,
				label: def ? `${s.name} (${def.name})` : s.name
			};
		})
	);

	// Build card data
	let cardData = $derived({
		title: group.name,
		iconColor: groupTypes.getColorHelper(group.group_type).icon,
		Icon: groupTypes.getIconComponent(group.group_type),
		fields: [
			{
				label: 'Description',
				value: group.description
			},
			{
				label: 'Group Type',
				value: [
					{
						id: 'type',
						label: groupTypes.getName(group.group_type),
						color: groupTypes.getColorString(group.group_type)
					}
				],
				emptyText: 'No type specified'
			},
			{
				label: 'Color',
				value: [
					{
						id: 'color',
						label: group.color.charAt(0).toUpperCase() + group.color.slice(1),
						color: group.color
					}
				],
				emptyText: 'No type specified'
			},
			{
				label: 'Edge Style',
				value: [
					{
						id: 'type',
						label: group.edge_style,
						color: toColor('gray')
					}
				],
				emptyText: 'No type specified'
			},
			{
				label: 'Services',
				value: groupServiceLabels.map(({ id, label }, i) => {
					return {
						id: id + i,
						label,
						color: entities.getColorString('Service')
					};
				}),
				emptyText: 'No services in group'
			},
			{
				label: 'Tags',
				value: group.tags.map((t) => {
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
				onClick: () => onDelete(group)
			},
			{
				label: 'Edit',
				icon: Edit,
				onClick: () => onEdit(group)
			}
		]
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
