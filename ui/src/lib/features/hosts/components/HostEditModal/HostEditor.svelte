<script lang="ts">
	import { Info } from 'lucide-svelte';
	import type {
		Host,
		HostFormData,
		CreateHostWithServicesRequest,
		UpdateHostWithServicesRequest
	} from '$lib/features/hosts/types/base';
	import { formDataToHostPrimitive } from '$lib/features/hosts/queries';
	import { createEmptyHostFormData, hydrateHostToFormData } from '$lib/features/hosts/store';
	import DetailsForm from './Details/HostDetailsForm.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import InterfacesForm from './Interfaces/InterfacesForm.svelte';
	import ServicesForm from './Services/ServicesForm.svelte';
	import { concepts, entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Service } from '$lib/features/services/types/base';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { useServicesQuery } from '$lib/features/services/queries';
	import PortsForm from './Ports/PortsForm.svelte';
	import VirtualizationForm from './Virtualization/VirtualizationForm.svelte';
	import { SvelteMap } from 'svelte/reactivity';

	interface Props {
		host?: Host | null;
		isOpen?: boolean;
		onCreate: (data: CreateHostWithServicesRequest) => Promise<void> | void;
		onCreateAndContinue: (data: CreateHostWithServicesRequest) => Promise<void> | void;
		onUpdate: (data: UpdateHostWithServicesRequest) => Promise<void> | void;
		onClose: () => void;
		onDelete?: ((id: string) => Promise<void> | void) | null;
	}

	let {
		host = null,
		isOpen = false,
		onCreate,
		onCreateAndContinue,
		onUpdate,
		onClose,
		onDelete = null
	}: Props = $props();

	// TanStack Query hook for services
	const servicesQuery = useServicesQuery();
	let servicesData = $derived(servicesQuery.data ?? []);

	let loading = $state(false);
	let deleting = $state(false);

	let currentHostServices = $state<Service[]>([]);

	let isEditing = $derived(host !== null);
	let title = $derived(isEditing ? `Edit ${host?.name}` : 'Create Host');

	let formData = $state<HostFormData>(createEmptyHostFormData());

	// Initialize form data when host changes or modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	let vmManagerServices = $derived(
		currentHostServices.filter(
			(s) => serviceDefinitions.getMetadata(s.service_definition).manages_virtualization != null
		)
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
	let activeTab = $state('details');
	let tabs = $derived([
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
	]);

	let currentTabIndex = $derived(tabs.findIndex((t) => t.id === activeTab) || 0);

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
		// Hydrate host to HostFormData for form editing (includes interfaces, ports, services)
		formData = host ? hydrateHostToFormData(host) : createEmptyHostFormData();

		if (host && host.id) {
			// Get services for this host from query data
			currentHostServices = servicesData.filter((s) => s.host_id === host.id);
		} else {
			currentHostServices = [];
		}
		activeTab = 'details'; // Reset to first tab
	}

	async function handleSubmit() {
		loading = true;
		let promises = [];
		if (isEditing && host) {
			// Extract Host primitive from form data for update
			const hostPrimitive = formDataToHostPrimitive(formData);
			promises.push(
				onUpdate({
					host: hostPrimitive,
					interfaces: formData.interfaces,
					ports: formData.ports,
					services: currentHostServices
				})
			);
		} else {
			// Create needs full form data (includes interfaces/ports)
			promises.push(onCreate({ host: formData, services: currentHostServices }));
		}

		// VM managed hosts are already Host primitives - only update host fields, not children
		for (const updatedHost of vmManagedHostUpdates.values()) {
			promises.push(
				onUpdate({
					host: updatedHost,
					interfaces: null, // Don't modify
					ports: null, // Don't modify
					services: null // Don't modify
				})
			);
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
	let isServicesTabDuringCreate = $derived(!isEditing && activeTab === 'services');

	// Dynamic labels based on create/edit mode and tab position
	let saveLabel = $derived(
		isEditing ? 'Update Host' : currentTabIndex === tabs.length - 1 ? 'Create Host' : 'Next'
	);
	let cancelLabel = $derived(isEditing ? 'Cancel' : 'Previous');
	let showCancel = $derived(isEditing ? true : currentTabIndex !== 0);

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
							onclick={() => {
								activeTab = tab.id;
							}}
							class="border-b-2 px-1 py-4 text-sm font-medium transition-colors
                     {activeTab === tab.id
								? 'text-primary'
								: 'text-muted hover:text-secondary border-transparent'}"
							aria-current={activeTab === tab.id ? 'page' : undefined}
						>
							<div class="flex items-center gap-2">
								<tab.icon class="h-4 w-4" />
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
						<InterfacesForm
							{formApi}
							bind:formData
							currentServices={currentHostServices}
							onServicesChange={(services) => (currentHostServices = services)}
						/>
					</div>
				</div>
			{/if}

			<!-- Ports Tab -->
			{#if activeTab === 'ports'}
				<div class="h-full">
					<div class="relative flex-1">
						<PortsForm
							{formApi}
							bind:formData
							currentServices={currentHostServices}
							onServicesChange={(services) => (currentHostServices = services)}
						/>
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
	<svelte:fragment
		slot="footer"
		let:handleCancel
		let:handleDelete
		let:loading
		let:deleting
		let:actualDisableSave
	>
		{#if isServicesTabDuringCreate}
			<!-- Special footer for services tab during create mode -->
			<div class="flex items-center justify-between">
				<div></div>
				<div class="flex items-center gap-3">
					<button type="button" disabled={loading} onclick={handleCancel} class="btn-secondary">
						Previous
					</button>
					<button
						type="button"
						disabled={actualDisableSave}
						onclick={handleCreateAndClose}
						class="btn-secondary"
					>
						{loading ? 'Creating...' : 'Create Host'}
					</button>
					<button
						type="button"
						disabled={actualDisableSave}
						onclick={handleCreateAndContinue}
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
							onclick={handleDelete}
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
							onclick={handleCancel}
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
