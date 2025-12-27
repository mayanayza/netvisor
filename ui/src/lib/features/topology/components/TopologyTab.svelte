<script lang="ts">
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import TopologyViewer from './visualization/TopologyViewer.svelte';
	import TopologyOptionsPanel from './panel/TopologyOptionsPanel.svelte';
	import { Edit, Globe, Lock, Plus, Radio, RefreshCcw, Share2, Trash2 } from 'lucide-svelte';
	import ExportButton from './ExportButton.svelte';
	import ShareModal from '$lib/features/shares/components/ShareModal.svelte';
	import { SvelteFlowProvider } from '@xyflow/svelte';
	import {
		topologies,
		topology,
		getTopologies,
		deleteTopology,
		rebuildTopology,
		lockTopology,
		unlockTopology,
		autoRebuild
	} from '../store';
	import type { Topology } from '../types/base';
	import TopologyModal from './TopologyModal.svelte';
	import { getTopologyState } from '../state';
	import StateBadge from './StateBadge.svelte';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import RefreshConflictsModal from './RefreshConflictsModal.svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import { TopologyDisplay } from '$lib/shared/components/forms/selection/display/TopologyDisplay.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { useGroupsQuery } from '$lib/features/groups/queries';
	import { useUsersQuery } from '$lib/features/users/queries';
	import { onMount } from 'svelte';

	// Queries - TanStack Query handles deduplication
	const hostsQuery = useHostsQuery();
	const subnetsQuery = useSubnetsQuery();
	const groupsQuery = useGroupsQuery();
	const usersQuery = useUsersQuery();

	// Derived data
	let usersData = $derived(usersQuery.data ?? []);
	let isLoading = $derived(hostsQuery.isPending || subnetsQuery.isPending || groupsQuery.isPending);

	// Load topologies (still uses old store)
	onMount(() => {
		getTopologies();
	});

	let isCreateEditOpen = $state(false);
	let editingTopology: Topology | null = $state(null);

	let isRefreshConflictsOpen = $state(false);
	let isShareModalOpen = $state(false);

	let topologyViewer: TopologyViewer | null = $state(null);

	$effect(() => {
		void $topology;
		void $topologies;
	});

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
	function handleTopologyChange(value: string) {
		const selectedTopology = $topologies.find((t) => t.id === value);
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

	async function handleAutoRebuildToggle() {
		autoRebuild.set(!$autoRebuild);
		if ($autoRebuild) {
			await handleRefresh();
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
			await rebuildTopology($topology);
			topologyViewer?.triggerFitView();
		}
	}

	async function handleReset() {
		if (!$topology) return;
		let resetTopology = { ...$topology };
		resetTopology.nodes = [];
		resetTopology.edges = [];
		await rebuildTopology(resetTopology);
		topologyViewer?.triggerFitView();
	}

	async function handleConfirmRefresh() {
		await rebuildTopology($topology);
		topologyViewer?.triggerFitView();
		isRefreshConflictsOpen = false;
	}

	async function handleLockFromConflicts() {
		await lockTopology($topology);
		isRefreshConflictsOpen = false;
	}

	async function handleToggleLock() {
		if (!$topology) return;
		if ($topology.is_locked) {
			await unlockTopology($topology);
		} else {
			await lockTopology($topology);
		}
	}

	let stateConfig = $derived(
		$topology
			? getTopologyState($topology, $autoRebuild, {
					onRefresh: handleRefresh,
					onReset: handleReset
				})
			: null
	);

	let lockedByUser = $derived(
		$topology?.locked_by ? usersData.find((u) => u.id === $topology.locked_by) : null
	);
</script>

<SvelteFlowProvider>
	<div class="space-y-6">
		<!-- Header -->
		<div class="card card-static flex items-center justify-evenly gap-4 px-4 py-2">
			{#if $topology}
				<div class="flex items-center gap-4 py-2">
					<ExportButton />
					<button class="btn-secondary" onclick={() => (isShareModalOpen = true)}>
						<Share2 class="my-1 h-5 w-5" />
					</button>
					<a
						href="https://tally.so/r/lbqLAv"
						target="_blank"
						rel="noopener noreferrer"
						class="btn-secondary"
						title="Submit to Community Showcase"
					>
						<Globe class="my-1 h-5 w-5" />
					</a>
				</div>

				<div class="card-divider-v self-stretch"></div>

				<div class="flex items-center py-2">
					<div class="mr-2 flex flex-col text-center">
						<div class="flex justify-around gap-6">
							<button
								onclick={handleToggleLock}
								class={`text-xs ${$topology.is_locked ? 'btn-icon-info' : 'btn-icon'}`}
							>
								<Lock class="mr-2 h-4 w-4" />
								{$topology.is_locked ? 'Unlock' : 'Lock'}
							</button>

							{#if !$topology.is_locked}
								<button
									onclick={handleAutoRebuildToggle}
									type="button"
									class={`text-xs ${$autoRebuild && !$topology.is_locked ? 'btn-icon-success' : 'btn-icon'}`}
									disabled={$topology.is_locked}
								>
									{#if $autoRebuild}
										<Radio class="mr-2 h-4 w-4" /> Auto
									{:else}
										<RefreshCcw class="mr-2 h-4 w-4" /> Manual
									{/if}
								</button>
							{/if}
						</div>
						{#if $topology.is_locked && $topology.locked_at}
							<span class="text-tertiary whitespace-nowrap text-[10px]"
								>Locked: {formatTimestamp($topology.locked_at)} by {usersData.find(
									(u) => u.id == $topology.locked_by
								)?.email}</span
							>
						{:else}
							<span class="text-tertiary whitespace-nowrap text-[10px]"
								>Last Rebuild: {formatTimestamp($topology.last_refreshed)}</span
							>
						{/if}
					</div>
					<!-- State Badge / Action Button -->
					{#if stateConfig && !$topology.is_locked && !$autoRebuild}
						<div class="flex flex-col items-center gap-2">
							<div class="flex items-center">
								<StateBadge
									disabled={stateConfig?.disabled || false}
									Icon={stateConfig.icon}
									label={stateConfig.buttonText}
									cls={stateConfig.class}
									onClick={stateConfig.action}
								/>
							</div>
						</div>
					{/if}
				</div>

				<div class="card-divider-v self-stretch"></div>

				{#if $topologies}
					<RichSelect
						label=""
						selectedValue={$topology.id}
						displayComponent={TopologyDisplay}
						onSelect={handleTopologyChange}
						options={$topologies}
					/>
				{/if}
			{/if}

			{#if $topology}
				<div class="card-divider-v self-stretch"></div>
			{/if}

			<div class="flex items-center gap-4 py-2">
				{#if $topology}
					<button class="btn-primary" onclick={handleEditTopology}>
						<Edit class="my-1 h-4 w-4" />
					</button>
				{/if}

				<button class="btn-primary" onclick={handleCreateTopology}>
					<Plus class="my-1 h-4 w-4" />
				</button>

				{#if $topology}
					<button class="btn-danger" onclick={handleDelete}>
						<Trash2 class="my-1 h-5 w-5" />
					</button>
				{/if}
			</div>
		</div>

		<!-- Contextual Info Banner -->
		{#if $topology && stateConfig}
			{#if stateConfig.type === 'locked'}
				<InlineInfo
					dismissableKey="topology-locked-info"
					title={`Topology Locked ${lockedByUser ? `by ${lockedByUser.email}` : ''}`}
					body="Data can't be refreshed while this topology is locked. You can still move and resize nodes and edges, but you won't be able to make any other changes. Click the badge above to unlock and enable data refresh."
				/>
			{:else if stateConfig.type === 'stale_conflicts'}
				<InlineDanger
					dismissableKey="topology-conflict-info"
					title="Conflicts Detected"
					body="Some entities in this diagram no longer exist. Click the badge above to review
								changes before updating."
				/>
			{:else if stateConfig.type === 'stale_safe'}
				<InlineWarning
					dismissableKey="topology-refresh-info"
					title="Stale Data"
					body="Entities have been updated, and the diagram layout may need to change to fit them."
				/>
			{/if}
		{/if}

		{#if isLoading}
			<Loading />
		{:else if $topology}
			<div class="relative">
				<TopologyOptionsPanel />
				<TopologyViewer bind:this={topologyViewer} />
			</div>
		{:else}
			<div class="card card-static text-secondary">
				No topology selected. Create one to get started.
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
	<ShareModal
		isOpen={isShareModalOpen}
		topologyId={$topology.id}
		networkId={$topology.network_id}
		onClose={() => (isShareModalOpen = false)}
	/>
{/if}
