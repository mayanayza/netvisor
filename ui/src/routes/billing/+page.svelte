<script lang="ts">
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import BillingPlanForm from '$lib/features/billing/BillingPlanForm.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getConfig } from '$lib/shared/stores/config';
	import { getMetadata } from '$lib/shared/stores/metadata';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import { getCurrentBillingPlans } from '$lib/features/billing/store';

	const loading = loadData([getCurrentBillingPlans, getConfig, getMetadata], { loadingDelay: 0 });
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
		</div>

		<!-- Content (sits above background) -->
		<div class="flex min-h-screen items-center justify-center">
			<div class="relative z-10">
				<BillingPlanForm />
			</div>
		</div>

		<Toast />
	</div>
{/if}
