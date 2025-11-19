<script lang="ts">
	export let title: string;
	export let items: { name: string; id: string }[];
</script>

{#if items.length > 0}
	<div>
		{#if title.length > 0}
			<h4 class="text-secondary mb-2 font-medium">
				{title} ({items.length})
			</h4>
		{/if}
		<ul class="card card-static space-y-2">
			{#each items as item (item.id)}
				<li class="text-secondary flex items-center gap-2 text-sm">
					<span>• {item.name}</span>
				</li>
			{/each}
		</ul>
	</div>
{/if}
