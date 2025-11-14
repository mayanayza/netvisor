import type { EntitySource } from '$lib/shared/types';

export type GroupType = 'RequestPath';

export type Group = RequestPathGroup | HubAndSpokeGroup;

interface BaseGroup {
	id: string;
	created_at: string;
	updated_at: string;
	name: string;
	description: string;
	source: EntitySource;
	network_id: string;
	color: string;
	edge_style: 'Straight' | 'SmoothStep' | 'Step' | 'Bezier' | 'SimpleBezier';
}

export interface RequestPathGroup extends BaseGroup {
	group_type: 'RequestPath';
	service_bindings: string[]; // Binding IDs
}

export interface HubAndSpokeGroup extends BaseGroup {
	group_type: 'HubAndSpoke';
	service_bindings: string[]; // Binding IDs
}
