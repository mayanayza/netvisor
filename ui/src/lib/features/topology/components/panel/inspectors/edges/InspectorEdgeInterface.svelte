<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { useTopologiesQuery } from '$lib/features/topology/queries';
	import { topology as selectedTopology } from '$lib/features/topology/store';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	let { edge, hostId }: { edge: Edge; hostId: string } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext
			? $topologyContext
			: (topologiesData.find((t) => t.id === $selectedTopology?.id) ?? $selectedTopology)
	);

	let host = $derived(topology ? topology.hosts.find((h) => h.id == hostId) : null);

	let sourceInterface = $derived(topology?.interfaces.find((i) => i.id == edge.source));
	let targetInterface = $derived(topology?.interfaces.find((i) => i.id == edge.target));

	// Context for interface displays
	let interfaceContext = $derived({ subnets: topology?.subnets ?? [] });
</script>

<div class="space-y-3">
	{#if host}
		<span class="text-secondary mb-2 block text-sm font-medium">Host</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={host} displayComponent={HostDisplay} />
		</div>
	{/if}
	<span class="text-secondary mb-2 block text-sm font-medium">Interfaces</span>
	{#if sourceInterface}
		<div class="card">
			<EntityDisplayWrapper
				context={interfaceContext}
				item={sourceInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}

	{#if targetInterface}
		<div class="card">
			<EntityDisplayWrapper
				context={interfaceContext}
				item={targetInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}
</div>
