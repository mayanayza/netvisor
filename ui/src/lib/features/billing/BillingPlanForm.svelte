<script lang="ts">
	/**
	 * BillingPlanForm Component
	 *
	 * A pure presentation layer for displaying billing plans.
	 * All data and callbacks are provided via props.
	 */
	import { Check, X, ChevronDown } from 'lucide-svelte';
	import GithubStars from '$lib/shared/components/data/GithubStars.svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import ToggleGroup from './ToggleGroup.svelte';
	import { SvelteMap } from 'svelte/reactivity';
	import { onMount } from 'svelte';
	import type { BillingPlan } from './types';
	import type { BillingPlanMetadata, FeatureMetadata } from '$lib/shared/stores/metadata';
	import type { ColorStyle } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';

	/**
	 * Interface for metadata helpers props.
	 * Both app store helpers and website fixture helpers satisfy this interface.
	 */
	interface MetadataHelpers<T> {
		getMetadata: (id: string | null) => T;
		getDescription: (id: string | null) => string;
		getName: (id: string | null) => string;
		getCategory: (id: string | null) => string;
		getIconComponent: (id: string | null) => IconComponent;
		getColorHelper: (id: string | null) => ColorStyle;
	}

	// ============================================================================
	// Props
	// ============================================================================

	interface Props {
		/** Array of billing plans to display */
		plans: BillingPlan[];

		/** Metadata helpers for billing plans (provides name, description, icon, color, features) */
		billingPlanHelpers: MetadataHelpers<BillingPlanMetadata>;

		/** Metadata helpers for features (provides name, description, is_coming_soon) */
		featureHelpers: MetadataHelpers<FeatureMetadata>;

		/** Callback when a plan is selected (not called for Enterprise plans) */
		onPlanSelect: (plan: BillingPlan) => void | Promise<void>;

		/**
		 * Initial filter for plan types. Defaults to 'commercial'.
		 * In the app, this can be set dynamically based on user email.
		 * On the website, this is typically static.
		 */
		initialPlanFilter?: 'all' | 'personal' | 'commercial';

		/** Whether to show GitHub stars badge. Defaults to true */
		showGithubStars?: boolean;

		/** Custom class for the container */
		class?: string;
	}

	// The MetadataHelpers interface includes methods for interface consistency
	// even though not all are used in this component
	// eslint-disable-next-line svelte/no-unused-props
	let {
		plans,
		billingPlanHelpers,
		featureHelpers,
		onPlanSelect,
		initialPlanFilter = 'commercial',
		showGithubStars = true,
		class: className = ''
	}: Props = $props();

	// ============================================================================
	// State
	// ============================================================================

	let collapsedCategories = $state<Record<string, boolean>>({});

	type PlanFilter = 'all' | 'personal' | 'commercial';
	let planFilter = $state<PlanFilter>(initialPlanFilter);

	type BillingPeriod = 'monthly' | 'yearly';
	let billingPeriod = $state<BillingPeriod>('monthly');

	// Sticky header visibility
	let mainHeaderRef = $state<HTMLElement | null>(null);
	let tableContainerRef = $state<HTMLElement | null>(null);
	let showStickyHeader = $state(false);
	let stickyHeaderLeft = $state(0);
	let stickyHeaderWidth = $state(0);

	onMount(() => {
		if (!mainHeaderRef) return;

		const observer = new IntersectionObserver(
			([entry]) => {
				showStickyHeader = !entry.isIntersecting;
			},
			{ threshold: 0 }
		);

		observer.observe(mainHeaderRef);

		// Update sticky header position on scroll/resize
		function updateStickyPosition() {
			if (tableContainerRef) {
				const rect = tableContainerRef.getBoundingClientRect();
				stickyHeaderLeft = rect.left;
				stickyHeaderWidth = rect.width;
			}
		}

		updateStickyPosition();
		window.addEventListener('scroll', updateStickyPosition);
		window.addEventListener('resize', updateStickyPosition);

		return () => {
			observer.disconnect();
			window.removeEventListener('scroll', updateStickyPosition);
			window.removeEventListener('resize', updateStickyPosition);
		};
	});

	// ============================================================================
	// Constants
	// ============================================================================

	const planTypeOptions = [
		{ value: 'all', label: 'All Plans' },
		{ value: 'personal', label: 'Personal' },
		{ value: 'commercial', label: 'Commercial' }
	];

	const billingPeriodOptions = [
		{ value: 'monthly', label: 'Monthly' },
		{ value: 'yearly', label: 'Yearly', badge: '-20%' }
	];

	// ============================================================================
	// Derived State
	// ============================================================================

	let filteredPlans = $derived.by(() => {
		let result = plans;

		if (planFilter !== 'all') {
			result = result.filter((plan) => {
				const metadata = billingPlanHelpers.getMetadata(plan.type);
				if (planFilter === 'commercial') return metadata.is_commercial;
				if (planFilter === 'personal') return !metadata.is_commercial;
				return true;
			});
		}

		result = result.filter((plan) => {
			if (billingPeriod === 'monthly') return plan.rate === 'Month';
			if (billingPeriod === 'yearly') return plan.rate === 'Year';
			return true;
		});

		return result;
	});

	let featureKeys = $derived(
		filteredPlans.length > 0
			? Object.keys(billingPlanHelpers.getMetadata(filteredPlans[0].type)?.features || {})
			: []
	);

	let sortedFeatureKeys = $derived(
		[...featureKeys].sort((a, b) => {
			// 1. Primary sort: by number of plans that have this feature (most first)
			// This creates the "cascade" effect where features increase with more expensive plans
			const countDiff = getTruthyCount(b) - getTruthyCount(a);
			if (countDiff !== 0) return countDiff;

			// 2. Secondary sort: Coming Soon features go after available features (within same count)
			const aComingSoon = isComingSoon(a);
			const bComingSoon = isComingSoon(b);
			if (aComingSoon && !bComingSoon) return 1;
			if (!aComingSoon && bComingSoon) return -1;

			// 3. Tertiary sort: Text fields go after boolean fields
			const aIsText = isTextField(a);
			const bIsText = isTextField(b);
			if (aIsText && !bIsText) return 1;
			if (!aIsText && bIsText) return -1;

			return 0;
		})
	);

	let groupedFeatures = $derived.by(() => {
		const groups: SvelteMap<string, string[]> = new SvelteMap();

		for (const featureKey of sortedFeatureKeys) {
			const category = featureHelpers.getCategory(featureKey) || 'Other';
			if (!groups.has(category)) {
				groups.set(category, []);
			}
			groups.get(category)!.push(featureKey);
		}

		const sortedEntries = [...groups.entries()].sort(([a], [b]) => {
			if (a === 'Features') return -1;
			if (b === 'Features') return 1;
			return a.localeCompare(b);
		});

		return new Map(sortedEntries);
	});

	let columnWidth = $derived(`${100 / (filteredPlans.length + 1)}%`);

	// ============================================================================
	// Helper Functions
	// ============================================================================

	function toggleCategory(category: string) {
		collapsedCategories[category] = !collapsedCategories[category];
	}

	function formatBasePricing(plan: BillingPlan): string {
		const metadata = billingPlanHelpers.getMetadata(plan.type);
		if (metadata?.custom_price) return metadata.custom_price;
		return `$${plan.base_cents / 100}/${plan.rate}`;
	}

	function formatSeatAddonPricing(plan: BillingPlan): string {
		if (plan.seat_cents) return `+$${plan.seat_cents / 100}/seat/${plan.rate.toLowerCase()}`;
		return '';
	}

	function formatNetworkAddonPricing(plan: BillingPlan): string {
		if (plan.network_cents)
			return `+$${plan.network_cents / 100}/network/${plan.rate.toLowerCase()}`;
		return '';
	}

	function isComingSoon(featureKey: string): boolean {
		return featureHelpers.getMetadata(featureKey)?.is_coming_soon === true;
	}

	function getFeatureValue(planType: string, featureKey: string): boolean | string | number | null {
		const metadata = billingPlanHelpers.getMetadata(planType);
		// Cast to allow dynamic key access - we iterate over keys from the same object
		const features = metadata?.features as
			| Record<string, boolean | string | number | null>
			| undefined;
		return features?.[featureKey] ?? null;
	}

	function isTextField(featureKey: string): boolean {
		if (filteredPlans.length === 0) return false;
		const values = filteredPlans.map((p) => getFeatureValue(p.type, featureKey));
		return values.some((v) => typeof v === 'string' && v !== 'Unlimited');
	}

	function isTruthyValue(value: string | boolean | number | null): boolean {
		if (value === null || value === false) return false;
		if (value === true) return true;
		if (typeof value === 'number' && value > 0) return true;
		if (typeof value === 'string' && value !== '') return true;
		return false;
	}

	function getTruthyCount(featureKey: string): number {
		return filteredPlans.filter((p) => isTruthyValue(getFeatureValue(p.type, featureKey))).length;
	}

	function getCustomCheckoutLink(plan: BillingPlan): string | null {
		return billingPlanHelpers.getMetadata(plan.type)?.custom_checkout_link ?? null;
	}

	function getCustomCheckoutCta(plan: BillingPlan): string {
		return billingPlanHelpers.getMetadata(plan.type)?.custom_checkout_cta ?? 'Select';
	}

	function getHosting(plan: BillingPlan): string {
		return billingPlanHelpers.getMetadata(plan.type)?.hosting ?? '';
	}

	function hasCustomPrice(plan: BillingPlan): boolean {
		return billingPlanHelpers.getMetadata(plan.type)?.custom_price !== null;
	}

	function getHostingColor(hosting: string): string {
		switch (hosting) {
			case 'Cloud':
				return 'sky';
			case 'Managed':
				return 'purple';
			case 'Self-Hosted':
				return 'green';
			default:
				return 'gray';
		}
	}

	function anyPlanHasFeature(featureKey: string): boolean {
		return getTruthyCount(featureKey) > 0;
	}

	function categoryHasVisibleFeatures(categoryFeatures: string[]): boolean {
		return categoryFeatures.some((featureKey) => anyPlanHasFeature(featureKey));
	}
</script>

<div class="space-y-6 px-10 {className}">
	<!-- Header with GitHub Stars and Toggles -->
	<div class="flex flex-wrap items-stretch justify-center gap-6">
		{#if showGithubStars}
			<div class="card inline-flex items-center gap-2 px-4 shadow-xl backdrop-blur-sm">
				<span class="text-secondary text-sm">Open source on GitHub</span>
				<GithubStars />
			</div>
		{/if}

		<ToggleGroup
			options={planTypeOptions}
			selected={planFilter}
			onchange={(value) => (planFilter = value as PlanFilter)}
		/>

		<ToggleGroup
			options={billingPeriodOptions}
			selected={billingPeriod}
			onchange={(value) => (billingPeriod = value as BillingPeriod)}
		/>
	</div>

	<!-- Pricing Table -->
	<div class="relative" bind:this={tableContainerRef}>
		<!-- Sticky Header (fixed overlay, always rendered for smooth transitions) -->
		<div
			class="card fixed top-0 z-30 overflow-hidden rounded-none p-0 transition-opacity duration-150 {showStickyHeader
				? 'opacity-100'
				: 'pointer-events-none opacity-0'}"
			style="left: {stickyHeaderLeft}px; width: {stickyHeaderWidth}px;"
		>
			<div class="flex">
				<div class="border-r border-gray-700 p-3" style="width: {columnWidth}"></div>
				{#each filteredPlans as plan (plan.type)}
					{@const IconComponent = billingPlanHelpers.getIconComponent(plan.type)}
					{@const colorHelper = billingPlanHelpers.getColorHelper(plan.type)}
					<div
						class="flex items-center justify-center gap-2 border-r border-gray-700 p-3 last:border-r-0"
						style="width: {columnWidth}"
					>
						<IconComponent class="{colorHelper.icon} h-5 w-5" />
						<span class="text-primary font-semibold">
							{billingPlanHelpers.getName(plan.type)}
						</span>
					</div>
				{/each}
			</div>
		</div>

		<div class="card overflow-hidden rounded-b-none border-b-0 p-0">
			<table class="w-full table-fixed">
				<!-- Header Row: Plan Names and Prices -->
				<thead class="z-10">
					<tr class="border-b border-gray-700" bind:this={mainHeaderRef}>
						<th class="border-r border-gray-700 p-4" style="width: {columnWidth}"></th>

						{#each filteredPlans as plan (plan.type)}
							{@const description = billingPlanHelpers.getDescription(plan.type)}
							{@const IconComponent = billingPlanHelpers.getIconComponent(plan.type)}
							{@const colorHelper = billingPlanHelpers.getColorHelper(plan.type)}
							<th class="border-r border-gray-700 p-4 last:border-r-0" style="width: {columnWidth}">
								<div class="flex h-full min-h-[200px] flex-col justify-between space-y-3">
									<!-- Top: Icon, Name -->
									<div class="flex flex-col items-center space-y-2">
										<div class="flex justify-center">
											<IconComponent class="{colorHelper.icon} h-8 w-8" />
										</div>
										<div class="flex items-center gap-2">
											<span class="text-primary text-lg font-semibold">
												{billingPlanHelpers.getName(plan.type)}
											</span>
										</div>
									</div>

									<!-- Center: Price -->
									<div class="flex flex-col items-center space-y-1">
										<div class="text-primary text-2xl font-bold">{formatBasePricing(plan)}</div>
										{#if plan.trial_days > 0 && !hasCustomPrice(plan)}
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

				<tbody>
					<!-- Seats Row -->
					<tr class="border-b border-gray-700 transition-colors hover:bg-gray-800/30">
						<td class="text-secondary border-r border-gray-700 p-4">
							<div class="text-sm font-medium">Seats</div>
						</td>
						{#each filteredPlans as plan (plan.type)}
							<td class="border-r border-gray-700 p-4 text-center last:border-r-0">
								<div class="flex flex-col">
									<span class="text-secondary">
										{plan.included_seats === null ? 'Unlimited' : plan.included_seats}
									</span>
									{#if plan.seat_cents}
										<span class="text-tertiary text-sm">
											{formatSeatAddonPricing(plan)} for additional seats
										</span>
									{/if}
								</div>
							</td>
						{/each}
					</tr>

					<!-- Networks Row -->
					<tr class="border-b border-gray-700 transition-colors hover:bg-gray-800/30">
						<td class="text-secondary border-r border-gray-700 p-4">
							<div class="text-sm font-medium">Networks</div>
						</td>
						{#each filteredPlans as plan (plan.type)}
							<td class="border-r border-gray-700 p-4 text-center last:border-r-0">
								<div class="flex flex-col">
									<span class="text-secondary">
										{plan.included_networks === null ? 'Unlimited' : plan.included_networks}
									</span>
									{#if plan.network_cents}
										<span class="text-tertiary text-sm">
											{formatNetworkAddonPricing(plan)} for additional networks
										</span>
									{/if}
								</div>
							</td>
						{/each}
					</tr>

					<!-- Hosting Row -->
					<tr class="border-b border-gray-700 transition-colors hover:bg-gray-800/30">
						<td class="text-secondary border-r border-gray-700 p-4">
							<div class="text-sm font-medium">Hosting</div>
						</td>
						{#each filteredPlans as plan (plan.type)}
							{@const hosting = getHosting(plan)}
							<td class="border-r border-gray-700 p-4 text-center last:border-r-0">
								{#if hosting}
									<Tag label={hosting} color={getHostingColor(hosting)} />
								{:else}
									<span class="text-tertiary">—</span>
								{/if}
							</td>
						{/each}
					</tr>

					<!-- Feature Rows grouped by category -->
					{#each [...groupedFeatures.entries()] as [category, categoryFeatures] (category)}
						{#if categoryHasVisibleFeatures(categoryFeatures)}
							<!-- Category Header -->
							<tr class="border-b border-gray-700">
								<td colspan={filteredPlans.length + 1} class="p-0">
									<button
										type="button"
										class="text-secondary hover:text-primary flex w-full items-center justify-between p-3 text-left transition-colors hover:bg-gray-800/60"
										onclick={() => toggleCategory(category)}
										aria-expanded={!collapsedCategories[category]}
									>
										<span class="text-sm font-semibold uppercase tracking-wide">{category}</span>
										<ChevronDown
											class="h-4 w-4 transition-transform {collapsedCategories[category]
												? '-rotate-90'
												: ''}"
										/>
									</button>
								</td>
							</tr>

							{#if !collapsedCategories[category]}
								{#each categoryFeatures as featureKey (featureKey)}
									{#if anyPlanHasFeature(featureKey)}
										{@const featureDescription = featureHelpers.getDescription(featureKey)}
										{@const comingSoon = isComingSoon(featureKey)}
										<tr class="border-b border-gray-700 transition-colors hover:bg-gray-800/30">
											<td class="text-secondary border-r border-gray-700 p-4">
												<div class="text-sm font-medium">
													{featureHelpers.getName(featureKey)}
												</div>
												{#if featureDescription}
													<div class="text-tertiary mt-1 text-xs leading-tight">
														{featureDescription}
													</div>
												{/if}
											</td>

											{#each filteredPlans as plan (plan.type)}
												{@const value = getFeatureValue(plan.type, featureKey)}
												<td class="border-r border-gray-700 p-4 text-center last:border-r-0">
													{#if comingSoon && value}
														<Tag label="Coming Soon" color="gray" />
													{:else if typeof value === 'boolean'}
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
									{/if}
								{/each}
							{/if}
						{/if}
					{/each}
				</tbody>
			</table>
		</div>

		<!-- Sticky CTA Footer -->
		<div class="sticky bottom-0 left-0 right-0 z-20">
			<div class="card overflow-hidden rounded-t-none p-0">
				<div class="flex">
					<div class="border-r border-gray-700 p-4" style="width: {columnWidth}"></div>
					{#each filteredPlans as plan (plan.type)}
						{@const customLink = getCustomCheckoutLink(plan)}
						{@const ctaText = getCustomCheckoutCta(plan)}
						<div class="border-r border-gray-700 p-4 last:border-r-0" style="width: {columnWidth}">
							{#if customLink}
								<!-- eslint-disable-next-line svelte/no-navigation-without-resolve -->
								<a href={customLink} class="btn-primary inline-block w-full text-center">
									{ctaText}
								</a>
							{:else}
								<button type="button" onclick={() => onPlanSelect(plan)} class="btn-primary w-full">
									{ctaText}
								</button>
							{/if}
						</div>
					{/each}
				</div>
			</div>
		</div>
	</div>
</div>
