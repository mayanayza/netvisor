<script lang="ts">
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import InterfaceConfigPanel from './InterfaceConfigPanel.svelte';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { type HostFormData, type Interface } from '$lib/features/hosts/types/base';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';
	import InternetInterfaceConfigPanel from './InternetInterfaceConfigPanel.svelte';
	import { v4 as uuidv4 } from 'uuid';
	import type { Service } from '$lib/features/services/types/base';
	import ConfirmationDialog from '$lib/shared/components/feedback/ConfirmationDialog.svelte';

	interface Props {
		formApi: FormApi;
		formData: HostFormData;
		currentServices?: Service[];
		onServicesChange?: (services: Service[]) => void;
	}

	let {
		formApi,
		formData = $bindable(),
		currentServices = [],
		onServicesChange = () => {}
	}: Props = $props();

	// TanStack Query for subnets
	const subnetsQuery = useSubnetsQuery();
	let subnetsData = $derived(subnetsQuery.data ?? []);

	// Confirmation dialog state
	let showDeleteConfirmation = $state(false);
	let pendingDeleteIndex: number | null = $state(null);
	let affectedServiceNames: string[] = $state([]);

	// Find services that have bindings to a specific interface
	function getServicesWithBindingsToInterface(interfaceId: string): Service[] {
		return currentServices.filter((service) =>
			service.bindings.some(
				(b) =>
					(b.type === 'Interface' && b.interface_id === interfaceId) ||
					(b.type === 'Port' && b.interface_id === interfaceId)
			)
		);
	}

	// Remove bindings to an interface from all services
	function removeBindingsToInterface(interfaceId: string) {
		const updatedServices = currentServices.map((service) => ({
			...service,
			bindings: service.bindings.filter(
				(b) =>
					!(b.type === 'Interface' && b.interface_id === interfaceId) &&
					!(b.type === 'Port' && b.interface_id === interfaceId)
			)
		}));
		onServicesChange(updatedServices);
	}

	// Computed values
	let interfaces = $derived(formData.interfaces || []);

	let availableSubnets = $derived(subnetsData.filter((s) => s.network_id == formData.network_id));

	// Helper function to find subnet by ID
	function findSubnetById(subnetId: string) {
		return subnetsData.find((s) => s.id === subnetId) || null;
	}

	// Event handlers
	function handleAddInterface(subnetId: string) {
		const subnet = findSubnetById(subnetId);
		if (!subnet) return;

		if (subnet.cidr == '0.0.0.0/0') {
			const newInterface: Interface = {
				id: uuidv4(), // Temp ID for form - store will detect as new since it's not in interfaces store
				host_id: formData.id,
				network_id: formData.network_id,
				name: subnet.name,
				subnet_id: subnetId,
				ip_address: '203.0.113.' + (Math.floor(Math.random() * 255) + 1).toString(),
				mac_address: null,
				created_at: new Date().toISOString(),
				updated_at: new Date().toISOString()
			};

			formData.interfaces = [...interfaces, newInterface];
		} else {
			const newInterface: Interface = {
				id: uuidv4(), // Temp ID for form - store will detect as new since it's not in interfaces store
				host_id: formData.id,
				network_id: formData.network_id,
				name: null,
				subnet_id: subnetId,
				ip_address: '',
				mac_address: null,
				created_at: new Date().toISOString(),
				updated_at: new Date().toISOString()
			};

			formData.interfaces = [...interfaces, newInterface];
		}
	}

	function handleRemoveInterface(index: number) {
		const iface = interfaces[index];
		const affectedServices = getServicesWithBindingsToInterface(iface.id);

		if (affectedServices.length > 0) {
			// Show confirmation dialog
			pendingDeleteIndex = index;
			affectedServiceNames = affectedServices.map((s) => s.name);
			showDeleteConfirmation = true;
		} else {
			// No bindings, delete immediately
			formData.interfaces = interfaces.filter((_, i) => i !== index);
		}
	}

	function confirmDelete() {
		if (pendingDeleteIndex !== null) {
			const iface = interfaces[pendingDeleteIndex];
			// Remove bindings from services first
			removeBindingsToInterface(iface.id);
			// Then remove the interface
			formData.interfaces = interfaces.filter((_, i) => i !== pendingDeleteIndex);
		}
		// Reset dialog state
		showDeleteConfirmation = false;
		pendingDeleteIndex = null;
		affectedServiceNames = [];
	}

	function cancelDelete() {
		showDeleteConfirmation = false;
		pendingDeleteIndex = null;
		affectedServiceNames = [];
	}
</script>

<ListConfigEditor bind:items={formData.interfaces}>
	<svelte:fragment slot="list" let:items let:onEdit let:highlightedIndex>
		<ListManager
			label="Interfaces"
			helpText="Configure network interfaces and addresses"
			placeholder="Select subnet to create interface with..."
			emptyMessage="No interfaces configured. Add one to get started."
			allowReorder={false}
			itemClickAction="edit"
			{formApi}
			options={availableSubnets}
			{items}
			optionDisplayComponent={SubnetDisplay}
			itemDisplayComponent={InterfaceDisplay}
			getItemContext={() => ({ subnets: subnetsData })}
			onAdd={handleAddInterface}
			onRemove={handleRemoveInterface}
			{onEdit}
			{highlightedIndex}
		/>
	</svelte:fragment>

	<svelte:fragment slot="config" let:selectedItem let:onChange>
		{@const subnet = selectedItem ? findSubnetById(selectedItem.subnet_id) : null}
		{#if selectedItem && subnet && subnet.cidr == '0.0.0.0/0'}
			<InternetInterfaceConfigPanel
				{formApi}
				iface={selectedItem}
				{subnet}
				onChange={(updatedInterface) => onChange(updatedInterface)}
			/>
		{:else if selectedItem && subnet && subnet.cidr != '0.0.0.0/0'}
			<InterfaceConfigPanel
				{formApi}
				iface={selectedItem}
				{subnet}
				onChange={(updatedInterface) => onChange(updatedInterface)}
			/>
		{:else}
			<EntityConfigEmpty
				title="No interface selected"
				subtitle="Select an interface from the list to configure it"
			/>
		{/if}
	</svelte:fragment>
</ListConfigEditor>

<ConfirmationDialog
	isOpen={showDeleteConfirmation}
	title="Delete Interface"
	message="This interface has bindings from the following services. Deleting it will remove those bindings."
	details={affectedServiceNames}
	confirmLabel="Delete Interface"
	cancelLabel="Cancel"
	variant="warning"
	onConfirm={confirmDelete}
	onCancel={cancelDelete}
/>
