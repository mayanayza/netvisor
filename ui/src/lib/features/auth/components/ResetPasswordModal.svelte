<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import { Key } from 'lucide-svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';

	export let isOpen = false;
	export let token: string;
	export let onResetPassword: (token: string, password: string) => Promise<void> | void;
	export let onClose: () => void;
	export let onBackToLogin: () => void;

	let resetting = false;
	let resetComplete = false;

	let formData = {
		password: '',
		confirmPassword: ''
	};

	// Reset state when modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = { password: '', confirmPassword: '' };
		resetComplete = false;
	}

	async function handleSubmit() {
		resetting = true;
		try {
			await onResetPassword(token, formData.password);
			resetComplete = true;
		} finally {
			resetting = false;
		}
	}
</script>

<EditModal
	{isOpen}
	title={resetComplete ? 'Password Reset' : 'Set New Password'}
	loading={false}
	centerTitle={true}
	saveLabel="Reset Password"
	cancelLabel="Cancel"
	showBackdrop={false}
	showCloseButton={false}
	showCancel={false}
	showSave={!resetComplete}
	onSave={handleSubmit}
	onCancel={onClose}
	size="md"
	preventCloseOnClickOutside={true}
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Key} color="Blue" />
	</svelte:fragment>

	{#if resetComplete}
		<InlineInfo
			title="Password updated"
			body="Your password has been successfully reset. You can now sign in with your new password."
		/>
	{:else}
		<Password
			{formApi}
			bind:value={formData.password}
			bind:confirmValue={formData.confirmPassword}
			showConfirm={true}
			required={false}
		/>
	{/if}

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			{#if resetComplete}
				<!-- Go to Login Button -->
				<button type="button" on:click={onBackToLogin} class="btn-primary w-full">
					Go to Login
				</button>
			{:else}
				<!-- Reset Password Button (type="submit" triggers form validation) -->
				<button type="submit" disabled={resetting} class="btn-primary w-full">
					{resetting ? 'Resetting...' : 'Reset Password'}
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
