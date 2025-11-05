<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { getSubnetFromId } from '$lib/features/subnets/store';
	import { getServicesForHost } from '$lib/features/services/store';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { HostDisplay }  from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	
	let { node } : { node: Node} = $props();
	
	let isInterfaceNode = $derived(node.type === 'InterfaceNode');
	let isSubnetNode = $derived(node.type === 'SubnetNode');
	
	// Get relevant data based on node type
	let hostStore = $derived(
		isInterfaceNode && node.data.host_id 
			? getHostFromId(node.data.host_id as string) 
			: null
	);
	let host = $derived(hostStore ? $hostStore : null);
	
	let subnetStore = $derived(isSubnetNode ? getSubnetFromId(node.id) : null);
	let subnet = $derived(subnetStore ? $subnetStore : null);
	
	let servicesStore = $derived(
		isInterfaceNode && node.data.host_id
			? getServicesForHost(node.data.host_id as string)
			: null
	);
	let services = $derived(servicesStore ? $servicesStore : []);
</script>

<div class="w-full space-y-4">
	{#if isInterfaceNode && host}
		<div class="space-y-3">
			<span class="text-secondary block text-sm font-medium mb-2">Host</span>
			<div class="card">
				<EntityDisplayWrapper context={{}} item={host} displayComponent={HostDisplay} />
			</div>
			{#if host.description}
				<div class="text-tertiary text-sm">{host.description}</div>
			{/if}
			
			{#if node.data.interface_id}
				{@const iface = host.interfaces.find(i => i.id === node.data.interface_id)}
				{#if iface}
					<span class="text-secondary block text-sm font-medium mb-2">Interface</span>
					<div class="card">
						<EntityDisplayWrapper context={{}} item={iface} displayComponent={InterfaceDisplay} />
					</div>
				{/if}
			{/if}
			
			{#if services && services.length > 0}
				<div>
					<span class="text-secondary block text-sm font-medium mb-2">Services bound to interface</span>
					<div class="space-y-1">
						{#each services as service}
							<div class="card">
								<EntityDisplayWrapper context={{}} item={service} displayComponent={ServiceDisplay} />
							</div>
						{/each}
					</div>
				</div>
			{/if}
			
			{#if host.virtualization}
				<div>
					<span class="text-secondary block text-sm font-medium mb-1">Virtualization</span>
					<p class="text-primary text-sm">{host.virtualization}</p>
				</div>
			{/if}
		</div>
	{:else if isSubnetNode && subnet}
		<span class="text-secondary block text-sm font-medium mb-2">Subnet</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
		</div>
	{/if}
</div>