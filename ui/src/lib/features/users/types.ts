import type { components } from '$lib/api/schema';
import type { OrganizationInvite } from '../organizations/types';

// Re-export generated types
export type User = components['schemas']['User'];
export type UserOrgPermissions = components['schemas']['UserOrgPermissions'];

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
