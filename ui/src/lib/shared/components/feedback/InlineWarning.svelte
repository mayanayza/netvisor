<script lang="ts">
	import { AlertTriangle } from 'lucide-svelte';

	export let title: string = 'Warning';
	export let body: string | null = null;
</script>

<div class="rounded-lg border border-yellow-600/30 bg-yellow-900/20 p-4">
	<div class="flex items-start gap-2">
		<AlertTriangle class="mt-0.5 h-4 w-4 shrink-0 text-warning" />
		<div>
			<p class="text-sm font-medium text-warning">{title}</p>
			{#if body}
				<p class="mt-1 text-sm text-warning">{body}</p>
			{/if}
		</div>
	</div>
</div>
