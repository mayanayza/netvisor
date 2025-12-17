import posthog from 'posthog-js';

/**
 * Track an analytics event via PostHog.
 * PostHog is already initialized in +layout.svelte, this is just a helper.
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
