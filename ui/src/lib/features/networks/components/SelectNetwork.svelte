<script lang="ts">
	import { networks } from '../store';

	export let selectedNetworkId: string | null;

	$: selected = selectedNetworkId ? selectedNetworkId : $networks[0].id;
</script>

<label for="network" class="text-secondary mb-2 block text-sm font-medium"> Network </label>
<select id="network" bind:value={selected} class="input-field">
	{#each $networks as network (network.id)}
		<option class="select-option" value={network.id}>{network.name}</option>
	{/each}
</select>
<p class="text-tertiary text-xs">Select network</p>
