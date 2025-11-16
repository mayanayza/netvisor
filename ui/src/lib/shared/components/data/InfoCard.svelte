<script lang="ts">
	export let title: string | null = null;
	export let variant: 'default' | 'compact' = 'default';
</script>

<div class="card card-static">
	{#if title}
		<h3 class="text-primary mb-3 text-sm font-semibold">{title}</h3>
	{/if}
	<div class={variant === 'compact' ? 'space-y-2' : 'space-y-3'}>
		<slot />
	</div>
</div>
