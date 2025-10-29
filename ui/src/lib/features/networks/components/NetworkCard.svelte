<script lang="ts">
	import { Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import type { Network } from '../types';

	export let network: Network;
	export let onDelete: (network: Network) => void = () => {};

	// Build card data
	$: cardData = {
		title: network.name,
		iconColor: entities.getColorHelper("Network").icon,
		icon: entities.getIconComponent("Network"),

		sections: [],
		lists: [],

		actions: [
			{
				label: 'Delete Network',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(network)
			},
		]
	};
</script>

<GenericCard {...cardData} />
