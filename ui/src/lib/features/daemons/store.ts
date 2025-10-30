import { derived, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { Daemon, GenerateApiRequest } from './types/base';
import type { DiscoveryUpdatePayload } from '../discovery/types/api';

export const daemons = writable<Daemon[]>([]);

export async function getDaemons() {
	return await api.request<Daemon[]>(`/daemons`, daemons, (daemons) => daemons, { method: 'GET' });
}

export async function generateApiKey(data: GenerateApiRequest) {
	const response = await api.request<string, void>(
		`/daemons/generate_api_key`,
		null,
		(daemons) => daemons,
		{ method: 'POST', body: JSON.stringify(data) }
	);

	if (response && response?.success && response.data) {
		return response.data;
	}
}

export async function deleteDaemon(id: string) {
	return await api.request<void, Daemon[]>(
		`/daemons/${id}`,
		daemons,
		(_, current) => current.filter((d) => d.id !== id),
		{ method: 'DELETE' }
	);
}

export function getDaemonIsRunningDiscovery(
	daemon_id: string | null,
	sessionsMap: Map<string, DiscoveryUpdatePayload>
): boolean {
	if (!daemon_id) return false;

	// Find any active session for this daemon
	for (const session of sessionsMap.values()) {
		if (
			session.daemon_id === daemon_id &&
			(session.phase === 'Initiated' || session.phase === 'Started' || session.phase === 'Scanning')
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
			(session.phase === 'Initiated' || session.phase === 'Started' || session.phase === 'Scanning')
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
