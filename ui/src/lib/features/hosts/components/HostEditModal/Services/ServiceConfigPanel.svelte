<script lang="ts">
	import { field } from 'svelte-forms';
	import type { InterfaceBinding, PortBinding, Service } from '$lib/features/services/types/base';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import { required } from 'svelte-forms/validators';
	import { pushWarning } from '$lib/shared/stores/feedback';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import ConfigHeader from '$lib/shared/components/forms/config/ConfigHeader.svelte';
	import { v4 as uuidv4 } from 'uuid';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { PortBindingDisplay } from '$lib/shared/components/forms/selection/display/PortBindingDisplay.svelte';
	import { InterfaceBindingDisplay } from '$lib/shared/components/forms/selection/display/InterfaceBindingDisplay.svelte';
	import MatchDetails from './MatchDetails.svelte';
	import type { HostFormData } from '$lib/features/hosts/types/base';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';
	import { useInterfacesQuery } from '$lib/features/interfaces/queries';
	import { usePortsQuery } from '$lib/features/ports/queries';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';

	// TanStack Query hooks
	const servicesQuery = useServicesQuery();
	const interfacesQuery = useInterfacesQuery();
	const portsQuery = usePortsQuery();

	let servicesData = $derived(servicesQuery.data ?? []);
	let interfacesData = $derived(interfacesQuery.data ?? []);
	let portsData = $derived(portsQuery.data ?? []);

	// Check if an interface is unsaved (not yet in the global cache)
	function isInterfaceUnsaved(id: string): boolean {
		return !interfacesData.some((i) => i.id === id);
	}

	// Check if a port is unsaved (not yet in the global cache)
	function isPortUnsaved(id: string): boolean {
		return !portsData.some((p) => p.id === id);
	}

	// Get services for a specific port
	function getServicesForPort(portId: string): Service[] {
		const port = portsData.find((p) => p.id === portId);
		if (!port) return [];

		return servicesData.filter(
			(s) =>
				s.host_id === port.host_id &&
				s.bindings.some((b) => b.type === 'Port' && (b as PortBinding).port_id === portId)
		);
	}

	interface Props {
		formApi: FormApi;
		host: HostFormData;
		service: Service;
		onChange?: (updatedService: Service) => void;
		selectedPortBindings?: PortBinding[];
		index?: number;
	}

	let {
		formApi,
		host,
		service,
		onChange = () => {},
		selectedPortBindings = $bindable([]),
		index = -1
	}: Props = $props();

	let currentServiceId = $state(service.id);
	let currentServiceIndex = $state(index);

	const getNameField = () => {
		return field(`service_name_${currentServiceId}_${index}`, service.name, [
			required(),
			maxLength(100)
		]);
	};

	let nameField = $state(getNameField());

	let serviceMetadata = $derived(
		service ? serviceDefinitions.getItem(service.service_definition) : null
	);

	$effect(() => {
		if (currentServiceIndex !== index) {
			currentServiceIndex = index;
			nameField = getNameField();
		}
	});

	// Port Bindings Logic
	let portBindings = $derived(service.bindings.filter((b) => b.type === 'Port') as PortBinding[]);

	// Interface Bindings Logic
	let interfaceBindings = $derived(
		service.bindings.filter((b) => b.type === 'Interface') as InterfaceBinding[]
	);

	// Get interfaces that this service has Port bindings on
	let interfacesWithPortBindingsThisService = $derived(
		new Set(portBindings.map((b) => b.interface_id).filter((id): id is string => id !== null))
	);

	// Get interfaces that this service has Interface bindings on
	let interfacesWithInterfaceBindingsThisService = $derived(
		new Set(interfaceBindings.map((b) => b.interface_id))
	);

	// Available port+interface combinations for new Port bindings
	// Only includes saved interfaces and ports (those not yet in global stores)
	let availablePortCombinations = $derived(
		host.interfaces
			.filter((iface) => !isInterfaceUnsaved(iface.id)) // Skip unsaved interfaces
			.flatMap((iface) => {
				// Can't add Port binding if THIS service has an Interface binding on this interface
				if (interfacesWithInterfaceBindingsThisService.has(iface.id)) {
					return [];
				}

				return host.ports
					.filter((port) => {
						// Skip unsaved ports
						if (isPortUnsaved(port.id)) return false;

						// Check if this specific port+interface combo is already bound by this service
						const alreadyBoundByThisService = portBindings.some(
							(b) => b.port_id === port.id && b.interface_id === iface.id
						);
						if (alreadyBoundByThisService) return false;

						// Get services for this port
						const servicesForPort = getServicesForPort(port.id);
						const otherServices = servicesForPort.filter((s) => s.id !== service.id);

						const boundByOtherService = otherServices.some((s) =>
							s.bindings.some(
								(b) =>
									b.type === 'Port' &&
									(b as PortBinding).port_id === port.id &&
									(b.interface_id === iface.id || b.interface_id === null)
							)
						);
						if (boundByOtherService) return false;

						// Check if this service has bound this port to ALL interfaces (null)
						const boundToAllInterfaces = portBindings.some(
							(b) => b.port_id === port.id && b.interface_id === null
						);
						if (boundToAllInterfaces) return false;

						return true;
					})
					.map((port) => ({ port, iface }));
			})
	);

	// Count of unsaved items for messaging
	let unsavedInterfaceCount = $derived(
		host.interfaces.filter((i) => isInterfaceUnsaved(i.id)).length
	);
	let unsavedPortCount = $derived(host.ports.filter((p) => isPortUnsaved(p.id)).length);
	let hasUnsavedItems = $derived(unsavedInterfaceCount > 0 || unsavedPortCount > 0);

	let canCreatePortBinding = $derived(availablePortCombinations.length > 0);

	// Available interfaces for new Interface bindings
	// Only includes saved interfaces (those already in global store)
	let availableInterfacesForInterfaceBinding = $derived(
		host.interfaces.filter((iface) => {
			// Skip unsaved interfaces
			if (isInterfaceUnsaved(iface.id)) return false;

			// Can't add Interface binding if this service already has one on this interface
			if (interfaceBindings.some((b) => b.interface_id === iface.id)) {
				return false;
			}

			// Can't add Interface binding if THIS service has Port bindings on this interface
			if (interfacesWithPortBindingsThisService.has(iface.id)) {
				return false;
			}

			return true;
		})
	);

	let canCreateInterfaceBinding = $derived(availableInterfacesForInterfaceBinding.length > 0);

	// Update service when field values change
	$effect(() => {
		// eslint-disable-next-line svelte/require-store-reactive-access -- checking if field exists, not its value
		if (nameField) {
			const fieldValue = $nameField;
			const updatedService: Service = {
				...service,
				name: fieldValue.value
			};

			if (updatedService.name !== service.name) {
				onChange(updatedService);
			}
		}
	});

	// Port Binding Handlers
	function handleCreatePortBinding() {
		if (!service) {
			pushWarning('Could not find service to create binding for');
			return;
		}

		if (host.interfaces.length === 0) {
			pushWarning("Host does not have any interfaces, can't create binding");
			return;
		}

		if (host.ports.length === 0) {
			pushWarning("Host does not have any ports, can't create binding");
			return;
		}

		if (!canCreatePortBinding) {
			pushWarning('No available port+interface combinations to bind');
			return;
		}

		const firstAvailable = availablePortCombinations[0];

		const binding: PortBinding = {
			type: 'Port',
			id: uuidv4(),
			service_id: service.id,
			network_id: service.network_id,
			port_id: firstAvailable.port.id,
			interface_id: firstAvailable.iface.id,
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		};

		onChange({
			...service,
			bindings: [...service.bindings, binding]
		});
	}

	function handleRemovePortBinding(index: number) {
		if (!service) {
			pushWarning('Could not find service to remove binding for');
			return;
		}

		const portBindingToRemove = portBindings[index];
		const fullIndex = service.bindings.findIndex((b) => b.id === portBindingToRemove.id);
		onChange({
			...service,
			bindings: service.bindings.filter((_, i) => i !== fullIndex)
		});
	}

	function handleUpdatePortBinding(binding: PortBinding, index: number) {
		if (!service) return;

		const portBindingToUpdate = portBindings[index];
		const fullIndex = service.bindings.findIndex((b) => b.id === portBindingToUpdate.id);

		const updatedBindings = [...service.bindings];
		updatedBindings[fullIndex] = {
			...updatedBindings[fullIndex],
			interface_id: binding.interface_id,
			port_id: binding.port_id
		} as PortBinding;

		onChange({
			...service,
			bindings: updatedBindings
		});
	}

	// Interface Binding Handlers
	function handleCreateInterfaceBinding() {
		if (!service) {
			pushWarning('Could not find service to create binding for');
			return;
		}

		if (host.interfaces.length === 0) {
			pushWarning("Host does not have any interfaces, can't create binding");
			return;
		}

		if (!canCreateInterfaceBinding) {
			pushWarning('No available interfaces to bind');
			return;
		}

		const firstAvailable = availableInterfacesForInterfaceBinding[0];

		const binding: InterfaceBinding = {
			type: 'Interface',
			id: uuidv4(),
			service_id: service.id,
			network_id: service.network_id,
			interface_id: firstAvailable.id,
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		};

		onChange({
			...service,
			bindings: [...service.bindings, binding]
		});
	}

	function handleRemoveInterfaceBinding(index: number) {
		if (!service) {
			pushWarning('Could not find service to remove binding for');
			return;
		}

		const interfaceBindingToRemove = interfaceBindings[index];
		const fullIndex = service.bindings.findIndex((b) => b.id === interfaceBindingToRemove.id);

		onChange({
			...service,
			bindings: service.bindings.filter((_, i) => i !== fullIndex)
		});
	}

	function handleUpdateInterfaceBinding(binding: InterfaceBinding, index: number) {
		if (!service) return;

		const interfaceBindingToUpdate = interfaceBindings[index];
		const fullIndex = service.bindings.findIndex((b) => b.id === interfaceBindingToUpdate.id);

		const updatedBindings = [...service.bindings];
		updatedBindings[fullIndex] = {
			...updatedBindings[fullIndex],
			interface_id: binding.interface_id
		} as InterfaceBinding;

		onChange({
			...service,
			bindings: updatedBindings
		});
	}
</script>

{#if service && serviceMetadata}
	<div class="space-y-6">
		<ConfigHeader title={serviceMetadata.name} subtitle={serviceMetadata.description} />

		<!-- Basic Configuration -->
		<div class="space-y-4">
			<div class="text-primary font-medium">Details</div>
			<!-- Service Name Field -->
			<!-- eslint-disable-next-line svelte/require-store-reactive-access -- checking if field exists -->
			{#if nameField}
				<TextInput
					label="Name"
					id="service_name_{service.id}"
					{formApi}
					required={true}
					placeholder="Enter a descriptive name..."
					field={nameField}
				/>
			{/if}

			<TagPicker bind:selectedTagIds={service.tags} />
		</div>

		<div>
			<div class="text-primary font-medium">Bindings</div>
			<span class="text-muted text-xs">
				For a given interface, a service can have either port bindings OR an interface binding, not
				both.
			</span>
			{#if hasUnsavedItems}
				<InlineWarning
					title={(() => {
						if (unsavedInterfaceCount > 0 && unsavedPortCount > 0) {
							return `${unsavedInterfaceCount} unsaved interface${unsavedInterfaceCount > 1 ? 's' : ''} and ${unsavedPortCount}
							unsaved port${unsavedPortCount > 1 ? 's' : ''} — save host to bind to them.`;
						} else if (unsavedInterfaceCount > 0) {
							return `${unsavedInterfaceCount} unsaved interface${unsavedInterfaceCount > 1 ? 's' : ''} — save
							host to bind to ${unsavedInterfaceCount > 1 ? 'them' : 'it'}.`;
						} else {
							return `${unsavedPortCount} unsaved port${unsavedPortCount > 1 ? 's' : ''} — save host to bind to
							${unsavedPortCount > 1 ? 'them' : 'it'}.`;
						}
					})()}
				/>
			{/if}
		</div>
		<!-- Port Bindings -->
		<div class="space-y-4">
			{#key `${service.id}`}
				<ListManager
					label="Port Bindings"
					helpText="Configure which ports this service listens on for a given interface"
					placeholder="Select a binding to add"
					createNewLabel="New Binding"
					allowDuplicates={false}
					allowItemEdit={() => true}
					allowItemRemove={() => true}
					allowSelection={true}
					allowReorder={false}
					{formApi}
					allowCreateNew={true}
					itemClickAction="select"
					allowAddFromOptions={false}
					disableCreateNewButton={!canCreatePortBinding}
					options={[] as PortBinding[]}
					optionDisplayComponent={PortBindingDisplay}
					itemDisplayComponent={PortBindingDisplay}
					items={portBindings}
					getItemContext={() => ({ service, host: host })}
					onCreateNew={handleCreatePortBinding}
					onRemove={handleRemovePortBinding}
					onEdit={handleUpdatePortBinding}
					bind:selectedItems={selectedPortBindings}
				/>
			{/key}
		</div>

		<!-- Interface Bindings -->
		<div class="space-y-4">
			{#key service.id}
				<ListManager
					label="Interface Bindings"
					helpText="Configure which interfaces this service is present on (without listening on ports)."
					placeholder="Select a binding to add"
					createNewLabel="New Binding"
					allowDuplicates={false}
					allowItemEdit={() => true}
					allowItemRemove={() => true}
					{formApi}
					allowReorder={false}
					allowCreateNew={true}
					allowAddFromOptions={false}
					disableCreateNewButton={!canCreateInterfaceBinding}
					options={[] as InterfaceBinding[]}
					optionDisplayComponent={InterfaceBindingDisplay}
					itemDisplayComponent={InterfaceBindingDisplay}
					items={interfaceBindings}
					getItemContext={() => ({ service, host: host })}
					onCreateNew={handleCreateInterfaceBinding}
					onRemove={handleRemoveInterfaceBinding}
					onEdit={handleUpdateInterfaceBinding}
				/>
			{/key}
		</div>

		{#if service.source.type === 'DiscoveryWithMatch' && service.source.details}
			<MatchDetails details={service.source.details} />
		{/if}
	</div>
{/if}
