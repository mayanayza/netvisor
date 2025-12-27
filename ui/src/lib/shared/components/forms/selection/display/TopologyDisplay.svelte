<script lang="ts" module>
	import { entities } from '$lib/shared/stores/metadata';
	import { queryClient, queryKeys } from '$lib/api/query-client';
	import type { Network } from '$lib/features/networks/types';
	import { autoRebuild } from '$lib/features/topology/store';

	export const TopologyDisplay: EntityDisplayComponent<Topology, object> = {
		getId: (topology: Topology) => topology.id,
		getLabel: (topology: Topology) => topology.name,
		getDescription: (topology: Topology) => {
			const networksData = queryClient.getQueryData<Network[]>(queryKeys.networks.all) ?? [];
			const network = networksData.find((n) => n.id == topology.network_id);
			return network ? network.name : 'Unknown Network';
		},
		getIcon: () => entities.getIconComponent('Topology'),
		getIconColor: () => entities.getColorHelper('Topology').icon,
		getTags: (topology: Topology) => {
			let state = getTopologyStateInfo(topology, get(autoRebuild));

			if (state.type == 'fresh') {
				return [
					{
						label: 'Up to date',
						color: state.color
					}
				];
			}

			return [
				{
					label: state.label,
					color: state.color
				}
			];
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getTopologyStateInfo } from '$lib/features/topology/state';
	import { get } from 'svelte/store';

	let {
		item,
		context = {}
	}: {
		item: Topology;
		context: object;
	} = $props();

	$effect(() => {
		void entities;
	});
</script>

<ListSelectItem {item} {context} displayComponent={TopologyDisplay} />
