import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { DiscoveryUpdatePayload } from './types/api';
import { pushError, pushSuccess, pushWarning } from '$lib/shared/stores/feedback';
import { getHosts } from '../hosts/store';
import { getSubnets } from '../subnets/store';
import { getServices } from '../services/store';
import { BaseSSEManager, type SSEConfig } from '$lib/shared/utils/sse';
import { getDaemons } from '../daemons/store';
import { getDiscoveries } from './store';

// session_id to latest update
export const sessions = writable<DiscoveryUpdatePayload[]>([]);
export const cancelling = writable<Map<string, boolean>>(new Map());

export async function getActiveSessions() {
	return await api.request<DiscoveryUpdatePayload[]>(
		`/discovery/active-sessions`,
		sessions,
		(sessions) => sessions,
		{
			method: 'GET'
		}
	);
}

// Track last known processed per session to detect changes
const lastProcessedCount = new Map<string, number>();

class DiscoverySSEManager extends BaseSSEManager<DiscoveryUpdatePayload> {
	protected createConfig(): SSEConfig<DiscoveryUpdatePayload> {
		return {
			url: '/api/discovery/stream',
			onMessage: async (update) => {
				// Check if discovered_count increased
				const lastCount = lastProcessedCount.get(update.session_id) || 0;
				const currentCount = update.processed || 0;

				if (currentCount > lastCount) {
					// Refresh data
					getHosts();
					getServices();
					getSubnets();
					getDaemons();
					lastProcessedCount.set(update.session_id, currentCount);
				}

				// Handle terminal phases
				if (update.phase === 'Complete') {
					pushSuccess(`${update.discovery_type.type} discovery completed`);
					// Final refresh on completion
					await Promise.all([
						getHosts(),
						getServices(),
						getSubnets(),
						getDaemons(),
						getDiscoveries()
					]);
				} else if (update.phase === 'Cancelled') {
					pushWarning(`Discovery cancelled`);
				} else if (update.phase === 'Failed' && update.error) {
					pushError(`Discovery error: ${update.error}`, -1);
				}

				// Update sessions store
				sessions.update((current) => {
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

						lastProcessedCount.delete(update.session_id);

						// Remove completed/cancelled/failed sessions
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
		};
	}
}

export const discoverySSEManager = new DiscoverySSEManager();

export async function initiateDiscovery(discovery_id: string) {
	const result = await api.request<DiscoveryUpdatePayload, DiscoveryUpdatePayload[]>(
		'/discovery/start-session',
		null,
		null,
		{ method: 'POST', body: JSON.stringify(discovery_id) }
	);

	if (result?.success && result.data) {
		// Add the session immediately to the store (only if it doesn't exist)
		sessions.update((current) => {
			// Check if session already exists
			const existingIndex = current.findIndex((s) => s.session_id === result.data!.session_id);

			if (existingIndex >= 0) {
				// Update existing (shouldn't happen, but defensive)
				const updated = [...current];
				updated[existingIndex] = result.data!;
				return updated;
			} else {
				// Add new session
				return [...current, result.data!];
			}
		});

		discoverySSEManager.connect(); // Start SSE to receive updates
		pushSuccess(
			`${result.data.discovery_type.type} discovery session created with session ID ${result.data.session_id}`
		);
	}
}

export async function cancelDiscovery(id: string) {
	const map = new Map(get(cancelling));
	map.set(id, true);
	cancelling.set(map);

	const result = await api.request<void, void>(`/discovery/${id}/cancel`, null, null, {
		method: 'POST'
	});

	if (!result?.success) {
		// If cancellation failed, remove the cancelling state
		cancelling.update((c) => {
			const m = new Map(c);
			m.delete(id);
			return m;
		});
		pushError('Failed to cancel discovery');
	}
	// If successful, the SSE will receive the "Cancelled" phase and handle cleanup
}
