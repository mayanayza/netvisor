<script lang="ts">
	import ListConfigEditor from '$lib/shared/components/forms/selection/ListConfigEditor.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { Service } from '$lib/features/services/types/base';
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

	export let formApi: FormApi;
	export let formData: Host;
	export let currentServices: Service[] = [];
	export let isEditing: boolean;

	// Available service types for adding
	const availableServiceTypes =
		serviceDefinitions
			.getItems()
			?.filter((service) => service.metadata?.can_be_added !== false)
			.sort((a, b) => a.category.localeCompare(b.category, 'en')) || [];

	// Event handlers
	function handleAddService(serviceTypeId: string) {
		const serviceMetadata = serviceDefinitions.getItems()?.find((s) => s.id === serviceTypeId);
		if (!serviceMetadata) return;

		const newService: Service = createDefaultService(
			serviceTypeId,
			formData.id,
			serviceDefinitions.getName(serviceTypeId)
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

		currentServices = updatedServices;
	}
</script>

<div class="space-y-6">
	<ListConfigEditor
		bind:items={currentServices}
		onChange={handleServiceChange}
		onReorder={handleServiceReorder}
	>
		<svelte:fragment
			slot="list"
			let:items
			let:onEdit
			let:highlightedIndex
			let:onMoveUp
			let:onMoveDown
		>
			<ListManager
				label="Services"
				helpText="Services define what this host provides to the network."
				placeholder="Select service type to add..."
				emptyMessage="No services configured yet. Add one to get started."
				allowReorder={true}
				options={availableServiceTypes}
				showSearch={true}
				{formApi}
				{items}
				allowItemRemove={() => true}
				optionDisplayComponent={ServiceTypeDisplay}
				itemDisplayComponent={ServiceDisplay}
				getItemContext={() => ({})}
				onAdd={handleAddService}
				onRemove={handleRemoveService}
				{onMoveDown}
				{onMoveUp}
				{onEdit}
				{highlightedIndex}
			/>
		</svelte:fragment>

		<svelte:fragment slot="config" let:selectedItem let:onChange>
			{#if selectedItem}
				<ServiceConfigPanel
					{formApi}
					bind:host={formData}
					service={selectedItem}
					onChange={(updatedService) => onChange(updatedService)}
				/>
			{:else}
				<EntityConfigEmpty
					title="No service selected"
					subtitle="Select a service from the list to configure it"
				/>
			{/if}
		</svelte:fragment>
	</ListConfigEditor>

	{#if isEditing}
		<EntityMetadataSection entities={currentServices} showSummary={false} />
	{/if}
</div>
