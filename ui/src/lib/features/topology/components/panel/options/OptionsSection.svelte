<script lang="ts">
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import { createEventDispatcher } from 'svelte';

	export let title: string;
	export let description: string = '';
	export let collapsible: boolean = false;
	export let defaultExpanded: boolean = true;

	let expanded = defaultExpanded;
	const dispatch = createEventDispatcher();

	function toggle() {
		if (collapsible) {
			expanded = !expanded;
			dispatch('toggle', expanded);
		}
	}
</script>

<div class="options-section border-t-2 border-gray-700/60 pb-3 pt-3">
	<!-- Header -->
	{#if collapsible}
		<!-- Collapsible header: use <button> for accessibility -->
		<button
			type="button"
			class="flex w-full items-center justify-between text-left focus:outline-none"
			on:click={toggle}
			aria-expanded={expanded}
			aria-controls="section-content"
		>
			<div>
				<h3 class="text-primary text-sm font-semibold">{title}</h3>
				{#if description}
					<p class="text-tertiary mt-0.5 text-xs">{description}</p>
				{/if}
			</div>
			{#if expanded}
				<ChevronDown class="text-secondary h-4 w-4" />
			{:else}
				<ChevronRight class="text-secondary h-4 w-4" />
			{/if}
		</button>
	{:else}
		<!-- Non-collapsible header: simple static div -->
		<div class="flex items-center justify-between">
			<div>
				<h3 class="text-primary text-sm font-semibold">{title}</h3>
				{#if description}
					<p class="text-tertiary mt-0.5 text-xs">{description}</p>
				{/if}
			</div>
		</div>
	{/if}

	<!-- Content -->
	{#if !collapsible || expanded}
		<div id="section-content" class="mt-3 space-y-3">
			<slot />
		</div>
	{/if}
</div>
