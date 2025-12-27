<script lang="ts">
	import { createEmptyGroupFormData } from '../../store';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { Group } from '../../types/base';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import GroupDetailsForm from './GroupDetailsForm.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import EdgeStyleForm from './EdgeStyleForm.svelte';

	interface Props {
		group?: Group | null;
		isOpen?: boolean;
		onCreate: (data: Group) => Promise<void> | void;
		onUpdate: (id: string, data: Group) => Promise<void> | void;
		onClose: () => void;
		onDelete?: ((id: string) => Promise<void> | void) | null;
	}

	let {
		group = null,
		isOpen = false,
		onCreate,
		onUpdate,
		onClose,
		onDelete = null
	}: Props = $props();

	// TanStack Query hooks
	const servicesQuery = useServicesQuery();
	let servicesData = $derived(servicesQuery.data ?? []);

	let loading = $state(false);
	let deleting = $state(false);

	let isEditing = $derived(group !== null);
	let title = $derived(isEditing ? `Edit ${group?.name}` : 'Create Group');

	let formData: Group = $state(createEmptyGroupFormData());

	// Initialize form data when group changes or modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function resetForm() {
		formData = group ? { ...group } : createEmptyGroupFormData();
	}

	// Available service bindings (exclude already selected ones)
	let availableServiceBindings = $derived(
		servicesData
			.filter((s) => s.network_id == formData.network_id)
			.flatMap((s) => s.bindings)
			.filter((sb) => !(formData.binding_ids ?? []).some((binding) => binding === sb.id))
	);

	let selectedServiceBindings = $derived(
		(formData.binding_ids ?? [])
			.map((bindingId) => servicesData.flatMap((s) => s.bindings).find((sb) => sb.id === bindingId))
			.filter(Boolean)
	);

	// Handlers for service bindings
	function handleAdd(bindingId: string) {
		formData.binding_ids = [...(formData.binding_ids ?? []), bindingId];
	}

	function handleRemove(index: number) {
		formData.binding_ids = (formData.binding_ids ?? []).filter((_, i) => i !== index);
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

		const updatedBindingIds = [...(formData.binding_ids ?? [])];
		const [movedBinding] = updatedBindingIds.splice(fromIndex, 1);
		updatedBindingIds.splice(toIndex, 0, movedBinding);

		// Trigger reactivity by reassigning the entire formData object
		formData = {
			...formData,
			binding_ids: updatedBindingIds
		};
	}

	// Dynamic labels based on create/edit mode
	let saveLabel = $derived(isEditing ? 'Update Group' : 'Create Group');

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
		<ModalHeaderIcon Icon={entities.getIconComponent('Group')} color={colorHelper.color} />
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
								allowItemEdit={() => false}
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
