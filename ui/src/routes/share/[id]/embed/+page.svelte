<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import {
		getPublicShareMetadata,
		getPublicShareTopology,
		verifySharePassword,
		getStoredSharePassword,
		storeSharePassword
	} from '$lib/features/shares/store';
	import type { PublicShareMetadata, ShareWithTopology } from '$lib/features/shares/types/base';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import ReadOnlyTopologyViewer from '$lib/features/shares/components/ReadOnlyTopologyViewer.svelte';
	import PasswordGate from '$lib/features/shares/components/PasswordGate.svelte';
	import { AlertTriangle } from 'lucide-svelte';
	import { getMetadata } from '$lib/shared/stores/metadata';

	let shareId = $derived($page.params.id);
	let shareMetadata: PublicShareMetadata | null = $state(null);
	let topologyData: ShareWithTopology | null = $state(null);
	let loading = $state(true);
	let error: string | null = $state(null);

	onMount(async () => {
		// Load metadata for service icons, edge types, etc.
		await getMetadata();
		await loadShare();
	});

	async function loadShare() {
		if (!shareId) {
			error = 'Embed not found';
			loading = false;
			return;
		}

		loading = true;
		error = null;

		// First, get share metadata to check if password is required
		const metaResult = await getPublicShareMetadata(shareId);

		if (!metaResult.success || !metaResult.data) {
			error = metaResult.error || 'Embed not found';
			loading = false;
			return;
		}

		shareMetadata = metaResult.data;

		// If no password required, fetch topology directly
		if (!shareMetadata.requires_password) {
			const topoResult = await getPublicShareTopology(shareId);

			if (!topoResult.success || !topoResult.data) {
				error = topoResult.error || 'Failed to load topology';
				loading = false;
				return;
			}

			topologyData = topoResult.data;
		} else {
			// Check for stored password and auto-verify
			const storedPassword = getStoredSharePassword(shareId);
			if (storedPassword) {
				const result = await verifySharePassword(shareId, storedPassword);
				if (result.success && result.data) {
					topologyData = result.data;
				}
				// If verification fails, stored password is invalid - user will see password gate
			}
		}

		loading = false;
	}

	async function handlePasswordSubmit(password: string): Promise<boolean> {
		if (!shareId) return false;
		const result = await verifySharePassword(shareId, password);

		if (result.success && result.data) {
			topologyData = result.data;
			storeSharePassword(shareId, password);
			return true;
		}

		return false;
	}
</script>

<svelte:head>
	<title>{topologyData?.share.name || 'Embedded Topology'} | Scanopy</title>
	<style>
		body {
			margin: 0;
			padding: 0;
			overflow: hidden;
		}
	</style>
</svelte:head>

<div class="h-screen w-screen bg-gray-900">
	{#if loading}
		<div class="flex h-full items-center justify-center">
			<Loading />
		</div>
	{:else if error}
		<div class="flex h-full flex-col items-center justify-center gap-2 p-4 text-center">
			<AlertTriangle class="h-8 w-8 text-yellow-500" />
			<p class="text-sm text-gray-400">{error}</p>
		</div>
	{:else if topologyData}
		<ReadOnlyTopologyViewer
			topology={topologyData.topology}
			showControls={topologyData.share.embed_options.show_zoom_controls}
			showInspectPanel={topologyData.share.embed_options.show_inspect_panel}
			isEmbed={true}
		/>
	{/if}

	<PasswordGate
		isOpen={!!shareMetadata?.requires_password && !topologyData && !loading}
		title={shareMetadata?.name || 'Password Required'}
		subtitle="This embed is password protected"
		onSubmit={handlePasswordSubmit}
	/>
</div>
