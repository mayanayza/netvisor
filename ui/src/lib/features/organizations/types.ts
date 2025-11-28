import type { BillingPlan } from '../billing/types';
import type { UserOrgPermissions } from '../users/types';

export interface Organization {
	id: string;
	created_at: string;
	updated_at: string;
	stripe_customer_id: string;
	name: string;
	plan: BillingPlan;
	plan_status: string;
	onboarding: string[];
}

export interface CreateInviteRequest {
	expiration_hours: number | null;
	permissions: UserOrgPermissions;
	network_ids: string[];
	send_to: string | null;
}

export interface OrganizationInvite {
	id: string;
	permissions: UserOrgPermissions;
	url: string;
	send_to: string | null;
	expires_at: string;
	created_at: string;
	created_by: string;
	organization_id: string;
}

export function isBillingPlanActive(organization: Organization) {
	return organization.plan_status == 'active' || organization.plan_status == 'trialing';
}
