<script lang="ts">
	import {
		matchConfidenceColor,
		type MatchReason,
		type MatchDetails,
		matchConfidenceLabel
	} from '$lib/shared/types';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import Tag from '$lib/shared/components/data/Tag.svelte';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';

	let { details }: { details: MatchDetails } = $props();

	let isExpanded = $state(false);
	let confidenceColor = $derived(matchConfidenceColor(details.confidence));
</script>

{#snippet matchReasonNode(reason: MatchReason)}
	{#if reason.type === 'reason'}
		<div class="text-secondary flex items-start gap-2 py-1 text-sm">
			<span class="text-tertiary select-none">•</span>
			<span>{reason.data}</span>
		</div>
	{:else if reason.type === 'container'}
		{@const label = reason.data[0]}
		{@const children = reason.data[1]}

		<div class="py-1">
			<div class="flex items-start gap-2 px-2 py-1">
				<span class="w-4 flex-shrink-0"></span>
				<span class="text-secondary text-sm font-medium">{label}</span>
			</div>

			{#if children.length > 0}
				<div class="ml-6 mt-1 border-l-2 border-gray-700 pl-4">
					{#each children as child, index (index)}
						{@render matchReasonNode(child)}
					{/each}
				</div>
			{/if}
		</div>
	{/if}
{/snippet}

<div class="space-y-4">
	<button
		type="button"
		onclick={() => (isExpanded = !isExpanded)}
		class="flex w-full items-center justify-between text-left"
	>
		<div class="text-secondary hover:text-info flex items-center gap-2">
			{#if isExpanded}
				<ChevronDown class="h-4 w-4" />
			{:else}
				<ChevronRight class="h-4 w-4" />
			{/if}
			<h3 class="text-sm font-semibold">Match Details</h3>
		</div>
		<Tag label={matchConfidenceLabel(details.confidence)} color={confidenceColor} />
	</button>

	{#if isExpanded}
		<div class="pl-1">
			{@render matchReasonNode(details.reason)}
		</div>
		<CodeContainer
			language="json"
			expandable={false}
			code={JSON.stringify(details.reason, null, 2)}
		/>
	{/if}
</div>
