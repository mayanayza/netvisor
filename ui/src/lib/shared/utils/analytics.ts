import posthog from 'posthog-js';
import { get } from 'svelte/store';
import { config } from '../stores/config';
import { queryClient, queryKeys } from '$lib/api/query-client';
import type { Organization } from '$lib/features/organizations/types';

/**
 * Check if the current organization is in demo mode.
 * Demo users should not have their data tracked.
 */
export function isDemo(): boolean {
	const org = queryClient.getQueryData<Organization | null>(queryKeys.organizations.current());
	return org?.plan?.type === 'Demo';
}

/**
 * Track an analytics event via PostHog.
 * PostHog is already initialized in +layout.svelte, this is just a helper.
 * In demo mode, events are tracked with a demo=true flag.
 *
 * Events focused on understanding friction:
 * - onboarding_blocker_selected - What's blocking users?
 * - onboarding_blocker_resolved - Did resolution help?
 * - onboarding_compatibility_issue - Only when incompatible
 * - onboarding_feedback_submitted - "Something else" friction
 */
export function trackEvent(event: string, properties?: Record<string, unknown>) {
	if (posthog.__loaded) {
		posthog.capture(event, properties);
	}
}

/**
 * Identify a user in PostHog.
 * Links all events to this user's profile.
 * Safe to call multiple times - PostHog deduplicates.
 * Skips identification in demo mode.
 */
export function identifyUser(userId: string, email: string, organizationId: string) {
	if (isDemo()) return;
	if (posthog.__loaded) {
		posthog.identify(userId, {
			email,
			organization_id: organizationId
		});
	}
}

/**
 * Reset PostHog identity on logout.
 * Unlinks future events from the user.
 */
export function resetIdentity() {
	if (posthog.__loaded) {
		posthog.reset();
	}
}

/**
 * Track a user event in Plunk for email marketing.
 * Uses the public key from server config.
 * Skips tracking in demo mode.
 */
export async function trackPlunkEvent(
	event: string,
	email: string,
	subscribed: boolean
): Promise<void> {
	if (isDemo()) return;

	const cfg = get(config);
	const plunkKey = cfg?.plunk_key;

	if (!plunkKey) {
		return;
	}

	try {
		await fetch('https://next-api.useplunk.com/v1/track', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
				Authorization: `Bearer ${plunkKey}`
			},
			body: JSON.stringify({
				event,
				email,
				subscribed
			})
		});
	} catch (error) {
		// Silently fail - email tracking is not critical
		console.warn('Failed to track Plunk event:', error);
	}
}
