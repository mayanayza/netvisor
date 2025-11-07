export interface User {
	id: string;
	created_at: string;
	updated_at: string;
	name: string;
	username: string;
	oidc_provider?: string;
	oidc_subject?: string;
	oidc_linked_at?: string;
}
