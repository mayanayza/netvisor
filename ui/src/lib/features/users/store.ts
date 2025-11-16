import { writable } from 'svelte/store';
import { api } from '$lib/shared/utils/api';
import type { User } from './types';

export const users = writable<User[]>([]);

/**
 * Fetch all users in the organization
 */
export async function getUsers(): Promise<void> {
	await api.request<User[], User[]>('/users', users, (users) => users, { method: 'GET' });
}

export async function deleteUser(id: string) {
	return await api.request<void, User[]>(
		`/users/${id}`,
		users,
		(_, current) => current.filter((d) => d.id !== id),
		{ method: 'DELETE' }
	);
}
