<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { User } from '../types';
	import { Trash2 } from 'lucide-svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { entities, permissions, metadata } from '$lib/shared/stores/metadata';
	import { currentUser } from '$lib/features/auth/store';
	import { deleteUser } from '../store';
	import { networks } from '$lib/features/networks/store';

	let {
		user,
		viewMode,
		selected,
		onSelectionChange
	}: {
		user: User;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange: (selected: boolean) => void;
	} = $props();

	// Force Svelte to track metadata reactivity
	$effect(() => {
		void $metadata;
		void $currentUser;
	});

	function handleDeleteUser() {
		if (confirm(`Are you sure you want to delete this user?`)) {
			deleteUser(user.id);
		}
	}

	let canManage = $derived(
		$currentUser
			? permissions
					.getMetadata($currentUser.permissions)
					.can_manage_user_permissions.includes(user.permissions)
			: false
	);

	// Build card data
	let cardData = $derived({
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
			},
			{
				label: 'Networks',
				value:
					user.permissions == 'Admin' || user.permissions == 'Owner'
						? [
								{
									id: user.id,
									label: 'All',
									color: entities.getColorHelper('Network').string
								}
							]
						: user.network_ids.map((n) => ({
								id: n,
								label: $networks.find((net) => net.id == n)?.name ?? 'Unknown Network',
								color: entities.getColorHelper('Network').string
							}))
			}
			// {
			// 	label: 'Tags',
			// 	value: user.tags.map(t => {
			// 		const tag = $tags.find(tag => tag.id == t)
			// 		return tag ? { id: tag.id, color: tag.color, label: tag.name} : { id: t, color: "gray", label: "Unknown Tag"}
			// 	})
			// },
		],
		actions: canManage
			? [
					{
						label: 'Delete',
						icon: Trash2,
						onClick: () => handleDeleteUser(),
						class: 'btn-icon-danger'
					}
				]
			: []
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
