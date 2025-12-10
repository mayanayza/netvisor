<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Tag } from '../types/base';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import { TagIcon } from 'lucide-svelte';

	export let tag: Tag;
	export let onEdit: (tag: Tag) => void = () => {};
	export let onDelete: (tag: Tag) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: colorHelper = createColorHelper(tag.color);

	$: cardData = {
		title: tag.name,
		iconColor: colorHelper.icon,
		Icon: TagIcon,
		fields: [
			{
				label: 'Description',
				value: tag.description
			},
			{
				label: 'Color',
				value: [
					{
						id: 'color',
						label: tag.color.charAt(0).toUpperCase() + tag.color.slice(1),
						color: tag.color
					}
				]
			}
		],
		actions: [
			{
				label: 'Delete',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(tag)
			},
			{
				label: 'Edit',
				icon: Edit,
				onClick: () => onEdit(tag)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
