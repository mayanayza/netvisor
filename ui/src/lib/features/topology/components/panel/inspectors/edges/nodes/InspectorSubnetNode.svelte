<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getSubnetFromId } from '$lib/features/subnets/store';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';

	let { node }: { node: Node } = $props();

	let subnetStore = $derived(getSubnetFromId(node.id));
	let subnet = $derived($subnetStore);
</script>

<div class="space-y-4">
	{#if subnet}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Subnet</span>
			<div class="card">
				<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
			</div>
		</div>
	{/if}
</div>
