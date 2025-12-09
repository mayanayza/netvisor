<script lang="ts">
	import type { FormApi, MultiSelectFieldType } from '../types';
	import FormField from './FormField.svelte';

	export let label: string;
	export let formApi: FormApi;
	export let field: MultiSelectFieldType;
	export let helpText: string;
	export let id: string;
	export let options: {
		value: string;
		label: string;
		id?: string;
		disabled?: boolean;
		description?: string;
	}[];
</script>

<FormField {label} {formApi} {field} {helpText} {id}>
	<select
		{id}
		multiple
		bind:value={$field.value}
		class="text-primary w-full rounded-md border border-gray-600 bg-gray-700 px-2 py-1.5 text-xs focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
	>
		{#each options as option (option?.id ? option.id : option.value)}
			<option value={option.value} selected={$field.value.includes(option.value)}>
				{option.label}
			</option>
		{/each}
	</select>
</FormField>

<style>
	/* Style multi-select options */
	select[multiple] option {
		padding: 0.25rem 0.5rem;
		cursor: pointer;
	}

	select[multiple] option:checked {
		background-color: rgb(37, 99, 235);
		color: white;
	}

	/* Remove default select styling for multi-select */
	select[multiple] {
		scrollbar-width: thin;
		scrollbar-color: #4b5563 #1f2937;
	}

	select[multiple]::-webkit-scrollbar {
		width: 8px;
	}

	select[multiple]::-webkit-scrollbar-track {
		background: #1f2937;
	}

	select[multiple]::-webkit-scrollbar-thumb {
		background-color: #4b5563;
		border-radius: 4px;
	}
</style>
