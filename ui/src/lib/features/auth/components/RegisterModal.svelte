<script lang="ts">
	import type { RegisterRequest } from '../types/base';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import { required } from 'svelte-forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import { field } from 'svelte-forms';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import { emailValidator } from '$lib/shared/components/forms/validators';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { loadData } from '$lib/shared/utils/dataLoader';

	let {
		orgName = null,
		invitedBy = null,
		isOpen = false,
		onRegister,
		onClose,
		onSwitchToLogin = null
	}: {
		orgName?: string | null;
		invitedBy?: string | null;
		isOpen?: boolean;
		onRegister: (data: RegisterRequest) => Promise<void> | void;
		onClose: () => void;
		onSwitchToLogin?: (() => void) | null;
	} = $props();

	const loading = loadData([getConfig]);
	let registering = $state(false);

	let oidcProviders = $derived($loading ? [] : ($config?.oidc_providers ?? []));
	let hasOidcProviders = $derived(oidcProviders.length > 0);
	let enableEmailOptIn = $derived($loading ? false : ($config?.has_email_opt_in ?? false));

	let formData: RegisterRequest & { confirmPassword: string } = $state({
		email: '',
		password: '',
		confirmPassword: '',
		subscribed: true
	});

	const subscribedField = field('subscribed', true, []);

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
		const returnUrl = encodeURIComponent(window.location.origin);
		const subscribed = formData.subscribed ? '&subscribed=true' : '';
		window.location.href = `/api/auth/oidc/${providerSlug}/authorize?flow=register&return_url=${returnUrl}${subscribed}`;
	}

	function resetForm() {
		formData = {
			email: '',
			password: '',
			confirmPassword: '',
			subscribed: true
		};
	}

	async function handleSubmit() {
		registering = true;
		try {
			await onRegister({
				email: formData.email,
				password: formData.password,
				subscribed: formData.subscribed
			});
		} finally {
			registering = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Create your account"
	loading={registering || $loading}
	centerTitle={true}
	saveLabel="Create Account"
	showCancel={false}
	showCloseButton={false}
	onSave={handleSubmit}
	onCancel={onClose}
	size="md"
	preventCloseOnClickOutside={true}
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<img src="/logos/netvisor-logo.png" alt="NetVisor Logo" class="h-8 w-8" />
	</svelte:fragment>

	{#if orgName && invitedBy}
		<div class="mb-6">
			<InlineInfo
				title="You're invited!"
				body={`You have been invited to join ${orgName} by ${invitedBy}. Please sign in or register to continue.`}
			/>
		</div>
	{/if}

	<!-- Content -->
	<div class="space-y-6">
		<TextInput
			label="Email"
			id="email"
			{formApi}
			placeholder="Enter email"
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
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Create Account Button -->
			<button
				type="button"
				disabled={registering}
				onclick={handleSubmit}
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
							class="btn-secondary flex w-full items-center justify-center gap-3"
						>
							{#if provider.logo}
								<img src={provider.logo} alt={provider.name} class="h-5 w-5" />
							{/if}
							Sign up with {provider.name}
						</button>
					{/each}
				</div>
			{/if}

			{#if enableEmailOptIn}
				<div class="flex flex-grow items-center justify-center">
					<Checkbox
						field={subscribedField}
						label="Subscribe"
						{formApi}
						id="subscribe"
						helpText="Sign up for product updates via email"
					/>
				</div>
			{/if}

			<!-- Login Link -->
			{#if onSwitchToLogin}
				<div class="text-center">
					<p class="text-sm text-gray-400">
						Already have an account?
						<button
							type="button"
							onclick={onSwitchToLogin}
							class="font-medium text-blue-400 hover:text-blue-300"
						>
							Sign in here
						</button>
					</p>
				</div>
			{/if}
		</div>
	</svelte:fragment>
</EditModal>
