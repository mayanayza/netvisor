<script lang="ts">
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { PortBinding, Service } from '$lib/features/services/types/base';
	import type { Host } from '$lib/features/hosts/types/base';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import { createDefaultService } from '$lib/features/services/store';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { ServiceTypeDisplay } from '$lib/shared/components/forms/selection/display/ServiceTypeDisplay.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import { pushError } from '$lib/shared/stores/feedback';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import ServiceConfigPanel from './ServiceConfigPanel.svelte';
	import EntityConfigEmpty from '$lib/shared/components/forms/EntityConfigEmpty.svelte';
	import ListSelectItem from '$lib/shared/components/forms/selection/ListSelectItem.svelte';
	import { ArrowRightLeft } from 'lucide-svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';

	export let formApi: FormApi;
	export let formData: Host;
	export let currentServices: Service[] = [];
	export let isEditing: boolean;

	let selectedPortBindings: PortBinding[] = [];

	// Available service types for adding
	const availableServiceTypes =
		serviceDefinitions
			.getItems()
			?.filter((service) => service.metadata?.can_be_added !== false)
			.sort((a, b) => a.category.localeCompare(b.category, 'en')) || [];

	function handleItemSelect() {
		selectedPortBindings = [];
	}

	function handleTransferPorts(transferToService: Service, transferFromService: Service) {
		const bindingIdsToTransfer = new Set(selectedPortBindings.map((b) => b.id));

		currentServices = currentServices.map((s) => {
			if (s.id === transferToService.id) {
				return {
					...s,
					bindings: [...s.bindings, ...selectedPortBindings]
				};
			} else if (s.id === transferFromService.id) {
				return {
					...s,
					bindings: s.bindings.filter((b) => !bindingIdsToTransfer.has(b.id))
				};
			}
			return s;
		});

		selectedPortBindings = [];
	}

	// Event handlers
	function handleAddService(serviceTypeId: string) {
		const serviceMetadata = serviceDefinitions.getItems()?.find((s) => s.id === serviceTypeId);
		if (!serviceMetadata) return;

		const newService: Service = createDefaultService(
			serviceTypeId,
			formData.id,
			formData.network_id
		);

		currentServices = [...currentServices, newService];
	}

	function handleRemoveService(index: number) {
		currentServices = currentServices.filter((_, i) => i !== index);
	}

	function handleServiceChange(service: Service, index: number) {
		if (index >= 0 && index < currentServices.length) {
			const updatedServices = [...currentServices];
			updatedServices[index] = service;
			currentServices = updatedServices;
		} else {
			pushError('Invalid service index');
		}
	}

	function handleServiceReorder(fromIndex: number, toIndex: number) {
		if (fromIndex === toIndex) return;

		const updatedServices = [...currentServices];
		const [movedService] = updatedServices.splice(fromIndex, 1);
		updatedServices.splice(toIndex, 0, movedService);

		currentServices = [...updatedServices];
	}
</script>

<div class="space-y-6">
	{#if !isEditing}
		<InlineInfo
			title="Services can be added after the host is created"
			body="Service bindings require the host's interfaces and ports to exist first. Use the buttons below to create the host, then add services."
		/>
	{:else}
		<ListConfigEditor
			bind:items={currentServices}
			onChange={handleServiceChange}
			onReorder={handleServiceReorder}
			onItemSelect={handleItemSelect}
		>
		<svelte:fragment
			slot="list"
			let:items
			let:onEdit
			let:highlightedIndex
			let:highlightedItem
			let:onMoveUp
			let:onMoveDown
			let:onItemSelect
		>
			{@const isTransferringPortBindings = selectedPortBindings.length > 0}
			<ListManager
				label="Services"
				helpText="Services define what this host provides to the network. The icon for the first service in the list will be used as the host's logo in the Host tab."
				placeholder="Select service type to add..."
				emptyMessage="No services configured yet. Add one to get started."
				options={availableServiceTypes}
				itemClickAction="edit"
				showSearch={true}
				{formApi}
				{items}
				allowItemRemove={() => !isTransferringPortBindings}
				allowReorder={!isTransferringPortBindings}
				optionDisplayComponent={ServiceTypeDisplay}
				itemDisplayComponent={ServiceDisplay}
				getItemContext={() => ({})}
				onAdd={handleAddService}
				onRemove={handleRemoveService}
				onClick={onItemSelect}
				{onMoveDown}
				{onMoveUp}
				{onEdit}
				{highlightedIndex}
			>
				{#snippet itemSnippet({ item })}
					<div class="flex min-w-0 flex-1 items-center justify-between gap-2">
						<div class="min-w-0 flex-1 overflow-hidden">
							<ListSelectItem
								{item}
								context={{ interfaceId: null }}
								displayComponent={ServiceDisplay}
							/>
						</div>

						{#if selectedPortBindings.length > 0 && item != highlightedItem && highlightedItem != null && !item.bindings.some((b) => b.type == 'Interface')}
							<button
								type="button"
								onclick={(e) => {
									e.stopPropagation();
									handleTransferPorts(item, highlightedItem);
								}}
								class="btn-secondary flex-shrink-0 text-xs"
								title="Transfer {selectedPortBindings.length} binding(s) here"
							>
								<ArrowRightLeft size={12} />
								<span>Transfer Ports</span>
							</button>
						{/if}
					</div>
				{/snippet}
			</ListManager>
		</svelte:fragment>

		<svelte:fragment slot="config" let:selectedItem let:onChange let:selectedIndex>
			{#if selectedItem}
				<ServiceConfigPanel
					{formApi}
					bind:host={formData}
					index={selectedIndex}
					service={selectedItem}
					onChange={(updatedService) => onChange(updatedService)}
					bind:selectedPortBindings
				/>
			{:else}
				<EntityConfigEmpty
					title="No service selected"
					subtitle="Select a service from the list to configure it"
				/>
			{/if}
		</svelte:fragment>
		</ListConfigEditor>

		<EntityMetadataSection entities={currentServices} showSummary={false} />
	{/if}
</div>
