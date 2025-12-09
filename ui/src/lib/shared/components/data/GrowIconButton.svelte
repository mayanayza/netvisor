<script lang="ts">
	import type { CardAction } from './types';

	let {
		action,
		isRightEdge = false,
		isLeftEdge = false
	}: {
		action: CardAction;
		isRightEdge?: boolean;
		isLeftEdge?: boolean;
	} = $props();

	let cls = $derived(action.class ? action.class : 'btn-icon');
</script>

<button
	onclick={action.onClick}
	disabled={action.disabled}
	class="group relative overflow-visible transition-all duration-200 ease-in-out {cls} {action.animation ||
		''}"
	title={action.label}
>
	<div class="flex items-center justify-center">
		<action.icon size={16} class="flex-shrink-0" />
	</div>

	<div
		class="absolute top-1/2 flex -translate-y-1/2 items-center justify-center whitespace-nowrap {action.disabled
			? 'opacity-0'
			: 'opacity-0 transition-all duration-200 ease-in-out group-hover:opacity-100'} {isLeftEdge
			? 'left-0'
			: isRightEdge
				? 'right-0'
				: 'left-1/2 -translate-x-1/2'} {cls}"
	>
		<action.icon size={16} class="flex-shrink-0" />
		<span class="ml-2">{action.label}</span>
	</div>
</button>
