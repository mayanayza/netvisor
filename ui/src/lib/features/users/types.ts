export interface User {
	id: string;
	organization_id: string;
	created_at: string;
	updated_at: string;
	email: string;
	oidc_provider?: string;
	oidc_subject?: string;
	oidc_linked_at?: string;
	permissions: string;
}
