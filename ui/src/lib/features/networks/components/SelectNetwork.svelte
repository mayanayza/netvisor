<script lang="ts">
	import { networks } from '../store';

	export let selectedNetworkId: string | null;
	export let disabled: boolean = false;

	$: if (!selectedNetworkId && $networks.length > 0) {
		selectedNetworkId = $networks[0].id;
	}
</script>

<div>
	<label for="network" class="text-secondary mb-2 block text-sm font-medium"> Network</label>
	<select id="network" {disabled} bind:value={selectedNetworkId} class="input-field">
		{#each $networks as network (network.id)}
			<option class="select-option" value={network.id}>{network.name}</option>
		{/each}
	</select>
	<p class="text-tertiary mt-2 text-xs">Select network</p>
</div>
