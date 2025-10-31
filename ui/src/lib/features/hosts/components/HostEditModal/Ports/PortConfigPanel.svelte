<script lang="ts">
	import { field } from 'svelte-forms';
	import type { Port } from '$lib/features/hosts/types/base';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import { required } from 'svelte-forms/validators';
	import { portRange } from '$lib/shared/components/forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import ConfigHeader from '$lib/shared/components/forms/config/ConfigHeader.svelte';

	export let formApi: FormApi;
	export let port: Port;
	export let onChange: (updatedPort: Port) => void = () => {};

	let currentPortId: string = port.id;

	const getPortNumberField = () => {
		return field(`port_${currentPortId}_number`, port.number, [portRange(), required()], {
			checkOnInit: false
		});
	};

	const getPortProtocolField = () => {
		return field(`port_${currentPortId}_protocol`, port.protocol, [], { checkOnInit: false });
	};

	let portNumberField = getPortNumberField();
	let portProtocolField = getPortProtocolField();

	// Reset fields when port changes
	$: if (port.id !== currentPortId) {
		currentPortId = port.id;
		portNumberField = getPortNumberField();
		portProtocolField = getPortProtocolField();
	}

	// Update port when field values change
	$: if ($portNumberField && $portProtocolField) {
		const updatedPort: Port = {
			...port,
			number: Number($portNumberField.value), // Explicitly convert to number
			protocol: $portProtocolField.value
		};

		if (updatedPort.number !== port.number || updatedPort.protocol !== port.protocol) {
			onChange(updatedPort);
		}
	}
</script>

<div class="space-y-6">
	<ConfigHeader title="Port Configuration" subtitle="Configure the port number and protocol" />

	<div class="space-y-4">
		{#if $portNumberField}
			<TextInput
				label="Port Number"
				id="port_{port.id}_number"
				type="number"
				{formApi}
				required={true}
				field={portNumberField}
				placeholder="80"
			/>
		{/if}

		{#if $portProtocolField}
			<SelectInput
				label="Protocol"
				id="port_{port.id}_protocol"
				{formApi}
				field={portProtocolField}
				options={[
					{ label: 'TCP', value: 'Tcp' },
					{ label: 'UDP', value: 'Udp' }
				]}
			/>
		{/if}
	</div>
</div>
