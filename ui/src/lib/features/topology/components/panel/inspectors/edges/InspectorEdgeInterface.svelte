<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { topology as globalTopology } from '$lib/features/topology/store';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	let { edge, hostId }: { edge: Edge; hostId: string } = $props();

	// Try to get topology from context (for share/embed pages), fallback to global store
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	let topology = $derived(topologyContext ? $topologyContext : $globalTopology);

	let host = $derived(topology ? topology.hosts.find((h) => h.id == hostId) : null);

	let sourceInterface = $derived(topology?.interfaces.find((i) => i.id == edge.source));
	let targetInterface = $derived(topology?.interfaces.find((i) => i.id == edge.target));
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
				context={{}}
				item={sourceInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}

	{#if targetInterface}
		<div class="card">
			<EntityDisplayWrapper
				context={{}}
				item={targetInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}
</div>
