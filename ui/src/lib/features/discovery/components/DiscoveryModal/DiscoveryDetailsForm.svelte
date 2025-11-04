<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import { DaemonDisplay } from '$lib/shared/components/forms/selection/display/DaemonDisplay.svelte';
	import type { Discovery } from '../../types/base';
	import type { Daemon } from '$lib/features/daemons/types/base';

	export let formApi: FormApi;
	export let formData: Discovery;
	export let daemons: Daemon[] = [];
	export let readOnly: boolean = false;

	// Create form fields with validation
	const name = field('name', formData.name, [required(), maxLength(100)]);

	console.log(readOnly);

	// Update formData when field values change
	$: formData.name = $name.value;
</script>

<div class="space-y-4">
	<h3 class="text-primary text-lg font-medium">Discovery Details</h3>

	<TextInput
		label="Discovery Name"
		id="name"
		{formApi}
		placeholder="e.g., Daily Network Scan, Docker Services Check"
		required={true}
		field={name}
		disabled={readOnly}
	/>

	<!-- Daemon Selection -->
	<div class="space-y-2">
		<RichSelect
			label="Daemon"
			required={true}
			placeholder="Select daemon to run discovery..."
			disabled={readOnly}
			selectedValue={formData.daemon_id}
			options={daemons}
			displayComponent={DaemonDisplay}
			onSelect={(value) => {
				formData = { ...formData, daemon_id: value };
			}}
		/>
		<p class="text-tertiary text-xs">The daemon that will execute this discovery</p>
	</div>
</div>
