/**
 * TanStack Query hooks for Shares
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Share, CreateUpdateShareRequest } from './types/base';

/**
 * Query hook for fetching all shares
 */
export function useSharesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.shares.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/shares');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch shares');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for creating a share
 */
export function useCreateShareMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (request: CreateUpdateShareRequest) => {
			const { data } = await apiClient.POST('/api/shares', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create share');
			}
			return data.data;
		},
		onSuccess: (newShare: Share) => {
			queryClient.setQueryData<Share[]>(queryKeys.shares.all, (old) =>
				old ? [...old, newShare] : [newShare]
			);
		}
	}));
}

/**
 * Mutation hook for updating a share
 */
export function useUpdateShareMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async ({ id, request }: { id: string; request: CreateUpdateShareRequest }) => {
			const { data } = await apiClient.PUT('/api/shares/{id}', {
				params: { path: { id } },
				body: request
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update share');
			}
			return data.data;
		},
		onSuccess: (updatedShare: Share) => {
			queryClient.setQueryData<Share[]>(
				queryKeys.shares.all,
				(old) => old?.map((s) => (s.id === updatedShare.id ? updatedShare : s)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a share
 */
export function useDeleteShareMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/shares/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete share');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Share[]>(
				queryKeys.shares.all,
				(old) => old?.filter((s) => s.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting shares
 */
export function useBulkDeleteSharesMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/shares/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete shares');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Share[]>(
				queryKeys.shares.all,
				(old) => old?.filter((s) => !ids.includes(s.id)) ?? []
			);
		}
	}));
}
