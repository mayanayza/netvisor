<script lang="ts">
	import { groups } from '$lib/features/groups/store';
	import { hosts } from '$lib/features/hosts/store';
	import { getSubnets } from '$lib/features/subnets/store';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import Sidebar from '$lib/shared/components/layout/Sidebar.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { getServices, services } from '$lib/features/services/store';
	import { getNetworks } from '$lib/features/networks/store';
	import { discoverySSEManager } from '$lib/features/discovery/sse';
	import { isAuthenticated, isCheckingAuth } from '$lib/features/auth/store';
	import { getMetadata } from '$lib/shared/stores/metadata';
	import { topologySSEManager } from '$lib/features/topology/sse';

	// Read hash immediately during script initialization, before onMount
	const initialHash = typeof window !== 'undefined' ? window.location.hash.substring(1) : '';

	let activeTab = $state(initialHash || 'topology');
	let appInitialized = $state(false);
	let sidebarCollapsed = $state(false);
	let dataLoadingStarted = $state(false);
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	let allTabs = $state<Array<{ id: string; component: any }>>([]);

	// Update URL hash when activeTab changes
	$effect(() => {
		if (typeof window !== 'undefined' && activeTab) {
			window.location.hash = activeTab;
		}
	});

	// Function to handle browser navigation (back/forward)
	function handleHashChange() {
		if (typeof window !== 'undefined') {
			const hash = window.location.hash.substring(1);
			if (hash && hash !== activeTab) {
				activeTab = hash;
			}
		}
	}

	let storeWatcherUnsubs: (() => void)[] = [];

	// Load data only when authenticated
	async function loadData() {
		if (dataLoadingStarted) return;
		dataLoadingStarted = true;

		await Promise.all([getNetworks(), getMetadata()]);

		// Set up store watchers for cascading data loads
		let hostsInitialized = false;
		let servicesInitialized = false;
		let groupsInitialized = false;

		storeWatcherUnsubs = [
			hosts.subscribe(() => {
				if (hostsInitialized) {
					getServices();
					getSubnets();
				}
				hostsInitialized = true;
			}),
			services.subscribe(() => {
				if (servicesInitialized) {
					getSubnets();
				}
				servicesInitialized = true;
			}),
			groups.subscribe(() => {
				if (groupsInitialized) {
					getServices();
				}
				groupsInitialized = true;
			})
		];

		topologySSEManager.connect();
		discoverySSEManager.connect();

		appInitialized = true;
	}

	// Reactive effect: load data when authenticated
	// The layout handles checkAuth(), so we just wait for it to complete
	$effect(() => {
		if ($isAuthenticated && !$isCheckingAuth && !dataLoadingStarted) {
			loadData();
		}
	});

	onMount(() => {
		// Listen for hash changes (browser back/forward)
		if (typeof window !== 'undefined') {
			window.addEventListener('hashchange', handleHashChange);
		}
	});

	onDestroy(() => {
		storeWatcherUnsubs.forEach((unsub) => {
			unsub();
		});

		topologySSEManager.disconnect();
		discoverySSEManager.disconnect();

		if (typeof window !== 'undefined') {
			window.removeEventListener('hashchange', handleHashChange);
		}
	});
</script>

{#if appInitialized}
	<div class="flex min-h-screen">
		<!-- Sidebar -->
		<div class="flex-shrink-0">
			<Sidebar bind:activeTab bind:collapsed={sidebarCollapsed} bind:allTabs />
		</div>

		<!-- Main Content -->
		<main
			class="flex-1 overflow-auto transition-all duration-300"
			class:ml-16={sidebarCollapsed}
			class:ml-64={!sidebarCollapsed}
		>
			<div class="p-8">
				<!-- Programmatically render all tabs based on sidebar config -->
				{#each allTabs as tab (tab.id)}
					<div class:hidden={activeTab !== tab.id}>
						<tab.component />
					</div>
				{/each}
			</div>

			<Toast />
		</main>
	</div>
{:else}
	<!-- Data still loading -->
	<Loading />
{/if}
