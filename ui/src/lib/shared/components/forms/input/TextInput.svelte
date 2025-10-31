<script lang="ts">
	import FormField from './FormField.svelte';
	import type { TextFieldType, FormApi, NumberFieldType } from '../types';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType | NumberFieldType;
	export let id: string;
	export let placeholder: string = '';
	export let required: boolean = false;
	export let helpText: string = '';
	export let type: 'text' | 'email' | 'password' | 'number' = 'text';
	export let disabled: boolean = false;
	export let showValidation: boolean = true;

	// Enable validation on user interaction
	function enableValidation() {
		showValidation = true;
	}

	$: if ($field.errors.length > 0) {
		showValidation = true;
	}
</script>

<FormField
	{label}
	{formApi}
	{field}
	{required}
	{helpText}
	errors={showValidation ? $field.errors : []}
	{showValidation}
	{id}
>
	<input
		{id}
		{type}
		bind:value={$field.value}
		{placeholder}
		{disabled}
		class={`input-field ${showValidation && $field.errors.length > 0 ? 'input-field-error' : ''}`}
		on:blur={enableValidation}
		on:input={() => {
			if (showValidation) field.validate();
		}}
	/>
</FormField>
