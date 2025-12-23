<script lang="ts">
	import { type Host } from '$lib/features/hosts/types/base';
	import { ports } from '$lib/shared/stores/metadata';
	import type { Port } from '$lib/features/hosts/types/base';
	import { PortTypeDisplay } from '$lib/shared/components/forms/selection/display/PortTypeDisplay.svelte';
	import { v4 as uuidv4 } from 'uuid';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { PortDisplay } from '$lib/shared/components/forms/selection/display/PortDisplay.svelte';
	import type { Service } from '$lib/features/services/types/base';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import PortConfigPanel from './PortConfigPanel.svelte';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';

	export let formData: Host;
	export let formApi: FormApi;
	export let currentServices: Service[];

	$: selectablePorts = ports
		.getItems()
		.filter(
			(p_type) =>
				p_type.metadata.can_be_added && !formData.ports.some((port) => port.type == p_type.id)
		)
		.sort((a, b) => a.metadata.number - b.metadata.number);

	// Check against currentServices instead of the global store
	function isPortUsed(port: Port): boolean {
		return currentServices.some((service) =>
			service.bindings.some((b) => b.type === 'Port' && b.port_id === port.id)
		);
	}

	function handleCreateNewPort() {
		const newPort: Port = {
			id: uuidv4(),
			host_id: formData.id,
			network_id: formData.network_id,
			protocol: 'Tcp',
			number: Math.floor(Math.random() * 65535) + 1,
			type: 'Custom',
			created_at: new Date().toISOString(),
			updated_at: new Date().toISOString()
		};

		formData.ports = [...formData.ports, newPort];
	}

	function handleAddPort(portId: string) {
		const portType = ports.getItem(portId);

		if (portType) {
			const newPort: Port = {
				id: uuidv4(),
				host_id: formData.id,
				network_id: formData.network_id,
				number: portType.metadata.number as number,
				protocol: portType.metadata.protocol,
				type: portType.id,
				created_at: new Date().toISOString(),
				updated_at: new Date().toISOString()
			};
			formData.ports = [...formData.ports, newPort];
		}
	}

	function handleRemovePort(index: number) {
		formData.ports = formData.ports.filter((_, i) => i != index);
	}
</script>

<ListConfigEditor bind:items={formData.ports}>
	<svelte:fragment slot="list" let:items let:onEdit let:highlightedIndex>
		<ListManager
			label="Ports"
			helpText="Manage ports for this host"
			placeholder="Add well-known or registered port..."
			emptyMessage="No ports on this host. Add one to get started."
			allowReorder={false}
			allowCreateNew={true}
			itemClickAction="edit"
			createNewLabel="Custom Port"
			allowDuplicates={false}
			allowItemRemove={(port: Port) => !isPortUsed(port)}
			{formApi}
			options={selectablePorts}
			{items}
			optionDisplayComponent={PortTypeDisplay}
			itemDisplayComponent={PortDisplay}
			getItemContext={() => ({ currentServices })}
			onCreateNew={handleCreateNewPort}
			onAdd={handleAddPort}
			onRemove={handleRemovePort}
			{onEdit}
			{highlightedIndex}
		/>
	</svelte:fragment>

	<svelte:fragment slot="config" let:selectedItem let:onChange>
		{#if selectedItem && selectedItem.type == 'Custom'}
			<PortConfigPanel
				{formApi}
				port={selectedItem}
				onChange={(updatedPort) => onChange(updatedPort)}
			/>
		{:else if selectedItem && selectedItem.type != 'Custom'}
			<EntityConfigEmpty
				title="Well-known or registered Port"
				subtitle="This is a well-known or registered port, and can't be edited"
			/>
		{:else}
			<EntityConfigEmpty
				title="No port selected"
				subtitle="Select a port from the list to configure it"
			/>
		{/if}
	</svelte:fragment>
</ListConfigEditor>
