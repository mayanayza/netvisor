<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import { required } from 'svelte-forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import { field } from 'svelte-forms';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineSuccess from '$lib/shared/components/feedback/InlineSuccess.svelte';
	import { emailValidator } from '$lib/shared/components/forms/validators';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { config } from '$lib/shared/stores/config';
	import { onboardingStore } from '../stores/onboarding';
	import type { RegisterRequest } from '../types/base';

	let {
		orgName = null,
		invitedBy = null,
		isOpen = false,
		onRegister,
		onClose
	}: {
		orgName?: string | null;
		invitedBy?: string | null;
		isOpen?: boolean;
		onRegister: (data: RegisterRequest, subscribed: boolean) => Promise<void> | void;
		onClose: () => void;
	} = $props();

	let registering = $state(false);

	let oidcProviders = $derived($config?.oidc_providers ?? []);
	let hasOidcProviders = $derived(oidcProviders.length > 0);
	let enableEmailOptIn = $derived($config?.has_email_opt_in ?? false);
	let enableTermsCheckbox = $derived($config?.billing_enabled ?? false);

	// Get networks with daemon setups that will scan after registration
	let networksWithDaemons = $derived.by(() => {
		const networks = $onboardingStore.networks;
		const daemonSetups = $onboardingStore.daemonSetups;

		// Find networks where user chose to install a daemon (installNow = true)
		return networks.filter((n) => {
			if (!n.id) return false;
			const setup = daemonSetups.get(n.id);
			return setup?.installNow === true;
		});
	});

	let hasPendingDaemons = $derived(networksWithDaemons.length > 0);
	let pendingNetworkNames = $derived(networksWithDaemons.map((n) => n.name).join(', '));

	let formData: RegisterRequest & { confirmPassword: string } = $state({
		email: '',
		password: '',
		confirmPassword: '',
		subscribed: true,
		terms_accepted: false
	});

	const subscribedField = field('subscribed', true, []);
	const termsField = field('terms', false, []);

	// Create form fields with validation
	const email = field('email', '', [required(), emailValidator()]);

	// Update formData when field values change
	$effect(() => {
		formData.email = $email.value;
	});

	// Reset form when modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function handleOidcRegister(providerSlug: string) {
		// Store subscribed preference for post-registration Plunk tracking
		if ($subscribedField.value) {
			sessionStorage.setItem('pendingPlunkRegistration', 'true');
		}

		const returnUrl = encodeURIComponent(window.location.origin);
		window.location.href = `/api/auth/oidc/${providerSlug}/authorize?flow=register&return_url=${returnUrl}&terms_accepted=${enableTermsCheckbox && $termsField.value}`;
	}

	function resetForm() {
		formData = {
			email: '',
			password: '',
			confirmPassword: '',
			terms_accepted: false
		};
	}

	async function handleSubmit() {
		registering = true;
		try {
			await onRegister(
				{
					email: formData.email,
					password: formData.password,
					terms_accepted: enableTermsCheckbox && $termsField.value
				},
				$subscribedField.value
			);
		} finally {
			registering = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Create your account"
	loading={registering}
	centerTitle={true}
	saveLabel="Create Account"
	showCancel={false}
	showCloseButton={false}
	onSave={handleSubmit}
	showBackdrop={false}
	onCancel={onClose}
	size="md"
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

	{#if orgName && invitedBy}
		<div class="mb-6">
			<InlineInfo
				title="You're invited!"
				body={`You have been invited to join ${orgName} by ${invitedBy}. Please sign in or register to continue.`}
			/>
		</div>
	{/if}

	{#if hasPendingDaemons}
		<div class="mb-6">
			<InlineSuccess
				title="Ready to scan"
				body={networksWithDaemons.length === 1
					? `Once installed, your daemon for "${pendingNetworkNames}" will begin scanning, and your visualization will start building, after you register.`
					: `Once installed, your daemons for "${pendingNetworkNames}" will begin scanning, and your visualization will start building, after you register.`}
			/>
		</div>
	{/if}

	<!-- Content -->
	<div class="space-y-6">
		<TextInput
			label="Email"
			id="email"
			{formApi}
			placeholder="Enter your email"
			required={true}
			field={email}
		/>

		<Password
			{formApi}
			bind:value={formData.password}
			bind:confirmValue={formData.confirmPassword}
			showConfirm={true}
		/>
	</div>

	<!-- Custom footer -->
	<svelte:fragment slot="footer" let:formApi>
		<div class="flex w-full flex-col gap-4">
			<div class="flex flex-grow flex-col items-center gap-2">
				{#if enableTermsCheckbox}
					<Checkbox
						label="I agree to the <a class='text-link' target='_blank' href='https://scanopy.net/terms'>terms</a> and <a target='_blank' class='text-link'href='https://scanopy.net/privacy'>privacy policy</a>"
						helpText=""
						{formApi}
						required={true}
						field={termsField}
						id="terms"
					/>
				{/if}
			</div>

			<!-- Create Account Button (type="submit" triggers form validation) -->
			<button
				type="submit"
				disabled={registering || (enableTermsCheckbox && !$termsField.value)}
				class="btn-primary w-full"
			>
				{registering ? 'Creating account...' : 'Create Account with Email'}
			</button>

			<!-- OIDC Providers -->
			{#if hasOidcProviders}
				<div class="relative">
					<div class="absolute inset-0 flex items-center">
						<div class="w-full border-t border-gray-600"></div>
					</div>
					<div class="relative flex justify-center text-sm">
						<span class="bg-gray-900 px-2 text-gray-400">or</span>
					</div>
				</div>

				<div class="space-y-2">
					{#each oidcProviders as provider (provider.slug)}
						<button
							onclick={() => handleOidcRegister(provider.slug)}
							disabled={enableTermsCheckbox && !$termsField.value}
							type="button"
							class="btn-secondary flex w-full items-center justify-center gap-3"
						>
							{#if provider.logo}
								<img src={provider.logo} alt={provider.name} class="h-5 w-5" />
							{/if}
							Create Account with {provider.name}
						</button>
					{/each}
				</div>
			{/if}

			<div class="flex flex-grow flex-col items-center gap-2">
				{#if enableEmailOptIn}
					<Checkbox
						field={subscribedField}
						label="Sign up for product updates via email"
						{formApi}
						id="subscribe"
						helpText=""
					/>
				{/if}
			</div>
		</div>
	</svelte:fragment>
</EditModal>
