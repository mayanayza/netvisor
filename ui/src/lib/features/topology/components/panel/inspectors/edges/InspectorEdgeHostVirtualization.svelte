<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { topology } from '$lib/features/topology/store';

	let { edge, vmServiceId }: { edge: Edge; vmServiceId: string } = $props();

	let vmService = $derived($topology.services.find((s) => s.id == vmServiceId) || null);
	let hypervisorHost = $derived($topology.hosts.find((h) => h.id == edge.target) || null);
</script>

<div class="space-y-3">
	{#if vmService}
		<span class="text-secondary mb-2 block text-sm font-medium">VM Service</span>
		<div class="card">
			<EntityDisplayWrapper
				context={{ interfaceId: null }}
				item={vmService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/if}

	{#if hypervisorHost}
		<span class="text-secondary mb-2 block text-sm font-medium">Hypervisor Host</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={hypervisorHost} displayComponent={HostDisplay} />
		</div>
	{/if}
</div>
