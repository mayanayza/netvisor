<script lang="ts">
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import InterfaceConfigPanel from './InterfaceConfigPanel.svelte';
	import { subnets } from '$lib/features/subnets/store';
	import { type Host, type Interface } from '$lib/features/hosts/types/base';
	import { v4 as uuidv4 } from 'uuid';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';
	import InternetInterfaceConfigPanel from './InternetInterfaceConfigPanel.svelte';

	export let formApi: FormApi;
	export let formData: Host;

	// Computed values
	$: interfaces = formData.interfaces || [];

	$: availableSubnets = $subnets.filter((s) => s.network_id == formData.network_id);

	// Helper function to find subnet by ID
	function findSubnetById(subnetId: string) {
		return $subnets.find((s) => s.id === subnetId) || null;
	}

	// Event handlers
	function handleAddInterface(subnetId: string) {
		const subnet = findSubnetById(subnetId);
		if (!subnet) return;

		if (subnet.cidr == '0.0.0.0/0') {
			const newInterface: Interface = {
				id: uuidv4(),
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
				id: uuidv4(),
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
		formData.interfaces = interfaces.filter((_, i) => i !== index);
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
