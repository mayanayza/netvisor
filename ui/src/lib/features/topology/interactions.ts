import { writable, get } from 'svelte/store';
import type { Edge } from '@xyflow/svelte';
import type { Node } from '@xyflow/svelte';
import { edgeTypes, subnetTypes } from '$lib/shared/stores/metadata';
import type { TopologyEdge } from './types/base';
import { getInterfacesOnSubnet, getSubnetFromId } from '../subnets/store';
import { getHostFromInterfaceId } from '../hosts/store';

// Shared stores for hover state across all component instances
export const groupHoverState = writable<Map<string, boolean>>(new Map());
export const edgeHoverState = writable<Map<string, boolean>>(new Map());
export const connectedNodeIds = writable<Set<string>>(new Set());

/**
 * Helper function to get all virtualized container interface IDs for a ServiceVirtualization edge
 * Returns the set of interface IDs for all containers on Docker bridge subnets
 */
function getVirtualizedContainerNodes(dockerHostInterfaceId: string): Set<string> {
	const connected = new Set<string>();

	const dockerHost = get(getHostFromInterfaceId(dockerHostInterfaceId));
	if (dockerHost) {
		const hostInterfaceSubnetIds = dockerHost.interfaces.flatMap((b) => b.subnet_id);
		const dockerBridgeSubnets = hostInterfaceSubnetIds
			.map((s) => get(getSubnetFromId(s)))
			.filter((s) => s !== null)
			.filter((s) => subnetTypes.getMetadata(s.subnet_type).is_for_containers);
		const interfacesOnDockerSubnets = dockerBridgeSubnets.flatMap((s) =>
			get(getInterfacesOnSubnet(s?.id))
		);

		for (const iface of interfacesOnDockerSubnets) {
			connected.add(iface.id);
		}
	}

	return connected;
}

/**
 * Update connected nodes when a node or edge is selected
 */
export function updateConnectedNodes(
	selectedNode: Node | null,
	selectedEdge: Edge | null,
	allEdges: Edge[]
) {
	const connected = new Set<string>();

	// If a node is selected
	if (selectedNode) {
		connected.add(selectedNode.id);

		for (const edge of allEdges) {
			const edgeData = edge.data as TopologyEdge;

			// Add directly connected nodes (regular edges)
			if (edgeData.source === selectedNode.id) {
				connected.add(edgeData.target as string);
			}
			if (edgeData.target === selectedNode.id) {
				connected.add(edgeData.source as string);
			}

			// Include virtualized nodes
			if (edgeData.edge_type === 'ServiceVirtualization') {
				if (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id) {
					connected.add(edgeData.source as string);

					// Add all virtualized container nodes
					const virtualizedNodes = getVirtualizedContainerNodes(edgeData.source as string);
					virtualizedNodes.forEach((nodeId) => connected.add(nodeId));
				}
			} else if (edgeData.edge_type === 'HostVirtualization') {
				if (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id) {
					connected.add(edgeData.source as string);
					connected.add(edgeData.target as string);
				}
			}
		}

		connectedNodeIds.set(connected);
		return;
	}

	// If an edge is selected (group OR non-group)
	if (selectedEdge) {
		const edgeData = selectedEdge.data as TopologyEdge;
		const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

		// For group edges
		if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
			const groupId = edgeData.group_id as string;

			// Find all edges in this group and add their connected nodes
			for (const edge of allEdges) {
				const eData = edge.data as TopologyEdge;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);

				if (eMetadata.is_group_edge && eData.group_id === groupId) {
					connected.add(eData.source as string);
					connected.add(eData.target as string);
				}
			}
		} else if (edgeData.edge_type === 'ServiceVirtualization') {
			// For ServiceVirtualization edges, add source, target, and all virtualized containers
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);

			// Add all virtualized container nodes
			const virtualizedNodes = getVirtualizedContainerNodes(edgeData.source as string);
			virtualizedNodes.forEach((nodeId) => connected.add(nodeId));
		} else if (edgeData.edge_type === 'HostVirtualization') {
			// For HostVirtualization edges, add source and target
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);
		} else {
			// For other non-group edges, just add source and target
			connected.add(edgeData.source as string);
			connected.add(edgeData.target as string);
		}

		connectedNodeIds.set(connected);
		return;
	}

	// Nothing selected - clear
	connectedNodeIds.set(new Set());
}

/**
 * Toggle edge hover state - updates both individual edge and group hover states
 */
export function toggleEdgeHover(edge: Edge, allEdges: Edge[]) {
	const edgeData = edge.data as TopologyEdge;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);

	// Toggle individual edge hover state
	edgeHoverState.update((state) => {
		const currentHoverState = state.get(edge.id) || false;
		const newState = new Map(state);
		newState.set(edge.id, !currentHoverState);
		return newState;
	});

	// For group edges, update group hover state
	if (edgeTypeMetadata.is_group_edge && 'group_id' in edgeData) {
		const groupId = edgeData.group_id as string;

		groupHoverState.update((state) => {
			const newState = new Map(state);

			// Get the UPDATED edge hover states (after we just toggled this edge)
			const updatedEdgeStates = get(edgeHoverState);
			let anyEdgeInGroupHovered = false;

			// Check if ANY edge in this group is hovered
			for (const e of allEdges) {
				const eData = e.data as TopologyEdge;
				const eMetadata = edgeTypes.getMetadata(eData.edge_type);
				if (eMetadata.is_group_edge && 'group_id' in eData && eData.group_id === groupId) {
					const eIsHovered = updatedEdgeStates.get(e.id) || false;
					if (eIsHovered) {
						anyEdgeInGroupHovered = true;
						break;
					}
				}
			}

			newState.set(groupId, anyEdgeInGroupHovered);
			return newState;
		});
	}
}

/**
 * Get display state for an edge based on hover and selection
 * Returns: { shouldShowFull, shouldAnimate }
 */
export function getEdgeDisplayState(
	edge: Edge,
	selectedNode: Node | null,
	selectedEdge: Edge | null
): { shouldShowFull: boolean; shouldAnimate: boolean } {
	const edgeData = edge.data as TopologyEdge;
	const edgeTypeMetadata = edgeTypes.getMetadata(edgeData.edge_type);
	const isGroupEdge = edgeTypeMetadata.is_group_edge;

	let shouldShowFull = false;
	let shouldAnimate = false;

	// Check if this edge is hovered
	const isThisEdgeHovered = get(edgeHoverState).get(edge.id) || false;

	// Check if this edge is selected
	const isThisEdgeSelected = selectedEdge?.id === edge.id;

	// For group edges, check group hover/selection state
	if (isGroupEdge && 'group_id' in edgeData) {
		const groupId = edgeData.group_id as string;
		const isGroupHovered = get(groupHoverState).get(groupId) || false;

		// Check if any edge in this group is selected
		let isGroupSelected = false;
		if (selectedEdge) {
			const selectedEdgeData = selectedEdge.data as TopologyEdge;
			const selectedMetadata = edgeTypes.getMetadata(selectedEdgeData.edge_type);
			if (selectedMetadata.is_group_edge && 'group_id' in selectedEdgeData) {
				isGroupSelected = selectedEdgeData.group_id === groupId;
			}
		}

		// Check if connected node is selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		// Should show full if: group hovered, group selected, or connected node selected
		shouldShowFull = isGroupHovered || isGroupSelected || !!isConnectedNodeSelected;

		// Should animate if: group hovered, group selected, or connected node selected
		shouldAnimate = isGroupHovered || isGroupSelected || !!isConnectedNodeSelected;
	} else {
		// Non-group edges: show full if hovered, selected, or connected node selected
		const isConnectedNodeSelected =
			selectedNode && (edgeData.source === selectedNode.id || edgeData.target === selectedNode.id);

		shouldShowFull = isThisEdgeHovered || isThisEdgeSelected || !!isConnectedNodeSelected;
		shouldAnimate = false; // Non-group edges don't animate
	}

	return { shouldShowFull, shouldAnimate };
}
