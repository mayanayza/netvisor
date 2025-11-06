<script lang="ts">
	import { CheckCircle } from 'lucide-svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import type { Host } from '../types/base';
	import { hosts } from '../store';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import EntityDisplay from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';

	export let otherHost: Host | null = null;
	export let isOpen = false;
	export let onConsolidate: (
		otherHostId: string,
		destinationHostId: string
	) => Promise<void> | void;
	export let onClose: () => void;

	let selectedDestinationHostId = '';
	let loading = false;
	let showPreview = false;

	// Get available hosts (excluding the source host)
	$: availableHosts = (otherHost ? $hosts.filter((host) => host.id !== otherHost.id) : $hosts).sort(
		(a, b) => a.name.toLowerCase().localeCompare(b.name.toLowerCase())
	);

	// Get the selected target host
	$: selectedTargetHost = selectedDestinationHostId
		? $hosts.find((host) => host.id === selectedDestinationHostId)
		: null;

	// Reset when modal opens/closes
	$: if (isOpen && otherHost) {
		resetForm();
	}

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
			color={entities.getColorString('Host')}
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
				<div class="card mb-6">
					<h4 class="text-primary mb-3 text-sm font-medium">What will happen:</h4>
					<ul class="text-secondary space-y-2 text-sm">
						{#if otherHost && selectedTargetHost}
							<li class="flex items-start gap-2">
								<CheckCircle class="mt-0.5 h-4 w-4 shrink-0 text-success" />
								<span>Host "{otherHost.name}" will be deleted</span>
							</li>
							{#if otherHost.services?.length > 0}
								<li class="flex items-start gap-2">
									<CheckCircle class="mt-0.5 h-4 w-4 shrink-0 text-success" />
									<span
										>{otherHost.services.length} services from "{otherHost.name}" will be migrated
										to "{selectedTargetHost.name}".</span
									>
								</li>
							{/if}
							{#if otherHost.interfaces?.length > 0}
								<li class="flex items-start gap-2">
									<CheckCircle class="mt-0.5 h-4 w-4 shrink-0 text-success" />
									<span
										>{otherHost.interfaces.length} interfaces from "{otherHost.name}" will be
										migrated to "{selectedTargetHost.name}".</span
									>
								</li>
							{/if}
							{#if otherHost.ports?.length > 0}
								<li class="flex items-start gap-2">
									<CheckCircle class="mt-0.5 h-4 w-4 shrink-0 text-success" />
									<span
										>{otherHost.ports.length} ports from "{otherHost.name}" will be migrated to "{selectedTargetHost.name}".</span
									>
								</li>
							{/if}
						{/if}
					</ul>
				</div>

				<!-- Warning -->
				<div>
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
					<button type="button" disabled={loading} on:click={handleBack} class="btn-secondary">
						Back
					</button>
				{/if}

				<button type="button" disabled={loading} on:click={handleClose} class="btn-secondary">
					Cancel
				</button>

				{#if !showPreview}
					<button
						type="button"
						disabled={!selectedDestinationHostId}
						on:click={handleTargetSelection}
						class="btn-primary"
					>
						Next
					</button>
				{:else}
					<button
						type="button"
						disabled={loading || !selectedDestinationHostId}
						on:click={handleConsolidate}
						class="btn-danger"
					>
						{loading ? 'Consolidating...' : 'Consolidate Hosts'}
					</button>
				{/if}
			</div>
		</div>
	</svelte:fragment>
</GenericModal>
