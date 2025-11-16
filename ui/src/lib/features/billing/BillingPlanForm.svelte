<script lang="ts">
	import { billingPlans, features } from '$lib/shared/stores/metadata';
	import { Check, X } from 'lucide-svelte';
	import { checkout, currentPlans } from './store';
	import type { BillingPlan } from './types';
	import GithubStars from '../../shared/components/data/GithubStars.svelte';

	async function handlePlanSelect(plan: BillingPlan) {
		const checkoutUrl = await checkout(plan);
		if (checkoutUrl) {
			window.location.href = checkoutUrl;
		}
	}

	function formatPrice(plan: (typeof $currentPlans)[0]): string {
		return `$${plan.price.cents / 100} per ${plan.price.rate}`;
	}

	// Get metadata for a plan type from billingPlans store
	function getPlanMetadata(planType: string) {
		return billingPlans.getMetadata(planType);
	}

	// Extract feature keys from the first plan's metadata
	let featureKeys = $derived(
		$currentPlans.length > 0
			? Object.keys(getPlanMetadata($currentPlans[0].type)?.features || {})
			: []
	);

	// Helper to get feature value for a plan type
	function getFeatureValue(planType: string, featureKey: string): string | boolean | number | null {
		const metadata = getPlanMetadata(planType);
		const value = metadata?.features?.[featureKey as keyof typeof metadata.features];

		if (value === undefined) return null;

		// Check if this feature uses null as unlimited
		const featureMetadata = features.getMetadata(featureKey);
		if (featureMetadata?.use_null_as_unlimited && value === null) {
			return 'Unlimited';
		}

		// Handle -1 as unlimited for numeric fields
		if (value === -1) {
			return 'Unlimited';
		}

		return value as string | boolean | number | null;
	}

	// Helper to check if a feature is a text field
	function isTextField(featureKey: string): boolean {
		if ($currentPlans.length === 0) return false;
		const values = $currentPlans.map((p) => getFeatureValue(p.type, featureKey));
		// Text fields have string values that aren't "Unlimited"
		return values.some((v) => typeof v === 'string' && v !== 'Unlimited');
	}

	// Helper to check if a value is "truthy" for sorting purposes
	function isTruthyValue(value: string | boolean | number | null): boolean {
		if (value === null || value === false) return false;
		if (value === true) return true;
		if (typeof value === 'number' && value > 0) return true;
		if (typeof value === 'string' && value !== '') return true;
		return false;
	}

	// Count how many plans have truthy values for each feature
	function getTruthyCount(featureKey: string): number {
		return $currentPlans.filter((p) => isTruthyValue(getFeatureValue(p.type, featureKey))).length;
	}

	// Sort features: text fields go to bottom, others sorted by truthy count
	let sortedFeatureKeys = $derived(
		[...featureKeys].sort((a, b) => {
			const aIsText = isTextField(a);
			const bIsText = isTextField(b);

			// Text fields always go to the bottom
			if (aIsText && !bIsText) return 1;
			if (!aIsText && bIsText) return -1;

			// Within the same category (both text or both non-text), sort by truthy count
			return getTruthyCount(b) - getTruthyCount(a);
		})
	);

	// Calculate equal column width based on number of plans
	let columnWidth = $derived(`${100 / ($currentPlans.length + 1)}%`);
</script>

<div class="space-y-6 px-10">
	<!-- GitHub Stars Island -->
	<div class="flex justify-center">
		<div
			class="inline-flex items-center gap-2 rounded-2xl border border-gray-700 bg-gray-800/90 px-4 py-3 shadow-xl backdrop-blur-sm"
		>
			<span class="text-secondary text-sm">Open source on GitHub</span>
			<GithubStars />
		</div>
	</div>

	<!-- Pricing Table Card -->
	<div class="card overflow-hidden p-0">
		<div class="overflow-x-auto">
			<table class="w-full table-fixed">
				<!-- Header Row: Plan Names and Prices -->
				<thead>
					<tr class="border-b border-gray-700">
						<!-- Feature labels column -->
						<th class="border-r border-gray-700 p-4" style="width: {columnWidth}"></th>

						<!-- Plan headers with equal width -->
						{#each $currentPlans as plan (plan.type)}
							{@const description = billingPlans.getDescription(plan.type)}
							{@const IconComponent = billingPlans.getIconComponent(plan.type)}
							{@const colorHelper = billingPlans.getColorHelper(plan.type)}
							<th class="border-r border-gray-700 p-4 last:border-r-0" style="width: {columnWidth}">
								<div class="flex h-full min-h-[200px] flex-col justify-between space-y-3">
									<!-- Top: Icon and Name -->
									<div class="flex flex-col items-center space-y-2">
										<div class="flex justify-center">
											<IconComponent class="{colorHelper.icon} h-8 w-8" />
										</div>
										<div class="text-primary text-lg font-semibold">
											{billingPlans.getName(plan.type)}
										</div>
									</div>

									<!-- Center: Price and Trial -->
									<div class="flex flex-col items-center space-y-1">
										<div class="text-primary text-2xl font-bold">{formatPrice(plan)}</div>
										{#if plan.trial_days > 0}
											<div class="text-xs font-medium text-success">
												{plan.trial_days}-day free trial
											</div>
										{/if}
									</div>

									<!-- Bottom: Description -->
									<div class="flex items-end justify-center">
										{#if description}
											<div class="text-tertiary text-center text-xs leading-tight">
												{description}
											</div>
										{/if}
									</div>
								</div>
							</th>
						{/each}
					</tr>
				</thead>

				<!-- Feature Rows -->
				<tbody>
					{#each sortedFeatureKeys as featureKey (featureKey)}
						{@const featureDescription = features.getDescription(featureKey)}
						<tr class="border-b border-gray-700 transition-colors hover:bg-gray-800/30">
							<!-- Feature label -->
							<td class="text-secondary border-r border-gray-700 p-4">
								<div class="text-sm font-medium">
									{features.getName(featureKey)}
								</div>
								{#if featureDescription}
									<div class="text-tertiary mt-1 text-xs leading-tight">
										{featureDescription}
									</div>
								{/if}
							</td>

							<!-- Feature values per plan -->
							{#each $currentPlans as plan (plan.type)}
								{@const value = getFeatureValue(plan.type, featureKey)}
								<td class="border-r border-gray-700 p-4 text-center last:border-r-0">
									{#if typeof value === 'boolean'}
										{#if value}
											<Check class="mx-auto h-8 w-8 text-success" />
										{:else}
											<X class="text-muted mx-auto h-8 w-8" />
										{/if}
									{:else if value === null}
										<span class="text-tertiary">—</span>
									{:else}
										<span class="text-secondary text-lg">{value}</span>
									{/if}
								</td>
							{/each}
						</tr>
					{/each}
				</tbody>

				<!-- Footer Row: Select Buttons -->
				<tfoot>
					<tr class="bg-gray-800/50">
						<!-- Empty cell for feature labels column -->
						<td class="border-r border-gray-700 p-4"></td>

						<!-- Select buttons -->
						{#each $currentPlans as plan (plan.type)}
							<td class="border-r border-gray-700 p-4 last:border-r-0">
								<button
									type="button"
									onclick={() => handlePlanSelect(plan)}
									class="btn-primary w-full"
								>
									Select
								</button>
							</td>
						{/each}
					</tr>
				</tfoot>
			</table>
		</div>
	</div>
</div>
