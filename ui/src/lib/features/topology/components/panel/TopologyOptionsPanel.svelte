<script lang="ts">
	import { optionsPanelExpanded, selectedNode, selectedEdge } from '../../store';
	import { ChevronLeft, ChevronRight, Settings, Info } from 'lucide-svelte';
	import OptionsContent from './options/OptionsContent.svelte';
	import InspectorNode from './inspectors/InspectorNode.svelte';
	import InspectorEdge from './inspectors/InspectorEdge.svelte';

	// Add tab state
	let activeTab: 'options' | 'inspector' = $state('options');

	// Automatically switch to inspector when something is selected
	$effect(() => {
		if ($selectedNode || $selectedEdge) {
			activeTab = 'inspector';
		}
	});
</script>

<!-- Floating Panel -->
<div
	class="topology-options absolute left-4 top-4 z-10 duration-300 {$optionsPanelExpanded
		? 'w-96'
		: 'w-auto'}"
>
	<div class="card p-0 shadow-lg">
		{#if $optionsPanelExpanded}
			<!-- Header with tabs and collapse button -->
			<div class="flex items-center border-b border-gray-700">
				<!-- Collapse button -->
				<button
					class="btn-icon rounded-xl p-3"
					onclick={() => optionsPanelExpanded.set(false)}
					aria-label="Collapse panel"
				>
					<ChevronLeft class="text-secondary h-5 w-5" />
				</button>
				<!-- Tab buttons -->
				<button
					class="flex-1 px-4 py-3 text-sm font-medium transition-colors {activeTab === 'options'
						? 'text-primary border-b-2 border-blue-500'
						: 'text-secondary hover:text-primary'}"
					onclick={() => (activeTab = 'options')}
				>
					<Settings class="mr-1 inline h-4 w-4" />
					Options
				</button>
				<button
					class="flex-1 px-4 py-3 text-sm font-medium transition-colors {activeTab === 'inspector'
						? 'text-primary border-b-2 border-blue-500'
						: 'text-secondary hover:text-primary'}"
					onclick={() => (activeTab = 'inspector')}
				>
					<Info class="mr-1 inline h-4 w-4" />
					Inspector
				</button>
			</div>

			<!-- Tab content -->
			<div class="overflow-y-auto p-3" style="max-height: calc(100vh - 250px);">
				{#if activeTab === 'options'}
					<OptionsContent />
				{:else if activeTab === 'inspector'}
					{#if $selectedNode}
						<InspectorNode node={$selectedNode} />
					{:else if $selectedEdge}
						<InspectorEdge edge={$selectedEdge} />
					{:else}
						<div class="text-tertiary py-8 text-center text-sm">
							Click on a node or edge to inspect it
						</div>
					{/if}
				{/if}
			</div>
		{:else}
			<!-- Collapsed toggle button - just the chevron -->
			<button
				class="btn-icon rounded-2xl p-3"
				onclick={() => optionsPanelExpanded.set(true)}
				aria-label="Expand panel"
			>
				<ChevronRight class="text-secondary h-5 w-5" />
			</button>
		{/if}
	</div>
</div>
