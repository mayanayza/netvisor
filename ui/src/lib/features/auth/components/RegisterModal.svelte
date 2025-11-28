<script lang="ts">
	import type { RegisterRequest } from '../types/base';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import { required } from 'svelte-forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import { field } from 'svelte-forms';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import { emailValidator } from '$lib/shared/components/forms/validators';

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

	// Create form fields with validation
	const email = field('email', formData.email, [required(), emailValidator()]);

	// Update formData when field values change
	$: formData.email = $email.value;

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
