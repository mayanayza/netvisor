<script lang="ts">
	import { formatInterface } from '$lib/features/hosts/store';
	import { ALL_INTERFACES, type Host } from '$lib/features/hosts/types/base';
	import { getServicesForPort } from '$lib/features/services/store';
	import type { PortBinding, Service } from '$lib/features/services/types/base';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { get } from 'svelte/store';
	import { field } from 'svelte-forms';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';

	export let binding: PortBinding;
	export let onUpdate: (updates: Partial<PortBinding>) => void = () => {};
	export let formApi: FormApi;
	export let service: Service | undefined = undefined;
	export let host: Host | undefined = undefined;

	// Type guard for services with Port bindings
	function isServiceWithPortBindings(svc: Service): svc is Service {
		return svc.bindings.length === 0 || svc.bindings.every((b) => b.type === 'Port');
	}

	// Check if this port+interface combination conflicts with existing bindings
	function getConflictingService(portId: string, interfaceId: string | null): Service | null {
		// Check OTHER services
		const otherServices = get(getServicesForPort(portId))
			.filter((s) => s.id !== service?.id)
			.filter(isServiceWithPortBindings);

		for (const svc of otherServices) {
			const hasConflict = svc.bindings.some((b) => {
				// If either binding is to ALL_INTERFACES (null), they conflict
				if (b.interface_id === null || interfaceId === null) {
					return true;
				}
				// Otherwise, they conflict only if they're the same specific interface
				return b.interface_id === interfaceId;
			});
			if (hasConflict) return svc;
		}

		// Check OTHER bindings in current service
		if (service) {
			const otherBindings = service.bindings.filter(
				(b) => b.type === 'Port' && b.id !== binding.id && b.port_id === portId
			);
			const hasConflict = otherBindings.some((b) => {
				// If either binding is to ALL_INTERFACES (null), they conflict
				if (b.interface_id === null || interfaceId === null) {
					return true;
				}
				// Otherwise, they conflict only if they're the same specific interface
				return b.interface_id === interfaceId;
			});
			if (hasConflict) return service;
		}

		return null;
	}

	// Create interface options with disabled state
	$: interfaceOptions =
		host?.interfaces.map((iface) => {
			// Check for Interface binding conflict - can't add Port binding if THIS service has Interface binding here
			const thisServiceHasInterfaceBinding = service?.bindings.some(
				(b) => b.type === 'Interface' && b.interface_id === iface.id && b.id !== binding.id
			);
			if (thisServiceHasInterfaceBinding) {
				return {
					iface,
					disabled: true,
					reason: 'This service has an Interface binding here',
					boundService: service
				};
			}

			// Check for Port binding conflict (port_id is required for Port bindings)
			const boundService = binding.port_id ? getConflictingService(binding.port_id, iface.id) : null;
			return {
				iface,
				disabled: boundService !== null && iface.id !== binding.interface_id,
				reason: boundService ? `Port bound by ${boundService.name}` : null,
				boundService
			};
		}) || [];

	// Check ALL_INTERFACES option
	$: allInterfacesOption = (() => {
		const boundService = binding.port_id ? getConflictingService(binding.port_id, null) : null;
		return {
			iface: ALL_INTERFACES,
			disabled: boundService !== null && binding.interface_id !== null,
			reason: boundService ? `Port bound by ${boundService.name}` : null,
			boundService
		};
	})();

	// Create port options with disabled state
	$: portOptions =
		host?.ports.map((p) => {
			const boundService = getConflictingService(p.id, binding.interface_id);
			return {
				port: p,
				disabled: boundService !== null && p.id !== binding.port_id,
				reason: boundService ? `Bound by ${boundService.name}` : null,
				boundService
			};
		}) || [];

	// Convert binding.interface_id to select value (null -> sentinel string)
	$: selectInterfaceValue =
		binding.interface_id === null ? ALL_INTERFACES.name : binding.interface_id;

	// Create svelte-forms fields
	const getInterfaceField = () => {
		return field(`binding_${binding.id}_interface`, selectInterfaceValue, [], {
			checkOnInit: false
		});
	};

	const getPortField = () => {
		// Port binding must have a port_id, use empty string as fallback for form state
		return field(`binding_${binding.id}_port`, binding.port_id ?? '', [], {
			checkOnInit: false
		});
	};

	let currentBindingId: string = binding.id;
	let interfaceField = getInterfaceField();
	let portField = getPortField();

	// Reinitialize fields when binding changes
	$: if (binding.id !== currentBindingId) {
		currentBindingId = binding.id;
		interfaceField = getInterfaceField();
		portField = getPortField();
	}

	// Update binding when field values change
	$: if ($interfaceField && $portField) {
		// Convert sentinel string back to null for interface
		const interfaceId: string | null =
			$interfaceField.value === ALL_INTERFACES.name ? null : $interfaceField.value;

		const portId = $portField.value;

		// Only trigger onUpdate if values actually changed
		if (interfaceId !== binding.interface_id || portId !== binding.port_id) {
			onUpdate({
				interface_id: interfaceId,
				port_id: portId
			});
		}
	}

	// Build select options for interfaces
	$: interfaceSelectOptions = [
		...interfaceOptions.map(({ iface, disabled, reason }) => ({
			value: iface.id,
			label: formatInterface(iface) + (disabled && reason ? ` - ${reason}` : ''),
			id: iface.id,
			disabled
		})),
		{
			value: ALL_INTERFACES.name,
			label:
				formatInterface(ALL_INTERFACES) +
				(allInterfacesOption.disabled && allInterfacesOption.reason
					? ` - ${allInterfacesOption.reason}`
					: ''),
			id: ALL_INTERFACES.name,
			disabled: allInterfacesOption.disabled
		}
	];

	// Build select options for ports
	$: portSelectOptions = portOptions.map(({ port, disabled, reason }) => ({
		value: port.id,
		label: formatPort(port) + (disabled && reason ? ` - ${reason}` : ''),
		id: port.id,
		disabled
	}));
</script>

<div class="flex-1">
	<div class="text-secondary mb-1 block text-xs font-medium">Port Binding</div>

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
			{#if host.interfaces && host.interfaces.length === 0}
				<div class="flex-1">
					<div
						class="rounded border border-yellow-600 bg-yellow-900/20 px-2 py-1 text-xs text-warning"
					>
						No interfaces configured on host
					</div>
				</div>
			{:else if host.interfaces.length > 0 && $interfaceField}
				<SelectInput
					label="Interface"
					id="binding_{binding.id}_interface"
					{formApi}
					field={interfaceField}
					options={interfaceSelectOptions}
				/>
			{/if}

			{#if host.ports.length === 0}
				<div class="flex-1">
					<div
						class="rounded border border-yellow-600 bg-yellow-900/20 px-2 py-1 text-xs text-warning"
					>
						No ports configured on host
					</div>
				</div>
			{:else if $portField}
				<SelectInput
					label="Port"
					id="binding_{binding.id}_port"
					{formApi}
					field={portField}
					options={portSelectOptions}
				/>
			{/if}
		</div>
	{/if}
</div>
