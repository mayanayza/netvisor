import type { components } from '$lib/api/schema';
import type { Service } from '$lib/features/services/types/base';
import type { ColorStyle } from '$lib/shared/utils/styling';
import type { IconComponent } from '$lib/shared/utils/types';

// Re-export generated types
export type Topology = components['schemas']['Topology'];
export type TopologyBase = components['schemas']['TopologyBase'];
export type TopologyOptions = components['schemas']['TopologyOptions'];
export type TopologyLocalOptions = components['schemas']['TopologyLocalOptions'];
export type TopologyRequestOptions = components['schemas']['TopologyRequestOptions'];
export type TopologyEdge = components['schemas']['Edge'];
export type TopologyNode = components['schemas']['Node'];
export type EdgeHandle = components['schemas']['EdgeHandle'];

// Variant types from Node union
export type InterfaceNode = Extract<TopologyNode, { node_type: 'InterfaceNode' }>;
export type SubnetNode = Extract<TopologyNode, { node_type: 'SubnetNode' }>;

// Frontend-specific render types (not from backend)
export interface NodeRenderData {
	headerText: string | null;
	footerText: string | null;
	bodyText: string | null;
	showServices: boolean;
	isVirtualized: boolean;
	services: Service[];
	interface_id: string;
}

export interface SubnetRenderData {
	headerText: string;
	cidr: string;
	IconComponent: IconComponent;
	colorHelper: ColorStyle;
}
