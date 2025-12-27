<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { Info } from 'lucide-svelte';
	import type { Discovery } from '../../types/base';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';

	// Queries
	const daemonsQuery = useDaemonsQuery();

	// Derived data
	let daemonsData = $derived(daemonsQuery.data ?? []);

	let {
		viewMode,
		discovery,
		onView = () => {},
		selected,
		onSelectionChange = () => {}
	}: {
		viewMode: 'card' | 'list';
		discovery: Discovery;
		onView?: (discovery: Discovery) => void;
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let results = $derived(
		discovery.run_type.type == 'Historical' ? discovery.run_type.results : null
	);

	let cardData = $derived({
		title: discovery.name,
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		fields: [
			{
				label: 'Daemon',
				value: daemonsData.find((d) => d.id == discovery.daemon_id)?.name || 'Unknown Daemon'
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
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
