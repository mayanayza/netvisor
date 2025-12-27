/**
 * TanStack Query helpers for openapi-fetch integration
 *
 * Provides type-safe wrappers for creating query and mutation functions
 * that work with our API response format: { success: boolean, data: T, error: string }
 */

import type { ApiResponse } from './client';

/**
 * Wraps an openapi-fetch call into a query function that throws on error
 *
 * @example
 * const queryFn = createApiQueryFn(async () => {
 *   return apiClient.GET('/api/tags');
 * });
 */
export function createApiQueryFn<T>(
	fetcher: () => Promise<{ data?: ApiResponse<T> }>
): () => Promise<T> {
	return async () => {
		const { data } = await fetcher();
		if (!data?.success || data.data === null || data.data === undefined) {
			throw new Error(data?.error || 'API request failed');
		}
		return data.data;
	};
}

/**
 * Wraps an openapi-fetch call into a mutation function that throws on error
 *
 * @example
 * const mutationFn = createApiMutationFn(async (tag: Tag) => {
 *   return apiClient.POST('/api/tags', { body: tag });
 * });
 */
export function createApiMutationFn<TInput, TOutput>(
	fetcher: (input: TInput) => Promise<{ data?: ApiResponse<TOutput> }>
): (input: TInput) => Promise<TOutput> {
	return async (input: TInput) => {
		const { data } = await fetcher(input);
		if (!data?.success || data.data === null || data.data === undefined) {
			throw new Error(data?.error || 'API request failed');
		}
		return data.data;
	};
}

/**
 * Wraps an openapi-fetch delete call that returns no data
 *
 * @example
 * const mutationFn = createApiDeleteFn(async (id: string) => {
 *   return apiClient.DELETE('/api/tags/{id}', { params: { path: { id } } });
 * });
 */
export function createApiDeleteFn<TInput>(
	fetcher: (input: TInput) => Promise<{ data?: { success: boolean; error?: string | null } }>
): (input: TInput) => Promise<void> {
	return async (input: TInput) => {
		const { data } = await fetcher(input);
		if (!data?.success) {
			throw new Error(data?.error || 'Delete request failed');
		}
	};
}
