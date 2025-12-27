/**
 * TanStack Query hooks for Organizations and Invites
 */

import { createQuery, createMutation, useQueryClient } from '@tanstack/svelte-query';
import { queryKeys, queryClient } from '$lib/api/query-client';
import { apiClient } from '$lib/api/client';
import type { CreateInviteRequest, OrganizationInvite, Organization } from './types';
import type { UserOrgPermissions, User } from '../users/types';

/**
 * Query hook for fetching current organization
 * Only fetches when user is authenticated
 */
export function useOrganizationQuery() {
	return createQuery(() => {
		// Check if user is authenticated before fetching
		const user = queryClient.getQueryData<User | null>(queryKeys.auth.currentUser());
		return {
			queryKey: queryKeys.organizations.current(),
			queryFn: async () => {
				const { data } = await apiClient.GET('/api/organizations');
				if (!data?.success || !data.data) {
					throw new Error(data?.error || 'Failed to fetch organization');
				}
				return data.data;
			},
			// Only fetch when user is authenticated
			enabled: !!user
		};
	});
}

/**
 * Query hook for fetching invites
 */
export function useInvitesQuery() {
	return createQuery(() => ({
		queryKey: queryKeys.invites.all,
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/invites');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch invites');
			}
			return data.data;
		}
	}));
}

/**
 * Mutation hook for updating organization name
 */
export function useUpdateOrganizationMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async ({ id, name }: { id: string; name: string }) => {
			const { data } = await apiClient.PUT('/api/organizations/{id}', {
				params: { path: { id } },
				body: name
			});
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to update organization');
			}
			return data.data;
		},
		onSuccess: (updatedOrg: Organization) => {
			queryClient.setQueryData(queryKeys.organizations.current(), updatedOrg);
		}
	}));
}

/**
 * Mutation hook for creating an invite
 */
export function useCreateInviteMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async ({
			permissions,
			network_ids,
			email
		}: {
			permissions: UserOrgPermissions;
			network_ids: string[];
			email: string;
		}) => {
			const request: CreateInviteRequest = {
				expiration_hours: null,
				permissions,
				network_ids,
				send_to: email?.length === 0 ? null : email
			};

			const { data } = await apiClient.POST('/api/invites', { body: request });
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to create invite');
			}
			return data.data;
		},
		onSuccess: (newInvite: OrganizationInvite) => {
			queryClient.setQueryData<OrganizationInvite[]>(queryKeys.invites.all, (old) =>
				old ? [...old, newInvite] : [newInvite]
			);
		}
	}));
}

/**
 * Mutation hook for revoking an invite
 */
export function useRevokeInviteMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (id: string) => {
			const { data } = await apiClient.DELETE('/api/invites/{id}/revoke', {
				params: { path: { id } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to revoke invite');
			}
			return id;
		},
		onSuccess: (id: string) => {
			queryClient.setQueryData<OrganizationInvite[]>(
				queryKeys.invites.all,
				(old) => old?.filter((i) => i.id !== id) ?? []
			);
		}
	}));
}

/**
 * Mutation hook for resetting organization data
 */
export function useResetOrganizationDataMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (orgId: string) => {
			const { data } = await apiClient.POST('/api/organizations/{id}/reset', {
				params: { path: { id: orgId } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to reset organization data');
			}
			return data;
		},
		onSuccess: () => {
			// Invalidate all data queries after reset
			queryClient.invalidateQueries();
		}
	}));
}

/**
 * Mutation hook for populating demo data
 */
export function usePopulateDemoDataMutation() {
	const queryClient = useQueryClient();

	return createMutation(() => ({
		mutationFn: async (orgId: string) => {
			const { data } = await apiClient.POST('/api/organizations/{id}/populate-demo', {
				params: { path: { id: orgId } }
			});
			if (!data?.success) {
				throw new Error(data?.error || 'Failed to populate demo data');
			}
			return data;
		},
		onSuccess: () => {
			// Invalidate all data queries after populating demo data
			queryClient.invalidateQueries();
		}
	}));
}

/**
 * Helper to format invite URL
 */
export function formatInviteUrl(invite: OrganizationInvite): string {
	return `${invite.url}/api/invites/${invite.id}/accept`;
}

/**
 * Fetch organization directly (bypasses enabled check, useful after login/register)
 */
export async function fetchOrganization(): Promise<Organization> {
	return queryClient.fetchQuery({
		queryKey: queryKeys.organizations.current(),
		queryFn: async () => {
			const { data } = await apiClient.GET('/api/organizations');
			if (!data?.success || !data.data) {
				throw new Error(data?.error || 'Failed to fetch organization');
			}
			return data.data;
		}
	});
}
