<script lang="ts">
	import { Info } from 'lucide-svelte';
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
	Icon={Info}
	borderColor="border-green-600/30"
	bgColor="bg-green-900/20"
	textColor="text-success"
/>
