<script lang="ts">
	import type { Service } from '$lib/features/services/types/base';
	import { getHostFromId, hosts } from '$lib/features/hosts/store';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Host } from '$lib/features/hosts/types/base';
	import { get } from 'svelte/store';
	import type { FormApi } from '$lib/shared/components/forms/types';

	export let service: Service;
	export let onChange: (updatedHost: Host) => void;
	export let formApi: FormApi;

	$: serviceMetadata = serviceDefinitions.getItem(service.service_definition);

	let managedVms = get(hosts).filter(
		(h) =>
			h.virtualization &&
			h.virtualization?.type == 'Proxmox' &&
			h.virtualization.details.service_id == service.id
	);
	$: vmIds = managedVms.map((h) => h.id);
	// Filter out the parent host and already managed VMs
	$: selectableVms = $hosts.filter(
		(host) => service.host_id !== host.id && !vmIds.includes(host.id)
	);

	function handleAddVm(vmId: string) {
		const hostStore = getHostFromId(vmId);
		let host = get(hostStore);
		if (host) {
			host.virtualization = {
				type: 'Proxmox',
				details: {
					vm_id: null,
					vm_name: null,
					service_id: service.id
				}
			};

			const updatedVms = managedVms;
			updatedVms.push(host);
			managedVms = [...updatedVms];

			onChange(host);
		}
	}

	function handleRemoveVm(index: number) {
		let removedVm = managedVms.at(index);

		if (removedVm) {
			removedVm.virtualization = null;

			managedVms = [...managedVms.filter((h) => h.id !== removedVm.id)];

			onChange(removedVm);
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
