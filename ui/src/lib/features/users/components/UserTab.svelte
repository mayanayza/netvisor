<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import UserCard from './UserCard.svelte';
	import InviteCard from './InviteCard.svelte';
	import { useInvitesQuery } from '$lib/features/organizations/queries';
	import { UserPlus } from 'lucide-svelte';
	import { isUser, type User, type UserOrInvite } from '../types';
	import InviteModal from './InviteModal.svelte';
	import { metadata, permissions } from '$lib/shared/stores/metadata';
	import UserEditModal from './UserEditModal.svelte';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useUsersQuery, useBulkDeleteUsersMutation } from '../queries';

	// Query
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const usersQuery = useUsersQuery();
	const bulkDeleteUsersMutation = useBulkDeleteUsersMutation();
	const invitesQuery = useInvitesQuery();

	// Derived data
	let usersData = $derived(usersQuery.data ?? []);
	let invitesData = $derived(invitesQuery.data ?? []);
	let isLoading = $derived(usersQuery.isPending);

	// Force Svelte to track metadata reactivity
	$effect(() => {
		void $metadata;
	});

	let showInviteModal = $state(false);
	let showEditModal = $state(false);
	let editingUser = $state<User | null>(null);

	// Combine users and invites into single array
	let combinedItems = $derived([
		...usersData.map((user) => ({ type: 'user' as const, data: user, id: user.id })),
		...invitesData.map((invite) => ({ type: 'invite' as const, data: invite, id: invite.id }))
	] as UserOrInvite[]);

	async function handleCreateInvite() {
		showInviteModal = true;
	}

	function handleCloseInviteModal() {
		showInviteModal = false;
	}

	// Check if user can invite
	let canInviteUsers = $derived(
		currentUser
			? permissions.getMetadata(currentUser.permissions).can_manage_user_permissions.length > 0
			: false
	);

	async function handleBulkDelete(ids: string[]) {
		if (confirm(`Are you sure you want to delete ${ids.length} Users?`)) {
			await bulkDeleteUsersMutation.mutateAsync(ids);
		}
	}

	function handleEditUser(user: User) {
		editingUser = user;
		showEditModal = true;
	}

	function handleCloseEditModal() {
		showEditModal = false;
		editingUser = null;
	}

	// Only define fields for users (invites won't be filtered/sorted)
	const userFields: FieldConfig<UserOrInvite>[] = [
		{
			key: 'email',
			label: 'Email',
			type: 'string',
			searchable: true,
			filterable: false,
			sortable: true,
			getValue(item) {
				return isUser(item) ? item.data.email : '';
			}
		},
		{
			key: 'permissions',
			label: 'Role',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: true,
			getValue(item) {
				return isUser(item) ? item.data.permissions : '';
			}
		},
		{
			key: 'oidc_provider',
			label: 'Auth Method',
			type: 'string',
			searchable: false,
			filterable: true,
			sortable: false,
			getValue(item) {
				return isUser(item) ? item.data.oidc_provider || 'Email & Password' : '';
			}
		}
	];
</script>

<div class="space-y-6">
	<!-- Header -->
	<TabHeader title="Users" subtitle="Manage users in your organization">
		<svelte:fragment slot="actions">
			{#if canInviteUsers}
				<button class="btn-primary flex items-center" onclick={handleCreateInvite}>
					<UserPlus class="mr-2 h-5 w-5" />
					Invite User
				</button>
			{/if}
		</svelte:fragment>
	</TabHeader>

	<!-- Loading state -->
	{#if isLoading}
		<Loading />
	{:else if combinedItems.length === 0}
		<!-- Empty state -->
		<EmptyState title="No users found" subtitle="Users will appear here once added" />
	{:else}
		<DataControls
			items={combinedItems}
			fields={userFields}
			storageKey="scanopy-users-table-state"
			onBulkDelete={handleBulkDelete}
			getItemId={(item) => item.id}
		>
			{#snippet children(
				item: UserOrInvite,
				viewMode: 'card' | 'list',
				isSelected: boolean,
				onSelectionChange: (selected: boolean) => void
			)}
				{#if isUser(item)}
					<UserCard
						user={item.data}
						{viewMode}
						selected={isSelected}
						{onSelectionChange}
						onEdit={handleEditUser}
					/>
				{:else}
					<InviteCard invite={item.data} {viewMode} />
				{/if}
			{/snippet}
		</DataControls>
	{/if}
</div>

<InviteModal isOpen={showInviteModal} onClose={handleCloseInviteModal} />
<UserEditModal isOpen={showEditModal} user={editingUser} onClose={handleCloseEditModal} />
