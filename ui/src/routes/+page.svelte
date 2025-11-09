<script lang="ts">
	import GroupTab from '$lib/features/groups/components/GroupTab.svelte';
	import { groups } from '$lib/features/groups/store';
	import HostTab from '$lib/features/hosts/components/HostTab.svelte';
	import TopologyTab from '$lib/features/topology/components/TopologyTab.svelte';
	import { hosts } from '$lib/features/hosts/store';
	import SubnetTab from '$lib/features/subnets/components/SubnetTab.svelte';
	import { getSubnets } from '$lib/features/subnets/store';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import Sidebar from '$lib/shared/components/layout/Sidebar.svelte';
	import { getMetadata } from '$lib/shared/stores/metadata';
	import { onDestroy, onMount } from 'svelte';
	import { getServices, services } from '$lib/features/services/store';
	import { watchStores } from '$lib/shared/utils/storeWatcher';
	import { getNetworks } from '$lib/features/networks/store';
	import { startDiscoverySSE } from '$lib/features/discovery/SSEStore';
	import NetworksTab from '$lib/features/networks/components/NetworksTab.svelte';
	import { isAuthenticated, isCheckingAuth } from '$lib/features/auth/store';
	import ServiceTab from '$lib/features/services/components/ServiceTab.svelte';
	import DaemonTab from '$lib/features/daemons/components/DaemonTab.svelte';
	import DiscoverySessionTab from '$lib/features/discovery/components/tabs/DiscoverySessionTab.svelte';
	import DiscoveryHistoryTab from '$lib/features/discovery/components/tabs/DiscoveryHistoryTab.svelte';
	import DiscoveryScheduledTab from '$lib/features/discovery/components/tabs/DiscoveryScheduledTab.svelte';
	import ApiKeyTab from '$lib/features/api_keys/components/ApiKeyTab.svelte';

	let activeTab = 'topology';
	let appInitialized = false;
	let sidebarCollapsed = false;
	let dataLoadingStarted = false;

	// Valid tab names for validation
	const validTabs = [
		'discovery-sessions',
		'discovery-scheduled',
		'discovery-history',
		'api-keys',
		'daemons',
		'networks',
		'hosts',
		'services',
		'subnets',
		'groups',
		'topology'
	];

	// Function to get initial tab from URL hash
	function getInitialTab(): string {
		if (typeof window !== 'undefined') {
			const hash = window.location.hash.substring(1); // Remove the #
			return validTabs.includes(hash) ? hash : 'topology';
		}
		return 'topology';
	}

	function handleTabChange(tab: string) {
		if (validTabs.includes(tab)) {
			activeTab = tab;

			// Update URL hash without triggering page reload
			if (typeof window !== 'undefined') {
				window.location.hash = tab;
			}
		}
	}

	// Function to handle browser navigation (back/forward)
	function handleHashChange() {
		if (typeof window !== 'undefined') {
			const hash = window.location.hash.substring(1);
			if (validTabs.includes(hash) && hash !== activeTab) {
				activeTab = hash;
			}
		}
	}

	let storeWatcherUnsubs: (() => void)[] = [];

	// Load data only when authenticated
	async function loadData() {
		if (dataLoadingStarted) return;
		dataLoadingStarted = true;

		await getNetworks();

		// Load initial data
		storeWatcherUnsubs = [
			watchStores([hosts], () => {
				getServices();
			}),
			watchStores([hosts, services], () => {
				getSubnets();
			}),
			watchStores([groups], () => {
				getServices();
			})
		].flatMap((w) => w);

		startDiscoverySSE();

		await getMetadata().then(() => (appInitialized = true));
	}

	// Reactive effect: load data when authenticated
	// The layout handles checkAuth(), so we just wait for it to complete
	$: if ($isAuthenticated && !$isCheckingAuth && !dataLoadingStarted) {
		loadData();
	}

	onMount(() => {
		// Set initial tab from URL hash
		activeTab = getInitialTab();

		// Listen for hash changes (browser back/forward)
		if (typeof window !== 'undefined') {
			window.addEventListener('hashchange', handleHashChange);
		}
	});

	onDestroy(() => {
		storeWatcherUnsubs.forEach((unsub) => {
			unsub();
		});

		if (typeof window !== 'undefined') {
			window.removeEventListener('hashchange', handleHashChange);
		}
	});
</script>

{#if appInitialized}
	<div class="flex min-h-screen">
		<!-- Sidebar -->
		<div class="flex-shrink-0">
			<Sidebar {activeTab} onTabChange={handleTabChange} bind:collapsed={sidebarCollapsed} />
		</div>

		<!-- Main Content -->
		<main
			class="flex-1 overflow-auto transition-all duration-300"
			class:ml-16={sidebarCollapsed}
			class:ml-64={!sidebarCollapsed}
		>
			<div class="p-8">
				{#if activeTab === 'discovery-sessions'}
					<DiscoverySessionTab />
				{:else if activeTab === 'discovery-scheduled'}
					<DiscoveryScheduledTab />
				{:else if activeTab === 'discovery-history'}
					<DiscoveryHistoryTab />
				{:else if activeTab === 'daemons'}
					<DaemonTab />
				{:else if activeTab === 'networks'}
					<NetworksTab />
				{:else if activeTab === 'hosts'}
					<HostTab />
				{:else if activeTab === 'services'}
					<ServiceTab />
				{:else if activeTab === 'subnets'}
					<SubnetTab />
				{:else if activeTab === 'groups'}
					<GroupTab />
				{:else if activeTab === 'api-keys'}
					<ApiKeyTab />
				{:else if activeTab === 'topology'}
					<TopologyTab />
				{/if}
			</div>

			<Toast />
		</main>
	</div>
{:else}
	<!-- Data still loading -->
	<Loading />
{/if}
