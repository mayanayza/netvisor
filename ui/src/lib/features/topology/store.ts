import { get, writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import { type Edge, type Node } from '@xyflow/svelte';
import { type Topology, type TopologyOptions } from './types/base';
import { networks } from '../networks/store';
import deepmerge from 'deepmerge';
import { browser } from '$app/environment';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

let initialized = false;
let topologyInitialized = false;
let lastTopologyId = '';

export const topologies = writable<Topology[]>([]);
export const topology = writable<Topology>();
export const selectedNetwork = writable<string>('');
export const autoRebuild = writable<boolean>(loadAutoRebuildFromStorage());

export const selectedNode = writable<Node | null>(null);
export const selectedEdge = writable<Edge | null>(null);

const OPTIONS_STORAGE_KEY = 'scanopy_topology_options';
const EXPANDED_STORAGE_KEY = 'scanopy_topology_options_expanded_state';
const AUTO_REBUILD_STORAGE_KEY = 'scanopy_topology_auto_rebuild';

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

const PREFERRED_NETWORK_KEY = 'scanopy_preferred_network_id';

/**
 * Set a preferred network to select when topology loads.
 * Used after onboarding to ensure the scanned network's topology is shown.
 */
export function setPreferredNetwork(networkId: string): void {
	if (browser) {
		localStorage.setItem(PREFERRED_NETWORK_KEY, networkId);
	}
}

function initializeSubscriptions() {
	if (initialized) {
		return;
	}

	initialized = true;

	if (browser) {
		topologies.subscribe(($topologies) => {
			if (!topologyInitialized && $topologies.length > 0) {
				// Check for a preferred network from onboarding
				const preferredNetworkId = localStorage.getItem(PREFERRED_NETWORK_KEY);
				let selectedTopology = $topologies[0];

				if (preferredNetworkId) {
					// Find topology for the preferred network
					const preferredTopology = $topologies.find((t) => t.network_id === preferredNetworkId);
					if (preferredTopology) {
						selectedTopology = preferredTopology;
					}
					// Clear the preference after using it
					localStorage.removeItem(PREFERRED_NETWORK_KEY);
				}

				topology.set(selectedTopology);
				topologyOptions.set(selectedTopology.options);
				lastTopologyId = selectedTopology.id;
				topologyInitialized = true;
			}
		});

		if (typeof window !== 'undefined') {
			let optionsUpdateTimeout: ReturnType<typeof setTimeout> | null = null;

			topologyOptions.subscribe(async (options) => {
				saveOptionsToStorage(options);

				// Clear any pending timeout
				if (optionsUpdateTimeout) {
					clearTimeout(optionsUpdateTimeout);
				}

				// Debounce the API call
				optionsUpdateTimeout = setTimeout(async () => {
					const currentTopology = get(topology);
					if (currentTopology) {
						const updatedTopology = {
							...currentTopology,
							options: options
						};
						await updateTopology(updatedTopology);
					}
				}, 500);
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

			// Load autoRebuild from localStorage and set up persistence
			const storedAutoRebuild = loadAutoRebuildFromStorage();
			autoRebuild.set(storedAutoRebuild);
			let autoRebuildInitialized = false;
			autoRebuild.subscribe((value) => {
				// Skip the first subscription call to avoid overwriting localStorage
				if (!autoRebuildInitialized) {
					autoRebuildInitialized = true;
					return;
				}
				saveAutoRebuildToStorage(value);
			});
		}
	}
}

// Initialize immediately
initializeSubscriptions();

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

// Load auto rebuild state from localStorage or use default (true)
function loadAutoRebuildFromStorage(): boolean {
	if (typeof window === 'undefined') return true;

	try {
		const stored = localStorage.getItem(AUTO_REBUILD_STORAGE_KEY);
		if (stored !== null) {
			return JSON.parse(stored);
		}
	} catch (error) {
		console.warn('Failed to load auto rebuild state from localStorage:', error);
	}
	return true;
}

// Save auto rebuild state to localStorage
function saveAutoRebuildToStorage(autoRebuild: boolean): void {
	if (typeof window === 'undefined') return;

	try {
		localStorage.setItem(AUTO_REBUILD_STORAGE_KEY, JSON.stringify(autoRebuild));
	} catch (error) {
		console.error('Failed to save auto rebuild state to localStorage:', error);
	}
}

export async function refreshTopology(data: Topology) {
	// Updated topology returns through SSE
	await apiClient.POST('/api/topology/{id}/refresh', {
		params: { path: { id: data.id } },
		body: data
	});
}

export async function lockTopology(data: Topology) {
	const { data: result } = await apiClient.POST('/api/topology/{id}/lock', {
		params: { path: { id: data.id } },
		body: data
	});

	if (result?.success && result.data) {
		topologies.update((current) => current.map((t) => (t.id == data.id ? result.data! : t)));
		if (get(topology)?.id === data.id) {
			topology.set(result.data);
		}
	}

	return result as ApiResponse<Topology>;
}

export async function unlockTopology(data: Topology) {
	const { data: result } = await apiClient.POST('/api/topology/{id}/unlock', {
		params: { path: { id: data.id } },
		body: data
	});

	if (result?.success && result.data) {
		topologies.update((current) => current.map((t) => (t.id == data.id ? result.data! : t)));
		if (get(topology)?.id === data.id) {
			topology.set(result.data);
		}
	}

	return result as ApiResponse<Topology>;
}

export async function getTopologies() {
	const { data } = await apiClient.GET('/api/topology');
	if (data?.success && data.data) {
		topologies.set(data.data);
	}
}

export async function rebuildTopology(data: Topology) {
	// Updated topology returns through SSE
	await apiClient.POST('/api/topology/{id}/rebuild', {
		params: { path: { id: data.id } },
		body: data
	});
}

export async function updateTopology(data: Topology) {
	// Updated topology returns through SSE
	await apiClient.PUT('/api/topology/{id}', {
		params: { path: { id: data.id } },
		body: data
	});
}

export async function createTopology(data: Topology) {
	const { data: result } = await apiClient.POST('/api/topology', { body: data });

	if (result?.success && result.data) {
		topologies.update((current) => [...current, result.data!]);
		topology.set(result.data);
	}

	return result as ApiResponse<Topology>;
}

export async function deleteTopology(id: string) {
	const { data: result } = await apiClient.DELETE('/api/topology/{id}', {
		params: { path: { id } }
	});

	if (result?.success) {
		topologies.update((current) => current.filter((t) => t.id != id));
		if (get(topologies).length > 0) {
			topology.set(get(topologies)[0]);
		}
	}
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
		interfaces: [],
		services: [],
		subnets: [],
		groups: [],
		ports: [],
		bindings: [],
		is_stale: false,
		last_refreshed: utcTimeZoneSentinel,
		is_locked: false,
		removed_groups: [],
		removed_hosts: [],
		removed_interfaces: [],
		removed_services: [],
		removed_subnets: [],
		removed_bindings: [],
		removed_ports: [],
		locked_at: null,
		locked_by: null,
		parent_id: null,
		tags: []
	};
}
