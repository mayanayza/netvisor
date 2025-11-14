<script lang="ts">
	import type { Node } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { InterfaceDisplay } from '$lib/shared/components/forms/selection/display/InterfaceDisplay.svelte';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { getServicesForHost } from '$lib/features/services/store';

	let { node }: { node: Node } = $props();

	let hostStore = $derived(getHostFromId(node.data.host_id as string));
	let host = $derived($hostStore);

	// Get the interface for this node
	let thisInterface = $derived(
		host ? host.interfaces.find((i) => i.id === node.data.interface_id) : null
	);

	// Get all services for this host
	let servicesForHostStore = $derived(getServicesForHost(node.data.host_id as string));
	let servicesForHost = $derived($servicesForHostStore);

	// Filter services bound to this specific interface
	let servicesOnThisInterface = $derived(
		servicesForHost.filter((s) =>
			s.bindings.some((b) => b.interface_id === node.data.interface_id || b.interface_id === null)
		)
	);

	// Get other interfaces on this host (excluding the current one)
	let otherInterfaces = $derived(
		host ? host.interfaces.filter((i) => i.id !== node.data.interface_id) : []
	);
</script>

<div class="space-y-4">
	<!-- This Interface -->
	{#if thisInterface}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">This Interface</span>
			<div class="card">
				<EntityDisplayWrapper
					context={{}}
					item={thisInterface}
					displayComponent={InterfaceDisplay}
				/>
			</div>
		</div>
	{/if}

	<!-- Services Bound to Interface -->
	{#if servicesOnThisInterface.length > 0}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">
				Services Bound to Interface
			</span>
			<div class="space-y-1">
				{#each servicesOnThisInterface as service (service.id)}
					<div class="card">
						<EntityDisplayWrapper
							context={{ interfaceId: node.data.interface_id }}
							item={service}
							displayComponent={ServiceDisplay}
						/>
					</div>
				{/each}
			</div>
		</div>
	{/if}

	<!-- Host -->
	{#if host}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">Host</span>
			<div class="card">
				<EntityDisplayWrapper context={{}} item={host} displayComponent={HostDisplay} />
			</div>
			{#if host.description}
				<div class="text-tertiary mt-2 text-sm">{host.description}</div>
			{/if}
		</div>
	{/if}

	<!-- Other Host Interfaces -->
	{#if otherInterfaces.length > 0}
		<div>
			<span class="text-secondary mb-2 block text-sm font-medium">
				Other Host Interface{otherInterfaces.length > 1 ? 's' : ''}
			</span>
			<div class="space-y-1">
				{#each otherInterfaces as iface (iface.id)}
					<div class="card">
						<EntityDisplayWrapper context={{}} item={iface} displayComponent={InterfaceDisplay} />
					</div>
				{/each}
			</div>
		</div>
	{/if}
</div>
