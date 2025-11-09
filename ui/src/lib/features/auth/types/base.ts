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
