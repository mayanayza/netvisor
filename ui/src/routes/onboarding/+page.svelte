<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { ChevronLeft } from 'lucide-svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import OnboardingModal from '$lib/features/auth/components/OnboardingModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import CreateDaemonModal from '$lib/features/daemons/components/CreateDaemonModal.svelte';
	import type { OnboardingRequest, RegisterRequest } from '$lib/features/auth/types/base';
	import { submitSetup, submitDaemonSetup, register, checkAuth } from '$lib/features/auth/store';
	import { getOrganization } from '$lib/features/organizations/store';
	import { navigate } from '$lib/shared/utils/navigation';
	import { config } from '$lib/shared/stores/config';
	import { resolve } from '$app/paths';

	// URL params for invite flow
	let orgName = $derived($page.url.searchParams.get('org_name'));
	let invitedBy = $derived($page.url.searchParams.get('invited_by'));

	// Determine if this is an invite flow (skip setup, go straight to register)
	let isInviteFlow = $derived(!!invitedBy);

	// Check if server has integrated daemon (skip daemon setup step)
	let hasIntegratedDaemon = $derived($config?.has_integrated_daemon ?? false);

	// Step tracking: 'setup' | 'daemon' | 'register'
	type Step = 'setup' | 'daemon' | 'register';
	// Initialize based on invite params - use URL directly to avoid reactivity warning
	let currentStep = $state<Step>($page.url.searchParams.get('invited_by') ? 'register' : 'setup');

	// Store setup data for display in later steps
	let setupData = $state<OnboardingRequest | null>(null);

	// Store provisional network ID from setup
	let provisionalNetworkId = $state<string | null>(null);

	// Store provisional API key from daemon setup
	let provisionalApiKey = $state<string | null>(null);

	// Calculate step numbers for progress indicator
	// Invite flow: 1 step, Integrated daemon: 2 steps, Normal: 3 steps
	let totalSteps = $derived(isInviteFlow ? 1 : hasIntegratedDaemon ? 2 : 3);
	let currentStepNumber = $derived(() => {
		if (isInviteFlow) return 1;
		if (hasIntegratedDaemon) {
			// Only setup and register steps
			return currentStep === 'setup' ? 1 : 2;
		}
		switch (currentStep) {
			case 'setup':
				return 1;
			case 'daemon':
				return 2;
			case 'register':
				return 3;
		}
	});

	// Note: Auth check is handled by +layout.svelte - no need to check here

	async function handleSetupSubmit(formData: OnboardingRequest) {
		// Submit setup data to backend (stored in session)
		const result = await submitSetup(formData);
		if (result) {
			setupData = formData;
			provisionalNetworkId = result.network_id;
			// Skip daemon step if server has integrated daemon
			currentStep = hasIntegratedDaemon ? 'register' : 'daemon';
		}
	}

	async function handleDaemonSetup() {
		// Get daemon name from form (use default if not set)
		const daemonName = setupData?.network_name ? `${setupData.network_name} Daemon` : 'My Daemon';

		const result = await submitDaemonSetup({ daemon_name: daemonName });
		if (result) {
			provisionalApiKey = result.api_key;
		}
	}

	function handleBack() {
		if (currentStep === 'daemon') {
			currentStep = 'setup';
		} else if (currentStep === 'register') {
			// Go back to setup if daemon step is skipped, otherwise go to daemon
			currentStep = hasIntegratedDaemon ? 'setup' : 'daemon';
		}
	}

	function handleDaemonSkip() {
		// User skipped daemon setup - clear the flag
		if (typeof localStorage !== 'undefined') {
			localStorage.removeItem('pendingDaemonSetup');
		}
		currentStep = 'register';
	}

	function handleDaemonContinue() {
		// User chose to set up daemon - store flag for progress indicator
		if (typeof localStorage !== 'undefined') {
			localStorage.setItem('pendingDaemonSetup', 'true');
		}
		currentStep = 'register';
	}

	async function handleRegister(data: RegisterRequest) {
		const user = await register(data);
		if (!user) return;

		// Refresh auth state and organization
		await Promise.all([checkAuth(), getOrganization()]);

		// Navigate to correct destination (billing or main app)
		await navigate();
	}

	function handleSwitchToLogin() {
		goto(resolve('/login'));
	}

	function handleClose() {
		// Don't allow closing during onboarding
	}

	// Auto-generate API key when entering daemon step (skip if integrated daemon)
	$effect(() => {
		if (currentStep === 'daemon' && !provisionalApiKey && !hasIntegratedDaemon) {
			handleDaemonSetup();
		}
	});
</script>

<div class="relative flex min-h-screen flex-col items-center bg-gray-900 p-4">
	<!-- Background image with overlay -->
	<div class="absolute inset-0 z-0">
		<div
			class="h-full w-full bg-cover bg-center bg-no-repeat blur-sm"
			style="background-image: url('/images/diagram.png')"
		></div>
		<div class="absolute inset-0 bg-black/60"></div>
	</div>

	<!-- Progress Indicator - fixed position above modal (hidden for invite flow) -->
	{#if !isInviteFlow}
		<div class="fixed left-1/2 top-6 z-[200] -translate-x-1/2">
			<div
				class="flex items-center gap-2 rounded-full bg-gray-800/90 px-4 py-2 shadow-lg backdrop-blur-sm"
			>
				{#if currentStepNumber() > 1}
					<button
						type="button"
						onclick={handleBack}
						class="text-secondary hover:text-primary -ml-1 flex items-center transition-colors"
						aria-label="Go back"
					>
						<ChevronLeft class="h-4 w-4" />
					</button>
				{/if}
				<span class="text-secondary text-sm">
					Step {currentStepNumber()} of {totalSteps}
				</span>
				<div class="flex gap-1">
					<!-- eslint-disable-next-line @typescript-eslint/no-unused-vars -->
					{#each Array(totalSteps) as _, i (i)}
						<div
							class="h-2 w-2 rounded-full transition-colors {i < currentStepNumber()
								? 'bg-primary-500'
								: 'bg-gray-600'}"
						></div>
					{/each}
				</div>
			</div>
		</div>
	{/if}

	<!-- GitHub Stars - positioned absolutely at bottom -->
	<!-- <div class="absolute bottom-10 left-10 z-[100] hidden md:block">
		<GithubStars />
	</div> -->

	<!-- Modal container -->
	<div class="flex flex-1 items-center justify-center">
		<!-- Modal Content -->
		<div class="relative z-10">
			{#if currentStep === 'setup'}
				<OnboardingModal
					isOpen={true}
					onClose={handleClose}
					onSubmit={handleSetupSubmit}
					showLoginLink={true}
					onSwitchToLogin={handleSwitchToLogin}
				/>
			{:else if currentStep === 'daemon'}
				<CreateDaemonModal
					isOpen={true}
					onClose={handleClose}
					onboardingMode={true}
					onSkip={handleDaemonSkip}
					onContinue={handleDaemonContinue}
					{provisionalApiKey}
					{provisionalNetworkId}
				/>
			{:else if currentStep === 'register'}
				<RegisterModal
					isOpen={true}
					onRegister={handleRegister}
					onClose={handleClose}
					{orgName}
					{invitedBy}
				/>
			{/if}
		</div>
	</div>

	<Toast />
</div>
