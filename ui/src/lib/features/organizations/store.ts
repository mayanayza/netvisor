import { writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { CreateInviteRequest, OrganizationInvite, Organization } from './types';
import type { SetupRequest } from '../auth/types/base';
import type { UserOrgPermissions } from '../users/types';

export const organization = writable<Organization | null>();
export const invites = writable<OrganizationInvite[]>([]);

export async function onboard(request: SetupRequest): Promise<void> {
	await api.request<Organization, Organization | null>('/onboarding', organization, (org) => org, {
		method: 'POST',
		body: JSON.stringify(request)
	});
}

export async function getOrganization(): Promise<Organization | null> {
	const result = await api.request<Organization | null>(
		`/organizations`,
		organization,
		(organization) => organization,
		{
			method: 'GET'
		}
	);

	if (result && result.success && result.data) {
		return result.data;
	}
	return null;
}

export async function updateOrganizationName(id: string, name: string) {
	return await api.request<Organization, Organization | null>(
		`/organizations/${id}`,
		organization,
		(updated) => updated,
		{
			method: 'PUT',
			body: JSON.stringify(name)
		}
	);
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

	const result = await api.request<OrganizationInvite, OrganizationInvite[]>(
		`/invites`,
		invites,
		(created, current) => [...current, created],
		{
			method: 'POST',
			body: JSON.stringify(request)
		}
	);

	if (result && result.success && result.data) {
		return result.data;
	}
	return null;
}

export async function getInvites(): Promise<OrganizationInvite[]> {
	const result = await api.request<OrganizationInvite[]>(
		`/invites`,
		invites,
		(invites) => invites,
		{
			method: 'GET'
		}
	);

	if (result && result.success && result.data) {
		return result.data;
	}
	return [];
}

export async function revokeInvite(id: string): Promise<void> {
	await api.request<void, OrganizationInvite[]>(
		`/invites/${id}/revoke`,
		invites,
		(_, current) => current.filter((i) => i.id != id),
		{
			method: 'DELETE'
		}
	);
}

export function formatInviteUrl(invite: OrganizationInvite): string {
	return `${invite.url}/api/invites/${invite.id}/accept`;
}
