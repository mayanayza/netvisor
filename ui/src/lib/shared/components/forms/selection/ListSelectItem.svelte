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

<div class="flex min-w-0 flex-1 items-center gap-3">
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
	<div class="min-w-0 flex-1 text-left">
		<div class="flex items-center gap-3">
			<span class="text-secondary block truncate">{displayComponent.getLabel(item, context)}</span>
			<!-- Tags -->
			{#if tags.length > 0}
				<div class="flex gap-1">
					{#each tags as tag, i (`${tag.label}-${i}`)}
						<Tag label={tag.label} color={tag.color} />
					{/each}
				</div>
			{/if}
		</div>
		{#if description.length > 0}
			<span class="text-tertiary mt-2 block truncate text-xs">{description}</span>
		{/if}
	</div>
</div>
