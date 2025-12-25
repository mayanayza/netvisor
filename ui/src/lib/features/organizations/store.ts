import { writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { CreateInviteRequest, OrganizationInvite, Organization } from './types';
import type { UserOrgPermissions } from '../users/types';

export const organization = writable<Organization | null>();
export const invites = writable<OrganizationInvite[]>([]);

export async function getOrganization(): Promise<Organization | null> {
	const { data } = await apiClient.GET('/api/organizations');
	if (data?.success && data.data) {
		organization.set(data.data);
		return data.data;
	}
	return null;
}

export async function updateOrganizationName(id: string, name: string) {
	const { data: result } = await apiClient.PUT('/api/organizations/{id}', {
		params: { path: { id } },
		body: name
	});
	if (result?.success && result.data) {
		organization.set(result.data);
	}
	return result as ApiResponse<Organization>;
}

export async function createInvite(
	permissions: UserOrgPermissions,
	network_ids: string[],
	email: string
): Promise<OrganizationInvite | null> {
	const request: CreateInviteRequest = {
		expiration_hours: null,
		permissions,
		network_ids,
		send_to: email?.length == 0 ? null : email
	};

	const { data: result } = await apiClient.POST('/api/invites', { body: request });
	if (result?.success && result.data) {
		invites.update((current) => [...current, result.data!]);
		return result.data;
	}
	return null;
}

export async function getInvites(): Promise<OrganizationInvite[]> {
	const { data } = await apiClient.GET('/api/invites');
	if (data?.success && data.data) {
		invites.set(data.data);
		return data.data;
	}
	return [];
}

export async function revokeInvite(id: string): Promise<void> {
	const { data: result } = await apiClient.DELETE('/api/invites/{id}/revoke', {
		params: { path: { id } }
	});
	if (result?.success) {
		invites.update((current) => current.filter((i) => i.id != id));
	}
}

export function formatInviteUrl(invite: OrganizationInvite): string {
	return `${invite.url}/api/invites/${invite.id}/accept`;
}

export async function resetOrganizationData(orgId: string) {
	const { data } = await apiClient.POST('/api/organizations/{id}/reset', {
		params: { path: { id: orgId } }
	});
	return data;
}

export async function populateDemoData(orgId: string) {
	const { data } = await apiClient.POST('/api/organizations/{id}/populate-demo', {
		params: { path: { id: orgId } }
	});
	return data;
}
