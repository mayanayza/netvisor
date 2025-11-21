<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { AlertTriangle, Lock, RefreshCcw } from 'lucide-svelte';
	import type { Topology } from '../types/base';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import EntityList from '$lib/shared/components/data/EntityList.svelte';

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

	// Build single list with category headers
	$: allRemovedEntities = (() => {
		const items = [];

		if (removedHosts.length > 0) {
			items.push({
				id: 'hosts-header',
				name: `Hosts: ${removedHosts.map((h) => h.name).join(', ')}`
			});
		}

		if (removedServices.length > 0) {
			items.push({
				id: 'services-header',
				name: `Services: ${removedServices.map((s) => s.name).join(', ')}`
			});
		}

		if (removedSubnets.length > 0) {
			items.push({
				id: 'subnets-header',
				name: `Subnets: ${removedSubnets.map((s) => s.name).join(', ')}`
			});
		}

		if (removedGroups.length > 0) {
			items.push({
				id: 'groups-header',
				name: `Groups: ${removedGroups.map((g) => g.name).join(', ')}`
			});
		}

		return items;
	})();
</script>

<GenericModal {isOpen} onClose={onCancel} title="Review Refresh Conflicts" size="lg">
	<svelte:fragment slot="header-icon">
		<AlertTriangle class="h-6 w-6 text-red-600 dark:text-red-400" />
	</svelte:fragment>

	<div class="space-y-4">
		<!-- Warning header -->
		<InlineDanger
			title={`${totalRemoved} ${totalRemoved === 1 ? 'entity' : 'entities'} will be removed`}
			body="These entities no longer exist in the network and will be removed from this diagram if you rebuild."
		/>

		<!-- List removed entities -->
		<EntityList title="" items={allRemovedEntities} />

		<!-- Info box -->
		<InlineInfo
			title="Tip:"
			body="If you want to preserve this network state as a historical record, click 'Lock' to freeze this topology without refreshing."
		/>
	</div>

	<svelte:fragment slot="footer">
		<div class="flex w-full items-center justify-between">
			<button class="btn-secondary" on:click={onCancel}> Cancel </button>
			<div class="flex gap-3">
				<button class="btn-primary flex items-center gap-2" on:click={onLock}>
					<Lock class="h-4 w-4" />
					Lock
				</button>
				<button class="btn-danger flex items-center gap-2" on:click={onConfirm}>
					<RefreshCcw class="h-4 w-4" />
					Rebulid
				</button>
			</div>
		</div>
	</svelte:fragment>
</GenericModal>
