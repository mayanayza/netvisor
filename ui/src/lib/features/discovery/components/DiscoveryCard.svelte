<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { cancelDiscovery, cancelling } from '$lib/features/discovery/store';
	import { entities } from '$lib/shared/stores/metadata';
	import { Loader2, X } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../types/api';
	import { daemons } from '../../daemons/store';
	import { hosts } from '../../hosts/store';

	export let viewMode: 'card' | 'list';
	export let session: DiscoveryUpdatePayload;

	// ...(daemon.api_key
	// ? [
	// 		{
	// 			label: 'Run Discovery',
	// 			icon: entities.getIconComponent('Discovery'),
	// 			class: daemonIsRunningDiscovery ? 'btn-icon-success' : 'btn-icon',
	// 			onClick: !daemonIsRunningDiscovery ? () => onDiscovery(daemon) : () => {},
	// 			disabled: daemonIsRunningDiscovery
	// 		}
	// 	]
	// : []),

	$: daemon = $daemons.find((d) => d.id == session.daemon_id);
	$: host = $hosts.find((h) => h.id == daemon?.host_id);

	$: isCancelling = session?.session_id ? $cancelling.get(session.session_id) === true : false;

	// Calculate progress
	$: progressPercent = (() => {
		const progress =
			session.completed && session.total && session.total > 0
				? session.completed / session.total
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
				value: session.started_at
			},
			{
				label: 'Session ID',
				value: session.session_id
			},
			{
				label: 'Running On',
				value: (() => {
					if (host) {
						return 'Daemon on Host ' + host.name;
					} else if (daemon) {
						return 'Daemon ' + daemon.ip;
					}
					return 'Unknown Host/Daemon';
				})()
			},
			...(session.phase == 'Pending'
				? [
						{
							label: 'Phase',
							value: session.phase
						}
					]
				: [])
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

<GenericCard {...cardData} {viewMode}>
	{#snippet footer()}
		{#if session.phase != 'Pending'}
			<div class="mt-2 flex items-center justify-between gap-3 pt-2">
				<div class="flex-1 space-y-2">
					<div class="flex items-center gap-3">
						<span class="text-secondary text-sm font-medium">Phase: </span>
						<span class="text-accent text-sm font-medium"
							>{isCancelling ? 'Cancelling' : session.phase}</span
						>
					</div>

					{#if session.total && session.total > 0}
						<div class="flex items-center gap-2">
							<div class="h-2 flex-1 overflow-hidden rounded-full bg-gray-700">
								<div
									class="h-full bg-blue-500 transition-all duration-300 ease-out"
									style="width: {progressPercent}%"
								></div>
							</div>
							<span class="text-secondary text-xs">{Math.round(progressPercent)}%</span>
						</div>
					{/if}
				</div>
			</div>
		{/if}
	{/snippet}
</GenericCard>
