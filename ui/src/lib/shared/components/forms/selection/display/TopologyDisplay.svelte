<script lang="ts" module>
	import { entities } from '$lib/shared/stores/metadata';

	export const TopologyDisplay: EntityDisplayComponent<Topology, object> = {
		getId: (topology: Topology) => topology.id,
		getLabel: (topology: Topology) => topology.name,
		getDescription: () => '',
		getIcon: () => entities.getIconComponent('Topology'),
		getIconColor: () => entities.getColorHelper('Topology').icon,
		getTags: (topology: Topology) => {
			let state = getTopologyStateInfo(topology);

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
