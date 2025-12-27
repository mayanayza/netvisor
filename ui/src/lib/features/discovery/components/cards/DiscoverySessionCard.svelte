<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { cancelDiscovery, cancelling } from '$lib/features/discovery/sse';
	import { entities } from '$lib/shared/stores/metadata';
	import { Loader2, X } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../../types/api';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	// Props
	let {
		viewMode,
		session
	}: {
		viewMode: 'card' | 'list';
		session: DiscoveryUpdatePayload;
	} = $props();

	// Queries
	const daemonsQuery = useDaemonsQuery();

	// Derived data
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let daemon = $derived(daemonsData.find((d) => d.id == session.daemon_id));
	let isCancelling = $derived(
		session?.session_id ? $cancelling.get(session.session_id) === true : false
	);

	async function handleCancelDiscovery() {
		await cancelDiscovery(session.session_id);
	}

	// Build card data
	let cardData = $derived({
		title: session.discovery_type.type + ' Discovery',
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		fields: [
			{
				label: 'Daemon',
				value: daemon ? daemon.name : 'Unknown Daemon'
			},
			{
				label: 'Started',
				value: session.started_at ? formatTimestamp(session.started_at) : 'Not Yet'
			},
			{
				label: 'Session ID',
				value: session.session_id
			},
			{
				label: '', // No label needed for snippet
				snippet: progressSnippet
			}
		],
		actions: [
			{
				label: 'Cancel Discovery',
				icon: isCancelling ? Loader2 : X,
				class: `btn-icon-danger ${isCancelling ? 'animate-spin' : ''}`,
				onClick: isCancelling ? () => {} : () => handleCancelDiscovery()
			}
		]
	});
</script>

{#snippet progressSnippet()}
	<div class="flex items-center justify-between gap-3">
		<div class="flex-1 space-y-2">
			<div class="flex items-center gap-3">
				<span class={`text-secondary ${viewMode == 'list' ? 'text-xs' : 'text-sm'} font-medium`}
					>Phase:
				</span>
				<span class={`text-accent ${viewMode == 'list' ? 'text-xs' : 'text-sm'} font-medium`}
					>{isCancelling ? 'Cancelling' : session.phase}</span
				>
			</div>

			<div class="flex items-center gap-2">
				<div class="h-2 flex-1 overflow-hidden rounded-full bg-gray-700">
					<div
						class="h-full bg-blue-500 transition-all duration-300 ease-out"
						style="width: {session.progress}%"
					></div>
				</div>
				<span class="text-secondary text-xs">{session.progress}%</span>
			</div>
		</div>
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} selectable={false} />
