<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import DateInput from '$lib/shared/components/forms/input/DateInput.svelte';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import type { ApiKey } from '../types/base';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';

	export let formApi: FormApi;
	export let formData: ApiKey;
	export let isEditing: boolean;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);
	const expires_at = field('expires_at', formData.expires_at || '', []);
	const is_enabled = field('is_enabled', formData.is_enabled ?? true, []);

	// Update formData when field values change
	$: formData.name = $name.value;
	$: formData.expires_at = $expires_at.value || null;
	$: formData.is_enabled = $is_enabled.value;

	// Track network_id separately to force reactivity
	let selectedNetworkId = formData.network_id;
	$: formData.network_id = selectedNetworkId;

	// Get minimum date (today)
	const today = new Date().toISOString().slice(0, 16);
</script>

<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Key Details</h3>

	<TextInput
		label="Name"
		id="name"
		{formApi}
		placeholder="e.g., Production Daemon Key, Terraform Deployment"
		required={true}
		field={name}
		helpText="A friendly name to help you identify this key"
	/>

	<SelectNetwork bind:selectedNetworkId disabled={isEditing} />

	<TagPicker bind:selectedTagIds={formData.tags} />

	<DateInput
		label="Expiration Date (Optional)"
		id="expires_at"
		{formApi}
		field={expires_at}
		helpText="Leave empty for keys that never expire"
		min={today}
	/>

	<Checkbox
		field={is_enabled}
		{formApi}
		label="Enable API Key"
		helpText="Manually enable or disable API Key. Will be auto-disabled if used in a request after expiry date passes."
		id="enableApiKey"
	/>
</div>
