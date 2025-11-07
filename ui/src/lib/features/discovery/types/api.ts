export interface InitiateDiscoveryRequest {
	daemon_id: string;
	discovery_type: DiscoveryType;
}

export interface DiscoverySessionRequest {
	session_id: string;
}

export interface DiscoveryUpdatePayload {
	session_id: string;
	daemon_id: string;
	discovery_type: DiscoveryType;
	phase: 'Pending' | 'Starting' | 'Started' | 'Scanning' | 'Complete' | 'Failed' | 'Cancelled';
	processed?: number;
	total_to_process?: number;
	error?: string;
	started_at?: string;
	finished_at?: string;
}

export type DiscoveryType = Network | Docker | SelfReport;

export interface Network {
	type: 'Network';
	subnet_ids: string[];
	host_naming_fallback: 'Ip' | 'BestService';
}

export interface Docker {
	type: 'Docker';
	host_id: string;
	host_naming_fallback: 'Ip' | 'BestService';
}

export interface SelfReport {
	type: 'SelfReport';
	host_id: string;
}
