/**
 * TanStack Query hooks for Topology
 *
 * Note: UI state (selected nodes/edges, options panel, localStorage preferences)
 * remains in local component state or a separate UI store.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { Topology, TopologyOptions } from './types/base';
import { uuidv4Sentinel, utcTimeZoneSentinel } from '$lib/shared/utils/formatting';

// Default options for new topologies
export const defaultTopologyOptions: TopologyOptions = {
	local: {
		left_zone_title: 'Infrastructure',
		hide_edge_types: [],
		no_fade_edges: false,
		hide_resize_handles: false
	},
	request: {
		group_docker_bridges_by_host: true,
		hide_ports: false,
		hide_vm_title_on_docker_container: false,
		show_gateway_in_left_zone: true,
		left_zone_service_categories: ['DNS', 'ReverseProxy'],
		hide_service_categories: []
	}
};

/**
 * Query hook for fetching all topologies
 */
export function useTopologiesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.topology.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/topology');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch topologies');
			}
			return data.data;
		}
	}));
}

/**
 * Query hook for fetching a single topology
 */
export function useTopologyQuery(id: () => string | undefined) {
	return createQuery(() => ({
		queryKey: queryKeys.topology.detail(id() ?? ''),
		queryFn: async () => {
			const topologyId = id();
			if (!topologyId) {
				throw new Error('No topology ID provided');
			}
			const { data } = await apiClient.GET('/api/topology/{id}', {
				params: { path: { id: topologyId } }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch topology');
			}
			return data.data;
		},
		enabled: () => !!id()
	}));
}

/**
 * Mutation hook for creating a topology
 */
export function useCreateTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/topology', { body: topology });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create topology');
			}
			return data.data;
		},
		onSuccess: (newTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(queryKeys.topology.all, (old) =>
				old ? [...old, newTopology] : [newTopology]
			);
		}
	}));
}

/**
 * Mutation hook for updating a topology
 * Note: Updated topology returns through SSE, so we don't update cache here
 */
export function useUpdateTopologyMutation() {
	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.PUT('/api/topology/{id}', {
				params: { path: { id: topology.id } },
				body: topology
			});
			return topology;
		}
	}));
}

/**
 * Mutation hook for deleting a topology
 */
export function useDeleteTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/topology/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete topology');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.filter((t) => t.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for refreshing a topology
 * Note: Updated topology returns through SSE
 */
export function useRefreshTopologyMutation() {
	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.POST('/api/topology/{id}/refresh', {
				params: { path: { id: topology.id } },
				body: topology
			});
			return topology.id;
		}
	}));
}

/**
 * Mutation hook for rebuilding a topology
 * Note: Updated topology returns through SSE
 */
export function useRebuildTopologyMutation() {
	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			await apiClient.POST('/api/topology/{id}/rebuild', {
				params: { path: { id: topology.id } },
				body: topology
			});
			return topology.id;
		}
	}));
}

/**
 * Mutation hook for locking a topology
 */
export function useLockTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/topology/{id}/lock', {
				params: { path: { id: topology.id } },
				body: topology
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to lock topology');
			}
			return data.data;
		},
		onSuccess: (updatedTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.map((t) => (t.id === updatedTopology.id ? updatedTopology : t)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for unlocking a topology
 */
export function useUnlockTopologyMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (topology: Topology) => {
			const { data } = await apiClient.POST('/api/topology/{id}/unlock', {
				params: { path: { id: topology.id } },
				body: topology
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to unlock topology');
			}
			return data.data;
		},
		onSuccess: (updatedTopology: Topology) => {
			queryClient.setQueryData<Topology[]>(
				queryKeys.topology.all,
				(old) => old?.map((t) => (t.id === updatedTopology.id ? updatedTopology : t)) ?? []
			);
		}
	}));
}

/**
 * Helper to update topologies in the query cache (for SSE updates)
 */
export function updateTopologyInCache(
	queryClient: ReturnType<typeof useQueryClient>,
	topology: Topology
) {
	queryClient.setQueryData<Topology[]>(
		queryKeys.topology.all,
		(old) => old?.map((t) => (t.id === topology.id ? topology : t)) ?? []
	);
}

/**
 * Create empty topology form data
 */
export function createEmptyTopologyFormData(networkId: string): Topology {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		name: '',
		network_id: networkId,
		edges: [],
		nodes: [],
		options: structuredClone(defaultTopologyOptions),
		hosts: [],
		interfaces: [],
		services: [],
		subnets: [],
		groups: [],
		ports: [],
		bindings: [],
		is_stale: false,
		last_refreshed: utcTimeZoneSentinel,
		is_locked: false,
		removed_groups: [],
		removed_hosts: [],
		removed_interfaces: [],
		removed_services: [],
		removed_subnets: [],
		removed_bindings: [],
		removed_ports: [],
		locked_at: null,
		locked_by: null,
		parent_id: null,
		tags: []
	};
}
