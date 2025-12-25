import { get, writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { Network } from './types';
import { currentUser } from '../auth/store';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export const networks = writable<Network[]>([]);

export async function getNetworks() {
	const user = get(currentUser);

	if (user) {
		const { data } = await apiClient.GET('/api/networks');
		if (data?.success && data.data) {
			networks.set(data.data);
		}
	}
}

export async function createNetwork(data: Network) {
	const { data: result } = await apiClient.POST('/api/networks', { body: data });
	if (result?.success && result.data) {
		networks.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Network>;
}

export async function updateNetwork(data: Network) {
	const { data: result } = await apiClient.PUT('/api/networks/{id}', {
		params: { path: { id: data.id } },
		body: data
	});
	if (result?.success && result.data) {
		networks.update((current) => current.map((g) => (g.id === data.id ? result.data! : g)));
	}
	return result as ApiResponse<Network>;
}

export async function deleteNetwork(id: string) {
	const { data: result } = await apiClient.DELETE('/api/networks/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		networks.update((current) => current.filter((n) => n.id !== id));
	}
	return result;
}

export async function bulkDeleteNetworks(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/networks/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		networks.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
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
