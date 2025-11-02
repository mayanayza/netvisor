<script lang="ts">
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { logout } from '$lib/features/auth/store';
	import { entities } from '$lib/shared/stores/metadata';
	import { LogOut, Menu } from 'lucide-svelte';
	import { onMount } from 'svelte';

	export let activeTab: string = 'hosts';
	export let onTabChange: (tab: string) => void;
	export let collapsed = false;

	const SIDEBAR_STORAGE_KEY = 'netvisor-sidebar-collapsed';

	const navItems = [
		{ id: 'discovery', label: 'Discovery', icon: entities.getIconComponent('Discovery') },
		{ id: 'daemons', label: 'Daemons', icon: entities.getIconComponent('Daemon') },
		{ id: 'networks', label: 'Networks', icon: entities.getIconComponent('Network') },
		{ id: 'subnets', label: 'Subnets', icon: entities.getIconComponent('Subnet') },
		{ id: 'groups', label: 'Groups', icon: entities.getIconComponent('Group') },
		{ id: 'hosts', label: 'Hosts', icon: entities.getIconComponent('Host') },
		{ id: 'services', label: 'Services', icon: entities.getIconComponent('Service') },
		{ id: 'topology', label: 'Topology', icon: entities.getIconComponent('Topology') }
	];

	onMount(() => {
		// Load collapsed state from localStorage
		if (typeof window !== 'undefined') {
			try {
				const stored = localStorage.getItem(SIDEBAR_STORAGE_KEY);
				if (stored !== null) {
					collapsed = JSON.parse(stored);
				}
			} catch (error) {
				console.warn('Failed to load sidebar state from localStorage:', error);
			}
		}
	});

	async function onLogoutClick() {
		logout();
		await goto(resolve('/auth'));
	}

	function toggleCollapse() {
		collapsed = !collapsed;

		// Save to localStorage
		if (typeof window !== 'undefined') {
			try {
				localStorage.setItem(SIDEBAR_STORAGE_KEY, JSON.stringify(collapsed));
			} catch (error) {
				console.error('Failed to save sidebar state to localStorage:', error);
			}
		}
	}

	const inactiveButtonClass =
		'text-tertiary hover:text-secondary hover:bg-gray-800 border border-[#15131e]';
</script>

<div
	class="sidebar flex flex-shrink-0 flex-col transition-all duration-300"
	class:w-16={collapsed}
	class:w-64={!collapsed}
>
	<!-- Logo/Brand -->
	<div class="flex min-h-0 flex-1 flex-col">
		<div class="border-b border-gray-700 px-2 py-4">
			<button
				on:click={toggleCollapse}
				class="text-tertiary hover:text-secondary flex w-full items-center rounded-lg transition-colors hover:bg-gray-800"
				style="height: 2.5rem; padding: 0.5rem 0.75rem;"
				aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
			>
				<Menu class="h-5 w-5 flex-shrink-0" />
				{#if !collapsed}
					<div class="absolute left-1/2 flex -translate-x-1/2 transform items-center">
						<img src="/logos/netvisor-logo.png" alt="Logo" class="h-8 w-auto" />
						<h1 class="text-primary ml-3 truncate whitespace-nowrap text-xl font-bold">NetVisor</h1>
					</div>
				{/if}
			</button>
		</div>

		<!-- Navigation -->
		<nav class="flex-1 overflow-y-auto px-2 py-4">
			<ul class="space-y-1">
				{#each navItems as item (item.id)}
					<li>
						<button
							on:click={() => onTabChange(item.id)}
							class={`flex w-full items-center rounded-lg font-medium transition-colors ${
								activeTab === item.id
									? 'text-primary border border-blue-600 bg-blue-700'
									: inactiveButtonClass
							}`}
							style="height: 2.5rem; padding: 0.5rem 0.75rem;"
							title={collapsed ? item.label : ''}
						>
							<svelte:component this={item.icon} class="h-5 w-5 flex-shrink-0" />
							{#if !collapsed}
								<span class="ml-3 truncate">{item.label}</span>
							{/if}
						</button>
					</li>
				{/each}
			</ul>
		</nav>
	</div>

	<div class="flex-shrink-0 px-2 py-4">
		<button
			class={`flex w-full items-center rounded-lg font-medium transition-colors ${inactiveButtonClass}`}
			style="min-height: 2.5rem; padding: 0.5rem 0.75rem;"
			on:click={onLogoutClick}
			title={collapsed ? 'Log Out' : ''}
		>
			<LogOut class="h-5 w-5 flex-shrink-0" />
			{#if !collapsed}
				<span class="ml-3 truncate">Log Out</span>
			{/if}
		</button>
	</div>
</div>
