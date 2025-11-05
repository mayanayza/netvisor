<script lang="ts">
	let {
		size = 24,
		class: className = '',
		iconName,
		iconUrl,
		useWhiteBackground = false
	}: {
		size?: number;
		class?: string;
		iconName: string;
		iconUrl: string;
		useWhiteBackground?: boolean;
	} = $props();

	let background_padding = 1;
	size = useWhiteBackground ? size : size - 2 * background_padding;

	const fallbackIcon =
		'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiLz4KPHA=';

	let imgElement: HTMLImageElement | undefined = $state();

	function handleError() {
		if (imgElement) {
			imgElement.src = fallbackIcon;
		}
	}

	let containerClasses = $derived(
		`inline-flex items-center justify-center ${useWhiteBackground ? `bg-white rounded-md p-${background_padding}` : ''} ${className}`
	);
</script>

<div class={containerClasses} style="width: {size}px; height: {size}px;">
	<img
		bind:this={imgElement}
		src={iconUrl}
		alt="{iconName} icon"
		width={size}
		height={size}
		class="block max-h-full max-w-full"
		onerror={handleError}
	/>
</div>
