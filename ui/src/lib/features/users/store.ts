// import { writable } from 'svelte/store';
// import { api } from '../../shared/utils/api';
// import type { User } from './types';
// import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

// export async function getUser(user_id: string): Promise<User | null> {
// 	const result = await api.request<User>(`/users/${user_id}`, user, (user) => user, {
// 		method: 'GET'
// 	});

// 	if (result && result.success && result.data) {
// 		return result.data;
// 	}
// 	return null;
// }

// export async function createUser(): Promise<User | null> {
// 	const result = await api.request<User>('/users', user, (user) => user, {
// 		method: 'POST',
// 		body: JSON.stringify(newUser())
// 	});

// 	if (result && result.success && result.data) {
// 		return result.data;
// 	}
// 	return null;
// }

// function newUser() {
// 	const user: User = {
// 		id: uuidv4Sentinel,
// 		created_at: utcTimeZoneSentinel,
// 		updated_at: utcTimeZoneSentinel,
// 		name: '',
// 		username: ''
// 	};

// 	return user;
// }
