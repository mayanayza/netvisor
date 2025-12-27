/**
 * TanStack Query hooks for Tags
 *
 * Replaces the writable store pattern with query-based data fetching.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Tag } from './types/base';

/**
 * Query hook for fetching all tags
 */
export function useTagsQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.tags.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/tags');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch tags');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for creating a tag
 */
export function useCreateTagMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (tag: Tag) => {
			const { data } = await apiClient.POST('/api/tags', { body: tag });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create tag');
			}
			return data.data;
		},
		onSuccess: (newTag: Tag) => {
			queryClient.setQueryData<Tag[]>(queryKeys.tags.all, (old) =>
				old ? [...old, newTag] : [newTag]
			);
		}
	}));
}

/**
 * Mutation hook for updating a tag
 */
export function useUpdateTagMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (tag: Tag) => {
			const { data } = await apiClient.PUT('/api/tags/{id}', {
				params: { path: { id: tag.id } },
				body: tag
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update tag');
			}
			return data.data;
		},
		onSuccess: (updatedTag: Tag) => {
			queryClient.setQueryData<Tag[]>(
				queryKeys.tags.all,
				(old) => old?.map((t) => (t.id === updatedTag.id ? updatedTag : t)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a single tag
 */
export function useDeleteTagMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/tags/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete tag');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Tag[]>(
				queryKeys.tags.all,
				(old) => old?.filter((t) => t.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting tags
 */
export function useBulkDeleteTagsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/tags/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete tags');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Tag[]>(
				queryKeys.tags.all,
				(old) => old?.filter((t) => !ids.includes(t.id)) ?? []
			);
		}
	}));
}
