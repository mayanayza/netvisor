import { BaseSSEManager, type SSEConfig } from '$lib/shared/utils/sse';
import { topologies, topology } from './store';
import { get } from 'svelte/store';

export interface TopologyStalenessUpdate {
	topology_id: string;
	is_stale: boolean;
	removed_hosts: string[];
	removed_services: string[];
	removed_subnets: string[];
	removed_groups: string[];
}

class TopologySSEManager extends BaseSSEManager<TopologyStalenessUpdate> {
	protected createConfig(): SSEConfig<TopologyStalenessUpdate> {
		return {
			url: '/api/topology/stream',
			onMessage: (update) => {
				console.log('Received topology staleness update', update);

				// Update the topologies array
				topologies.update((topos) => {
					return topos.map((topo) => {
						if (topo.id === update.topology_id) {
							return {
								...topo,
								is_stale: update.is_stale,
								removed_hosts: update.removed_hosts,
								removed_services: update.removed_services,
								removed_subnets: update.removed_subnets,
								removed_groups: update.removed_groups
							};
						}
						return topo;
					});
				});

				// ALSO update the currently selected topology if it matches
				const currentTopology = get(topology);
				if (currentTopology && currentTopology.id === update.topology_id) {
					topology.update((topo) => ({
						...topo,
						is_stale: update.is_stale,
						removed_hosts: update.removed_hosts,
						removed_services: update.removed_services,
						removed_subnets: update.removed_subnets,
						removed_groups: update.removed_groups
					}));
				}
			},
			onError: (error) => {
				console.error('Topology SSE error:', error);
			},
			onOpen: () => {
				console.log('Topology SSE connected');
			}
		};
	}
}

export const topologySSEManager = new TopologySSEManager();
