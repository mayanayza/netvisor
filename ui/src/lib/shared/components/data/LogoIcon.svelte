<script lang="ts">
	type IconSource = 'vector_zone_icons' | 'simple_icons' | 'dashboard_icons' | 'static_file_icon';

	let {
		size = 24,
		class: className = '',
		iconName,
		iconSource,
		use_white_background = false
	}: {
		size?: number;
		class?: string;
		iconName: string;
		iconSource: IconSource;
		use_white_background?: boolean;
	} = $props();

	let background_padding = 1;
	size = use_white_background ? size : size - 2 * background_padding;

	const sourceUrls: Record<IconSource, (name: string) => string> = {
		vector_zone_icons: (name) => `https://www.vectorlogo.zone/logos/${name}.svg`,
		simple_icons: (name) => `https://cdn.simpleicons.org/${name}`,
		dashboard_icons: (name) =>
			`https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/${name}.svg`,
		static_file_icon: (name) => `/logos/${name}`
	};

	let iconUrl = $derived(sourceUrls[iconSource](iconName));

	const fallbackIcon =
		'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTIiIGN5PSIxMiIgcj0iMTAiIHN0cm9rZT0iY3VycmVudENvbG9yIiBzdHJva2Utd2lkdGg9IjIiLz4KPHA=';

	let imgElement: HTMLImageElement | undefined = $state();

	function handleError() {
		if (imgElement) {
			imgElement.src = fallbackIcon;
		}
	}

	let containerClasses = $derived(
		`inline-flex items-center justify-center ${use_white_background ? `bg-white rounded-md p-${background_padding}` : ''} ${className}`
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
