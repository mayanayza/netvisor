/**
 * TanStack Query hooks for Interfaces
 *
 * Interfaces are child entities populated by the hosts query.
 * This file provides read-only access to the interfaces cache.
 */

import { createQuery, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import type { Interface } from '$lib/features/hosts/types/base';

// Re-export type for convenience
export type { Interface };

/**
 * Query hook for accessing the interfaces cache
 * This cache is populated by useHostsQuery - it does not fetch directly
 */
export function useInterfacesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.interfaces.all,
		queryFn: async () => {
			// Interfaces are populated by hosts query, return empty if not yet populated
			return [] as Interface[];
		},
		// Don't refetch - data comes from hosts query
		staleTime: Infinity,
		refetchOnMount: false,
		refetchOnWindowFocus: false
	}));
}

/**
 * Get interfaces for a specific host from the cache
 */
export function getInterfacesForHostFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	hostId: string
): Interface[] {
	const interfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
	return interfaces.filter((i) => i.host_id === hostId);
}

/**
 * Get interfaces for a specific subnet from the cache
 */
export function getInterfacesForSubnetFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	subnetId: string
): Interface[] {
	const interfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
	return interfaces.filter((i) => i.subnet_id === subnetId);
}

/**
 * Get a single interface by ID from the cache
 */
export function getInterfaceByIdFromCache(
	queryClient: ReturnType<typeof useQueryClient>,
	id: string
): Interface | null {
	const interfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
	return interfaces.find((i) => i.id === id) ?? null;
}
