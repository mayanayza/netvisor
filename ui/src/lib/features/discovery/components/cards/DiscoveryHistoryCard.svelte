<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { Info } from 'lucide-svelte';
	import type { Discovery } from '../../types/base';
	import { daemons } from '$lib/features/daemons/store';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';

	export let viewMode: 'card' | 'list';
	export let discovery: Discovery;
	export let onView: (discovery: Discovery) => void = () => {};
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: results = discovery.run_type.type == 'Historical' ? discovery.run_type.results : null;

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
				label: 'Started',
				value: results && results.started_at ? formatTimestamp(results.started_at) : 'Unknown'
			},
			{
				label: 'Finished',
				value: results && results.finished_at ? formatTimestamp(results.finished_at) : 'Unknown'
			},
			{
				label: 'Duration',
				value: (() => {
					const results =
						discovery.run_type.type == 'Historical' ? discovery.run_type.results : null;
					if (results && results.finished_at && results.started_at) {
						return formatDuration(results.started_at, results.finished_at);
					}
					return 'Unknown';
				})()
			}
		],
		actions: [
			{
				label: 'Details',
				icon: Info,
				class: `btn-icon`,
				onClick: () => onView(discovery)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
