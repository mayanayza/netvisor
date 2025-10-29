import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { Network } from './types';
import { currentUser } from '../auth/store';

export const networks = writable<Network[]>([]);
export const currentNetwork = writable<Network>();

export async function getNetworks() {
	const user = get(currentUser);

	if (user) {
		const result = await api.request<Network[]>(
			`/networks?user_id=${user.id}`,
			networks,
			(networks) => networks,
			{ method: 'GET' }
		);

		if (result && result.success && result.data) {
			console.log(result.data);
			const current = get(networks).find((n) => n.is_default) || get(networks)[0];
			currentNetwork.set(current);
		}
	}
}
