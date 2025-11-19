<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength, minLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import type { Topology } from '../types/base';

	export let formApi: FormApi;
	export let formData: Topology;
	export let isEditing: boolean;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100), minLength(3)]);

	// Update formData when field values change
	$: formData.name = $name.value;

	// Track network_id separately to force reactivity
	let selectedNetworkId = formData.network_id;
	$: formData.network_id = selectedNetworkId;
</script>

<div class="space-y-4">
	<SelectNetwork bind:selectedNetworkId disabled={isEditing} />

	<TextInput
		label="Name"
		id="name"
		{formApi}
		placeholder="Enter topology name"
		required={true}
		field={name}
	/>
</div>
