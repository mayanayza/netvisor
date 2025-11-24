<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { UserPlus, UserX } from 'lucide-svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { formatInviteUrl, revokeInvite } from '$lib/features/organizations/store';
	import { entities, permissions } from '$lib/shared/stores/metadata';
	import type { OrganizationInvite } from '$lib/features/organizations/types';
	import { users } from '../store';
	import { currentUser } from '$lib/features/auth/store';

	export let invite: OrganizationInvite;
	export let viewMode: 'card' | 'list';

	function handleRevokeInvite() {
		if (confirm(`Are you sure you want to revoke this invite URL?`)) {
			revokeInvite(invite.id);
		}
	}

	$: canManage = $currentUser
		? permissions.getMetadata($currentUser.permissions).can_manage.includes(invite.permissions)
		: false;

	// Build card data
	$: cardData = {
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
				value: $users.find((u) => u.id == invite.created_by)?.email || 'Unknown User'
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
	};
</script>

<GenericCard {...cardData} {viewMode} selectable={false} />
