<script lang="ts">
	import FormField from './FormField.svelte';
	import type { TextFieldType, FormApi, NumberFieldType } from '../types';
	import InlineInfo from '../../feedback/InlineInfo.svelte';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType | NumberFieldType;
	export let id: string;
	export let options: {
		value: string;
		label: string;
		id?: string;
		disabled?: boolean;
		description?: string;
	}[];
	export let helpText: string = '';
	export let disabled: boolean = false;

	$: selectedOption = options.find((f) => f.value == $field.value);
	$: description = selectedOption ? selectedOption.description : '';
</script>

<FormField {label} {formApi} {field} {helpText} {id}>
	<select
		{id}
		bind:value={$field.value}
		{disabled}
		class="input-field"
		onclick={(e) => e.stopPropagation()}
	>
		{#each options as option (option.id ? option.id : option.value)}
			<option disabled={option.disabled} value={option.value}>{option.label}</option>
		{/each}
	</select>
</FormField>
{#if selectedOption && description && description.length > 0}
	<InlineInfo title={label} body={description} />
{/if}
