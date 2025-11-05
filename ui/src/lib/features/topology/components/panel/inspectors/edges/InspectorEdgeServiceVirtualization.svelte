<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getServiceById } from '$lib/features/services/store';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { getSubnetFromId } from '$lib/features/subnets/store';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { topologyOptions } from '$lib/features/topology/store';
	
	let { edge, containerizingServiceId }: { edge: Edge; containerizingServiceId: string } = $props();
	
	let containerizingService = $derived(getServiceById(containerizingServiceId));
	
	// Target can be either a subnet (grouped) or a service (not grouped)
	let isGrouped = $derived($topologyOptions.request_options.group_docker_bridges_by_host);
	let dockerBridgeSubnet = $derived(isGrouped ? getSubnetFromId(edge.target) : null);
	let containerService = $derived(!isGrouped ? getServiceById(edge.target) : null);
</script>

<div class="space-y-3">
	{#if $containerizingService}
		<span class="text-secondary block text-sm font-medium mb-2">Docker/Container Manager Service</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$containerizingService} displayComponent={ServiceDisplay} />
		</div>
	{/if}
	
	{#if isGrouped && $dockerBridgeSubnet}
		<span class="text-secondary block text-sm font-medium mb-2">Docker Bridge Subnet (Grouped)</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$dockerBridgeSubnet} displayComponent={SubnetDisplay} />
		</div>
	{:else if !isGrouped && $containerService}
		<span class="text-secondary block text-sm font-medium mb-2">Container Service</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$containerService} displayComponent={ServiceDisplay} />
		</div>
	{/if}
</div>