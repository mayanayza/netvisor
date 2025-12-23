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
	import { getServicesForPort } from '$lib/features/services/store';
	import { PortBindingDisplay } from '$lib/shared/components/forms/selection/display/PortBindingDisplay.svelte';
	import { InterfaceBindingDisplay } from '$lib/shared/components/forms/selection/display/InterfaceBindingDisplay.svelte';
	import MatchDetails from './MatchDetails.svelte';
	import type { Host } from '$lib/features/hosts/types/base';
	import { get, readable, type Readable } from 'svelte/store';
	import TagPicker from '$lib/features/tags/components/TagPicker.svelte';

	export let formApi: FormApi;
	export let host: Host;
	export let service: Service;
	export let onChange: (updatedService: Service) => void = () => {};
	export let selectedPortBindings: PortBinding[] = [];
	export let index: number = -1;

	let currentServiceId: string = service.id;
	let currentServiceIndex: number = index;

	const getNameField = () => {
		return field(`service_name_${currentServiceId}_${index}`, service.name, [
			required(),
			maxLength(100)
		]);
	};

	let nameField = getNameField();

	$: serviceMetadata = service ? serviceDefinitions.getItem(service.service_definition) : null;

	$: if (currentServiceIndex !== index) {
		currentServiceIndex = index;
		nameField = getNameField();
	}

	// Port Bindings Logic
	$: portBindings = service.bindings.filter((b) => b.type === 'Port') as PortBinding[];

	// Interface Bindings Logic
	$: interfaceBindings = service.bindings.filter(
		(b) => b.type === 'Interface'
	) as InterfaceBinding[];

	// Get interfaces that this service has Port bindings on
	$: interfacesWithPortBindingsThisService = new Set(
		portBindings.map((b) => b.interface_id).filter((id): id is string => id !== null)
	);

	// Get interfaces that this service has Interface bindings on
	$: interfacesWithInterfaceBindingsThisService = new Set(
		interfaceBindings.map((b) => b.interface_id)
	);

	// Available port+interface combinations for new Port bindings

	// First, get all services for all ports reactively
	$: allPortServicesStores = host.ports.map((port) => ({
		portId: port.id,
		store: getServicesForPort(port.id)
	}));

	// Subscribe to all of them
	$: allPortServices = allPortServicesStores.map(({ portId, store }) => ({
		portId,
		services: store
	}));

	// Available port+interface combinations for new Port bindings
	$: availablePortCombinations = host.interfaces.flatMap((iface) => {
		// Can't add Port binding if THIS service has an Interface binding on this interface
		if (interfacesWithInterfaceBindingsThisService.has(iface.id)) {
			return [];
		}

		return host.ports
			.filter((port) => {
				// Check if this specific port+interface combo is already bound by this service
				const alreadyBoundByThisService = portBindings.some(
					(b) => b.port_id === port.id && b.interface_id === iface.id
				);
				if (alreadyBoundByThisService) return false;

				// Get services for this port from our reactive map
				const servicesForPort =
					allPortServices.find((p) => p.portId === port.id)?.services ||
					(readable([]) as Readable<Service[]>);
				const otherServices = get(servicesForPort).filter((s) => s.id !== service.id);

				const boundByOtherService = otherServices.some((s) =>
					s.bindings.some(
						(b) =>
							b.type === 'Port' &&
							b.port_id === port.id &&
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
	});

	$: canCreatePortBinding = availablePortCombinations.length > 0;

	// Available interfaces for new Interface bindings
	$: availableInterfacesForInterfaceBinding = host.interfaces.filter((iface) => {
		// Can't add Interface binding if this service already has one on this interface
		if (interfaceBindings.some((b) => b.interface_id === iface.id)) {
			return false;
		}

		// Can't add Interface binding if THIS service has Port bindings on this interface
		if (interfacesWithPortBindingsThisService.has(iface.id)) {
			return false;
		}

		return true;
	});

	$: canCreateInterfaceBinding = availableInterfacesForInterfaceBinding.length > 0;

	// Update service when field values change
	$: if ($nameField) {
		const updatedService: Service = {
			...service,
			name: $nameField.value
		};

		if (updatedService.name !== service.name) {
			onChange(updatedService);
		}
	}

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
			port_id: null,
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
			{#if $nameField}
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
