<script lang="ts">
	import { writable, get } from 'svelte/store';
	import {
		SvelteFlow,
		Controls,
		Background,
		BackgroundVariant,
		type EdgeMarkerType,
		useNodesInitialized
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
	import { updateConnectedNodes, toggleEdgeHover, getEdgeDisplayState } from '../interactions';

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

	// Hook to check when nodes are initialized
	const nodesInitialized = useNodesInitialized();

	// Store pending edges until nodes are ready
	let pendingEdges: Edge[] = [];

	onMount(async () => {
		await loadTopologyData();
	});

	$effect(() => {
		if ($topology?.edges || $topology?.nodes) {
			void loadTopologyData();
		}
	});

	// Update edges when selection changes
	$effect(() => {
		void $selectedNode;
		void $selectedEdge;

		if ($topology?.edges) {
			const currentEdges = get(edges);
			updateConnectedNodes($selectedNode, $selectedEdge, currentEdges);

			// Update edge animated state based on selection
			const updatedEdges = currentEdges.map((edge) => {
				const { shouldAnimate } = getEdgeDisplayState(edge, $selectedNode, $selectedEdge);

				return {
					...edge,
					id: edge.id, // Force new reference
					animated: shouldAnimate
				};
			});

			edges.set(updatedEdges);
		}
	});

	// Effect to add edges when nodes are ready
	$effect(() => {
		if (nodesInitialized.current && pendingEdges.length > 0) {
			edges.set(pendingEdges);
			pendingEdges = [];
		}
	});

	async function loadTopologyData() {
		try {
			if ($topology?.nodes && $topology?.edges) {
				// Create nodes FIRST
				const allNodes: Node[] = $topology.nodes.map((node): Node => {
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
				const flowEdges: Edge[] = $topology.edges
					.filter(
						([, , edge]: [number, number, TopologyEdge]) => edge.edge_type != 'HostVirtualization'
					)
					.map(([, , edge]: [number, number, TopologyEdge], index: number): Edge => {
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
							data: { ...edge, edgeIndex: index },
							animated: false,
							interactionWidth: 50
						};
					});

				pendingEdges = flowEdges;
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

	function onPaneClick() {
		selectedNode.set(null);
		selectedEdge.set(null);
	}

	function hoveredEdge({ edge }: { edge: Edge }) {
		const currentEdges = get(edges);
		toggleEdgeHover(edge, currentEdges);

		// Update animated state for all edges after hover toggle
		const updatedEdges = currentEdges.map((e) => {
			const { shouldAnimate } = getEdgeDisplayState(e, $selectedNode, $selectedEdge);

			return {
				...e,
				id: e.id,
				animated: shouldAnimate
			};
		});

		edges.set(updatedEdges);
	}
</script>

<div class="h-[calc(100vh-150px)] w-full overflow-hidden rounded-2xl border border-gray-700">
	<SvelteFlow
		nodes={$nodes}
		edges={$edges}
		{nodeTypes}
		edgeTypes={customEdgeTypes}
		onpaneclick={onPaneClick}
		onedgeclick={onEdgeClick}
		onnodeclick={onNodeClick}
		onedgepointerenter={hoveredEdge}
		onedgepointerleave={hoveredEdge}
		fitView
		minZoom={0.1}
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
