<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { User } from '../types';
	import { Trash2 } from 'lucide-svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { entities, permissions } from '$lib/shared/stores/metadata';
	import { currentUser } from '$lib/features/auth/store';
	import { deleteUser } from '../store';

	export let user: User;
	export let viewMode: 'card' | 'list';

	function handleDeleteUser() {
		if (confirm(`Are you sure you want to delete this user?`)) {
			deleteUser(user.id);
		}
	}

	$: canManage = $currentUser
		? permissions.getMetadata($currentUser.permissions).can_manage.includes(user.permissions)
		: false;

	// Build card data
	$: cardData = {
		title: user.email,
		iconColor: entities.getColorHelper('User').icon,
		Icon: entities.getIconComponent('User'),
		status:
			user.id == $currentUser?.id
				? {
						label: 'You',
						color: 'yellow'
					}
				: null,
		fields: [
			{
				label: 'Role',
				value: [
					{
						id: user.id,
						label: permissions.getName(user.permissions),
						color: permissions.getColorHelper(user.permissions).string
					}
				]
			},
			{
				label: 'Authentication',
				value: user.oidc_provider || 'Email & Password'
			},
			{
				label: 'Joined',
				value: formatTimestamp(user.created_at)
			}
		],
		actions: [
			...(canManage
				? [
						{
							label: 'Delete',
							icon: Trash2,
							onClick: () => handleDeleteUser(),
							class: 'btn-icon-danger'
						}
					]
				: [])
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
