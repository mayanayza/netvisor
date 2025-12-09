<!-- T: Item type, C: type of context passed to item -->
<!-- eslint-disable-next-line @typescript-eslint/no-explicit-any -->
<script lang="ts" generics="T, C">
	import Tag from '../../data/Tag.svelte';
	import type { EntityDisplayComponent } from './types';

	export let item: T;
	export let displayComponent: EntityDisplayComponent<T, C>;
	export let context: C;

	$: icon = displayComponent.getIcon?.(item, context);
	$: tags = displayComponent.getTags?.(item, context) || [];
	$: description = displayComponent.getDescription?.(item, context) || '';
</script>

<div class="flex min-w-0 items-center gap-3">
	<!-- Icon -->
	{#if icon}
		<div class="flex h-7 w-7 flex-shrink-0 items-center justify-center">
			<svelte:component
				this={icon}
				class="h-5 w-5 {displayComponent.getIconColor?.(item, context) || 'text-secondary'}"
			/>
		</div>
	{/if}

	<!-- Label and description -->
	<div class="min-w-0 flex-1 overflow-hidden text-left">
		<div class="flex min-w-0 items-center gap-2">
			<span class="text-secondary truncate">{displayComponent.getLabel(item, context)}</span>
			<!-- Tags with horizontal scrolling -->
			{#if tags.length > 0}
				<div class="tags-scroll-container flex-shrink-0">
					<div class="flex gap-1">
						{#each tags as tag, i (`${tag.label}-${i}`)}
							<Tag label={tag.label} color={tag.color} />
						{/each}
					</div>
				</div>
			{/if}
		</div>
		{#if description.length > 0}
			<span class="text-tertiary mt-1 block truncate text-xs">{description}</span>
		{/if}
	</div>
</div>

<style>
	.tags-scroll-container {
		overflow-x: auto;
		overflow-y: hidden;
		scrollbar-width: thin;
		scrollbar-color: #4b5563 transparent;
		/* Hide scrollbar by default, show on hover */
		scrollbar-width: none;
	}

	.tags-scroll-container::-webkit-scrollbar {
		height: 4px;
		display: none;
	}

	.tags-scroll-container:hover {
		scrollbar-width: thin;
	}

	.tags-scroll-container:hover::-webkit-scrollbar {
		display: block;
	}

	.tags-scroll-container::-webkit-scrollbar-track {
		background: transparent;
	}

	.tags-scroll-container::-webkit-scrollbar-thumb {
		background-color: #4b5563;
		border-radius: 2px;
	}

	.tags-scroll-container::-webkit-scrollbar-thumb:hover {
		background-color: #6b7280;
	}

	/* Ensure inner flex container doesn't wrap */
	.tags-scroll-container > div {
		flex-wrap: nowrap;
	}
</style>
