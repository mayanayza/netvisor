// Re-export generated types from backend
export type {
	HostResponse,
	HostVirtualization,
	ProxmoxVirtualization,
	Interface,
	Port,
	Service,
	TransportProtocol,
	CreateHostRequest,
	CreateInterfaceInput,
	CreatePortInput,
	UpdateHostRequest
} from '$lib/generated';

import type { HostResponse, Service } from '$lib/generated';

// Type alias for backwards compatibility
export type Host = HostResponse;

// Internal type for modal state (host + services editing together)
export interface HostWithServicesRequest {
	host: HostResponse;
	services: Service[] | null;
}

// Frontend-specific types
export interface AllInterfaces {
	id: null;
	name: string;
}

export const ALL_INTERFACES: AllInterfaces = {
	id: null,
	name: 'All Interfaces'
};
