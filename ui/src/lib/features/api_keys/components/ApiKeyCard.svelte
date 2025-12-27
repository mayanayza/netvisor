<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { toColor } from '$lib/shared/utils/styling';
	import { Edit, Trash2 } from 'lucide-svelte';
	import type { ApiKey } from '../types/base';
	import { useTagsQuery } from '$lib/features/tags/queries';

	// Tags query
	const tagsQuery = useTagsQuery();
	let tagsData = $derived(tagsQuery.data ?? []);

	let {
		apiKey,
		onDelete = () => {},
		onEdit = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: {
		apiKey: ApiKey;
		onDelete?: (apiKey: ApiKey) => void;
		onEdit?: (apiKey: ApiKey) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	// Build card data
	let cardData = $derived({
		title: apiKey.name,
		iconColor: entities.getColorHelper('ApiKey').icon,
		Icon: entities.getIconComponent('ApiKey'),
		fields: [
			{
				label: 'Created',
				value: formatTimestamp(apiKey.created_at)
			},
			{
				label: 'Last Used',
				value: apiKey.last_used ? formatTimestamp(apiKey.last_used) : 'Never'
			},
			{
				label: 'Expires',
				value: apiKey.expires_at
					? new Date(apiKey.expires_at) < new Date()
						? 'Expired'
						: formatTimestamp(apiKey.expires_at)
					: 'Never'
			},
			{
				label: 'Enabled',
				value: apiKey.is_enabled ? 'Yes' : 'No'
			},
			{
				label: 'Tags',
				value: apiKey.tags.map((t) => {
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
				onClick: () => onDelete(apiKey)
			},
			{
				label: 'Edit',
				icon: Edit,
				class: 'btn-icon',
				onClick: () => onEdit(apiKey)
			}
		]
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
