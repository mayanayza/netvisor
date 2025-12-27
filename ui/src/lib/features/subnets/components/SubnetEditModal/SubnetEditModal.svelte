<script lang="ts">
	import { createEmptySubnetFormData } from '../../store';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import SubnetDetailsForm from './SubnetDetailsForm.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { Subnet } from '../../types/base';

	export let subnet: Subnet | null = null;
	export let isOpen = false;
	export let onCreate: (data: Subnet) => Promise<void> | void;
	export let onUpdate: (id: string, data: Subnet) => Promise<void> | void;
	export let onClose: () => void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;

	let loading = false;
	let deleting = false;

	$: isEditing = subnet !== null;
	$: title = isEditing ? `Edit ${subnet?.name}` : 'Create Subnet';

	let formData: Subnet = createEmptySubnetFormData();

	// Initialize form data when subnet changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = subnet ? { ...subnet } : createEmptySubnetFormData();
	}

	async function handleSubmit() {
		// Clean up the data before sending
		const subnetData: Subnet = {
			...formData,
			name: formData.name.trim(),
			description: formData.description?.trim() || '',
			cidr: formData.cidr.trim()
		};

		loading = true;
		try {
			if (isEditing && subnet) {
				await onUpdate(subnet.id, subnetData);
			} else {
				await onCreate(subnetData);
			}
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (onDelete && subnet) {
			deleting = true;
			try {
				await onDelete(subnet.id);
			} finally {
				deleting = false;
			}
		}
	}

	// Dynamic labels based on create/edit mode
	$: saveLabel = isEditing ? 'Update Subnet' : 'Create Subnet';

	let colorHelper = entities.getColorHelper('Subnet');
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
		<ModalHeaderIcon Icon={entities.getIconComponent('Subnet')} color={colorHelper.color} />
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<SubnetDetailsForm {formApi} bind:formData {isEditing} />

				{#if isEditing}
					<EntityMetadataSection entities={[subnet]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
