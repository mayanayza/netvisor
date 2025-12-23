<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import type { Host } from '$lib/features/hosts/types/base';
	import {
		hostname as hostnameValidator,
		maxLength
	} from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';

	export let host: Host | null = null;
	export let formApi: FormApi;
	export let formData: Host;
	export let isEditing: boolean;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);
	const description = field('description', formData.description || '', [maxLength(500)]);
	const hostname = field('hostname', formData.hostname || '', [hostnameValidator()]);

	// Update formData when field values change
	$: formData.name = $name.value;
	$: formData.description = $description.value;
	$: formData.hostname = $hostname.value;

	// Track network_id separately to force reactivity
	let selectedNetworkId = formData.network_id;
	$: formData.network_id = selectedNetworkId;
</script>

<div class="space-y-6 p-6">
	<div class="grid grid-cols-2 gap-6">
		<TextInput
			label="Name"
			id="name"
			{formApi}
			placeholder="Enter a name for this host..."
			required={true}
			field={name}
		/>

		<TextInput
			label="Hostname"
			id="hostname"
			{formApi}
			placeholder="api.example.com"
			field={hostname}
		/>
	</div>

	<SelectNetwork bind:selectedNetworkId />

	<TextArea
		label="Description"
		id="description"
		{formApi}
		placeholder="Describe what this host does or its role in your infrastructure"
		field={description}
	/>

	<TagPicker bind:selectedTagIds={formData.tags} />

	{#if isEditing}
		<EntityMetadataSection entities={[host]} />
	{/if}
</div>
