<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import { edgeTypes } from '$lib/shared/stores/metadata';
	import type { TopologyEdge } from '$lib/features/topology/types/base';
	import InspectorEdgeGroup from './edges/InspectorEdgeGroup.svelte';
	import InspectorEdgeInterface from './edges/InspectorEdgeInterface.svelte';
	import InspectorEdgeHostVirtualization from './edges/InspectorEdgeHostVirtualization.svelte';
	import InspectorEdgeServiceVirtualization from './edges/InspectorEdgeServiceVirtualization.svelte';
	
	let { edge }: { edge: Edge } = $props();
	
	let edgeData = $derived(edge.data as TopologyEdge);
	
</script>

<div class="w-full space-y-4">
	{#if edgeData.edge_type === 'HubAndSpoke' || edgeData.edge_type === 'RequestPath'}
		<InspectorEdgeGroup {edge} groupId={edgeData.group_id} sourceBindingId={edgeData.source_binding_id} targetBindingId={edgeData.target_binding_id} />
	{:else if edgeData.edge_type === 'Interface'}
		<InspectorEdgeInterface {edge} hostId={edgeData.host_id} />
	{:else if edgeData.edge_type === 'HostVirtualization'}
		<InspectorEdgeHostVirtualization {edge} vmServiceId={edgeData.vm_service_id} />
	{:else if edgeData.edge_type === 'ServiceVirtualization'}
		<InspectorEdgeServiceVirtualization {edge} containerizingServiceId={edgeData.containerizing_service_id} />
	{:else}
		<div class="space-y-3">
			<p class="text-tertiary text-sm">Unable to display edge details</p>
		</div>
	{/if}
</div>