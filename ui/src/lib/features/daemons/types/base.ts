export interface DaemonBase {
	host_id: string;
	network_id: string;
	ip: string;
	port: number;
	last_seen: string;
	capabilities: {
		has_docker_socket: boolean;
		interfaced_subnet_ids: string[];
	};
}

export interface Daemon extends DaemonBase {
	id: string;
	created_at: string;
	updated_at: string;
}
