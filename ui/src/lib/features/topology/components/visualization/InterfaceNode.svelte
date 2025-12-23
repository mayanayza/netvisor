<script lang="ts">
	import { Handle, Position, type NodeProps } from '@xyflow/svelte';
	import { concepts, entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import {
		selectedEdge,
		selectedNode,
		topology as globalTopology,
		topologyOptions
	} from '../../store';
	import type {
		InterfaceNode as InterfaceNodeType,
		NodeRenderData,
		Topology
	} from '../../types/base';
	import type { Writable } from 'svelte/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { connectedNodeIds } from '../../interactions';
	import { getContext } from 'svelte';
	import type { Port } from '$lib/features/hosts/types/base';

	let { id, data, width, height }: NodeProps = $props();

	// Try to get topology from context (for share/embed pages), fallback to global store
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	let topology = $derived(topologyContext ? $topologyContext : $globalTopology);

	let nodeData = data as InterfaceNodeType;

	height = height ? height : 0;
	width = width ? width : 0;

	let host = $derived(topology ? topology.hosts.find((h) => h.id == nodeData.host_id) : undefined);

	let servicesForHost = $derived(
		topology ? topology.services.filter((s) => s.host_id == nodeData.host_id) : []
	);

	// Get the interface for this node
	let iface = $derived(host ? host.interfaces.find((i) => i.id === data.interface_id) : null);

	// Reactively subscribe to the container subnet store
	let isContainerSubnetValue = $derived(
		iface ? topology?.subnets.find((s) => s.id == iface.subnet_id)?.cidr == '0.0.0.0/0' : false
	);

	// Look up port from topology hosts (works for both main app and share pages)
	function getPortById(portId: string): Port | null {
		if (!topology) return null;
		for (const h of topology.hosts) {
			const port = h.ports.find((p) => p.id === portId);
			if (port) return port;
		}
		return null;
	}

	// Compute nodeRenderData reactively
	let nodeRenderData: NodeRenderData | null = $derived(
		host && data.host_id
			? (() => {
					const servicesOnInterface = servicesForHost
						? servicesForHost.filter((s) =>
								s.bindings.some(
									(b) => b.interface_id == null || (iface && b.interface_id == iface.id)
								)
							)
						: [];

					let bodyText: string | null = null;
					let footerText: string | null = null;
					let headerText: string | null = data.header ? (data.header as string) : null;
					let showServices = servicesOnInterface.length != 0;

					if (iface && !isContainerSubnetValue) {
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

	let isNodeSelected = $derived($selectedNode?.id === nodeRenderData?.interface_id);

	// Calculate if this node should fade out when another node is selected
	let shouldFadeOut = $derived.by(() => {
		if (!$selectedNode && !$selectedEdge) return false;
		if (!nodeRenderData) return false;

		// Check if this node is in the connected set
		return !$connectedNodeIds.has(nodeRenderData.interface_id);
	});

	let nodeOpacity = $derived(shouldFadeOut ? 0.3 : 1);

	const hostColorHelper = entities.getColorHelper('Host');
	const virtualizationColorHelper = concepts.getColorHelper('Virtualization');

	let cardClass = $derived(
		`card ${isNodeSelected ? 'ring-2 ring-blue-500 hover:ring-2 hover:ring-blue-500' : ''} ${nodeRenderData?.isVirtualized ? `border-color: ${virtualizationColorHelper.border}` : ''}`
	);

	let handleStyle = $derived.by(() => {
		const baseSize = 8;
		const baseOpacity = $selectedEdge?.source == id || $selectedEdge?.target == id ? 1 : 0;

		// Use host color or virtualization color
		const fillColor = nodeRenderData?.isVirtualized
			? virtualizationColorHelper.rgb
			: hostColorHelper.rgb;

		return `
			width: ${baseSize}px;
			height: ${baseSize}px;
			border: 2px solid #374151;
			background-color: ${fillColor};
			opacity: ${baseOpacity};
			transition: opacity 0.2s ease-in-out;
		`;
	});
</script>

{#if nodeRenderData}
	<div
		class={cardClass}
		style={`width: ${width}px; height: ${height}px; display: flex; flex-direction: column; padding: 0; opacity: ${nodeOpacity}; transition: opacity 0.2s ease-in-out;`}
	>
		<!-- Rest of component stays the same -->
		<!-- Header section with gradient transition to body -->
		{#if nodeRenderData.headerText}
			<div class="relative flex-shrink-0 px-2 pt-2 text-center">
				<div
					class={`truncate text-xs font-medium leading-none ${nodeRenderData.isVirtualized ? virtualizationColorHelper.text : 'text-tertiary'}`}
				>
					{nodeRenderData.headerText}
				</div>
			</div>
		{/if}

		<!-- Body section -->
		<div
			class="flex flex-col items-center justify-around px-3 py-2"
			style="flex: 1 1 0; min-height: 0;"
		>
			{#if nodeRenderData.showServices}
				<!-- Show services list -->
				<div
					class="flex w-full flex-1 flex-col items-center justify-evenly"
					style="min-width: 0; max-width: 100%;"
				>
					{#each nodeRenderData.services as service (service.id)}
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
							{#if !$topologyOptions.request.hide_ports && service.bindings.filter((b) => b.type == 'Port').length > 0}
								<span class="text-tertiary mt-1 text-center text-xs"
									>{service.bindings
										.map((b) => {
											if (
												(b.interface_id == nodeRenderData.interface_id || b.interface_id == null) &&
												b.type == 'Port' &&
												b.port_id
											) {
												const port = getPortById(b.port_id);
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
					title={nodeRenderData.bodyText}
				>
					{nodeRenderData.bodyText}
				</div>
			{/if}
		</div>

		<!-- Footer section -->
		{#if nodeRenderData.footerText}
			<div class="relative flex flex-shrink-0 items-center justify-center px-2 pb-2">
				<div class="text-tertiary truncate text-xs font-medium leading-none">
					{nodeRenderData.footerText}
				</div>
			</div>
		{/if}
	</div>
{/if}

<Handle type="target" id="Top" position={Position.Top} style={handleStyle} />
<Handle type="target" id="Right" position={Position.Right} style={handleStyle} />
<Handle type="target" id="Bottom" position={Position.Bottom} style={handleStyle} />
<Handle type="target" id="Left" position={Position.Left} style={handleStyle} />

<Handle type="source" id="Top" position={Position.Top} style={handleStyle} />
<Handle type="source" id="Right" position={Position.Right} style={handleStyle} />
<Handle type="source" id="Bottom" position={Position.Bottom} style={handleStyle} />
<Handle type="source" id="Left" position={Position.Left} style={handleStyle} />
