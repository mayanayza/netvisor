<script lang="ts">
	import type { TextFieldType, FormApi } from '../types';
	import FormField from './FormField.svelte';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType;
	export let placeholder: string = '';
	export let required: boolean = false;
	export let helpText: string = '';
	export let id: string = '';
	export let rows: number = 3;
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
	<textarea
		{id}
		bind:value={$field.value}
		{placeholder}
		{rows}
		{disabled}
		class={`input-field ${showValidation && $field.errors.length > 0 ? 'input-field-error' : ''}`}
		on:blur={enableValidation}
		on:input={() => {
			if (showValidation) field.validate();
		}}
	></textarea>
</FormField>
