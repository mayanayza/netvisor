import type { OrganizationInvite } from '../organizations/types';

export interface User {
	id: string;
	organization_id: string;
	created_at: string;
	updated_at: string;
	email: string;
	oidc_provider?: string;
	oidc_subject?: string;
	oidc_linked_at?: string;
	permissions: UserOrgPermissions;
	network_ids: string[];
	tags: string[];
}

export type UserOrgPermissions = 'Owner' | 'Admin' | 'Member' | 'Viewer';

export type UserOrInvite =
	| { type: 'user'; data: User; id: string }
	| { type: 'invite'; data: OrganizationInvite; id: string };

export function isUser(item: UserOrInvite): item is { type: 'user'; data: User; id: string } {
	return item.type === 'user';
}

export function isInvite(
	item: UserOrInvite
): item is { type: 'invite'; data: OrganizationInvite; id: string } {
	return item.type === 'invite';
}
