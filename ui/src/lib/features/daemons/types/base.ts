export interface DaemonBase {
	host_id: string;
	network_id: string;
	ip: string;
	port: number;
	api_key: string | null;
	capabilities: {
		has_docker_socket: boolean;
		interfaced_subnet_ids: string[];
	};
}

export interface Daemon extends DaemonBase {
	id: string;
	registered_at: string;
	last_seen: string;
}
