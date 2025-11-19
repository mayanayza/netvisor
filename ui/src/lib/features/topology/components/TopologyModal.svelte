<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { Topology } from '../types/base';
	import {
		createEmptyTopologyFormData,
		createTopology,
		topologyOptions,
		updateTopology
	} from '../store';
	import { entities } from '$lib/shared/stores/metadata';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TopologyDetailsForm from './TopologyDetailsForm.svelte';

	export let isOpen = false;
	export let onSubmit: () => Promise<void> | void;
	export let onClose: () => void;
	export let topo: Topology | null = null;

	$: isEditing = topo != null;
	$: title = isEditing ? `Edit ${topo?.name}` : 'Create Topology';

	let loading = false;
	let formData: Topology = createEmptyTopologyFormData();

	// Reset form when modal opens
	$: if (isOpen) {
		resetForm();
	}

	function resetForm() {
		formData = topo ? { ...topo } : createEmptyTopologyFormData();
	}

	async function handleSubmit() {
		const topologyData: Topology = {
			...formData,
			name: formData.name.trim(),
			options: $topologyOptions,
			network_id: formData.network_id
		};

		loading = true;
		try {
			if (isEditing) {
				await updateTopology(topologyData);
			} else {
				await createTopology(topologyData);
			}
			await onSubmit();
		} finally {
			loading = false;
		}
	}

	let colorHelper = entities.getColorHelper('Subnet');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	saveLabel="Save"
	cancelLabel="Cancel"
	onSave={handleSubmit}
	onCancel={onClose}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Topology')} color={colorHelper.string} />
	</svelte:fragment>

	<div class="space-y-6">
		<TopologyDetailsForm {formApi} bind:formData {isEditing} />
	</div>
</EditModal>
