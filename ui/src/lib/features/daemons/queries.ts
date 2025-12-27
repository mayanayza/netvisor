/**
 * TanStack Query hooks for Daemons
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Daemon } from './types/base';
import type { DiscoveryUpdatePayload } from '../discovery/types/api';

/**
 * Query hook for fetching all daemons
 */
export function useDaemonsQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.daemons.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/daemons');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch daemons');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for deleting a daemon
 */
export function useDeleteDaemonMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/daemons/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete daemon');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Daemon[]>(
				queryKeys.daemons.all,
				(old) => old?.filter((d) => d.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting daemons
 */
export function useBulkDeleteDaemonsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/daemons/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete daemons');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Daemon[]>(
				queryKeys.daemons.all,
				(old) => old?.filter((d) => !ids.includes(d.id)) ?? []
			);
		}
	}));
}

/**
 * Helper to check if a daemon is currently running a discovery session
 */
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
