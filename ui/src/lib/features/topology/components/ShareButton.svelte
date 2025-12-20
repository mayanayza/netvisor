<script lang="ts">
	import { Share2 } from 'lucide-svelte';

	export let onclick: () => void;
</script>

<button class="btn-secondary" on:click={onclick}>
	<Share2 class="h-5 w-5" /> Share
</button>
