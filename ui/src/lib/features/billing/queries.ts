/**
 * TanStack Query hooks for Billing
 */

import { createQuery, createMutation } from '@tanstack/svelte-query';
import { queryKeys } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { BillingPlan } from './types';
import { pushError } from '$lib/shared/stores/feedback';

/**
 * Query hook for fetching current billing plans
 */
export function useBillingPlansQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.billing.plans(),
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/billing/plans');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch billing plans');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for checkout
 */
export function useCheckoutMutation() {
	return createMutation(() => ({
		mutationFn: async (plan: BillingPlan) => {
			const { data } = await apiClient.POST('/api/billing/checkout', {
				body: { plan, url: window.location.origin }
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to get checkout URL');
			}
			return data.data;
		},
		onError: (error: Error) => {
			pushError(`Error getting checkout URL: ${error.message}. Please try again.`);
		}
	}));
}

/**
 * Mutation hook for opening customer portal
 */
export function useCustomerPortalMutation() {
	return createMutation(() => ({
		mutationFn: async () => {
			const { data } = await apiClient.POST('/api/billing/portal', {
				body: window.location.origin
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to get billing portal URL');
			}
			return data.data;
		},
		onError: (error: Error) => {
			pushError(`Error getting billing portal URL: ${error.message}. Please try again.`);
		}
	}));
}
