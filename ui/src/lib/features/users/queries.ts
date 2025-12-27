/**
 * TanStack Query hooks for Users
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { User } from './types';

/**
 * Query hook for fetching all users
 */
export function useUsersQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.users.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/users');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch users');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for updating a user as admin
 */
export function useUpdateUserAsAdminMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (user: User) => {
			const { data } = await apiClient.PUT('/api/users/{id}/admin', {
				params: { path: { id: user.id } },
				body: user
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update user');
			}
			return data.data;
		},
		onSuccess: (updatedUser: User) => {
			queryClient.setQueryData<User[]>(
				queryKeys.users.all,
				(old) => old?.map((u) => (u.id === updatedUser.id ? updatedUser : u)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a user
 */
export function useDeleteUserMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/users/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete user');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<User[]>(
				queryKeys.users.all,
				(old) => old?.filter((u) => u.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting users
 */
export function useBulkDeleteUsersMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/users/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete users');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<User[]>(
				queryKeys.users.all,
				(old) => old?.filter((u) => !ids.includes(u.id)) ?? []
			);
		}
	}));
}
