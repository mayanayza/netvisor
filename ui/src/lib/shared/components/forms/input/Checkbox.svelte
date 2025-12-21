<script lang="ts">
	import type { BooleanFieldType, FormApi } from '../types';
	import FormField from './FormField.svelte';

	export let label: string;
	export let helpText: string = '';
	export let formApi: FormApi;
	export let field: BooleanFieldType;
	export let id: string;
	export let required: boolean = false;
	export let disabled: boolean = false;
</script>

<div class:disabled>
	<FormField {label} {formApi} {field} {helpText} {id} inline={true} {required}>
		<input
			type="checkbox"
			{id}
			checked={$field.value}
			{disabled}
			on:change={(e) => field.set(e.currentTarget.checked)}
			class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-1 focus:ring-blue-500 disabled:cursor-not-allowed disabled:opacity-50"
		/>
	</FormField>
</div>

<style>
	input[type='checkbox']:checked {
		background-color: rgb(37, 99, 235);
		border-color: rgb(37, 99, 235);
	}

	.disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	.disabled :global(label) {
		cursor: not-allowed;
	}
</style>
