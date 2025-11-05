<script lang="ts">
	export let topologyOption: boolean;
	export let title: string;
	export let description: string;
</script>

<label class="flex flex-col gap-1">
	<div class="flex items-center gap-2">
		<input
			type="checkbox"
			bind:checked={topologyOption}
			class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-1 focus:ring-blue-500"
		/>
		<span class="text-primary text-sm">{title}</span>
	</div>
	<p class="text-tertiary text-xs leading-tight">
		{description}
	</p>
</label>

<style>
	/* Ensure checkboxes are styled consistently */
	input[type='checkbox']:checked {
		background-color: rgb(37, 99, 235);
		border-color: rgb(37, 99, 235);
	}
</style>
