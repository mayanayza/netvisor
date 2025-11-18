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
}

export type UserOrgPermissions = 'Owner' | 'Admin' | 'Member' | 'Visualizer' | 'None';

export type UserOrInvite =
	| { type: 'user'; data: User }
	| { type: 'invite'; data: OrganizationInvite };

export function isUser(item: UserOrInvite): item is { type: 'user'; data: User } {
	return item.type === 'user';
}

export function isInvite(item: UserOrInvite): item is { type: 'invite'; data: OrganizationInvite } {
	return item.type === 'invite';
}
