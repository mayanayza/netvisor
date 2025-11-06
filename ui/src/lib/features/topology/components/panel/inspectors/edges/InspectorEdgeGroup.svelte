<script lang="ts">
	import EntityDisplayWrapper from '$lib/shared/components/forms/selection/display/EntityDisplayWrapper.svelte';
	import { getBindingFromId, getServiceForBinding } from '$lib/features/services/store';
	import { getHostFromId } from '$lib/features/hosts/store';
	import { getGroupById } from '$lib/features/groups/store';
	import { BindingWithServiceDisplay } from '$lib/shared/components/forms/selection/display/BindingWithServiceDisplay.svelte';
	import { get } from 'svelte/store';
	import { GroupDisplay } from '$lib/shared/components/forms/selection/display/GroupDisplay.svelte';
	import { ArrowDown } from 'lucide-svelte';

	let {
		groupId,
		sourceBindingId,
		targetBindingId
	}: { groupId: string; sourceBindingId: string; targetBindingId: string } = $props();

	let group = $derived(getGroupById(groupId));
</script>

<div class="space-y-3">
	{#if $group}
		<span class="text-secondary mb-2 block text-sm font-medium">Group</span>
		<div class="card">
			<EntityDisplayWrapper context={{}} item={$group} displayComponent={GroupDisplay} />
		</div>

		<span class="text-secondary mb-2 block text-sm font-medium">Services</span>
		{#each $group.service_bindings as binding (binding)}
			{@const bindingService = get(getServiceForBinding(binding))}
			{@const bindingHost = bindingService ? getHostFromId(bindingService.id) : null}
			{#if bindingService && bindingHost}
				<div
					class={`card ${binding == sourceBindingId || binding == targetBindingId ? 'ring-1 ring-gray-500' : ''}`}
				>
					<EntityDisplayWrapper
						context={{ host: bindingHost, service: bindingService }}
						item={get(getBindingFromId(binding))}
						displayComponent={BindingWithServiceDisplay}
					/>
				</div>
				{#if binding == sourceBindingId}
					<div class="flex flex-col items-center">
						<ArrowDown class="text-secondary h-5 w-5" />
					</div>
				{/if}
			{/if}
		{/each}
	{/if}
</div>
