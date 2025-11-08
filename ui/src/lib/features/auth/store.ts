import { writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { LoginRequest, RegisterRequest } from './types/base';
import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
import type { User } from '../users/types';

export const currentUser = writable<User | null>(null);
export const isAuthenticated = writable<boolean>(false);
export const isCheckingAuth = writable<boolean>(true);

/**
 * Check if user is authenticated by fetching current session
 */
export async function checkAuth(): Promise<boolean> {
	isCheckingAuth.set(true);

	const result = await api.request<User, User | null>('/auth/me', currentUser, (user) => user, {
		method: 'POST'
	});

	if (result && result.success && result.data) {
		isAuthenticated.set(true);
		isCheckingAuth.set(false);
		return true;
	}

	isAuthenticated.set(false);
	currentUser.set(null);
	isCheckingAuth.set(false);
	return false;
}

/**
 * Login user
 */
export async function login(request: LoginRequest): Promise<boolean> {
	const result = await api.request<User, User | null>('/auth/login', currentUser, (user) => user, {
		method: 'POST',
		body: JSON.stringify(request)
	});

	if (result && result.success && result.data) {
		isAuthenticated.set(true);
		pushSuccess(`Welcome back, ${result.data.email}!`);
		return true;
	}

	pushError('Login failed. Please check your credentials.');
	return false;
}

/**
 * Register new user
 */
export async function register(request: RegisterRequest): Promise<boolean> {
	const result = await api.request<User, User | null>(
		'/auth/register',
		currentUser,
		(user) => user,
		{
			method: 'POST',
			body: JSON.stringify(request)
		}
	);

	if (result && result.success && result.data) {
		isAuthenticated.set(true);
		pushSuccess(`Welcome, ${result.data.email}!`);
		return true;
	}

	pushError('Registration failed. Please try again.');
	return false;
}

/**
 * Logout user
 */
export async function logout(): Promise<void> {
	const result = await api.request<void>('/auth/logout', null, null, { method: 'POST' });

	if (result && result.success) {
		isAuthenticated.set(false);
		currentUser.set(null);
		pushSuccess('Logged out successfully');
	} else {
		pushError('Logout failed');
	}
}
