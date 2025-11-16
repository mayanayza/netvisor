<script lang="ts">
	import {
		type EdgeProps,
		getSmoothStepPath,
		BaseEdge,
		EdgeLabel,
		getBezierPath,
		getStraightPath,
		type Edge
	} from '@xyflow/svelte';
	import { selectedEdge, selectedNode, topology, topologyOptions } from '../store';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import { groups } from '$lib/features/groups/store';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import type { TopologyEdge } from '../types/base';
	import { getEdgeDisplayState, edgeHoverState, groupHoverState } from '../interactions';

	let {
		id,
		sourceX,
		sourceY,
		sourcePosition,
		targetX,
		targetY,
		targetPosition,
		sourceHandleId,
		targetHandleId,
		label,
		data,
		interactionWidth
	}: EdgeProps = $props();

	const nodes = $derived($topology.nodes);

	const edgeData = data as TopologyEdge;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

	// Get group reactively - updates when groups store changes
	let group = $derived.by(() => {
		if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
			return $groups.find((g) => g.id == edgeData.group_id) || null;
		}
		return null;
	});

	let hideEdge = $derived($topologyOptions.hide_edge_types.includes(edgeData.edge_type));

	// Get display state from helper - Make reactive to hover stores
	let displayState = $derived.by(() => {
		// Subscribe to hover stores to trigger reactivity
		void $edgeHoverState;
		void $groupHoverState;

		// Create a minimal edge object for the helper
		const edge: Edge = {
			id,
			source: edgeData.source as string,
			target: edgeData.target as string,
			data: edgeData
		} as Edge;

		return getEdgeDisplayState(edge, $selectedNode, $selectedEdge);
	});

	let shouldShowFull = $derived(displayState.shouldShowFull);
	let isSelected = $derived($selectedEdge?.id === id);

	// Calculate edge color - use group color if available, otherwise use edge type color
	let edgeColorHelper = $derived.by(() => {
		if (group?.color) {
			return createColorHelper(group.color);
		}
		return edgeTypes.getColorHelper(edgeData.edge_type);
	});

	// Determine if this edge should use the two-color dashed effect
	let isGroupEdge = $derived(edgeTypeMetadata.is_group_edge);
	let useMultiColorDash = $derived(isGroupEdge && shouldShowFull);

	// Calculate base edge properties
	let baseStrokeWidth = $derived(!$topologyOptions.no_fade_edges && shouldShowFull ? 3 : 2);
	let baseOpacity = $derived(!$topologyOptions.no_fade_edges && !shouldShowFull ? 0.2 : 1);

	// Calculate edge style for primary layer (dashed white overlay for group edges, or normal edge)
	let edgeStyle = $derived.by(() => {
		// For group edges with multi-color dash: white dashes
		// For non-group dashed edges: use standard 5 5 pattern with edge color
		let strokeColor = edgeColorHelper.rgb;
		let dashArray = '';

		if (useMultiColorDash && isSelected) {
			// Group edge currently selected
			strokeColor = 'rgba(0, 0, 0, 0.4)';
		} else if (useMultiColorDash && !isSelected) {
			// Other group edges, subtler highlight
			strokeColor = 'rgba(0, 0, 0, 0.15)';
		} else if (!isGroupEdge && edgeTypeMetadata.is_dashed) {
			dashArray = 'stroke-dasharray: 5 5;';
		}

		return `stroke: ${strokeColor}; stroke-width: ${baseStrokeWidth}px; opacity: ${baseOpacity}; ${dashArray} transition: opacity 0.2s ease-in-out, stroke-width 0.2s ease-in-out;`;
	});

	// Calculate edge style for secondary solid layer (only for group edges when shown full)
	let solidBaseStyle = $derived.by(() => {
		if (!useMultiColorDash) return '';
		// Solid base color underneath the white dashes
		return `stroke: ${edgeColorHelper.rgb}; stroke-width: ${baseStrokeWidth}px; opacity: ${baseOpacity}; transition: opacity 0.2s ease-in-out, stroke-width 0.2s ease-in-out;`;
	});

	// Calculate dynamic offset for multi-hop edges
	function calculateDynamicOffset(isMultiHop: boolean): number {
		if (!isMultiHop) {
			return 20; // Default offset for single-hop
		}

		// Determine routing direction from edge handles
		const routingLeft = sourceHandleId == 'Left' || targetHandleId == 'Left';

		// Find the bounding box of the edge path
		const minX = Math.min(sourceX, targetX);
		const maxX = Math.max(sourceX, targetX);
		const minY = Math.min(sourceY, targetY);
		const maxY = Math.max(sourceY, targetY);

		let maxOutcrop = 0;

		// Check all nodes to find intermediate subnets
		for (const node of nodes) {
			// Skip if node is outside the vertical range of the edge
			if (node.position.y <= minY || node.position.y >= maxY) {
				continue;
			}

			// Check if this node is a subnet in the path
			if (node.node_type == 'SubnetNode') {
				const nodeLeft = node.position.x;
				const nodeRight = node.position.x + (node.size.x || 0);

				if (routingLeft) {
					// Check how far left this node extends beyond our leftmost point
					const outcrop = minX - nodeLeft;
					maxOutcrop = Math.max(maxOutcrop, outcrop);
				} else {
					// Check how far right this node extends beyond our rightmost point
					const outcrop = nodeRight - maxX;
					maxOutcrop = Math.max(maxOutcrop, outcrop);
				}
			}
		}

		// Return calculated offset with padding, or minimum offset
		const padding = 50;
		const minimumOffset = 100;
		return Math.max(minimumOffset, maxOutcrop + padding);
	}

	// Helper function to get the path calculation function based on edge style
	function getPathFunction(edge_style: string) {
		const isMultiHop = (edgeData.is_multi_hop as boolean) || false;
		const offset = calculateDynamicOffset(isMultiHop);

		const basePathProperties = {
			sourceX,
			sourceY,
			sourcePosition,
			targetX,
			targetY,
			targetPosition
		};

		switch (edge_style) {
			case 'Straight':
				return getStraightPath(basePathProperties);
			case 'Smoothstep':
			case 'SmoothStep':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
			case 'Bezier':
			case 'SimpleBezier':
				return getBezierPath(basePathProperties);
			case 'Step':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
			default:
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
		}
	}

	// Calculate edge path and label position - DRY approach
	let pathData = $derived.by(() => {
		// Use group edge_style if available, otherwise use edge type metadata
		const edge_style = group ? group.edge_style : edgeTypeMetadata.edge_style;
		return getPathFunction(edge_style);
	});

	let edgePath = $derived(pathData[0]);
	let labelX = $derived(pathData[1]);
	let labelY = $derived(pathData[2]);

	let labelOffsetX = $state(0);
	let labelOffsetY = $state(0);
	let isDragging = $state(false);
	let dragStartX = 0;
	let dragStartY = 0;

	function onDragStart(event: DragEvent) {
		isDragging = true;
		dragStartX = event.clientX - labelOffsetX;
		dragStartY = event.clientY - labelOffsetY;
	}

	function onDrag(event: DragEvent) {
		if (event.clientX === 0 && event.clientY === 0) return; // Ignore end drag event
		labelOffsetX = event.clientX - dragStartX;
		labelOffsetY = event.clientY - dragStartY;
	}

	function onDragEnd() {
		isDragging = false;
	}
</script>

{#if !hideEdge}
	<!-- Solid base layer for group edges when shown full (rendered first, behind) -->
	{#if useMultiColorDash}
		<BaseEdge path={edgePath} style={solidBaseStyle} {id} interactionWidth={0} class="solid-base" />
	{/if}

	<!-- Primary edge layer (white dashes for group edges when shown, normal for everything else) -->
	<BaseEdge
		path={edgePath}
		style={edgeStyle}
		{id}
		interactionWidth={interactionWidth || 20}
		class={useMultiColorDash ? 'dashed-overlay' : ''}
	/>

	{#if label && shouldShowFull}
		<EdgeLabel
			x={labelX + labelOffsetX}
			y={labelY + labelOffsetY}
			style="background: none; pointer-events: none;"
		>
			<div
				class="card text-secondary nopan"
				style="font-size: 12px; font-weight: 500; padding: 0.5rem 0.75rem; border-color: rgb(55 65 81); cursor: {isDragging
					? 'grabbing'
					: 'grab'}; pointer-events: auto;"
				draggable="true"
				role="button"
				tabindex="0"
				ondragstart={onDragStart}
				ondrag={onDrag}
				ondragend={onDragEnd}
			>
				{label}
			</div>
		</EdgeLabel>
	{/if}
{/if}

<style>
	/* Override SvelteFlow's animated behavior ONLY for our solid base layer - keep it solid */
	:global(.svelte-flow__edge.animated .svelte-flow__edge-path.solid-base) {
		stroke-dasharray: 0 !important;
		animation: none !important;
	}

	/* Let the dashed overlay use SvelteFlow's built-in animation */
</style>
