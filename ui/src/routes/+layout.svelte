<script lang="ts">
	import { onMount } from 'svelte';
	import type { Snippet } from 'svelte';
	import { QueryClientProvider } from '@tanstack/svelte-query';
	import { queryClient } from '$lib/api/query-client';
	import { getConfig } from '$lib/shared/stores/config';
	import AppShell from '$lib/shared/components/layout/AppShell.svelte';
	import '../app.css';
	import { VERSION } from '$lib/version';

	let { children }: { children: Snippet } = $props();

	// Load public server config on mount
	onMount(async () => {
		console.log('Scanopy v' + VERSION);
		await getConfig();
	});
</script>

<QueryClientProvider client={queryClient}>
	<AppShell {children} />
</QueryClientProvider>
