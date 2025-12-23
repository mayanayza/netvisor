// Re-export generated types from backend
export type {
	Service,
	ServiceVirtualization,
	DockerVirtualization,
	Binding
} from '$lib/generated';

import type { Binding } from '$lib/generated';

// Utility types for binding discrimination
export type PortBinding = Binding & { type: 'Port' };
export type InterfaceBinding = Binding & { type: 'Interface' };
