<script lang="ts">
	import { createEmptyGroupFormData } from '../../store';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { Group } from '../../types/base';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { services } from '$lib/features/services/store';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import GroupDetailsForm from './GroupDetailsForm.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import EdgeStyleForm from './EdgeStyleForm.svelte';

	export let group: Group | null = null;
	export let isOpen = false;
	export let onCreate: (data: Group) => Promise<void> | void;
	export let onUpdate: (id: string, data: Group) => Promise<void> | void;
	export let onClose: () => void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;

	let loading = false;
	let deleting = false;

	$: isEditing = group !== null;
	$: title = isEditing ? `Edit ${group?.name}` : 'Create Group';

	let formData: Group = createEmptyGroupFormData();

	// Initialize form data when group changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = group ? { ...group } : createEmptyGroupFormData();
	}

	// Available service bindings (exclude already selected ones)
	$: availableServiceBindings = $services
		.flatMap((s) => s.bindings)
		.filter((sb) => !formData.service_bindings.some((binding) => binding === sb.id));

	$: selectedServiceBindings = formData.service_bindings
		.map((bindingId) => $services.flatMap((s) => s.bindings).find((sb) => sb.id === bindingId))
		.filter(Boolean);

	// Handlers for service bindings
	function handleAdd(bindingId: string) {
		formData.service_bindings = [...formData.service_bindings, bindingId];
	}

	function handleRemove(index: number) {
		formData.service_bindings = formData.service_bindings.filter((_, i) => i !== index);
	}

	async function handleSubmit() {
		// Clean up the data before sending
		const groupData: Group = {
			...formData,
			name: formData.name.trim(),
			description: formData.description?.trim() || ''
		};

		loading = true;
		try {
			if (isEditing && group) {
				await onUpdate(group.id, groupData);
			} else {
				await onCreate(groupData);
			}
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (onDelete && group) {
			deleting = true;
			try {
				await onDelete(group.id);
			} finally {
				deleting = false;
			}
		}
	}

	function handleServiceBindingsReorder(fromIndex: number, toIndex: number) {
		if (fromIndex === toIndex) return;

		const updatedServiceBindings = [...formData.service_bindings];
		const [movedBinding] = updatedServiceBindings.splice(fromIndex, 1);
		updatedServiceBindings.splice(toIndex, 0, movedBinding);

		// Trigger reactivity by reassigning the entire formData object
		formData = {
			...formData,
			service_bindings: updatedServiceBindings
		};
	}

	// Dynamic labels based on create/edit mode
	$: saveLabel = isEditing ? 'Update Group' : 'Create Group';

	let colorHelper = entities.getColorHelper('Group');
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
		<ModalHeaderIcon Icon={entities.getIconComponent('Group')} color={colorHelper.string} />
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<GroupDetailsForm {formApi} bind:formData />

				<!-- Service Bindings Section -->
				<div class="space-y-4">
					<div class="border-t border-gray-700 pt-6">
						<div class="rounded-lg bg-gray-800/50 p-4">
							<ListManager
								label="Service Bindings"
								helpText="Select service bindings for this group"
								placeholder="Select a binding to add..."
								emptyMessage="No bindings in this group yet."
								allowReorder={true}
								{formApi}
								showSearch={true}
								options={availableServiceBindings}
								items={selectedServiceBindings}
								optionDisplayComponent={BindingWithServiceDisplay}
								itemDisplayComponent={BindingWithServiceDisplay}
								onAdd={handleAdd}
								onRemove={handleRemove}
								onMoveUp={(index) => handleServiceBindingsReorder(index, index - 1)}
								onMoveDown={(index) => handleServiceBindingsReorder(index, index + 1)}
							/>
						</div>
					</div>
				</div>

				<!-- Edge Style Section -->
				<div class="space-y-4">
					<div class="border-t border-gray-700 pt-6">
						<h3 class="text-primary mb-4 text-lg font-medium">Edge Appearance</h3>
						<div class="rounded-lg bg-gray-800/50 p-4">
							<EdgeStyleForm bind:formData />
						</div>
					</div>
				</div>

				{#if isEditing}
					<EntityMetadataSection entities={[group]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
