/**
 * TanStack Query hooks for Authentication
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
import { resetIdentity } from '$lib/shared/utils/analytics';
import type { User } from '../users/types';
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

/**
 * Query hook for fetching current authenticated user
 */
export function useCurrentUserQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.auth.currentUser(),
		queryFn: async () => {
			const { data } = await apiClient.POST('/api/auth/me', {});
			if (!data?.success || !data.data) {
				return null;
			}
			return data.data;
		},
		// Don't retry auth checks - if it fails, user is not authenticated
		retry: false,
		// Auth state should be checked frequently
		staleTime: 60 * 1000
	}));
}

/**
 * Mutation hook for logging in
 */
export function useLoginMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (request: LoginRequest) => {
			const { data } = await apiClient.POST('/api/auth/login', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Login failed. Please check your credentials.');
			}
			return data.data;
		},
		onSuccess: (user: User) => {
			queryClient.setQueryData(queryKeys.auth.currentUser(), user);
			// Mark that user has an account (for redirect logic after logout)
			if (typeof localStorage !== 'undefined') {
				localStorage.setItem('hasAccount', 'true');
			}
			pushSuccess(`Welcome back, ${user.email}!`);
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

/**
 * Mutation hook for registering
 */
export function useRegisterMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (request: RegisterRequest) => {
			const { data } = await apiClient.POST('/api/auth/register', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Registration failed. Please try again.');
			}
			return data.data;
		},
		onSuccess: (user: User) => {
			queryClient.setQueryData(queryKeys.auth.currentUser(), user);
			// Mark that user has an account (for redirect logic after logout)
			if (typeof localStorage !== 'undefined') {
				localStorage.setItem('hasAccount', 'true');
			}
			pushSuccess(`Welcome, ${user.email}!`);
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

/**
 * Mutation hook for logging out
 */
export function useLogoutMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async () => {
			const { data } = await apiClient.POST('/api/auth/logout', {});
			if (!data?.success) {
				throw new Error(data?.error || 'Logout failed');
			}
			return true;
		},
		onSuccess: () => {
			queryClient.setQueryData(queryKeys.auth.currentUser(), null);
			// Invalidate all queries on logout
			queryClient.clear();
			resetIdentity();
			pushSuccess('Logged out successfully');
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

/**
 * Mutation hook for forgot password
 */
export function useForgotPasswordMutation() {
	return createMutation(() => ({
		mutationFn: async (request: ForgotPasswordRequest) => {
			const { data } = await apiClient.POST('/api/auth/forgot-password', { body: request });
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to send password reset link');
			}
			return true;
		},
		onSuccess: () => {
			pushSuccess('Password reset link sent to your email');
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

/**
 * Mutation hook for reset password
 */
export function useResetPasswordMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (request: ResetPasswordRequest) => {
			const { data } = await apiClient.POST('/api/auth/reset-password', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to reset password');
			}
			return data.data;
		},
		onSuccess: (user: User) => {
			queryClient.setQueryData(queryKeys.auth.currentUser(), user);
			// Mark that user has an account (for redirect logic after logout)
			if (typeof localStorage !== 'undefined') {
				localStorage.setItem('hasAccount', 'true');
			}
			pushSuccess('Your password has been reset');
			pushSuccess(`Welcome, ${user.email}!`);
		}
	}));
}

/**
 * Mutation hook for pre-registration setup
 */
export function useSetupMutation() {
	return createMutation(() => ({
		mutationFn: async (request: SetupRequest) => {
			const { data } = await apiClient.POST('/api/auth/setup', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to save setup data');
			}
			return data.data as SetupResponse;
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

/**
 * Mutation hook for pre-registration daemon setup
 */
export function useDaemonSetupMutation() {
	return createMutation(() => ({
		mutationFn: async (request: DaemonSetupRequest) => {
			const { data } = await apiClient.POST('/api/auth/daemon-setup', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to save daemon setup');
			}
			return data.data as DaemonSetupResponse;
		},
		onError: (error: Error) => {
			pushError(error.message);
		}
	}));
}

// Helper to check if user is authenticated from query data
export function isAuthenticated(user: User | null | undefined): boolean {
	return user !== null && user !== undefined;
}
