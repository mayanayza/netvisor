import { derived, get, writable, type Readable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import type { Subnet } from './types/base';
import type { Interface } from '../hosts/types/base';
import { interfaces } from '../interfaces/store';
import { networks } from '../networks/store';

export const subnets = writable<Subnet[]>([]);

export async function getSubnets() {
	const { data } = await apiClient.GET('/api/subnets');
	if (data?.success && data.data) {
		subnets.set(data.data);
	}
	return data as ApiResponse<Subnet[]>;
}

export async function createSubnet(subnet: Subnet) {
	const { data: result } = await apiClient.POST('/api/subnets', { body: subnet });
	if (result?.success && result.data) {
		subnets.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Subnet>;
}

export async function bulkDeleteSubnets(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/subnets/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		subnets.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export async function updateSubnet(subnet: Subnet) {
	const { data: result } = await apiClient.PUT('/api/subnets/{id}', {
		params: { path: { id: subnet.id } },
		body: subnet
	});
	if (result?.success && result.data) {
		subnets.update((current) => current.map((s) => (s.id === subnet.id ? result.data! : s)));
	}
	return result as ApiResponse<Subnet>;
}

export async function deleteSubnet(subnetId: string) {
	const { data: result } = await apiClient.DELETE('/api/subnets/{id}', {
		params: { path: { id: subnetId } }
	});
	if (result?.success) {
		subnets.update((current) => current.filter((s) => s.id !== subnetId));
	}
	return result;
}

export function createEmptySubnetFormData(): Subnet {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		tags: [],
		name: '',
		network_id: get(networks)[0]?.id || '',
		cidr: '',
		description: '',
		subnet_type: 'Unknown',
		source: {
			type: 'Manual'
		}
	};
}

export function getSubnetFromId(id: string): Readable<Subnet | null> {
	return derived([subnets], ([$subnets]) => {
		return $subnets.find((s) => s.id == id) || null;
	});
}

export function isContainerSubnet(id: string): Readable<boolean> {
	return derived([subnets], ([$subnets]) => {
		const subnet = $subnets.find((s) => s.id == id);
		if (subnet) {
			return subnet.cidr == '0.0.0.0/0' && subnet.source.type == 'System';
		}
		return false;
	});
}

export function getInterfacesOnSubnet(subnet_id: string): Readable<Interface[]> {
	return derived([interfaces], ([$interfaces]) => {
		return $interfaces.filter((i) => i.subnet_id === subnet_id);
	});
}
