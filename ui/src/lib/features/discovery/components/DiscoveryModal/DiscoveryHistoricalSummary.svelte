<script lang="ts">
	import { CheckCircle, XCircle, AlertCircle, Clock } from 'lucide-svelte';
	import type { DiscoveryUpdatePayload } from '../../types/api';
	import { formatDuration, formatTimestamp } from '$lib/shared/utils/formatting';
	import { useSubnetsQuery, getSubnetById } from '$lib/features/subnets/queries';

	interface Props {
		payload: DiscoveryUpdatePayload;
	}

	let { payload }: Props = $props();

	// TanStack Query for subnets
	const subnetsQuery = useSubnetsQuery();
	let subnetsData = $derived(subnetsQuery.data ?? []);

	let phaseStyles = $derived.by(() => {
		switch (payload.phase) {
			case 'Complete':
				return {
					icon: CheckCircle,
					color: 'text-green-400',
					bg: 'bg-green-900/20 border-green-800'
				};
			case 'Failed':
				return {
					icon: XCircle,
					color: 'text-red-400',
					bg: 'bg-red-900/20 border-red-800'
				};
			case 'Cancelled':
				return {
					icon: AlertCircle,
					color: 'text-yellow-400',
					bg: 'bg-yellow-900/20 border-yellow-800'
				};
			default:
				return {
					icon: Clock,
					color: 'text-blue-400',
					bg: 'bg-blue-900/20 border-blue-800'
				};
		}
	});

	let duration = $derived(
		payload.started_at && payload.finished_at
			? formatDuration(payload.started_at, payload.finished_at)
			: null
	);

	// Helper to get subnet name by ID
	function getSubnetName(subnetId: string): string {
		const subnet = getSubnetById(subnetsData, subnetId);
		return subnet?.name || 'Unknown Subnet';
	}
</script>

<div class="space-y-4 border-t border-gray-700 pt-6">
	<h3 class="text-primary text-lg font-medium">Discovery Run Summary</h3>

	<!-- Status Banner -->
	<div class="rounded-lg border {phaseStyles.bg} p-4">
		<div class="flex items-center gap-3">
			<phaseStyles.icon class="h-6 w-6 {phaseStyles.color}"></phaseStyles.icon>
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
		{#if payload.progress !== undefined}
			<div class="card p-4">
				<div class="text-tertiary mb-1 text-xs font-medium uppercase tracking-wide">Progress</div>
				<div class="flex items-center gap-2">
					<div class="text-secondary text-sm">
						{payload.progress}%
					</div>
					<div class="h-2 flex-1 overflow-hidden rounded-full bg-gray-700">
						<div class="h-full bg-blue-500 transition-all" style="width: {payload.progress}%"></div>
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
					Scanned {payload.discovery_type.subnet_ids.map((s) => getSubnetName(s)).join(', ')}
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
