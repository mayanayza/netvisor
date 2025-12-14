<script lang="ts">
	import { Globe, Network } from 'lucide-svelte';
	import type { Host } from '$lib/features/hosts/types/base';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import type { FormType } from '$lib/shared/components/forms/types';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { getBindingFromId, getServicesForHost } from '$lib/features/services/store';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import { derived, readable } from 'svelte/store';

	export let form: FormType;
	export let formData: Host;

	$: selectedBindingStore =
		formData.target.type == 'ServiceBinding'
			? getBindingFromId(formData.target.config)
			: readable(null);

	$: selectedBinding = $selectedBindingStore;

	$: serviceBindingsStore = derived(getServicesForHost(formData.id), ($services) =>
		$services.flatMap((s) => s.bindings)
	);
	$: serviceBindings = $serviceBindingsStore;

	$: hostnameField = form.getField('hostname');
	$: has_hostname = $hostnameField ? $hostnameField.value.length > 0 : false;

	// Form fields
	$: targetTypes = [
		{
			value: 'ServiceBinding',
			label: formData.interfaces.length != 0 ? 'Service Binding' : 'No Services Configured',
			description: 'Connect to a service port on a network interface',
			disabled: serviceBindings.length === 0,
			icon: Network
		},
		{
			value: 'Hostname',
			label: has_hostname ? 'Hostname' : 'No Hostname Configured',
			description: "Connect using the host's hostname field",
			disabled: !has_hostname,
			icon: Globe
		},
		{
			value: 'None',
			label: 'None',
			description: 'No connection set for this host',
			disabled: false,
			icon: Globe
		}
	];

	// Initialize target if not set
	$: if (!formData.target) {
		formData.target = {
			type: 'Hostname'
		};
	}

	// Handle target type changes
	function handleTargetTypeChange(event: Event) {
		const targetElement = event.target as HTMLSelectElement;
		const newType = targetElement.value;

		// Reset target config when type changes
		if (newType === 'ServiceBinding') {
			let binding_id = serviceBindings[0].id;
			formData.target = {
				type: 'ServiceBinding',
				config: binding_id
			};
		} else if (newType === 'Hostname') {
			formData.target = {
				type: 'Hostname'
			};
		} else if (newType === 'None') {
			formData.target = {
				type: 'None'
			};
		}

		// Force reactivity update
		formData = { ...formData };
	}

	// Handle interface selection
	function handleServiceBindingSelect(binding_id: string) {
		if (formData.target.type == 'ServiceBinding') {
			formData.target.config = binding_id;
		}
		// Force reactivity update
		formData = { ...formData };
	}
</script>

<div class="flex items-start gap-6">
	<!-- Target Type Selection -->
	<div class="flex w-1/3 flex-col space-y-2">
		<label for="target_type" class="text-secondary block text-sm font-medium"> Link Type </label>
		<select
			id="target_type"
			value={formData.target?.type || 'Interface'}
			on:change={handleTargetTypeChange}
			class="input-field"
		>
			{#each targetTypes as targetType (targetType.value)}
				<option class="select-option" disabled={targetType.disabled} value={targetType.value}
					>{targetType.label}</option
				>
			{/each}
		</select>
		<p class="text-tertiary text-xs">How should Scanopy display a link for this host?</p>
	</div>

	<!-- Target Configuration -->
	<div class="flex flex-grow flex-col">
		{#if formData.target}
			<div class="space-y-4">
				{#if formData.target.type === 'ServiceBinding'}
					<!-- Interface Selection -->
					<div class="space-y-2">
						<label for="interface_select" class="text-secondary block text-sm font-medium">
							Service Binding
							<span class="text-danger ml-1">*</span>
						</label>

						{#if formData.interfaces.length == 0}
							<InlineWarning
								title="No services available"
								body="No services available. Add a service or change target type."
							/>
						{:else}
							<RichSelect
								selectedValue={selectedBinding ? selectedBinding.id : null}
								options={serviceBindings}
								placeholder="Select a service binding..."
								displayComponent={BindingWithServiceDisplay}
								onSelect={handleServiceBindingSelect}
							/>
						{/if}
					</div>
				{:else if formData.target.type === 'Hostname'}
					<!-- Hostname Display -->
					<div class="space-y-2">
						<div class="text-secondary block text-sm font-medium">Hostname</div>
						<div
							class="text-secondary flex w-full items-center gap-2 rounded-md border border-gray-500 bg-gray-800/50 px-3 py-2"
						>
							<span class="font-mono">{formData.hostname}</span>
						</div>
					</div>
				{/if}
			</div>
		{/if}
	</div>
</div>
