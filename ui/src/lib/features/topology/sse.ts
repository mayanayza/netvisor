import { BaseSSEManager, type SSEConfig } from '$lib/shared/utils/sse';
import { topologies, topology } from './store';
import { get } from 'svelte/store';
import type { Topology } from './types/base';

class TopologySSEManager extends BaseSSEManager<Topology> {
	private stalenessTimers: Map<string, ReturnType<typeof setTimeout>> = new Map();
	private readonly DEBOUNCE_MS = 300;

	// Call this when a refresh completes to cancel pending staleness updates
	public cancelPendingStaleness(topologyId: string) {
		const existingTimer = this.stalenessTimers.get(topologyId);
		if (existingTimer) {
			clearTimeout(existingTimer);
			this.stalenessTimers.delete(topologyId);
		}
	}

	protected createConfig(): SSEConfig<Topology> {
		return {
			url: '/api/topology/stream',
			onMessage: (update) => {
				// If the update says it's NOT stale, apply immediately (it's a refresh)
				if (!update.is_stale) {
					this.cancelPendingStaleness(update.id);
					this.applyUpdate(update);
					return;
				}

				// For staleness updates, debounce them
				const existingTimer = this.stalenessTimers.get(update.id);
				if (existingTimer) {
					clearTimeout(existingTimer);
				}

				const timer = setTimeout(() => {
					this.applyUpdate(update);
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

	private applyUpdate(update: Topology) {
		// Update the topologies array
		topologies.update((topos) => {
			return topos.map((topo) => {
				if (topo.id === update.id) {
					return {
						...update
					};
				}
				return topo;
			});
		});

		// ALSO update the currently selected topology if it matches
		const currentTopology = get(topology);
		if (currentTopology && currentTopology.id === update.id) {
			topology.set(update);
		}
	}
}

export const topologySSEManager = new TopologySSEManager();
