export interface LoginRequest {
	name: string;
	password: string;
	remember_me: boolean;
}

export interface RegisterRequest {
	username: string;
	password: string;
}

export interface SessionUser {
	user_id: string;
	name: string;
}

export interface User {
	id: string;
	created_at: string;
	updated_at: string;
	name: string;
	username: string;
}
