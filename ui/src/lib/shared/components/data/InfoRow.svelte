<script lang="ts">
	export let label: string;
	export let mono: boolean = false;
</script>

<div class="flex justify-between">
	<span class="text-secondary text-sm">{label}:</span>
	<span class="text-primary text-sm" class:font-mono={mono} class:text-xs={mono}>
		<slot />
	</span>
</div>
