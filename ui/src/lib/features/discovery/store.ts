import { api } from '$lib/shared/utils/api';
import { writable } from 'svelte/store';
import type { Discovery } from './types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import type { FieldConfig } from '$lib/shared/components/data/types';
import type { Daemon } from '../daemons/types/base';

export const discoveries = writable<Discovery[]>([]);

export async function getDiscoveries() {
	return await api.request<Discovery[]>(`/discovery`, discoveries, (discoveries) => discoveries, {
		method: 'GET'
	});
}

export async function createDiscovery(data: Discovery) {
	return api.request<Discovery, Discovery[]>(
		'/discovery',
		discoveries,
		(group, current) => [...current, group],
		{ method: 'POST', body: JSON.stringify(data) }
	);
}

export async function updateDiscovery(data: Discovery) {
	return api.request<Discovery, Discovery[]>(
		`/discovery/${data.id}`,
		discoveries,
		(updatedDiscovery, current) => current.map((g) => (g.id === data.id ? updatedDiscovery : g)),
		{ method: 'PUT', body: JSON.stringify(data) }
	);
}

export async function deleteDiscovery(id: string) {
	await api.request<void, Discovery[]>(
		`/discovery/${id}`,
		discoveries,
		(_, current) => current.filter((g) => g.id !== id),
		{ method: 'DELETE' }
	);
}

export async function bulkDeleteDiscoveries(ids: string[]) {
	const result = await api.request<void, Discovery[]>(
		`/discovery/bulk-delete`,
		discoveries,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

export function createEmptyDiscoveryFormData(daemon: Daemon | null): Discovery {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		discovery_type: {
			type: 'Network',
			subnet_ids: daemon ? daemon.capabilities.interfaced_subnet_ids : [],
			host_naming_fallback: 'BestService'
		},
		run_type: {
			type: 'Scheduled',
			last_run: null,
			cron_schedule: '0 0 * * * *',
			enabled: true
		},
		name: 'My Scheduled Discovery',
		daemon_id: daemon ? daemon.id : uuidv4Sentinel,
		network_id: daemon ? daemon.network_id : uuidv4Sentinel
	};
}

/**
 * Parse a simple cron expression back to hours
 * Only handles the patterns we generate
 */
export function parseCronToHours(cron: string): number | null {
	const parts = cron.split(' ');
	if (parts.length !== 6) return null;

	const [, , hour, day, ,] = parts;

	// Daily pattern: "0 0 0 * * *"
	if (hour === '0' && day === '*') {
		return 24;
	}

	// Every N days: "0 0 0 */N * *"
	if (hour === '0' && day.startsWith('*/')) {
		const days = parseInt(day.slice(2));
		return days * 24;
	}

	// Every N hours: "0 0 */N * * *"
	if (hour.startsWith('*/')) {
		return parseInt(hour.slice(2));
	}

	// Every hour: "0 0 * * * *"
	if (hour === '*') {
		return 1;
	}

	return null;
}

/**
 * Generate a cron expression for "every N hours"
 * Format: "0 0 *\/N * * *" (second minute hour day month weekday)
 */
export function generateCronSchedule(hours: number): string {
	if (hours === 0) {
		return '0 0 * * * *'; // Every hour as fallback
	}
	if (hours === 1) {
		return '0 0 * * * *'; // Every hour
	}
	if (hours === 24) {
		return '0 0 0 * * *'; // Daily at midnight
	}
	if (hours % 24 === 0) {
		// Every N days at midnight
		const days = hours / 24;
		return `0 0 0 */${days} * *`;
	}
	// Every N hours
	return `0 0 */${hours} * * *`;
}

// Define field configuration for the DataTableControls
export const discoveryFields = (daemons: Daemon[]): FieldConfig<Discovery>[] => [
	{
		key: 'name',
		label: 'Name',
		type: 'string',
		searchable: true,
		filterable: false,
		sortable: true
	},
	{
		key: 'daemon',
		label: 'Daemon',
		type: 'string',
		searchable: true,
		filterable: true,
		sortable: true,
		getValue: (item) => {
			const daemon = daemons.find((d) => d.id == item.daemon_id);
			return daemon ? daemon.name : 'Unknown Daemon';
		}
	},
	{
		key: 'discovery_type',
		label: 'Discovery Type',
		type: 'string',
		searchable: true,
		filterable: true,
		sortable: true,
		getValue: (item) => item.discovery_type.type
	}
];
