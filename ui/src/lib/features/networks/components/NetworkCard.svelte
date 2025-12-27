<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, permissions } from '$lib/shared/stores/metadata';
	import type { Network } from '../types';
	import { useHostsQuery } from '$lib/features/hosts/queries';
	import { useDaemonsQuery } from '$lib/features/daemons/queries';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { useGroupsQuery } from '$lib/features/groups/queries';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { useTagsQuery } from '$lib/features/tags/queries';
	import { toColor } from '$lib/shared/utils/styling';

	interface Props {
		network: Network;
		onDelete?: (network: Network) => void;
		onEdit?: (network: Network) => void;
		viewMode: 'card' | 'list';
		selected: boolean;
		onSelectionChange?: (selected: boolean) => void;
	}

	let {
		network,
		onDelete = () => {},
		onEdit = () => {},
		viewMode,
		selected,
		onSelectionChange = () => {}
	}: Props = $props();

	// TanStack Query hooks
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const hostsQuery = useHostsQuery();
	const daemonsQuery = useDaemonsQuery();
	const subnetsQuery = useSubnetsQuery();
	const groupsQuery = useGroupsQuery();
	const tagsQuery = useTagsQuery();

	// Derived data from queries
	let hostsData = $derived(hostsQuery.data ?? []);
	let daemonsData = $derived(daemonsQuery.data ?? []);
	let subnetsData = $derived(subnetsQuery.data ?? []);
	let groupsData = $derived(groupsQuery.data ?? []);
	let tagsData = $derived(tagsQuery.data ?? []);

	let networkHosts = $derived(hostsData.filter((h) => h.network_id == network.id));
	let networkDaemons = $derived(daemonsData.filter((d) => d.network_id == network.id));
	let networkSubnets = $derived(subnetsData.filter((s) => s.network_id == network.id));
	let networkGroups = $derived(groupsData.filter((g) => g.network_id == network.id));

	let canManageNetworks = $derived(
		(currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities) || false
	);

	// Build card data
	let cardData = $derived({
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
						color: entities.getColorHelper('Daemon').color
					};
				})
			},
			{
				label: 'Hosts',
				value: networkHosts.map((h) => {
					return {
						id: h.id,
						label: h.name,
						color: entities.getColorHelper('Host').color
					};
				})
			},
			{
				label: 'Subnets',
				value: networkSubnets.map((s) => {
					return {
						id: s.id,
						label: s.name,
						color: entities.getColorHelper('Subnet').color
					};
				})
			},
			{
				label: 'Groups',
				value: networkGroups.map((g) => {
					return {
						id: g.id,
						label: g.name,
						color: entities.getColorHelper('Group').color
					};
				})
			},
			{
				label: 'Tags',
				value: network.tags.map((t) => {
					const tag = tagsData.find((tag) => tag.id == t);
					return tag
						? { id: tag.id, color: tag.color, label: tag.name }
						: { id: t, color: toColor('gray'), label: 'Unknown Tag' };
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
	});
</script>

<GenericCard
	{...cardData}
	{viewMode}
	{selected}
	{onSelectionChange}
	selectable={canManageNetworks}
/>
