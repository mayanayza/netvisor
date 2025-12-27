<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import { Mail } from 'lucide-svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { emailValidator } from '$lib/shared/components/forms/validators';

	export let isOpen = false;
	export let onRequestReset: (email: string) => Promise<void> | void;
	export let onClose: () => void;
	export let onBackToLogin: () => void;

	let requesting = false;
	let emailSent = false;

	let formData = {
		email: ''
	};

	// Create form field with validation
	const email = field('email', formData.email, [required(), emailValidator()]);

	// Update formData when field value changes
	$: formData.email = $email.value;

	// Reset state when modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = { email: '' };
		emailSent = false;
	}

	async function handleSubmit() {
		requesting = true;
		try {
			await onRequestReset(formData.email);
			emailSent = true;
		} finally {
			requesting = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title={emailSent ? 'Check Your Email' : 'Reset Password'}
	loading={false}
	centerTitle={true}
	saveLabel="Send Reset Link"
	cancelLabel="Cancel"
	showCloseButton={false}
	showCancel={false}
	showBackdrop={false}
	showSave={!emailSent}
	onSave={handleSubmit}
	onCancel={onClose}
	size="md"
	preventCloseOnClickOutside={true}
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Mail} color="Blue" />
	</svelte:fragment>

	{#if emailSent}
		<InlineInfo
			title="Reset link sent"
			body="If an account exists with that email, you'll receive a password reset link shortly. Please check your inbox and spam folder."
		/>
	{:else}
		<div class="space-y-6">
			<p class="text-sm text-gray-400">
				Enter your email address and we'll send you a link to reset your password.
			</p>

			<TextInput
				label="Email"
				id="email"
				{formApi}
				placeholder="Enter your email"
				required={true}
				field={email}
			/>
		</div>
	{/if}

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			{#if emailSent}
				<!-- Back to Login Button -->
				<button type="button" on:click={onBackToLogin} class="btn-primary w-full">
					Back to Login
				</button>
			{:else}
				<!-- Send Reset Link Button (type="submit" triggers form validation) -->
				<button type="submit" disabled={requesting} class="btn-primary w-full">
					{requesting ? 'Sending...' : 'Send Reset Link'}
				</button>

				<!-- Back to Login Link -->
				<div class="text-center">
					<button
						type="button"
						on:click={onBackToLogin}
						class="text-sm font-medium text-blue-400 hover:text-blue-300"
					>
						Back to Login
					</button>
				</div>
			{/if}
		</div>
	</svelte:fragment>
</EditModal>
