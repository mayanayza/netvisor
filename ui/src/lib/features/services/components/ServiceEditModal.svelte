<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { Service } from '../types/base';
	import ServiceConfigPanel from '$lib/features/hosts/components/HostEditModal/Services/ServiceConfigPanel.svelte';
	import type { Host, HostFormData } from '$lib/features/hosts/types/base';
	import { hydrateHostToFormData } from '$lib/features/hosts/store';

	export let service: Service;
	export let host: Host;
	export let isOpen = false;
	export let onUpdate: (id: string, data: Service) => Promise<void> | void;
	export let onClose: () => void;

	let loading = false;
	let deleting = false;
	let formData = service;

	// Hydrate host to form data for ServiceConfigPanel
	let hostFormData: HostFormData;
	$: hostFormData = hydrateHostToFormData(host);

	$: title = `Edit ${service.name}`;

	// Initialize form data when group changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = { ...service };
	}

	async function handleSubmit() {
		// Clean up the data before sending
		const serviceData: Service = {
			...formData,
			name: formData.name.trim()
		};

		loading = true;
		try {
			await onUpdate(service.id, serviceData);
		} finally {
			loading = false;
		}
	}

	function handleServiceUpdate(updatedService: Service) {
		formData = { ...updatedService };
	}
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	saveLabel="Update Service"
	cancelLabel="Cancel"
	onSave={handleSubmit}
	onCancel={onClose}
	size="xl"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon
			Icon={serviceDefinitions.getIconComponent(service.service_definition)}
			color={serviceDefinitions.getColorHelper(service.service_definition).string}
		/>
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<ServiceConfigPanel
					{formApi}
					host={hostFormData}
					bind:service={formData}
					onChange={handleServiceUpdate}
				/>

				<EntityMetadataSection entities={[service]} />
			</div>
		</div>
	</div>
</EditModal>
