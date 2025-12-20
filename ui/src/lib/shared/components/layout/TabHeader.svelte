<script lang="ts">
	export let title: string = '';
	export let subtitle: string = '';
</script>

<div class="flex items-center justify-between">
	<div>
		{#if title}
			<h2 class="text-primary text-2xl font-bold">{title}</h2>
		{/if}
		{#if subtitle}
			<p class="text-secondary mt-1">{subtitle}</p>
		{/if}
	</div>
	<div class="flex gap-4">
		<slot name="actions" />
	</div>
</div>
