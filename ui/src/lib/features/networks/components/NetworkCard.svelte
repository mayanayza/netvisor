<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, permissions } from '$lib/shared/stores/metadata';
	import type { Network } from '../types';
	import { hosts } from '$lib/features/hosts/store';
	import { daemons } from '$lib/features/daemons/store';
	import { subnets } from '$lib/features/subnets/store';
	import { groups } from '$lib/features/groups/store';
	import { currentUser } from '$lib/features/auth/store';

	export let network: Network;
	export let onDelete: (network: Network) => void = () => {};
	export let onEdit: (network: Network) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	$: networkHosts = $hosts.filter((h) => h.network_id == network.id);
	$: networkDaemons = $daemons.filter((d) => d.network_id == network.id);
	$: networkSubnets = $subnets.filter((s) => s.network_id == network.id);
	$: networkGroups = $groups.filter((g) => g.network_id == network.id);

	$: canManageNetworks =
		$currentUser && permissions.getMetadata($currentUser.permissions).network_permissions;

	// Build card data
	$: cardData = {
		title: network.name,
		iconColor: entities.getColorHelper('Network').icon,
		Icon: entities.getIconComponent('Network'),
		fields: [
			{
				label: 'Daemons',
				value: networkDaemons.map((d) => {
					return {
						id: d.id,
						label: d.name,
						color: entities.getColorHelper('Daemon').string
					};
				})
			},
			{
				label: 'Hosts',
				value: networkHosts.map((h) => {
					return {
						id: h.id,
						label: h.name,
						color: entities.getColorHelper('Host').string
					};
				})
			},
			{
				label: 'Subnets',
				value: networkSubnets.map((s) => {
					return {
						id: s.id,
						label: s.name,
						color: entities.getColorHelper('Subnet').string
					};
				})
			},
			{
				label: 'Groups',
				value: networkGroups.map((g) => {
					return {
						id: g.id,
						label: g.name,
						color: entities.getColorHelper('Group').string
					};
				})
			}
		],

		actions: [
			...(canManageNetworks
				? [
						{
							label: 'Delete',
							icon: Trash2,
							class: 'btn-icon-danger',
							onClick: () => onDelete(network)
						},
						{
							label: 'Edit',
							icon: Edit,
							onClick: () => onEdit(network)
						}
					]
				: [])
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
