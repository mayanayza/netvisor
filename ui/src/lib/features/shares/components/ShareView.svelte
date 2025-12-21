<script lang="ts">
	import { onMount } from 'svelte';
	import {
		getPublicShareMetadata,
		getPublicShareTopology,
		verifySharePassword,
		getStoredSharePassword,
		storeSharePassword
	} from '../store';
	import type { PublicShareMetadata, ShareWithTopology } from '../types/base';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import PasswordGate from './PasswordGate.svelte';
	import ReadOnlyTopologyViewer from './ReadOnlyTopologyViewer.svelte';
	import { AlertTriangle } from 'lucide-svelte';
	import { getMetadata } from '$lib/shared/stores/metadata';

	interface Props {
		shareId: string | undefined;
		isEmbed?: boolean;
	}

	let { shareId, isEmbed = false }: Props = $props();

	let shareMetadata: PublicShareMetadata | null = $state(null);
	let topologyData: ShareWithTopology | null = $state(null);
	let loading = $state(true);
	let error: string | null = $state(null);
	let passwordVerified = $state(false);

	onMount(async () => {
		await getMetadata();
		await loadShare();
	});

	async function loadShare() {
		if (!shareId) {
			error = isEmbed ? 'Embed not found' : 'Share not found';
			loading = false;
			return;
		}

		loading = true;
		error = null;

		const metaResult = await getPublicShareMetadata(shareId);

		if (!metaResult.success || !metaResult.data) {
			error = metaResult.error || (isEmbed ? 'Embed not found' : 'Share not found');
			loading = false;
			return;
		}

		shareMetadata = metaResult.data;

		if (!shareMetadata.requires_password) {
			const topoResult = await getPublicShareTopology(shareId, { embed: isEmbed });

			if (!topoResult.success || !topoResult.data) {
				error = topoResult.error || 'Failed to load topology';
				loading = false;
				return;
			}

			topologyData = topoResult.data;
		} else {
			const storedPassword = getStoredSharePassword(shareId);
			if (storedPassword) {
				const result = await getPublicShareTopology(shareId, {
					embed: isEmbed,
					password: storedPassword
				});
				if (result.success && result.data) {
					topologyData = result.data;
				}
			}
		}

		loading = false;
	}

	async function handlePasswordSubmit(password: string): Promise<boolean> {
		if (!shareId) return false;

		const verifyResult = await verifySharePassword(shareId, password);
		if (!verifyResult.success) {
			return false;
		}

		// Password is correct - store it and close the gate
		storeSharePassword(shareId, password);
		passwordVerified = true;

		// Now try to load topology - errors will show in main view, not gate
		const topoResult = await getPublicShareTopology(shareId, { embed: isEmbed, password });
		if (topoResult.success && topoResult.data) {
			topologyData = topoResult.data;
		} else {
			error = topoResult.error || 'Failed to load topology';
		}

		return true;
	}

	function getTitle(): string {
		if (topologyData?.share.name) return topologyData.share.name;
		if (shareMetadata?.name) return shareMetadata.name;
		return isEmbed ? 'Embedded Topology' : 'Shared Topology';
	}
</script>

<svelte:head>
	<title>{getTitle()} | Scanopy</title>
	{#if isEmbed}
		<style>
			body {
				margin: 0;
				padding: 0;
				overflow: hidden;
			}
		</style>
	{/if}
</svelte:head>

<div class="{isEmbed ? 'h-screen w-screen' : 'min-h-screen'} bg-gray-900">
	{#if loading}
		<div class="flex {isEmbed ? 'h-full' : 'min-h-screen'} items-center justify-center">
			<Loading />
		</div>
	{:else if error}
		<div
			class="flex {isEmbed
				? 'h-full'
				: 'min-h-screen'} flex-col items-center justify-center gap-2 p-4 text-center"
		>
			<AlertTriangle class="h-8 w-8 text-yellow-500" />
			<p class="text-sm text-gray-400">{error}</p>
		</div>
	{:else if topologyData}
		<div class={isEmbed ? 'h-full' : 'h-screen'}>
			<ReadOnlyTopologyViewer
				topology={topologyData.topology}
				shareName={isEmbed ? undefined : topologyData.share.name}
				showControls={topologyData.share.options.show_zoom_controls}
				showInspectPanel={topologyData.share.options.show_inspect_panel}
				showExport={!isEmbed && (topologyData.share.options.show_export_button ?? true)}
				{isEmbed}
			/>
		</div>
	{/if}

	<PasswordGate
		isOpen={!!shareMetadata?.requires_password && !topologyData && !passwordVerified && !loading}
		title={shareMetadata?.name || 'Password Required'}
		onSubmit={handlePasswordSubmit}
	/>
</div>
