<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import type { Network } from '../types';
	import { hosts } from '$lib/features/hosts/store';
	import { daemons } from '$lib/features/daemons/store';
	import { subnets } from '$lib/features/subnets/store';
	import { groups } from '$lib/features/groups/store';

	export let network: Network;
	export let onDelete: (network: Network) => void = () => {};
	export let onEdit: (network: Network) => void = () => {};
	export let viewMode: 'card' | 'list';

	$: networkHosts = $hosts.filter((h) => h.network_id == network.id);
	$: networkDaemons = $daemons.filter((d) => d.network_id == network.id);
	$: networkSubnets = $subnets.filter((s) => s.network_id == network.id);
	$: networkGroups = $groups.filter((g) => g.network_id == network.id);

	// Build card data
	$: cardData = {
		title: network.name,
		iconColor: entities.getColorHelper('Network').icon,
		icon: entities.getIconComponent('Network'),
		fields: [
			{
				label: 'Daemons',
				value: networkDaemons.map((d) => {
					return {
						id: d.id,
						label: d.ip,
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
			{
				label: 'Delete Network',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(network)
			},
			{
				label: 'Edit Network',
				icon: Edit,
				onClick: () => onEdit(network)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
