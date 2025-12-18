<script lang="ts">
	import { field } from 'svelte-forms';
	import { email as emailValidator, required } from 'svelte-forms/validators';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';

	export let isOpen: boolean = false;
	export let planName: string = '';
	export let userEmail: string = '';
	export let onClose: () => void;
	export let onSubmit: (email: string, message: string) => void | Promise<void>;

	let loading = false;

	const emailField = field('email', userEmail, [required(), emailValidator()]);
	const messageField = field('message', '', []);

	// Reset fields when modal opens with new data
	$: if (isOpen) {
		emailField.set(userEmail);
		messageField.set('');
	}

	async function handleSave() {
		loading = true;
		try {
			await onSubmit($emailField.value, $messageField.value);
			onClose();
		} finally {
			loading = false;
		}
	}
</script>

<EditModal
	title="Request Information - {planName}"
	{isOpen}
	onCancel={onClose}
	onSave={handleSave}
	saveLabel="Send Request"
	{loading}
	size="md"
	let:formApi
>
	<div class="space-y-4">
		<TextInput
			label="Email"
			id="inquiry-email"
			{formApi}
			field={emailField}
			placeholder="your@email.com"
			required
		/>

		<TextArea
			label="What information are you looking for?"
			id="inquiry-message"
			{formApi}
			field={messageField}
			placeholder="Tell us what you'd like to know about the {planName} plan..."
			rows={5}
		/>
	</div>
</EditModal>
