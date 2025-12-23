<script lang="ts">
	import { formatInterface, getInterfaceFromId } from '$lib/features/hosts/store';
	import type { Host } from '$lib/features/hosts/types/base';
	import type { InterfaceBinding, Service } from '$lib/features/services/types/base';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import { field } from 'svelte-forms';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';

	export let binding: InterfaceBinding;
	export let onUpdate: (updates: Partial<InterfaceBinding>) => void = () => {};
	export let formApi: FormApi;
	export let service: Service | undefined = undefined;
	export let host: Host | undefined = undefined;

	// Interface binding must have an interface_id
	$: ifaceStore = binding.interface_id ? getInterfaceFromId(binding.interface_id) : null;
	$: iface = ifaceStore ? $ifaceStore : null;

	// Create interface options with disabled state
	$: interfaceOptions =
		host?.interfaces.map((iface) => {
			// Can't select if THIS service has Port bindings on this interface
			const thisServiceHasPortBindings = service?.bindings.some(
				(b) => b.type === 'Port' && b.interface_id === iface.id
			);
			if (thisServiceHasPortBindings && iface.id !== binding.interface_id) {
				return {
					iface,
					disabled: true,
					reason: 'This service has Port bindings on this interface'
				};
			}

			return {
				iface,
				disabled: false,
				reason: null
			};
		}) || [];

	// Create svelte-forms field - interface_id is required for Interface bindings
	const getInterfaceField = () => {
		return field(`interface_binding_${binding.id}`, binding.interface_id ?? '', [], {
			checkOnInit: false
		});
	};

	let currentBindingId: string = binding.id;
	let interfaceField = getInterfaceField();

	// Reinitialize field when binding changes
	$: if (binding.id !== currentBindingId) {
		currentBindingId = binding.id;
		interfaceField = getInterfaceField();
	}

	// Update binding when field value changes
	$: if ($interfaceField) {
		const interfaceId: string = $interfaceField.value;

		// Only trigger onUpdate if value actually changed
		if (interfaceId !== binding.interface_id) {
			onUpdate({ interface_id: interfaceId });
		}
	}

	// Build select options for interfaces
	$: interfaceSelectOptions = interfaceOptions.map(({ iface, disabled, reason }) => ({
		value: iface.id,
		label: formatInterface(iface) + (disabled && reason ? ` - ${reason}` : ''),
		id: iface.id,
		disabled
	}));
</script>

<div class="flex-1">
	<div class="text-secondary mb-1 block text-xs font-medium">Interface Binding</div>

	{#if !service}
		<div class="text-danger rounded border border-red-600 bg-red-900/20 px-2 py-1 text-xs">
			Service not found
		</div>
	{:else if !host}
		<div class="text-danger rounded border border-red-600 bg-red-900/20 px-2 py-1 text-xs">
			Host not found
		</div>
	{:else}
		<div class="flex gap-3">
			<div class="flex-1">
				{#if host.interfaces && host.interfaces.length === 0}
					<div
						class="rounded border border-yellow-600 bg-yellow-900/20 px-2 py-1 text-xs text-warning"
					>
						No interfaces configured on host
					</div>
				{:else if host.interfaces && host.interfaces.length === 1}
					<!-- Single interface - show as read-only -->
					<div class="text-secondary rounded border border-gray-600 bg-gray-700 px-2 py-1 text-sm">
						{iface ? formatInterface(iface) : 'Unknown Interface'}
					</div>
				{:else if host.interfaces.length > 0 && $interfaceField}
					<!-- Multiple interfaces - show as dropdown with SelectInput -->
					<SelectInput
						label=""
						id="interface_binding_{binding.id}"
						{formApi}
						field={interfaceField}
						options={interfaceSelectOptions}
					/>
				{/if}
			</div>
		</div>
	{/if}
</div>
