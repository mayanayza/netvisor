<script lang="ts">
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { ChevronLeft } from 'lucide-svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import OrgNetworksModal from '$lib/features/auth/components/onboarding/OrgNetworksModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import UseCaseStep from '$lib/features/auth/components/onboarding/UseCaseStep.svelte';
	import BlockerFlow from '$lib/features/auth/components/onboarding/BlockerFlow.svelte';
	import MultiDaemonSetup from '$lib/features/auth/components/onboarding/MultiDaemonSetup.svelte';
	import type { RegisterRequest, SetupRequest } from '$lib/features/auth/types/base';
	import { useSetupMutation, useRegisterMutation } from '$lib/features/auth/queries';
	import { fetchOrganization } from '$lib/features/organizations/queries';
	import { navigate } from '$lib/shared/utils/navigation';
	import { config, isSelfHosted } from '$lib/shared/stores/config';
	import { resolve } from '$app/paths';
	import { onboardingStore } from '$lib/features/auth/stores/onboarding';
	import { setPreferredNetwork } from '$lib/features/topology/store';
	import { trackEvent, trackPlunkEvent } from '$lib/shared/utils/analytics';

	// TanStack Query mutations
	const setupMutation = useSetupMutation();
	const registerMutation = useRegisterMutation();

	// URL params for invite flow
	let orgName = $derived($page.url.searchParams.get('org_name'));
	let invitedBy = $derived($page.url.searchParams.get('invited_by'));

	// Determine if this is an invite flow (skip to register)
	let isInviteFlow = $derived(!!invitedBy);

	// Check if server has integrated daemon (skip daemon setup step)
	let hasIntegratedDaemon = $derived($config?.has_integrated_daemon ?? false);

	// Step tracking
	type Step = 'use_case' | 'blocker' | 'setup' | 'daemon' | 'register';
	// Initialize based on invite params
	let currentStep = $state<Step>(
		$page.url.searchParams.get('invited_by') ? 'register' : 'use_case'
	);

	// Get use case from store
	let useCase = $derived($onboardingStore.useCase);
	let networks = $derived($onboardingStore.networks);

	// Calculate total steps based on flow
	// Cloud: use_case -> (blocker?) -> setup -> daemon -> register = 4-5 steps
	// Self-hosted with integrated daemon: use_case -> setup -> register = 3 steps
	// Self-hosted without integrated daemon: use_case -> setup -> daemon -> register = 4 steps
	// Invite: just register = 1 step
	let totalSteps = $derived(() => {
		if (isInviteFlow) return 1;
		if ($config && isSelfHosted($config)) {
			return hasIntegratedDaemon ? 3 : 4;
		}
		// Cloud
		return hasIntegratedDaemon ? 3 : 4;
	});

	let currentStepNumber = $derived(() => {
		if (isInviteFlow) return 1;

		const stepMap: Record<Step, number> = {
			use_case: 1,
			blocker: 1, // Blocker doesn't count as a separate step in progress
			setup: 2,
			daemon: 3,
			register: hasIntegratedDaemon ? 3 : 4
		};
		return stepMap[currentStep];
	});

	// Note: Auth check is handled by +layout.svelte

	function handleUseCaseNext() {
		currentStep = 'setup';
	}

	function handleBlockerFlow() {
		currentStep = 'blocker';
	}

	function handleBlockerResolved() {
		currentStep = 'setup';
	}

	async function handleSetupSubmit(formData: SetupRequest) {
		try {
			// Submit setup data to backend (stored in session)
			const result = await setupMutation.mutateAsync(formData);
			// Update store with network IDs
			onboardingStore.setNetworkIds(result.network_ids);
			// Skip daemon step if server has integrated daemon
			currentStep = hasIntegratedDaemon ? 'register' : 'daemon';
		} catch {
			// Error handled by mutation
		}
	}

	function handleDaemonComplete() {
		currentStep = 'register';
	}

	function handleBack() {
		switch (currentStep) {
			case 'blocker':
				currentStep = 'use_case';
				break;
			case 'setup':
				currentStep = 'use_case';
				break;
			case 'daemon':
				currentStep = 'setup';
				break;
			case 'register':
				currentStep = hasIntegratedDaemon ? 'setup' : 'daemon';
				break;
		}
	}

	async function handleRegister(data: RegisterRequest, subscribed: boolean) {
		try {
			// Extract subscribed for Plunk, send rest to backend
			const user = await registerMutation.mutateAsync(data);

			// Track registration in Plunk for email marketing
			trackPlunkEvent('register', user.email, subscribed);

			// Before clearing onboarding store, get state for tracking and network preference
			const state = onboardingStore.getState();

			// Track successful registration with context
			const daemonsInstalled = Array.from(state.daemonSetups.values()).filter(
				(d) => d.installNow
			).length;
			trackEvent('onboarding_registration_completed', {
				use_case: state.useCase,
				daemons_installed: daemonsInstalled
			});

			// Set preferred network for topology view
			// This ensures the topology tab shows the network being scanned
			const networkWithDaemon = state.networks.find((n) => {
				if (!n.id) return false;
				const setup = state.daemonSetups.get(n.id);
				return setup?.installNow === true;
			});
			if (networkWithDaemon?.id) {
				setPreferredNetwork(networkWithDaemon.id);
			}

			// Fetch organization data before navigating
			await fetchOrganization();

			// Clear onboarding store
			onboardingStore.reset();

			// Navigate to correct destination (billing or main app)
			await navigate();
		} catch {
			// Error handled by mutation
		}
	}

	function handleSwitchToLogin() {
		goto(resolve('/login'));
	}

	function handleClose() {
		// Don't allow closing during onboarding
	}
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
				{#if currentStepNumber() > 1 && currentStep !== 'blocker'}
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
					Step {currentStepNumber()} of {totalSteps()}
				</span>
				<div class="flex gap-1">
					<!-- eslint-disable-next-line @typescript-eslint/no-unused-vars -->
					{#each Array(totalSteps()) as _, i (i)}
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

	<!-- Content container -->
	<div class="flex flex-1 items-center justify-center">
		<div class="relative z-10 w-full">
			{#if currentStep === 'use_case'}
				<!-- Use Case Selection Step -->
				<UseCaseStep
					isOpen={true}
					onNext={handleUseCaseNext}
					onBlockerFlow={handleBlockerFlow}
					onClose={handleClose}
					onSwitchToLogin={handleSwitchToLogin}
				/>
			{:else if currentStep === 'blocker'}
				<!-- Blocker Resolution Flow (Cloud users only) -->
				<BlockerFlow
					isOpen={true}
					useCase={useCase ?? 'homelab'}
					onResolved={handleBlockerResolved}
					onClose={handleClose}
				/>
			{:else if currentStep === 'setup'}
				<!-- Organization & Network Setup -->
				<OrgNetworksModal
					isOpen={true}
					onClose={handleClose}
					onSubmit={handleSetupSubmit}
					{useCase}
				/>
			{:else if currentStep === 'daemon'}
				<!-- Multi-Network Daemon Setup -->
				<MultiDaemonSetup
					isOpen={true}
					{networks}
					onComplete={handleDaemonComplete}
					onClose={handleClose}
				/>
			{:else if currentStep === 'register'}
				<!-- Registration -->
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
