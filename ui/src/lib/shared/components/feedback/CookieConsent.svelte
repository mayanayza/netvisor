<script lang="ts">
	import '@beyonk/gdpr-cookie-consent-banner/banner.css';
	import GdprBanner from '@beyonk/gdpr-cookie-consent-banner';
	import posthog from 'posthog-js';
	import { dev } from '$app/environment';

	function handleAnalytics(event: CustomEvent<{ agreed: boolean }>) {
		if (posthog.__loaded) {
			if (event.detail.agreed) {
				posthog.opt_in_capturing();
			} else {
				posthog.opt_out_capturing();
			}
		}
	}
</script>

<GdprBanner
	cookieName="netvisor_gdpr"
	heading="Cookie Settings"
	description="We use cookies to offer a better browsing experience and analyze site traffic. Please review our <a href='/privacy'>privacy policy page</a>. By clicking accept, you consent to our privacy policy & use of cookies."
	on:analytics={handleAnalytics}
	cookieConfig={dev ? {} : { domain: '.netvisor.io' }}
	canRejectCookies={true}
	rejectLabel="Reject"
	on:all={handleAnalytics}
	acceptAllLabel="Accept All"
	acceptSelectedLabel="Accept"
	choices={{
		necessary: {
			label: 'Necessary cookies',
			description: "Used for basic functionality. Can't be turned off.",
			value: true
		},
		tracking: false,
		analytics: {
			label: 'Analytics cookies',
			description: 'Used for analyitcs tools that track user behavior.',
			value: true
		},
		marketing: false
	}}
/>

<style>
	/* Banner wrapper - bottom bar */
	:global(.cookieConsentWrapper) {
		background: #1f2937;
		border-top: 1px solid #374151;
		padding: 1.5rem;
	}

	/* Floating toggle button */
	:global(.cookieConsentToggle) {
		background: #1f2937;
		border: 1px solid #374151;
		color: #9ca3af;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
	}

	:global(.cookieConsentToggle:hover) {
		background: #374151;
		color: white;
	}

	/* Main buttons */
	:global(.cookieConsent__Button) {
		background: #1d4ed8;
		color: white;
		border: 1px solid #2563eb;
		border-radius: 0.375rem;
		padding: 0.5rem 1rem;
		font-weight: 500;
		transition:
			background-color 150ms,
			border-color 150ms;
	}

	:global(.cookieConsent__Button:hover) {
		background: #2563eb;
		border-color: #3b82f6;
		opacity: 1;
	}

	/* Secondary/settings button style */
	:global(.cookieConsent__Button:first-of-type) {
		background: transparent;
		border: 1px solid #374151;
		color: #9ca3af;
	}

	:global(.cookieConsent__Button:first-of-type:hover) {
		background: #1f2937;
		border-color: #4b5563;
		color: #e5e7eb;
	}

	/* Settings modal overlay */
	:global(.cookieConsentOperations) {
		background: rgba(0, 0, 0, 0.7);
		backdrop-filter: blur(4px);
	}

	/* Settings modal content */
	:global(.cookieConsentOperations__List) {
		background: #111827;
		color: white;
		border: 1px solid #374151;
		border-radius: 0.5rem;
		box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
	}

	/* Reduce padding since checkbox is smaller */
	:global(.cookieConsentOperations__Item) {
		padding-left: 36px;
	}

	/* Checkbox box */
	:global(.cookieConsentOperations__Item label::before) {
		width: 1rem;
		height: 1rem;
		border-radius: 0.25rem;
		background: #374151;
		border: 1px solid #4b5563;
		left: -36px;
		top: 50%;
		transform: translateY(-50%);
	}

	/* Hide the default toggle thumb entirely */
	:global(.cookieConsentOperations__Item label::after) {
		display: none;
	}

	/* Checkbox checked state - blue background with checkmark */
	:global(.cookieConsentOperations__Item input:checked + label::before) {
		background: #2563eb
			url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z'/%3e%3c/svg%3e")
			center/80% no-repeat;
		border-color: #2563eb;
	}

	/* Disabled item - grayed out appearance */
	:global(.cookieConsentOperations__Item.disabled) {
		color: #6b7280;
		cursor: not-allowed;
	}

	:global(.cookieConsentOperations__Item.disabled label::before) {
		background: #4b5563
			url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z'/%3e%3c/svg%3e")
			center/80% no-repeat;
		border-color: #4b5563;
		opacity: 0.6;
	}

	/* Close button in modal */
	:global(.cookieConsent__Button--Close) {
		background: #1d4ed8;
		color: white;
		border: 1px solid #2563eb;
		border-radius: 0.375rem;
	}

	:global(.cookieConsent__Button--Close:hover) {
		background: #2563eb;
		border-color: #3b82f6;
	}

	/* Description text */
	:global(.cookieConsent__Description) {
		color: #9ca3af;
	}

	/* Title text */
	:global(.cookieConsent__Title) {
		color: white;
	}

	/* Item description in modal */
	:global(.cookieConsentOperations__Item span) {
		color: #9ca3af;
		font-size: 0.875rem;
	}
</style>
