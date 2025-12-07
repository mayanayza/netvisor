<script lang="ts">
	import { pushSuccess, pushWarning } from '$lib/shared/stores/feedback';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import Prism from '@magidoc/plugin-svelte-prismjs';
	import 'prismjs/components/prism-yaml';
	import 'prismjs/components/prism-json';
	import 'prismjs/components/prism-bash';
	import 'prismjs/themes/prism-twilight.css';

	export let code: string;
	export let expandable: boolean = true;
	export let expanded: boolean = true;
	export let language: string = 'json';
	export let expandLabel: string = 'Expand';

	// Copy JSON to clipboard
	async function copyJson() {
		try {
			await navigator.clipboard.writeText(code);
			pushSuccess('Copied to clipboard!');
		} catch (error) {
			pushWarning('Failed to copy to clipboard: ' + error);
		}
	}

	const isSecureContext =
		window.isSecureContext ||
		window.location.hostname === 'localhost' ||
		window.location.hostname === '127.0.0.1';

	function toggleJson() {
		expanded = !expanded;
	}
</script>

<div>
	{#if expandable}
		<button type="button" class="btn-icon" on:click={toggleJson}>
			{#if expanded}
				<ChevronDown class="h-4 w-4" />
			{:else}
				<ChevronRight class="h-4 w-4" />
			{/if}
			<span class="ml-1">{expandLabel}</span>
		</button>
	{/if}

	{#if expanded}
		<div class="relative">
			{#if isSecureContext}
				<div class="absolute right-2 top-2 z-10">
					<button type="button" class="btn-icon" title="Copy JSON to clipboard" on:click={copyJson}>
						Copy
					</button>
				</div>
			{/if}
			<Prism {language} showCopyButton={false} source={code} showLineNumbers={true} />
		</div>
	{/if}
</div>

<style>
	:global(.prism--code-container) {
		margin: 0 !important;
		border: 2px solid #6b7280 !important;
		/* uses text-muted as color */
	}

	/* Enable text wrapping in code blocks */
	:global(.prism--code-container pre),
	:global(.prism--code-container code) {
		white-space: pre-wrap !important;
		font-size: 0.875rem;
		word-wrap: break-word !important;
		overflow-wrap: break-word !important;
	}
</style>
