<script lang="ts">
	import type { IconComponent } from '$lib/shared/utils/types';

	let {
		Icon,
		label,
		color,
		onClick = null
	}: {
		Icon: IconComponent;
		label: string;
		color: 'blue' | 'green' | 'yellow' | 'red';
		onClick?: (() => void) | null;
	} = $props();

	// Map colors to existing button classes
	const buttonClassMap = {
		blue: 'btn-info',
		green: 'btn-success',
		yellow: 'btn-warning',
		red: 'btn-danger'
	};

	const buttonClass = $derived(buttonClassMap[color]);
</script>

{#if onClick}
	<button type="button" onclick={onClick} class={buttonClass}>
		<Icon class="h-4 w-4" />
		<span>{label}</span>
	</button>
{:else}
	<div class={buttonClass}>
		<Icon class="h-4 w-4" />
		<span>{label}</span>
	</div>
{/if}
