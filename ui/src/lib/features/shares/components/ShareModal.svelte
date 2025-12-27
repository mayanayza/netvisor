<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { Share2 } from 'lucide-svelte';
	import type { Share } from '../types/base';
	import { createEmptyShare } from '../types/base';
	import {
		useCreateShareMutation,
		useUpdateShareMutation,
		useDeleteShareMutation
	} from '../queries';
	import ShareDetailsForm from './ShareDetailsForm.svelte';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans, entities } from '$lib/shared/stores/metadata';

	let {
		isOpen = false,
		onClose,
		share = null,
		topologyId = '',
		networkId = ''
	}: {
		isOpen?: boolean;
		onClose: () => void;
		share?: Share | null;
		topologyId?: string;
		networkId?: string;
	} = $props();

	// Mutations
	const createShareMutation = useCreateShareMutation();
	const updateShareMutation = useUpdateShareMutation();
	const deleteShareMutation = useDeleteShareMutation();

	// TanStack Query for current user and organization
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let loading = $state(false);
	let deleting = $state(false);

	let isEditing = $derived(share !== null);
	let title = $derived(isEditing ? `Edit ${share?.name || 'Share'}` : 'Share Topology');

	let formData: Share = $state(createEmptyShare('', ''));
	let passwordValue = $state('');
	let createdShare: Share | null = $state(null);

	let hasEmbedsFeature = $derived(
		organization?.plan ? billingPlans.getMetadata(organization.plan.type).features.embeds : true
	);

	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function resetForm() {
		if (share) {
			formData = { ...share };
		} else {
			formData = createEmptyShare(topologyId, networkId);
		}
		passwordValue = '';
		createdShare = null;
	}

	function handleClose() {
		resetForm();
		onClose();
	}

	async function handleSubmit() {
		if (currentUser) formData.created_by = currentUser.id;

		loading = true;

		try {
			if (isEditing && share) {
				// For updates: undefined preserves existing password, empty string removes it, value sets new
				const password = passwordValue || undefined;
				await updateShareMutation.mutateAsync({
					id: share.id,
					request: { share: formData, password }
				});
				handleClose();
			} else {
				// For create: send the password (empty string means no password)
				const result = await createShareMutation.mutateAsync({
					share: formData,
					password: passwordValue || undefined
				});
				createdShare = result;
			}
		} catch (error) {
			pushError(error instanceof Error ? error.message : 'Failed to save share');
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (!share) return;

		deleting = true;
		try {
			await deleteShareMutation.mutateAsync(share.id);
			handleClose();
		} catch (error) {
			pushError(error instanceof Error ? error.message : 'Failed to delete share');
		} finally {
			deleting = false;
		}
	}

	let saveLabel = $derived(isEditing ? 'Save' : 'Create');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	cancelLabel={createdShare ? 'Done' : 'Cancel'}
	onSave={createdShare ? undefined : handleSubmit}
	showSave={!createdShare}
	onCancel={handleClose}
	onDelete={isEditing ? handleDelete : null}
	size="xl"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Share2} color={entities.getColorHelper('Share').color} />
	</svelte:fragment>

	<div class="space-y-6">
		<ShareDetailsForm
			{formApi}
			bind:formData
			bind:passwordValue
			bind:createdShare
			{isEditing}
			{hasEmbedsFeature}
		/>
	</div>
</EditModal>
