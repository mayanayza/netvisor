<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import type { Group } from '../../types/base';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import { groupTypes } from '$lib/shared/stores/metadata';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';

	export let formApi: FormApi;
	export let formData: Group;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);
	const description = field('description', formData.description || '', [maxLength(500)]);

	// Update formData when field values change
	$: formData.name = $name.value;
	$: formData.description = $description.value;

	// Track network_id separately to force reactivity
	let selectedNetworkId = formData.network_id;
	$: formData.network_id = selectedNetworkId;
</script>

<!-- Basic Information -->
<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Group Details</h3>

	<TextInput
		label="Group Name"
		id="name"
		{formApi}
		placeholder="e.g., DNS Resolution Path, Web Access Chain"
		required={true}
		field={name}
	/>

	<SelectNetwork bind:selectedNetworkId />

	<!-- Group Type -->
	<label for="group_type" class="text-secondary mb-2 block text-sm font-medium"> Group Type </label>
	<select id="group_type" bind:value={formData.group_type} class="input-field">
		{#each groupTypes.getItems() as group_type (group_type.id)}
			<option class="select-option" value={group_type.id}>{group_type.name}</option>
		{/each}
	</select>
	<p class="text-tertiary text-xs">{groupTypes.getDescription(formData.group_type)}</p>

	<TextArea
		label="Description"
		id="description"
		{formApi}
		placeholder="Describe the data flow or purpose of this group..."
		field={description}
	/>
</div>
