<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import TopologyViewer from './visualization/TopologyViewer.svelte';
	import TopologyOptionsPanel from './panel/TopologyOptionsPanel.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { Edit, Lock, Plus, Trash2 } from 'lucide-svelte';
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
	import TopologyModal from './TopologyModal.svelte';
	import { users } from '$lib/features/users/store';
	import { getTopologyState } from '../state';
	import StateBadge from './StateBadge.svelte';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import RefreshConflictsModal from './RefreshConflictsModal.svelte';
	import RichSelect from '$lib/shared/components/forms/selection/RichSelect.svelte';
	import { TopologyDisplay } from '$lib/shared/components/forms/selection/display/TopologyDisplay.svelte';

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
	$: stateConfig = $topology ? getTopologyState($topology) : null;
	$: lockedByUser = $topology?.locked_by ? $users.find((u) => u.id === $topology.locked_by) : null;

	// Determine primary action handler
	function handlePrimaryAction() {
		if (!stateConfig || !stateConfig.primaryAction) return;

		if (stateConfig.primaryAction === 'refresh') {
			handleRefresh();
		} else if (stateConfig.primaryAction === 'unlock') {
			handleUnlock();
		}
	}

	const loading = loadData([getHosts, getServices, getSubnets, getGroups, getTopologies]);
</script>

<SvelteFlowProvider>
	<div class="space-y-6">
		<!-- Header -->
		<TabHeader title="Topology" subtitle="Generate and view network topology">
			<svelte:fragment slot="actions">
				<div class="flex items-center gap-4">
					<ExportButton />

					<button class="btn-icon-primary" on:click={handleEditTopology}>
						<Edit class="mr-2 h-5 w-5" /> Edit
					</button>

					{#if $topology && stateConfig}
						{#if stateConfig.secondaryAction === 'lock'}
							<button class="btn-icon-primary" on:click={handleLock}>
								<Lock class="mr-2 h-5 w-5" /> Lock
							</button>
						{/if}
					{/if}

					<!-- State Badge / Action Button -->
					{#if $topology && stateConfig}
						<div class="flex-shrink-0">
							<StateBadge
								Icon={stateConfig.icon}
								label={stateConfig.getLabel($topology)}
								color={stateConfig.color}
								onClick={stateConfig.primaryAction ? handlePrimaryAction : null}
							/>
						</div>
					{/if}

					{#if $topologies && $topology}
						<div>
							<RichSelect
								label=""
								selectedValue={$topology.id}
								displayComponent={TopologyDisplay}
								onSelect={handleTopologyChange}
								options={$topologies}
							/>
						</div>
					{/if}

					<button class="btn-primary" on:click={handleCreateTopology}>
						<Plus class="h-5 w-5" /> New
					</button>

					<button class="btn-danger" on:click={handleDelete}>
						<Trash2 class="my-1 h-5 w-5" />
					</button>
				</div>
			</svelte:fragment>
		</TabHeader>

		<!-- Contextual Info Banner -->
		{#if $topology && stateConfig}
			{#if stateConfig.type === 'locked'}
				<InlineInfo
					title={`Topology Locked ${lockedByUser ? `by ${lockedByUser.email}` : ''}`}
					body="Data can't be refreshed while this topology is locked. Click the badge above to unlock and enable data refresh."
				/>
			{:else if stateConfig.type === 'stale_conflicts'}
				<InlineDanger
					title="Conflicts Detected"
					body="Some entities in this diagram no longer exist. Click the badge above to review
								changes before updating."
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
			<div class="card card-static">No topology selected. Create one to get started.</div>
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
