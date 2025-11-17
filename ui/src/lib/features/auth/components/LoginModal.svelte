<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { LoginRequest } from '../types/base';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { email as emailValidator, required } from 'svelte-forms/validators';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { field } from 'svelte-forms';
	import { minLength } from '$lib/shared/components/forms/validators';

	export let orgName: string | null = null;
	export let invitedBy: string | null = null;
	export let isOpen = false;
	export let onLogin: (data: LoginRequest) => Promise<void> | void;
	export let onClose: () => void;
	export let onSwitchToRegister: (() => void) | null = null;
	export let onSwitchToForgot: (() => void) | null = null;

	const loading = loadData([getConfig]);
	let signingIn = false;

	$: disableRegistration = $loading ? false : $config.disable_registration;
	$: enableOidc = $loading ? true : $config.oidc_enabled;

	let formData: LoginRequest = {
		email: '',
		password: ''
	};

	// Reset form when modal opens
	$: if (isOpen) {
		resetForm();
	}

	// Create form fields with validation
	const email = field('email', formData.email, [required(), emailValidator()]);
	const password = field('password', formData.password, [required(), minLength(12)]);

	// Update formData when field values change
	$: formData.email = $email.value;
	$: formData.password = $password.value;

	async function handleOidcLogin() {
		// Pass current URL as return_url parameter
		const returnUrl = encodeURIComponent(window.location.origin);
		window.location.href = `/api/auth/oidc/authorize?return_url=${returnUrl}`;
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
	title="Sign in to NetVisor"
	loading={$loading}
	centerTitle={true}
	saveLabel="Sign In"
	cancelLabel="Cancel"
	showCloseButton={false}
	showCancel={false}
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
	<div class="space-y-6">
		<div class="space-y-4">
			<TextInput
				label="Email"
				id="name"
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
			<!-- Sign In Button -->
			<button type="button" disabled={signingIn} on:click={handleSubmit} class="btn-primary w-full">
				{signingIn ? 'Signing in...' : 'Sign In with Email'}
			</button>

			<!-- Separator before OIDC -->
			{#if enableOidc}
				<div class="relative">
					<div class="absolute inset-0 flex items-center">
						<div class="w-full border-t border-gray-600"></div>
					</div>
					<div class="relative flex justify-center text-sm">
						<span class="bg-gray-900 px-2 text-gray-400">or</span>
					</div>
				</div>

				<!-- OIDC Button -->
				<button on:click={handleOidcLogin} class="btn-secondary w-full">
					Sign in with {$config.oidc_provider_name}
				</button>
			{/if}

			<!-- Register Link -->
			{#if onSwitchToRegister && !disableRegistration}
				<div class="text-center">
					<p class="text-sm text-gray-400">
						Don't have an account?
						<button
							type="button"
							on:click={onSwitchToRegister}
							class="font-medium text-blue-400 hover:text-blue-300"
						>
							Register here
						</button>
					</p>
				</div>
			{/if}
			<div class="text-center">
				<p class="text-sm text-gray-400">
					Forgot your password?
					<button
						type="button"
						on:click={onSwitchToForgot}
						class="font-medium text-blue-400 hover:text-blue-300"
					>
						Reset password
					</button>
				</p>
			</div>
		</div>
	</svelte:fragment>
</EditModal>
