import type { DiscoveryType, DiscoveryUpdatePayload } from './api';

export interface Discovery {
	id: string;
	created_at: string;
	updated_at: string;
	discovery_type: DiscoveryType;
	run_type: RunType;
	name: string;
	daemon_id: string;
	network_id: string;
	tags: string[];
}

export type RunType = HistoricalRun | ScheduledRun | AdHocRun;

export interface HistoricalRun {
	type: 'Historical';
	results: DiscoveryUpdatePayload;
}

export interface ScheduledRun {
	type: 'Scheduled';
	cron_schedule: string;
	last_run: string | null;
	enabled: boolean;
}

export interface AdHocRun {
	type: 'AdHoc';
	last_run: string | null;
}
