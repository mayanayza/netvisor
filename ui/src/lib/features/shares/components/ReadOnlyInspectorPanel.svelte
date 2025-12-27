<script lang="ts">
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';
	import type { Node, Edge } from '@xyflow/svelte';
	import { ChevronLeft, ChevronRight, Info } from 'lucide-svelte';
	import InspectorNode from '$lib/features/topology/components/panel/inspectors/InspectorNode.svelte';
	import InspectorEdge from '$lib/features/topology/components/panel/inspectors/InspectorEdge.svelte';

	// Get selected node/edge from context (set by ReadOnlyTopologyViewer)
	const selectedNode = getContext<Writable<Node | null>>('selectedNode');
	const selectedEdge = getContext<Writable<Edge | null>>('selectedEdge');

	let expanded = $state(true);

	// Automatically expand when something is selected
	$effect(() => {
		if ($selectedNode || $selectedEdge) {
			expanded = true;
		}
	});
</script>

<!-- Floating Panel -->
<div
	class="topology-options absolute left-4 top-4 z-10 duration-300 {expanded ? 'w-80' : 'w-auto'}"
>
	<div class="card p-0 shadow-lg">
		{#if expanded}
			<!-- Header with title and collapse button -->
			<div class="flex items-center border-b border-gray-700">
				<!-- Collapse button -->
				<button
					class="btn-icon rounded-xl p-3"
					onclick={() => (expanded = false)}
					aria-label="Collapse panel"
				>
					<ChevronLeft class="text-secondary h-5 w-5" />
				</button>
				<!-- Title -->
				<div class="text-primary flex-1 px-4 py-3 text-sm font-medium">
					<Info class="mr-1 inline h-4 w-4" />
					Inspector
				</div>
			</div>

			<!-- Content -->
			<div class="overflow-y-auto p-3" style="max-height: calc(100vh - 200px);">
				{#if $selectedNode}
					{#key $selectedNode.id}
						<InspectorNode node={$selectedNode} />
					{/key}
				{:else if $selectedEdge}
					{#key $selectedEdge.id}
						<InspectorEdge edge={$selectedEdge} />
					{/key}
				{:else}
					<div class="text-tertiary py-8 text-center text-sm">
						Click on a node or edge to inspect it
					</div>
				{/if}
			</div>
		{:else}
			<!-- Collapsed toggle button -->
			<button
				class="btn-icon rounded-2xl p-3"
				onclick={() => (expanded = true)}
				aria-label="Expand panel"
			>
				<ChevronRight class="text-secondary h-5 w-5" />
			</button>
		{/if}
	</div>
</div>
