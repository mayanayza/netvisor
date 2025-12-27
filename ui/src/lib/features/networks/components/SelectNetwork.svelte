<script lang="ts">
	import { useNetworksQuery } from '$lib/features/networks/queries';

	interface Props {
		selectedNetworkId?: string | null;
		disabled?: boolean;
	}

	let { selectedNetworkId = $bindable(null), disabled = false }: Props = $props();

	const networksQuery = useNetworksQuery();
	let networksData = $derived(networksQuery.data ?? []);

	$effect(() => {
		if (!selectedNetworkId && networksData.length > 0) {
			selectedNetworkId = networksData[0].id;
		}
	});
</script>

<div>
	<label for="network" class="text-secondary mb-2 block text-sm font-medium"> Network</label>
	<select id="network" {disabled} bind:value={selectedNetworkId} class="input-field">
		{#each networksData as network (network.id)}
			<option class="select-option" value={network.id}>{network.name}</option>
		{/each}
	</select>
	<p class="text-tertiary mt-2 text-xs">Select network</p>
</div>
