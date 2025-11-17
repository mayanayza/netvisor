<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { LoginRequest } from '../types/base';
	import LoginForm from './LoginForm.svelte';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';

	export let orgName: string | null = null;
	export let invitedBy: string | null = null;
	export let isOpen = false;
	export let onLogin: (data: LoginRequest) => Promise<void> | void;
	export let onClose: () => void;
	export let onSwitchToRegister: (() => void) | null = null;

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
		<InlineInfo
			title="You're invited!"
			body={`You have been invited to join ${orgName} by ${invitedBy}. Please sign in or register to continue.`}
		/>
	{/if}
	<!-- Content (remove padding to eliminate gap) -->
	<LoginForm {formApi} bind:formData />

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
		</div>
	</svelte:fragment>
</EditModal>
