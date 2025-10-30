export interface DaemonBase {
	host_id: string;
	network_id: string;
	ip: string;
	port: number;
	api_key: string | null;
}

export interface Daemon extends DaemonBase {
	id: string;
	registered_at: string;
	last_seen: string;
}

export interface GenerateApiRequest {
	daemon_id: string;
	network_id: string;
}
