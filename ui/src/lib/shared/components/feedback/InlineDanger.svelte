<script lang="ts">
	import { AlertTriangle } from 'lucide-svelte';

	export let title: string = 'Error';
	export let body: string | null = null;
</script>

<div class="rounded-lg border border-red-600/30 bg-red-900/20 p-4">
	<div class="flex items-start gap-2">
		<AlertTriangle class="text-danger mt-0.5 h-4 w-4 shrink-0" />
		<div>
			<p class="text-danger text-sm font-medium">{title}</p>
			{#if body}
				<p class="text-danger mt-1 text-sm">{body}</p>
			{/if}
		</div>
	</div>
</div>
