import { apiClient, type ApiResponse } from '$lib/api/client';
import { writable } from 'svelte/store';
import type { Discovery } from './types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import type { FieldConfig } from '$lib/shared/components/data/types';
import type { Daemon } from '../daemons/types/base';

export const discoveries = writable<Discovery[]>([]);

export async function getDiscoveries() {
	const { data } = await apiClient.GET('/api/discovery');
	if (data?.success && data.data) {
		discoveries.set(data.data);
	}
	return data as ApiResponse<Discovery[]>;
}

export async function createDiscovery(data: Discovery) {
	const { data: result } = await apiClient.POST('/api/discovery', { body: data });
	if (result?.success && result.data) {
		discoveries.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Discovery>;
}

export async function updateDiscovery(data: Discovery) {
	const { data: result } = await apiClient.PUT('/api/discovery/{id}', {
		params: { path: { id: data.id } },
		body: data
	});
	if (result?.success && result.data) {
		discoveries.update((current) => current.map((g) => (g.id === data.id ? result.data! : g)));
	}
	return result as ApiResponse<Discovery>;
}

export async function deleteDiscovery(id: string) {
	const { data: result } = await apiClient.DELETE('/api/discovery/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		discoveries.update((current) => current.filter((g) => g.id !== id));
	}
	return result;
}

export async function bulkDeleteDiscoveries(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/discovery/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		discoveries.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export function createEmptyDiscoveryFormData(daemon: Daemon | null): Discovery {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		tags: [],
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
