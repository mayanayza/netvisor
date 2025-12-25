<script lang="ts">
	import { writable, get } from 'svelte/store';
	import {
		SvelteFlow,
		Controls,
		Background,
		BackgroundVariant,
		type EdgeMarkerType,
		useNodesInitialized,
		type Connection,
		useSvelteFlow
	} from '@xyflow/svelte';
	import { type Node, type Edge } from '@xyflow/svelte';
	import '@xyflow/svelte/dist/style.css';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import { pushError } from '$lib/shared/stores/feedback';

	// Import custom node/edge components
	import SubnetNode from './SubnetNode.svelte';
	import InterfaceNode from './InterfaceNode.svelte';
	import CustomEdge from './CustomEdge.svelte';
	import type { TopologyEdge, Topology } from '../../types/base';
	import { updateConnectedNodes, toggleEdgeHover, getEdgeDisplayState } from '../../interactions';
	import { onMount, tick, setContext } from 'svelte';
	import { writable as svelteWritable } from 'svelte/store';

	// Props
	export let topology: Topology;
	export let readonly: boolean = false;
	export let showControls: boolean = true;
	export let isEmbed: boolean = false;
	export let showBranding: boolean = false;

	// Create a context store for the topology so child nodes can access it
	const topologyContext = svelteWritable<Topology>(topology);
	setContext('topology', topologyContext);

	// Keep context in sync with prop
	$: topologyContext.set(topology);

	// Selection state - can be bound by parent
	export let selectedNode: Node | null = null;
	export let selectedEdge: Edge | null = null;

	// Optional callbacks for editing
	export let onNodeDragStop: ((node: Node) => void) | null = null;
	export let onReconnect: ((edge: Edge, newConnection: Connection) => void) | null = null;

	// Optional callbacks for selection changes
	export let onNodeSelect: ((node: Node | null) => void) | null = null;
	export let onEdgeSelect: ((edge: Edge | null) => void) | null = null;
	export let onPaneSelect: (() => void) | null = null;

	const { fitView } = useSvelteFlow();
	let containerElement: HTMLDivElement;

	export function triggerFitView() {
		requestAnimationFrame(() => fitView());
	}

	onMount(() => {
		const { fitView } = useSvelteFlow();

		const observer = new IntersectionObserver(
			(entries) => {
				if (entries[0].isIntersecting) {
					requestAnimationFrame(() => fitView());
					observer.disconnect();
				}
			},
			{ threshold: 0.1 }
		);

		if (containerElement) {
			observer.observe(containerElement);
		}

		return () => observer.disconnect();
	});

	// Define node types
	const nodeTypes = {
		SubnetNode: SubnetNode,
		InterfaceNode: InterfaceNode
	};

	const customEdgeTypes = {
		custom: CustomEdge
	};

	// Stores for SvelteFlow
	let nodes = writable<Node[]>([]);
	let edges = writable<Edge[]>([]);

	// Hook to check when nodes are initialized
	const nodesInitialized = useNodesInitialized();

	// Store pending edges until nodes are ready
	let pendingEdges: Edge[] = [];

	// Load topology data when it changes
	$: if (topology && (topology.edges || topology.nodes)) {
		void loadTopologyData();
	}

	// Update edges when selection changes
	$: {
		void selectedNode;
		void selectedEdge;

		if (topology && (topology.edges || topology.nodes)) {
			const currentEdges = get(edges);
			const currentNodes = get(nodes);
			updateConnectedNodes(selectedNode, selectedEdge, currentEdges, currentNodes);

			// Update edge animated state based on selection
			const updatedEdges = currentEdges.map((edge) => {
				const { shouldAnimate } = getEdgeDisplayState(edge, selectedNode, selectedEdge);

				return {
					...edge,
					id: edge.id, // Force new reference
					animated: shouldAnimate
				};
			});

			edges.set(updatedEdges);
		}
	}

	// Add edges when nodes are ready
	$: if (nodesInitialized.current && pendingEdges.length > 0) {
		edges.set(pendingEdges);
		pendingEdges = [];
	}

	async function loadTopologyData() {
		try {
			if (topology && (topology.edges || topology.nodes)) {
				// Create nodes FIRST
				const allNodes: Node[] = topology.nodes.map((node) => ({
					id: node.id,
					type: node.node_type,
					position: { x: node.position.x, y: node.position.y },
					width: node.size.x,
					height: node.size.y,
					expandParent: true,
					deletable: false,
					parentId: node.node_type == 'InterfaceNode' ? node.subnet_id : undefined,
					extent: node.node_type == 'InterfaceNode' ? 'parent' : undefined,
					data: node
				}));

				// Save current edge animated states before clearing
				const currentEdges = get(edges);
				const animatedStates = new Map(currentEdges.map((edge) => [edge.id, edge.animated]));

				// Clear edges FIRST
				edges.set([]);

				// Sort so children come before parents (as per Svelte Flow docs)
				const sortedNodes = allNodes.sort((a, b) => {
					if (a.parentId && !b.parentId) return 1; // children first
					if (!a.parentId && b.parentId) return -1; // parents second
					return 0;
				});

				// Set nodes
				nodes.set(sortedNodes);

				// Create edges with markers
				const flowEdges: Edge[] = topology.edges
					.filter((edge) => edge.edge_type != 'HostVirtualization')
					.map((edge: TopologyEdge, index: number) => {
						const edgeType = edge.edge_type as string;
						const edgeMetadata = edgeTypes.getMetadata(edgeType);
						const edgeColorHelper = edgeTypes.getColorHelper(edgeType);

						const markerStart = !edgeMetadata.has_start_marker
							? undefined
							: ({
									type: 'arrow',
									color: edgeColorHelper.rgb
								} as EdgeMarkerType);
						const markerEnd = !edgeMetadata.has_end_marker
							? undefined
							: ({
									type: 'arrow',
									color: edgeColorHelper.rgb
								} as EdgeMarkerType);

						const edgeId = `edge-${index}`;

						return {
							id: `edge-${index}`,
							source: edge.source,
							target: edge.target,
							markerEnd,
							markerStart,
							sourceHandle: edge.source_handle.toString(),
							targetHandle: edge.target_handle.toString(),
							type: 'custom',
							label: edge.label ?? undefined,
							data: { ...edge, edgeIndex: index },
							animated: animatedStates.get(edgeId) ?? false,
							interactionWidth: 50
						};
					});

				pendingEdges = flowEdges;

				// Wait for nodes to render, then set edges
				await tick();
				if (pendingEdges.length > 0) {
					edges.set(pendingEdges);
					pendingEdges = [];
				}
			}
		} catch (err) {
			pushError(`Failed to parse topology data ${err}`);
		}
	}

	function handleNodeDragStop({
		targetNode
	}: {
		targetNode: Node | null;
		nodes: Node[];
		event: MouseEvent | TouchEvent;
	}) {
		if (onNodeDragStop && targetNode) {
			onNodeDragStop(targetNode);
		}
	}

	function handleReconnect(edge: Edge, newConnection: Connection) {
		if (onReconnect) {
			onReconnect(edge, newConnection);
		}
	}

	function handleNodeClick({ node }: { node: Node; event: MouseEvent | TouchEvent }) {
		selectedNode = node;
		selectedEdge = null;
		if (onNodeSelect) {
			onNodeSelect(node);
		}
	}

	function handleEdgeClick({ edge }: { edge: Edge; event: MouseEvent }) {
		selectedEdge = edge;
		selectedNode = null;
		if (onEdgeSelect) {
			onEdgeSelect(edge);
		}
	}

	function handlePaneClick() {
		selectedNode = null;
		selectedEdge = null;
		if (onPaneSelect) {
			onPaneSelect();
		}
	}

	function handleEdgeHover({ edge }: { edge: Edge }) {
		const currentEdges = get(edges);
		toggleEdgeHover(edge, currentEdges);

		// Update animated state for all edges after hover toggle
		const updatedEdges = currentEdges.map((e) => {
			const { shouldAnimate } = getEdgeDisplayState(e, selectedNode, selectedEdge);

			return {
				...e,
				id: e.id,
				animated: shouldAnimate
			};
		});

		edges.set(updatedEdges);
	}
</script>

<div
	class="h-full w-full overflow-hidden"
	class:rounded-2xl={!isEmbed}
	class:border={!isEmbed}
	class:border-gray-700={!isEmbed}
	bind:this={containerElement}
>
	<SvelteFlow
		nodes={$nodes}
		edges={$edges}
		{nodeTypes}
		edgeTypes={customEdgeTypes}
		onpaneclick={handlePaneClick}
		onedgeclick={handleEdgeClick}
		onnodeclick={handleNodeClick}
		onedgepointerenter={handleEdgeHover}
		onedgepointerleave={handleEdgeHover}
		onnodedragstop={readonly ? undefined : handleNodeDragStop}
		onreconnect={readonly ? undefined : handleReconnect}
		fitView={true}
		minZoom={0.1}
		noPanClass="nopan"
		snapGrid={[25, 25]}
		nodesDraggable={!readonly}
		nodesConnectable={!readonly}
		elementsSelectable={true}
		panOnDrag={true}
		zoomOnScroll={true}
	>
		<Background variant={BackgroundVariant.Dots} bgColor="#15131e" gap={50} size={1} />

		{#if showControls}
			<Controls
				showZoom={true}
				showFitView={true}
				showLock={false}
				position="top-right"
				class="!rounded !border !border-gray-600 !bg-gray-800 !shadow-lg [&_button:hover]:!bg-gray-600 [&_button]:!border-gray-600 [&_button]:!bg-gray-700 [&_button]:!text-gray-100"
			/>
		{/if}

		{#if showBranding}
			<a
				href="https://scanopy.net?utm_source={isEmbed
					? 'embed'
					: 'share'}&utm_medium=referral&utm_campaign=created_with"
				target="_blank"
				rel="noopener noreferrer"
				class="branding-badge"
			>
				<img
					src="https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png"
					alt="Scanopy"
					class="h-4 w-4"
				/>
				<span>Created with Scanopy</span>
			</a>
		{/if}
	</SvelteFlow>
</div>

<style>
	:global(.svelte-flow__attribution) {
		background: transparent;
		color: rgba(255, 255, 255, 0.15);
		font-size: 10px;
	}

	:global(.svelte-flow__attribution.right) {
		right: unset;
		left: 10px;
	}

	:global(.svelte-flow__attribution.bottom) {
		bottom: 10px;
	}

	:global(.svelte-flow__attribution a) {
		color: rgba(255, 255, 255, 0.15);
	}

	:global(.svelte-flow__attribution a:hover) {
		color: rgba(255, 255, 255, 0.3);
	}

	.branding-badge {
		position: absolute;
		bottom: 10px;
		right: 10px;
		display: flex;
		align-items: center;
		gap: 6px;
		color: rgba(255, 255, 255, 0.5);
		font-size: 12px;
		text-decoration: none;
		z-index: 5;
		transition: color 0.2s;
	}

	.branding-badge:hover {
		color: rgba(255, 255, 255, 0.8);
	}

	:global(.hide-for-export .svelte-flow__attribution) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__controls) {
		opacity: 0;
	}

	:global(.hide-for-export .svelte-flow__resize-control) {
		opacity: 0;
	}

	:global(.hide-for-export .branding-badge) {
		opacity: 0;
	}
</style>
