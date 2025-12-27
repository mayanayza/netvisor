<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { useTopologiesQuery } from '$lib/features/topology/queries';
	import { topology as selectedTopology } from '$lib/features/topology/store';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	let { node }: { node: Node } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext
			? $topologyContext
			: (topologiesData.find((t) => t.id === $selectedTopology?.id) ?? $selectedTopology)
	);

	let subnet = $derived(topology ? topology.subnets.find((s) => s.id == node.id) : null);
</script>

<div class="space-y-4">
	{#if subnet}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Subnet</span>
			<div class="card">
				<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
			</div>
		</div>
	{/if}
</div>
