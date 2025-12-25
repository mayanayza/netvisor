import { writable } from 'svelte/store';
import { apiClient } from '$lib/api/client';
import type {
	DaemonSetupRequest,
	DaemonSetupResponse,
	ForgotPasswordRequest,
	LoginRequest,
	RegisterRequest,
	ResetPasswordRequest,
	SetupRequest,
	SetupResponse
} from './types/base';
import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
import type { User } from '../users/types';
import { resetIdentity } from '$lib/shared/utils/analytics';

export const currentUser = writable<User | null>(null);
export const isAuthenticated = writable<boolean>(false);
export const isCheckingAuth = writable<boolean>(true);

/**
 * Check if user is authenticated by fetching current session
 */
export async function checkAuth(): Promise<boolean> {
	isCheckingAuth.set(true);

	const { data: result } = await apiClient.POST('/api/auth/me', {});

	if (result?.success && result.data) {
		currentUser.set(result.data);
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
	const { data: result } = await apiClient.POST('/api/auth/login', { body: request });

	if (result?.success && result.data) {
		currentUser.set(result.data);
		isAuthenticated.set(true);
		// Mark that user has an account (for redirect logic after logout)
		if (typeof localStorage !== 'undefined') {
			localStorage.setItem('hasAccount', 'true');
		}
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
	const { data: result } = await apiClient.POST('/api/auth/register', { body: request });

	if (result?.success && result.data) {
		currentUser.set(result.data);
		isAuthenticated.set(true);
		// Mark that user has an account (for redirect logic after logout)
		if (typeof localStorage !== 'undefined') {
			localStorage.setItem('hasAccount', 'true');
		}
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
	const { data: result } = await apiClient.POST('/api/auth/logout', {});

	if (result?.success) {
		isAuthenticated.set(false);
		currentUser.set(null);
		resetIdentity();
		pushSuccess('Logged out successfully');
	} else {
		pushError('Logout failed');
	}
}

/**
 * Forgot password
 */
export async function forgotPassword(request: ForgotPasswordRequest): Promise<void> {
	const { data: result } = await apiClient.POST('/api/auth/forgot-password', { body: request });

	if (result?.success) {
		pushSuccess('Password reset link sent to your email');
	} else {
		pushError('Failed to send password reset link');
	}
}

/**
 * Reset password
 */
export async function resetPassword(request: ResetPasswordRequest): Promise<User | null> {
	const { data: result } = await apiClient.POST('/api/auth/reset-password', { body: request });

	if (result?.success && result.data) {
		currentUser.set(result.data);
		isAuthenticated.set(true);
		// Mark that user has an account (for redirect logic after logout)
		if (typeof localStorage !== 'undefined') {
			localStorage.setItem('hasAccount', 'true');
		}
		pushSuccess('Your password has been reset');
		pushSuccess(`Welcome, ${result.data.email}!`);
		return result.data;
	}
	return null;
}

/**
 * Submit pre-registration setup data (org name, network name, seed preference)
 * This is stored in session and applied during registration
 * Returns the provisional network ID to use for daemon setup
 */
export async function submitSetup(request: SetupRequest): Promise<SetupResponse | null> {
	const { data: result } = await apiClient.POST('/api/auth/setup', { body: request });

	if (result?.success && result.data) {
		return result.data;
	}

	pushError('Failed to save setup data');
	return null;
}

/**
 * Submit pre-registration daemon setup data
 * Returns the provisional API key to show to user for installation
 */
export async function submitDaemonSetup(
	request: DaemonSetupRequest
): Promise<DaemonSetupResponse | null> {
	const { data: result } = await apiClient.POST('/api/auth/daemon-setup', { body: request });

	if (result?.success && result.data) {
		return result.data;
	}

	pushError('Failed to save daemon setup');
	return null;
}
