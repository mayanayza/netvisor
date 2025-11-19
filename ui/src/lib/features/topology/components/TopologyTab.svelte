<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import TopologyViewer from './visualization/TopologyViewer.svelte';
	import TopologyOptionsPanel from './panel/TopologyOptionsPanel.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { Edit, Lock, LockOpen, Plus, RefreshCcw, Trash2, AlertTriangle } from 'lucide-svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import { getServices } from '$lib/features/services/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import ExportButton from './ExportButton.svelte';
	import { SvelteFlowProvider } from '@xyflow/svelte';
	import { getGroups } from '$lib/features/groups/store';
	import {
		topologies,
		topology,
		getTopologies,
		deleteTopology,
		refreshTopology,
		lockTopology,
		unlockTopology
	} from '../store';
	import type { Topology } from '../types/base';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import TopologyModal from './TopologyModal.svelte';
	import RefreshConflictsModal from './RefreshConflictsModal.svelte';
	import { users } from '$lib/features/users/store';

	let isCreateEditOpen = false;
	let editingTopology: Topology | null = null;

	let isRefreshConflictsOpen = false;

	function handleCreateTopology() {
		isCreateEditOpen = true;
		editingTopology = null;
	}

	function handleEditTopology() {
		isCreateEditOpen = true;
		editingTopology = $topology;
	}

	function onSubmit() {
		isCreateEditOpen = false;
		editingTopology = null;
	}

	function onClose() {
		isCreateEditOpen = false;
		editingTopology = null;
	}

	// Handle topology selection
	function handleTopologyChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedId = target.value;
		const selectedTopology = $topologies.find((t) => t.id === selectedId);
		if (selectedTopology) {
			topology.set(selectedTopology);
		}
	}

	async function handleDelete() {
		if (confirm(`Are you sure you want to delete topology ${$topology.name}?`)) {
			await deleteTopology($topology.id);
			topology.set($topologies[0]);
		}
	}

	async function handleRefresh() {
		if (!$topology) return;

		// Check if there are conflicts
		const hasConflicts =
			$topology.removed_hosts.length > 0 ||
			$topology.removed_services.length > 0 ||
			$topology.removed_subnets.length > 0 ||
			$topology.removed_groups.length > 0;

		if (hasConflicts) {
			// Open modal to review conflicts
			isRefreshConflictsOpen = true;
		} else {
			// Safe to refresh directly
			await refreshTopology($topology);
		}
	}

	async function handleConfirmRefresh() {
		await refreshTopology($topology);
		isRefreshConflictsOpen = false;
	}

	async function handleLockFromConflicts() {
		await lockTopology($topology);
		isRefreshConflictsOpen = false;
	}

	async function handleLock() {
		if (!$topology) return;
		await lockTopology($topology);
	}

	async function handleUnlock() {
		if (!$topology) return;
		await unlockTopology($topology);
	}

	// Compute topology state
	$: topologyState = $topology ? getTopologyState($topology) : null;
	$: lockedByUser = $topology?.locked_by ? $users.find((u) => u.id === $topology.locked_by) : null;

	function getTopologyState(topo: Topology) {
		if (topo.is_locked) {
			return { type: 'locked', color: 'blue', icon: Lock };
		}

		if (!topo.is_stale) {
			return { type: 'fresh', color: 'green', icon: RefreshCcw };
		}

		const hasConflicts =
			topo.removed_hosts.length > 0 ||
			topo.removed_services.length > 0 ||
			topo.removed_subnets.length > 0 ||
			topo.removed_groups.length > 0;

		if (hasConflicts) {
			return { type: 'stale_conflicts', color: 'red', icon: AlertTriangle };
		}

		return { type: 'stale_safe', color: 'yellow', icon: RefreshCcw };
	}

	const loading = loadData([getHosts, getServices, getSubnets, getGroups, getTopologies]);
</script>

<SvelteFlowProvider>
	<div class="space-y-6">
		<!-- Header -->
		<TabHeader title="Topology" subtitle="Generate and view network topology">
			<svelte:fragment slot="actions">
				<div class="flex items-center gap-4">
					<!-- State Badge -->
					{#if $topology && topologyState}
						<div class="flex-shrink-0">
							{#if topologyState.type === 'locked'}
								<div
									class="flex items-center gap-2 rounded-lg border border-blue-600 bg-blue-50 px-3 py-2 text-sm dark:bg-blue-950"
								>
									<Lock class="h-4 w-4 text-blue-600 dark:text-blue-400" />
									<span class="font-medium text-blue-900 dark:text-blue-100">
										Locked {$topology.locked_at
											? new Date($topology.locked_at).toLocaleDateString()
											: ''}
									</span>
								</div>
							{:else if topologyState.type === 'fresh'}
								<div
									class="flex items-center gap-2 rounded-lg border border-green-600 bg-green-50 px-3 py-2 text-sm dark:bg-green-950"
								>
									<svelte:component
										this={topologyState.icon}
										class="h-4 w-4 text-green-600 dark:text-green-400"
									/>
									<span class="font-medium text-green-900 dark:text-green-100">Up to date</span>
								</div>
							{:else if topologyState.type === 'stale_safe'}
								<div
									class="flex items-center gap-2 rounded-lg border border-yellow-600 bg-yellow-50 px-3 py-2 text-sm dark:bg-yellow-950"
								>
									<svelte:component
										this={topologyState.icon}
										class="h-4 w-4 text-yellow-600 dark:text-yellow-400"
									/>
									<span class="font-medium text-yellow-900 dark:text-yellow-100"
										>Refresh available</span
									>
								</div>
							{:else if topologyState.type === 'stale_conflicts'}
								<div
									class="flex items-center gap-2 rounded-lg border border-red-600 bg-red-50 px-3 py-2 text-sm dark:bg-red-950"
								>
									<AlertTriangle class="h-4 w-4 text-red-600 dark:text-red-400" />
									<span class="font-medium text-red-900 dark:text-red-100">Conflicts detected</span>
								</div>
							{/if}
						</div>
					{/if}

					<select
						value={$topology?.id || ''}
						on:change={handleTopologyChange}
						class="input-field min-w-[200px]"
					>
						{#each $topologies as topologyOption (topologyOption.id)}
							<option value={topologyOption.id}>{topologyOption.name}</option>
						{/each}
					</select>

					<ExportButton />

					<button class="btn-primary flex items-center" on:click={handleCreateTopology}>
						<Plus class="my-1 h-5 w-5" />
					</button>

					{#if $topology && !$topology.is_locked}
						<button class="btn-primary flex items-center" on:click={handleRefresh}>
							<RefreshCcw class="my-1 h-5 w-5" />
						</button>
					{/if}

					{#if $topology}
						{#if $topology.is_locked}
							<button class="btn-primary flex items-center" on:click={handleUnlock}>
								<LockOpen class="my-1 h-5 w-5" />
							</button>
						{:else}
							<button class="btn-primary flex items-center" on:click={handleLock}>
								<Lock class="my-1 h-5 w-5" />
							</button>
						{/if}
					{/if}

					<button class="btn-primary flex items-center" on:click={handleEditTopology}>
						<Edit class="my-1 h-5 w-5" />
					</button>

					<button class="btn-danger flex items-center" on:click={handleDelete}>
						<Trash2 class="my-1 h-5 w-5" />
					</button>
				</div>
			</svelte:fragment>
		</TabHeader>

		<!-- Info Banner based on state -->
		{#if $topology && topologyState}
			{#if topologyState.type === 'locked'}
				<div
					class="rounded-lg border border-blue-200 bg-blue-50 p-4 dark:border-blue-800 dark:bg-blue-950"
				>
					<div class="flex items-start gap-3">
						<Lock class="mt-0.5 h-5 w-5 flex-shrink-0 text-blue-600 dark:text-blue-400" />
						<div class="flex-1">
							<h3 class="font-medium text-blue-900 dark:text-blue-100">
								Topology Locked
								{#if lockedByUser}
									by {lockedByUser.email}
								{/if}
							</h3>
							<p class="mt-1 text-sm text-blue-700 dark:text-blue-300">
								This topology is frozen at its current network state. Click "Unlock" to enable
								refreshing.
							</p>
						</div>
					</div>
				</div>
			{:else if topologyState.type === 'stale_safe'}
				<InlineWarning
					title="Network data has changed. Click refresh to update to current state."
				/>
			{:else if topologyState.type === 'stale_conflicts'}
				<div
					class="rounded-lg border border-red-200 bg-red-50 p-4 dark:border-red-800 dark:bg-red-950"
				>
					<div class="flex items-start gap-3">
						<AlertTriangle class="mt-0.5 h-5 w-5 flex-shrink-0 text-red-600 dark:text-red-400" />
						<div class="flex-1">
							<h3 class="font-medium text-red-900 dark:text-red-100">Conflicts Detected</h3>
							<p class="mt-1 text-sm text-red-700 dark:text-red-300">
								Some entities in this diagram no longer exist. Click "Refresh" to review changes
								before updating.
							</p>
						</div>
					</div>
				</div>
			{/if}
		{/if}

		{#if $loading}
			<Loading />
		{:else}
			<div class="relative">
				<TopologyOptionsPanel />
				<TopologyViewer />
			</div>
		{/if}
	</div>
</SvelteFlowProvider>

<TopologyModal bind:isOpen={isCreateEditOpen} {onSubmit} {onClose} topo={editingTopology} />

{#if $topology}
	<RefreshConflictsModal
		bind:isOpen={isRefreshConflictsOpen}
		topology={$topology}
		onConfirm={handleConfirmRefresh}
		onLock={handleLockFromConflicts}
		onCancel={() => (isRefreshConflictsOpen = false)}
	/>
{/if}
