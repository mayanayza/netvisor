import { derived, writable, type Readable } from 'svelte/store';
import type { Interface } from '$lib/features/hosts/types/base';

// Store for interface primitives
export const interfaces = writable<Interface[]>([]);

/**
 * Sync interfaces from HostResponse data.
 * Called when APIs return hosts with embedded interfaces.
 */
export function syncInterfaces(newInterfaces: Interface[]) {
	interfaces.update((current) => {
		const newIds = new Set(newInterfaces.map((i) => i.id));
		// Keep interfaces not in the new batch, add all new interfaces
		const kept = current.filter((i) => !newIds.has(i.id));
		return [...kept, ...newInterfaces];
	});
}

/**
 * Replace all interfaces for a specific host.
 * Used when updating a single host's interfaces.
 */
export function syncInterfacesForHost(hostId: string, hostInterfaces: Interface[]) {
	interfaces.update((current) => {
		// Remove all interfaces for this host, add the new ones
		const other = current.filter((i) => i.host_id !== hostId);
		return [...other, ...hostInterfaces];
	});
}

/**
 * Remove all interfaces for a host (used when host is deleted).
 */
export function removeInterfacesForHost(hostId: string) {
	interfaces.update((current) => current.filter((i) => i.host_id !== hostId));
}

// Derived lookups

export function getInterfaceFromId(id: string): Readable<Interface | null> {
	return derived([interfaces], ([$interfaces]) => {
		return $interfaces.find((i) => i.id === id) || null;
	});
}

export function getInterfacesForHost(hostId: string): Readable<Interface[]> {
	return derived([interfaces], ([$interfaces]) => {
		return $interfaces.filter((i) => i.host_id === hostId);
	});
}

export function getInterfacesForSubnet(subnetId: string): Readable<Interface[]> {
	return derived([interfaces], ([$interfaces]) => {
		return $interfaces.filter((i) => i.subnet_id === subnetId);
	});
}
