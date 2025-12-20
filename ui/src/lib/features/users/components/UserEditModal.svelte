<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import { NetworkDisplay } from '$lib/shared/components/forms/selection/display/NetworkDisplay.svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { entities, permissions, metadata } from '$lib/shared/stores/metadata';
	import { currentUser } from '$lib/features/auth/store';
	import { networks } from '$lib/features/networks/store';
	import { updateUserAsAdmin } from '../store';
	import { pushSuccess, pushError } from '$lib/shared/stores/feedback';
	import type { User, UserOrgPermissions } from '../types';
	import type { Network } from '$lib/features/networks/types';

	let {
		isOpen = $bindable(false),
		user,
		onClose
	}: {
		isOpen: boolean;
		user: User | null;
		onClose: () => void;
	} = $props();

	// Force Svelte to track reactivity
	$effect(() => {
		void $metadata;
		void $currentUser;
		void $networks;
	});

	let loading = $state(false);

	// Permission levels that don't need network assignment
	const networksNotNeeded: string[] = permissions
		.getItems()
		.filter((p) => p.metadata.manage_org_entities)
		.map((p) => p.id);

	// Create form field for permissions
	const permissionsField = field('permissions', '', [required()]);

	// Selected networks state
	let selectedNetworks: Network[] = $state([]);

	// Filter permission options to only those the current user can manage
	let permissionOptions = $derived(
		permissions
			.getItems()
			.filter((p) => {
				if (!$currentUser) return false;
				const canManage = permissions
					.getMetadata($currentUser.permissions)
					.can_manage_user_permissions.includes(p.id);
				return canManage;
			})
			.map((p) => ({ value: p.id, label: p.name, description: p.description }))
	);

	// Available networks for selection
	let networkOptions = $derived(
		$networks.filter((n) => !selectedNetworks.some((sn) => sn.id === n.id))
	);

	// Reset form when modal opens or user changes
	$effect(() => {
		if (isOpen && user) {
			permissionsField.set(user.permissions);
			selectedNetworks = user.network_ids
				.map((id) => $networks.find((n) => n.id === id))
				.filter((n): n is Network => n !== undefined);
		}
	});

	function handleAddNetwork(id: string) {
		const network = $networks.find((n) => n.id === id);
		if (network) {
			selectedNetworks = [...selectedNetworks, network];
		}
	}

	function handleRemoveNetwork(index: number) {
		selectedNetworks = selectedNetworks.filter((_, i) => i !== index);
	}

	async function handleSubmit() {
		if (!user) return;

		loading = true;
		try {
			const updatedUser: User = {
				...user,
				permissions: $permissionsField.value as UserOrgPermissions,
				network_ids: networksNotNeeded.includes($permissionsField.value as UserOrgPermissions)
					? []
					: selectedNetworks.map((n) => n.id)
			};

			const result = await updateUserAsAdmin(updatedUser);
			if (result?.success) {
				pushSuccess(`User ${user.email} updated successfully`);
				onClose();
			} else {
				pushError(result?.error || 'Failed to update user');
			}
		} catch (err) {
			pushError(`Failed to update user: ${err}`);
		} finally {
			loading = false;
		}
	}

	function handleClose() {
		if (!loading) {
			onClose();
		}
	}

	let title = $derived(user ? `Edit ${user.email}` : 'Edit User');
</script>

<EditModal
	{isOpen}
	{title}
	{loading}
	saveLabel="Save Changes"
	cancelLabel="Cancel"
	onSave={handleSubmit}
	onCancel={handleClose}
	size="xl"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon
			Icon={entities.getIconComponent('User')}
			color={entities.getColorHelper('User').icon}
		/>
	</svelte:fragment>

	{#if user}
		<div class="space-y-6">
			<!-- User Info (read-only) -->
			<div class="card card-static">
				<div class="space-y-2">
					<div class="flex items-center justify-between">
						<span class="text-secondary text-sm">Email</span>
						<span class="text-primary text-sm font-medium">{user.email}</span>
					</div>
					<div class="flex items-center justify-between">
						<span class="text-secondary text-sm">Authentication</span>
						<span class="text-primary text-sm">{user.oidc_provider || 'Email & Password'}</span>
					</div>
				</div>
			</div>

			<!-- Permissions Selection -->
			<SelectInput
				label="Permissions Level"
				id="permissions"
				{formApi}
				field={permissionsField}
				options={permissionOptions}
				helpText="Choose the access level for this user"
			/>

			<!-- Network Assignment (only for Member/Viewer) -->
			{#if !networksNotNeeded.includes($permissionsField.value as UserOrgPermissions)}
				<ListManager
					label="Networks"
					helpText="Select networks this user will have access to"
					required={true}
					allowReorder={false}
					allowAddFromOptions={true}
					allowCreateNew={false}
					allowItemEdit={() => false}
					disableCreateNewButton={false}
					onAdd={handleAddNetwork}
					onRemove={handleRemoveNetwork}
					options={networkOptions}
					optionDisplayComponent={NetworkDisplay}
					items={selectedNetworks}
					itemDisplayComponent={NetworkDisplay}
					{formApi}
				/>
			{:else}
				<div class="card card-static">
					<p class="text-secondary text-sm">
						Users with {$permissionsField.value} permissions have access to all networks.
					</p>
				</div>
			{/if}
		</div>
	{/if}
</EditModal>
