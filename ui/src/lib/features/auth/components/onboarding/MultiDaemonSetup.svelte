<script lang="ts">
	import { ChevronDown, ChevronRight, Check, CalendarClock } from 'lucide-svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import CreateDaemonForm from '$lib/features/daemons/components/CreateDaemonForm.svelte';
	import { submitDaemonSetup } from '../../store';
	import { onboardingStore } from '../../stores/onboarding';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import type { NetworkSetup } from '../../types/base';
	import type { FormApi } from '$lib/shared/components/forms/types';

	// Convert string to kebab-case
	function toKebabCase(str: string): string {
		return str
			.toLowerCase()
			.replace(/[^a-z0-9]+/g, '-')
			.replace(/^-+|-+$/g, '');
	}

	export let isOpen: boolean;
	export let networks: NetworkSetup[];
	export let onComplete: () => void;
	export let onClose: () => void;

	interface NetworkCardState {
		choice: 'pending' | 'install_now' | 'install_later';
		apiKey: string | null;
		isExpanded: boolean;
		isLoading: boolean;
	}

	// Initialize card state for each network
	let cardStates: Record<string, NetworkCardState> = {};

	// References to CreateDaemonForm components for getting daemon names
	let daemonFormRefs: Record<string, CreateDaemonForm> = {};

	$: {
		// Initialize states for new networks
		networks.forEach((network) => {
			if (network.id && !cardStates[network.id]) {
				cardStates[network.id] = {
					choice: 'pending',
					apiKey: null,
					isExpanded: false,
					isLoading: false
				};
			}
		});
	}

	// Create a simple formApi for each network (fields still work, just not integrated with parent form)
	function createFormApi(): FormApi {
		return {
			registerField: () => {},
			unregisterField: () => {}
		};
	}

	async function handleInstallNow(networkId: string) {
		const state = cardStates[networkId];
		if (!state) return;

		const daemonName = daemonFormRefs[networkId]?.getDaemonName() ?? 'daemon';

		cardStates[networkId] = { ...state, isLoading: true };

		const result = await submitDaemonSetup({
			daemon_name: daemonName,
			network_id: networkId,
			install_later: false
		});

		if (result) {
			cardStates[networkId] = {
				...state,
				choice: 'install_now',
				apiKey: result.api_key ?? null,
				isExpanded: true,
				isLoading: false
			};

			// Update onboarding store
			onboardingStore.setDaemonSetup(networkId, {
				name: daemonName,
				installNow: true,
				apiKey: result.api_key ?? undefined
			});

			// Track daemon choice
			trackEvent('onboarding_daemon_choice', {
				choice: 'install_now',
				use_case: onboardingStore.getState().useCase
			});
		} else {
			cardStates[networkId] = { ...state, isLoading: false };
		}
	}

	async function handleInstallLater(networkId: string) {
		const state = cardStates[networkId];
		if (!state) return;

		const daemonName = daemonFormRefs[networkId]?.getDaemonName() ?? 'daemon';

		cardStates[networkId] = { ...state, isLoading: true };

		const result = await submitDaemonSetup({
			daemon_name: daemonName,
			network_id: networkId,
			install_later: true
		});

		if (result) {
			cardStates[networkId] = {
				...state,
				choice: 'install_later',
				isExpanded: false,
				isLoading: false
			};

			// Update onboarding store
			onboardingStore.setDaemonSetup(networkId, {
				name: daemonName,
				installNow: false
			});

			// Track daemon choice
			trackEvent('onboarding_daemon_choice', {
				choice: 'install_later',
				use_case: onboardingStore.getState().useCase
			});
		} else {
			cardStates[networkId] = { ...state, isLoading: false };
		}
	}

	function toggleExpanded(networkId: string) {
		const state = cardStates[networkId];
		if (state && state.choice === 'install_now') {
			cardStates[networkId] = { ...state, isExpanded: !state.isExpanded };
		}
	}

	// Check if all networks have been configured
	$: allConfigured = networks.every((n) => n.id && cardStates[n.id]?.choice !== 'pending');
</script>

<GenericModal
	{isOpen}
	title="Start scanning your network"
	{onClose}
	size="xl"
	showCloseButton={false}
	preventCloseOnClickOutside={true}
>
	<div class="space-y-6">
		<p class="text-secondary text-sm">
			Install a daemon on any device on your network to start discovering hosts and services. We
			recommend installing at least one now so you can see your network visualized immediately after
			registration.
		</p>

		<InlineInfo
			title="Daemons activate after account creation"
			body="If you install a daemon now, it'll connect and start mapping your network automatically after you register."
		/>

		<!-- Network cards -->
		<div class="space-y-4">
			{#each networks as network (network.id)}
				{#if network.id}
					{@const state = cardStates[network.id]}
					{#if state}
						<div class="card overflow-hidden">
							<!-- Header -->
							<div class="flex items-center justify-between">
								<div class="flex items-center gap-3">
									{#if state.choice == 'install_now'}
										<div
											class="flex h-6 w-6 items-center justify-center rounded-full bg-success/20"
										>
											<Check class="h-5 w-5 text-success" />
										</div>
									{:else if state.choice == 'install_later'}
										<div class="bg-gray/20 flex h-6 w-6 items-center justify-center rounded-full">
											<CalendarClock class="text-tertiary h-5 w-5" />
										</div>
									{/if}
									<div>
										<span class="text-secondary">Network: {network.name}</span>
										{#if state.choice === 'install_later'}
											<div class="text-tertiary text-xs">
												You can install this daemon later by going to the Daemons tab and selecting
												"Create Daemon"
											</div>
										{:else if state.choice === 'install_now'}
											<div class="text-xs text-success">
												Use the configuration tool below to install your daemon.
											</div>
										{/if}
									</div>
								</div>

								<div class="flex items-center gap-2">
									{#if state.choice === 'install_now' && network.id}
										<button
											type="button"
											class="btn-secondary"
											on:click={() => network.id && handleInstallLater(network.id)}
										>
											Install Later
										</button>
										<button
											type="button"
											class="text-secondary hover:text-primary p-1"
											on:click={() => network.id && toggleExpanded(network.id)}
										>
											{#if state.isExpanded}
												<ChevronDown class="h-5 w-5" />
											{:else}
												<ChevronRight class="h-5 w-5" />
											{/if}
										</button>
									{:else if state.choice === 'install_later' && network.id}
										<button
											type="button"
											class="btn-secondary"
											on:click={() => network.id && handleInstallNow(network.id)}
										>
											Install Now
										</button>
									{/if}
								</div>
							</div>

							<!-- Daemon configuration form -->
							<div class={`space-y-4 ${state.choice == 'install_now' ? 'mt-4' : ''}`}>
								{#if state.choice == 'pending' || (state.choice == 'install_now' && state.isExpanded && state.apiKey && network.id)}
									<CreateDaemonForm
										bind:this={daemonFormRefs[network.id]}
										formApi={createFormApi()}
										daemon={null}
										networkId={network.id}
										apiKey={state.apiKey}
										showAdvanced={state.choice == 'install_now'}
										initialName={toKebabCase(network.name) + '-daemon'}
										showModeSelect={state.choice == 'install_now'}
									/>
								{/if}

								{#if state.choice == 'pending'}
									<div class="flex gap-2">
										<button
											type="button"
											class="btn-secondary flex-1"
											disabled={state.isLoading}
											on:click={() => network.id && handleInstallLater(network.id)}
										>
											Install Later
										</button>
										<button
											type="button"
											class="btn-primary flex-1"
											disabled={state.isLoading}
											on:click={() => network.id && handleInstallNow(network.id)}
										>
											{state.isLoading ? 'Setting up...' : 'Install Now'}
										</button>
									</div>
								{/if}
							</div>
						</div>
					{/if}
				{/if}
			{/each}
		</div>
	</div>

	<svelte:fragment slot="footer">
		<div class="flex justify-end">
			<button type="button" class="btn-primary" disabled={!allConfigured} on:click={onComplete}>
				{allConfigured ? 'Continue to Registration' : 'Configure remaining daemons to continue'}
			</button>
		</div>
	</svelte:fragment>
</GenericModal>
