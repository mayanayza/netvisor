<script lang="ts">
	import {
		matchConfidenceColor,
		type MatchDetails,
		matchConfidenceLabel
	} from '$lib/shared/types';
	import Tag from '$lib/shared/components/data/Tag.svelte';

	let { details }: { details: MatchDetails } = $props();

	let confidenceColor = $derived(matchConfidenceColor(details.confidence));
</script>

<div class="flex items-center justify-between">
	<div class="text-secondary flex items-center gap-2">
		<h3 class="text-sm font-semibold">Match Details</h3>
		<span class="text-tertiary text-xs">({details.pattern_name})</span>
	</div>
	<Tag label={matchConfidenceLabel(details.confidence)} color={confidenceColor} />
</div>
