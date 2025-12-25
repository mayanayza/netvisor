<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { Snippet } from 'svelte';
	import { QueryClientProvider } from '@tanstack/svelte-query';
	import { queryClient } from '$lib/api/query-client';
	import {
		checkAuth,
		isCheckingAuth,
		isAuthenticated,
		currentUser
	} from '$lib/features/auth/store';
	import { identifyUser, trackPlunkEvent } from '$lib/shared/utils/analytics';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import '../app.css';
	import { resolve } from '$app/paths';
	import { resetTopologyOptions } from '$lib/features/topology/store';
	import { hosts } from '$lib/features/hosts/store';
	import { services } from '$lib/features/services/store';
	import { groups } from '$lib/features/groups/store';
	import { networks } from '$lib/features/networks/store';
	import { subnets } from '$lib/features/subnets/store';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { getOrganization, organization } from '$lib/features/organizations/store';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import { getRoute } from '$lib/shared/utils/navigation';
	import { apiKeys } from '$lib/features/api_keys/store';
	import { daemons } from '$lib/features/daemons/store';
	import posthog from 'posthog-js';
	import { browser } from '$app/environment';
	import CookieConsent from '$lib/shared/components/feedback/CookieConsent.svelte';

	// Accept children as a snippet prop
	let { children }: { children: Snippet } = $props();

	// Effect to reset data when user logs out
	$effect(() => {
		if (!$isAuthenticated) {
			resetTopologyOptions();
			hosts.set([]);
			services.set([]);
			subnets.set([]);
			groups.set([]);
			organization.set(null);
			apiKeys.set([]);
			daemons.set([]);
			networks.set([]);
		}
	});

	let posthogInitialized = false;

	$effect(() => {
		if (!$config) return;

		const posthogKey = $config.posthog_key;

		if (browser && posthogKey && !posthogInitialized) {
			posthog.init(posthogKey, {
				api_host: 'https://ph.scanopy.net',
				ui_host: 'https://us.posthog.com',
				defaults: '2025-11-30',
				secure_cookie: true,
				persistence: 'memory',
				opt_out_capturing_by_default: true
			});
			posthogInitialized = true;
		}
	});

	// Identify user in PostHog when authenticated (skipped in demo mode by identifyUser)
	$effect(() => {
		if (posthogInitialized && $currentUser) {
			identifyUser($currentUser.id, $currentUser.email, $currentUser.organization_id);
		}
	});

	async function waitForBillingActivation(maxAttempts = 10) {
		for (let i = 0; i < maxAttempts; i++) {
			const organization = await getOrganization();

			if (organization && isBillingPlanActive(organization)) {
				pushSuccess('Subscription activated successfully!');
				return true;
			}

			// Wait 2 seconds before next check
			await new Promise((resolve) => setTimeout(resolve, 2000));
		}

		pushError('Subscription is taking longer than expected to activate. Please refresh the page.');
		return false;
	}

	onMount(async () => {
		const sessionId = $page.url.searchParams.get('session_id');

		// Check for OIDC error in URL
		const error = $page.url.searchParams.get('error');
		if (error) {
			pushError(decodeURIComponent(error));
			const cleanUrl = new URL($page.url);
			cleanUrl.searchParams.delete('error');
			window.history.replaceState({}, '', cleanUrl.toString());
		}

		// Check authentication status and get public server config
		await Promise.all([checkAuth(), getConfig()]);

		// Redirect if not authenticated and not on an auth/public route
		if (!$isAuthenticated) {
			const isPublicRoute =
				$page.url.pathname === '/auth' ||
				$page.url.pathname === '/login' ||
				$page.url.pathname === '/onboarding' ||
				$page.url.pathname.startsWith('/share/');

			if (!isPublicRoute) {
				// Check for password reset token - redirect to login with token
				const token = $page.url.searchParams.get('token');
				const isDemo = $page.url.hostname === 'demo.scanopy.net';
				if (token) {
					// eslint-disable-next-line svelte/no-navigation-without-resolve
					await goto(`${resolve('/login')}?token=${token}`);
				} else if (isDemo) {
					// Demo mode - redirect to login
					await goto(resolve('/login'));
				} else if (typeof localStorage !== 'undefined' && localStorage.getItem('hasAccount')) {
					// Returning user (has logged in before) - redirect to login
					await goto(resolve('/login'));
				} else {
					// New user - redirect to onboarding
					// eslint-disable-next-line svelte/no-navigation-without-resolve
					await goto(`${resolve('/onboarding')}${$page.url.search}`);
				}
			}
		} else {
			// Check for pending Plunk tracking after OIDC registration
			const pendingPlunk = sessionStorage.getItem('pendingPlunkRegistration');
			if (pendingPlunk && $currentUser) {
				sessionStorage.removeItem('pendingPlunkRegistration');
				trackPlunkEvent('register', $currentUser.email, pendingPlunk === 'true');
			}

			await getOrganization();

			if ($organization) {
				// Handle Stripe session callback (billing activation)
				if (sessionId && !isBillingPlanActive($organization)) {
					const cleanUrl = new URL($page.url);
					cleanUrl.searchParams.delete('session_id');
					window.history.replaceState({}, '', cleanUrl.toString());

					const activated = await waitForBillingActivation();
					if (activated) {
						const correctRoute = getRoute();
						// eslint-disable-next-line svelte/no-navigation-without-resolve
						await goto(correctRoute);
						return;
					}
				}

				// Check if current page matches where user should be
				// Skip redirect for public share pages - authenticated users can still view them
				const isSharePage = $page.url.pathname.startsWith('/share/');
				if (!isSharePage) {
					const correctRoute = getRoute();
					if ($page.url.pathname !== correctRoute) {
						// eslint-disable-next-line svelte/no-navigation-without-resolve
						await goto(correctRoute);
					}
				}
			} else {
				pushError('Failed to load organization. Please refresh the page.');
			}
		}
	});
</script>

<QueryClientProvider client={queryClient}>
	{#if $isCheckingAuth}
		<div class="flex min-h-screen items-center justify-center bg-gray-900">
			<Loading />
		</div>
	{:else}
		{@render children()}
	{/if}

	{#if $config && $config.needs_cookie_consent}
		<CookieConsent />
	{/if}
</QueryClientProvider>
