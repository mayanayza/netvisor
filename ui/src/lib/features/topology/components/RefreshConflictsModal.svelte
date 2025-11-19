<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { AlertTriangle, Lock, RefreshCcw } from 'lucide-svelte';
	import type { Topology } from '../types/base';

	export let isOpen: boolean;
	export let topology: Topology;
	export let onConfirm: () => void;
	export let onLock: () => void;
	export let onCancel: () => void;

	// Get removed entity details
	$: removedHosts = topology.removed_hosts
		.map((id) => topology.hosts.find((h) => h.id === id))
		.filter((h) => h != undefined);

	$: removedServices = topology.removed_services
		.map((id) => topology.services.find((s) => s.id === id))
		.filter((s) => s != undefined);

	$: removedSubnets = topology.removed_subnets
		.map((id) => topology.subnets.find((s) => s.id === id))
		.filter((s) => s != undefined);

	$: removedGroups = topology.removed_groups
		.map((id) => topology.groups.find((g) => g.id === id))
		.filter((g) => g != undefined);

	$: totalRemoved =
		removedHosts.length + removedServices.length + removedSubnets.length + removedGroups.length;
</script>

<GenericModal {isOpen} onClose={onCancel} title="Review Refresh Conflicts" size="lg">
	<svelte:fragment slot="header-icon">
		<AlertTriangle class="h-6 w-6 text-red-600 dark:text-red-400" />
	</svelte:fragment>

	<div class="space-y-4">
		<!-- Warning header -->
		<div
			class="flex items-start gap-3 rounded-lg border border-red-200 bg-red-50 p-4 dark:border-red-800 dark:bg-red-950"
		>
			<AlertTriangle class="mt-0.5 h-5 w-5 flex-shrink-0 text-red-600 dark:text-red-400" />
			<div>
				<h3 class="font-medium text-red-900 dark:text-red-100">
					{totalRemoved}
					{totalRemoved === 1 ? 'entity' : 'entities'} will be removed
				</h3>
				<p class="mt-1 text-sm text-red-700 dark:text-red-300">
					These entities no longer exist in the network and will be removed from this diagram if you
					refresh.
				</p>
			</div>
		</div>

		<!-- List removed entities -->
		<div class="space-y-3">
			{#if removedHosts.length > 0}
				<div>
					<h4 class="mb-2 font-medium text-gray-900 dark:text-gray-100">
						Hosts ({removedHosts.length})
					</h4>
					<ul
						class="space-y-1 rounded-lg border border-gray-200 bg-gray-50 p-3 dark:border-gray-700 dark:bg-gray-900"
					>
						{#each removedHosts as host (host.id)}
							<li class="text-sm text-gray-700 dark:text-gray-300">• {host.name}</li>
						{/each}
					</ul>
				</div>
			{/if}

			{#if removedServices.length > 0}
				<div>
					<h4 class="mb-2 font-medium text-gray-900 dark:text-gray-100">
						Services ({removedServices.length})
					</h4>
					<ul
						class="space-y-1 rounded-lg border border-gray-200 bg-gray-50 p-3 dark:border-gray-700 dark:bg-gray-900"
					>
						{#each removedServices as service (service.id)}
							<li class="text-sm text-gray-700 dark:text-gray-300">• {service.name}</li>
						{/each}
					</ul>
				</div>
			{/if}

			{#if removedSubnets.length > 0}
				<div>
					<h4 class="mb-2 font-medium text-gray-900 dark:text-gray-100">
						Subnets ({removedSubnets.length})
					</h4>
					<ul
						class="space-y-1 rounded-lg border border-gray-200 bg-gray-50 p-3 dark:border-gray-700 dark:bg-gray-900"
					>
						{#each removedSubnets as subnet (subnet.id)}
							<li class="text-sm text-gray-700 dark:text-gray-300">• {subnet.name}</li>
						{/each}
					</ul>
				</div>
			{/if}

			{#if removedGroups.length > 0}
				<div>
					<h4 class="mb-2 font-medium text-gray-900 dark:text-gray-100">
						Groups ({removedGroups.length})
					</h4>
					<ul
						class="space-y-1 rounded-lg border border-gray-200 bg-gray-50 p-3 dark:border-gray-700 dark:bg-gray-900"
					>
						{#each removedGroups as group (group.id)}
							<li class="text-sm text-gray-700 dark:text-gray-300">• {group.name}</li>
						{/each}
					</ul>
				</div>
			{/if}
		</div>

		<!-- Info box -->
		<div
			class="rounded-lg border border-blue-200 bg-blue-50 p-3 dark:border-blue-800 dark:bg-blue-950"
		>
			<p class="text-sm text-blue-700 dark:text-blue-300">
				<strong>Tip:</strong> If you want to preserve this network state as a historical record, click
				"Lock Instead" to freeze this topology without refreshing.
			</p>
		</div>
	</div>

	<svelte:fragment slot="footer">
		<div class="flex w-full items-center justify-between">
			<button class="btn-secondary" on:click={onCancel}> Cancel </button>
			<div class="flex gap-3">
				<button class="btn-primary flex items-center gap-2" on:click={onLock}>
					<Lock class="h-4 w-4" />
					Lock Instead
				</button>
				<button class="btn-danger flex items-center gap-2" on:click={onConfirm}>
					<RefreshCcw class="h-4 w-4" />
					Refresh Anyway
				</button>
			</div>
		</div>
	</svelte:fragment>
</GenericModal>
