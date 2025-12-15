<!-- ui/src/lib/shared/components/forms/input/PasswordInput.svelte -->
<script lang="ts">
	import { field } from 'svelte-forms';
	import { required as requiredValidation } from 'svelte-forms/validators';
	import { minLength, passwordComplexity, passwordMatch } from '../validators';
	import type { FormApi } from '../types';
	import TextInput from './TextInput.svelte';

	export let formApi: FormApi;
	export let value: string = '';
	export let showConfirm: boolean = true;
	export let confirmValue: string = '';
	export let label: string = 'Password';
	export let confirmLabel: string = 'Confirm Password';
	export let required: boolean = true;

	// Create form fields with validation
	let passwordValidation = [minLength(10), passwordComplexity()];
	if (required) passwordValidation.push(requiredValidation());
	const password = field('password', value, passwordValidation);

	let confirmPasswordValidation = [passwordMatch(() => $password.value)];
	if (required) confirmPasswordValidation.push(requiredValidation());
	const confirmPassword = field('confirmPassword', confirmValue, confirmPasswordValidation);

	// Update parent values when field values change
	$: value = $password.value;
	$: confirmValue = $confirmPassword.value;

	// Show password requirements
	$: passwordValue = $password.value;
	$: hasUppercase = /[A-Z]/.test(passwordValue);
	$: hasLowercase = /[a-z]/.test(passwordValue);
	$: hasNumber = /[0-9]/.test(passwordValue);
	$: passwordLongEnough = passwordValue.length >= 10;

	// Expose validation state
	export let isValid = false;
	$: isValid = showConfirm ? $password.valid && $confirmPassword.valid : $password.valid;
</script>

<div class="space-y-4">
	<div>
		<TextInput
			{label}
			id="password"
			type="password"
			{formApi}
			placeholder="Create a strong password"
			{required}
			field={password}
		/>

		<!-- Password Requirements -->
		{#if passwordValue}
			<div class="mt-2 space-y-1 rounded-md bg-gray-700 p-3">
				<p class="text-xs font-medium text-gray-300">Password Requirements:</p>
				<p class="text-xs {passwordLongEnough ? 'text-green-400' : 'text-gray-400'}">
					{passwordLongEnough ? '✓' : '○'} At least 10 characters
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
			</div>
		{/if}
	</div>

	{#if showConfirm}
		<TextInput
			label={confirmLabel}
			id="confirmPassword"
			type="password"
			{formApi}
			placeholder="Re-enter your password"
			{required}
			field={confirmPassword}
		/>
	{/if}
</div>
