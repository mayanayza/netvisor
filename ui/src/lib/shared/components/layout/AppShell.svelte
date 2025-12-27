<script lang="ts">
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { Snippet } from 'svelte';
	import { queryClient, queryKeys } from '$lib/api/query-client';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { identifyUser, trackPlunkEvent } from '$lib/shared/utils/analytics';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { resolve } from '$app/paths';
	import { resetTopologyOptions } from '$lib/features/topology/store';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { config } from '$lib/shared/stores/config';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import { getRoute } from '$lib/shared/utils/navigation';
	import posthog from 'posthog-js';
	import { browser } from '$app/environment';
	import CookieConsent from '$lib/shared/components/feedback/CookieConsent.svelte';

	let { children }: { children: Snippet } = $props();

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);
	let isAuthenticated = $derived(currentUser != null);
	let isCheckingAuth = $derived(currentUserQuery.isPending);
	let authCheckComplete = $derived(!currentUserQuery.isPending);

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	// Track if we've done initial setup
	let hasInitialized = $state(false);
	let previouslyAuthenticated = $state<boolean | null>(null);

	// Effect to handle logout (clear data when user goes from authenticated to not)
	$effect(() => {
		if (authCheckComplete) {
			if (previouslyAuthenticated === true && !isAuthenticated) {
				// User logged out - clear data
				resetTopologyOptions();
				queryClient.clear();
			}
			previouslyAuthenticated = isAuthenticated;
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
		if (posthogInitialized && currentUser) {
			identifyUser(currentUser.id, currentUser.email, currentUser.organization_id);
		}
	});

	async function waitForBillingActivation(maxAttempts = 10) {
		for (let i = 0; i < maxAttempts; i++) {
			// Invalidate and refetch organization data
			await queryClient.invalidateQueries({ queryKey: queryKeys.organizations.current() });
			const orgData = queryClient.getQueryData<typeof organization>(
				queryKeys.organizations.current()
			);

			if (orgData && isBillingPlanActive(orgData)) {
				pushSuccess('Subscription activated successfully!');
				return true;
			}

			// Wait 2 seconds before next check
			await new Promise((r) => setTimeout(r, 2000));
		}

		pushError('Subscription is taking longer than expected to activate. Please refresh the page.');
		return false;
	}

	// Handle routing after auth check completes
	$effect(() => {
		if (!authCheckComplete || hasInitialized) return;
		if (!browser) return;

		hasInitialized = true;

		// Check for OIDC error in URL
		const error = $page.url.searchParams.get('error');
		if (error) {
			pushError(decodeURIComponent(error));
			const cleanUrl = new URL($page.url);
			cleanUrl.searchParams.delete('error');
			window.history.replaceState({}, '', cleanUrl.toString());
		}

		if (!isAuthenticated) {
			// Not authenticated - redirect to login/onboarding if not on public route
			const isPublicRoute =
				$page.url.pathname === '/auth' ||
				$page.url.pathname === '/login' ||
				$page.url.pathname === '/onboarding' ||
				$page.url.pathname.startsWith('/share/');

			if (!isPublicRoute) {
				const token = $page.url.searchParams.get('token');
				const isDemo = $page.url.hostname === 'demo.scanopy.net';
				if (token) {
					// eslint-disable-next-line svelte/no-navigation-without-resolve
					goto(`${resolve('/login')}?token=${token}`);
				} else if (isDemo) {
					goto(resolve('/login'));
				} else if (typeof localStorage !== 'undefined' && localStorage.getItem('hasAccount')) {
					goto(resolve('/login'));
				} else {
					// eslint-disable-next-line svelte/no-navigation-without-resolve
					goto(`${resolve('/onboarding')}${$page.url.search}`);
				}
			}
		} else {
			// Authenticated - handle Plunk tracking
			const pendingPlunk = sessionStorage.getItem('pendingPlunkRegistration');
			if (pendingPlunk && currentUser) {
				sessionStorage.removeItem('pendingPlunkRegistration');
				trackPlunkEvent('register', currentUser.email, pendingPlunk === 'true');
			}
		}
	});

	// Handle organization-dependent routing (runs after org data loads)
	$effect(() => {
		if (!authCheckComplete || !isAuthenticated || !browser) return;
		if (!organization) return;

		const sessionId = $page.url.searchParams.get('session_id');

		// Handle Stripe session callback (billing activation)
		if (sessionId && !isBillingPlanActive(organization)) {
			const cleanUrl = new URL($page.url);
			cleanUrl.searchParams.delete('session_id');
			window.history.replaceState({}, '', cleanUrl.toString());

			waitForBillingActivation().then((activated) => {
				if (activated) {
					const correctRoute = getRoute();
					// eslint-disable-next-line svelte/no-navigation-without-resolve
					goto(correctRoute);
				}
			});
			return;
		}

		// Check if current page matches where user should be
		const isSharePage = $page.url.pathname.startsWith('/share/');
		if (!isSharePage) {
			const correctRoute = getRoute();
			if ($page.url.pathname !== correctRoute) {
				// eslint-disable-next-line svelte/no-navigation-without-resolve
				goto(correctRoute);
			}
		}
	});
</script>

{#if isCheckingAuth}
	<div class="flex min-h-screen items-center justify-center bg-gray-900">
		<Loading />
	</div>
{:else}
	{@render children()}
{/if}

{#if $config && $config.needs_cookie_consent}
	<CookieConsent />
{/if}
