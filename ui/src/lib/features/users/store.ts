import { writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { User } from './types';

export const users = writable<User[]>([]);

/**
 * Fetch all users in the organization
 */
export async function getUsers(): Promise<void> {
	const { data } = await apiClient.GET('/api/users');
	if (data?.success && data.data) {
		users.set(data.data);
	}
}

export async function deleteUser(id: string) {
	const { data: result } = await apiClient.DELETE('/api/users/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		users.update((current) => current.filter((d) => d.id !== id));
	}
	return result;
}

export async function bulkDeleteUsers(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/users/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		users.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export async function updateUserAsAdmin(user: User) {
	const { data: result } = await apiClient.PUT('/api/users/{id}/admin', {
		params: { path: { id: user.id } },
		body: user
	});
	if (result?.success && result.data) {
		users.update((current) => current.map((u) => (u.id === user.id ? result.data! : u)));
	}
	return result as ApiResponse<User>;
}
