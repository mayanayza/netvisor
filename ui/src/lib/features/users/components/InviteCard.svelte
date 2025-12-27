<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { UserPlus, UserX } from 'lucide-svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { formatInviteUrl, useRevokeInviteMutation } from '$lib/features/organizations/queries';
	import { entities, permissions } from '$lib/shared/stores/metadata';
	import type { OrganizationInvite } from '$lib/features/organizations/types';
	import { useUsersQuery } from '$lib/features/users/queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';

	let { invite, viewMode }: { invite: OrganizationInvite; viewMode: 'card' | 'list' } = $props();

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	// TanStack Query for users
	const usersQuery = useUsersQuery();
	let usersData = $derived(usersQuery.data ?? []);

	// Mutation for revoking invite
	const revokeInviteMutation = useRevokeInviteMutation();

	function handleRevokeInvite() {
		if (confirm(`Are you sure you want to revoke this invite URL?`)) {
			revokeInviteMutation.mutate(invite.id);
		}
	}

	let canManage = $derived(
		currentUser
			? permissions
					.getMetadata(currentUser.permissions)
					.can_manage_user_permissions.includes(invite.permissions)
			: false
	);

	// Build card data
	let cardData = $derived({
		title: 'Pending Invite',
		iconColor: entities.getColorHelper('User').icon,
		Icon: UserPlus,
		fields: [
			{
				label: 'URL',
				value: formatInviteUrl(invite)
			},
			{
				label: 'Permissions',
				value: invite.permissions
			},
			{
				label: 'Created By',
				value: usersData.find((u) => u.id == invite.created_by)?.email || 'Unknown User'
			},
			{
				label: 'Sent To',
				value: invite.send_to ? invite.send_to : 'N/A'
			},
			{
				label: 'Expires',
				value: formatTimestamp(invite.expires_at)
			}
		],
		actions: [
			...(canManage
				? [
						{
							label: 'Revoke',
							icon: UserX,
							class: 'btn-icon-danger',
							onClick: () => handleRevokeInvite()
						}
					]
				: [])
		]
	});
</script>

<GenericCard {...cardData} {viewMode} selectable={false} />
