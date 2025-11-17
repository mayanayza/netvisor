import type { UserOrgPermissions } from '../users/types';

export interface Organization {
	id: string;
	created_at: string;
	updated_at: string;
	stripe_customer_id: string;
	name: string;
	plan: BillingPlan;
	plan_status: string;
	is_onboarded: boolean;
}

export function isBillingPlanActive(organization: Organization) {
	return organization.plan_status == 'active' || organization.plan_status == 'trialing';
}

type BillingPlan =
	| HomelabStarterBillingPlan
	| HomelabProBillingPlan
	| TeamBillingPlan
	| CommunityBillingPlan;

export interface HomelabStarterBillingPlan {
	type: 'HomelabStarter';
	price: {
		cents: number;
		rate: string;
	};
	trial_days: number;
}

export interface HomelabProBillingPlan {
	type: 'HomelabPro';
	price: {
		cents: number;
		rate: string;
	};
	trial_days: number;
}

export interface TeamBillingPlan {
	type: 'Team';
	price: {
		cents: number;
		rate: string;
	};
	trial_days: number;
}

export interface CommunityBillingPlan {
	type: 'Community';
	price: {
		cents: number;
		rate: string;
	};
	trial_days: number;
}

export interface CreateInviteRequest {
	expiration_hours: number | null;
	permissions: UserOrgPermissions;
}

export interface OrganizationInvite {
	token: string;
	permissions: UserOrgPermissions;
	url: string;
	expires_at: string;
	created_at: string;
	created_by: string;
	organization_id: string;
}
