<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { type UseCase, type SetupRequest, USE_CASES } from '../../types/base';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength, minLength } from '$lib/shared/components/forms/validators';
	import { onboardingStore } from '../../stores/onboarding';
	import type { TextFieldType } from '$lib/shared/components/forms/types';
	import { get } from 'svelte/store';
	import { Plus, Trash2 } from 'lucide-svelte';
	import { trackEvent } from '$lib/shared/utils/analytics';

	let {
		isOpen = false,
		onClose,
		onSubmit,
		useCase = null
	}: {
		isOpen: boolean;
		onClose: () => void;
		onSubmit: (formData: SetupRequest) => void;
		useCase?: UseCase | null;
	} = $props();

	let loading = false;

	// Get use case config (default to company)
	let useCaseConfig = $derived(useCase ? USE_CASES[useCase] : USE_CASES.company);

	// Initialize form fields from store (for back navigation persistence)
	const storeState = onboardingStore.getState();
	const organizationName = field('organizationName', storeState.organizationName || '', [
		required(),
		maxLength(100)
	]);

	// Local state for network fields
	function newNetworkField(i: number, initialValue: string = ''): TextFieldType {
		let validators = [minLength(1)];
		if (i == 0) validators.push(required());
		return field(`network-${i}`, initialValue, validators);
	}

	function addNetwork() {
		networkFields = [...networkFields, newNetworkField(networkFields.length)];
	}

	function removeNetwork(index: number) {
		networkFields = networkFields.filter((_, i) => i !== index);
	}

	// Initialize network fields from store (for back navigation persistence)
	function initNetworkFields(): TextFieldType[] {
		const storedNetworks = storeState.networks;
		if (storedNetworks.length > 0 && storedNetworks.some((n) => n.name)) {
			return storedNetworks.map((n, i) => newNetworkField(i, n.name));
		}
		return [newNetworkField(0)];
	}

	let networkFields: TextFieldType[] = $state(initNetworkFields());

	function handleSubmit() {
		const formData: SetupRequest = {
			organization_name: $organizationName.value.trim(),
			networks: networkFields.map((n) => ({ name: get(n).value.trim() }))
		};

		trackEvent('onboarding_org_networks_selected', {
			networks_count: networkFields.length,
			use_case: useCase
		});

		// Update store with final values
		onboardingStore.setOrganizationName(formData.organization_name);
		onboardingStore.setNetworks(formData.networks);

		onSubmit(formData);
	}
</script>

<EditModal
	{isOpen}
	title={useCase === 'msp'
		? "Let's visualize your customers' networks!"
		: useCase === 'company'
			? "Let's visualize your networks!"
			: "Let's visualize your network!"}
	{loading}
	centerTitle={true}
	saveLabel="Continue"
	showCancel={false}
	showCloseButton={false}
	onSave={handleSubmit}
	showBackdrop={false}
	onCancel={onClose}
	size="lg"
	preventCloseOnClickOutside={true}
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<img
			src="https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png"
			alt="Scanopy Logo"
			class="h-8 w-8"
		/>
	</svelte:fragment>

	<!-- Content -->
	<div class="space-y-6">
		<TextInput
			label={useCaseConfig.orgLabel}
			id="organizationName"
			{formApi}
			placeholder={useCaseConfig.orgPlaceholder}
			helpText={useCase === 'homelab' ? '' : 'Your company, team, or project name'}
			required={true}
			field={organizationName}
		/>

		<div class="space-y-3">
			{#each networkFields as field, index (index)}
				<div class="flex items-center gap-2">
					<div class="flex-1">
						<TextInput
							label={index === 0 ? useCaseConfig.networkLabel : ''}
							id="network-{index}"
							{formApi}
							{field}
							required={index == 0}
							placeholder={useCaseConfig.networkPlaceholder}
							helpText={index === 0 && useCase === 'msp'
								? 'Each network represents a customer environment. One customer can have multiple networks.'
								: ''}
						/>
					</div>
					{#if index > 0}
						<button
							type="button"
							class="btn-icon-danger"
							onclick={() => removeNetwork(index)}
							aria-label="Remove network"
						>
							<Trash2 class="h-4 w-4" />
						</button>
					{/if}
				</div>
			{/each}

			{#if useCase && useCase != 'homelab'}
				<button
					type="button"
					class="text-secondary hover:text-primary flex items-center gap-1 text-sm transition-colors"
					onclick={addNetwork}
				>
					<Plus class="h-4 w-4" />
					Add another network
				</button>
			{/if}
		</div>
	</div>

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Continue Button (type="submit" triggers form validation) -->
			<button type="submit" disabled={loading} class="btn-primary w-full">
				{loading ? 'Setting up...' : 'Continue'}
			</button>
		</div>
	</svelte:fragment>
</EditModal>
