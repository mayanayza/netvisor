<script lang="ts">
	import { Handle, NodeResizeControl, Position, useViewport, type NodeProps } from '@xyflow/svelte';
	import { createColorHelper, twColorToRgba } from '$lib/shared/utils/styling';
	import { subnetTypes } from '$lib/shared/stores/metadata';
	import { getSubnetFromId, isContainerSubnet } from '$lib/features/subnets/store';
	import { topologyOptions } from '../store';
	import type { SubnetRenderData } from '../types/base';
	import { get } from 'svelte/store';

	let { id, data, selected, width, height }: NodeProps = $props();

	let leftZoneTitle = $derived($topologyOptions.left_zone_title);
	let infra_width = $derived((data.infra_width as number) || 0);
	let nodeStyle = $derived(`width: ${width}px; height: ${height}px;`);
	let hasInfra = $derived(infra_width > 0);

	let subnetStore = getSubnetFromId(id);
	let subnet = $derived($subnetStore);

	const viewport = useViewport();
	let resizeHandleZoomLevel = $derived(viewport.current.zoom > 0.5);

	const grayColorHelper = createColorHelper('gray');

	let subnetRenderData: SubnetRenderData | null = $derived(
		subnet
			? (() => {
					const subnetColorHelper = subnetTypes.getColorHelper(subnet.subnet_type);
					let IconComponent = subnetTypes.getIconComponent(subnet.subnet_type);
					let cidr = subnet.cidr;

					let label = data.header
						? (data.header as string)
						: (subnet.name != subnet.cidr ? subnet.name : subnetTypes.getName(subnet.subnet_type)) +
							(get(isContainerSubnet(subnet.id)) ? '' : ': ' + subnet.cidr);

					return {
						headerText: label,
						colorHelper: subnetColorHelper,
						cidr,
						IconComponent
					} as SubnetRenderData;
				})()
			: null
	);
</script>

{#if subnetRenderData}
	<div class="relative" style={nodeStyle}>
		<!-- External label in upper left corner -->
		{#if subnetRenderData.cidr || subnetRenderData.headerText}
			<div
				class="card text-secondary z-100 absolute -top-10 left-0 flex items-center gap-1 px-2 py-1 shadow-lg backdrop-blur-sm"
			>
				<!-- Icon -->
				{#if subnetRenderData.IconComponent}
					<!-- eslint-disable-next-line @typescript-eslint/no-explicit-any -->
					<subnetRenderData.IconComponent class={`h-5 w-5 ${subnetRenderData.colorHelper.icon}`} />
				{/if}

				<!-- Label -->
				<span class="text-s text-secondary whitespace-nowrap font-medium">
					{subnetRenderData.headerText || subnetRenderData.cidr}
				</span>
			</div>
		{/if}

		<!-- Main container -->
		<div
			class="rounded-xl text-center text-sm font-semibold shadow-lg transition-all duration-200"
			style="background: #1a1d29; width: 100%; height: 100%; position: relative; overflow: hidden;"
		>
			<!-- Infrastructure background area with gradient centered at infra_width -->
			{#if hasInfra}
				<div
					style={`position: absolute; top: 0; left: 0; width: ${infra_width + 20}px; height: 100%; border-radius: 0.75rem 0 0 0.75rem; pointer-events: none;
						background: linear-gradient(to right, 
							${twColorToRgba(grayColorHelper.bg, 0.2)} 0%, 
							${twColorToRgba(grayColorHelper.bg, 0.2)} ${((infra_width - 20) / (infra_width + 20)) * 100}%, 
							${twColorToRgba(grayColorHelper.bg, 0)} 100%);`}
				>
					<!-- Infrastructure title -->
					<div
						class="text-muted absolute left-1/2 top-0.5 -translate-x-1/2 transform text-[0.5rem] font-semibold"
					>
						{leftZoneTitle}
					</div>
				</div>
			{/if}
		</div>

		{#if resizeHandleZoomLevel && !$topologyOptions.hide_resize_handles}
			<NodeResizeControl
				position="bottom-right"
				style="z-index: 100; border: none; width: 20px; height: 20px;"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					style="position: absolute; right: 10px; bottom: 10px;"
				>
					<path
						d="M20 7.5 L20 20 L7.5 20 Z"
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
						style="transition: fill 200ms ease-in-out;"
					/>
					<line x1="11.667" y1="20" x2="20" y2="11.667" stroke="#374151" stroke-width="1" />
					<line x1="16.333" y1="20" x2="20" y2="16.333" stroke="#374151" stroke-width="1" />
				</svg>
			</NodeResizeControl>

			<NodeResizeControl
				position="top-left"
				style="z-index: 100; border: none; width: 20px; height: 20px;"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					style="position: absolute; left: 10px; top: 10px;"
				>
					<path
						d="M0 12.5 L0 0 L12.5 0 Z"
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
						style="transition: fill 200ms ease-in-out;"
					/>
					<line x1="8.333" y1="0" x2="0" y2="8.333" stroke="#374151" stroke-width="1" />
					<line x1="3.667" y1="0" x2="0" y2="3.667" stroke="#374151" stroke-width="1" />
				</svg>
			</NodeResizeControl>

			<NodeResizeControl
				position="top-right"
				style="z-index: 100; border: none; width: 20px; height: 20px;"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					style="position: absolute; right: 10px; top: 10px;"
				>
					<path
						d="M7.5 0 L20 0 L20 12.5 Z"
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
						style="transition: fill 200ms ease-in-out;"
					/>
					<line x1="11.667" y1="0" x2="20" y2="8.333" stroke="#374151" stroke-width="1" />
					<line x1="16.333" y1="0" x2="20" y2="3.667" stroke="#374151" stroke-width="1" />
				</svg>
			</NodeResizeControl>

			<NodeResizeControl
				position="bottom-left"
				style="z-index: 100; border: none; width: 20px; height: 20px;"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					style="position: absolute; left: 10px; bottom: 10px;"
				>
					<path
						d="M0 7.5 L12.5 20 L0 20 Z"
						fill={selected ? subnetRenderData.colorHelper.rgb : grayColorHelper.rgb}
						style="transition: fill 200ms ease-in-out;"
					/>
					<line x1="0" y1="11.667" x2="8.333" y2="20" stroke="#374151" stroke-width="1" />
					<line x1="0" y1="16.333" x2="3.667" y2="20" stroke="#374151" stroke-width="1" />
				</svg>
			</NodeResizeControl>
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

<style>
	/* Ensure proper text wrapping and overflow handling */
	div {
		word-wrap: break-word;
		overflow-wrap: break-word;
	}

	:global(.svelte-flow__resize-control) {
		background-color: transparent !important;
	}
</style>
