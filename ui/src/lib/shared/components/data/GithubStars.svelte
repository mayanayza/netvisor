<script lang="ts">
	import { Star, Github } from 'lucide-svelte';
	import { onMount } from 'svelte';
	import { apiClient } from '$lib/api/client';

	interface Props {
		class?: string;
	}

	let { class: className = '' }: Props = $props();

	let stars = $state<number | undefined>(undefined);
	let loading = $state(true);
	let error = $state(false);

	async function fetchStars() {
		try {
			const { data } = await apiClient.GET('/api/github-stars', {});
			if (data?.success && typeof data.data === 'number') {
				stars = data.data;
				error = false;
			} else {
				error = true;
			}
		} catch (err) {
			console.error('Error fetching GitHub stars:', err);
			error = true;
		} finally {
			loading = false;
		}
	}

	onMount(() => {
		fetchStars();
	});

	function formatStars(count: number): string {
		if (count >= 1000) {
			return `${(count / 1000).toFixed(1)}k`;
		}
		return count.toString();
	}
</script>

{#if !loading && !error && stars != null && stars != undefined}
	<a
		href="https://github.com/scanopy/scanopy"
		target="_blank"
		rel="noopener noreferrer"
		class="card inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm text-gray-300 transition-all hover:border-gray-600 hover:bg-gray-700/80 {className}"
	>
		<Github class="h-4 w-4" />
		<span class="flex items-center gap-1">
			<Star class="h-3.5 w-3.5 fill-yellow-400 text-yellow-400" />
			<span>{formatStars(stars)}</span>
		</span>
	</a>
{:else if loading}
	<div
		class="card inline-flex items-center gap-2 rounded-full px-4 py-2 text-sm text-gray-400 {className}"
	>
		<Github class="h-4 w-4" />
		<span class="flex items-center gap-1">
			<Star class="h-3.5 w-3.5" />
			<span>...</span>
		</span>
	</div>
{/if}
