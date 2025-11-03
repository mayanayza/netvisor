<script lang="ts">
	import type { Group } from '$lib/features/groups/types/base';
	import type { Subnet } from '$lib/features/subnets/types/base';
	import type { Host } from '$lib/features/hosts/types/base';
	import { formatId, formatTimestamp } from '$lib/shared/utils/formatting';
	import { Calendar, Clock, Hash } from 'lucide-svelte';
	import type { Service } from '$lib/features/services/types/base';
	import { pushWarning } from '$lib/shared/stores/feedback';
	import CodeContainer from '../data/CodeContainer.svelte';
	import type { Network } from '$lib/features/networks/types';
	import type { Discovery } from '$lib/features/discovery/types/base';

	export let entities: (Group | Host | Subnet | Service | Network | Discovery | null)[] = [null];
	export let showSummary: boolean = true;

	let id = entities.length == 1 ? entities[0]?.id : null;
	let createdAt = entities.length == 1 ? entities[0]?.created_at : null;
	let updatedAt = entities.length == 1 ? entities[0]?.updated_at : null;

	const isSecureContext =
		window.isSecureContext ||
		window.location.hostname === 'localhost' ||
		window.location.hostname === '127.0.0.1';

	// Copy ID to clipboard
	async function copyId() {
		if (id) {
			try {
				await navigator.clipboard.writeText(id);
			} catch (error) {
				pushWarning('Failed to copy ID to clipboard: ' + error);
			}
		}
	}
</script>

<div class="border-t border-gray-700 pt-6">
	<div class="rounded-lg bg-gray-800/50 p-4">
		{#if showSummary && (id || createdAt || updatedAt)}
			<div class="mb-6 grid grid-cols-1 gap-4 border-b border-gray-700 pb-4 md:grid-cols-3">
				<!-- ID -->
				{#if id}
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<Hash class="text-tertiary h-5 w-5" />
						</div>
						{#if isSecureContext}
							<div class="min-w-0 flex-1">
								<p class="text-secondary text-sm font-medium">ID</p>
								<button
									type="button"
									class="text-tertiary hover:text-primary block max-w-full cursor-pointer truncate font-mono text-sm transition-colors"
									title={`${id} (Click to copy)`}
									on:click={copyId}
								>
									{formatId(id)}
								</button>
							</div>
						{/if}
					</div>
				{/if}

				{#if createdAt}
					<!-- Created -->
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<Calendar class="text-tertiary h-5 w-5" />
						</div>
						<div class="min-w-0 flex-1">
							<p class="text-secondary text-sm font-medium">Created</p>
							<p class="text-tertiary text-sm" title={createdAt}>
								{formatTimestamp(createdAt)}
							</p>
						</div>
					</div>
				{/if}

				{#if updatedAt}
					<!-- Updated -->
					<div class="flex items-center space-x-3">
						<div class="flex-shrink-0">
							<Clock class="text-tertiary h-5 w-5" />
						</div>
						<div class="min-w-0 flex-1">
							<p class="text-secondary text-sm font-medium">Updated</p>
							<p class="text-tertiary text-sm" title={updatedAt}>
								{formatTimestamp(updatedAt)}
							</p>
						</div>
					</div>
				{/if}
			</div>
		{/if}

		<!-- JSON Entity Section -->
		{#if entities.length > 0}
			<CodeContainer expandable={true} expanded={false} code={JSON.stringify(entities, null, 2)} />
		{/if}
	</div>
</div>
