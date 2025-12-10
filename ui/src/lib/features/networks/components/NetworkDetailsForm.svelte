<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import type { Network } from '../types';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';

	export let formApi: FormApi;
	export let formData: Network;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);
	// const description = field('description', formData.description || '', [maxLength(500)]);

	// Update formData when field values change
	$: formData.name = $name.value;
	// $: formData.description = $description.value;
</script>

<!-- Basic Information -->
<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Network Details</h3>

	<TextInput
		label="Network Name"
		id="name"
		{formApi}
		placeholder="e.g Home Network"
		required={true}
		field={name}
	/>
	<!-- 
	<TextArea
		label="Description"
		id="description"
		{formApi}
		placeholder="Describe the data flow or purpose of this service chain..."
		field={description}
	/> -->

	<TagPicker bind:selectedTagIds={formData.tags} />
</div>
