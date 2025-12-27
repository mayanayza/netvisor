<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { Service } from '../types/base';
	import ServiceConfigPanel from '$lib/features/hosts/components/HostEditModal/Services/ServiceConfigPanel.svelte';
	import type { Host, HostFormData } from '$lib/features/hosts/types/base';
	import { useInterfacesQuery } from '$lib/features/interfaces/queries';
	import { usePortsQuery } from '$lib/features/ports/queries';
	import { useServicesQuery } from '$lib/features/services/queries';

	// TanStack Query hooks to get child entities for hydrating host form data
	const interfacesQuery = useInterfacesQuery();
	const portsQuery = usePortsQuery();
	const servicesQuery = useServicesQuery();
	let interfacesData = $derived(interfacesQuery.data ?? []);
	let portsData = $derived(portsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);

	// Hydrate host to form data for ServiceConfigPanel
	function hydrateHostToFormData(host: Host): HostFormData {
		const hostInterfaces = interfacesData.filter((i) => i.host_id === host.id);
		const hostPorts = portsData.filter((p) => p.host_id === host.id);
		const hostServices = servicesData.filter((s) => s.host_id === host.id);

		return {
			...host,
			interfaces: hostInterfaces,
			ports: hostPorts,
			services: hostServices
		};
	}

	interface Props {
		service: Service;
		host: Host;
		isOpen?: boolean;
		onUpdate: (id: string, data: Service) => Promise<void> | void;
		onClose: () => void;
	}

	let { service, host, isOpen = false, onUpdate, onClose }: Props = $props();

	let loading = $state(false);
	let deleting = $state(false);
	let formData = $state(service);

	// Hydrate host to form data for ServiceConfigPanel
	let hostFormData = $derived(hydrateHostToFormData(host));

	let title = $derived(`Edit ${service.name}`);

	// Initialize form data when group changes or modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

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
			color={serviceDefinitions.getColorHelper(service.service_definition).color}
		/>
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<ServiceConfigPanel
					{formApi}
					host={hostFormData}
					service={formData}
					onChange={handleServiceUpdate}
				/>

				<EntityMetadataSection entities={[service]} />
			</div>
		</div>
	</div>
</EditModal>
