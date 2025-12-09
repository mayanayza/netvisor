<script lang="ts">
	import type { BooleanFieldType, FormApi } from '../types';
	import FormField from './FormField.svelte';

	export let label: string;
	export let helpText: string = '';
	export let formApi: FormApi;
	export let field: BooleanFieldType;
	export let id: string;
</script>

<FormField {label} {formApi} {field} {helpText} {id} inline={true}>
	<input
		type="checkbox"
		{id}
		checked={$field.value}
		on:change={(e) => field.set(e.currentTarget.checked)}
		class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-1 focus:ring-blue-500"
	/>
</FormField>

<style>
	input[type='checkbox']:checked {
		background-color: rgb(37, 99, 235);
		border-color: rgb(37, 99, 235);
	}
</style>
