<script lang="ts">
	import FormField from './FormField.svelte';
	import type { TextFieldType, FormApi, NumberFieldType } from '../types';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType | NumberFieldType;
	export let id: string;
	export let options: { value: string; label: string; id?: string; disabled?: boolean }[];
	export let helpText: string = '';
	export let disabled: boolean = false;
</script>

<FormField {label} {formApi} {field} {helpText} {id}>
	<select {id} bind:value={$field.value} {disabled} class="input-field">
		{#each options as option (option.id ? option.id : option.value)}
			<option disabled={option.disabled} value={option.value}>{option.label}</option>
		{/each}
	</select>
</FormField>
