/**
 * TanStack Query hooks for API Keys
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { ApiKey } from './types/base';

/**
 * Query hook for fetching all API keys
 */
export function useApiKeysQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.apiKeys.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/auth/keys');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch API keys');
			}
			return data.data;
		}
	}));
}

/**
 * Response type from create API key endpoint
 */
interface CreateApiKeyResponse {
	key: string;
	api_key: ApiKey;
}

/**
 * Mutation hook for creating an API key
 * Returns the key string (only shown once) and the created API key
 */
export function useCreateApiKeyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (apiKey: ApiKey) => {
			const { data } = await apiClient.POST('/api/auth/keys', { body: apiKey });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create API key');
			}
			// Response contains both the key string and the created api_key object
			const response = data.data as CreateApiKeyResponse;
			return { keyString: response.key, apiKey: response.api_key };
		},
		onSuccess: ({ apiKey }) => {
			queryClient.setQueryData<ApiKey[]>(queryKeys.apiKeys.all, (old) =>
				old ? [...old, apiKey] : [apiKey]
			);
		}
	}));
}

/**
 * Mutation hook for updating an API key
 */
export function useUpdateApiKeyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (apiKey: ApiKey) => {
			const { data } = await apiClient.PUT('/api/auth/keys/{id}', {
				params: { path: { id: apiKey.id } },
				body: apiKey
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update API key');
			}
			return data.data;
		},
		onSuccess: (updatedKey: ApiKey) => {
			queryClient.setQueryData<ApiKey[]>(
				queryKeys.apiKeys.all,
				(old) => old?.map((k) => (k.id === updatedKey.id ? updatedKey : k)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting an API key
 */
export function useDeleteApiKeyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/auth/keys/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete API key');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<ApiKey[]>(
				queryKeys.apiKeys.all,
				(old) => old?.filter((k) => k.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting API keys
 */
export function useBulkDeleteApiKeysMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/auth/keys/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete API keys');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<ApiKey[]>(
				queryKeys.apiKeys.all,
				(old) => old?.filter((k) => !ids.includes(k.id)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for rotating an API key
 */
export function useRotateApiKeyMutation() {
	return createMutation(() => ({
		mutationFn: async (keyId: string) => {
			const { data } = await apiClient.POST('/api/auth/keys/{id}/rotate', {
				params: { path: { id: keyId } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to rotate API key');
			}
			// Returns the new key string
			return data.data as string;
		}
	}));
}
