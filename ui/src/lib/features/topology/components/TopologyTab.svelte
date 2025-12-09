<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import TopologyViewer from './visualization/TopologyViewer.svelte';
	import TopologyOptionsPanel from './panel/TopologyOptionsPanel.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { Edit, Lock, Plus, Radio, RefreshCcw, Trash2 } from 'lucide-svelte';
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
		rebuildTopology,
		lockTopology,
		unlockTopology,
		autoRebuild
	} from '../store';
	import type { Topology } from '../types/base';
	import TopologyModal from './TopologyModal.svelte';
	import { users } from '$lib/features/users/store';
	import { getTopologyState } from '../state';
	import StateBadge from './StateBadge.svelte';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import RefreshConflictsModal from './RefreshConflictsModal.svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import { TopologyDisplay } from '$lib/shared/components/forms/selection/display/TopologyDisplay.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { formatTimestamp } from '$lib/shared/utils/formatting';

	const loading = loadData([getHosts, getServices, getSubnets, getGroups, getTopologies]);

	let isCreateEditOpen = $state(false);
	let editingTopology: Topology | null = $state(null);

	let isRefreshConflictsOpen = $state(false);

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
		}
	}

	async function handleReset() {
		if (!$topology) return;
		let resetTopology = { ...$topology };
		resetTopology.nodes = [];
		resetTopology.edges = [];
		await rebuildTopology(resetTopology);
	}

	async function handleConfirmRefresh() {
		await rebuildTopology($topology);
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
		$topology?.locked_by ? $users.find((u) => u.id === $topology.locked_by) : null
	);
</script>

<SvelteFlowProvider>
	<div class="space-y-6">
		<!-- Header -->
		<TabHeader title="Topology" subtitle="Generate and view network topology">
			<svelte:fragment slot="actions">
				<div class="card card-static flex items-center gap-4 px-4 py-2">
					{#if $topology}
						<ExportButton />

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

									<button
										onclick={() => autoRebuild.set(!$autoRebuild)}
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
								</div>
								{#if $topology.is_locked && $topology.locked_at}
									<span class="text-tertiary whitespace-nowrap text-[10px]"
										>Locked: {formatTimestamp($topology.locked_at)} by {$users.find(
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
							<div class="min-w-[300px]">
								<RichSelect
									label=""
									selectedValue={$topology.id}
									displayComponent={TopologyDisplay}
									onSelect={handleTopologyChange}
									options={$topologies}
								/>
							</div>
						{/if}
					{/if}

					<div class="card-divider-v self-stretch"></div>

					<div class="flex items-center gap-4 py-2">
						{#if $topology}
							<button class="btn-primary" onclick={handleEditTopology}>
								<Edit class="mr-2 h-4 w-4" /> Edit
							</button>
						{/if}

						<button class="btn-primary" onclick={handleCreateTopology}>
							<Plus class="h-4 w-4" /> New
						</button>

						{#if $topology}
							<button class="btn-danger" onclick={handleDelete}>
								<Trash2 class="my-1 h-5 w-5" />
							</button>
						{/if}
					</div>
				</div>
			</svelte:fragment>
		</TabHeader>

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

		{#if $loading}
			<Loading />
		{:else if $topology}
			<div class="relative">
				<TopologyOptionsPanel />
				<TopologyViewer />
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
{/if}
