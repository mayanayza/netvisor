<!-- ui/src/lib/shared/components/forms/input/PasswordInput.svelte -->
<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { minLength, passwordComplexity, passwordMatch } from '../validators';
	import type { FormApi } from '../types';
	import TextInput from './TextInput.svelte';

	export let formApi: FormApi;
	export let value: string = '';
	export let showConfirm: boolean = true;
	export let confirmValue: string = '';
	export let label: string = 'Password';
	export let confirmLabel: string = 'Confirm Password';

	// Create form fields with validation
	const password = field('password', value, [required(), minLength(12), passwordComplexity()]);

	const confirmPassword = field('confirmPassword', confirmValue, [
		required(),
		passwordMatch(() => $password.value)
	]);

	// Update parent values when field values change
	$: value = $password.value;
	$: confirmValue = $confirmPassword.value;

	// Show password requirements
	$: passwordValue = $password.value;
	$: hasUppercase = /[A-Z]/.test(passwordValue);
	$: hasLowercase = /[a-z]/.test(passwordValue);
	$: hasNumber = /[0-9]/.test(passwordValue);
	$: hasSpecial = /[^A-Za-z0-9]/.test(passwordValue);
	$: passwordLongEnough = passwordValue.length >= 12;

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

	{#if showConfirm}
		<TextInput
			label={confirmLabel}
			id="confirmPassword"
			type="password"
			{formApi}
			placeholder="Re-enter your password"
			required={true}
			field={confirmPassword}
		/>
	{/if}
</div>
