<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { CreateNetworkRequest, Network } from '../types';
	import { createEmptyNetworkFormData } from '../store';
	import NetworkDetailsForm from './NetworkDetailsForm.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { organization } from '$lib/features/organizations/store';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { field } from 'svelte-forms';

	export let network: Network | null = null;
	export let isOpen = false;
	export let onCreate: (data: CreateNetworkRequest) => Promise<void> | void;
	export let onUpdate: (id: string, data: Network) => Promise<void> | void;
	export let onClose: () => void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;

	let loading = false;
	let deleting = false;

	$: isEditing = network !== null;
	$: title = isEditing ? `Edit ${network?.name}` : 'Create Network';

	let formData: Network = createEmptyNetworkFormData();

	// Initialize form data when group changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = network ? { ...network } : createEmptyNetworkFormData();
	}

	async function handleSubmit() {
		// Clean up the data before sending

		if ($organization) {
			const networkData: Network = {
				...formData,
				name: formData.name.trim(),
				organization_id: $organization.id
			};

			loading = true;
			try {
				if (isEditing && network) {
					await onUpdate(network.id, networkData);
				} else {
					await onCreate({
						network: networkData,
						seed_baseline_data: $seedDataField.value
					});
				}
			} finally {
				loading = false;
			}
		} else {
			pushError('Could not load ID for current user');
			onClose();
		}
	}

	async function handleDelete() {
		if (onDelete && network) {
			deleting = true;
			try {
				await onDelete(network.id);
			} finally {
				deleting = false;
			}
		}
	}

	// Dynamic labels based on create/edit mode
	$: saveLabel = isEditing ? 'Update Network' : 'Create Network';

	const seedDataField = field('seedData', true, []);

	let colorHelper = entities.getColorHelper('Network');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	cancelLabel="Cancel"
	onSave={handleSubmit}
	onCancel={onClose}
	onDelete={isEditing ? handleDelete : null}
	size="xl"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Network')} color={colorHelper.string} />
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<NetworkDetailsForm {formApi} bind:formData />

				{#if !isEditing}
					<Checkbox
						label="Populate with baseline data"
						helpText="NetVisor will create two subnets - one representing a remote network, one representing
									the internet - to help you organize services which are not discoverable on your own
									network, and three hosts with example services to help you understand how NetVisor
									works. You can delete this data at any time."
						id="seedData"
						field={seedDataField}
						{formApi}
					/>
				{/if}

				{#if isEditing}
					<EntityMetadataSection entities={[network]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
