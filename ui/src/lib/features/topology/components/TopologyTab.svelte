<script lang="ts">
	import TabHeader from '$lib/shared/components/layout/TabHeader.svelte';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import TopologyViewer from './TopologyViewer.svelte';
	import TopologyOptionsPanel from './panel/TopologyOptionsPanel.svelte';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { getTopology } from '../store';
	import { RefreshCcw } from 'lucide-svelte';
	import { getHosts } from '$lib/features/hosts/store';
	import { getServices } from '$lib/features/services/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import ExportButton from './ExportButton.svelte';
	import { SvelteFlowProvider } from '@xyflow/svelte';
	import { getGroups } from '$lib/features/groups/store';

	const loading = loadData([getHosts, getServices, getSubnets, getGroups, getTopology]);
</script>

<SvelteFlowProvider>
	<div class="space-y-6">
		<!-- Header -->
		<TabHeader
			title="Topology"
			subtitle="Generate and view network topology"
			buttons={[
				{ ButtonComponent: ExportButton },
				{ cta: 'Reload', onClick: getTopology, IconComponent: RefreshCcw }
			]}
		/>
		{#if $loading}
			<Loading />
		{:else}
			<div class="relative">
				<TopologyOptionsPanel />
				<TopologyViewer />
			</div>
		{/if}
	</div>
</SvelteFlowProvider>
