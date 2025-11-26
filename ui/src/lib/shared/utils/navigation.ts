import { goto } from '$app/navigation';
import { resolve } from '$app/paths';
import { get } from 'svelte/store';
import { organization } from '$lib/features/organizations/store';
import { config } from '$lib/shared/stores/config';
import { isBillingPlanActive } from '$lib/features/organizations/types';

/**
 * Determines the correct route for an authenticated user based on their state
 */
export function getRoute(): string {
	const $organization = get(organization);
	const $config = get(config);

	if (!$organization) {
		return resolve('/auth');
	}

	// Check onboarding first
	if (!$organization.is_onboarded) {
		return resolve('/onboarding');
	}

	// Check billing if enabled
	const billingEnabled = $config?.billing_enabled ?? false;
	if (billingEnabled && !isBillingPlanActive($organization)) {
		return resolve('/billing');
	}

	// All checks passed - go to main app
	return resolve('/');
}

/**
 * Navigate to the appropriate route after authentication
 */
export async function navigate(): Promise<void> {
	const route = getRoute();
	// eslint-disable-next-line svelte/no-navigation-without-resolve
	await goto(route);
}
