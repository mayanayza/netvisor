<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getHostFromId, getInterfaceFromId } from '$lib/features/hosts/store';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';

	let { edge, hostId }: { edge: Edge; hostId: string } = $props();

	let hostStore = $derived(getHostFromId(hostId));
	let host = $derived($hostStore);

	let sourceInterfaceStore = $derived(getInterfaceFromId(edge.source));
	let sourceInterface = $derived($sourceInterfaceStore);

	let targetInterfaceStore = $derived(getInterfaceFromId(edge.target));
	let targetInterface = $derived($targetInterfaceStore);
</script>

<div class="space-y-3">
	{#if host}
		<span class="text-secondary mb-2 block text-sm font-medium">Host</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={host} displayComponent={HostDisplay} />
		</div>
	{/if}
	<span class="text-secondary mb-2 block text-sm font-medium">Interfaces</span>
	{#if sourceInterface}
		<div class="card">
			<EntityDisplayWrapper
				context={{}}
				item={sourceInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}

	{#if targetInterface}
		<div class="card">
			<EntityDisplayWrapper
				context={{}}
				item={targetInterface}
				displayComponent={InterfaceDisplay}
			/>
		</div>
	{/if}
</div>
