import { BaseSSEManager, type SSEConfig } from '$lib/shared/utils/sse';
import { autoRebuild, rebuildTopology, topologies, topology } from './store';
import { get } from 'svelte/store';
import type { Topology } from './types/base';

class TopologySSEManager extends BaseSSEManager<Topology> {
	private stalenessTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
	private readonly DEBOUNCE_MS = 300;

	protected createConfig(): SSEConfig<Topology> {
		return {
			url: '/api/topology/stream',
			onMessage: (update) => {
				// If the update says it's NOT stale, apply immediately (it's a full refresh)
				if (!update.is_stale) {
					this.applyFullUpdate(update);
					return;
				}

				// For stale updates with autoRebuild enabled, trigger an actual rebuild
				if (get(autoRebuild)) {
					const currentTopo = get(topology);
					if (currentTopo && currentTopo.id === update.id && !currentTopo.is_locked) {
						rebuildTopology(update);
					}
					return;
				}

				// For staleness updates, debounce thema
				const existingTimer = this.stalenessTimers.get(update.id);
				if (existingTimer) {
					clearTimeout(existingTimer);
				}

				const timer = setTimeout(() => {
					this.applyPartialUpdate(update.id, {
						removed_groups: update.removed_groups,
						removed_hosts: update.removed_hosts,
						removed_services: update.removed_services,
						removed_subnets: update.removed_subnets,
						removed_bindings: update.removed_bindings,
						removed_interfaces: update.removed_interfaces,
						removed_ports: update.removed_ports,
						is_stale: update.is_stale,
						options: update.options
					});
					this.stalenessTimers.delete(update.id);
				}, this.DEBOUNCE_MS);

				this.stalenessTimers.set(update.id, timer);
			},
			onError: (error) => {
				console.error('Topology SSE error:', error);
			},
			onOpen: () => {
				console.log('Topology SSE connected');
			}
		};
	}

	private applyFullUpdate(update: Topology) {
		topologies.update((topos) => {
			return topos.map((topo) => {
				if (topo.id === update.id) {
					return update;
				}
				return topo;
			});
		});

		const currentTopology = get(topology);
		if (currentTopology && currentTopology.id === update.id) {
			topology.set(update);
		}
	}

	private applyPartialUpdate(topologyId: string, updates: Partial<Topology>) {
		topologies.update((topos) => {
			return topos.map((topo) => {
				if (topo.id === topologyId) {
					return {
						...topo,
						...updates
					};
				}
				return topo;
			});
		});

		const currentTopology = get(topology);
		if (currentTopology && currentTopology.id === topologyId) {
			topology.update((topo) => {
				return {
					...topo,
					...updates
				};
			});
		}
	}
}

export const topologySSEManager = new TopologySSEManager();
