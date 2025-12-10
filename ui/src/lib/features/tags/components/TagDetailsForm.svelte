<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import type { Tag } from '../types/base';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import { createColorHelper, AVAILABLE_COLORS } from '$lib/shared/utils/styling';

	export let formApi: FormApi;
	export let formData: Tag;

	const name = field('name', formData.name, [required(), maxLength(100)]);
	const description = field('description', formData.description || '', [maxLength(500)]);

	$: formData.name = $name.value;
	$: formData.description = $description.value || null;
</script>

<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Tag Details</h3>

	<TextInput
		label="Tag Name"
		id="name"
		{formApi}
		placeholder="e.g., Production, Critical, Staging"
		required={true}
		field={name}
	/>

	<TextArea
		label="Description"
		id="description"
		{formApi}
		placeholder="Describe what this tag represents..."
		field={description}
	/>

	<!-- Color Selector -->
	<div class="space-y-3">
		<div class="text-secondary block text-sm font-medium">Color</div>
		<div class="grid grid-cols-7 gap-2">
			{#each AVAILABLE_COLORS as color (color)}
				{@const colorHelper = createColorHelper(color)}
				<button
					type="button"
					onclick={() => (formData.color = color)}
					class="group relative aspect-square w-full rounded-lg border-2 transition-all hover:scale-110"
					class:border-gray-500={formData.color !== color}
					class:border-white={formData.color === color}
					class:ring-2={formData.color === color}
					class:ring-white={formData.color === color}
					style="background-color: {colorHelper.rgb};"
					title={color}
				></button>
			{/each}
		</div>
	</div>
</div>
