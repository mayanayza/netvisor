<script lang="ts">
	import type { Edge } from '@xyflow/svelte';
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getServiceById, services } from '$lib/features/services/store';
	import { ServiceDisplay } from '$lib/shared/components/forms/selection/display/ServiceDisplay.svelte';
	import { getSubnetFromId } from '$lib/features/subnets/store';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import { topologyOptions } from '$lib/features/topology/store';
	import { getHostFromId, getInterfaceFromId } from '$lib/features/hosts/store';
	import { get } from 'svelte/store';
	import { HostDisplay } from '$lib/shared/components/forms/selection/display/HostDisplay.svelte';
	import { SvelteMap } from 'svelte/reactivity';
	import type { Subnet } from '$lib/features/subnets/types/base';

	let { edge, containerizingServiceId }: { edge: Edge; containerizingServiceId: string } = $props();

	let containerizingService = $derived(getServiceById(containerizingServiceId));

	let containerizingHost = $derived(
		$containerizingService ? getHostFromId($containerizingService.host_id) : null
	);

	// Target can be either a subnet (grouped) or a service (not grouped)
	let isGrouped = $derived($topologyOptions.request_options.group_docker_bridges_by_host);

	// Get containerized services - all if grouped, or just the one in edge.target if not
	let containerizedServices = $derived(
		isGrouped
			? $services.filter(
					(s) =>
						s.virtualization &&
						s.virtualization.type === 'Docker' &&
						s.virtualization.details.service_id === containerizingServiceId
				)
			: $services.filter((s) => s.bindings.some((b) => b.interface_id == edge.target))
	);

	// Get all Docker Bridge subnets for those containerized services
	let allDockerSubnets = $derived.by(() => {
		const subnets = new SvelteMap<string, Subnet>(); // Use Map to deduplicate by subnet ID

		for (const service of containerizedServices) {
			for (const binding of service.bindings) {
				// Get interface_id based on binding type
				let ifaceId: string | null = null;
				if (binding.type === 'Interface') {
					ifaceId = binding.interface_id;
				} else if (binding.type === 'Port') {
					ifaceId = binding.interface_id;
				}

				if (!ifaceId) continue;

				const iface = get(getInterfaceFromId(ifaceId));
				if (!iface?.subnet_id) continue;

				const subnet = get(getSubnetFromId(iface.subnet_id));
				if (subnet?.subnet_type === 'DockerBridge') {
					subnets.set(subnet.id, subnet);
				}
			}
		}

		return Array.from(subnets.values());
	});
</script>

<div class="space-y-3">
	{#if $containerizingHost}
		<span class="text-secondary mb-2 block text-sm font-medium">Docker Host</span>
		<div class="card">
			<EntityDisplayWrapper
				context={{}}
				item={$containerizingHost}
				displayComponent={HostDisplay}
			/>
		</div>
	{/if}
	{#if $containerizingService}
		<span class="text-secondary mb-2 block text-sm font-medium">Docker Service</span>
		<div class="card">
			<EntityDisplayWrapper
				context={{ interfaceId: null }}
				item={$containerizingService}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/if}

	<span class="text-secondary mb-2 block text-sm font-medium">
		{isGrouped ? 'Containerized Services' : 'Containerized Service'}
	</span>
	{#each containerizedServices as service (service.id)}
		<div class="card">
			<EntityDisplayWrapper
				context={{ interfaceId: null }}
				item={service}
				displayComponent={ServiceDisplay}
			/>
		</div>
	{/each}

	{#if allDockerSubnets.length > 0}
		<span class="text-secondary mb-2 block text-sm font-medium"
			>Docker Bridge Subnet{allDockerSubnets.length > 1 ? 's' : ''}</span
		>
		{#each allDockerSubnets as subnet (subnet.id)}
			<div class="card">
				<EntityDisplayWrapper context={{}} item={subnet} displayComponent={SubnetDisplay} />
			</div>
		{/each}
	{/if}
</div>
