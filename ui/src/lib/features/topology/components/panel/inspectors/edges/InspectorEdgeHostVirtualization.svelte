<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { useTopologiesQuery } from '$lib/features/topology/queries';
	import { topology as selectedTopology } from '$lib/features/topology/store';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	let { edge, vmServiceId }: { edge: Edge; vmServiceId: string } = $props();

	// Try to get topology from context (for share/embed pages), fallback to query + selected topology
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	const topologiesQuery = useTopologiesQuery();
	let topologiesData = $derived(topologiesQuery.data ?? []);
	let topology = $derived(
		topologyContext
			? $topologyContext
			: (topologiesData.find((t) => t.id === $selectedTopology?.id) ?? $selectedTopology)
	);

	let vmService = $derived(topology ? topology.services.find((s) => s.id == vmServiceId) : null);
	let hypervisorHost = $derived(topology ? topology.hosts.find((h) => h.id == edge.target) : null);
</script>

<div class="space-y-3">
	{#if vmService}
		<span class="text-secondary mb-2 block text-sm font-medium">VM Service</span>
		<div class="card">
			<EntityDisplayWrapper
				context={{ interfaceId: null }}
				item={vmService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/if}

	{#if hypervisorHost}
		<span class="text-secondary mb-2 block text-sm font-medium">Hypervisor Host</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={hypervisorHost} displayComponent={HostDisplay} />
		</div>
	{/if}
</div>
