<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import EntityMetadataSection from '$lib/shared/components/forms/EntityMetadataSection.svelte';
	import type { Network } from '../types';
	import { createEmptyNetworkFormData } from '../store';
	import NetworkDetailsForm from './NetworkDetailsForm.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { field } from 'svelte-forms';

	let {
		network = null,
		isOpen = false,
		onCreate,
		onUpdate,
		onClose,
		onDelete = null
	}: {
		network?: Network | null;
		isOpen?: boolean;
		onCreate: (data: Network) => Promise<void> | void;
		onUpdate: (id: string, data: Network) => Promise<void> | void;
		onClose: () => void;
		onDelete?: ((id: string) => Promise<void> | void) | null;
	} = $props();

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let loading = $state(false);
	let deleting = $state(false);

	let isEditing = $derived(network !== null);
	let title = $derived(isEditing ? `Edit ${network?.name}` : 'Create Network');

	let formData: Network = $state(createEmptyNetworkFormData());

	// Initialize form data when network changes or modal opens
	$effect(() => {
		if (isOpen) {
			resetForm();
		}
	});

	function resetForm() {
		formData = network ? { ...network } : createEmptyNetworkFormData();
	}

	async function handleSubmit() {
		// Clean up the data before sending

		if (organization) {
			const networkData: Network = {
				...formData,
				name: formData.name.trim(),
				organization_id: organization.id
			};

			loading = true;
			try {
				if (isEditing && network) {
					await onUpdate(network.id, networkData);
				} else {
					await onCreate(networkData);
				}
			} finally {
				loading = false;
			}
		} else {
			pushError('Could not load ID for current user');
			onClose();
		}
	}

	async function handleDelete() {
		if (onDelete && network) {
			deleting = true;
			try {
				await onDelete(network.id);
			} finally {
				deleting = false;
			}
		}
	}

	// Dynamic labels based on create/edit mode
	let saveLabel = $derived(isEditing ? 'Update Network' : 'Create Network');

	const seedDataField = field('seedData', true, []);

	let colorHelper = entities.getColorHelper('Network');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	{deleting}
	{saveLabel}
	cancelLabel="Cancel"
	onSave={handleSubmit}
	onCancel={onClose}
	onDelete={isEditing ? handleDelete : null}
	size="xl"
	let:formApi
>
	<!-- Header icon -->
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={entities.getIconComponent('Network')} color={colorHelper.color} />
	</svelte:fragment>

	<!-- Content -->
	<div class="flex h-full flex-col overflow-hidden">
		<div class="flex-1 overflow-y-auto">
			<div class="space-y-8 p-6">
				<NetworkDetailsForm {formApi} bind:formData />

				{#if !isEditing}
					<Checkbox
						label="Track services Scanopy can't discover automatically?"
						helpText="Creates subnets for remote hosts and internet services that aren't on your local network (Cloud services, APIs, SaaS tools, etc). Includes example data to show how it works."
						id="seedData"
						field={seedDataField}
						{formApi}
					/>
				{/if}

				{#if isEditing}
					<EntityMetadataSection entities={[network]} />
				{/if}
			</div>
		</div>
	</div>
</EditModal>
