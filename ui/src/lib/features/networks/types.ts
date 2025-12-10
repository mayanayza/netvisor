export interface Network {
	id: string;
	created_at: string;
	updated_at: string;
	name: string;
	is_default: boolean;
	organization_id: string;
	tags: string[];
}

export interface CreateNetworkRequest {
	network: Network;
	seed_baseline_data: boolean;
}
