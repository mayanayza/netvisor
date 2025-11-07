<script lang="ts">
	import FormField from './FormField.svelte';
	import type { TextFieldType, FormApi } from '../types';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType;
	export let id: string;
	export let placeholder: string = '';
	export let required: boolean = false;
	export let helpText: string = '';
	export let disabled: boolean = false;
	export let showValidation: boolean = true;
	export let min: string | undefined = undefined;
	export let max: string | undefined = undefined;

	// Convert ISO 8601 string to datetime-local format (YYYY-MM-DDTHH:00)
	function toDateTimeLocal(isoString: string): string {
		if (!isoString) return '';
		const date = new Date(isoString);
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0');
		const day = String(date.getDate()).padStart(2, '0');
		const hours = String(date.getHours()).padStart(2, '0');
		const minutes = String(date.getMinutes()).padStart(2, '0');
		return `${year}-${month}-${day}T${hours}:${minutes}`;
	}

	// Convert datetime-local string to ISO 8601 with Z suffix
	function toISO8601(localString: string): string {
		if (!localString) return '';
		const date = new Date(localString);
		return date.toISOString();
	}

	// Local value for the input (datetime-local format)
	let localValue = toDateTimeLocal($field.value);

	// Sync changes back to field in ISO format
	function handleInput(event: Event) {
		const target = event.target as HTMLInputElement;
		localValue = target.value;
		$field.value = toISO8601(localValue);
		if (showValidation) field.validate();
	}

	// Update localValue when field value changes externally
	$: localValue = toDateTimeLocal($field.value);

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
		type="datetime-local"
		value={localValue}
		{placeholder}
		{disabled}
		{min}
		{max}
		class={`input-field datetime-picker ${showValidation && $field.errors.length > 0 ? 'input-field-error' : ''}`}
		on:blur={enableValidation}
		on:input={handleInput}
	/>
</FormField>

<style>
	/* Style the datetime picker to match app theme */
	:global(.datetime-picker) {
		color-scheme: dark;
	}

	/* Style the calendar icon to use text-secondary color */
	:global(.datetime-picker::-webkit-calendar-picker-indicator) {
		cursor: pointer;
	}

	:global(.datetime-picker::-webkit-calendar-picker-indicator:hover) {
		filter: invert(1) opacity(1);
	}
</style>
