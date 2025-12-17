<script lang="ts">
	import posthog from 'posthog-js';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import BillingPlanForm from '$lib/features/billing/BillingPlanForm.svelte';
	import type { BillingPlan } from '$lib/features/billing/types';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { getMetadata, billingPlans, features } from '$lib/shared/stores/metadata';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { getCurrentBillingPlans, currentPlans, checkout } from '$lib/features/billing/store';
	import { onboardingStore } from '$lib/features/auth/stores/onboarding';
	import { currentUser } from '$lib/features/auth/store';
	import { pushSuccess, pushError } from '$lib/shared/stores/feedback';

	const loading = loadData([getCurrentBillingPlans, getConfig, getMetadata], { loadingDelay: 0 });

	// Determine initial filter based on use case from onboarding
	// homelab = personal, company/msp = commercial
	let useCase = $derived($onboardingStore.useCase);
	let networkCount = $derived($onboardingStore.networks.length);

	// If user has > 3 networks, they must use commercial plans
	let forceCommercial = $derived(networkCount > 3);

	let initialPlanFilter = $derived<'commercial' | 'personal'>(
		forceCommercial || useCase === 'company' || useCase === 'msp' ? 'commercial' : 'personal'
	);

	// Recommended plan based on use case
	// company → Team, msp → Business
	let recommendedPlan = $derived<string | null>(
		useCase === 'company' ? 'Team' : useCase === 'msp' ? 'Business' : null
	);

	async function handlePlanSelect(plan: BillingPlan) {
		const checkoutUrl = await checkout(plan);
		if (checkoutUrl) {
			window.location.href = checkoutUrl;
		}
	}

	async function handleEnterpriseInquiry() {
		const plunkKey = $config?.plunk_key;
		if (!plunkKey) {
			pushError('Unable to send inquiry. Please contact enterprise@scanopy.net directly.');
			return;
		}

		const user = $currentUser;
		if (!user) {
			pushError('Unable to send inquiry. Please try again.');
			return;
		}

		try {
			// Get PostHog distinct ID
			const posthogId = posthog.__loaded ? posthog.get_distinct_id() : null;

			// Send enterprise inquiry via Plunk
			await fetch('https://next-api.useplunk.com/v1/track', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${plunkKey}`
				},
				body: JSON.stringify({
					event: 'enterprise_inquiry',
					email: 'enterprise@scanopy.net',
					subscribed: false,
					data: {
						user_email: user.email,
						organization_id: user.organization_id,
						use_case: useCase,
						posthog_id: posthogId
					}
				})
			});

			pushSuccess("We'll reach out shortly to discuss our Enterprise plan!");
		} catch (error) {
			console.error('Failed to send enterprise inquiry:', error);
			pushError('Unable to send inquiry. Please contact enterprise@scanopy.net directly.');
		}
	}
</script>

{#if $loading}
	<Loading />
{:else}
	<div class="relative min-h-dvh bg-gray-900">
		<!-- Background image with overlay -->
		<div class="absolute inset-0 z-0">
			<div
				class="h-full w-full bg-cover bg-center bg-no-repeat"
				style="background-image: url('/images/diagram.png')"
			></div>
			<div class="absolute inset-0 bg-black/70"></div>
		</div>

		<!-- Content (sits above background) -->
		<section class="py-10 pb-24 lg:pb-10">
			<div class="container mx-auto px-2">
				<BillingPlanForm
					plans={$currentPlans}
					billingPlanHelpers={billingPlans}
					featureHelpers={features}
					onPlanSelect={handlePlanSelect}
					onEnterpriseInquiry={handleEnterpriseInquiry}
					{initialPlanFilter}
					{recommendedPlan}
					{forceCommercial}
				/>
			</div>
		</section>

		<Toast />
	</div>
{/if}
