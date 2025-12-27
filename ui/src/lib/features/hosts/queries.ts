/**
 * TanStack Query hooks for Hosts
 *
 * Hosts are the parent entity that populates child caches for interfaces, ports, and services.
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import { pushSuccess } from '$lib/shared/stores/feedback';
import type {
	Host,
	HostResponse,
	HostFormData,
	Interface,
	Port,
	CreateHostWithServicesRequest,
	UpdateHostWithServicesRequest,
	CreateHostRequest,
	CreateInterfaceInput,
	CreatePortInput,
	UpdateHostRequest,
	UpdateInterfaceInput,
	UpdatePortInput,
	AllInterfaces
} from './types/base';
import type { Service } from '$lib/features/services/types/base';

// Re-export types for convenience
export type { Host, HostResponse, HostFormData, Interface, Port };

/**
 * Extract Host primitive from HostResponse (removes embedded children)
 */
export function toHostPrimitive(response: HostResponse): Host {
	return {
		id: response.id,
		created_at: response.created_at,
		updated_at: response.updated_at,
		name: response.name,
		network_id: response.network_id,
		hostname: response.hostname ?? null,
		description: response.description ?? null,
		source: response.source,
		virtualization: response.virtualization ?? null,
		hidden: response.hidden,
		tags: response.tags
	};
}

/**
 * Extract Host primitive from HostFormData (removes embedded children)
 */
export function formDataToHostPrimitive(formData: HostFormData): Host {
	return {
		id: formData.id,
		created_at: formData.created_at,
		updated_at: formData.updated_at,
		name: formData.name,
		network_id: formData.network_id,
		hostname: formData.hostname,
		description: formData.description,
		source: formData.source,
		virtualization: formData.virtualization,
		hidden: formData.hidden,
		tags: formData.tags
	};
}

/**
 * Transform HostFormData to CreateHostRequest format for API
 */
function toCreateHostRequest(formData: HostFormData): CreateHostRequest {
	return {
		name: formData.name,
		network_id: formData.network_id,
		hostname: formData.hostname,
		description: formData.description,
		virtualization: formData.virtualization,
		hidden: formData.hidden,
		tags: formData.tags,
		interfaces: formData.interfaces.map(
			(iface): CreateInterfaceInput => ({
				subnet_id: iface.subnet_id,
				ip_address: iface.ip_address,
				mac_address: iface.mac_address,
				name: iface.name
			})
		),
		ports: formData.ports.map(
			(port): CreatePortInput => ({
				number: port.number,
				protocol: port.protocol
			})
		)
	};
}

/**
 * Query hook for fetching all hosts
 * Populates interfaces, ports, and services caches from the response
 */
export function useHostsQuery() {
	const queryClient = useQueryClient();

	return createQuery(() => ({
		queryKey: queryKeys.hosts.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/hosts');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch hosts');
			}

			const responses = data.data;

			// Extract and populate child caches
			const allInterfaces = responses.flatMap((r) => r.interfaces);
			const allPorts = responses.flatMap((r) => r.ports);
			const allServices = responses.flatMap((r) => r.services);

			queryClient.setQueryData(queryKeys.interfaces.all, allInterfaces);
			queryClient.setQueryData(queryKeys.ports.all, allPorts);
			queryClient.setQueryData(queryKeys.services.all, allServices);

			// Return host primitives
			return responses.map(toHostPrimitive);
		}
	}));
}

/**
 * Mutation hook for creating a host
 */
export function useCreateHostMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (data: CreateHostWithServicesRequest) => {
			const request = toCreateHostRequest(data.host);
			const { data: result } = await apiClient.POST('/api/hosts', { body: request });
			if (!result?.success || !result.data) {
				throw new Error(result?.error || 'Failed to create host');
			}
			return result.data;
		},
		onSuccess: (response: HostResponse) => {
			// Add host to cache
			queryClient.setQueryData<Host[]>(queryKeys.hosts.all, (old) =>
				old ? [...old, toHostPrimitive(response)] : [toHostPrimitive(response)]
			);

			// Add children to their caches
			queryClient.setQueryData<Interface[]>(queryKeys.interfaces.all, (old) =>
				old ? [...old, ...response.interfaces] : response.interfaces
			);
			queryClient.setQueryData<Port[]>(queryKeys.ports.all, (old) =>
				old ? [...old, ...response.ports] : response.ports
			);
			queryClient.setQueryData<Service[]>(queryKeys.services.all, (old) =>
				old ? [...old, ...response.services] : response.services
			);
		}
	}));
}

/**
 * Mutation hook for updating a host
 */
export function useUpdateHostMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (data: UpdateHostWithServicesRequest) => {
			// Get current saved interfaces/ports from cache to detect new items
			const savedInterfaces = queryClient.getQueryData<Interface[]>(queryKeys.interfaces.all) ?? [];
			const savedPorts = queryClient.getQueryData<Port[]>(queryKeys.ports.all) ?? [];
			const savedInterfaceIds = new Set(savedInterfaces.map((i) => i.id));
			const savedPortIds = new Set(savedPorts.map((p) => p.id));

			const request: UpdateHostRequest = {
				id: data.host.id,
				name: data.host.name,
				hostname: data.host.hostname,
				description: data.host.description,
				virtualization: data.host.virtualization,
				hidden: data.host.hidden,
				tags: data.host.tags,
				expected_updated_at: data.host.updated_at,
				interfaces: data.interfaces
					? data.interfaces.map(
							(iface): UpdateInterfaceInput => ({
								id: savedInterfaceIds.has(iface.id) ? iface.id : null,
								subnet_id: iface.subnet_id,
								ip_address: iface.ip_address,
								mac_address: iface.mac_address,
								name: iface.name
							})
						)
					: null,
				ports: data.ports
					? data.ports.map(
							(port): UpdatePortInput => ({
								id: savedPortIds.has(port.id) ? port.id : null,
								number: port.number,
								protocol: port.protocol
							})
						)
					: null
			};

			const { data: result } = await apiClient.PUT('/api/hosts/{id}', {
				params: { path: { id: data.host.id } },
				body: request
			});
			if (!result?.success || !result.data) {
				throw new Error(result?.error || 'Failed to update host');
			}

			return { response: result.data, services: data.services };
		},
		onSuccess: async ({ response, services: newServices }) => {
			const hostId = response.id;

			// Update host in cache
			queryClient.setQueryData<Host[]>(
				queryKeys.hosts.all,
				(old) => old?.map((h) => (h.id === hostId ? toHostPrimitive(response) : h)) ?? []
			);

			// Replace interfaces for this host
			queryClient.setQueryData<Interface[]>(queryKeys.interfaces.all, (old) => {
				const others = old?.filter((i) => i.host_id !== hostId) ?? [];
				return [...others, ...response.interfaces];
			});

			// Replace ports for this host
			queryClient.setQueryData<Port[]>(queryKeys.ports.all, (old) => {
				const others = old?.filter((p) => p.host_id !== hostId) ?? [];
				return [...others, ...response.ports];
			});

			// Replace services for this host from response
			queryClient.setQueryData<Service[]>(queryKeys.services.all, (old) => {
				const others = old?.filter((s) => s.host_id !== hostId) ?? [];
				return [...others, ...response.services];
			});

			// If services were provided separately, handle bulk update
			if (newServices !== null) {
				// This would call the services bulk update API
				// For now, services are synced from response above
			}
		}
	}));
}

/**
 * Mutation hook for deleting a host
 */
export function useDeleteHostMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/hosts/{id}', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete host');
			}
			return id;
		},
		onSuccess: (id: string) => {
			// Remove host from cache
			queryClient.setQueryData<Host[]>(
				queryKeys.hosts.all,
				(old) => old?.filter((h) => h.id !== id) ?? []
			);

			// Remove children from their caches
			queryClient.setQueryData<Interface[]>(
				queryKeys.interfaces.all,
				(old) => old?.filter((i) => i.host_id !== id) ?? []
			);
			queryClient.setQueryData<Port[]>(
				queryKeys.ports.all,
				(old) => old?.filter((p) => p.host_id !== id) ?? []
			);
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.filter((s) => s.host_id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for bulk deleting hosts
 */
export function useBulkDeleteHostsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (ids: string[]) => {
			const { data } = await apiClient.POST('/api/hosts/bulk-delete', { body: ids });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to delete hosts');
			}
			return ids;
		},
		onSuccess: (ids: string[]) => {
			const idSet = new Set(ids);

			// Remove hosts from cache
			queryClient.setQueryData<Host[]>(
				queryKeys.hosts.all,
				(old) => old?.filter((h) => !idSet.has(h.id)) ?? []
			);

			// Remove children from their caches
			queryClient.setQueryData<Interface[]>(
				queryKeys.interfaces.all,
				(old) => old?.filter((i) => !idSet.has(i.host_id)) ?? []
			);
			queryClient.setQueryData<Port[]>(
				queryKeys.ports.all,
				(old) => old?.filter((p) => !idSet.has(p.host_id)) ?? []
			);
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.filter((s) => !idSet.has(s.host_id)) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for consolidating hosts
 */
export function useConsolidateHostsMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async ({
			destinationHostId,
			otherHostId
		}: {
			destinationHostId: string;
			otherHostId: string;
		}) => {
			const hosts = queryClient.getQueryData<Host[]>(queryKeys.hosts.all) ?? [];
			const otherHostName = hosts.find((h) => h.id === otherHostId)?.name;

			const { data } = await apiClient.PUT(
				'/api/hosts/{destination_host}/consolidate/{other_host}',
				{
					params: { path: { destination_host: destinationHostId, other_host: otherHostId } }
				}
			);
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to consolidate hosts');
			}
			return { response: data.data, otherHostId, otherHostName };
		},
		onSuccess: ({ response, otherHostId, otherHostName }) => {
			// Remove consolidated host, update destination host
			queryClient.setQueryData<Host[]>(queryKeys.hosts.all, (old) => {
				const filtered = old?.filter((h) => h.id !== otherHostId) ?? [];
				return filtered.map((h) => (h.id === response.id ? toHostPrimitive(response) : h));
			});

			// Remove children of consolidated host
			queryClient.setQueryData<Interface[]>(
				queryKeys.interfaces.all,
				(old) => old?.filter((i) => i.host_id !== otherHostId) ?? []
			);
			queryClient.setQueryData<Port[]>(
				queryKeys.ports.all,
				(old) => old?.filter((p) => p.host_id !== otherHostId) ?? []
			);
			queryClient.setQueryData<Service[]>(
				queryKeys.services.all,
				(old) => old?.filter((s) => s.host_id !== otherHostId) ?? []
			);

			// Add updated destination host children
			queryClient.setQueryData<Interface[]>(queryKeys.interfaces.all, (old) => {
				const others = old?.filter((i) => i.host_id !== response.id) ?? [];
				return [...others, ...response.interfaces];
			});
			queryClient.setQueryData<Port[]>(queryKeys.ports.all, (old) => {
				const others = old?.filter((p) => p.host_id !== response.id) ?? [];
				return [...others, ...response.ports];
			});
			queryClient.setQueryData<Service[]>(queryKeys.services.all, (old) => {
				const others = old?.filter((s) => s.host_id !== response.id) ?? [];
				return [...others, ...response.services];
			});

			if (otherHostName) {
				pushSuccess(`Consolidated host "${otherHostName}" into host "${response.name}"`);
			}
		}
	}));
}

/**
 * Format an interface for display
 */
export function formatInterface(
	i: Interface | AllInterfaces,
	isContainerSubnetFn: (subnetId: string) => boolean
): string {
	if (i.id == null) return i.name;
	return isContainerSubnetFn(i.subnet_id)
		? (i.name ?? i.ip_address)
		: (i.name ? i.name + ': ' : '') + i.ip_address;
}
