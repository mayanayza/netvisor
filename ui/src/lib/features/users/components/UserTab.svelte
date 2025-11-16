<script lang="ts">
	import { users, getUsers } from '../store';
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import EmptyState from '$lib/shared/components/layout/EmptyState.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import DataControls from '$lib/shared/components/data/DataControls.svelte';
	import type { FieldConfig } from '$lib/shared/components/data/types';
	import UserCard from './UserCard.svelte';
	import InviteCard from './InviteCard.svelte';
	import {
		getInvites,
		getOrganization,
		invites,
		organization
	} from '$lib/features/organizations/store';
	import { UserPlus } from 'lucide-svelte';
	import { isUser, type UserOrInvite } from '../types';
	import InviteModal from './InviteModal.svelte';
	import { billingPlans, metadata } from '$lib/shared/stores/metadata';

	// Force Svelte to track metadata reactivity
	$effect(() => {
		void $metadata;
		void $organization;
	});

	const loading = loadData([getUsers, getInvites, getOrganization]);

	let showInviteModal = $state(false);

	// Combine users and invites into single array
	let combinedItems = $derived([
		...$users.map((user) => ({ type: 'user' as const, data: user })),
		...$invites.map((invite) => ({ type: 'invite' as const, data: invite }))
	] as UserOrInvite[]);

	async function handleCreateInvite() {
		showInviteModal = true;
	}

	function handleCloseInviteModal() {
		showInviteModal = false;
	}

	// Make headerButtons reactive
	let headerButtons = $derived.by(() => {
		if (!$organization || !$organization.plan) return [];

		let features = billingPlans.getMetadata($organization.plan.type).features;
		let canInviteUsers = features.share_views || features.team_members;

		return canInviteUsers
			? [
					{
						cta: 'Invite User',
						onClick: handleCreateInvite,
						IconComponent: UserPlus
					}
				]
			: [];
	});

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
	<TabHeader title="Users" subtitle="Manage users in your organization" buttons={headerButtons} />

	<!-- Loading state -->
	{#if $loading}
		<Loading />
	{:else if combinedItems.length === 0}
		<!-- Empty state -->
		<EmptyState title="No users found" subtitle="Users will appear here once added" />
	{:else}
		<DataControls items={combinedItems} fields={userFields} storageKey="netvisor-users-table-state">
			{#snippet children(item: UserOrInvite, viewMode: 'card' | 'list')}
				{#if isUser(item)}
					<UserCard user={item.data} {viewMode} />
				{:else}
					<InviteCard invite={item.data} {viewMode} />
				{/if}
			{/snippet}
		</DataControls>
	{/if}
</div>

<InviteModal isOpen={showInviteModal} onClose={handleCloseInviteModal} />
