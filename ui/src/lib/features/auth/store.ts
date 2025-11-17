import { writable } from 'svelte/store';
import { api, getServerUrl } from '../../shared/utils/api';
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

	const result = await api.request<User, User | null>(
		'/auth/me',
		currentUser,
		(user) => user,
		{ method: 'POST' },
		true
	);

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
export async function login(request: LoginRequest): Promise<User | null> {
	const result = await api.request<User, User | null>('/auth/login', currentUser, (user) => user, {
		method: 'POST',
		body: JSON.stringify(request)
	});

	if (result && result.success && result.data != undefined) {
		isAuthenticated.set(true);
		pushSuccess(`Welcome back, ${result.data.email}!`);
		return result.data;
	}

	pushError('Login failed. Please check your credentials.');
	return null;
}

/**
 * Register new user
 */
export async function register(request: RegisterRequest): Promise<User | null> {
	const result = await api.request<User, User | null>(
		'/auth/register',
		currentUser,
		(user) => user,
		{
			method: 'POST',
			body: JSON.stringify(request)
		}
	);

	if (result && result.success && result.data != undefined) {
		isAuthenticated.set(true);
		pushSuccess(`Welcome, ${result.data.email}!`);
		return result.data;
	}

	pushError('Registration failed. Please try again.');
	return null;
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

/**
 * Forgot password
 */
export async function forgotPassword(email: string): Promise<void> {
	const result = await api.request<void>('/auth/forgot-password', null, null, {
		method: 'POST',
		body: JSON.stringify({ email, url: getServerUrl() })
	});

	if (result && result.success) {
		isAuthenticated.set(false);
		currentUser.set(null);
		pushSuccess('Logged out successfully');
	} else {
		pushError('Logout failed');
	}
}

/**
 * Reset password
 */
export async function resetPassword(password: string, token: string): Promise<void> {
	const result = await api.request<void>('/auth/reset-password', null, null, {
		method: 'POST',
		body: JSON.stringify({ password, token })
	});

	if (result && result.success) {
		isAuthenticated.set(false);
		currentUser.set(null);
		pushSuccess('Logged out successfully');
	} else {
		pushError('Logout failed');
	}
}
