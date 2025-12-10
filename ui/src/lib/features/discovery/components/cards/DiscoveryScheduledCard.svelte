<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { Edit, Play, Trash2 } from 'lucide-svelte';
	import type { Discovery } from '../../types/base';
	import { daemons } from '$lib/features/daemons/store';
	import { parseCronToHours } from '../../store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { tags } from '$lib/features/tags/store';

	export let viewMode: 'card' | 'list';
	export let discovery: Discovery;
	export let onEdit: (discovery: Discovery) => void = () => {};
	export let onDelete: (discovery: Discovery) => void = () => {};
	export let onRun: (discovery: Discovery) => void = () => {};
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: cardData = {
		title: discovery.name,
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		fields: [
			{
				label: 'Daemon',
				value: $daemons.find((d) => d.id == discovery.daemon_id)?.name || 'Unknown Daemon'
			},
			{
				label: 'Type',
				value: discovery.discovery_type.type
			},
			{
				label: 'Schedule',
				value:
					discovery.run_type.type == 'Scheduled'
						? `Every ${parseCronToHours(discovery.run_type.cron_schedule) || 'Unknown'} Hours`
						: 'Manual'
			},
			{
				label: 'Last Run',
				value:
					discovery.run_type.type != 'Historical' && discovery.run_type.last_run
						? formatTimestamp(discovery.run_type.last_run)
						: 'Never'
			},
			{
				label: 'Tags',
				value: discovery.tags.map((t) => {
					const tag = $tags.find((tag) => tag.id == t);
					return tag
						? { id: tag.id, color: tag.color, label: tag.name }
						: { id: t, color: 'gray', label: 'Unknown Tag' };
				})
			}
		],
		actions: [
			{
				label: 'Edit',
				icon: Edit,
				class: `btn-icon`,
				onClick: () => onEdit(discovery)
			},
			{
				label: 'Run',
				icon: Play,
				class: `btn-icon`,
				onClick: () => onRun(discovery)
			},
			{
				label: 'Delete',
				icon: Trash2,
				class: `btn-icon`,
				onClick: () => onDelete(discovery)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
