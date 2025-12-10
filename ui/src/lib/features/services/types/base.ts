import type { EntitySource } from '$lib/shared/types';

export type ServiceVirtualization = { type: 'Docker'; details: DockerVirtualization };

export interface Service {
	id: string;
	created_at: string;
	updated_at: string;
	host_id: string;
	service_definition: string;
	is_gateway: boolean;
	name: string;
	bindings: Binding[];
	virtualization: ServiceVirtualization | null;
	source: EntitySource;
	network_id: string;
	tags: string[];
}

export type ServiceWithVMs = Omit<Service, 'vms'> & {
	vms: string[];
};

export interface DockerVirtualization {
	container_id: string | null;
	container_name: string | null;
	service_id: string;
}

export type Binding =
	| { type: 'Interface'; id: string; interface_id: string }
	| { type: 'Port'; id: string; interface_id: string | null; port_id: string };

export type PortBinding = Extract<Binding, { type: 'Port' }>;
export type InterfaceBinding = Extract<Binding, { type: 'Interface' }>;
