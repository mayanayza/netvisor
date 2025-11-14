import { derived, get, writable, type Readable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import type { Subnet } from './types/base';
import { currentNetwork } from '../networks/store';
import type { Interface } from '../hosts/types/base';
import { hosts } from '../hosts/store';

export const subnets = writable<Subnet[]>([]);

export async function getSubnets() {
	return await api.request<Subnet[]>(`/subnets`, subnets, (subnets) => subnets, { method: 'GET' });
}

export async function createSubnet(subnet: Subnet) {
	const result = await api.request<Subnet, Subnet[]>(
		'/subnets',
		subnets,
		(response, currentSubnets) => [...currentSubnets, response],
		{
			method: 'POST',
			body: JSON.stringify(subnet)
		}
	);

	return result;
}

export async function updateSubnet(subnet: Subnet) {
	const result = await api.request<Subnet, Subnet[]>(
		`/subnets/${subnet.id}`,
		subnets,
		(response, currentSubnets) => currentSubnets.map((s) => (s.id === subnet.id ? response : s)),
		{
			method: 'PUT',
			body: JSON.stringify(subnet)
		}
	);

	return result;
}

export async function deleteSubnet(subnetId: string) {
	const result = await api.request<void, Subnet[]>(
		`/subnets/${subnetId}`,
		subnets,
		(_, currentSubnets) => currentSubnets.filter((s) => s.id !== subnetId),
		{ method: 'DELETE' }
	);

	return result;
}

export function createEmptySubnetFormData(): Subnet {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		name: '',
		network_id: get(currentNetwork).id,
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
	return derived([hosts], ([$hosts]) => {
		return $hosts.flatMap((h) => h.interfaces).filter((i) => i.subnet_id == subnet_id);
	});
}
