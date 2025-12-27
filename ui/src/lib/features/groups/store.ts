import { derived, get, writable, type Readable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { Group } from '$lib/features/groups/types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { getServices } from '../services/store';
import { entities } from '$lib/shared/stores/metadata';
import { networks } from '../networks/store';
import type { Color } from '$lib/shared/utils/styling';

export const groups = writable<Group[]>([]);

export async function getGroups() {
	const { data } = await apiClient.GET('/api/groups');
	if (data?.success && data.data) {
		groups.set(data.data);
	}
	return data as ApiResponse<Group[]>;
}

export async function createGroup(data: Group) {
	const { data: result } = await apiClient.POST('/api/groups', { body: data });
	if (result?.success && result.data) {
		groups.update((current) => [...current, result.data!]);
		await getServices();
	}
	return result as ApiResponse<Group>;
}

export async function updateGroup(data: Group) {
	const { data: result } = await apiClient.PUT('/api/groups/{id}', {
		params: { path: { id: data.id } },
		body: data
	});
	if (result?.success && result.data) {
		groups.update((current) => current.map((g) => (g.id === data.id ? result.data! : g)));
		await getServices();
	}
	return result as ApiResponse<Group>;
}

export async function deleteGroup(id: string) {
	const { data: result } = await apiClient.DELETE('/api/groups/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		groups.update((current) => current.filter((g) => g.id !== id));
		await getServices();
	}
	return result;
}

export async function bulkDeleteGroups(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/groups/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		groups.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export function createEmptyGroupFormData(): Group {
	return {
		id: uuidv4Sentinel,
		name: '',
		description: '',
		binding_ids: [],
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		group_type: 'RequestPath',
		source: {
			type: 'Manual'
		},
		network_id: get(networks)[0]?.id || '',
		color: entities.getColorHelper('Group').color as Color,
		edge_style: 'Straight',
		tags: []
	};
}

export function getGroupById(id: string): Readable<Group | null> {
	return derived([groups], ([$groups]) => {
		return $groups.find((g) => g.id == id) || null;
	});
}
