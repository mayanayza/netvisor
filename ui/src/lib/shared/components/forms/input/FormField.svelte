<script lang="ts">
	import { AlertCircle } from 'lucide-svelte';
	import type {
		TextFieldType,
		FormApi,
		NumberFieldType,
		BooleanFieldType,
		MultiSelectFieldType
	} from '../types';
	import { onMount } from 'svelte';

	export let label: string;
	export let formApi: FormApi;
	export let field: TextFieldType | NumberFieldType | BooleanFieldType | MultiSelectFieldType;
	export let required: boolean = false;
	export let helpText: string = '';
	export let errors: string[] = [];
	export let showValidation: boolean = true;
	export let id: string = '';
	export let inline: boolean = false;

	onMount(() => {
		formApi.registerField(id, field);
	});
</script>

{#if inline}
	<div class="space-y-2">
		<label
			for={id}
			class="text-secondary flex cursor-pointer items-center gap-3 text-sm font-medium"
		>
			<slot />
			{label}
		</label>

		{#if showValidation && errors.length > 0}
			<div class="text-danger flex items-center gap-2">
				<AlertCircle size={16} />
				<p class="text-xs">{errors[0]}</p>
			</div>
		{/if}

		{#if helpText}
			<p class="text-tertiary text-xs">{helpText}</p>
		{/if}
	</div>
{:else}
	<div class="space-y-2">
		<label for={id} class="text-secondary block text-sm font-medium">
			{label}
			{#if required}
				<span class="text-danger ml-1">*</span>
			{/if}
		</label>

		<slot />

		{#if showValidation && errors.length > 0}
			<div class="text-danger flex items-center gap-2">
				<AlertCircle size={16} />
				<p class="text-xs">{errors[0]}</p>
			</div>
		{/if}

		{#if helpText}
			<p class="text-tertiary text-xs">{helpText}</p>
		{/if}
	</div>
{/if}
