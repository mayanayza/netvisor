<script lang="ts">
	import { CheckCircle, XCircle, AlertCircle, Clock } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../../types/api';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';

	export let payload: DiscoveryUpdatePayload;

	$: phaseIcon = (() => {
		switch (payload.phase) {
			case 'Complete':
				return CheckCircle;
			case 'Failed':
				return XCircle;
			case 'Cancelled':
				return AlertCircle;
			default:
				return Clock;
		}
	})();

	$: phaseColor = (() => {
		switch (payload.phase) {
			case 'Complete':
				return 'text-green-400';
			case 'Failed':
				return 'text-red-400';
			case 'Cancelled':
				return 'text-yellow-400';
			default:
				return 'text-blue-400';
		}
	})();

	$: phaseBg = (() => {
		switch (payload.phase) {
			case 'Complete':
				return 'bg-green-900/20 border-green-800';
			case 'Failed':
				return 'bg-red-900/20 border-red-800';
			case 'Cancelled':
				return 'bg-yellow-900/20 border-yellow-800';
			default:
				return 'bg-blue-900/20 border-blue-800';
		}
	})();

	$: duration = (() => {
		if (!payload.started_at || !payload.finished_at) return null;

		return formatDuration(payload.started_at, payload.finished_at);
	})();
</script>

<div class="space-y-4 border-t border-gray-700 pt-6">
	<h3 class="text-primary text-lg font-medium">Discovery Run Summary</h3>

	<!-- Status Banner -->
	<div class="rounded-lg border {phaseBg} p-4">
		<div class="flex items-center gap-3">
			<svelte:component this={phaseIcon} class="h-6 w-6 {phaseColor}" />
			<div class="flex-1">
				<div class="flex items-center gap-2">
					<span class="text-primary text-lg font-semibold">{payload.phase}</span>
				</div>
				{#if payload.error}
					<p class="mt-1 text-sm text-red-300">{payload.error}</p>
				{/if}
			</div>
		</div>
	</div>

	<!-- Details Grid -->
	<div class="grid grid-cols-2 gap-4">
		<!-- Session ID -->
		<div class="card p-4">
			<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Session ID</div>
			<div class="text-secondary font-mono text-sm">{payload.session_id}</div>
		</div>

		<!-- Discovery Type -->
		<div class="card p-4">
			<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">
				Discovery Type
			</div>
			<div class="text-secondary text-sm">{payload.discovery_type.type}</div>
		</div>

		<!-- Processed -->
		{#if payload.total_to_process !== undefined && payload.processed !== undefined}
			<div class="card p-4">
				<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Processed</div>
				<div class="flex items-center gap-2">
					<div class="text-secondary text-sm">
						{payload.processed} / {payload.total_to_process}
					</div>
					<div class="h-2 flex-1 overflow-hidden rounded-full bg-gray-700">
						<div
							class="h-full bg-blue-500 transition-all"
							style="width: {(payload.processed / payload.total_to_process) * 100}%"
						></div>
					</div>
				</div>
			</div>
		{/if}

		<!-- Duration -->
		{#if duration}
			<div class="card p-4">
				<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Duration</div>
				<div class="text-secondary text-sm">{duration}</div>
			</div>
		{/if}

		<!-- Start Time -->
		{#if payload.started_at}
			<div class="card p-4">
				<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Started</div>
				<div class="text-secondary text-sm">{formatTimestamp(payload.started_at)}</div>
			</div>
		{/if}

		<!-- End Time -->
		{#if payload.finished_at}
			<div class="card p-4">
				<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Finished</div>
				<div class="text-secondary text-sm">{formatTimestamp(payload.finished_at)}</div>
			</div>
		{/if}
	</div>

	<!-- Type-specific Details -->
	{#if payload.discovery_type.type === 'Network'}
		<div class="card p-4">
			<div class="text-tertiary mb-2 text-xs font-medium uppercase tracking-wide">
				Network Scan Details
			</div>
			<div class="text-secondary text-sm">
				{#if payload.discovery_type.subnet_ids === null}
					Scanned all subnets that daemon had an interface with at time of scan
				{:else}
					Scanned {payload.discovery_type.subnet_ids.length} specific subnet{payload.discovery_type
						.subnet_ids.length !== 1
						? 's'
						: ''}
				{/if}
			</div>
		</div>
	{:else if payload.discovery_type.type === 'Docker'}
		<div class="card p-4">
			<div class="text-tertiary mb-2 text-xs font-medium uppercase tracking-wide">
				Docker Scan Details
			</div>
			<div class="text-secondary font-mono text-sm">
				Host ID: {payload.discovery_type.host_id}
			</div>
		</div>
	{:else if payload.discovery_type.type === 'SelfReport'}
		<div class="card p-4">
			<div class="text-tertiary mb-2 text-xs font-medium uppercase tracking-wide">
				Self Report Details
			</div>
			<div class="text-secondary font-mono text-sm">
				Host ID: {payload.discovery_type.host_id}
			</div>
		</div>
	{/if}
</div>
