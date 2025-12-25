import { derived, writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { Daemon } from './types/base';
import type { DiscoveryUpdatePayload } from '../discovery/types/api';

export const daemons = writable<Daemon[]>([]);

export async function getDaemons() {
	const { data } = await apiClient.GET('/api/daemons');
	if (data?.success && data.data) {
		daemons.set(data.data);
	}
	return data as ApiResponse<Daemon[]>;
}

export async function deleteDaemon(id: string) {
	const { data: result } = await apiClient.DELETE('/api/daemons/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		daemons.update((current) => current.filter((d) => d.id !== id));
	}
	return result;
}

export async function bulkDeleteDaemons(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/daemons/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		daemons.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export function getDaemonIsRunningDiscovery(
	daemon_id: string | null,
	sessions: DiscoveryUpdatePayload[]
): boolean {
	if (!daemon_id) return false;

	// Find any active session for this daemon
	for (const session of sessions) {
		if (
			session.daemon_id === daemon_id &&
			(session.phase === 'Pending' ||
				session.phase === 'Starting' ||
				session.phase === 'Started' ||
				session.phase === 'Scanning')
		) {
			return true;
		}
	}
	return false;
}

export function getDaemonDiscoveryData(
	daemonId: string,
	sessions: Map<string, DiscoveryUpdatePayload>
): DiscoveryUpdatePayload | null {
	// Find the active session for this daemon
	for (const session of sessions.values()) {
		if (
			session.daemon_id === daemonId &&
			(session.phase === 'Pending' ||
				session.phase === 'Starting' ||
				session.phase === 'Started' ||
				session.phase === 'Scanning')
		) {
			return session;
		}
	}
	return null;
}

export const hostDaemonMap = derived(daemons, ($daemons) => {
	const map = new Map<string, Daemon>();
	$daemons.forEach((daemon) => {
		map.set(daemon.host_id, daemon);
	});
	return map;
});
