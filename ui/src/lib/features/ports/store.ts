import { derived, writable, type Readable } from 'svelte/store';
import type { Port } from '$lib/features/hosts/types/base';

// Store for port primitives
export const ports = writable<Port[]>([]);

/**
 * Sync ports from HostResponse data.
 * Called when APIs return hosts with embedded ports.
 */
export function syncPorts(newPorts: Port[]) {
	ports.update((current) => {
		const newIds = new Set(newPorts.map((p) => p.id));
		// Keep ports not in the new batch, add all new ports
		const kept = current.filter((p) => !newIds.has(p.id));
		return [...kept, ...newPorts];
	});
}

/**
 * Replace all ports for a specific host.
 * Used when updating a single host's ports.
 */
export function syncPortsForHost(hostId: string, hostPorts: Port[]) {
	ports.update((current) => {
		// Remove all ports for this host, add the new ones
		const other = current.filter((p) => p.host_id !== hostId);
		return [...other, ...hostPorts];
	});
}

/**
 * Remove all ports for a host (used when host is deleted).
 */
export function removePortsForHost(hostId: string) {
	ports.update((current) => current.filter((p) => p.host_id !== hostId));
}

// Derived lookups

export function getPortFromId(id: string): Readable<Port | null> {
	return derived([ports], ([$ports]) => {
		return $ports.find((p) => p.id === id) || null;
	});
}

export function getPortsForHost(hostId: string): Readable<Port[]> {
	return derived([ports], ([$ports]) => {
		return $ports.filter((p) => p.host_id === hostId);
	});
}
