<script lang="ts">
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import Sidebar from '$lib/shared/components/layout/Sidebar.svelte';
	import { onDestroy, onMount } from 'svelte';
	import { discoverySSEManager } from '$lib/features/discovery/sse';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { getMetadata } from '$lib/shared/stores/metadata';
	import { topologySSEManager } from '$lib/features/topology/sse';

	// Read hash immediately during script initialization, before onMount
	const initialHash = typeof window !== 'undefined' ? window.location.hash.substring(1) : '';

	// TanStack Query for current user
	const currentUserQuery = useCurrentUserQuery();
	let isAuthenticated = $derived(currentUserQuery.data != null);
	let isCheckingAuth = $derived(currentUserQuery.isPending);

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

	// Initialize app when authenticated
	// TanStack Query handles data fetching in components - no need for cascading loads
	async function initializeApp() {
		if (dataLoadingStarted) return;
		dataLoadingStarted = true;

		// Load metadata (static config) - required before components render
		await getMetadata();

		// Connect SSE managers for real-time updates
		topologySSEManager.connect();
		discoverySSEManager.connect();

		appInitialized = true;
	}

	// Reactive effect: initialize app when authenticated
	// The layout handles auth check via TanStack Query, so we just wait for it to complete
	$effect(() => {
		if (isAuthenticated && !isCheckingAuth && !dataLoadingStarted) {
			initializeApp();
		}
	});

	onMount(() => {
		// Listen for hash changes (browser back/forward)
		if (typeof window !== 'undefined') {
			window.addEventListener('hashchange', handleHashChange);
		}
	});

	onDestroy(() => {
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
