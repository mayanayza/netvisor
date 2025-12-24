<script lang="ts">
	import { Info } from 'lucide-svelte';
	import type { Host, HostWithServicesRequest } from '$lib/features/hosts/types/base';
	import { createEmptyHostFormData } from '$lib/features/hosts/store';
	import DetailsForm from './Details/HostDetailsForm.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import InterfacesForm from './Interfaces/InterfacesForm.svelte';
	import ServicesForm from './Services/ServicesForm.svelte';
	import { concepts, entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Service } from '$lib/features/services/types/base';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { getServicesForHost } from '$lib/features/services/store';
	import PortsForm from './Ports/PortsForm.svelte';
	import VirtualizationForm from './Virtualization/VirtualizationForm.svelte';
	import { SvelteMap } from 'svelte/reactivity';
	import { get } from 'svelte/store';

	export let host: Host | null = null;
	export let isOpen = false;
	export let onCreate: (data: HostWithServicesRequest) => Promise<void> | void;
	export let onCreateAndContinue: (data: HostWithServicesRequest) => Promise<void> | void;
	export let onUpdate: (data: HostWithServicesRequest) => Promise<void> | void;
	export let onClose: () => void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;

	let loading = false;
	let deleting = false;

	let currentHostServices: Service[] = [];

	$: isEditing = host !== null;
	$: title = isEditing ? `Edit ${host?.name}` : 'Create Host';

	let formData: Host = createEmptyHostFormData();

	// Initialize form data when host changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	$: vmManagerServices = currentHostServices.filter(
		(s) => serviceDefinitions.getMetadata(s.service_definition).manages_virtualization != null
	);

	function handleVirtualizationServiceChange(updatedService: Service) {
		// Find the actual index in currentHostServices
		const actualIndex = currentHostServices.findIndex((s) => s.id === updatedService.id);
		if (actualIndex >= 0) {
			currentHostServices[actualIndex] = updatedService;
			currentHostServices = [...currentHostServices]; // Trigger reactivity
		}
	}

	let vmManagedHostUpdates: SvelteMap<string, Host> = new SvelteMap();

	function handleVirtualizationHostChange(updatedHost: Host) {
		// This is another host; ie not the current
		// Hold on to updates and only make them on submit
		vmManagedHostUpdates.set(updatedHost.id, updatedHost);
	}

	// Tab management
	let activeTab = 'details';
	$: tabs = [
		{
			id: 'details',
			label: 'Details',
			icon: Info,
			description: 'Basic host information and connection details'
		},
		{
			id: 'interfaces',
			label: 'Interfaces',
			icon: entities.getIconComponent('Interface'),
			description: 'Network interfaces and subnet membership'
		},
		{
			id: 'ports',
			label: 'Ports',
			icon: entities.getIconComponent('Port'),
			description: 'Service configuration'
		},
		{
			id: 'services',
			label: 'Services',
			icon: entities.getIconComponent('Service'),
			description: 'Service configuration'
		},
		...(vmManagerServices && vmManagerServices.length > 0
			? [
					{
						id: 'virtualization',
						label: 'Virtualization',
						icon: concepts.getIconComponent('Virtualization'),
						description: 'VMs and containers managed by services on this host'
					}
				]
			: [])
	];

	$: currentTabIndex = tabs.findIndex((t) => t.id === activeTab) || 0;

	function nextTab() {
		if (currentTabIndex < tabs.length - 1) {
			activeTab = tabs[currentTabIndex + 1].id;
		}
	}

	function previousTab() {
		if (currentTabIndex > 0) {
			activeTab = tabs[currentTabIndex - 1].id;
		}
	}

	function resetForm() {
		formData = host ? { ...host } : createEmptyHostFormData();

		if (host && host.id) {
			// Sort as ordered for host to get high confidence services with logo first
			currentHostServices = get(getServicesForHost(host.id));
		} else {
			currentHostServices = [];
		}
		activeTab = 'details'; // Reset to first tab
	}

	async function handleSubmit() {
		loading = true;
		let promises = [];
		if (isEditing && host) {
			promises.push(onUpdate({ host: formData, services: currentHostServices }));
		} else {
			promises.push(onCreate({ host: formData, services: currentHostServices }));
		}

		for (const updatedHost of vmManagedHostUpdates.values()) {
			const hostServicesStore = getServicesForHost(updatedHost.id);
			const hostServices = get(hostServicesStore);
			promises.push(onUpdate({ host: updatedHost, services: hostServices }));
		}

		await Promise.all(promises);

		loading = false;
	}

	async function handleDelete() {
		if (onDelete && host) {
			deleting = true;
			await onDelete(host.id);
			deleting = false;
		}
	}

	// Handle form-based submission for create flow with steps
	function handleFormSubmit() {
		if (isEditing || currentTabIndex === tabs.length - 1) {
			handleSubmit();
		} else {
			nextTab();
		}
	}

	function handleFormCancel() {
		if (isEditing || currentTabIndex == 0) {
			onClose();
		} else {
			previousTab();
		}
	}

	// Check if we're on the services tab during create mode
	$: isServicesTabDuringCreate = !isEditing && activeTab === 'services';

	// Dynamic labels based on create/edit mode and tab position
	$: saveLabel = isEditing
		? 'Update Host'
		: currentTabIndex === tabs.length - 1
			? 'Create Host'
			: 'Next';
	$: cancelLabel = isEditing ? 'Cancel' : 'Previous';
	$: showCancel = isEditing ? true : currentTabIndex !== 0;

	// Handler for "Create Host & Add Services" - creates host and keeps modal open
	async function handleCreateAndContinue() {
		loading = true;
		await onCreateAndContinue({ host: formData, services: [] });
		loading = false;
	}

	// Handler for "Create Host" when on services tab - creates host and closes
	async function handleCreateAndClose() {
		loading = true;
		await onCreate({ host: formData, services: [] });
		loading = false;
	}
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	{cancelLabel}
	{showCancel}
	onSave={handleFormSubmit}
	onCancel={handleFormCancel}
	onDelete={isEditing ? handleDelete : null}
	size="full"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon
			Icon={entities.getIconComponent('Host')}
			color={entities.getColorString('Host')}
		/>
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full min-h-0 flex-col">
		<!-- Tab Navigation (only show for editing) -->
		{#if isEditing}
			<div class="border-b border-gray-700 px-6">
				<nav class="flex space-x-8" aria-label="Host editor tabs">
					{#each tabs as tab (tab.id)}
						<button
							type="button"
							on:click={() => {
								activeTab = tab.id;
							}}
							class="border-b-2 px-1 py-4 text-sm font-medium transition-colors
                     {activeTab === tab.id
								? 'text-primary'
								: 'text-muted hover:text-secondary border-transparent'}"
							aria-current={activeTab === tab.id ? 'page' : undefined}
						>
							<div class="flex items-center gap-2">
								<svelte:component this={tab.icon} class="h-4 w-4" />
								{tab.label}
							</div>
						</button>
					{/each}
				</nav>
			</div>
		{/if}

		<!-- Tab Content -->
		<div class="flex-1 overflow-auto">
			<!-- Details Tab -->
			{#if activeTab === 'details'}
				<div class="h-full">
					<div class="relative flex-1">
						<DetailsForm {formApi} {isEditing} {host} bind:formData />
					</div>
				</div>
			{/if}

			<!-- Interfaces Tab -->
			{#if activeTab === 'interfaces'}
				<div class="h-full">
					<div class="relative flex-1">
						<InterfacesForm {formApi} bind:formData />
					</div>
				</div>
			{/if}

			<!-- Ports Tab -->
			{#if activeTab === 'ports'}
				<div class="h-full">
					<div class="relative flex-1">
						<PortsForm {formApi} bind:formData currentServices={currentHostServices} />
					</div>
				</div>
			{/if}

			<!-- Services Tab -->
			{#if activeTab === 'services'}
				<div class="h-full">
					<div class="relative flex-1">
						<ServicesForm
							{formApi}
							bind:formData
							bind:currentServices={currentHostServices}
							{isEditing}
						/>
					</div>
				</div>
			{/if}

			<!-- Services Tab -->
			{#if activeTab === 'virtualization'}
				<div class="h-full">
					<div class="relative flex-1">
						<VirtualizationForm
							{formApi}
							virtualizationManagerServices={vmManagerServices}
							onServiceChange={handleVirtualizationServiceChange}
							onVirtualizedHostChange={handleVirtualizationHostChange}
						/>
					</div>
				</div>
			{/if}
		</div>
	</div>

	<!-- Custom footer: handles both normal mode and services-tab-during-create mode -->
	<svelte:fragment slot="footer" let:handleCancel let:handleDelete let:loading let:deleting let:actualDisableSave>
		{#if isServicesTabDuringCreate}
			<!-- Special footer for services tab during create mode -->
			<div class="flex items-center justify-between">
				<div></div>
				<div class="flex items-center gap-3">
					<button
						type="button"
						disabled={loading}
						on:click={handleCancel}
						class="btn-secondary"
					>
						Previous
					</button>
					<button
						type="button"
						disabled={actualDisableSave}
						on:click={handleCreateAndClose}
						class="btn-secondary"
					>
						{loading ? 'Creating...' : 'Create Host'}
					</button>
					<button
						type="button"
						disabled={actualDisableSave}
						on:click={handleCreateAndContinue}
						class="btn-primary"
					>
						{loading ? 'Creating...' : 'Create Host & Add Services'}
					</button>
				</div>
			</div>
		{:else}
			<!-- Default footer behavior -->
			<div class="flex items-center justify-between">
				<div>
					{#if isEditing && onDelete}
						<button
							type="button"
							disabled={deleting || loading}
							on:click={handleDelete}
							class="btn-danger"
						>
							{deleting ? 'Deleting...' : 'Delete'}
						</button>
					{/if}
				</div>
				<div class="flex items-center gap-3">
					{#if showCancel}
						<button
							type="button"
							disabled={loading || deleting}
							on:click={handleCancel}
							class="btn-secondary"
						>
							{cancelLabel}
						</button>
					{/if}
					<button type="submit" disabled={actualDisableSave} class="btn-primary">
						{loading ? 'Saving...' : saveLabel}
					</button>
				</div>
			</div>
		{/if}
	</svelte:fragment>
</EditModal>
