<script lang="ts" context="module">
	import { entities } from '$lib/shared/stores/metadata';

	export const TopologyDisplay: EntityDisplayComponent<Topology, object> = {
		getId: (topology: Topology) => topology.id,
		getLabel: (topology: Topology) => topology.name,
		getDescription: () => '',
		getIcon: () => entities.getIconComponent('Topology'),
		getIconColor: () => entities.getColorHelper('Topology').icon,
		getTags: (topology: Topology) => {
			let state = getTopologyState(topology);

			return [
				{
					label: state.getLabel(topology),
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
	import { getTopologyState } from '$lib/features/topology/state';

	export let item: Topology;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={TopologyDisplay} />
