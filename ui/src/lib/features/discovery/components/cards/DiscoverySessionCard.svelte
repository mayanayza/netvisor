<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { cancelDiscovery, cancelling } from '$lib/features/discovery/SSEStore';
	import { entities } from '$lib/shared/stores/metadata';
	import { Loader2, X } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../../types/api';
	import { daemons } from '../../../daemons/store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	export let viewMode: 'card' | 'list';
	export let session: DiscoveryUpdatePayload;

	$: daemon = $daemons.find((d) => d.id == session.daemon_id);

	$: isCancelling = session?.session_id ? $cancelling.get(session.session_id) === true : false;

	// Calculate progress
	$: progressPercent = (() => {
		const progress =
			session.processed && session.total_to_process && session.total_to_process > 0
				? session.processed / session.total_to_process
				: 0;

		return Math.min(100, progress * 100);
	})();

	async function handleCancelDiscovery() {
		await cancelDiscovery(session.session_id);
	}

	// Build card data
	$: cardData = {
		title:
			session.discovery_type.type + ' Discovery on ' + (daemon ? daemon?.ip : 'Unknown Daemon'),
		iconColor: entities.getColorHelper('Discovery').icon,
		Icon: entities.getIconComponent('Discovery'),
		fields: [
			{
				label: 'Started',
				value: session.started_at ? formatTimestamp(session.started_at) : 'Not Yet'
			},
			{
				label: 'Session ID',
				value: session.session_id
			},
			{
				label: 'Running On',
				value: daemon ? `Daemon @ ${daemon.ip}` : 'Unknown Daemon'
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
	};
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
						style="width: {progressPercent}%"
					></div>
				</div>
				<span class="text-secondary text-xs">{Math.round(progressPercent)}%</span>
			</div>
		</div>
	</div>
{/snippet}

<GenericCard {...cardData} {viewMode} />
