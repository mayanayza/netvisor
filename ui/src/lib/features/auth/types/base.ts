export interface LoginRequest {
	email: string;
	password: string;
}

export interface RegisterRequest {
	email: string;
	password: string;
}

export interface SessionUser {
	user_id: string;
	name: string;
}

export interface OnboardingRequest {
	organization_name: string;
	network_name: string;
	populate_seed_data: boolean;
}

export interface ForgotPasswordRequest {
	email: string;
}

export interface ResetPasswordRequest {
	password: string;
	token: string;
}
