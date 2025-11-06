<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { minLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { LoginRequest } from '../types/base';

	export let formApi: FormApi;
	export let formData: LoginRequest;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), minLength(3)]);
	const password = field('password', formData.password, [required(), minLength(12)]);

	// Update formData when field values change
	$: formData.name = $name.value;
	$: formData.password = $password.value;
</script>

<div class="space-y-6">
	<div class="space-y-4">
		<TextInput
			label="Username"
			id="name"
			{formApi}
			placeholder="Enter your username"
			required={true}
			field={name}
		/>

		<TextInput
			label="Password"
			id="password"
			type="password"
			{formApi}
			placeholder="Enter your password"
			required={true}
			field={password}
		/>
	</div>
</div>
