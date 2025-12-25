import { apiClient } from '$lib/api/client';
import { writable } from 'svelte/store';
import type { BillingPlan } from './types';
import { pushError } from '$lib/shared/stores/feedback';

export const currentPlans = writable<BillingPlan[]>([]);

export async function getCurrentBillingPlans(): Promise<BillingPlan[]> {
	const { data } = await apiClient.GET('/api/billing/plans');
	if (data?.success && data.data) {
		currentPlans.set(data.data);
		return data.data;
	}
	return [];
}

export async function checkout(plan: BillingPlan): Promise<string | null> {
	const { data: result } = await apiClient.POST('/api/billing/checkout', {
		body: { plan, url: window.location.origin }
	});

	if (result?.success && result.data) {
		return result.data;
	}
	pushError(`Error getting checkout URL: ${result?.error}. Please try again.`);
	return null;
}

export async function openCustomerPortal(): Promise<string | null> {
	const { data: result } = await apiClient.POST('/api/billing/portal', {
		body: window.location.origin
	});

	if (result?.success && result.data) {
		return result.data;
	}
	pushError(`Error getting billing portal URL: ${result?.error}. Please try again.`);
	return null;
}
