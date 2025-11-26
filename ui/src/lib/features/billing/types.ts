export interface BillingPlan {
	base_cents: number;
	seat_cents: number | null;
	included_seats: number | null;
	network_cents: number | null;
	included_networks: number | null;
	rate: string;
	trial_days: number;
	type: 'Starter' | 'Pro' | 'Team' | 'Enterprise';
}

export function formatPrice(cents: number, rate: string): string {
	return `${cents / 100} per ${rate}`;
}

export interface CheckoutSessionRequest {
	plan: BillingPlan;
	host: string;
}

export interface CheckoutSessionResponse {
	checkout_url: string;
	session_id: string;
}
