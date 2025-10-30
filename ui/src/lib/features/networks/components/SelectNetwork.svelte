<script lang="ts">
	import { networks } from '../store';

	export let selectedNetworkId: string;
</script>

<label for="network" class="text-secondary mb-2 block text-sm font-medium"> Network </label>
<select id="network" bind:value={selectedNetworkId} class="input-field">
	{#each $networks as network (network.id)}
		<option class="select-option" value={network.id}>{network.name}</option>
	{/each}
</select>
<p class="text-tertiary text-xs">Select network</p>
