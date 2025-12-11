export interface DaemonBase {
	host_id: string;
	network_id: string;
	url: string;
	name: string;
	last_seen: string;
	mode: 'Pull' | 'Push';
	capabilities: {
		has_docker_socket: boolean;
		interfaced_subnet_ids: string[];
	};
	tags: string[];
}

export interface Daemon extends DaemonBase {
	id: string;
	created_at: string;
	updated_at: string;
}
