<script lang="ts">
	import { page } from '$app/stores';
	import AuthSettingsModal from '$lib/features/auth/components/AuthSettingsModal.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { Menu, ChevronDown, History, Calendar, User } from 'lucide-svelte';
	import { onMount } from 'svelte';

	export let activeTab: string = 'hosts';
	export let onTabChange: (tab: string) => void;
	export let collapsed = false;

	let showAuthSettings = false;

	interface NavItem {
		id: string;
		label: string;
		icon: IconComponent;
		position?: 'main' | 'bottom'; // Allow items to be positioned at bottom
		onClick?: () => void | Promise<void>; // Custom click handler
	}

	interface NavSection {
		id: string;
		label: string;
		items: NavItem[];
		position?: 'main' | 'bottom';
	}

	type NavConfig = (NavSection | NavItem)[];

	const SIDEBAR_STORAGE_KEY = 'netvisor-sidebar-collapsed';

	// Configuration for navigation - can include sections or standalone items
	const navConfig: NavConfig = [
		{
			id: 'visualize',
			label: 'Visualize',
			items: [{ id: 'topology', label: 'Topology', icon: entities.getIconComponent('Topology') }]
		},
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
				{ id: 'networks', label: 'Networks', icon: entities.getIconComponent('Network') },
				{ id: 'subnets', label: 'Subnets', icon: entities.getIconComponent('Subnet') },
				{ id: 'groups', label: 'Groups', icon: entities.getIconComponent('Group') },
				{ id: 'hosts', label: 'Hosts', icon: entities.getIconComponent('Host') },
				{ id: 'services', label: 'Services', icon: entities.getIconComponent('Service') },
				{ id: 'daemons', label: 'Daemons', icon: entities.getIconComponent('Daemon') },
				{ id: 'api-keys', label: 'API Keys', icon: entities.getIconComponent('ApiKey') }
			]
		},
		// Bottom items
		{
			id: 'account',
			label: 'Account',
			icon: User as IconComponent,
			position: 'bottom',
			onClick: async () => {
				showAuthSettings = true;
			}
		}
	];

	// Track collapsed state for each section
	let sectionStates: Record<string, boolean> = {};

	// Helper to check if item is a section
	function isSection(item: NavSection | NavItem): item is NavSection {
		return 'items' in item;
	}

	// Filter nav items by position
	function filterByPosition(items: NavConfig, position: 'main' | 'bottom'): NavConfig {
		return items.filter((item) => {
			const itemPosition = isSection(item) ? item.position : item.position;
			return itemPosition === position || (position === 'main' && !itemPosition);
		});
	}

	const mainNavItems = filterByPosition(navConfig, 'main');
	const bottomNavItems = filterByPosition(navConfig, 'bottom');

	onMount(() => {
		// Load collapsed states from localStorage
		// Show auth modal
		if (typeof window !== 'undefined') {
			if ($page.url.searchParams.get('auth_modal')) {
				showAuthSettings = true;
			}

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

	function handleItemClick(item: NavItem) {
		if (item.onClick) {
			item.onClick();
		} else {
			onTabChange(item.id);
		}
	}

	const inactiveButtonClass =
		'text-tertiary hover:text-secondary hover:bg-gray-800 border border-[#15131e]';

	const sectionHeaderClass =
		'text-secondary hover:text-primary flex w-full items-center rounded-lg text-xs font-semibold uppercase tracking-wide transition-colors hover:bg-gray-800/50';

	const baseClasses = 'flex w-full items-center rounded-lg font-medium transition-colors';
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

		<!-- Main Navigation -->
		<nav class="flex-1 overflow-y-auto px-2 py-4">
			<ul class="space-y-4">
				{#each mainNavItems as configItem (configItem.id)}
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
												on:click={() => handleItemClick(item)}
												class="{baseClasses} {activeTab === item.id ||
												(item.id === 'account' && showAuthSettings)
													? 'text-primary border border-blue-600 bg-blue-700'
													: inactiveButtonClass}"
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
								on:click={() => handleItemClick(configItem)}
								class="{baseClasses} {activeTab === configItem.id ||
								(configItem.id === 'account' && showAuthSettings)
									? 'text-primary border border-blue-600 bg-blue-700'
									: inactiveButtonClass}"
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

	<!-- Bottom Navigation -->
	<div class="flex-shrink-0 border-t border-gray-700 px-2 py-4">
		<ul class="space-y-1">
			{#each bottomNavItems as item (item.id)}
				{#if !isSection(item)}
					<li>
						<button
							on:click={() => handleItemClick(item)}
							class="{baseClasses} {activeTab === item.id ||
							(item.id === 'account' && showAuthSettings)
								? 'text-primary border border-blue-600 bg-blue-700'
								: inactiveButtonClass}"
							style="height: 2.5rem; padding: 0.5rem 0.75rem;"
							title={collapsed ? item.label : ''}
						>
							<svelte:component this={item.icon} class="h-5 w-5 flex-shrink-0" />
							{#if !collapsed}
								<span class="ml-3 truncate">{item.label}</span>
							{/if}
						</button>
					</li>
				{/if}
			{/each}
		</ul>
	</div>
</div>

<AuthSettingsModal isOpen={showAuthSettings} onClose={() => (showAuthSettings = false)} />
