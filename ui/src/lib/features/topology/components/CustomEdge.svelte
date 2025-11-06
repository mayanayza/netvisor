<script lang="ts">
	import {
		type EdgeProps,
		getSmoothStepPath,
		BaseEdge,
		EdgeLabel,
		getBezierPath,
		getStraightPath
	} from '@xyflow/svelte';
	import { topology, topologyOptions } from '../store';
	import type { TopologyEdge } from '../types/base';
	import { edgeTypes } from '$lib/shared/stores/metadata';

	let {
		id,
		sourceX,
		sourceY,
		sourcePosition,
		targetX,
		targetY,
		targetPosition,
		markerEnd,
		markerStart,
		sourceHandleId,
		targetHandleId,
		style,
		label,
		data
	}: EdgeProps = $props();

	const nodes = $derived($topology.nodes);

	const edgeData = data as TopologyEdge;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

	let hideEdge = $derived($topologyOptions.hide_edge_types.includes(edgeData.edge_type));

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

	let [edgePath, labelX, labelY] = $derived.by(() => {
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

		switch (edgeTypeMetadata.edge_style) {
			case 'straight':
				return getStraightPath(basePathProperties);
			case 'smoothstep':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
			case 'bezier':
				return getBezierPath(basePathProperties);
			case 'simplebezier':
				return getBezierPath(basePathProperties);
			case 'step':
				return getSmoothStepPath({
					...basePathProperties,
					borderRadius: 10,
					offset
				});
		}
	});

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
	<BaseEdge path={edgePath} {markerEnd} {markerStart} {style} {id} />

	{#if label}
		<EdgeLabel x={labelX + labelOffsetX} y={labelY + labelOffsetY} style="background: none;">
			<div
				class="card text-secondary nopan"
				style="font-size: 12px; font-weight: 500; padding: 0.5rem 0.75rem; border-color: rgb(55 65 81); cursor: {isDragging
					? 'grabbing'
					: 'grab'};"
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
