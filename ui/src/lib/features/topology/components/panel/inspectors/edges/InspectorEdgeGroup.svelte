<script lang="ts">
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { updateGroup } from '$lib/features/groups/store';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import { GroupDisplay } from '$lib/shared/components/forms/selection/display/GroupDisplay.svelte';
	import { ArrowDown } from 'lucide-svelte';
	import EdgeStyleForm from '$lib/features/groups/components/GroupEditModal/EdgeStyleForm.svelte';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import type { Group } from '$lib/features/groups/types/base';
	import { autoRebuild, topology as globalTopology } from '$lib/features/topology/store';
	import type { Topology } from '$lib/features/topology/types/base';
	import { getTopologyStateInfo } from '$lib/features/topology/state';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { getContext } from 'svelte';
	import type { Writable } from 'svelte/store';

	let {
		groupId,
		sourceBindingId,
		targetBindingId
	}: { groupId: string; sourceBindingId: string; targetBindingId: string } = $props();

	// Try to get topology from context (for share/embed pages), fallback to global store
	const topologyContext = getContext<Writable<Topology> | undefined>('topology');
	let topology = $derived(topologyContext ? $topologyContext : $globalTopology);

	// Check if we're in readonly mode (context exists means we're on share page)
	let isReadonly = $derived(!!topologyContext);

	let group = $derived(topology ? topology.groups.find((g) => g.id == groupId) : null);

	// Local copy of group for editing
	let localGroup = $state<Group | null>(null);

	// Initialize from group when it loads
	$effect(() => {
		if (group) {
			localGroup = { ...group };
		}
	});

	let liveEditsEnabled = $derived(
		!isReadonly && topology && getTopologyStateInfo(topology, $autoRebuild).type == 'fresh'
	);

	// Auto-save when styling changes (only in non-readonly mode)
	$effect(() => {
		if (
			!isReadonly &&
			localGroup &&
			group &&
			(localGroup.color !== group.color || localGroup.edge_style !== group.edge_style)
		) {
			updateGroup(localGroup);
		}
	});

	let groupColor = $derived(createColorHelper(group?.color || 'gray'));

	let isRequestPath = $derived(group?.group_type == 'RequestPath');

	// Helper functions to get data from topology
	function getServiceForBindingFromTopology(bindingId: string) {
		if (!topology) return null;
		return topology.services.find((s) => s.bindings.some((b) => b.id === bindingId)) || null;
	}

	function getBindingFromTopology(bindingId: string) {
		if (!topology) return null;
		for (const service of topology.services) {
			const binding = service.bindings.find((b) => b.id === bindingId);
			if (binding) return binding;
		}
		return null;
	}

	function getHostForService(serviceHostId: string) {
		if (!topology) return null;
		return topology.hosts.find((h) => h.id === serviceHostId) || null;
	}
</script>

<div class="space-y-3">
	{#if group && localGroup}
		<span class="text-secondary mb-2 block text-sm font-medium">Group</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={group} displayComponent={GroupDisplay} />
		</div>

		{#if !isReadonly}
			<span class="text-secondary mb-2 block text-sm font-medium">Edge Style</span>
			{#if topology && getTopologyStateInfo(topology, $autoRebuild).type != 'fresh'}
				<InlineWarning
					title="Editing disabled"
					body="Editing is only available when topology is unlocked and up-to-date."
				/>
			{/if}
			<div class={`card p-4 ${liveEditsEnabled ? '' : 'card-static'}`}>
				<EdgeStyleForm bind:formData={localGroup} collapsed={true} editable={liveEditsEnabled} />
			</div>
		{/if}

		<span class="text-secondary mb-2 block text-sm font-medium">Services</span>
		{#each group.binding_ids ?? [] as binding (binding)}
			{@const bindingService = getServiceForBindingFromTopology(binding)}
			{@const bindingHost = bindingService ? getHostForService(bindingService.host_id) : null}
			{@const bindingData = getBindingFromTopology(binding)}
			{#if bindingService && bindingHost && bindingData}
				<div
					class={isRequestPath
						? `card ${binding == sourceBindingId || binding == targetBindingId ? 'ring-1 ring-gray-500' : ''}`
						: `card ${binding == sourceBindingId ? `ring-1 ${groupColor.ring}` : binding == targetBindingId ? 'ring-1 ring-gray-500' : ''}`}
				>
					<EntityDisplayWrapper
						context={{ host: bindingHost, service: bindingService }}
						item={bindingData}
						displayComponent={BindingWithServiceDisplay}
					/>
				</div>
				{#if binding == sourceBindingId && isRequestPath}
					<div class="flex flex-col items-center">
						<ArrowDown class="text-secondary h-5 w-5" />
					</div>
				{/if}
			{/if}
		{/each}
	{/if}
</div>
