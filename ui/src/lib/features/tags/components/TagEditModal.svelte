<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { Tag } from '../types/base';
	import { createDefaultTag } from '../types/base';
	import TagDetailsForm from './TagDetailsForm.svelte';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import { TagIcon } from 'lucide-svelte';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { pushError } from '$lib/shared/stores/feedback';

	let {
		tag = null,
		isOpen = false,
		onCreate,
		onUpdate,
		onClose,
		onDelete = null
	}: {
		tag?: Tag | null;
		isOpen?: boolean;
		onCreate: (data: Tag) => Promise<void> | void;
		onUpdate: (id: string, data: Tag) => Promise<void> | void;
		onClose: () => void;
		onDelete?: ((id: string) => Promise<void> | void) | null;
	} = $props();

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let loading = $state(false);
	let deleting = $state(false);

	let isEditing = $derived(tag !== null);
	let title = $derived(isEditing ? `Edit ${tag?.name}` : 'Create Tag');

	let formData: Tag = $state(createDefaultTag(''));

	// Reset form when modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function resetForm() {
		if (tag) {
			formData = { ...tag };
		} else if (organization) {
			formData = createDefaultTag(organization.id);
		}
	}

	async function handleSubmit() {
		if (!organization) {
			pushError('Could not load organization');
			onClose();
			return;
		}

		const tagData: Tag = {
			...formData,
			name: formData.name.trim(),
			description: formData.description?.trim() || null,
			organization_id: organization.id
		};

		loading = true;
		try {
			if (isEditing && tag) {
				await onUpdate(tag.id, tagData);
			} else {
				await onCreate(tagData);
			}
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (onDelete && tag) {
			deleting = true;
			try {
				await onDelete(tag.id);
			} finally {
				deleting = false;
			}
		}
	}

	let saveLabel = $derived(isEditing ? 'Update Tag' : 'Create Tag');
	let colorHelper = $derived(createColorHelper(formData.color));
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
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={TagIcon} color={colorHelper.color} />
	</svelte:fragment>

	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<TagDetailsForm {formApi} bind:formData />

				{#if isEditing}
					<EntityMetadataSection entities={[tag]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
