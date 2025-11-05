<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getBindingFromId, getServiceForBinding } from '$lib/features/services/store';
	import { PortBindingDisplay } from '$lib/shared/components/forms/selection/display/PortBindingDisplay.svelte';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { getGroupById } from '$lib/features/groups/store';
	import { GroupDisplay } from '$lib/shared/components/forms/selection/display/GroupDisplay.svelte';
	import { InterfaceBindingDisplay } from '$lib/shared/components/forms/selection/display/InterfaceBindingDisplay.svelte';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	
	let { edge, groupId, sourceBindingId, targetBindingId }: { edge: Edge; groupId: string, sourceBindingId: string, targetBindingId: string } = $props();

	console.log(groupId)

	let group = $derived(getGroupById(groupId));
	let sourceBinding = $derived(getBindingFromId(sourceBindingId));
	let targetBinding = $derived(getBindingFromId(targetBindingId));
	
	let sourceService = $derived($sourceBinding ? getServiceForBinding($sourceBinding.id) : null);
	let targetService = $derived($targetBinding ? getServiceForBinding($targetBinding.id) : null);
	let sourceHost = $derived($sourceService ? getHostFromId($sourceService.host_id) : null);
	let targetHost = $derived($targetService ? getHostFromId($targetService.host_id) : null);
	
	let sourceContext = $derived(
		$sourceService && $sourceHost 
			? { service: $sourceService, host: $sourceHost }
			: null
	);
	let targetContext = $derived(
		$targetService && $targetHost
			? { service: $targetService, host: $targetHost }
			: null
	);

</script>

<div class="space-y-3">
	{#if $group}
		<span class="text-secondary block text-sm font-medium mb-2">Group</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$group} displayComponent={GroupDisplay} />
		</div>
	{/if}
	
	{#if $sourceBinding && sourceContext}
		<span class="text-secondary block text-sm font-medium mb-2">Source</span>
		<div class="card">
			<EntityDisplayWrapper context={sourceContext} item={$sourceBinding} displayComponent={BindingWithServiceDisplay} />
		</div>
	{/if}
	
	{#if $targetBinding && targetContext}
		<span class="text-secondary block text-sm font-medium mb-2">Target</span>
		<div class="card">
			<EntityDisplayWrapper context={targetContext} item={$targetBinding} displayComponent={BindingWithServiceDisplay} />
		</div>
	{/if}
</div>