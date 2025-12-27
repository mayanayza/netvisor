<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { LoginRequest } from '../types/base';
	import { config } from '$lib/shared/stores/config';
	import { required } from 'svelte-forms/validators';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { field } from 'svelte-forms';
	import { emailValidator } from '$lib/shared/components/forms/validators';

	let {
		orgName = null,
		invitedBy = null,
		demoMode = false,
		isOpen = false,
		onLogin,
		onClose,
		onSwitchToRegister = null,
		onSwitchToForgot = null
	}: {
		orgName?: string | null;
		invitedBy?: string | null;
		demoMode?: boolean;
		isOpen?: boolean;
		onLogin: (data: LoginRequest) => Promise<void> | void;
		onClose: () => void;
		onSwitchToRegister?: (() => void) | null;
		onSwitchToForgot?: (() => void) | null;
	} = $props();

	let signingIn = $state(false);

	let disableRegistration = $derived($config?.disable_registration ?? false);
	let oidcProviders = $derived($config?.oidc_providers ?? []);
	let hasOidcProviders = $derived(oidcProviders.length > 0);
	let enablePasswordReset = $derived($config?.has_email_service ?? false);

	let formData: LoginRequest = {
		email: '',
		password: ''
	};

	// Create form fields with validation
	const email = field('email', formData.email, [required(), emailValidator()]);
	const password = field('password', formData.password, [required()]);

	// Update formData when field values change
	$effect(() => {
		formData.email = $email.value;
	});

	$effect(() => {
		formData.password = $password.value;
	});

	// Reset form when modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function handleOidcLogin(providerSlug: string) {
		const returnUrl = encodeURIComponent(window.location.origin);
		window.location.href = `/api/auth/oidc/${providerSlug}/authorize?flow=login&return_url=${returnUrl}`;
	}

	function resetForm() {
		formData = {
			email: '',
			password: ''
		};
	}

	async function handleSubmit() {
		signingIn = true;
		try {
			await onLogin(formData);
		} finally {
			signingIn = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Sign in to Scanopy"
	loading={signingIn}
	centerTitle={true}
	saveLabel="Sign In"
	cancelLabel="Cancel"
	showCloseButton={false}
	showBackdrop={false}
	showCancel={false}
	onSave={handleSubmit}
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

	{#if demoMode}
		<div class="mb-6">
			<InlineInfo
				title="Demo Mode"
				body="You're about to log in to a demo account. Use the credentials below to explore Scanopy. Note that some actions are disabled in demo mode."
			/>
			<div class="mt-3 rounded-md bg-gray-800 p-3 font-mono text-sm">
				<div class="text-secondary">
					<span class="text-gray-400">Email:</span>
					<span class="text-primary ml-2">demo@scanopy.net</span>
				</div>
				<div class="text-secondary mt-1">
					<span class="text-gray-400">Password:</span>
					<span class="text-primary ml-2">password123</span>
				</div>
			</div>
		</div>
	{:else if orgName && invitedBy}
		<div class="mb-6">
			<InlineInfo
				title="You're invited!"
				body={`You have been invited to join ${orgName} by ${invitedBy}. Please sign in or register to continue.`}
			/>
		</div>
	{/if}
	<div class="space-y-6">
		<div class="space-y-4">
			<TextInput
				label="Email"
				id="email"
				{formApi}
				placeholder="Enter your email"
				required={true}
				field={email}
			/>

			<TextInput
				label="Password"
				id="password"
				type="password"
				{formApi}
				placeholder="Enter your password"
				required={true}
				field={password}
			/>
		</div>
	</div>

	<!-- Custom footer with register link -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Sign In Button (type="submit" triggers form validation) -->
			<button type="submit" disabled={signingIn} class="btn-primary w-full">
				{signingIn ? 'Signing in...' : 'Sign In with Email'}
			</button>

			<!-- OIDC Providers -->
			{#if hasOidcProviders && !demoMode}
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
							onclick={() => handleOidcLogin(provider.slug)}
							class="btn-secondary flex w-full items-center justify-center gap-3"
						>
							{#if provider.logo}
								<img src={provider.logo} alt={provider.name} class="h-5 w-5" />
							{/if}
							Sign in with {provider.name}
						</button>
					{/each}
				</div>
			{/if}

			<!-- Register Link (hidden in demo mode) -->
			{#if onSwitchToRegister && !disableRegistration && !demoMode}
				<div class="text-center">
					<p class="text-sm text-gray-400">
						Don't have an account?
						<button
							type="button"
							onclick={onSwitchToRegister}
							class="font-medium text-blue-400 hover:text-blue-300"
						>
							Register here
						</button>
					</p>
				</div>
			{/if}
			{#if enablePasswordReset && !demoMode}
				<div class="text-center">
					<p class="text-sm text-gray-400">
						Forgot your password?
						<button
							type="button"
							onclick={onSwitchToForgot}
							class="font-medium text-blue-400 hover:text-blue-300"
						>
							Reset password
						</button>
					</p>
				</div>
			{/if}
		</div>
	</svelte:fragment>
</EditModal>
