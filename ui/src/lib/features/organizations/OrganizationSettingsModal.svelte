<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { Building2 } from 'lucide-svelte';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import {
		useOrganizationQuery,
		useUpdateOrganizationMutation,
		useResetOrganizationDataMutation,
		usePopulateDemoDataMutation
	} from './queries';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	let { isOpen = $bindable(false), onClose }: { isOpen: boolean; onClose: () => void } = $props();

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	const updateOrganizationMutation = useUpdateOrganizationMutation();
	const resetOrganizationDataMutation = useResetOrganizationDataMutation();
	const populateDemoDataMutation = usePopulateDemoDataMutation();

	let saving = $derived(updateOrganizationMutation.isPending);
	let resetting = $derived(resetOrganizationDataMutation.isPending);
	let populating = $derived(populateDemoDataMutation.isPending);
	let activeSection = $state<'main' | 'edit'>('main');

	let org = $derived(organizationQuery.data);
	let isOwner = $derived(currentUser?.permissions === 'Owner');
	let isDemoOrg = $derived(org?.plan?.type === 'Demo');

	// Form data
	let formData = $state({
		name: ''
	});

	const name = field('name', '', [required()]);

	$effect(() => {
		if (isOpen && activeSection === 'edit' && org) {
			name.set(org.name);
			formData.name = org.name;
		}
	});

	$effect(() => {
		formData.name = $name.value;
	});

	async function handleSave() {
		if (!org) return;

		try {
			await updateOrganizationMutation.mutateAsync({ id: org.id, name: formData.name });
			pushSuccess('Organization updated successfully');
			activeSection = 'main';
			formData = { name: '' };
		} catch {
			pushError('Failed to update organization');
		}
	}

	function handleCancel() {
		if (activeSection === 'edit') {
			activeSection = 'main';
			formData = { name: '' };
			name.set(org?.name || '');
		} else {
			onClose();
		}
	}

	async function handleReset() {
		if (!org) return;

		if (
			!confirm(
				'Are you sure you want to reset all organization data? This will delete all entities and users from your organization. This action cannot be undone.'
			)
		) {
			return;
		}

		try {
			await resetOrganizationDataMutation.mutateAsync(org.id);
			pushSuccess('Organization data has been reset');
		} catch {
			pushError('Failed to reset organization data');
		}
	}

	async function handlePopulateDemo() {
		if (!org) return;

		if (
			!confirm(
				'Are you sure you want to populate demo data? This will add sample networks, hosts, and services to your organization.'
			)
		) {
			return;
		}

		try {
			await populateDemoDataMutation.mutateAsync(org.id);
			pushSuccess('Demo data has been populated');
		} catch {
			pushError('Failed to populate demo data');
		}
	}

	let modalTitle = $derived(
		activeSection === 'main' ? 'Organization Settings' : 'Edit Organization'
	);
	let showSave = $derived(activeSection === 'edit');
	let cancelLabel = $derived(activeSection === 'main' ? 'Close' : 'Back');
</script>

<EditModal
	{isOpen}
	title={modalTitle}
	loading={saving}
	saveLabel="Save Changes"
	{showSave}
	showCancel={true}
	{cancelLabel}
	onSave={showSave ? handleSave : null}
	onCancel={handleCancel}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={Building2} color="Blue" />
	</svelte:fragment>

	{#if org}
		{#if activeSection === 'main'}
			<div class="space-y-6">
				<!-- Organization Info -->
				<InfoCard title="Organization Information">
					<InfoRow label="Name">{org.name}</InfoRow>
					{#if org.plan}
						<InfoRow label="Plan">{org.plan.type}</InfoRow>
					{/if}
					<InfoRow label="Created">
						{formatTimestamp(org.created_at)}
					</InfoRow>
					<InfoRow label="ID" mono={true}>{org.id}</InfoRow>
				</InfoCard>

				<!-- Actions -->
				<InfoCard>
					<div class="flex items-center justify-between">
						<div>
							<p class="text-primary text-sm font-medium">Organization Name</p>
							<p class="text-secondary text-xs">Update your organization's display name</p>
						</div>
						<button
							onclick={() => {
								activeSection = 'edit';
								name.set(org.name);
							}}
							class="btn-primary"
						>
							Edit
						</button>
					</div>
				</InfoCard>

				{#if isOwner}
					<!-- Reset Organization Data (available to all org owners) -->
					<InfoCard>
						<div class="flex items-center justify-between">
							<div>
								<p class="text-primary text-sm font-medium">Reset Organization Data</p>
								<p class="text-secondary text-xs">
									Delete everything except for any organization owner user account. This cannot be
									undone.
								</p>
							</div>
							<button onclick={handleReset} disabled={resetting} class="btn-danger">
								{resetting ? 'Resetting...' : 'Reset'}
							</button>
						</div>
					</InfoCard>

					{#if isDemoOrg}
						<!-- Populate Demo Data (only for Demo orgs) -->
						<InfoCard>
							<div class="flex items-center justify-between">
								<div>
									<p class="text-primary text-sm font-medium">Populate Demo Data</p>
									<p class="text-secondary text-xs">
										Fill the organization with sample data for demonstration purposes.
									</p>
								</div>
								<button onclick={handlePopulateDemo} disabled={populating} class="btn-primary">
									{populating ? 'Populating...' : 'Populate'}
								</button>
							</div>
						</InfoCard>
					{/if}
				{/if}
			</div>
		{:else if activeSection === 'edit'}
			<div class="space-y-6">
				<p class="text-secondary text-sm">Update your organization's display name</p>
				<TextInput
					label="Organization Name"
					id="name"
					{formApi}
					placeholder="Enter organization name"
					field={name}
				/>
			</div>
		{/if}
	{:else}
		<div class="text-secondary py-8 text-center">
			<p>Unable to load organization information</p>
			<p class="text-tertiary mt-2 text-sm">Please try again later</p>
		</div>
	{/if}
</EditModal>
