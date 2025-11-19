<script lang="ts">
	import { Star } from 'lucide-svelte';
	import { onMount } from 'svelte';
	import { api } from '$lib/shared/utils/api';
	import { writable } from 'svelte/store';

	interface Props {
		class?: string;
	}

	let { class: className = '' }: Props = $props();

	let stars = writable<number>();
	let loading = $state(true);
	let error = $state(false);

	async function fetchStars() {
		try {
			const response = await api.request<number>('/github-stars', stars, (updated) => updated, {
				method: 'GET'
			});

			console.log(response);

			if (response) {
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

{#if !loading && !error && $stars !== null}
	<a
		href="https://github.com/mayanayza/netvisor"
		target="_blank"
		rel="noopener noreferrer"
		class="inline-flex items-center gap-1.5 rounded-md border border-gray-600 bg-gray-700/50 px-3 py-1.5 text-sm font-medium text-gray-300 transition-colors hover:border-gray-500 hover:bg-gray-700 {className}"
	>
		<Star class="h-4 w-4 fill-yellow-400 text-yellow-400" />
		<span>{formatStars($stars)}</span>
	</a>
{:else if loading}
	<div
		class="inline-flex items-center gap-1.5 rounded-md border border-gray-600 bg-gray-700/50 px-3 py-1.5 text-sm {className}"
	>
		<Star class="h-4 w-4 text-gray-500" />
		<span class="text-gray-500">...</span>
	</div>
{/if}
