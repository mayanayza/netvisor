<script lang="ts">
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import type { User } from '../types';
	import { Edit, Trash2 } from 'lucide-svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { toColor } from '$lib/shared/utils/styling';
	import { entities, permissions, metadata } from '$lib/shared/stores/metadata';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useDeleteUserMutation } from '$lib/features/users/queries';
	import { useNetworksQuery } from '$lib/features/networks/queries';

	let {
		user,
		viewMode,
		selected,
		onSelectionChange,
		onEdit
	}: {
		user: User;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange: (selected: boolean) => void;
		onEdit?: (user: User) => void;
	} = $props();

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const networksQuery = useNetworksQuery();
	let networksData = $derived(networksQuery.data ?? []);

	// TanStack Query mutation for deleting user
	const deleteUserMutation = useDeleteUserMutation();

	// Force Svelte to track metadata reactivity
	$effect(() => {
		void $metadata;
		void currentUser;
	});

	function handleDeleteUser() {
		if (confirm(`Are you sure you want to delete this user?`)) {
			deleteUserMutation.mutate(user.id);
		}
	}
	function handleEditUser() {
		onEdit?.(user);
	}

	let canManage = $derived(
		currentUser
			? permissions
					.getMetadata(currentUser.permissions)
					.can_manage_user_permissions.includes(user.permissions)
			: false
	);

	// Build card data
	let cardData = $derived({
		title: user.email,
		iconColor: entities.getColorHelper('User').icon,
		Icon: entities.getIconComponent('User'),
		status:
			user.id == currentUser?.id
				? {
						label: 'You',
						color: toColor('yellow')
					}
				: null,
		fields: [
			{
				label: 'Role',
				value: [
					{
						id: user.id,
						label: permissions.getName(user.permissions),
						color: permissions.getColorHelper(user.permissions).color
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
									color: entities.getColorHelper('Network').color
								}
							]
						: user.network_ids.map((n) => ({
								id: n,
								label: networksData.find((net) => net.id == n)?.name ?? 'Unknown Network',
								color: entities.getColorHelper('Network').color
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
		actions:
			canManage && user.id != currentUser?.id
				? [
						{
							label: 'Delete',
							icon: Trash2,
							onClick: () => handleDeleteUser(),
							class: 'btn-icon-danger'
						},
						{
							label: 'Edit',
							icon: Edit,
							onClick: () => handleEditUser(),
							class: 'btn-icon'
						}
					]
				: []
	});
</script>

<GenericCard
	{...cardData}
	{viewMode}
	{selected}
	{onSelectionChange}
	selectable={user.id != currentUser?.id}
/>
