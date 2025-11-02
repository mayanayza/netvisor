export interface InitiateDiscoveryRequest {
	daemon_id: string;
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

export type DiscoveryType = NetworkScan | DockerScan | SelfReport;

export interface NetworkScan {
	type: 'NetworkScan';
	subnet_ids: null;
}

export interface DockerScan {
	type: 'DockerScan';
	host_id: string;
}

export interface SelfReport {
	type: 'SelfReport';
	host_id: string;
}
