<script lang="ts">
	import { Info } from 'lucide-svelte';

	export let title: string = 'Information';
	export let body: string | null = null;
</script>

<div class="rounded-lg border border-blue-600/30 bg-blue-900/20 p-4">
	<div class="flex items-start gap-2">
		<Info class="text-info mt-0.5 h-4 w-4 shrink-0" />
		<div>
			<p class="text-info text-sm font-medium">{title}</p>
			{#if body}
				<p class="text-info mt-1 text-sm">{body}</p>
			{/if}
		</div>
	</div>
</div>
