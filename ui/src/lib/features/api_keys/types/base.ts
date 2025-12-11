export interface ApiKey {
	id: string;
	created_at: string;
	updated_at: string;
	key: string;
	expires_at: string | null;
	last_used: string | null;
	network_id: string;
	name: string;
	is_enabled: boolean;
	tags: string[];
}
