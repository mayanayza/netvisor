<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { OnboardingRequest } from '../types/base';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import { untrack } from 'svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';

	let {
		isOpen = false,
		onClose,
		onSubmit,
		onSwitchToLogin = null,
		showLoginLink = false
	}: {
		isOpen: boolean;
		onClose: () => void;
		onSubmit: (formData: OnboardingRequest) => void;
		onSwitchToLogin?: (() => void) | null;
		showLoginLink?: boolean;
	} = $props();

	let loading = false;

	let formData: OnboardingRequest = {
		organization_name: '',
		network_name: '',
		populate_seed_data: true
	};

	// Create form fields with validation
	const organizationName = field('organizationName', formData.organization_name, [
		required(),
		maxLength(100)
	]);

	// Create form fields with validation
	const networkName = field('networkName', formData.network_name, [required(), maxLength(100)]);
	const seedDataField = field('seedData', true, []);

	$effect(() => {
		const orgValue = $organizationName.value;
		const netValue = $networkName.value;
		const seedData = $seedDataField.value;

		untrack(() => {
			formData.organization_name = orgValue;
			formData.network_name = netValue;
			formData.populate_seed_data = seedData;
		});
	});
</script>

<EditModal
	{isOpen}
	title="Let's start mapping your network!"
	{loading}
	centerTitle={true}
	saveLabel="Continue"
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
	<div class="space-y-6">
		<TextInput
			label="Organization Name"
			id="organizationName"
			{formApi}
			placeholder="My Organization"
			helpText="Enter the name of your organization (you can change it later)"
			required={true}
			field={organizationName}
		/>

		<TextInput
			label="Network Name"
			id="networkName"
			{formApi}
			placeholder="My Network"
			helpText="Enter the name of your first network (you can change it later)"
			required={true}
			field={networkName}
		/>

		<Checkbox
			label="Populate with baseline data (recommended)"
			helpText="NetVisor will create two subnets - one representing a remote network, one representing
						the internet - to help you organize services which are not discoverable on your own
						network, and three hosts with example services to help you understand how NetVisor
						works. You can delete this data at any time."
			id="seedData"
			field={seedDataField}
			{formApi}
		/>
	</div>

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Continue Button -->
			<button
				type="button"
				disabled={loading}
				onclick={() => onSubmit(formData)}
				class="btn-primary w-full"
			>
				{loading ? 'Setting up...' : 'Continue'}
			</button>

			{#if showLoginLink && onSwitchToLogin}
				<p class="text-secondary text-center text-sm">
					Already have an account?
					<button
						type="button"
						onclick={onSwitchToLogin}
						class="font-medium text-blue-400 hover:text-blue-300"
					>
						Log in here
					</button>
				</p>
			{/if}
		</div>
	</svelte:fragment>
</EditModal>
