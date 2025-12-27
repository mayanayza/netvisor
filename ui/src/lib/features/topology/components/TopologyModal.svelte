<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import type { Topology } from '../types/base';
	import {
		createEmptyTopologyFormData,
		createTopology,
		topologies,
		topology,
		topologyOptions,
		updateTopology
	} from '../store';
	import { entities } from '$lib/shared/stores/metadata';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TopologyDetailsForm from './TopologyDetailsForm.svelte';

	let {
		isOpen = $bindable(false),
		onSubmit,
		onClose,
		topo = null
	}: {
		isOpen: boolean;
		onSubmit: () => Promise<void> | void;
		onClose: () => void;
		topo: Topology | null;
	} = $props();

	let isEditing = $derived(topo != null);
	let title = $derived(isEditing ? `Edit ${topo?.name}` : 'Create Topology');

	let loading = $state(false);
	let formData: Topology = $derived(topo ? { ...topo } : createEmptyTopologyFormData());

	$effect(() => {
		void $topology;
		void $topologies;
	});

	// Reset form when modal opens
	$effect(() => {
		if (isOpen) resetForm();
	});

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

	let colorHelper = $state(entities.getColorHelper('Topology'));
	let Icon = $state(entities.getIconComponent('Topology'));
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
		<ModalHeaderIcon {Icon} color={colorHelper.color} />
	</svelte:fragment>

	<div class="space-y-6">
		<TopologyDetailsForm {formApi} bind:formData {isEditing} />
	</div>
</EditModal>
