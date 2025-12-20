<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { Share2 } from 'lucide-svelte';
	import type { Share } from '../types/base';
	import { createEmptyShare } from '../types/base';
	import { createShare, updateShare, deleteShare } from '../store';
	import ShareDetailsForm from './ShareDetailsForm.svelte';
	import EmbedCodeGenerator from './EmbedCodeGenerator.svelte';
	import { currentUser } from '$lib/features/auth/store';
	import { organization } from '$lib/features/organizations/store';
	import { billingPlans } from '$lib/shared/stores/metadata';

	export let isOpen = false;
	export let onClose: () => void;
	export let share: Share | null = null;
	export let topologyId: string = '';
	export let networkId: string = '';

	let loading = false;
	let deleting = false;

	$: isEditing = share !== null;
	$: title = isEditing ? `Edit ${share?.name || 'Share'}` : 'Share Topology';

	let formData: Share = createEmptyShare('', '');
	let passwordValue: string = '';
	let showEmbedCode = false;
	let showShowcase = false;
	let createdShare: Share | null = null;

	$: blockEmbeds =
		$organization && formData.share_type == 'embed'
			? billingPlans.getMetadata($organization.plan.type).features.embeds
			: false;

	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		if (share) {
			formData = { ...share };
		} else {
			formData = createEmptyShare(topologyId, networkId);
		}
		passwordValue = '';
		showEmbedCode = false;
		showShowcase = false;
		createdShare = null;
	}

	function handleClose() {
		resetForm();
		onClose();
	}

	async function handleSubmit() {
		if ($currentUser) formData.created_by = $currentUser.id;

		loading = true;

		try {
			if (isEditing && share) {
				// For updates: undefined preserves existing password, empty string removes it, value sets new
				const password = passwordValue || undefined;
				const result = await updateShare(share.id, { share: formData, password });
				if (result?.success) {
					pushSuccess('Share updated');
					handleClose();
				} else {
					pushError(result?.error || 'Failed to update share');
				}
			} else {
				// For create: send the password (empty string means no password)
				const result = await createShare({ share: formData, password: passwordValue || undefined });
				if (result?.success && result.data) {
					pushSuccess('Share created');
					if (formData.share_type === 'embed') {
						createdShare = result.data;
						showEmbedCode = true;
					} else {
						handleClose();
					}
				} else {
					pushError(result?.error || 'Failed to create share');
				}
			}
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (!share) return;

		deleting = true;
		try {
			await deleteShare(share.id);
			pushSuccess('Share deleted');
			handleClose();
		} finally {
			deleting = false;
		}
	}

	$: saveLabel = isEditing ? 'Save' : 'Create';
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	cancelLabel={showEmbedCode || showShowcase ? 'Done' : 'Cancel'}
	onSave={showEmbedCode || showShowcase ? undefined : handleSubmit}
	showSave={!showEmbedCode && !showShowcase}
	disableSave={blockEmbeds}
	onCancel={handleClose}
	onDelete={isEditing ? handleDelete : null}
	size="xl"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Share2} color="rgb(59, 130, 246)" />
	</svelte:fragment>

	{#if showEmbedCode && createdShare}
		<EmbedCodeGenerator shareId={createdShare.id} />
	{:else}
		<div class="space-y-6">
			<ShareDetailsForm
				{formApi}
				bind:formData
				bind:passwordValue
				bind:showShowcase
				{isEditing}
				{blockEmbeds}
			/>
		</div>
	{/if}
</EditModal>
