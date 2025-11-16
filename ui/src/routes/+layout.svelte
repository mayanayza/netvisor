<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import type { Snippet } from 'svelte';
	import { checkAuth, isCheckingAuth, isAuthenticated } from '$lib/features/auth/store';
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
	import { getMetadata } from '$lib/shared/stores/metadata';
	import { getOrganization, organization } from '$lib/features/organizations/store';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import { getCurrentBillingPlans } from '$lib/features/billing/store';

	// Accept children as a snippet prop
	let { children }: { children: Snippet } = $props();

	// Reactive values from stores
	let billingEnabled = $derived($config ? $config.billing_enabled : false);

	// Effect to reset data when user logs out
	$effect(() => {
		if (!$isAuthenticated) {
			resetTopologyOptions();
			hosts.set([]);
			services.set([]);
			subnets.set([]);
			groups.set([]);
			networks.set([]);
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
		await getOrganization();
		const sessionId = $page.url.searchParams.get('session_id');

		// Check for OIDC error in URL
		const error = $page.url.searchParams.get('error');
		if (error) {
			pushError(decodeURIComponent(error));

			// Clean up URL
			const cleanUrl = new URL($page.url);
			cleanUrl.searchParams.delete('error');
			window.history.replaceState({}, '', cleanUrl.toString());
		}

		// Check authentication status and get public server config
		await Promise.all([checkAuth(), getConfig(), getMetadata()]);

		// Redirect to auth page if not authenticated and not already there
		if (!$isAuthenticated) {
			if ($page.url.pathname !== '/auth') {
				// eslint-disable-next-line svelte/no-navigation-without-resolve
				await goto(`${resolve('/auth')}${$page.url.search}`);
			}
		} else {
			if ($organization) {
				// Check onboarding - don't redirect if already on onboarding page
				if (!$organization.is_onboarded) {
					if ($page.url.pathname !== '/onboarding') {
						await goto(resolve('/onboarding'));
					}
					return; // Stop here regardless of whether we redirected or not
				}

				// Only check billing if onboarded
				if (!billingEnabled) {
					if ($page.url.pathname !== '/') {
						await goto(resolve('/'));
					}
					return;
				}

				// Billing logic (only runs if onboarded)
				if (sessionId && !isBillingPlanActive($organization)) {
					// Clean up URL first
					const cleanUrl = new URL($page.url);
					cleanUrl.searchParams.delete('session_id');
					window.history.replaceState({}, '', cleanUrl.toString());

					// Poll for webhook to complete
					const activated = await waitForBillingActivation();
					if (activated) {
						await goto(resolve('/'));
						return;
					}
				} else if (isBillingPlanActive($organization)) {
					if ($page.url.pathname === '/billing') {
						await goto(resolve('/'));
					}
				} else if (!isBillingPlanActive($organization)) {
					if ($page.url.pathname !== '/billing') {
						await getCurrentBillingPlans();
						await goto(resolve('/billing'));
					}
				}
			} else {
				pushError('Failed to load organization. Please refresh the page.');
			}
		}
	});
</script>

{#if $isCheckingAuth}
	<div class="flex min-h-screen items-center justify-center bg-gray-900">
		<Loading />
	</div>
{:else}
	{@render children()}
{/if}
