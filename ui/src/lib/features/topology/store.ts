import { get, writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import { type Edge, type Node } from '@xyflow/svelte';
import { EdgeHandle, type TopologyResponse, type TopologyOptions } from './types/base';
import { networks } from '../networks/store';
import deepmerge from 'deepmerge';
import { browser } from '$app/environment';

export const selectedNode = writable<Node | null>(null);
export const selectedEdge = writable<Edge | null>(null);

const OPTIONS_STORAGE_KEY = 'netvisor_topology_options';
const EXPANDED_STORAGE_KEY = 'netvisor_topology_options_expanded_state';

// Default options
const defaultOptions: TopologyOptions = {
	left_zone_title: 'Infrastructure',
	hide_edge_types: [],
	no_fade_edges: false,
	hide_resize_handles: false,
	request_options: {
		group_docker_bridges_by_host: true,
		hide_ports: false,
		hide_vm_title_on_docker_container: false,
		show_gateway_in_left_zone: true,
		left_zone_service_categories: ['DNS', 'ReverseProxy'],
		hide_service_categories: [],
		network_ids: []
	}
};

export const topology = writable<TopologyResponse>();
export const topologyOptions = writable<TopologyOptions>(loadOptionsFromStorage());
export const optionsPanelExpanded = writable<boolean>(loadExpandedFromStorage());

// Initialize network_ids with the first network when networks are loaded
let networksInitialized = false;

if (browser) {
	networks.subscribe(($networks) => {
		if (!networksInitialized && $networks.length > 0) {
			networksInitialized = true;
			topologyOptions.update((opts) => {
				// Only set default if network_ids is empty
				if (opts.request_options.network_ids.length === 0 && $networks[0]) {
					opts.request_options.network_ids = [$networks[0].id];
				}
				return opts;
			});
		}
	});

	let lastRequestOptions = JSON.stringify(get(topologyOptions).request_options);

	// Subscribe to options changes and save to localStorage
	if (typeof window !== 'undefined') {
		topologyOptions.subscribe((options) => {
			saveOptionsToStorage(options);
		});

		optionsPanelExpanded.subscribe((expanded) => {
			saveExpandedToStorage(expanded);
		});

		topologyOptions.subscribe(($options) => {
			const current = JSON.stringify($options.request_options);
			if (current !== lastRequestOptions) {
				lastRequestOptions = current;
				if (networksInitialized) getTopology();
			}
		});
	}
}

export function resetTopologyOptions(): void {
	networksInitialized = false;
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

export async function getTopology() {
	const options = get(topologyOptions);
	return await api.request<TopologyResponse>('/topology', topology, (topology) => topology, {
		method: 'POST',
		body: JSON.stringify(options.request_options)
	});
}

// Cycle through anchor positions in logical order
export function getNextHandle(currentHandle: EdgeHandle): EdgeHandle {
	const cycle = [EdgeHandle.Top, EdgeHandle.Right, EdgeHandle.Bottom, EdgeHandle.Left];
	const currentIndex = cycle.indexOf(currentHandle);
	const nextIndex = (currentIndex + 1) % cycle.length;
	return cycle[nextIndex];
}
