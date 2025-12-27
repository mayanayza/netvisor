<script lang="ts">
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import type { Host } from '../types/base';
	import { useHostsQuery } from '../queries';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import EntityDisplay from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import EntityList from '$lib/shared/components/data/EntityList.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { useServicesQuery } from '$lib/features/services/queries';
	import { useInterfacesQuery } from '$lib/features/interfaces/queries';
	import { usePortsQuery } from '$lib/features/ports/queries';

	interface Props {
		otherHost?: Host | null;
		isOpen?: boolean;
		onConsolidate: (otherHostId: string, destinationHostId: string) => Promise<void> | void;
		onClose: () => void;
	}

	let { otherHost = null, isOpen = false, onConsolidate, onClose }: Props = $props();

	// TanStack Query hooks
	const hostsQuery = useHostsQuery();
	const servicesQuery = useServicesQuery();
	const interfacesQuery = useInterfacesQuery();
	const portsQuery = usePortsQuery();

	let hostsData = $derived(hostsQuery.data ?? []);
	let servicesData = $derived(servicesQuery.data ?? []);
	let interfacesData = $derived(interfacesQuery.data ?? []);
	let portsData = $derived(portsQuery.data ?? []);

	let selectedDestinationHostId = $state('');
	let loading = $state(false);
	let showPreview = $state(false);

	// Get available hosts (excluding the host being consolidated away)
	let availableHosts = $derived(
		(otherHost
			? hostsData
					.filter((host) => host.id !== otherHost.id)
					.filter((host) => host.network_id == otherHost.network_id)
			: []
		).sort((a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase()))
	);

	// Get the selected target host
	let selectedTargetHost = $derived(
		selectedDestinationHostId
			? hostsData.find((host) => host.id === selectedDestinationHostId)
			: null
	);

	// Build consolidation actions list
	let consolidationActions = $derived(
		(() => {
			if (!otherHost || !selectedTargetHost) return [];

			// Get children counts from query data
			const services = servicesData.filter((s) => s.host_id === otherHost.id);
			const interfaces = interfacesData.filter((i) => i.host_id === otherHost.id);
			const ports = portsData.filter((p) => p.host_id === otherHost.id);

			const actions = [
				{
					id: 'delete',
					name: `Host "${otherHost.name}" will be deleted`
				}
			];

			if (services.length > 0) {
				actions.push({
					id: 'services',
					name: `${services.length} service${services.length !== 1 ? 's' : ''} from "${otherHost.name}" will be migrated to "${selectedTargetHost.name}"`
				});
			}

			if (interfaces.length > 0) {
				actions.push({
					id: 'interfaces',
					name: `${interfaces.length} interface${interfaces.length !== 1 ? 's' : ''} from "${otherHost.name}" will be migrated to "${selectedTargetHost.name}"`
				});
			}

			if (ports.length > 0) {
				actions.push({
					id: 'ports',
					name: `${ports.length} port${ports.length !== 1 ? 's' : ''} from "${otherHost.name}" will be migrated to "${selectedTargetHost.name}"`
				});
			}

			return actions;
		})()
	);

	// Reset when modal opens/closes
	$effect(() => {
		if (isOpen && otherHost) {
			resetForm();
		}
	});

	function resetForm() {
		selectedDestinationHostId = '';
		showPreview = false;
		loading = false;
	}

	function handleTargetSelection() {
		if (selectedDestinationHostId) {
			showPreview = true;
		}
	}

	function handleBack() {
		showPreview = false;
	}

	async function handleConsolidate() {
		if (!otherHost || !selectedDestinationHostId) return;

		loading = true;
		try {
			await onConsolidate(selectedDestinationHostId, otherHost.id);
			onClose();
		} finally {
			loading = false;
		}
	}

	function handleClose() {
		if (!loading) {
			onClose();
		}
	}

	function handleHostSelect(hostId: string) {
		selectedDestinationHostId = hostId;
	}
</script>

<GenericModal
	{isOpen}
	title="Consolidate Hosts"
	size="lg"
	onClose={handleClose}
	preventCloseOnClickOutside={loading}
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon
			Icon={entities.getIconComponent('Host')}
			color={entities.getColorHelper('Host').color}
		/>
	</svelte:fragment>

	<!-- Main content -->
	<div class="p-6">
		{#if !showPreview}
			<!-- Step 1: Target Selection -->
			<div>
				<!-- Source host info -->
				<div class="card mb-6">
					<EntityDisplay context={{}} item={otherHost} displayComponent={HostDisplay} />
				</div>

				<!-- Target selection -->
				<div>
					<RichSelect
						label="Select host which {otherHost?.name} will be consolidated with:"
						placeholder="Choose a host..."
						selectedValue={selectedDestinationHostId}
						options={availableHosts}
						onSelect={handleHostSelect}
						showSearch={true}
						displayComponent={HostDisplay}
					/>
				</div>
			</div>
		{:else}
			<!-- Step 2: Conversion Preview -->
			<div>
				<div class="mb-6 text-center">
					<h3 class="text-primary mb-2 text-lg font-medium">Consolidation Preview</h3>
					<p class="text-secondary text-sm">
						Review the changes before confirming the consolidation.
					</p>
				</div>

				<!-- Details of what will happen -->
				<EntityList title="" items={consolidationActions} />

				<!-- Warning -->
				<div class="mt-4">
					<InlineWarning
						title="This action cannot be undone"
						body="The source host will be permanently deleted and converted to an interface. Make sure this is what you want before proceeding."
					/>
				</div>
			</div>
		{/if}
	</div>

	<!-- Footer -->
	<svelte:fragment slot="footer">
		<div class="flex items-center justify-between">
			<div>
				<!-- Empty space for alignment -->
			</div>

			<div class="flex items-center gap-3">
				{#if showPreview}
					<button type="button" disabled={loading} onclick={handleBack} class="btn-secondary">
						Back
					</button>
				{/if}

				<button type="button" disabled={loading} onclick={handleClose} class="btn-secondary">
					Cancel
				</button>

				{#if !showPreview}
					<button
						type="button"
						disabled={!selectedDestinationHostId}
						onclick={handleTargetSelection}
						class="btn-primary"
					>
						Next
					</button>
				{:else}
					<button
						type="button"
						disabled={loading || !selectedDestinationHostId}
						onclick={handleConsolidate}
						class="btn-danger"
					>
						{loading ? 'Consolidating...' : 'Consolidate Hosts'}
					</button>
				{/if}
			</div>
		</div>
	</svelte:fragment>
</GenericModal>
