<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { cidr as cidrValidator, maxLength } from '$lib/shared/components/forms/validators';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import { isContainerSubnet } from '../../store';
	import type { Subnet } from '../../types/base';
	import { get } from 'svelte/store';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';

	export let formApi: FormApi;
	export let formData: Subnet;
	export let isEditing: boolean;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);
	const cidr = field('cidr', formData.cidr, [required(), cidrValidator()]);
	const description = field('description', formData.description || '', [maxLength(500)]);

	// Update formData when field values change
	$: formData.name = $name.value;
	$: formData.description = $description.value;
	$: formData.cidr = $cidr.value;

	// Track network_id separately to force reactivity
	let selectedNetworkId = formData.network_id;
	$: formData.network_id = selectedNetworkId;
</script>

<!-- Basic Information -->
<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Subnet Details</h3>

	<TextInput
		label="Name"
		id="name"
		{formApi}
		placeholder="e.g., Home LAN, VPN Network"
		required={true}
		field={name}
	/>

	<TextInput
		label="CIDR"
		id="cidr"
		{formApi}
		disabled={!!get(isContainerSubnet(formData.id)) || isEditing}
		placeholder="192.168.1.0/24"
		helpText="Network address and prefix length (e.g., 192.168.1.0/24)"
		required={true}
		field={cidr}
	/>

	<SelectNetwork bind:selectedNetworkId />

	<!-- Subnet Type -->
	<div>
		<label for="subnet_type" class="text-secondary mb-2 block text-sm font-medium">
			Subnet Type
		</label>
		<select id="subnet_type" bind:value={formData.subnet_type} class="input-field">
			{#each subnetTypes.getItems() as subnet_type (subnet_type.id)}
				<option class="select-option" value={subnet_type.id}>{subnet_type.name}</option>
			{/each}
		</select>
	</div>

	<TextArea
		label="Description"
		id="description"
		{formApi}
		placeholder="Describe the purpose of this subnet..."
		field={description}
	/>

	<TagPicker bind:selectedTagIds={formData.tags} />
</div>
