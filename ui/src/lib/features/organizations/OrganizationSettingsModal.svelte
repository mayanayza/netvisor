<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { Building2 } from 'lucide-svelte';
	import { currentUser } from '$lib/features/auth/store';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import { getOrganization, organization, updateOrganization } from './store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	export let isOpen = false;
	export let onClose: () => void;

	let saving = false;
	let activeSection: 'main' | 'edit' = 'main';

	$: if (isOpen && $currentUser) {
		loadOrganization();
	}

	async function loadOrganization() {
		if (!$currentUser) return;
		await getOrganization();
	}

	$: org = $organization;

	// Form data
	let formData = {
		name: ''
	};

	const name = field('name', '', [required()]);

	$: if (isOpen && activeSection === 'edit' && org) {
		name.set(org.name);
		formData.name = org.name;
	}

	$: formData.name = $name.value;

	async function handleSave() {
		if (!org) return;

		saving = true;
		try {
			const result = await updateOrganization({
				...org,
				name: formData.name.trim()
			});

			if (result?.success) {
				pushSuccess('Organization updated successfully');
				activeSection = 'main';
				formData = { name: '' };
			} else {
				pushError(result?.error || 'Failed to update organization');
			}
		} finally {
			saving = false;
		}
	}

	function handleCancel() {
		if (activeSection === 'edit') {
			activeSection = 'main';
			formData = { name: '' };
			name.set(org?.name || '');
		} else {
			onClose();
		}
	}

	$: modalTitle = activeSection === 'main' ? 'Organization Settings' : 'Edit Organization';
	$: showSave = activeSection === 'edit';
	$: cancelLabel = activeSection === 'main' ? 'Close' : 'Back';
</script>

<EditModal
	{isOpen}
	title={modalTitle}
	loading={saving}
	saveLabel="Save Changes"
	{showSave}
	showCancel={true}
	{cancelLabel}
	onSave={showSave ? handleSave : null}
	onCancel={handleCancel}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Building2} color="#3b82f6" />
	</svelte:fragment>

	{#if org}
		{#if activeSection === 'main'}
			<div class="space-y-6">
				<!-- Organization Info -->
				<InfoCard title="Organization Information">
					<InfoRow label="Name">{org.name}</InfoRow>
					<InfoRow label="Plan">{org.plan.type}</InfoRow>
					<InfoRow label="Created">
						{formatTimestamp(org.created_at)}
					</InfoRow>
					<InfoRow label="ID" mono={true}>{org.id}</InfoRow>
				</InfoCard>

				<!-- Actions -->
				<InfoCard>
					<div class="flex items-center justify-between">
						<div>
							<p class="text-primary text-sm font-medium">Organization Name</p>
							<p class="text-secondary text-xs">Update your organization's display name</p>
						</div>
						<button
							on:click={() => {
								activeSection = 'edit';
								name.set(org.name);
							}}
							class="btn-primary"
						>
							Edit
						</button>
					</div>
				</InfoCard>
			</div>
		{:else if activeSection === 'edit'}
			<div class="space-y-6">
				<p class="text-secondary text-sm">Update your organization's display name</p>
				<TextInput
					label="Organization Name"
					id="name"
					{formApi}
					placeholder="Enter organization name"
					field={name}
				/>
			</div>
		{/if}
	{:else}
		<div class="text-secondary py-8 text-center">
			<p>Unable to load organization information</p>
			<p class="text-tertiary mt-2 text-sm">Please try again later</p>
		</div>
	{/if}
</EditModal>
