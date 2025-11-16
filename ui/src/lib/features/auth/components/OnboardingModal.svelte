<!-- ui/src/lib/features/auth/components/OnboardingModal.svelte -->
<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { OnboardingRequest } from '../types/base';
	import OnboardingForm from './OnboardingForm.svelte';

	export let isOpen = false;
	export let onClose: () => void;
	export let onSubmit: (formData: OnboardingRequest) => void;

	let loading = false;

	let formData: OnboardingRequest = {
		organization_name: '',
		network_name: '',
		populate_seed_data: true
	};
</script>

<EditModal
	{isOpen}
	title="Welcome to NetVisor"
	{loading}
	centerTitle={true}
	saveLabel="Get Started"
	showCancel={false}
	showCloseButton={false}
	onSave={() => onSubmit(formData)}
	onCancel={onClose}
	size="md"
	preventCloseOnClickOutside={true}
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<img src="/logos/netvisor-logo.png" alt="NetVisor Logo" class="h-8 w-8" />
	</svelte:fragment>

	<!-- Content -->
	<OnboardingForm {formApi} bind:formData />

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Get Started Button -->
			<button
				type="button"
				disabled={loading}
				on:click={() => onSubmit(formData)}
				class="btn-primary w-full"
			>
				{loading ? 'Setting up...' : 'Get Started'}
			</button>
		</div>
	</svelte:fragment>
</EditModal>
