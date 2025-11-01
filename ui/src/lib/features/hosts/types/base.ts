import type { Service } from '$lib/features/services/types/base';
import type { EntitySource } from '$lib/shared/types';

export interface HostWithServicesRequest {
	host: Host;
	services: Service[] | null;
}

export type HostVirtualization = { type: 'Proxmox'; details: ProxmoxVirtualization };

export interface Host {
	id: string;
	created_at: string;
	updated_at: string;
	name: string;
	description: string;
	hostname: string;
	target: HostTarget;
	services: string[];
	ports: Port[];
	interfaces: Interface[];
	virtualization: HostVirtualization | null;
	source: EntitySource;
	network_id: string;
	hidden: boolean;
}

export interface ProxmoxVirtualization {
	vm_id: string | null;
	vm_name: string | null;
	service_id: string;
}

export interface AllInterfaces {
	id: null;
	name: string;
}

export const ALL_INTERFACES: AllInterfaces = {
	id: null,
	name: 'All Interfaces'
};

export interface Interface {
	id: string;
	subnet_id: string;
	name: string;
	ip_address?: string;
	mac_address?: string;
}

export type HostTarget =
	// Binding ID
	{ type: 'ServiceBinding'; config: string } | { type: 'None' } | { type: 'Hostname' };

// For backwards compatibility during transition
export interface IpTargetConfig {
	ip: string;
}

export interface HostnameTargetConfig {
	hostname: string;
}

export interface Port {
	number: number;
	protocol: 'Tcp' | 'Udp';
	id: string;
	type: string;
}
