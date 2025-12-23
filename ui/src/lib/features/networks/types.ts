// Re-export generated types from backend
export type { Network } from '$lib/generated';

import type { Network } from '$lib/generated';

// Frontend-specific types
export interface CreateNetworkRequest {
	network: Omit<Network, 'id' | 'created_at' | 'updated_at'>;
	seed_baseline_data: boolean;
}
