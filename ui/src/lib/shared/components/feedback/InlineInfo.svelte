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
	borderColor="border-blue-600/30"
	bgColor="bg-blue-900/20"
	textColor="text-info"
/>
