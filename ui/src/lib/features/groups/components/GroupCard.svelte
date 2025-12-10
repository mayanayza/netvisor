<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Group } from '../types/base';
	import { entities, groupTypes } from '$lib/shared/stores/metadata';
	import { formatServiceLabels, getServicesForGroup } from '$lib/features/services/store';
	import { tags } from '$lib/features/tags/store';

	export let group: Group;
	export let onEdit: (group: Group) => void = () => {};
	export let onDelete: (group: Group) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: groupServicesStore = getServicesForGroup(group.id);
	$: groupServices = $groupServicesStore;
	$: groupServiceLabelsStore = formatServiceLabels(groupServices.map((s) => s.id));
	$: groupServiceLabels = $groupServiceLabelsStore;

	// Build card data
	$: cardData = {
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
						color: 'gray'
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
				onClick: () => onDelete(group)
			},
			{
				label: 'Edit',
				icon: Edit,
				onClick: () => onEdit(group)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
