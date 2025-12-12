<script lang="ts">
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import BillingPlanForm from '$lib/features/billing/BillingPlanForm.svelte';
	import type { BillingPlan } from '$lib/features/billing/types';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getConfig } from '$lib/shared/stores/config';
	import { getMetadata, billingPlans, features } from '$lib/shared/stores/metadata';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { getCurrentBillingPlans, currentPlans, checkout } from '$lib/features/billing/store';
	import { currentUser } from '$lib/features/auth/store';
	import { isCompanyEmail } from 'company-email-validator';

	const loading = loadData([getCurrentBillingPlans, getConfig, getMetadata], { loadingDelay: 0 });

	// Determine initial filter based on user email
	let companyEmail = $derived($currentUser ? isCompanyEmail($currentUser.email) : false);
	let initialPlanFilter = $derived<'commercial' | 'personal'>(
		companyEmail ? 'commercial' : 'personal'
	);

	async function handlePlanSelect(plan: BillingPlan) {
		const checkoutUrl = await checkout(plan);
		if (checkoutUrl) {
			window.location.href = checkoutUrl;
		}
	}
</script>

{#if $loading}
	<Loading />
{:else}
	<div class="relative min-h-screen bg-gray-900">
		<!-- Background image with overlay -->
		<div class="absolute inset-0 z-0">
			<div
				class="h-full w-full bg-cover bg-center bg-no-repeat"
				style="background-image: url('/images/diagram.png')"
			></div>
			<div class="absolute inset-0 bg-black/70"></div>
		</div>

		<!-- Content (sits above background) -->
		<div class="flex min-h-screen items-center justify-center">
			<div class="relative z-10 pt-10">
				<BillingPlanForm
					plans={$currentPlans}
					billingPlanHelpers={billingPlans}
					featureHelpers={features}
					onPlanSelect={handlePlanSelect}
					{initialPlanFilter}
				/>
			</div>
		</div>

		<Toast />
	</div>
{/if}
