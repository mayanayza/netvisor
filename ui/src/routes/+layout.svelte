<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { checkAuth, isCheckingAuth, isAuthenticated } from '$lib/features/auth/store';
	import Loading from '$lib/shared/components/feedback/Loading.svelte';
	import '../app.css';
	import { resolve } from '$app/paths';
	import { resetTopologyOptions } from '$lib/features/topology/store';
	import { hosts } from '$lib/features/hosts/store';
	import { services } from '$lib/features/services/store';
	import { groups } from '$lib/features/groups/store';
	import { networks } from '$lib/features/networks/store';
	import { subnets } from '$lib/features/subnets/store';

	$: if (!$isAuthenticated) {
		resetTopologyOptions();
		hosts.set([]);
		services.set([]);
		subnets.set([]);
		groups.set([]);
		networks.set([]);
	}

	onMount(async () => {
		// Check authentication status
		await checkAuth();

		// Redirect to auth page if not authenticated and not already there
		if (!$isAuthenticated && $page.url.pathname !== '/auth') {
			await goto(resolve('/auth'));
		} else if ($isAuthenticated && $page.url.pathname === '/auth') {
			// Redirect to home if already authenticated and on auth page
			await goto(resolve('/'));
		}
	});
</script>

{#if $isCheckingAuth}
	<div class="flex min-h-screen items-center justify-center bg-gray-900">
		<Loading />
	</div>
{:else}
	<slot />
{/if}
