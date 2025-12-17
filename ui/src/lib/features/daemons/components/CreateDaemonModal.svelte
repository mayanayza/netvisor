<script lang="ts">
	import { networks } from '$lib/features/networks/store';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { entities } from '$lib/shared/stores/metadata';
	import { writable, type Writable } from 'svelte/store';
	import type { Daemon } from '../types/base';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import { RotateCcwKey, SatelliteDish } from 'lucide-svelte';
	import { createEmptyApiKeyFormData, createNewApiKey } from '$lib/features/api_keys/store';
	import { config } from '$lib/shared/stores/config';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import CreateDaemonForm from './CreateDaemonForm.svelte';

	export let isOpen = false;
	export let onClose: () => void;
	export let daemon: Daemon | null = null;

	// Onboarding mode props
	export let onboardingMode = false;
	export let onSkip: (() => void) | null = null;
	export let onContinue: (() => void) | null = null;
	export let provisionalApiKey: string | null = null;
	export let provisionalNetworkId: string | null = null;

	let keyStore: Writable<string | null> = writable(null);
	// In onboarding mode, use the provisionalApiKey; otherwise use keyStore
	$: key = onboardingMode ? provisionalApiKey : $keyStore;
	// In onboarding mode, use the provisionalNetworkId; otherwise use first network or daemon's network
	let selectedNetworkId = '';

	$: if (daemon) {
		selectedNetworkId = daemon.network_id;
	} else if (onboardingMode && provisionalNetworkId) {
		selectedNetworkId = provisionalNetworkId;
	} else if (!selectedNetworkId && $networks[0]?.id) {
		selectedNetworkId = $networks[0].id;
	}

	let serverUrl = $config.public_url;

	// Reference to CreateDaemonForm for getting daemon name
	let daemonFormRef: CreateDaemonForm;

	function handleOnClose() {
		keyStore.set(null);
		onClose();
	}

	async function handleCreateNewApiKey() {
		const daemonName = daemonFormRef?.getDaemonName() ?? 'daemon';
		let newApiKey = createEmptyApiKeyFormData();
		newApiKey.network_id = selectedNetworkId;
		newApiKey.name = `${daemonName} Api Key`;

		const generatedKey = await createNewApiKey(newApiKey);
		if (generatedKey) {
			keyStore.set(generatedKey);
		} else {
			pushError('Failed to generate API key');
		}
	}

	// For existing daemon with new key - simple run command
	$: existingDaemonRunCommand =
		daemon && key ? `sudo scanopy-daemon --server-url ${serverUrl} --daemon-api-key ${key}` : '';

	let colorHelper = entities.getColorHelper('Daemon');
</script>

<EditModal
	{isOpen}
	title={onboardingMode ? 'Set up network scanning' : 'Create Daemon'}
	cancelLabel={onboardingMode ? 'Continue' : 'Close'}
	onCancel={onboardingMode && onContinue ? onContinue : handleOnClose}
	showSave={false}
	showBackdrop={onboardingMode}
	size="xl"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		{#if onboardingMode}
			<ModalHeaderIcon Icon={SatelliteDish} color="#10b981" />
		{:else}
			<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.string} />
		{/if}
	</svelte:fragment>

	<div class="space-y-4">
		{#if onboardingMode}
			<!-- Onboarding mode: show info banner -->
			<InlineInfo
				title="Your daemon will activate after account creation"
				body="To visualize your network, Scanopy needs to discover what's on it. Install the daemon below—after registration, it'll connect and start mapping automatically."
			/>
		{:else if !daemon}
			<SelectNetwork bind:selectedNetworkId />
		{/if}

		<!-- Use the extracted CreateDaemonForm component -->
		<CreateDaemonForm
			bind:this={daemonFormRef}
			{formApi}
			{daemon}
			networkId={selectedNetworkId}
			apiKey={key}
			showAdvanced={!onboardingMode || !!key}
		/>

		<!-- API Key Section (hidden in onboarding mode) -->
		{#if !onboardingMode && !daemon}
			<div class="pb-2">
				<div class="flex items-start gap-2">
					<button
						class="btn-primary m-1 flex-shrink-0 self-stretch"
						disabled={!!key}
						type="button"
						on:click={handleCreateNewApiKey}
					>
						<RotateCcwKey />
						<span>Generate Key</span>
					</button>

					<div class="flex-1">
						<CodeContainer
							language="bash"
							expandable={false}
							code={key ? key : 'Press Generate Key...'}
						/>
					</div>
				</div>
				{#if !key}
					<div class="text-tertiary mt-1 text-xs">
						This will create a new API key, which you can manage later in the API Keys tab.
					</div>
				{/if}
			</div>
		{/if}

		<!-- Existing daemon with new key warning -->
		{#if daemon && key && selectedNetworkId}
			<InlineWarning
				title="This API key will not be available once you close this modal. Please use the provided run command or update your docker compose with the API key as depicted below."
			/>

			<div class="text-secondary mt-3">
				<b>Option 1.</b> Stop the daemon process, and use this command to start it
			</div>
			<CodeContainer language="bash" expandable={false} code={existingDaemonRunCommand} />
			<div class="text-secondary mt-3">
				<b>Option 2.</b> Stop the daemon container, and add this environment variable
			</div>
			<CodeContainer
				language="bash"
				expandable={false}
				code={`- SCANOPY_DAEMON_API_KEY=${key}\n`}
			/>
		{/if}
	</div>

	<!-- Custom footer for onboarding mode -->
	<svelte:fragment slot="footer">
		{#if onboardingMode}
			<div class="flex w-full items-center justify-between gap-4">
				{#if onSkip}
					<button type="button" class="btn-secondary" on:click={onSkip}>
						I'll do this later
					</button>
				{/if}
				<button type="button" class="btn-primary ml-auto" on:click={onContinue ?? handleOnClose}>
					Continue
				</button>
			</div>
		{/if}
	</svelte:fragment>
</EditModal>
