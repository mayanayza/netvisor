<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { entities } from '$lib/shared/stores/metadata';
	import { writable, type Writable } from 'svelte/store';
	import { RotateCcwKey } from 'lucide-svelte';
	import type { ApiKey } from '../types/base';
	import { createEmptyApiKeyFormData, createNewApiKey, rotateKey } from '../store';
	import ApiKeyDetailsForm from './ApiKeyDetailsForm.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';

	export let isOpen = false;
	export let onClose: () => void;
	export let onUpdate: (data: ApiKey) => Promise<void> | void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;
	export let apiKey: ApiKey | null = null;

	let loading = false;
	let deleting = false;

	$: isEditing = apiKey !== null;
	$: title = isEditing ? `Edit ${apiKey?.name || 'API Key'}` : 'Create API Key';

	let formData: ApiKey = createEmptyApiKeyFormData();
	let keyStore: Writable<string | null> = writable(null);
	$: key = $keyStore;

	// Initialize form data when modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = apiKey ? { ...apiKey } : createEmptyApiKeyFormData();
		keyStore.set(null);
	}

	function handleOnClose() {
		keyStore.set(null);
		onClose();
	}

	async function handleGenerateKey() {
		const generatedKey = await createNewApiKey(formData);
		if (generatedKey) {
			keyStore.set(generatedKey);
		} else {
			pushError('Failed to generate API key');
		}
	}

	async function handleRotateKey() {
		const generatedKey = await rotateKey(formData.id);
		if (generatedKey) {
			keyStore.set(generatedKey);
		} else {
			pushError('Failed to generate API key');
		}
	}

	async function handleSubmit() {
		loading = true;
		try {
			if (isEditing) {
				await onUpdate(formData);
			}
		} finally {
			loading = false;
		}
	}

	async function handleDelete() {
		if (onDelete && apiKey) {
			deleting = true;
			try {
				await onDelete(apiKey.id);
			} finally {
				deleting = false;
			}
		}
	}

	let colorHelper = entities.getColorHelper('ApiKey');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	cancelLabel="Close"
	onSave={handleSubmit}
	showSave={isEditing}
	saveLabel="Save"
	onCancel={handleOnClose}
	onDelete={isEditing ? handleDelete : null}
	size="xl"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('ApiKey')} color={colorHelper.color} />
	</svelte:fragment>

	<div class="space-y-6">
		<!-- Form fields -->
		<ApiKeyDetailsForm {formApi} bind:formData {isEditing} />

		<!-- Key generation section -->
		<div class="space-y-3">
			{#if !key && isEditing}
				<InlineWarning
					title="Generating a new key will invalidate your old key"
					body="Click the button below to generate a new API key. You'll only see it once, so make sure to copy it."
				/>
			{/if}

			{#if key}
				<InlineWarning
					title="Save this key now"
					body="This key will not be shown again. Copy it now and store it securely."
				/>
			{/if}

			<div class="flex items-start gap-2">
				<button
					type="button"
					class="btn-primary flex-shrink-0 self-stretch"
					on:click={apiKey != null ? handleRotateKey : handleGenerateKey}
					disabled={loading}
				>
					<RotateCcwKey />
					<span>{loading ? 'Generating...' : isEditing ? 'Rotate Key' : 'Generate Key'}</span>
				</button>

				<div class="flex-1">
					<CodeContainer
						language="bash"
						expandable={false}
						code={key ? key : 'Press Generate Key...'}
					/>
				</div>
			</div>
		</div>

		<!-- Metadata section for existing keys -->
		{#if isEditing}
			<EntityMetadataSection entities={[apiKey]} />
		{/if}
	</div>
</EditModal>
