import { writable, derived, type Readable, readable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { Binding, Service } from './types/base';
import { formatPort, utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { formatInterface, getInterfaceFromId, getPortFromId, hosts } from '../hosts/store';
import { ALL_INTERFACES, type Host } from '../hosts/types/base';
import { groups } from '../groups/store';
import type { Subnet } from '../subnets/types/base';

export const services = writable<Service[]>([]);

// Get all services
export async function getServices() {
	return await api.request<Service[]>(`/services`, services, (services) => services, {
		method: 'GET'
	});
}

// Delete a service
export async function deleteService(id: string) {
	return await api.request<void, Service[]>(
		`/services/${id}`,
		services,
		(_, current) => current.filter((g) => g.id !== id),
		{ method: 'DELETE' }
	);
}

export async function bulkDeleteServices(ids: string[]) {
	const result = await api.request<void, Service[]>(
		`/services/bulk-delete`,
		services,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

// Update a service
export async function updateService(data: Service) {
	console.log(1);
	return await api.request<Service, Service[]>(
		`/services/${data.id}`,
		services,
		(updatedService, current) => current.map((s) => (s.id === data.id ? updatedService : s)),
		{ method: 'PUT', body: JSON.stringify(data) }
	);
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
	return derived([services, hosts], ([$services, $hosts]) => {
		const host_ids = $hosts
			.filter((h) => h.interfaces.some((i) => i.subnet_id == subnet.id))
			.map((h) => h.id);
		const interface_ids = $hosts
			.flatMap((h) => h.interfaces)
			.filter((i) => i.subnet_id == subnet.id)
			.map((i) => i.id);

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
	return derived([services, hosts], ([$services, $hosts]) => {
		const host = $hosts.find((h) => h.id == host_id);

		return $services
			.filter((s) => s.host_id == host_id)
			.sort((a, b) => {
				if (host) {
					const aIndex = host.services.findIndex((s) => s.id === a.id);
					const bIndex = host.services.findIndex((s) => s.id === b.id);
					return aIndex - bIndex;
				}
				return 0;
			});
	});
}

export function getServicesForGroup(group_id: string): Readable<Service[]> {
	return derived([groups, services], ([$groups, $services]) => {
		const group = $groups.find((g) => g.id == group_id);

		if (group) {
			if (group.group_type === 'RequestPath' || group.group_type === 'HubAndSpoke') {
				const serviceMap = new Map($services.flatMap((s) => s.bindings.map((b) => [b.id, s])));
				return group.service_bindings
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
	return derived([hosts], ([$hosts]) => {
		const host = $hosts.find((h) => h.id == service.host_id);
		if (!host) return false;

		return service.bindings.some((binding) => {
			const iface = host.interfaces.find((iface) => iface.id === binding.interface_id);
			return iface && iface.subnet_id === subnetId;
		});
	});
}

export function getServiceName(service: Service): string {
	return service.name || service.service_definition;
}

export function getServicesForPort(port_id: string): Readable<Service[]> {
	return derived([hosts, services], ([$hosts, $services]) => {
		const host = $hosts.find((h) => h.ports.some((p) => p.id === port_id));

		if (host) {
			return $services.filter(
				(s) =>
					s.host_id == host.id && s.bindings.some((b) => b.type == 'Port' && b.port_id === port_id)
			);
		}
		return [];
	});
}

export function getServicesForInterface(interface_id: string): Readable<Service[]> {
	return derived([hosts, services], ([$hosts, $services]) => {
		const host = $hosts.find((h) => h.interfaces.some((i) => i.id === interface_id));

		if (host) {
			return $services.filter(
				(s) => s.host_id == host.id && s.bindings.some((b) => b.interface_id === interface_id)
			);
		}
		return [];
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
