<script lang="ts" context="module">
	import { entities } from '$lib/shared/stores/metadata';

	export const DaemonDisplay: EntityDisplayComponent<Daemon, object> = {
		getId: (daemon: Daemon) => daemon.id,
		getLabel: (daemon: Daemon) =>
			get(getHostFromId(daemon.host_id))?.name || daemon.ip || 'Unknown Daemon',
		getDescription: (daemon: Daemon) => get(getHostFromId(daemon.host_id))?.description || '',
		getIcon: () => entities.getIconComponent('Daemon'),
		getIconColor: () => entities.getColorHelper('Daemon').icon,
		getTags: () => [],
		getCategory: () => null
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';

	export let item: Daemon;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={DaemonDisplay} />
