import type { components } from '$lib/api/schema';

// Re-export generated types
export type Organization = components['schemas']['Organization'];
export type OrganizationInvite = components['schemas']['Invite'];
export type CreateInviteRequest = components['schemas']['CreateInviteRequest'];

export function isBillingPlanActive(organization: Organization) {
	return organization.plan_status == 'active' || organization.plan_status == 'trialing';
}
