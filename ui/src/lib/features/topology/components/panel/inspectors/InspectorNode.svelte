<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import InspectorInterfaceNode from './edges/nodes/InspectorInterfaceNode.svelte';
	import InspectorSubnetNode from './edges/nodes/InspectorSubnetNode.svelte';

	let { node }: { node: Node } = $props();

	let isInterfaceNode = $derived(node.type === 'InterfaceNode');
	let isSubnetNode = $derived(node.type === 'SubnetNode');
</script>

<div class="w-full space-y-4">
	{#if isInterfaceNode}
		<InspectorInterfaceNode {node} />
	{:else if isSubnetNode}
		<InspectorSubnetNode {node} />
	{:else}
		<div class="space-y-3">
			<p class="text-tertiary text-sm">Unable to display node details</p>
		</div>
	{/if}
</div>
