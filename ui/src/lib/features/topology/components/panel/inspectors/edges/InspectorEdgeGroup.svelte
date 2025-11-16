<script lang="ts">
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getBindingFromId, getServiceForBinding } from '$lib/features/services/store';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { getGroupById, updateGroup } from '$lib/features/groups/store';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import { get } from 'svelte/store';
	import { GroupDisplay } from '$lib/shared/components/forms/selection/display/GroupDisplay.svelte';
	import { ArrowDown } from 'lucide-svelte';
	import EdgeStyleForm from '$lib/features/groups/components/GroupEditModal/EdgeStyleForm.svelte';
	import { createColorHelper } from '$lib/shared/utils/styling';
	import type { Group } from '$lib/features/groups/types/base';

	let {
		groupId,
		sourceBindingId,
		targetBindingId
	}: { groupId: string; sourceBindingId: string; targetBindingId: string } = $props();

	let group = $derived(getGroupById(groupId));

	// Local copy of group for editing
	let localGroup = $state<Group | null>(null);

	// Initialize from group when it loads
	$effect(() => {
		if ($group) {
			localGroup = { ...$group };
		}
	});

	// Auto-save when styling changes
	$effect(() => {
		if (
			localGroup &&
			$group &&
			(localGroup.color !== $group.color || localGroup.edge_style !== $group.edge_style)
		) {
			updateGroup(localGroup);
		}
	});

	let groupColor = $derived(createColorHelper($group?.color || 'gray'));

	let isRequestPath = $derived($group?.group_type == 'RequestPath');
</script>

<div class="space-y-3">
	{#if $group && localGroup}
		<span class="text-secondary mb-2 block text-sm font-medium">Group</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$group} displayComponent={GroupDisplay} />
		</div>

		<span class="text-secondary mb-2 block text-sm font-medium">Edge Style</span>
		<div class="card p-4">
			<EdgeStyleForm bind:formData={localGroup} collapsed={true} />
		</div>

		<span class="text-secondary mb-2 block text-sm font-medium">Services</span>
		{#each $group.service_bindings as binding (binding)}
			{@const bindingService = get(getServiceForBinding(binding))}
			{@const bindingHost = bindingService ? getHostFromId(bindingService.id) : null}
			{#if bindingService && bindingHost}
				<div
					class={isRequestPath
						? `card ${binding == sourceBindingId || binding == targetBindingId ? 'ring-1 ring-gray-500' : ''}`
						: `card ${binding == sourceBindingId ? `ring-1 ${groupColor.ring}` : binding == targetBindingId ? 'ring-1 ring-gray-500' : ''}`}
				>
					<EntityDisplayWrapper
						context={{ host: bindingHost, service: bindingService }}
						item={get(getBindingFromId(binding))}
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
