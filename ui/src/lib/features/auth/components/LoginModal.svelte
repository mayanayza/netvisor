<script lang="ts">
	import { LogIn } from 'lucide-svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import type { LoginRequest } from '../types/base';
	import LoginForm from './LoginForm.svelte';

	export let isOpen = false;
	export let onLogin: (data: LoginRequest) => Promise<void> | void;
	export let onClose: () => void;
	export let onSwitchToRegister: (() => void) | null = null;

	let loading = false;

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
		loading = true;
		try {
			await onLogin(formData);
		} finally {
			loading = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Sign in to NetVisor"
	{loading}
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
		<ModalHeaderIcon Icon={LogIn} color="#3b82f6" />
	</svelte:fragment>

	<!-- Content -->
	<LoginForm {formApi} bind:formData />

	<!-- Custom footer with register link -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Sign In Button -->
			<button type="button" disabled={loading} on:click={handleSubmit} class="btn-primary w-full">
				{loading ? 'Signing in...' : 'Sign In'}
			</button>

			<!-- OIDC Button -->
			<div>
				<button on:click={handleOidcLogin} class="btn-secondary w-full">
					Sign in with OIDC Provider
				</button>
			</div>

			<!-- Register Link -->
			{#if onSwitchToRegister}
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
