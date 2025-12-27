/**
 * TanStack Query hooks for Subnets
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Subnet } from './types/base';

/**
 * Query hook for fetching all subnets
 */
export function useSubnetsQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.subnets.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/subnets');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch subnets');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for creating a subnet
 */
export function useCreateSubnetMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (subnet: Subnet) => {
			const { data } = await apiClient.POST('/api/subnets', { body: subnet });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create subnet');
			}
			return data.data;
		},
		onSuccess: (newSubnet: Subnet) => {
			queryClient.setQueryData<Subnet[]>(queryKeys.subnets.all, (old) =>
				old ? [...old, newSubnet] : [newSubnet]
			);
		}
	}));
}

/**
 * Mutation hook for updating a subnet
 */
export function useUpdateSubnetMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (subnet: Subnet) => {
			const { data } = await apiClient.PUT('/api/subnets/{id}', {
				params: { path: { id: subnet.id } },
				body: subnet
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update subnet');
			}
			return data.data;
		},
		onSuccess: (updatedSubnet: Subnet) => {
			queryClient.setQueryData<Subnet[]>(
				queryKeys.subnets.all,
				(old) => old?.map((s) => (s.id === updatedSubnet.id ? updatedSubnet : s)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for deleting a subnet
 */
export function useDeleteSubnetMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/subnets/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete subnet');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Subnet[]>(
				queryKeys.subnets.all,
				(old) => old?.filter((s) => s.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting subnets
 */
export function useBulkDeleteSubnetsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/subnets/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete subnets');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			queryClient.setQueryData<Subnet[]>(
				queryKeys.subnets.all,
				(old) => old?.filter((s) => !ids.includes(s.id)) ?? []
			);
		}
	}));
}

/**
 * Check if a subnet is a container subnet (CIDR is 0.0.0.0/0 and source is System)
 */
export function isContainerSubnet(subnet: Subnet): boolean {
	return subnet.cidr === '0.0.0.0/0' && subnet.source.type === 'System';
}

/**
 * Get a subnet by ID from a list of subnets
 */
export function getSubnetById(subnets: Subnet[], id: string): Subnet | null {
	return subnets.find((s) => s.id === id) ?? null;
}
