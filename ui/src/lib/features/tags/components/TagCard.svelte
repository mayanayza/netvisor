<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { Tag } from '../types/base';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import { TagIcon } from 'lucide-svelte';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { permissions } from '$lib/shared/stores/metadata';

	let {
		tag,
		onEdit = () => {},
		onDelete = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		tag: Tag;
		onEdit?: (tag: Tag) => void;
		onDelete?: (tag: Tag) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	let colorHelper = $derived(createColorHelper(tag.color));

	let canManageNetworks = $derived(
		(currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities) || false
	);

	let cardData = $derived({
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
			...(canManageNetworks
				? [
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
				: [])
		]
	});
</script>

<GenericCard
	{...cardData}
	{viewMode}
	{selected}
	{onSelectionChange}
	selectable={canManageNetworks}
/>
