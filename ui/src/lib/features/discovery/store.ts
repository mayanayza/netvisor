import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { DiscoveryUpdatePayload, InitiateDiscoveryRequest } from './types/api';
import { pushError, pushSuccess, pushWarning } from '$lib/shared/stores/feedback';
import { getHosts } from '../hosts/store';
import { getSubnets } from '../subnets/store';
import { getServices } from '../services/store';
import { SSEClient, type SSEClient as SSEClientType } from '$lib/shared/utils/sse';
import { getDaemons } from '../daemons/store';

// session_id to latest update
export const sessions = writable<DiscoveryUpdatePayload[]>([]);
export const cancelling = writable<Map<string, boolean>>(new Map());

// Track last known discovered_count per session to detect changes
const lastDiscoveredCount = new Map<string, number>();

let sseClient: SSEClientType<DiscoveryUpdatePayload> | null = null;

export function startDiscoverySSE() {
	if (sseClient?.isConnected()) {
		return;
	}

	sseClient = new SSEClient<DiscoveryUpdatePayload>({
		url: '/api/discovery/stream',
		onMessage: (update) => {
			sessions.update((current) => {
				console.log(current);
				// Check if discovered_count increased
				const lastCount = lastDiscoveredCount.get(update.session_id) || 0;
				const currentCount = update.discovered_count || 0;

				if (currentCount > lastCount) {
					// New hosts discovered - refresh data
					getHosts();
					getServices();
					getSubnets();
					getDaemons();
					lastDiscoveredCount.set(update.session_id, currentCount);
				}

				// Handle terminal phases
				if (update.phase === 'Complete') {
					pushSuccess(`Discovery completed with ${update.discovered_count} hosts found`);
					// Final refresh on completion
					getHosts();
					getServices();
					getSubnets();
					getDaemons();
				} else if (update.phase === 'Cancelled') {
					pushWarning(`Discovery cancelled`);
				} else if (update.phase === 'Failed' && update.error) {
					pushError(`Discovery error: ${update.error}`, -1);
				}

				// Cleanup for terminal phases
				if (
					update.phase === 'Complete' ||
					update.phase === 'Cancelled' ||
					update.phase === 'Failed'
				) {
					cancelling.update((c) => {
						const m = new Map(c);
						m.delete(update.session_id);
						return m;
					});

					lastDiscoveredCount.delete(update.session_id);

					// Remove completed/cancelled/failed sessions and return
					return current.filter((session) => session.session_id !== update.session_id);
				}

				// For non-terminal phases, update or add the session
				const existingIndex = current.findIndex((s) => s.session_id === update.session_id);

				if (existingIndex >= 0) {
					// Update existing session
					const updated = [...current];
					updated[existingIndex] = update;
					return updated;
				} else {
					// Add new session
					return [...current, update];
				}
			});
		},
		onError: (error) => {
			console.error('Discovery SSE error:', error);
			pushError('Lost connection to discovery updates');
		},
		onOpen: () => {
			console.log('Connected to discovery updates');
		}
	});

	sseClient.connect();
}

export function stopDiscoverySSE() {
	if (sseClient) {
		sseClient.disconnect();
		sseClient = null;
	}
}

export async function initiateDiscovery(data: InitiateDiscoveryRequest) {
	const result = await api.request<DiscoveryUpdatePayload, DiscoveryUpdatePayload[]>(
		'/discovery/initiate',
		sessions,
		(update, currentSessions) => [...currentSessions, update],
		{ method: 'POST', body: JSON.stringify(data) }
	);

	if (result?.success) {
		startDiscoverySSE(); // Start SSE on first discovery
	}
}

export async function cancelDiscovery(id: string) {
	const map = new Map(get(cancelling));
	map.set(id, true);
	cancelling.set(map);

	await api.request<void, void>(`/discovery/${id}/cancel`, null, null, { method: 'POST' });
}
