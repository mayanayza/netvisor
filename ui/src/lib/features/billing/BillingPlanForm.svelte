<script lang="ts">
	/**
	 * BillingPlanForm Component
	 *
	 * A pure presentation layer for displaying billing plans.
	 * Uses CSS Grid for consistent sticky header/footer on both desktop and mobile.
	 */
	import { Check, X, ChevronDown } from 'lucide-svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import ToggleGroup from './ToggleGroup.svelte';
	import ScanProgressIndicator from '$lib/features/discovery/components/ScanProgressIndicator.svelte';
	import { SvelteMap } from 'svelte/reactivity';
	import type { BillingPlan } from './types';
	import type { BillingPlanMetadata, FeatureMetadata } from '$lib/shared/stores/metadata';
	import type { ColorStyle, Color } from '$lib/shared/utils/styling';
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
		plans: BillingPlan[];
		billingPlanHelpers: MetadataHelpers<BillingPlanMetadata>;
		featureHelpers: MetadataHelpers<FeatureMetadata>;
		onPlanSelect: (plan: BillingPlan) => void | Promise<void>;
		onPlanInquiry?: (plan: BillingPlan) => void | Promise<void>;
		initialPlanFilter?: 'all' | 'personal' | 'commercial';
		showGithubStars?: boolean;
		showHosting?: boolean;
		class?: string;
		recommendedPlan?: string | null;
		forceCommercial?: boolean;
	}

	// eslint-disable-next-line svelte/no-unused-props
	let {
		plans,
		billingPlanHelpers,
		featureHelpers,
		onPlanSelect,
		onPlanInquiry,
		initialPlanFilter = 'commercial',
		showGithubStars = true,
		class: className = '',
		showHosting = false,
		recommendedPlan = null,
		forceCommercial = false
	}: Props = $props();

	let collapsedCategories = $state<Record<string, boolean>>({});

	type PlanFilter = 'all' | 'personal' | 'commercial';
	let planFilter = $derived<PlanFilter>(initialPlanFilter);

	type BillingPeriod = 'monthly' | 'yearly';
	let billingPeriod = $state<BillingPeriod>('monthly');

	// Refs for scroll sync between header, content, and footer
	let headerScrollRef = $state<HTMLElement | null>(null);
	let contentScrollRef = $state<HTMLElement | null>(null);
	let footerScrollRef = $state<HTMLElement | null>(null);

	// Sync horizontal scroll across header, content, and footer
	$effect(() => {
		if (!contentScrollRef) return;

		function syncFromContent() {
			const scrollLeft = contentScrollRef?.scrollLeft ?? 0;
			if (headerScrollRef) headerScrollRef.scrollLeft = scrollLeft;
			if (footerScrollRef) footerScrollRef.scrollLeft = scrollLeft;
		}

		function syncFromHeader() {
			const scrollLeft = headerScrollRef?.scrollLeft ?? 0;
			if (contentScrollRef) contentScrollRef.scrollLeft = scrollLeft;
			if (footerScrollRef) footerScrollRef.scrollLeft = scrollLeft;
		}

		function syncFromFooter() {
			const scrollLeft = footerScrollRef?.scrollLeft ?? 0;
			if (contentScrollRef) contentScrollRef.scrollLeft = scrollLeft;
			if (headerScrollRef) headerScrollRef.scrollLeft = scrollLeft;
		}

		contentScrollRef.addEventListener('scroll', syncFromContent);
		headerScrollRef?.addEventListener('scroll', syncFromHeader);
		footerScrollRef?.addEventListener('scroll', syncFromFooter);

		return () => {
			contentScrollRef?.removeEventListener('scroll', syncFromContent);
			headerScrollRef?.removeEventListener('scroll', syncFromHeader);
			footerScrollRef?.removeEventListener('scroll', syncFromFooter);
		};
	});

	// Filter out personal option when forceCommercial is true
	let planTypeOptions = $derived(
		forceCommercial
			? [
					{ value: 'all', label: 'All Plans' },
					{ value: 'commercial', label: 'Commercial' }
				]
			: [
					{ value: 'all', label: 'All Plans' },
					{ value: 'personal', label: 'Personal' },
					{ value: 'commercial', label: 'Commercial' }
				]
	);

	const billingPeriodOptions = [
		{ value: 'monthly', label: 'Monthly' },
		{ value: 'yearly', label: 'Yearly', badge: '-20%' }
	];

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
			const countDiff = getTruthyCount(b) - getTruthyCount(a);
			if (countDiff !== 0) return countDiff;
			const aComingSoon = isComingSoon(a);
			const bComingSoon = isComingSoon(b);
			if (aComingSoon && !bComingSoon) return 1;
			if (!aComingSoon && bComingSoon) return -1;
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
			if (!groups.has(category)) groups.set(category, []);
			groups.get(category)!.push(featureKey);
		}
		function getCategoryScore(categoryFeatures: string[]): number {
			return categoryFeatures.reduce((sum, featureKey) => sum + getTruthyCount(featureKey), 0);
		}
		const sortedEntries = [...groups.entries()].sort(([a, aFeatures], [b, bFeatures]) => {
			if (a === 'Support') return 1;
			if (b === 'Support') return -1;
			if (a === 'Licensing & Billing') return 1;
			if (b === 'Licensing & Billing') return -1;
			if (a === 'Enterprise') return 1;
			if (b === 'Enterprise') return -1;
			const scoreDiff = getCategoryScore(bFeatures) - getCategoryScore(aFeatures);
			if (scoreDiff !== 0) return scoreDiff;
			return a.localeCompare(b);
		});
		return new Map(sortedEntries);
	});

	// Grid column template based on number of plans
	let gridColumns = $derived.by(() => {
		const planCount = filteredPlans.length;
		if (planCount === 0) return '120px 1fr';
		// Label column + plan columns
		return `minmax(100px, 20%) repeat(${planCount}, minmax(120px, 1fr))`;
	});

	function toggleCategory(category: string) {
		collapsedCategories[category] = !collapsedCategories[category];
	}

	function formatBasePricing(plan: BillingPlan): string {
		const metadata = billingPlanHelpers.getMetadata(plan.type);
		if (metadata?.custom_price) return metadata.custom_price;
		return `$${plan.base_cents / 100} / ${plan.rate}`;
	}

	function formatSeatAddonPricing(plan: BillingPlan): string {
		if (plan.seat_cents) return `+$${plan.seat_cents / 100} / seat / ${plan.rate.toLowerCase()}`;
		return '';
	}

	function formatNetworkAddonPricing(plan: BillingPlan): string {
		if (plan.network_cents)
			return `+$${plan.network_cents / 100} / network / ${plan.rate.toLowerCase()}`;
		return '';
	}

	function isComingSoon(featureKey: string): boolean {
		return featureHelpers.getMetadata(featureKey)?.is_coming_soon === true;
	}

	function getFeatureValue(planType: string, featureKey: string): boolean | string | number | null {
		const metadata = billingPlanHelpers.getMetadata(planType);
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

	function getHosting(plan: BillingPlan): string {
		return billingPlanHelpers.getMetadata(plan.type)?.hosting ?? '';
	}

	function isCommercial(plan: BillingPlan): boolean {
		return billingPlanHelpers.getMetadata(plan.type)?.is_commercial === true;
	}

	function hasTrial(plan: BillingPlan): boolean {
		return plan.trial_days > 0;
	}

	function hasCustomPrice(plan: BillingPlan): boolean {
		return billingPlanHelpers.getMetadata(plan.type)?.custom_price !== null;
	}

	function getHostingColor(hosting: string): Color {
		switch (hosting) {
			case 'Cloud':
				return 'Cyan';
			case 'Managed':
				return 'Purple';
			case 'Self-Hosted':
				return 'Green';
			default:
				return 'Gray';
		}
	}

	function anyPlanHasFeature(featureKey: string): boolean {
		return getTruthyCount(featureKey) > 0;
	}

	function categoryHasVisibleFeatures(categoryFeatures: string[]): boolean {
		return categoryFeatures.some((featureKey) => anyPlanHasFeature(featureKey));
	}

	function isEnterprise(plan: BillingPlan): boolean {
		return plan.type === 'Enterprise';
	}
</script>

<div class="space-y-6 {className}">
	<!-- Header with GitHub Stars and Toggles -->
	<div class="flex flex-wrap items-stretch justify-center gap-3 px-4 lg:gap-6 lg:px-10">
		{#if showGithubStars}
			<!-- <GithubStars /> -->
		{/if}

		<ScanProgressIndicator />

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

	<!-- Pricing Grid -->
	<div class="pricing-wrapper card p-0">
		<!-- Sticky Header -->
		<div
			class="sticky-header card card-static rounded-b-none border-0 p-0"
			bind:this={headerScrollRef}
		>
			<div class="grid-row header-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell"></div>
				{#each filteredPlans as plan (plan.type)}
					{@const IconComponent = billingPlanHelpers.getIconComponent(plan.type)}
					{@const colorHelper = billingPlanHelpers.getColorHelper(plan.type)}
					{@const isRecommended = recommendedPlan === plan.type}
					<div class="grid-cell plan-cell">
						<div class="flex flex-col items-center gap-1 py-2 lg:py-3">
							<div class="flex items-center justify-center gap-2">
								<IconComponent class="{colorHelper.icon} h-4 w-4 lg:h-8 lg:w-8" />
								<span class="text-primary text-sm font-semibold lg:text-lg"
									>{billingPlanHelpers.getName(plan.type)}</span
								>
							</div>
							{#if isRecommended}
								<Tag label="Recommended" color="Yellow" />
							{/if}
						</div>
					</div>
				{/each}
			</div>
		</div>

		<!-- Scrollable Content -->
		<div class="content-scroll rounded-none border-y-0 p-0" bind:this={contentScrollRef}>
			<!-- Price Row -->
			<div class="grid-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell"></div>
				{#each filteredPlans as plan (plan.type)}
					<div class="grid-cell plan-cell text-center">
						<div class="flex min-w-0 flex-col items-center space-y-1">
							<div class="text-primary min-w-0 text-sm font-bold lg:text-2xl">
								{formatBasePricing(plan)}
							</div>
							{#if plan.trial_days > 0 && !hasCustomPrice(plan)}
								<div class="text-xs font-medium text-success">{plan.trial_days}-day free trial</div>
							{/if}
						</div>
					</div>
				{/each}
			</div>

			<!-- Description Row -->
			<div class="grid-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell">
					<div class="text-xs font-medium lg:text-sm">Description</div>
				</div>
				{#each filteredPlans as plan (plan.type)}
					{@const description = billingPlanHelpers.getDescription(plan.type)}
					<div class="grid-cell plan-cell text-center">
						{#if description}
							<div class="text-tertiary text-xs leading-tight lg:text-sm">{description}</div>
						{:else}
							<span class="text-tertiary">—</span>
						{/if}
					</div>
				{/each}
			</div>

			<!-- Seats Row -->
			<div class="grid-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell">
					<div class="text-xs font-medium lg:text-sm">Seats</div>
				</div>
				{#each filteredPlans as plan (plan.type)}
					<div class="grid-cell plan-cell text-center">
						<div class="flex flex-col">
							<span class="text-secondary text-xs lg:text-base"
								>{plan.included_seats === null ? 'Unlimited' : plan.included_seats}</span
							>
							{#if plan.seat_cents}
								<span class="text-tertiary text-xs">{formatSeatAddonPricing(plan)}</span>
							{/if}
						</div>
					</div>
				{/each}
			</div>

			<!-- Networks Row -->
			<div class="grid-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell">
					<div class="text-xs font-medium lg:text-sm">Networks</div>
				</div>
				{#each filteredPlans as plan (plan.type)}
					<div class="grid-cell plan-cell text-center">
						<div class="flex flex-col">
							<span class="text-secondary text-xs lg:text-base"
								>{plan.included_networks === null ? 'Unlimited' : plan.included_networks}</span
							>
							{#if plan.network_cents}
								<span class="text-tertiary text-xs">{formatNetworkAddonPricing(plan)}</span>
							{/if}
						</div>
					</div>
				{/each}
			</div>

			<!-- Hosting Row -->
			{#if showHosting}
				<div class="grid-row" style="grid-template-columns: {gridColumns}">
					<div class="grid-cell label-cell">
						<div class="text-xs font-medium lg:text-sm">Hosting</div>
					</div>
					{#each filteredPlans as plan (plan.type)}
						{@const hosting = getHosting(plan)}
						<div class="grid-cell plan-cell text-center">
							{#if hosting}
								<Tag label={hosting} color={getHostingColor(hosting)} />
							{:else}
								<span class="text-tertiary">—</span>
							{/if}
						</div>
					{/each}
				</div>
			{/if}

			<!-- Feature Rows -->
			{#each [...groupedFeatures.entries()] as [category, categoryFeatures] (category)}
				{#if categoryHasVisibleFeatures(categoryFeatures)}
					<!-- Category Header -->
					<div class="category-row">
						<button
							type="button"
							class="text-secondary hover:text-primary flex w-full items-center gap-2 p-2 text-left transition-colors hover:bg-gray-800/60 lg:p-3"
							onclick={() => toggleCategory(category)}
							aria-expanded={!collapsedCategories[category]}
						>
							<span class="text-xs font-semibold uppercase tracking-wide lg:text-sm"
								>{category}</span
							>
							<ChevronDown
								class="h-4 w-4 flex-shrink-0 transition-transform {collapsedCategories[category]
									? '-rotate-90'
									: ''}"
							/>
						</button>
					</div>

					{#if !collapsedCategories[category]}
						{#each categoryFeatures as featureKey (featureKey)}
							{#if anyPlanHasFeature(featureKey)}
								{@const featureDescription = featureHelpers.getDescription(featureKey)}
								{@const comingSoon = isComingSoon(featureKey)}
								<div class="grid-row" style="grid-template-columns: {gridColumns}">
									<div class="grid-cell label-cell">
										<div class="text-xs font-medium lg:text-sm">
											{featureHelpers.getName(featureKey)}
										</div>
										{#if featureDescription}
											<div class="feature-description text-tertiary mt-1 leading-tight">
												{featureDescription}
											</div>
										{/if}
									</div>
									{#each filteredPlans as plan (plan.type)}
										{@const value = getFeatureValue(plan.type, featureKey)}
										<div class="grid-cell plan-cell text-center">
											{#if comingSoon && value}
												<Tag label="Coming Soon" color="Gray" />
											{:else if typeof value === 'boolean'}
												{#if value}
													<Check class="mx-auto h-5 w-5 text-success lg:h-8 lg:w-8" />
												{:else}
													<X class="text-muted mx-auto h-5 w-5 lg:h-8 lg:w-8" />
												{/if}
											{:else if value === null}
												<span class="text-tertiary">—</span>
											{:else}
												<span class="text-secondary text-xs lg:text-lg">{value}</span>
											{/if}
										</div>
									{/each}
								</div>
							{/if}
						{/each}
					{/if}
				{/if}
			{/each}
		</div>

		<!-- Sticky Footer -->
		<div
			class="sticky-footer card card-static rounded-t-none border-0 p-0"
			bind:this={footerScrollRef}
		>
			<div class="grid-row footer-row" style="grid-template-columns: {gridColumns}">
				<div class="grid-cell label-cell"></div>
				{#each filteredPlans as plan (plan.type)}
					{@const hosting = getHosting(plan)}
					{@const commercial = isCommercial(plan)}
					{@const trial = hasTrial(plan)}
					{@const enterprise = isEnterprise(plan)}
					<div class="grid-cell plan-cell footer-plan-cell">
						<div class="flex w-full flex-col gap-3">
							{#if enterprise && onPlanInquiry}
								<!-- Enterprise plan: Request Information button -->
								<button
									type="button"
									onclick={() => onPlanInquiry(plan)}
									class="btn-primary w-full whitespace-nowrap px-2 text-xs lg:text-sm"
								>
									Request Information
								</button>
							{:else if hosting === 'Cloud'}
								<button
									type="button"
									onclick={() => onPlanSelect(plan)}
									class="btn-primary w-full whitespace-nowrap px-2 text-xs lg:text-sm"
								>
									{trial ? 'Start Free Trial' : 'Get Started'}
								</button>
								{#if commercial && onPlanInquiry}
									<button
										type="button"
										onclick={() => onPlanInquiry(plan)}
										class="btn-secondary w-full whitespace-nowrap text-xs lg:text-sm"
									>
										Contact Us
									</button>
								{/if}
							{:else if hosting === 'Self-Hosted'}
								{#if commercial && onPlanInquiry}
									<button
										type="button"
										onclick={() => onPlanInquiry(plan)}
										class="btn-primary w-full whitespace-nowrap text-xs lg:text-sm"
									>
										Contact Us
									</button>
								{:else}
									<a
										href="https://github.com/scanopy/scanopy"
										target="_blank"
										rel="noopener noreferrer"
										class="btn-secondary inline-block w-full whitespace-nowrap text-center text-xs lg:text-sm"
										>View on GitHub</a
									>
								{/if}
							{:else if commercial && onPlanInquiry}
								<button
									type="button"
									onclick={() => onPlanInquiry(plan)}
									class="btn-primary w-full whitespace-nowrap text-xs lg:text-sm"
								>
									Contact Us
								</button>
							{/if}
						</div>
					</div>
				{/each}
			</div>
		</div>
	</div>
</div>

<style>
	/* Sticky header - sticks below navbar */
	.sticky-header {
		position: sticky;
		top: 0;
		z-index: 20;
		overflow-x: auto;
		scrollbar-width: none;
		box-shadow: none;
	}

	.sticky-header::-webkit-scrollbar {
		display: none;
	}

	/* Scrollable content area */
	.content-scroll {
		overflow-x: auto;
	}

	/* Sticky footer - sticks to bottom of viewport */
	.sticky-footer {
		position: sticky;
		bottom: 0;
		z-index: 20;
		overflow-x: auto;
		scrollbar-width: none;
		padding-bottom: env(safe-area-inset-bottom, 0);
	}

	.sticky-footer::-webkit-scrollbar {
		display: none;
	}

	/* Grid rows */
	.grid-row {
		display: grid;
		min-width: 600px;
	}

	/* Header row styling */
	.header-row .grid-cell {
		border-bottom: none;
	}

	/* Footer row styling */
	.footer-row .grid-cell {
		border-bottom: none;
	}

	/* Grid cells */
	.grid-cell {
		padding: 0.5rem;
		border-bottom: 1px solid rgb(55 65 81);
		border-right: 1px solid rgb(55 65 81);
	}

	@media (min-width: 1024px) {
		.grid-cell {
			padding: 1rem;
		}
	}

	.grid-cell:last-child {
		border-right: none;
	}

	/* Plan cells - allow text wrapping */
	.plan-cell {
		min-width: 0;
		display: flex;
		align-items: center;
		justify-content: center;
		text-align: center;
	}

	/* Footer plan cells - full width CTAs with padding */
	.footer-plan-cell {
		padding: 1rem;
	}

	@media (min-width: 1024px) {
		.footer-plan-cell {
			padding: 1.25rem;
		}
	}

	/* Label column - sticky on horizontal scroll */
	.label-cell {
		color: rgb(156 163 175);
		text-align: left;
		position: sticky;
		left: 0;
		z-index: 10;
		background: rgb(31 41 55);
	}

	/* Category row - full width, not grid */
	.category-row {
		min-width: 600px;
		border-bottom: 1px solid rgb(55 65 81);
	}

	/* Category button stays fixed on horizontal scroll */
	.category-row button {
		position: sticky;
		left: 0;
		background: rgb(31 41 55 0);
		width: fit-content;
	}

	/* Feature descriptions - smaller on mobile */
	.feature-description {
		font-size: 0.625rem;
		line-height: 1.2;
	}

	@media (min-width: 1024px) {
		.feature-description {
			font-size: 0.75rem;
		}
	}
</style>
