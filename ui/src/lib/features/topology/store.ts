import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import { type Edge, type Node } from '@xyflow/svelte';
import { EdgeHandle, type Topology, type TopologyOptions } from './types/base';
import { networks } from '../networks/store';
import deepmerge from 'deepmerge';
import { browser } from '$app/environment';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export const topologies = writable<Topology[]>([]);
export const topology = writable<Topology>();
export const selectedNetwork = writable<string>('');

export const selectedNode = writable<Node | null>(null);
export const selectedEdge = writable<Edge | null>(null);

const OPTIONS_STORAGE_KEY = 'netvisor_topology_options';
const EXPANDED_STORAGE_KEY = 'netvisor_topology_options_expanded_state';

// Default options
const defaultOptions: TopologyOptions = {
	local: {
		left_zone_title: 'Infrastructure',
		hide_edge_types: [],
		no_fade_edges: false,
		hide_resize_handles: false
	},
	request: {
		group_docker_bridges_by_host: true,
		hide_ports: false,
		hide_vm_title_on_docker_container: false,
		show_gateway_in_left_zone: true,
		left_zone_service_categories: ['DNS', 'ReverseProxy'],
		hide_service_categories: []
	}
};

export const topologyOptions = writable<TopologyOptions>(loadOptionsFromStorage());
export const optionsPanelExpanded = writable<boolean>(loadExpandedFromStorage());

let topologyInitialized = false;
let lastTopologyId = '';

if (browser) {
	topologies.subscribe(($topologies) => {
		if (!topologyInitialized && $topologies.length > 0) {
			topology.set($topologies[0]);
			lastTopologyId = $topologies[0].id;
			topologyInitialized = true;
		}
	});

	// Subscribe to options changes and save to localStorage + update topology object
	if (typeof window !== 'undefined') {
		topologyOptions.subscribe((options) => {
			saveOptionsToStorage(options);
		});

		topology.subscribe((topology) => {
			if (topology && lastTopologyId != topology.id) {
				lastTopologyId = topology.id;
				topologyOptions.set(topology.options);
			}
		});

		optionsPanelExpanded.subscribe((expanded) => {
			saveExpandedToStorage(expanded);
		});
	}
}

export function resetTopologyOptions(): void {
	// networksInitialized = false;
	topologyOptions.set(structuredClone(defaultOptions));
	if (browser) {
		localStorage.removeItem(OPTIONS_STORAGE_KEY);
		localStorage.removeItem(EXPANDED_STORAGE_KEY);
	}
}

// Load options from localStorage or use defaults
function loadOptionsFromStorage(): TopologyOptions {
	if (typeof window === 'undefined') return defaultOptions;

	try {
		const stored = localStorage.getItem(OPTIONS_STORAGE_KEY);
		if (stored) {
			const parsed = JSON.parse(stored);

			// Deep merge ensures newly added nested fields get defaults,
			// while preserving any existing stored preferences.
			return deepmerge(defaultOptions, parsed, {
				arrayMerge: (_, sourceArray) => sourceArray
			});
		}
	} catch (error) {
		console.warn('Failed to load topology options from localStorage:', error);
	}
	return defaultOptions;
}

// Save options to localStorage
function saveOptionsToStorage(options: TopologyOptions): void {
	if (typeof window === 'undefined') return;

	try {
		localStorage.setItem(OPTIONS_STORAGE_KEY, JSON.stringify(options));
	} catch (error) {
		console.error('Failed to save topology options to localStorage:', error);
	}
}

// Load options panel expanded state from localStorage or use defaults
function loadExpandedFromStorage(): boolean {
	if (typeof window === 'undefined') return true;

	try {
		const stored = localStorage.getItem(EXPANDED_STORAGE_KEY);
		if (stored) {
			return JSON.parse(stored);
		}
	} catch (error) {
		console.warn('Failed to load topology expanded state from localStorage:', error);
	}
	return false;
}

// Save options to localStorage
function saveExpandedToStorage(expanded: boolean): void {
	if (typeof window === 'undefined') return;

	try {
		localStorage.setItem(EXPANDED_STORAGE_KEY, JSON.stringify(expanded));
	} catch (error) {
		console.error('Failed to save topology expanded state to localStorage:', error);
	}
}

export async function refreshTopology(data: Topology) {
	return await api.request<Topology>(
		`/topology/${data.id}/refresh`,
		topology,
		(topology) => topology,
		{
			method: 'POST',
			body: JSON.stringify(data)
		}
	);
}

export async function lockTopology(data: Topology) {
	return await api.request<Topology>(
		`/topology/${data.id}/lock`,
		topology,
		(topology) => topology,
		{
			method: 'POST',
			body: JSON.stringify(data)
		}
	);
}

export async function unlockTopology(data: Topology) {
	return await api.request<Topology>(
		`/topology/${data.id}/unlock`,
		topology,
		(topology) => topology,
		{
			method: 'POST',
			body: JSON.stringify(data)
		}
	);
}

export async function getTopologies() {
	const result = await api.request<Topology[]>(
		'/topology',
		topologies,
		(topologies) => topologies,
		{
			method: 'GET'
		}
	);
	return result;
}

export async function createTopology(data: Topology) {
	const result = await api.request<Topology, Topology[]>(
		`/topology`,
		topologies,
		(newTopology, current) => [...current, newTopology],
		{ method: 'POST', body: JSON.stringify(data) }
	);

	if (result && result.data && result.success) {
		topology.set(result.data);
	}

	return result;
}

export async function deleteTopology(id: string) {
	await api.request<void, Topology[]>(
		`/topology/${id}`,
		topologies,
		(_, current) => current.filter((t) => t.id != id),
		{ method: 'DELETE' }
	);
}

export async function updateTopology(data: Topology) {
	const result = await api.request<Topology, Topology[]>(
		`/topology/${data.id}`,
		topologies,
		(updatedTopology, current) => current.map((t) => (t.id === data.id ? updatedTopology : t)),
		{ method: 'PUT', body: JSON.stringify(data) }
	);

	return result;
}

// Cycle through anchor positions in logical order
export function getNextHandle(currentHandle: EdgeHandle): EdgeHandle {
	const cycle = [EdgeHandle.Top, EdgeHandle.Right, EdgeHandle.Bottom, EdgeHandle.Left];
	const currentIndex = cycle.indexOf(currentHandle);
	const nextIndex = (currentIndex + 1) % cycle.length;
	return cycle[nextIndex];
}

export function createEmptyTopologyFormData(): Topology {
	return {
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		name: '',
		network_id: get(networks)[0]?.id || '',
		edges: [],
		nodes: [],
		options: structuredClone(defaultOptions),
		hosts: [],
		services: [],
		subnets: [],
		groups: [],
		is_stale: false,
		last_refreshed: utcTimeZoneSentinel,
		is_locked: false,
		removed_groups: [],
		removed_hosts: [],
		removed_services: [],
		removed_subnets: [],
		locked_at: null,
		locked_by: null
	};
}
