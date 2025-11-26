<script lang="ts">
	interface ToggleOption {
		value: string;
		label: string;
		badge?: string;
	}

	interface Props {
		options: ToggleOption[];
		selected: string;
		onchange: (value: string) => void;
	}

	let { options, selected, onchange }: Props = $props();
</script>

<div class="card inline-flex gap-1 p-1">
	{#each options as option (option.value)}
		<button
			type="button"
			onclick={() => onchange(option.value)}
			class="rounded-xl px-4 py-2 text-sm font-medium transition-all {selected === option.value
				? 'scale-110 bg-gray-700/50 text-white shadow-lg'
				: 'text-secondary hover:text-primary hover:bg-gray-800/50'}"
		>
			<span>{option.label}</span>
			{#if option.badge}
				<span
					class="ml-1 text-xs font-semibold {selected === option.value
						? 'text-green-300'
						: 'text-success'}">{option.badge}</span
				>
			{/if}
		</button>
	{/each}
</div>
