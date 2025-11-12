<script lang="ts">
	import { goto } from '$app/navigation';
	import { login, register } from '$lib/features/auth/store';
	import LoginModal from '$lib/features/auth/components/LoginModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import type { LoginRequest, RegisterRequest } from '$lib/features/auth/types/base';
	import { resolve } from '$app/paths';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import { config } from '$lib/shared/stores/config';
	import { getOrganization } from '$lib/features/organizations/store';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import { getCurrentBillingPlans } from '$lib/features/billing/store';

	let showLogin = true;

	$: billingEnabled = $config ? $config.billing_enabled : false;

	async function handleLogin(data: LoginRequest) {
		const user = await login(data);
		if (user) {
			const organization = await getOrganization(user.organization_id);

			if (billingEnabled && organization && !isBillingPlanActive(organization)) {
				await getCurrentBillingPlans();
				await goto(resolve('/billing'));
			} else if (billingEnabled && organization && isBillingPlanActive(organization)) {
				await goto(resolve('/'));
			} else {
				await goto(resolve('/'));
			}
		}
	}

	async function handleRegister(data: RegisterRequest) {
		const user = await register(data);
		if (user) {
			const organization = await getOrganization(user?.organization_id);

			if (billingEnabled && organization && !isBillingPlanActive(organization)) {
				await getCurrentBillingPlans();
				await goto(resolve('/billing'));
			} else if (billingEnabled && organization && isBillingPlanActive(organization)) {
				await goto(resolve('/'));
			} else {
				await goto(resolve('/'));
			}
		}
	}

	function switchToRegister() {
		showLogin = false;
	}

	function switchToLogin() {
		showLogin = true;
	}

	// Dummy onClose since we don't want to close these modals
	function handleClose() {}
</script>

<div class="relative flex min-h-screen items-center justify-center bg-gray-900">
	<!-- Background image with overlay -->
	<div class="absolute inset-0 z-0">
		<div 
			class="h-full w-full bg-cover bg-center bg-no-repeat"
			style="background-image: url('/path/to/your/image.jpg')"
		></div>
	</div>

	<!-- Content (sits above background) -->
	<div class="relative z-10">
		{#if showLogin}
			<LoginModal
				isOpen={true}
				onLogin={handleLogin}
				onClose={handleClose}
				onSwitchToRegister={switchToRegister}
			/>
		{:else}
			<RegisterModal
				isOpen={true}
				onRegister={handleRegister}
				onClose={handleClose}
				onSwitchToLogin={switchToLogin}
			/>
		{/if}
	</div>

	<Toast />
</div>