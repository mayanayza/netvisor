<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import DiscoveryDetailsForm from './DiscoveryDetailsForm.svelte';
	import DiscoveryTypeForm from './DiscoveryTypeForm.svelte';
	import type { Discovery } from '../../types/base';
	import DiscoveryHistoricalSummary from './DiscoveryHistoricalSummary.svelte';
	import { uuidv4Sentinel } from '$lib/shared/utils/formatting';
	import { createEmptyDiscoveryFormData } from '../../store';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import type { Host } from '$lib/features/hosts/types/base';

	export let discovery: Discovery | null = null;
	export let isOpen = false;
	export let daemons: Daemon[] = [];
	export let hosts: Host[] = [];
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

	$: daemon = daemons.find((d) => d.id === formData.daemon_id) || null;
	$: daemonHostId = (daemon ? hosts.find((h) => h.id === daemon.host_id)?.id : null) || null;

	let formData: Discovery = createEmptyDiscoveryFormData(daemon);

	// Reset form when modal opens
	$: if (isOpen) {
		resetForm();
	}

	// Set default daemon when available
	$: if (formData.daemon_id === uuidv4Sentinel && daemons.length > 0) {
		formData.daemon_id = daemons[0].id;
		formData.network_id = daemons[0].network_id;
	}

	function resetForm() {
		formData = discovery ? { ...discovery } : createEmptyDiscoveryFormData(daemon);
	}

	async function handleSubmit() {
		if (daemon) {
			const discoveryData: Discovery = {
				...formData,
				name: formData.name.trim()
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

	$: saveLabel = isEditing ? 'Update Discovery' : 'Create Discovery';
	$: showSave = !isHistoricalRun;

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
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Discovery')} color={colorHelper.color} />
	</svelte:fragment>

	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<DiscoveryDetailsForm {formApi} {daemons} bind:formData readOnly={isEditing} />

				{#if isHistoricalRun && discovery?.run_type.type === 'Historical'}
					<DiscoveryHistoricalSummary payload={discovery.run_type.results} />
				{:else if daemon}
					<DiscoveryTypeForm {formApi} bind:formData readOnly={isEditing} {daemonHostId} {daemon} />
				{:else}
					<InlineWarning body="No daemon selected; can't set up discovery" />
				{/if}

				{#if isEditing}
					<EntityMetadataSection entities={[discovery]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
