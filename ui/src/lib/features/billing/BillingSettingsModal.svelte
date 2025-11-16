<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { CreditCard, CheckCircle, AlertCircle } from 'lucide-svelte';
	import { organization, getOrganization } from '$lib/features/organizations/store';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import { currentUser } from '$lib/features/auth/store';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import { openCustomerPortal } from './store';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';

	export let isOpen = false;
	export let onClose: () => void;

	$: if (isOpen && $currentUser) {
		loadOrganization();
	}

	async function loadOrganization() {
		if (!$currentUser) return;
		await getOrganization();
	}

	$: org = $organization;
	$: planActive = org ? isBillingPlanActive(org) : false;

	function formatPlanStatus(status: string): string {
		return status.charAt(0).toUpperCase() + status.slice(1);
	}

	function getPlanStatusColor(status: string): string {
		switch (status.toLowerCase()) {
			case 'active':
				return 'text-green-400';
			case 'trialing':
				return 'text-blue-400';
			case 'past_due':
			case 'unpaid':
				return 'text-red-400';
			case 'canceled':
			case 'incomplete':
				return 'text-yellow-400';
			default:
				return 'text-gray-400';
		}
	}

	async function handleManageSubscription() {
		const url = await openCustomerPortal();
		if (url) {
			window.location.href = url;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Billing"
	showSave={false}
	showCancel={true}
	cancelLabel="Close"
	onCancel={onClose}
	size="md"
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={CreditCard} color="#3b82f6" />
	</svelte:fragment>

	{#if org}
		<div class="space-y-6">
			<!-- Current Plan -->
			<InfoCard>
				<svelte:fragment slot="default">
					<div class="mb-3 flex items-center justify-between">
						<h3 class="text-primary text-sm font-semibold">Current Plan</h3>
						<div class="flex items-center gap-2">
							{#if planActive}
								<CheckCircle class="h-4 w-4 text-green-400" />
							{:else}
								<AlertCircle class="h-4 w-4 text-yellow-400" />
							{/if}
							<span class={`text-sm font-medium ${getPlanStatusColor(org.plan_status)}`}>
								{formatPlanStatus(org.plan_status)}
							</span>
						</div>
					</div>

					<div class="space-y-3">
						<div class="flex items-baseline justify-between">
							<div>
								<p class="text-primary text-lg font-semibold">
									{billingPlans.getName(org.plan.type)}
								</p>
								{#if org.plan.trial_days > 0 && org.plan_status === 'trialing'}
									<p class="text-secondary mt-1 text-xs">
										Includes {org.plan.trial_days}-day free trial
									</p>
								{/if}
							</div>
							<div class="text-right">
								<p class="text-primary text-2xl font-bold">
									${org.plan.price.cents / 100}
								</p>
								<p class="text-secondary text-xs">per {org.plan.price.rate}</p>
							</div>
						</div>

						{#if org.plan_status === 'trialing'}
							<div
								class="rounded-md border border-blue-800 bg-blue-900/30 p-3 text-sm text-blue-300"
							>
								Your trial is active. You won't be charged until your trial ends.
							</div>
						{:else if org.plan_status === 'past_due'}
							<div class="rounded-md border border-red-800 bg-red-900/30 p-3 text-sm text-red-300">
								Your payment is past due. Please update your payment method to continue using
								NetVisor.
							</div>
						{:else if org.plan_status === 'canceled'}
							<div
								class="rounded-md border border-yellow-800 bg-yellow-900/30 p-3 text-sm text-yellow-300"
							>
								Your subscription has been canceled. Access will end at the end of your billing
								period.
							</div>
						{/if}
					</div>
				</svelte:fragment>
			</InfoCard>

			<!-- Actions -->
			<div class="space-y-3">
				<button on:click={handleManageSubscription} class="btn-primary w-full">
					Manage Subscription
				</button>
			</div>

			<!-- Additional Info -->
			<InfoCard title="Need Help?">
				<p class="text-secondary text-sm">
					Contact us at <a href="mailto:billing@netvisor.io" class="text-blue-400 hover:underline"
						>billing@netvisor.io</a
					> for billing questions or assistance.
				</p>
			</InfoCard>
		</div>
	{:else}
		<div class="text-secondary py-8 text-center">
			<p>Unable to load billing information</p>
			<p class="text-tertiary mt-2 text-sm">Please try again later</p>
		</div>
	{/if}
</EditModal>
