import { writable, derived, type Readable, readable, get } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { Binding, Service } from './types/base';
import { formatPort, utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { formatInterface, hosts } from '../hosts/store';
import { interfaces, getInterfaceFromId } from '../interfaces/store';
import { ports, getPortFromId } from '../ports/store';
import { ALL_INTERFACES, type Host } from '../hosts/types/base';
import { groups } from '../groups/store';
import type { Subnet } from '../subnets/types/base';

export const services = writable<Service[]>([]);

// Get all services
export async function getServices() {
	const { data } = await apiClient.GET('/api/services');
	if (data?.success && data.data) {
		services.set(data.data);
	}
	return data as ApiResponse<Service[]>;
}

// Create a service
export async function createService(data: Service) {
	const { data: result } = await apiClient.POST('/api/services', { body: data });
	if (result?.success && result.data) {
		services.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Service>;
}

// Delete a service
export async function deleteService(id: string) {
	const { data: result } = await apiClient.DELETE('/api/services/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		services.update((current) => current.filter((g) => g.id !== id));
	}
	return result;
}

export async function bulkDeleteServices(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/services/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		services.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

// Update a service
export async function updateService(data: Service) {
	const { data: result } = await apiClient.PUT('/api/services/{id}', {
		params: { path: { id: data.id } },
		body: data
	});
	if (result?.success && result.data) {
		services.update((current) => current.map((s) => (s.id === data.id ? result.data! : s)));
	}
	return result as ApiResponse<Service>;
}

/**
 * Bulk update services for a host - handles creates, updates, and deletes.
 * Compares new services list with existing services and syncs them.
 */
export async function bulkUpdateServices(hostId: string, newServices: Service[]) {
	const currentServices = get(services).filter((s) => s.host_id === hostId);

	const newIds = new Set(newServices.map((s) => s.id));
	const currentIds = new Set(currentServices.map((s) => s.id));

	// Services to delete (in current but not in new)
	const toDelete = currentServices.filter((s) => !newIds.has(s.id));

	// Services to create (in new but not in current, or with sentinel ID)
	const toCreate = newServices.filter((s) => !currentIds.has(s.id) || s.id === uuidv4Sentinel);

	// Services to update (in both, excluding new ones)
	const toUpdate = newServices.filter((s) => currentIds.has(s.id) && s.id !== uuidv4Sentinel);

	// Execute operations
	const promises: Promise<unknown>[] = [];

	for (const service of toDelete) {
		promises.push(deleteService(service.id));
	}

	for (const service of toCreate) {
		promises.push(createService(service));
	}

	for (const service of toUpdate) {
		promises.push(updateService(service));
	}

	await Promise.all(promises);
}

// Helper functions for working with services and the MetadataRegistry
export function createDefaultService(
	serviceType: string,
	host_id: string,
	host_network_id: string
): Service {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		network_id: host_network_id,
		host_id,
		tags: [],
		service_definition: serviceType,
		name: serviceType,
		bindings: [],
		virtualization: null,
		source: {
			type: 'Manual'
		}
	};
}

export function formatServiceLabel(service: Service | null, host: Host | null): string {
	if (host && service) {
		if (host.name === service.name) return host.name;
		else return host.name + ': ' + service.name;
	} else if (host && !service) {
		return host.name + ': Unknown Service';
	} else if (!host && service) {
		return service.name + ' (Unknown Host)';
	} else {
		return 'Unknown Service';
	}
}

export function formatServiceLabels(
	service_ids: string[]
): Readable<{ id: string; label: string }[]> {
	return derived([services, hosts], ([$services, $hosts]) => {
		return service_ids.map((service_id) => {
			const service = $services.find((s) => s.id === service_id);
			const host = service ? $hosts.find((h) => h.id === service.host_id) : null;

			return {
				id: service_id,
				label: formatServiceLabel(service || null, host || null)
			};
		});
	});
}

export function getServiceById(service_id: string): Readable<Service | null> {
	return derived([services], ([$services]) => {
		return $services.find((s) => s.id == service_id) || null;
	});
}

export function getServiceHost(service_id: string): Readable<Host | null> {
	return derived([hosts, services], ([$hosts, $services]) => {
		const service = $services.find((s) => s.id == service_id);
		if (service) {
			const host = $hosts.find((h) => h.id == service.host_id) || null;
			return host;
		}
		return null;
	});
}

export function getServicesForSubnet(subnet: Subnet): Readable<Service[]> {
	return derived([services, interfaces], ([$services, $interfaces]) => {
		// Get all interfaces on this subnet
		const subnetInterfaces = $interfaces.filter((i) => i.subnet_id === subnet.id);
		const interface_ids = subnetInterfaces.map((i) => i.id);
		const host_ids = [...new Set(subnetInterfaces.map((i) => i.host_id))];

		return $services.filter((s) => {
			return s.bindings.some(
				(b) =>
					(b.interface_id && interface_ids.includes(b.interface_id)) ||
					(host_ids.includes(s.host_id) && b.interface_id == null)
			);
		});
	});
}

export function getServicesForHost(host_id: string): Readable<Service[]> {
	return derived([services], ([$services]) => {
		// Note: Service ordering was previously stored on HostResponse.services,
		// but is no longer available with primitive stores.
		// Services are returned in their store order (typically creation order).
		return $services.filter((s) => s.host_id === host_id);
	});
}

export function getServicesForGroup(group_id: string): Readable<Service[]> {
	return derived([groups, services], ([$groups, $services]) => {
		const group = $groups.find((g) => g.id == group_id);

		if (group) {
			if (group.group_type === 'RequestPath' || group.group_type === 'HubAndSpoke') {
				const serviceMap = new Map($services.flatMap((s) => s.bindings.map((b) => [b.id, s])));
				return group.binding_ids
					.map((sb) => serviceMap.get(sb))
					.filter((s) => s !== null && s !== undefined);
			} else {
				return [];
			}
		}
		return [];
	});
}

export function serviceHasInterfaceOnSubnet(service: Service, subnetId: string): Readable<boolean> {
	return derived([interfaces], ([$interfaces]) => {
		return service.bindings.some((binding) => {
			if (!binding.interface_id) return false;
			const iface = $interfaces.find((i) => i.id === binding.interface_id);
			return iface && iface.subnet_id === subnetId;
		});
	});
}

export function getServiceName(service: Service): string {
	return service.name || service.service_definition;
}

export function getServicesForPort(port_id: string): Readable<Service[]> {
	return derived([ports, services], ([$ports, $services]) => {
		const port = $ports.find((p) => p.id === port_id);
		if (!port) return [];

		return $services.filter(
			(s) =>
				s.host_id === port.host_id &&
				s.bindings.some((b) => b.type === 'Port' && b.port_id === port_id)
		);
	});
}

export function getServicesForInterface(interface_id: string): Readable<Service[]> {
	return derived([interfaces, services], ([$interfaces, $services]) => {
		const iface = $interfaces.find((i) => i.id === interface_id);
		if (!iface) return [];

		return $services.filter(
			(s) => s.host_id === iface.host_id && s.bindings.some((b) => b.interface_id === interface_id)
		);
	});
}

export function getServiceForBinding(binding_id: string): Readable<Service | null> {
	return derived([services], ([$services]) => {
		return $services.find((s) => s.bindings.map((b) => b.id).includes(binding_id)) || null;
	});
}

export function getBindingFromId(id: string): Readable<Binding | null> {
	return derived([services], ([$services]) => {
		return $services.flatMap((s) => s.bindings).find((b) => b.id == id) || null;
	});
}

export function getBindingDisplayName(binding: Binding): Readable<string> {
	return derived(
		[
			getServiceForBinding(binding.id),
			getInterfaceFromId(binding.interface_id || ''),
			binding.type == 'Port' ? getPortFromId(binding.port_id || '') : readable(null),
			hosts
		],
		([$service, $iface, $port, $hosts]) => {
			if ($service) {
				const interfaceToUse = $iface || ALL_INTERFACES;
				const host = $hosts.find((h) => h.id === $service.host_id);

				if (host) {
					switch (binding.type) {
						case 'Interface':
							if (interfaceToUse) return formatInterface(interfaceToUse);
							break;
						case 'Port': {
							if ($port && interfaceToUse) {
								return formatInterface(interfaceToUse) + ' · ' + formatPort($port);
							}
							break;
						}
					}
				}
			}
			return 'Unknown Binding';
		}
	);
}
