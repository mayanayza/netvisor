<script lang="ts">
	import { writable } from 'svelte/store';
	import {
		SvelteFlow,
		Controls,
		Background,
		BackgroundVariant,
		type EdgeMarkerType
	} from '@xyflow/svelte';
	import { type Node, type Edge } from '@xyflow/svelte';
	import '@xyflow/svelte/dist/style.css';
	import { optionsPanelExpanded, selectedEdge, selectedNode, topology } from '../store';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import { pushError } from '$lib/shared/stores/feedback';

	// Import custom node/edge components
	import SubnetNode from './SubnetNode.svelte';
	import InterfaceNode from './InterfaceNode.svelte';
	import CustomEdge from './CustomEdge.svelte';
	import { type TopologyEdge } from '../types/base';
	import { onMount } from 'svelte';

	// Define node types
	const nodeTypes = {
		SubnetNode: SubnetNode,
		InterfaceNode: InterfaceNode
	};

	const customEdgeTypes = {
		custom: CustomEdge
	};

	// Stores
	let nodes = writable<Node[]>([]);
	let edges = writable<Edge[]>([]);
	// let selectedNodeId: string | null = null;

	onMount(async () => {
		await loadTopologyData();
	});

	$: if ($topology?.edges || $topology?.nodes) {
		void loadTopologyData();
	}

	async function loadTopologyData() {
		try {
			if ($topology?.nodes && $topology?.edges) {
				// Create nodes FIRST
				const flowNodes: Node[] = $topology.nodes.map((node): Node => {
					return {
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
					};
				});

				// Set nodes first and wait for next tick
				nodes.set(flowNodes);
				await new Promise((resolve) => setTimeout(resolve, 0));

				// Create edges AFTER nodes are set
				const flowEdges: Edge[] = $topology.edges
					.filter(
						([, , edge]: [number, number, TopologyEdge]) => edge.edge_type != 'HostVirtualization'
					)
					.map(([, , edge]: [number, number, TopologyEdge], index: number): Edge => {
						const edgeType = edge.edge_type as string;
						let edgeMetadata = edgeTypes.getMetadata(edgeType);
						let edgeColorHelper = edgeTypes.getColorHelper(edgeType);

						const dashArray = edgeMetadata.is_dashed ? 'stroke-dasharray: 5,5;' : '';
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

						return {
							id: `edge-${index}`,
							source: edge.source,
							target: edge.target,
							markerEnd,
							markerStart,
							sourceHandle: edge.source_handle.toString(),
							targetHandle: edge.target_handle.toString(),
							type: 'custom',
							label: edge.label,
							style: `stroke: ${edgeColorHelper.rgb}; stroke-width: 2px; ${dashArray}`,
							data: edge
						};
					});

				edges.set(flowEdges);
			}
		} catch (err) {
			pushError(`Failed to parse topology data ${err}`);
		}
	}

	function onNodeClick({ node }: { node: Node; event: MouseEvent | TouchEvent }) {
		selectedNode.set(node);
		selectedEdge.set(null);
		optionsPanelExpanded.set(true);
	}

	function onEdgeClick({ edge }: { edge: Edge; event: MouseEvent }) {
		selectedEdge.set(edge);
		selectedNode.set(null);
		optionsPanelExpanded.set(true);
	}
</script>

<div class="h-[calc(100vh-150px)] w-full overflow-hidden rounded-2xl border border-gray-700">
	<SvelteFlow
		nodes={$nodes}
		edges={$edges}
		{nodeTypes}
		edgeTypes={customEdgeTypes}
		onedgeclick={onEdgeClick}
		onnodeclick={onNodeClick}
		fitView
		noPanClass="nopan"
		snapGrid={[25, 25]}
		nodesDraggable={true}
		nodesConnectable={false}
		elementsSelectable={true}
	>
		<Background variant={BackgroundVariant.Dots} bgColor="#15131e" gap={50} size={1} />

		<Controls
			showZoom={true}
			showFitView={true}
			position="top-right"
			class="!rounded !border !border-gray-600 !bg-gray-800 !shadow-lg [&_button:hover]:!bg-gray-600 [&_button]:!border-gray-600 [&_button]:!bg-gray-700 [&_button]:!text-gray-100"
		/>
	</SvelteFlow>
</div>

<style>
	:global(.hide-for-export .svelte-flow__controls),
	:global(.hide-for-export .svelte-flow__resize-control),
	:global(.hide-for-export .svelte-flow__attribution),
	:global(.hide-for-export .svelte-flow__minimap),
	:global(.hide-for-export .topology-options),
	:global(.hide-for-export .svelte-flow__panel) {
		display: none !important;
	}

	:global(.svelte-flow__attribution) {
		background-color: #1f2937 !important; /* gray-800 */
		border: 1px solid #374151 !important; /* gray-700 */
		color: #9ca3af !important; /* gray-400 */
		padding: 4px 8px !important;
		border-radius: 4px !important;
		font-size: 11px !important;
	}

	:global(.svelte-flow__attribution a) {
		color: 'text-primary';
		text-decoration: none !important;
	}
</style>
