import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { CreateNetworkRequest, Network } from './types';
import { currentUser } from '../auth/store';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export const networks = writable<Network[]>([]);

export async function getNetworks() {
	const user = get(currentUser);

	if (user) {
		await api.request<Network[]>(`/networks`, networks, (networks) => networks, {
			method: 'GET'
		});
	}
}

export async function createNetwork(data: CreateNetworkRequest) {
	const result = await api.request<Network, Network[]>(
		'/networks',
		networks,
		(network, current) => [...current, network],
		{ method: 'POST', body: JSON.stringify(data) }
	);

	return result;
}

export async function updateNetwork(data: Network) {
	const result = await api.request<Network, Network[]>(
		`/networks/${data.id}`,
		networks,
		(updatedNetwork, current) => current.map((g) => (g.id === data.id ? updatedNetwork : g)),
		{ method: 'PUT', body: JSON.stringify(data) }
	);

	return result;
}

export async function deleteNetwork(id: string) {
	const result = await api.request<void, Network[]>(
		`/networks/${id}`,
		networks,
		(_, current) => current.filter((n) => n.id !== id),
		{ method: 'DELETE' }
	);

	return result;
}

export async function bulkDeleteNetworks(ids: string[]) {
	const result = await api.request<void, Network[]>(
		`/networks/bulk-delete`,
		networks,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

export function createEmptyNetworkFormData(): Network {
	return {
		id: uuidv4Sentinel,
		name: '',
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		organization_id: uuidv4Sentinel,
		tags: []
	};
}
