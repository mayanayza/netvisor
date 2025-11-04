import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { DiscoveryUpdatePayload } from './types/api';
import { pushError, pushSuccess, pushWarning } from '$lib/shared/stores/feedback';
import { getHosts } from '../hosts/store';
import { getSubnets } from '../subnets/store';
import { getServices } from '../services/store';
import { SSEClient, type SSEClient as SSEClientType } from '$lib/shared/utils/sse';
import { getDaemons } from '../daemons/store';

const STORAGE_KEY = 'netvisor_discovery_sessions';
const SESSION_MAX_AGE_MS = 60 * 1000; // 60 seconds

interface PersistedSession extends DiscoveryUpdatePayload {
	persistedAt: number;
}

// Helper to save sessions to localStorage
function persistSessions(sessionList: DiscoveryUpdatePayload[]) {
	if (typeof window === 'undefined') return;

	try {
		const persisted: PersistedSession[] = sessionList.map((session) => ({
			...session,
			persistedAt: Date.now()
		}));
		localStorage.setItem(STORAGE_KEY, JSON.stringify(persisted));
	} catch (error) {
		console.warn('Failed to persist discovery sessions:', error);
	}
}

// Helper to load sessions from localStorage
function loadPersistedSessions(): DiscoveryUpdatePayload[] {
	if (typeof window === 'undefined') return [];

	try {
		const stored = localStorage.getItem(STORAGE_KEY);
		if (!stored) return [];

		const persisted: PersistedSession[] = JSON.parse(stored);
		const now = Date.now();

		// Filter out stale sessions and terminal states that might have been missed
		const active = persisted.filter((session) => {
			const age = now - session.persistedAt;
			const isStale = age > SESSION_MAX_AGE_MS;
			const isTerminal = ['Complete', 'Cancelled', 'Failed'].includes(session.phase);

			return !isStale && !isTerminal;
		});

		// Return just the payload data without persistedAt
		// eslint-disable-next-line @typescript-eslint/no-unused-vars
		return active.map(({ persistedAt: _, ...payload }) => payload);
	} catch (error) {
		console.warn('Failed to load persisted discovery sessions:', error);
		return [];
	}
}

// session_id to latest update
export const sessions = writable<DiscoveryUpdatePayload[]>(loadPersistedSessions());
export const cancelling = writable<Map<string, boolean>>(new Map());

// Track last known processed per session to detect changes
const lastProcessedCount = new Map<string, number>();

let sseClient: SSEClientType<DiscoveryUpdatePayload> | null = null;

export function startDiscoverySSE() {
	if (sseClient?.isConnected()) {
		return;
	}

	sseClient = new SSEClient<DiscoveryUpdatePayload>({
		url: '/api/discovery/stream',
		onMessage: (update) => {
			sessions.update((current) => {
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

					lastProcessedCount.delete(update.session_id);

					// Remove completed/cancelled/failed sessions
					const updated = current.filter((session) => session.session_id !== update.session_id);
					persistSessions(updated);
					return updated;
				}

				// For non-terminal phases, update or add the session
				const existingIndex = current.findIndex((s) => s.session_id === update.session_id);

				let updated: DiscoveryUpdatePayload[];
				if (existingIndex >= 0) {
					// Update existing session
					updated = [...current];
					updated[existingIndex] = update;
				} else {
					// Add new session
					updated = [...current, update];
				}

				// Persist to localStorage
				persistSessions(updated);
				return updated;
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

		// Clear persisted sessions when explicitly stopping
		if (typeof window !== 'undefined') {
			localStorage.removeItem(STORAGE_KEY);
		}
	}
}

export function cleanupStaleDiscoverySessions() {
	const current = loadPersistedSessions();
	if (current.length === 0) {
		// No active sessions, clear storage
		if (typeof window !== 'undefined') {
			localStorage.removeItem(STORAGE_KEY);
		}
	} else {
		// Re-persist cleaned sessions
		persistSessions(current);
	}
}

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

			let updated: DiscoveryUpdatePayload[];
			if (existingIndex >= 0) {
				// Update existing (shouldn't happen, but defensive)
				updated = [...current];
				updated[existingIndex] = result.data!;
			} else {
				// Add new session
				updated = [...current, result.data!];
			}

			persistSessions(updated);
			return updated;
		});

		startDiscoverySSE(); // Start SSE to receive updates
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
