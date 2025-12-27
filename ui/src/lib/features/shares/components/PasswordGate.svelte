<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { Lock } from 'lucide-svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';

	export let isOpen: boolean = true;
	export let title: string = 'Password Required';
	export let onSubmit: (password: string) => Promise<boolean>;
	export let submitLabel: string = 'View Topology';

	let loading = false;
	let serverError = '';

	const password = field('password', '', [required()]);

	async function handleSave() {
		serverError = '';
		loading = true;

		try {
			const success = await onSubmit($password.value);
			if (!success) {
				serverError = 'Invalid password';
				password.set('');
			}
		} catch {
			serverError = 'An error occurred';
		} finally {
			loading = false;
		}
	}

	function handleCancel() {
		// No-op - can't close the password gate without entering password
	}
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	saveLabel={submitLabel}
	showCancel={false}
	showCloseButton={false}
	preventCloseOnClickOutside={true}
	onSave={handleSave}
	onCancel={handleCancel}
	size="sm"
	centerTitle={true}
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Lock} color="Blue" />
	</svelte:fragment>

	<div class="space-y-4">
		<TextInput
			label="Password"
			id="password"
			type="password"
			{formApi}
			field={password}
			placeholder="Enter password"
			required={true}
			disabled={loading}
		/>

		{#if serverError}
			<p class="text-danger text-sm">{serverError}</p>
		{/if}
	</div>
</EditModal>
