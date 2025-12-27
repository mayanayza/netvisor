<script lang="ts">
	import type { Service } from '$lib/features/services/types/base';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Host } from '$lib/features/hosts/types/base';
	import type { FormApi } from '$lib/shared/components/forms/types';

	interface Props {
		service: Service;
		onChange: (updatedHost: Host) => void;
		formApi: FormApi;
	}

	let { service, onChange, formApi }: Props = $props();

	// TanStack Query hook
	const hostsQuery = useHostsQuery();
	let hostsData = $derived(hostsQuery.data ?? []);

	let serviceMetadata = $derived(serviceDefinitions.getItem(service.service_definition));

	// Initialize managedVms from current hosts data
	let managedVms = $state<Host[]>([]);

	// Initialize managedVms when hostsData is available (only once at mount)
	$effect(() => {
		if (hostsData.length > 0 && managedVms.length === 0) {
			managedVms = hostsData.filter(
				(h) =>
					h.virtualization &&
					h.virtualization?.type == 'Proxmox' &&
					h.virtualization.details.service_id == service.id
			);
		}
	});

	let vmIds = $derived(managedVms.map((h) => h.id));
	// Filter out the parent host and already managed VMs
	let selectableVms = $derived(
		hostsData
			.filter((host) => service.host_id !== host.id && !vmIds.includes(host.id))
			.filter((h) => h.network_id == service.network_id)
	);

	function handleAddVm(vmId: string) {
		const host = hostsData.find((h) => h.id === vmId);
		if (host) {
			const updatedHost = {
				...host,
				virtualization: {
					type: 'Proxmox' as const,
					details: {
						vm_id: null,
						vm_name: null,
						service_id: service.id
					}
				}
			};

			managedVms = [...managedVms, updatedHost];
			onChange(updatedHost);
		}
	}

	function handleRemoveVm(index: number) {
		let removedVm = managedVms.at(index);

		if (removedVm) {
			const updatedHost = {
				...removedVm,
				virtualization: null
			};

			managedVms = managedVms.filter((h) => h.id !== removedVm.id);
			onChange(updatedHost);
		}
	}
</script>

<div class="space-y-6">
	<ListManager
		label="Virtual Machines"
		helpText="Manage VMs controlled by this {serviceMetadata?.name
			? serviceMetadata.name
			: ''} instance"
		placeholder="Add VM host..."
		emptyMessage="No VMs managed by this service yet. Add hosts that are VMs running on this hypervisor."
		allowReorder={false}
		allowDuplicates={false}
		{formApi}
		showSearch={true}
		allowItemEdit={() => false}
		options={selectableVms}
		items={managedVms}
		optionDisplayComponent={HostDisplay}
		itemDisplayComponent={HostDisplay}
		onAdd={handleAddVm}
		onRemove={handleRemoveVm}
	/>
</div>
