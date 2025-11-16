export interface BillingPlan {
	price: {
		cents: number;
		rate: string;
	};
	trial_days: number;
	type: string;
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
