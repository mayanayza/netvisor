<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { OnboardingRequest } from '../types/base';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import { untrack } from 'svelte';

	let {
		isOpen = false,
		onClose,
		onSubmit
	}: {
		isOpen: boolean;
		onClose: () => void;
		onSubmit: (formData: OnboardingRequest) => void;
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

	$effect(() => {
		const orgValue = $organizationName.value;
		const netValue = $networkName.value;

		untrack(() => {
			formData.organization_name = orgValue;
			formData.network_name = netValue;
		});
	});
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
	<div class="space-y-6">
		<TextInput
			label="Organization Name"
			id="organizationName"
			{formApi}
			placeholder="My Organization"
			helpText="This will be the name of your organization (you can change it later)"
			required={true}
			field={organizationName}
		/>

		<TextInput
			label="Network Name"
			id="networkName"
			{formApi}
			placeholder="My Network"
			helpText="This will be the name of your first network (you can change it later)"
			required={true}
			field={networkName}
		/>

		<!-- Seed Data Option -->
		<div class="space-y-3">
			<div class="flex items-start gap-3">
				<input
					id="populateSeedData"
					type="checkbox"
					bind:checked={formData.populate_seed_data}
					class="mt-1 h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-500 focus:ring-2 focus:ring-blue-500"
				/>
				<div class="flex-1">
					<label for="populateSeedData" class="block text-sm font-medium text-gray-200">
						Populate with baseline data
					</label>
					<p class="mt-1 text-xs text-gray-400">
						NetVisor will create two subnets - one representing a remote network, one representing
						the internet - to help you organize services which are not discoverable on your own
						network, and three hosts with example services to help you understand how NetVisor
						works. You can delete this data at any time.
					</p>
				</div>
			</div>
		</div>
	</div>

	<!-- Custom footer -->
	<svelte:fragment slot="footer">
		<div class="flex w-full flex-col gap-4">
			<!-- Get Started Button -->
			<button
				type="button"
				disabled={loading}
				onclick={() => onSubmit(formData)}
				class="btn-primary w-full"
			>
				{loading ? 'Setting up...' : 'Get Started'}
			</button>
		</div>
	</svelte:fragment>
</EditModal>
