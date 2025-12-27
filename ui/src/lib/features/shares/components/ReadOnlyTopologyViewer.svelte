<script lang="ts">
	import { SvelteFlowProvider, type Node, type Edge } from '@xyflow/svelte';
	import BaseTopologyViewer from '$lib/features/topology/components/visualization/BaseTopologyViewer.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import { setContext } from 'svelte';
	import { writable } from 'svelte/store';
	import ReadOnlyInspectorPanel from './ReadOnlyInspectorPanel.svelte';
	import ExportButton from '$lib/features/topology/components/ExportButton.svelte';
	import { Share2 } from 'lucide-svelte';

	export let topology: Topology;
	export let showControls: boolean = true;
	export let showInspectPanel: boolean = true;
	export let showExport: boolean = false;
	export let isEmbed: boolean = false;
	export let shareName: string = '';

	// Create a context store for the topology so child components (inspectors) can access it
	const topologyContext = writable<Topology>(topology);
	setContext('topology', topologyContext);

	// Create local stores for selected node/edge (instead of using global store)
	const selectedNodeStore = writable<Node | null>(null);
	const selectedEdgeStore = writable<Edge | null>(null);
	setContext('selectedNode', selectedNodeStore);
	setContext('selectedEdge', selectedEdgeStore);

	// Keep context in sync with prop
	$: topologyContext.set(topology);

	// Selection state for binding
	let localSelectedNode: Node | null = null;
	let localSelectedEdge: Edge | null = null;

	// Update local stores when selection changes (needed for node/edge highlighting)
	function handleNodeSelect(node: Node | null) {
		selectedNodeStore.set(node);
		selectedEdgeStore.set(null);
	}

	function handleEdgeSelect(edge: Edge | null) {
		selectedEdgeStore.set(edge);
		selectedNodeStore.set(null);
	}

	function handlePaneSelect() {
		selectedNodeStore.set(null);
		selectedEdgeStore.set(null);
	}
</script>

<SvelteFlowProvider>
	<div class="flex h-full w-full flex-col">
		{#if shareName}
			<header
				class="flex flex-shrink-0 items-center justify-between border-b border-gray-700 bg-gray-800 px-4 py-3"
			>
				<div class="flex items-center gap-3">
					<Share2 class="text-info h-8 w-8" />
					<h1 class="text-primary font-semibold">{shareName}</h1>
				</div>
				<div class="flex items-center gap-4">
					{#if showExport}
						<ExportButton />
					{/if}
				</div>
			</header>
		{/if}
		<div class="relative min-h-0 flex-1">
			{#if showInspectPanel}
				<ReadOnlyInspectorPanel />
			{/if}
			<BaseTopologyViewer
				{topology}
				readonly={true}
				{showControls}
				{isEmbed}
				showBranding={true}
				bind:selectedNode={localSelectedNode}
				bind:selectedEdge={localSelectedEdge}
				onNodeSelect={handleNodeSelect}
				onEdgeSelect={handleEdgeSelect}
				onPaneSelect={handlePaneSelect}
			/>
		</div>
	</div>
</SvelteFlowProvider>
