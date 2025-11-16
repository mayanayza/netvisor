<script lang="ts">
	import type { RegisterRequest } from '../types/base';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import RegisterForm from './RegisterForm.svelte';

	export let orgName: string | null = null;
	export let invitedBy: string | null = null;
	export let isOpen = false;
	export let onRegister: (data: RegisterRequest) => Promise<void> | void;
	export let onClose: () => void;
	export let onSwitchToLogin: (() => void) | null = null;

	let loading = false;

	let formData: RegisterRequest & { confirmPassword: string } = {
		email: '',
		password: '',
		confirmPassword: ''
	};

	// Reset form when modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = {
			email: '',
			password: '',
			confirmPassword: ''
		};
	}

	async function handleSubmit() {
		loading = true;
		try {
			// Only pass username and password to onRegister
			await onRegister({
				email: formData.email,
				password: formData.password
			});
		} finally {
			loading = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title="Create your account"
	{loading}
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
		<div class="mb-4 rounded-lg border border-blue-500/50 bg-blue-900/20 p-4 text-center">
			<p class="text-sm text-blue-200">
				You have been invited to join<br />
				<span class="font-semibold">{orgName}</span> by
				<span class="font-semibold">{invitedBy}</span>
			</p>
		</div>
	{/if}

	<!-- Content -->
	<RegisterForm {formApi} bind:formData />

	<!-- Custom footer with login link -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Create Account Button -->
			<button type="button" disabled={loading} on:click={handleSubmit} class="btn-primary w-full">
				{loading ? 'Creating account...' : 'Create Account'}
			</button>

			<!-- Login Link -->
			{#if onSwitchToLogin}
				<div class="text-center">
					<p class="text-sm text-gray-400">
						Already have an account?
						<button
							type="button"
							on:click={onSwitchToLogin}
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
