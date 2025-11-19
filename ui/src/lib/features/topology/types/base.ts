import type { Group } from '$lib/features/groups/types/base';
import type { Host } from '$lib/features/hosts/types/base';
import type { Service } from '$lib/features/services/types/base';
import type { Subnet } from '$lib/features/subnets/types/base';
import type { ColorStyle } from '$lib/shared/utils/styling';
import type { IconComponent } from '$lib/shared/utils/types';

export interface Topology {
	edges: TopologyEdge[];
	nodes: Node[];
	options: TopologyOptions;
	name: string;
	id: string;
	created_at: string;
	updated_at: string;
	network_id: string;
	hosts: Host[];
	subnets: Subnet[];
	groups: Group[];
	services: Service[];
	is_stale: boolean;
	last_refreshed: string;
	is_locked: boolean;
	locked_at: string | null;
	locked_by: string | null;
	removed_hosts: string[];
	removed_services: string[];
	removed_subnets: string[];
	removed_groups: string[];
	parent_id: string | null;
}

export interface NodeBase {
	id: string;
	node_type: string;
	position: { x: number; y: number };
	size: { x: number; y: number };
	header: string | null;
}

type NodeType = InterfaceNode | SubnetNode;

export interface InterfaceNode extends Record<string, unknown> {
	node_type: 'InterfaceNode';
	subnet_id: string;
	host_id: string;
	interface_id: string;
	is_infra: boolean;
}

export interface SubnetNode extends Record<string, unknown> {
	node_type: 'SubnetNode';
	infra_width: number;
}

type Node = NodeBase & NodeType & Record<string, unknown>;

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

interface EdgeBase extends Record<string, unknown> {
	source: string;
	label: string;
	target: string;
	source_handle: EdgeHandle;
	target_handle: EdgeHandle;
	is_multi_hop: boolean;
}

export type TopologyEdge =
	| (EdgeBase & RequestPathEdge)
	| (EdgeBase & HubAndSpokeEdge)
	| (EdgeBase & InterfaceEdge)
	| (EdgeBase & ServiceVirtualizationEdge)
	| (EdgeBase & HostVirtualizationEdge);

export interface RequestPathEdge {
	edge_type: 'RequestPath';
	group_id: string;
	source_binding_id: string;
	target_binding_id: string;
}

export interface HubAndSpokeEdge {
	edge_type: 'HubAndSpoke';
	group_id: string;
	source_binding_id: string;
	target_binding_id: string;
}

export interface InterfaceEdge {
	edge_type: 'Interface';
	host_id: string;
}

export interface ServiceVirtualizationEdge {
	edge_type: 'ServiceVirtualization';
	containerizing_service_id: string;
	host_id: string;
}

export interface HostVirtualizationEdge {
	edge_type: 'HostVirtualization';
	vm_service_id: string;
}

export enum EdgeHandle {
	Top = 'Top',
	Right = 'Right',
	Bottom = 'Bottom',
	Left = 'Left'
}

export interface TopologyOptions {
	local: TopologyLocalOptions;
	request: TopologyRequestOptions;
}

export interface TopologyLocalOptions {
	left_zone_title: string;
	no_fade_edges: boolean;
	hide_resize_handles: boolean;
	hide_edge_types: string[];
}

export interface TopologyRequestOptions {
	group_docker_bridges_by_host: boolean;
	hide_vm_title_on_docker_container: boolean;
	hide_ports: boolean;
	show_gateway_in_left_zone: boolean;
	left_zone_service_categories: string[];
	hide_service_categories: string[];
}
