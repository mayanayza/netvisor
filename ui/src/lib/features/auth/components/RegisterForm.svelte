<!-- ui/src/lib/features/auth/components/RegisterForm.svelte -->
<script lang="ts">
	import { field } from 'svelte-forms';
	import { email as emailValidator, required } from 'svelte-forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { RegisterRequest } from '../types/base';
	import Password from '$lib/shared/components/forms/input/Password.svelte';

	export let formApi: FormApi;
	export let formData: RegisterRequest & { confirmPassword: string };

	// Create form fields with validation
	const email = field('email', formData.email, [required(), emailValidator()]);

	// Update formData when field values change
	$: formData.email = $email.value;
</script>

<div class="space-y-6">
	<TextInput
		label="Email"
		id="email"
		{formApi}
		placeholder="Enter email"
		required={true}
		field={email}
	/>

	<Password
		{formApi}
		bind:value={formData.password}
		bind:confirmValue={formData.confirmPassword}
		showConfirm={true}
	/>
</div>
