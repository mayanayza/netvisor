<script lang="ts">
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { Service } from '$lib/features/services/types/base';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import VmManagerConfigPanel from './VmManagerConfigPanel.svelte';
	import ContainerManagerConfigPanel from './ContainerManagerConfigPanel.svelte';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';
	import {
		VirtualizationManagerServiceDisplay,
		type VirtualizationManagerContext
	} from '$lib/shared/components/forms/selection/display/VirtualizationManagerServiceDisplay.svelte';
	import type { Host } from '$lib/features/hosts/types/base';
	import { uuidv4Sentinel } from '$lib/shared/utils/formatting';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useServicesQuery } from '$lib/features/services/queries';

	interface Props {
		virtualizationManagerServices: Service[];
		onServiceChange: (service: Service) => void;
		onVirtualizedHostChange: (host: Host) => void;
		formApi: FormApi;
	}

	let { virtualizationManagerServices, onServiceChange, onVirtualizedHostChange, formApi }: Props =
		$props();

	// TanStack Query hooks for context data
	const hostsQuery = useHostsQuery();
	const servicesQuery = useServicesQuery();
	let hostsData = $derived(hostsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);

	// Context for VirtualizationManagerServiceDisplay
	let displayContext: VirtualizationManagerContext = $derived({
		hosts: hostsData,
		services: servicesData
	});
</script>

<div class="space-y-6">
	<ListConfigEditor bind:items={virtualizationManagerServices} onChange={onServiceChange}>
		<svelte:fragment slot="list" let:items let:onEdit let:highlightedIndex>
			<ListManager
				label="Virtualization Services"
				helpText="Services that manage virtual machines or containers on this host"
				emptyMessage="No virtualization services on this host."
				{items}
				{formApi}
				itemClickAction="edit"
				allowItemRemove={() => false}
				allowReorder={false}
				allowAddFromOptions={false}
				options={[] as Service[]}
				itemDisplayComponent={VirtualizationManagerServiceDisplay}
				optionDisplayComponent={VirtualizationManagerServiceDisplay}
				getItemContext={() => displayContext}
				{onEdit}
				{highlightedIndex}
			/>
		</svelte:fragment>

		<svelte:fragment slot="config" let:selectedItem>
			{#if selectedItem}
				{#if selectedItem.id == uuidv4Sentinel}
					<InlineWarning
						title="Please Save {selectedItem.name}"
						body="You need to save {selectedItem.name} before managing virtualization"
					/>
				{:else}
					{@const virtualizationType = serviceDefinitions.getMetadata(
						selectedItem.service_definition
					).manages_virtualization}
					{#if virtualizationType === 'vms'}
						<VmManagerConfigPanel
							service={selectedItem}
							{formApi}
							onChange={(updatedHost) => onVirtualizedHostChange(updatedHost)}
						/>
					{:else if virtualizationType === 'containers'}
						<ContainerManagerConfigPanel
							service={selectedItem}
							{formApi}
							onChange={(updatedService) => onServiceChange(updatedService)}
						/>
					{:else}
						<EntityConfigEmpty
							title="Unknown virtualization type"
							subtitle="This service has an unrecognized virtualization management type"
						/>
					{/if}
				{/if}
			{:else}
				<EntityConfigEmpty
					title="No service selected"
					subtitle="Select a virtualization service from the list to manage its VMs or containers"
				/>
			{/if}
		</svelte:fragment>
	</ListConfigEditor>
</div>
