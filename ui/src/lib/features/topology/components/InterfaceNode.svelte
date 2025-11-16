<script lang="ts">
	import { Handle, Position, type NodeProps } from '@xyflow/svelte';
	import { getHostFromId, getPortFromId } from '$lib/features/hosts/store';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getServicesForHost } from '$lib/features/services/store';
	import { isContainerSubnet } from '$lib/features/subnets/store';
	import { selectedEdge, selectedNode, topologyOptions } from '../store';
	import type { NodeRenderData } from '../types/base';
	import { get } from 'svelte/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { connectedNodeIds } from '../interactions';

	let { data, width, height }: NodeProps = $props();

	height = height ? height : 0;
	width = width ? width : 0;

	let hostStore = $derived(data.host_id ? getHostFromId(data.host_id as string) : null);
	let host = $derived(hostStore ? $hostStore : null);

	let servicesForHostStore = $derived(
		data.host_id ? getServicesForHost(data.host_id as string) : null
	);
	let servicesForHost = $derived(servicesForHostStore ? $servicesForHostStore : []);

	// Compute nodeData reactively
	let nodeData: NodeRenderData | null = $derived(
		host && data.host_id
			? (() => {
					const iface = host.interfaces.find((i) => i.id === data.interface_id);

					const servicesOnInterface = servicesForHost
						? servicesForHost.filter(
								(s) =>
									s.bindings.some(
										(b) => b.interface_id == null || (iface && b.interface_id == iface.id)
									) &&
									!$topologyOptions.request_options.hide_service_categories.includes(
										serviceDefinitions.getCategory(s.service_definition)
									)
							)
						: [];

					let bodyText: string | null = null;
					let footerText: string | null = null;
					let headerText: string | null = data.header ? (data.header as string) : null;
					let showServices = servicesOnInterface.length != 0;

					if (iface && !get(isContainerSubnet(iface?.subnet_id))) {
						footerText = (iface.name ? iface.name + ': ' : '') + iface.ip_address;
					}

					if (servicesOnInterface.length == 0) {
						bodyText = host.name;
					}

					return {
						footerText,
						services: servicesOnInterface,
						headerText,
						bodyText,
						showServices,
						isVirtualized: host.virtualization !== null,
						interface_id: data.interface_id
					} as NodeRenderData;
				})()
			: null
	);

	let isNodeSelected = $derived($selectedNode?.id === nodeData?.interface_id);

	// Calculate if this node should fade out when another node is selected
	// Calculate if this node should fade out when another node is selected
	let shouldFadeOut = $derived.by(() => {
		if (!$selectedNode && !$selectedEdge) return false;
		if (!nodeData) return false;

		// Check if this node is in the connected set
		return !$connectedNodeIds.has(nodeData.interface_id);
	});

	let nodeOpacity = $derived(shouldFadeOut ? 0.3 : 1);

	const hostColorHelper = entities.getColorHelper('Host');
	const virtualizationColorHelper = entities.getColorHelper('Virtualization');

	let cardClass = $derived(
		`card ${isNodeSelected ? 'ring-2 ring-blue-500 hover:ring-2 hover:ring-blue-500' : ''} ${nodeData?.isVirtualized ? `border-color: ${virtualizationColorHelper.border}` : ''}`
	);
</script>

{#if nodeData}
	<div
		class={cardClass}
		style={`width: ${width}px; height: ${height}px; display: flex; flex-direction: column; padding: 0; opacity: ${nodeOpacity}; transition: opacity 0.2s ease-in-out;`}
	>
		<!-- Rest of component stays the same -->
		<!-- Header section with gradient transition to body -->
		{#if nodeData.headerText}
			<div class="relative flex-shrink-0 px-2 pt-2 text-center">
				<div
					class={`truncate text-xs font-medium leading-none ${nodeData.isVirtualized ? virtualizationColorHelper.text : 'text-tertiary'}`}
				>
					{nodeData.headerText}
				</div>
			</div>
		{/if}

		<!-- Body section -->
		<div
			class="flex flex-col items-center justify-around px-3 py-2"
			style="flex: 1 1 0; min-height: 0;"
		>
			{#if nodeData.showServices}
				<!-- Show services list -->
				<div
					class="flex w-full flex-1 flex-col items-center justify-evenly"
					style="min-width: 0; max-width: 100%;"
				>
					{#each nodeData.services as service (service.id)}
						{@const ServiceIcon = serviceDefinitions.getIconComponent(service.service_definition)}
						<div
							class="flex flex-1 flex-col items-center justify-center"
							style="min-width: 0; max-width: 100%; width: 100%;"
						>
							<div
								class="flex items-center justify-center gap-1"
								style="line-height: 1.3; width: 100%; min-width: 0; max-width: 100%;"
								title={service.name}
							>
								<ServiceIcon class="h-5 w-5 flex-shrink-0 {hostColorHelper.icon}" />
								<span class="text-m text-secondary truncate">
									{service.name}
								</span>
							</div>
							{#if !$topologyOptions.request_options.hide_ports && service.bindings.filter((b) => b.type == 'Port').length > 0}
								<span class="text-tertiary mt-1 text-xs"
									>{service.bindings
										.map((b) => {
											if (
												(b.interface_id == nodeData.interface_id || b.interface_id == null) &&
												b.type == 'Port'
											) {
												const port = get(getPortFromId(b.port_id));
												if (port) {
													return formatPort(port);
												}
											}
										})
										.filter((p) => {
											return p !== undefined;
										})
										.join(', ')}</span
								>
							{/if}
						</div>
					{/each}
				</div>
			{:else}
				<!-- Show host name as body text -->
				<div
					class="text-secondary truncate text-center text-xs leading-none"
					title={nodeData.bodyText}
				>
					{nodeData.bodyText}
				</div>
			{/if}
		</div>

		<!-- Footer section -->
		{#if nodeData.footerText}
			<div class="relative flex flex-shrink-0 items-center justify-center px-2 pb-2">
				<div class="text-tertiary truncate text-xs font-medium leading-none">
					{nodeData.footerText}
				</div>
			</div>
		{/if}
	</div>
{/if}

<Handle type="target" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="target" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="target" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="target" id="Left" position={Position.Left} style="opacity: 0" />

<Handle type="source" id="Top" position={Position.Top} style="opacity: 0" />
<Handle type="source" id="Right" position={Position.Right} style="opacity: 0" />
<Handle type="source" id="Bottom" position={Position.Bottom} style="opacity: 0" />
<Handle type="source" id="Left" position={Position.Left} style="opacity: 0" />
