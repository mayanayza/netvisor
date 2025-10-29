<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import {
		minLength,
		maxLength,
		usernamePattern,
		passwordComplexity,
		passwordMatch
	} from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { RegisterRequest } from '../types/base';

	export let formApi: FormApi;
	export let formData: RegisterRequest & { confirmPassword: string };

	// Create form fields with validation
	const username = field('username', formData.username, [
		required(),
		minLength(3),
		maxLength(50),
		usernamePattern()
	]);
	const password = field('password', formData.password, [
		required(),
		minLength(12),
		passwordComplexity()
	]);
	const confirmPassword = field('confirmPassword', formData.confirmPassword, [
		required(),
		passwordMatch(() => $password.value)
	]);

	// Update formData when field values change
	$: formData.username = $username.value;
	$: formData.password = $password.value;
	$: formData.confirmPassword = $confirmPassword.value;

	// Show password requirements
	$: passwordValue = $password.value;
	$: hasUppercase = /[A-Z]/.test(passwordValue);
	$: hasLowercase = /[a-z]/.test(passwordValue);
	$: hasNumber = /[0-9]/.test(passwordValue);
	$: hasSpecial = /[^A-Za-z0-9]/.test(passwordValue);
	$: passwordLongEnough = passwordValue.length >= 12;
</script>

<div class="space-y-6">
	<div class="space-y-4">
		<TextInput
			label="Username"
			id="username"
			{formApi}
			placeholder="Choose a username"
			required={true}
			field={username}
			helpText="3-50 characters, letters, numbers, and underscores only"
		/>

		<div>
			<TextInput
				label="Password"
				id="password"
				type="password"
				{formApi}
				placeholder="Create a strong password"
				required={true}
				field={password}
			/>

			<!-- Password Requirements -->
			{#if passwordValue}
				<div class="mt-2 space-y-1 rounded-md bg-gray-700 p-3">
					<p class="text-xs font-medium text-gray-300">Password Requirements:</p>
					<p class="text-xs {passwordLongEnough ? 'text-green-400' : 'text-gray-400'}">
						{passwordLongEnough ? '✓' : '○'} At least 12 characters
					</p>
					<p class="text-xs {hasUppercase ? 'text-green-400' : 'text-gray-400'}">
						{hasUppercase ? '✓' : '○'} Contains uppercase letter
					</p>
					<p class="text-xs {hasLowercase ? 'text-green-400' : 'text-gray-400'}">
						{hasLowercase ? '✓' : '○'} Contains lowercase letter
					</p>
					<p class="text-xs {hasNumber ? 'text-green-400' : 'text-gray-400'}">
						{hasNumber ? '✓' : '○'} Contains number
					</p>
					<p class="text-xs {hasSpecial ? 'text-green-400' : 'text-gray-400'}">
						{hasSpecial ? '✓' : '○'} Contains special character
					</p>
				</div>
			{/if}
		</div>

		<TextInput
			label="Confirm Password"
			id="confirmPassword"
			type="password"
			{formApi}
			placeholder="Re-enter your password"
			required={true}
			field={confirmPassword}
		/>
	</div>
</div>
