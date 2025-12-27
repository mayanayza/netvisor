/**
 * TanStack Query hooks for Services
 *
 * Services are populated by the hosts query but also have direct CRUD operations.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Service } from './types/base';

// Re-export type for convenience
export type { Service };

/**
 * Query hook for accessing the services cache
 * This cache is primarily populated by useHostsQuery
 */
export function useServicesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.services.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/services');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch services');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for creating a service
 */
export function useCreateServiceMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (service: Service) => {
			const { data } = await apiClient.POST('/api/services', { body: service });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create service');
			}
			return data.data;
		},
		onSuccess: (newService: Service) => {
			queryClient.setQueryData<Service[]>(queryKeys.services.all, (old) =>
				old ? [...old, newService] : [newService]
			);
		}
	}));
}

/**
 * Mutation hook for updating a service
 */
export function useUpdateServiceMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (service: Service) => {
			const { data } = await apiClient.PUT('/api/services/{id}', {
				params: { path: { id: service.id } },
				body: service
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update service');
			}
			return data.data;
		},
		onSuccess: (updatedService: Service) => {
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.map((s) => (s.id === updatedService.id ? updatedService : s)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a service
 */
export function useDeleteServiceMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/services/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete service');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.filter((s) => s.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting services
 */
export function useBulkDeleteServicesMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/services/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete services');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.filter((s) => !ids.includes(s.id)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk updating services for a host
 * Orchestrates create/update/delete operations
 */
export function useBulkUpdateServicesMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async ({ hostId, services }: { hostId: string; services: Service[] }) => {
			const currentServices = queryClient.getQueryData<Service[]>(queryKeys.services.all) ?? [];
			const hostServices = currentServices.filter((s) => s.host_id === hostId);

			const newServiceIds = new Set(services.map((s) => s.id));
			const currentServiceIds = new Set(hostServices.map((s) => s.id));

			// Detect creates, updates, deletes
			const toCreate = services.filter(
				(s) => !currentServiceIds.has(s.id) || s.id.startsWith('00000000')
			);
			const toUpdate = services.filter(
				(s) => currentServiceIds.has(s.id) && !s.id.startsWith('00000000')
			);
			const toDelete = hostServices.filter((s) => !newServiceIds.has(s.id));

			// Execute all operations
			const results = await Promise.all([
				...toCreate.map((s) =>
					apiClient.POST('/api/services', { body: { ...s, id: undefined } as unknown as Service })
				),
				...toUpdate.map((s) =>
					apiClient.PUT('/api/services/{id}', { params: { path: { id: s.id } }, body: s })
				),
				...toDelete.map((s) =>
					apiClient.DELETE('/api/services/{id}', { params: { path: { id: s.id } } })
				)
			]);

			// Collect created/updated services from results
			const createdUpdated: Service[] = [];
			for (let i = 0; i < toCreate.length + toUpdate.length; i++) {
				const result = results[i];
				if (result.data?.success && result.data.data) {
					createdUpdated.push(result.data.data as Service);
				}
			}

			return { hostId, createdUpdated, deletedIds: toDelete.map((s) => s.id) };
		},
		onSuccess: ({ hostId, createdUpdated, deletedIds }) => {
			queryClient.setQueryData<Service[]>(queryKeys.services.all, (old) => {
				if (!old) return createdUpdated;

				// Remove deleted and old host services
				const others = old.filter((s) => s.host_id !== hostId || !deletedIds.includes(s.id));

				// Replace host services with created/updated
				const nonHostServices = others.filter((s) => s.host_id !== hostId);
				return [...nonHostServices, ...createdUpdated];
			});
		}
	}));
}
