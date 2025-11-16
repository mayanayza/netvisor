<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getServiceById } from '$lib/features/services/store';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';

	let { edge, vmServiceId }: { edge: Edge; vmServiceId: string } = $props();

	let vmService = $derived(getServiceById(vmServiceId));
	let hypervisorHost = $derived(getHostFromId(edge.target));
</script>

<div class="space-y-3">
	{#if $vmService}
		<span class="text-secondary mb-2 block text-sm font-medium">VM Service</span>
		<div class="card">
			<EntityDisplayWrapper
				context={{ interfaceId: null }}
				item={$vmService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/if}

	{#if $hypervisorHost}
		<span class="text-secondary mb-2 block text-sm font-medium">Hypervisor Host</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$hypervisorHost} displayComponent={HostDisplay} />
		</div>
	{/if}
</div>
