<script lang="ts">
	import { form as createForm } from 'svelte-forms';
	import GenericModal from '../layout/GenericModal.svelte';
	import type {
		TextFieldType,
		FormApi,
		NumberFieldType,
		BooleanFieldType,
		MultiSelectFieldType
	} from './types';
	import { pushWarning } from '$lib/shared/stores/feedback';

	export let title: string = 'Edit';
	export let centerTitle: boolean = false;
	export let isOpen: boolean = false;
	export let onSave: (() => void) | null = null;
	export let onCancel: (() => void) | null = null;
	export let saveLabel: string = 'Save';
	export let showSave: boolean = true;
	export let showCloseButton: boolean = true;
	export let showCancel: boolean = true;
	export let cancelLabel: string = 'Cancel';
	export let disableSave: boolean = false;
	export let size: 'sm' | 'md' | 'lg' | 'xl' | 'full' = 'lg';
	export let preventCloseOnClickOutside: boolean = false;
	export let loading: boolean = false;
	export let deleting: boolean = false;
	export let onDelete: (() => void) | null = null;
	export let showBackdrop: boolean = true;

	// Create a container for fields that child components will populate
	let formFields: Record<
		string,
		TextFieldType | NumberFieldType | BooleanFieldType | MultiSelectFieldType
	> = {};

	// Create the actual form reactively based on registered fields
	$: form = createForm(...Object.values(formFields));

	const formApi: FormApi = {
		registerField: (
			id: string,
			field: TextFieldType | NumberFieldType | BooleanFieldType | MultiSelectFieldType
		) => {
			if (!Object.prototype.hasOwnProperty.call(formFields, id)) {
				formFields = { ...formFields, [id]: field };
			}
		},
		unregisterField: (id: string) => {
			if (Object.prototype.hasOwnProperty.call(formFields, id)) {
				// eslint-disable-next-line @typescript-eslint/no-unused-vars
				const { [id]: _, ...newFields } = formFields;
				formFields = newFields;
			}
		}
	};

	async function handleFormSubmit() {
		// Force validation on all fields
		await Promise.all(Object.values(formFields).map((field) => field.validate()));

		// Check if current fields are valid
		if (!$form.valid) {
			pushWarning('Form invalid: ' + $form.errors);
			return; // Don't proceed if validation fails
		} else {
			onSave?.();
		}
	}

	function handleCancel() {
		onCancel?.();
	}

	function handleDelete() {
		onDelete?.();
	}

	// Disable save button if form validation fails or explicitly disabled
	$: actualDisableSave = disableSave || loading || deleting;

	// Check if parent component is providing a custom footer
	$: hasCustomFooter = $$slots.footer;
</script>

<GenericModal
	{isOpen}
	{centerTitle}
	{title}
	{size}
	{preventCloseOnClickOutside}
	onClose={handleCancel}
	{showCloseButton}
	{showBackdrop}
>
	<!-- Header icon slot -->
	<svelte:fragment slot="header-icon">
		<slot name="header-icon" />
	</svelte:fragment>

	<!-- Main content wrapped in form (includes footer so type="submit" works) -->
	<form onsubmit={handleFormSubmit} class="flex h-full flex-col">
		<!-- Form content -->
		<div class="flex-1 overflow-auto p-6">
			<!-- Form fields slot -->
			<!-- eslint-disable-next-line svelte/require-store-reactive-access -->
			<slot {form} {formApi} />
		</div>

		<!-- Footer inside form so type="submit" triggers validation -->
		<div class="modal-footer">
			{#if hasCustomFooter}
				<!-- Custom footer provided by parent -->
				<slot
					name="footer"
					{handleFormSubmit}
					{handleCancel}
					{handleDelete}
					{loading}
					{deleting}
					{actualDisableSave}
					{formApi}
				/>
			{:else}
				<!-- Default footer -->
				<div class="flex items-center justify-between">
					<!-- Delete button (if editing) -->
					<div>
						{#if onDelete}
							<button
								type="button"
								disabled={deleting || loading}
								onclick={handleDelete}
								class="btn-danger"
							>
								{deleting ? 'Deleting...' : 'Delete'}
							</button>
						{/if}
					</div>

					<!-- Cancel and Save buttons -->
					<div class="flex items-center gap-3">
						{#if showCancel}
							<button
								type="button"
								disabled={loading || deleting}
								onclick={handleCancel}
								class="btn-secondary"
							>
								{cancelLabel}
							</button>
						{/if}

						{#if showSave}
							<button type="submit" disabled={actualDisableSave} class="btn-primary">
								{loading ? 'Saving...' : saveLabel}
							</button>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	</form>
</GenericModal>
