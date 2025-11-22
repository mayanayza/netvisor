<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { networks } from '$lib/features/networks/store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { Edit, Trash2 } from 'lucide-svelte';
	import type { ApiKey } from '../types/base';

	export let apiKey: ApiKey;
	export let onDelete: (apiKey: ApiKey) => void = () => {};
	export let onEdit: (apiKey: ApiKey) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	// Build card data
	$: cardData = {
		title: apiKey.name,
		iconColor: entities.getColorHelper('ApiKey').icon,
		Icon: entities.getIconComponent('ApiKey'),
		fields: [
			{
				label: 'Network',
				value: $networks.find((n) => n.id == apiKey.network_id)?.name || 'Unknown Network'
			},
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
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
