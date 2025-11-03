<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import DiscoveryDetailsForm from './DiscoveryDetailsForm.svelte';
	import DiscoveryTypeForm from './DiscoveryTypeForm.svelte';
	import type { Discovery } from '../../types/base';
	import DiscoveryHistoricalSummary from './DiscoveryHistoricalSummary.svelte';
	import { daemons } from '$lib/features/daemons/store';
	import { hosts } from '$lib/features/hosts/store';
	import { uuidv4Sentinel } from '$lib/shared/utils/formatting';
	import { createEmptyDiscoveryFormData } from '../../store';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { pushError } from '$lib/shared/stores/feedback';

	export let discovery: Discovery | null = null;
	export let isOpen = false;
	export let onCreate: (data: Discovery) => Promise<void> | void;
	export let onUpdate: (id: string, data: Discovery) => Promise<void> | void;
	export let onClose: () => void;
	export let onDelete: ((id: string) => Promise<void> | void) | null = null;

	let loading = false;
	let deleting = false;

	$: isEditing = discovery !== null;
	$: isHistoricalRun = discovery?.run_type.type === 'Historical';

	$: title = isEditing
		? isHistoricalRun
			? `View Discovery Run: ${discovery?.name}`
			: `Edit Discovery: ${discovery?.name}`
		: 'Create Scheduled Discovery';

	let formData: Discovery = createEmptyDiscoveryFormData();

	$: if (formData.daemon_id == uuidv4Sentinel && $daemons.length > 0) {
		formData.daemon_id = $daemons[0].id;
	}

	$: daemon = $daemons.find((d) => d.id == formData.daemon_id) || null;
	$: daemonHostId = (daemon ? $hosts.find((h) => h.id === daemon.host_id)?.id : null) || null;

	// Initialize form data when discovery changes or modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = discovery ? { ...discovery } : createEmptyDiscoveryFormData();
	}

	async function handleSubmit() {
		// Clean up the data before sending
		if (daemon) {
			const discoveryData: Discovery = {
				...formData,
				name: formData.name.trim(),
				network_id: daemon.network_id
			};

			loading = true;
			try {
				if (isEditing && discovery) {
					await onUpdate(discovery.id, discoveryData);
				} else {
					await onCreate(discoveryData);
				}
			} finally {
				loading = false;
			}
		} else {
			pushError('Could not get network ID from selected daemon. Please try a different daemon.');
		}
	}

	async function handleDelete() {
		if (onDelete && discovery) {
			deleting = true;
			try {
				await onDelete(discovery.id);
			} finally {
				deleting = false;
			}
		}
	}

	// Dynamic labels based on mode
	$: saveLabel = isEditing ? 'Update Discovery' : 'Create Discovery';
	$: showSave = !isHistoricalRun; // Don't show save for historical runs

	let colorHelper = entities.getColorHelper('Discovery');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	{showSave}
	cancelLabel={isHistoricalRun ? 'Close' : 'Cancel'}
	onSave={showSave ? handleSubmit : null}
	onCancel={onClose}
	onDelete={isEditing && !isHistoricalRun ? handleDelete : null}
	size="xl"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Discovery')} color={colorHelper.string} />
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<!-- Basic Details Form -->
				<DiscoveryDetailsForm {formApi} bind:formData readOnly={isHistoricalRun} />

				{#if isHistoricalRun && discovery?.run_type.type === 'Historical'}
					<!-- Historical Run Summary -->
					<DiscoveryHistoricalSummary payload={discovery.run_type.results} />
				{:else}
					<!-- Discovery Type Configuration -->
					{#if daemon}
						<DiscoveryTypeForm
							{formApi}
							bind:formData
							readOnly={isEditing}
							{daemonHostId}
							{daemon}
						/>
					{:else}
						<InlineWarning body="No daemon selected; can't set up discovery" />
					{/if}
				{/if}

				{#if isEditing}
					<EntityMetadataSection entities={[discovery]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
