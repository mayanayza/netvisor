<script lang="ts">
	import posthog from 'posthog-js';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import BillingPlanForm from '$lib/features/billing/BillingPlanForm.svelte';
	import type { BillingPlan } from '$lib/features/billing/types';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { config } from '$lib/shared/stores/config';
	import { getMetadata, billingPlans, features } from '$lib/shared/stores/metadata';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { useBillingPlansQuery, useCheckoutMutation } from '$lib/features/billing/queries';
	import { onboardingStore } from '$lib/features/auth/stores/onboarding';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { pushSuccess, pushError } from '$lib/shared/stores/feedback';
	import PlanInquiryModal from '$lib/features/billing/PlanInquiryModal.svelte';

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	// TanStack Query for billing plans
	const billingPlansQuery = useBillingPlansQuery();
	const checkoutMutation = useCheckoutMutation();
	let plansData = $derived(billingPlansQuery.data ?? []);

	// Load metadata (billing plans are loaded via TanStack Query)
	const loading = loadData([getMetadata], { loadingDelay: 0 });
	let isLoading = $derived($loading || billingPlansQuery.isPending);

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
		try {
			const checkoutUrl = await checkoutMutation.mutateAsync(plan);
			if (checkoutUrl) {
				window.location.href = checkoutUrl;
			}
		} catch {
			// Error handled by mutation
		}
	}

	// Plan inquiry modal state
	let inquiryModalOpen = $state(false);
	let selectedPlan = $state<BillingPlan | null>(null);

	function handlePlanInquiry(plan: BillingPlan) {
		selectedPlan = plan;
		inquiryModalOpen = true;
	}

	async function handleInquirySubmit(email: string, message: string) {
		const plunkKey = $config?.plunk_key;
		if (!plunkKey) {
			pushError('Unable to send inquiry. Please contact sales@scanopy.net directly.');
			return;
		}

		try {
			const posthogId = posthog.__loaded ? posthog.get_distinct_id() : null;

			await fetch('https://next-api.useplunk.com/v1/track', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json',
					Authorization: `Bearer ${plunkKey}`
				},
				body: JSON.stringify({
					event: 'plan_inquiry',
					email: 'sales@scanopy.net',
					subscribed: false,
					data: {
						user_email: email,
						organization_id: currentUser?.organization_id,
						plan_type: selectedPlan?.type,
						message,
						use_case: useCase,
						posthog_id: posthogId
					}
				})
			});

			pushSuccess("Thanks for your interest! We'll be in touch soon.");
		} catch (error) {
			console.error('Failed to send plan inquiry:', error);
			pushError('Unable to send inquiry. Please contact sales@scanopy.net directly.');
		}
	}
</script>

{#if isLoading}
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
					plans={plansData}
					billingPlanHelpers={billingPlans}
					featureHelpers={features}
					onPlanSelect={handlePlanSelect}
					onPlanInquiry={handlePlanInquiry}
					{initialPlanFilter}
					{recommendedPlan}
					{forceCommercial}
				/>
			</div>
		</section>

		<Toast />

		<PlanInquiryModal
			isOpen={inquiryModalOpen}
			planName={selectedPlan ? billingPlans.getName(selectedPlan.type) : ''}
			userEmail={currentUser?.email ?? ''}
			onClose={() => (inquiryModalOpen = false)}
			onSubmit={handleInquirySubmit}
		/>
	</div>
{/if}
