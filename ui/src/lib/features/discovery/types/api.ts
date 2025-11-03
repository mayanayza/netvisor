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
	completed?: number;
	total?: number;
	discovered_count?: number;
	error?: string;
	started_at?: string;
	finished_at?: string;
}

export type DiscoveryType = Network | Docker | SelfReport;

export interface Network {
	type: 'Network';
	subnet_ids: string[];
}

export interface Docker {
	type: 'Docker';
	host_id: string;
}

export interface SelfReport {
	type: 'SelfReport';
	host_id: string;
}
