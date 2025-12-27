<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { CreditCard, CheckCircle, AlertCircle } from 'lucide-svelte';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { isBillingPlanActive } from '../organizations/types';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import { openCustomerPortal } from './store';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import { useUsersQuery } from '$lib/features/users/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	let { isOpen = $bindable(false), onClose }: { isOpen: boolean; onClose: () => void } = $props();

	// TanStack Query for users
	const usersQuery = useUsersQuery();
	let usersData = $derived(usersQuery.data ?? []);

	// TanStack Query for networks
	const networksQuery = useNetworksQuery();
	let networksData = $derived(networksQuery.data ?? []);

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let org = $derived(organizationQuery.data);

	let seatCount = $derived(usersData.length);
	let networkCount = $derived(networksData.length);

	let extraSeats = $derived.by(() => {
		if (!org?.plan?.included_seats) return 0;
		return Math.max(seatCount - org.plan.included_seats, 0);
	});

	let extraNetworks = $derived.by(() => {
		if (!org?.plan?.included_networks) return 0;
		return Math.max(networkCount - org.plan.included_networks, 0);
	});

	let extraSeatsCents = $derived(extraSeats * (org?.plan?.seat_cents || 0));
	let extraNetworksCents = $derived(extraNetworks * (org?.plan?.network_cents || 0));

	let planActive = $derived(org ? isBillingPlanActive(org) : false);

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
		<ModalHeaderIcon Icon={CreditCard} color="Blue" />
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
							<span class={`text-sm font-medium ${getPlanStatusColor(org.plan_status || '')}`}>
								{formatPlanStatus(org.plan_status || '')}
							</span>
						</div>
					</div>

					<div class="space-y-4">
						{#if org.plan}
							<!-- Base Plan -->
							<div class="flex items-baseline justify-between">
								<div>
									<p class="text-primary text-lg font-semibold">
										{billingPlans.getName(org.plan.type || null)}
									</p>
									{#if org.plan.trial_days > 0 && org.plan_status === 'trialing'}
										<p class="text-secondary mt-1 text-xs">
											Includes {org.plan.trial_days}-day free trial
										</p>
									{/if}
								</div>
								<div class="text-right">
									<p class="text-primary text-2xl font-bold">
										${org.plan.base_cents / 100}
									</p>
									<p class="text-secondary text-xs">per {org.plan.rate}</p>
								</div>
							</div>

							<!-- Seats Usage -->
							{#if org.plan.included_seats !== null}
								<div class="border-t border-gray-700 pt-3">
									<div class="flex items-baseline justify-between">
										<div>
											<p class="text-primary font-medium">Seats</p>
											<p class="text-secondary text-sm">
												{seatCount} total ({org.plan.included_seats} included
												{#if extraSeats > 0}
													+ {extraSeats} extra @ ${org.plan.seat_cents
														? org.plan.seat_cents / 100
														: 0} each
												{/if})
											</p>
										</div>
										{#if extraSeatsCents > 0}
											<div class="text-right">
												<p class="text-primary text-xl font-bold">
													+${extraSeatsCents / 100}
												</p>
												<p class="text-secondary text-xs">per {org.plan.rate}</p>
											</div>
										{:else}
											<p class="text-tertiary text-sm">Included</p>
										{/if}
									</div>
								</div>
							{/if}

							<!-- Networks Usage -->
							{#if org.plan.included_networks !== null}
								<div class="border-t border-gray-700 pt-3">
									<div class="flex items-baseline justify-between">
										<div>
											<p class="text-primary font-medium">Networks</p>
											<p class="text-secondary text-sm">
												{networkCount} total ({org.plan.included_networks} included
												{#if extraNetworks > 0}
													+ {extraNetworks} extra @ ${org.plan.network_cents
														? org.plan.network_cents / 100
														: 0} each
												{/if})
											</p>
										</div>
										{#if extraNetworksCents > 0}
											<div class="text-right">
												<p class="text-primary text-xl font-bold">
													+${extraNetworksCents / 100}
												</p>
												<p class="text-secondary text-xs">per {org.plan.rate}</p>
											</div>
										{:else}
											<p class="text-tertiary text-sm">Included</p>
										{/if}
									</div>
								</div>
							{/if}
						{/if}

						{#if org.plan_status === 'trialing'}
							<div
								class="rounded-md border border-blue-800 bg-blue-900/30 p-3 text-sm text-blue-300"
							>
								Your trial is active. You won't be charged until your trial ends.
							</div>
						{:else if org.plan_status === 'past_due'}
							<div class="rounded-md border border-red-800 bg-red-900/30 p-3 text-sm text-red-300">
								Your payment is past due. Please update your payment method to continue using
								Scanopy.
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
				<button onclick={handleManageSubscription} class="btn-primary w-full">
					Manage Subscription
				</button>
			</div>

			<!-- Additional Info -->
			<InfoCard title="Need Help?">
				<p class="text-secondary text-sm">
					Contact us at <a href="mailto:billing@scanopy.net" class="text-blue-400 hover:underline"
						>billing@scanopy.net</a
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
