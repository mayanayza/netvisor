/**
 * TanStack Query hooks for Discovery
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Discovery } from './types/base';

/**
 * Query hook for fetching all discoveries
 */
export function useDiscoveriesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.discovery.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/discovery');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch discoveries');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for creating a discovery
 */
export function useCreateDiscoveryMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (discovery: Discovery) => {
			const { data } = await apiClient.POST('/api/discovery', { body: discovery });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create discovery');
			}
			return data.data;
		},
		onSuccess: (newDiscovery: Discovery) => {
			queryClient.setQueryData<Discovery[]>(queryKeys.discovery.all, (old) =>
				old ? [...old, newDiscovery] : [newDiscovery]
			);
		}
	}));
}

/**
 * Mutation hook for updating a discovery
 */
export function useUpdateDiscoveryMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (discovery: Discovery) => {
			const { data } = await apiClient.PUT('/api/discovery/{id}', {
				params: { path: { id: discovery.id } },
				body: discovery
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update discovery');
			}
			return data.data;
		},
		onSuccess: (updatedDiscovery: Discovery) => {
			queryClient.setQueryData<Discovery[]>(
				queryKeys.discovery.all,
				(old) => old?.map((d) => (d.id === updatedDiscovery.id ? updatedDiscovery : d)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a discovery
 */
export function useDeleteDiscoveryMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/discovery/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete discovery');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Discovery[]>(
				queryKeys.discovery.all,
				(old) => old?.filter((d) => d.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting discoveries
 */
export function useBulkDeleteDiscoveriesMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/discovery/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete discoveries');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Discovery[]>(
				queryKeys.discovery.all,
				(old) => old?.filter((d) => !ids.includes(d.id)) ?? []
			);
		}
	}));
}
