<script lang="ts">
	import { AlertTriangle } from 'lucide-svelte';
	import BaseInlineFeedback from './BaseInlineFeedback.svelte';

	let {
		title = 'Error',
		body = null,
		dismissableKey = null
	}: {
		title?: string;
		body?: string | null;
		dismissableKey?: string | null;
	} = $props();
</script>

<BaseInlineFeedback
	{title}
	{body}
	{dismissableKey}
	Icon={AlertTriangle}
	borderColor="border-yellow-600/30"
	bgColor="bg-yellow-900/20"
	textColor="text-warning"
/>
