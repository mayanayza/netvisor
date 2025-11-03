<script lang="ts">
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { logout } from '$lib/features/auth/store';
	import { entities } from '$lib/shared/stores/metadata';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { LogOut, Menu, ChevronDown, History, Calendar } from 'lucide-svelte';
	import { onMount } from 'svelte';

	export let activeTab: string = 'hosts';
	export let onTabChange: (tab: string) => void;
	export let collapsed = false;

	interface NavItem {
		id: string;
		label: string;
		icon: IconComponent;
	}

	interface NavSection {
		id: string;
		label: string;
		items: NavItem[];
	}

	type NavConfig = (NavSection | NavItem)[];

	const SIDEBAR_STORAGE_KEY = 'netvisor-sidebar-collapsed';

	// Configuration for navigation - can include sections or standalone items
	const navConfig: NavConfig = [
		// Standalone item (no section)
		{ id: 'topology', label: 'Topology', icon: entities.getIconComponent('Topology') },
		{
			id: 'discover',
			label: 'Discover',
			items: [
				{
					id: 'discovery-sessions',
					label: 'Sessions',
					icon: entities.getIconComponent('Discovery')
				},
				{ id: 'discovery-scheduled', label: 'Scheduled', icon: Calendar as IconComponent },
				{ id: 'discovery-history', label: 'History', icon: History as IconComponent }
			]
		},
		{
			id: 'manage',
			label: 'Manage',
			items: [
				{ id: 'daemons', label: 'Daemons', icon: entities.getIconComponent('Daemon') },
				{ id: 'networks', label: 'Networks', icon: entities.getIconComponent('Network') },
				{ id: 'subnets', label: 'Subnets', icon: entities.getIconComponent('Subnet') },
				{ id: 'groups', label: 'Groups', icon: entities.getIconComponent('Group') },
				{ id: 'hosts', label: 'Hosts', icon: entities.getIconComponent('Host') },
				{ id: 'services', label: 'Services', icon: entities.getIconComponent('Service') }
			]
		}
	];

	// Track collapsed state for each section
	let sectionStates: Record<string, boolean> = {};

	// Helper to check if item is a section
	function isSection(item: NavSection | NavItem): item is NavSection {
		return 'items' in item;
	}

	onMount(() => {
		// Load collapsed states from localStorage
		if (typeof window !== 'undefined') {
			try {
				const stored = localStorage.getItem(SIDEBAR_STORAGE_KEY);
				if (stored !== null) {
					collapsed = JSON.parse(stored);
				}

				// Load section states
				navConfig.forEach((item) => {
					if (isSection(item)) {
						const key = `netvisor-section-${item.id}-collapsed`;
						const sectionStored = localStorage.getItem(key);
						if (sectionStored !== null) {
							sectionStates[item.id] = JSON.parse(sectionStored);
						} else {
							sectionStates[item.id] = false; // Default expanded
						}
					}
				});
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

	function toggleSection(sectionId: string) {
		sectionStates[sectionId] = !sectionStates[sectionId];

		if (typeof window !== 'undefined') {
			try {
				const key = `netvisor-section-${sectionId}-collapsed`;
				localStorage.setItem(key, JSON.stringify(sectionStates[sectionId]));
			} catch (error) {
				console.error('Failed to save section state:', error);
			}
		}
	}

	const inactiveButtonClass =
		'text-tertiary hover:text-secondary hover:bg-gray-800 border border-[#15131e]';

	const sectionHeaderClass =
		'text-secondary hover:text-primary flex w-full items-center rounded-lg text-xs font-semibold uppercase tracking-wide transition-colors hover:bg-gray-800/50';
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
			<ul class="space-y-4">
				{#each navConfig as configItem (configItem.id)}
					{#if isSection(configItem)}
						<!-- Section with items -->
						<li>
							{#if !collapsed}
								<button
									on:click={() => toggleSection(configItem.id)}
									class={sectionHeaderClass}
									style="height: 2rem; padding: 0.25rem 0.75rem;"
								>
									<span class="flex-1 text-left">{configItem.label}</span>
									<ChevronDown
										class="h-4 w-4 flex-shrink-0 transition-transform {sectionStates[configItem.id]
											? '-rotate-90'
											: ''}"
									/>
								</button>
							{/if}

							{#if !sectionStates[configItem.id] || collapsed}
								<ul class="mt-1 space-y-1" class:mt-0={collapsed}>
									{#each configItem.items as item (item.id)}
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
							{/if}
						</li>
					{:else}
						<!-- Standalone item (no section, no indentation) -->
						<li>
							<button
								on:click={() => onTabChange(configItem.id)}
								class={`flex w-full items-center rounded-lg font-medium transition-colors ${
									activeTab === configItem.id
										? 'text-primary border border-blue-600 bg-blue-700'
										: inactiveButtonClass
								}`}
								style="height: 2.5rem; padding: 0.5rem 0.75rem;"
								title={collapsed ? configItem.label : ''}
							>
								<svelte:component this={configItem.icon} class="h-5 w-5 flex-shrink-0" />
								{#if !collapsed}
									<span class="ml-3 truncate">{configItem.label}</span>
								{/if}
							</button>
						</li>
					{/if}
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
