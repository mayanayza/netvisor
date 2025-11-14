<script lang="ts">
	import { createColorHelper, AVAILABLE_COLORS } from '$lib/shared/utils/styling';
	import type { Group } from '../../types/base';
	import { Edit } from 'lucide-svelte';

	export let formData: Group;
	export let collapsed: boolean = false;

	const edgeStyleOptions: Array<{
		value: 'Straight' | 'SmoothStep' | 'Step' | 'Bezier' | 'SimpleBezier';
		label: string;
	}> = [
		{ value: 'Straight', label: 'Straight' },
		{ value: 'SmoothStep', label: 'Smooth Step' },
		{ value: 'Step', label: 'Step' },
		{ value: 'Bezier', label: 'Bezier' },
		{ value: 'SimpleBezier', label: 'Simple Bezier' }
	];

	// Ensure formData has default values if not set
	$: if (!formData.color) {
		formData.color = 'blue';
	}
	$: if (!formData.edge_style) {
		formData.edge_style = 'SmoothStep';
	}

	$: selectedColorHelper = createColorHelper(formData.color);
	$: selectedEdgeStyleLabel =
		edgeStyleOptions.find((opt) => opt.value === formData.edge_style)?.label || 'Smooth Step';
</script>

{#if collapsed}
	<!-- Collapsed view -->
	<div class="flex items-center justify-between gap-3">
		<div class="flex items-center gap-3">
			<!-- Color indicator -->
			<div
				class="h-8 w-8 rounded-lg border-2 border-white ring-2 ring-white ring-offset-2 ring-offset-gray-800"
				style="background-color: {selectedColorHelper.rgb};"
				aria-label="Selected color: {formData.color}"
			></div>

			<!-- Edge style label -->
			<div class="flex flex-col">
				<span class="text-sm font-medium text-gray-200">{selectedEdgeStyleLabel}</span>
				<span class="text-xs capitalize text-gray-400">{formData.color}</span>
			</div>
		</div>

		<!-- Edit button -->
		<button
			type="button"
			onclick={() => (collapsed = false)}
			class="btn-icon"
			aria-label="Edit edge style"
		>
			<Edit size={16} />
		</button>
	</div>
{:else}
	<!-- Expanded view -->
	<div class="space-y-6">
		<!-- Header with collapse button -->
		<div class="flex items-center justify-between">
			<div class="block text-sm font-medium text-gray-200">Edit Edge Style</div>
			<button type="button" onclick={() => (collapsed = true)} class="btn-secondary text-xs">
				Done
			</button>
		</div>

		<!-- Edge Color Section -->
		<div class="space-y-3">
			<div class="block text-sm font-medium text-gray-200">Edge Color</div>
			<p class="text-xs text-gray-400">Choose the color for edges in this group</p>

			<div class="grid grid-cols-7 gap-2">
				{#each AVAILABLE_COLORS as color (color)}
					{@const colorHelper = createColorHelper(color)}
					<button
						type="button"
						onclick={() => (formData.color = color)}
						class="group relative aspect-square w-full rounded-lg border-2 transition-all hover:scale-110"
						class:border-gray-500={formData.color !== color}
						class:border-white={formData.color === color}
						class:ring-2={formData.color === color}
						class:ring-white={formData.color === color}
						class:ring-offset-2={formData.color === color}
						class:ring-offset-gray-800={formData.color === color}
						style="background-color: {colorHelper.rgb};"
						aria-label={`Select ${color} color`}
					>
						{#if formData.color === color}
							<div class="absolute inset-0 flex items-center justify-center">
								<svg
									class="h-5 w-5 text-white drop-shadow-lg"
									fill="currentColor"
									viewBox="0 0 20 20"
								>
									<path
										fill-rule="evenodd"
										d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
										clip-rule="evenodd"
									/>
								</svg>
							</div>
						{/if}
					</button>
				{/each}
			</div>
		</div>

		<!-- Edge Style Section -->
		<div class="space-y-3">
			<div class="block text-sm font-medium text-gray-200">Edge Style</div>
			<p class="text-xs text-gray-400">Choose how edges are drawn between services</p>

			<div class="space-y-2">
				{#each edgeStyleOptions as option (option.value)}
					<button
						type="button"
						onclick={() => (formData.edge_style = option.value)}
						class="flex w-full items-center gap-3 rounded-lg border px-4 py-3 text-left transition-all hover:bg-gray-700/30"
						class:border-gray-600={formData.edge_style !== option.value}
						class:bg-gray-700-20={formData.edge_style !== option.value}
						class:border-blue-500={formData.edge_style === option.value}
						class:bg-blue-900-20={formData.edge_style === option.value}
						class:ring-1={formData.edge_style === option.value}
						class:ring-blue-500={formData.edge_style === option.value}
					>
						<div
							class="flex h-5 w-5 items-center justify-center rounded-full border-2 transition-all"
							class:border-gray-500={formData.edge_style !== option.value}
							class:border-blue-500={formData.edge_style === option.value}
							class:bg-blue-500={formData.edge_style === option.value}
						>
							{#if formData.edge_style === option.value}
								<div class="h-2 w-2 rounded-full bg-white"></div>
							{/if}
						</div>
						<span
							class="text-sm font-medium transition-colors"
							class:text-gray-300={formData.edge_style !== option.value}
							class:text-blue-400={formData.edge_style === option.value}
						>
							{option.label}
						</span>
					</button>
				{/each}
			</div>
		</div>
	</div>
{/if}
