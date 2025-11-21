<script lang="ts">
	import type { IconComponent } from '$lib/shared/utils/types';

	let {
		Icon,
		label,
		cls,
		onClick = null
	}: {
		Icon: IconComponent;
		label: string;
		cls: string;
		onClick?: (() => void) | null;
	} = $props();
</script>

<button type="button" onclick={onClick} class={cls}>
	<Icon class="h-4 w-4" />
	<span>{label}</span>
</button>
