<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { Building2 } from 'lucide-svelte';
	import { currentUser } from '$lib/features/auth/store';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import {
		getOrganization,
		organization,
		updateOrganization,
		resetOrganizationData,
		populateDemoData
	} from './store';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	let { isOpen = $bindable(false), onClose }: { isOpen: boolean; onClose: () => void } = $props();

	// Force Svelte to track organization reactivity
	$effect(() => {
		void $organization;
	});

	let saving = $state(false);
	let resetting = $state(false);
	let populating = $state(false);
	let activeSection = $state<'main' | 'edit'>('main');

	$effect(() => {
		if (isOpen && $currentUser) {
			loadOrganization();
		}
	});

	async function loadOrganization() {
		if (!$currentUser) return;
		await getOrganization();
	}

	let org = $derived($organization);
	let isOwner = $derived($currentUser?.permissions === 'Owner');
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

		saving = true;
		try {
			const result = await updateOrganization({
				...org,
				name: formData.name.trim()
			});

			if (result?.success) {
				pushSuccess('Organization updated successfully');
				activeSection = 'main';
				formData = { name: '' };
			} else {
				pushError(result?.error || 'Failed to update organization');
			}
		} finally {
			saving = false;
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
				'Are you sure you want to reset all organization data? This will delete all networks, hosts, daemons, API keys, and invites. This action cannot be undone.'
			)
		) {
			return;
		}

		resetting = true;
		try {
			const result = await resetOrganizationData(org.id);
			if (result?.success) {
				pushSuccess('Organization data has been reset');
			} else {
				pushError(result?.error || 'Failed to reset organization data');
			}
		} finally {
			resetting = false;
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

		populating = true;
		try {
			const result = await populateDemoData(org.id);
			if (result?.success) {
				pushSuccess('Demo data has been populated');
			} else {
				pushError(result?.error || 'Failed to populate demo data');
			}
		} finally {
			populating = false;
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
		<ModalHeaderIcon Icon={Building2} color="#3b82f6" />
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
									Delete all networks, hosts, daemons, and invites. This cannot be undone.
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
