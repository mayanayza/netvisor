<script lang="ts">
	import { page } from '$app/stores';
	import AuthSettingsModal from '$lib/features/auth/components/AuthSettingsModal.svelte';
	import { currentUser } from '$lib/features/auth/store';
	import BillingSettingsModal from '$lib/features/billing/BillingSettingsModal.svelte';
	import { organization } from '$lib/features/organizations/store';
	import { isBillingPlanActive } from '$lib/features/organizations/types';
	import SupportModal from '$lib/features/support/SupportModal.svelte';
	import { entities } from '$lib/shared/stores/metadata';
	import type { IconComponent } from '$lib/shared/utils/types';
	import {
		Menu,
		ChevronDown,
		History,
		Calendar,
		User,
		LifeBuoy,
		CreditCard,
		Building
	} from 'lucide-svelte';
	import { onMount } from 'svelte';
	import type { Component } from 'svelte';
	import type { UserOrgPermissions } from '$lib/features/users/types';

	// Import tab components
	import TopologyTab from '$lib/features/topology/components/TopologyTab.svelte';
	import DiscoverySessionTab from '$lib/features/discovery/components/tabs/DiscoverySessionTab.svelte';
	import DiscoveryScheduledTab from '$lib/features/discovery/components/tabs/DiscoveryScheduledTab.svelte';
	import DiscoveryHistoryTab from '$lib/features/discovery/components/tabs/DiscoveryHistoryTab.svelte';
	import NetworksTab from '$lib/features/networks/components/NetworksTab.svelte';
	import SubnetTab from '$lib/features/subnets/components/SubnetTab.svelte';
	import GroupTab from '$lib/features/groups/components/GroupTab.svelte';
	import HostTab from '$lib/features/hosts/components/HostTab.svelte';
	import ServiceTab from '$lib/features/services/components/ServiceTab.svelte';
	import DaemonTab from '$lib/features/daemons/components/DaemonTab.svelte';
	import ApiKeyTab from '$lib/features/api_keys/components/ApiKeyTab.svelte';
	import UserTab from '$lib/features/users/components/UserTab.svelte';
	import OrganizationSettingsModal from '$lib/features/organizations/OrganizationSettingsModal.svelte';

	let {
		activeTab = $bindable('topology'),
		collapsed = $bindable(false),
		activeComponent = $bindable<Component | null>(null)
	}: {
		activeTab?: string;
		collapsed?: boolean;
		activeComponent?: Component | null;
	} = $props();

	// Derived values from stores
	let userPermissions = $derived($currentUser?.permissions);
	let isBillingEnabled = $derived($organization ? isBillingPlanActive($organization) : false);

	let showAuthSettings = $state(false);
	let showSupport = $state(false);
	let showBilling = $state(false);
	let showOrgSettings = $state(false);

	interface NavItem {
		id: string;
		label: string;
		icon: IconComponent;
		component?: Component;
		position?: 'main' | 'bottom';
		onClick?: () => void | Promise<void>;
		requiredPermissions?: UserOrgPermissions[]; // Which permissions can see this item
		requiresBilling?: boolean; // Whether this requires billing to be enabled
	}

	interface NavSection {
		id: string;
		label: string;
		items: NavItem[];
		position?: 'main' | 'bottom';
	}

	type NavConfig = (NavSection | NavItem)[];

	const SIDEBAR_STORAGE_KEY = 'netvisor-sidebar-collapsed';

	// Base navigation config (before filtering)
	const baseNavConfig: NavConfig = [
		{
			id: 'visualize',
			label: 'Visualize',
			items: [
				{
					id: 'topology',
					label: 'Topology',
					icon: entities.getIconComponent('Topology'),
					component: TopologyTab
				}
			]
		},
		{
			id: 'discover',
			label: 'Discover',
			items: [
				{
					id: 'discovery-sessions',
					label: 'Sessions',
					icon: entities.getIconComponent('Discovery'),
					component: DiscoverySessionTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'discovery-scheduled',
					label: 'Scheduled',
					icon: Calendar as IconComponent,
					component: DiscoveryScheduledTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'discovery-history',
					label: 'History',
					icon: History as IconComponent,
					component: DiscoveryHistoryTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				}
			]
		},
		{
			id: 'manage',
			label: 'Manage',
			items: [
				{
					id: 'networks',
					label: 'Networks',
					icon: entities.getIconComponent('Network'),
					component: NetworksTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'subnets',
					label: 'Subnets',
					icon: entities.getIconComponent('Subnet'),
					component: SubnetTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'groups',
					label: 'Groups',
					icon: entities.getIconComponent('Group'),
					component: GroupTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'hosts',
					label: 'Hosts',
					icon: entities.getIconComponent('Host'),
					component: HostTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'services',
					label: 'Services',
					icon: entities.getIconComponent('Service'),
					component: ServiceTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'daemons',
					label: 'Daemons',
					icon: entities.getIconComponent('Daemon'),
					component: DaemonTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'api-keys',
					label: 'API Keys',
					icon: entities.getIconComponent('ApiKey'),
					component: ApiKeyTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				},
				{
					id: 'users',
					label: 'Users',
					icon: entities.getIconComponent('User'),
					component: UserTab,
					requiredPermissions: ['Member', 'Admin', 'Owner']
				}
			]
		},
		{
			id: 'settings',
			label: 'Settings',
			items: [
				{
					id: 'account',
					label: 'Account',
					icon: User as IconComponent,
					onClick: async () => {
						showAuthSettings = true;
					}
				},
				{
					id: 'organization',
					label: 'Organization',
					icon: Building,
					requiredPermissions: ['Owner'],
					onClick: async () => {
						showOrgSettings = true;
					}
				},
				{
					id: 'billing',
					label: 'Billing',
					icon: CreditCard as IconComponent,
					onClick: async () => {
						showBilling = true;
					},
					requiredPermissions: ['Owner'],
					requiresBilling: true
				}
			]
		},
		{
			id: 'support',
			label: 'Support',
			icon: LifeBuoy,
			position: 'bottom',
			onClick: async () => {
				showSupport = true;
			}
		}
	];

	// Helper to check if user has required permissions
	function hasRequiredPermissions(item: NavItem): boolean {
		// If no permissions specified, everyone can see it
		if (!item.requiredPermissions || item.requiredPermissions.length === 0) {
			return true;
		}

		// If user has no permissions, they can't see items with permission requirements
		if (!userPermissions) {
			return false;
		}

		// Check if user's permission is in the allowed list
		return item.requiredPermissions.includes(userPermissions);
	}

	// Helper to check billing requirements
	function meetsBillingRequirement(item: NavItem): boolean {
		// If billing not required, always show
		if (!item.requiresBilling) {
			return true;
		}

		// If billing is required, check if it's enabled
		return isBillingEnabled;
	}

	// Helper to check if item should be visible
	function isItemVisible(item: NavItem): boolean {
		return hasRequiredPermissions(item) && meetsBillingRequirement(item);
	}

	// Filter nav config based on user permissions and billing status
	let navConfig = $derived.by((): NavConfig => {
		return baseNavConfig
			.map((configItem) => {
				if (isSection(configItem)) {
					// Filter items within the section
					const visibleItems = configItem.items.filter(isItemVisible);

					// Only include section if it has visible items
					if (visibleItems.length === 0) {
						return null;
					}

					return {
						...configItem,
						items: visibleItems
					};
				} else {
					// Standalone item - check if it should be visible
					return isItemVisible(configItem) ? configItem : null;
				}
			})
			.filter((item): item is NavSection | NavItem => item !== null);
	});

	// Track collapsed state for each section
	let sectionStates = $state<Record<string, boolean>>({});

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

	// Find component for a given tab ID
	function findComponentForTab(tabId: string): Component | null {
		for (const item of navConfig) {
			if (isSection(item)) {
				const found = item.items.find((i) => i.id === tabId);
				if (found?.component) return found.component;
			} else if (item.id === tabId && 'component' in item) {
				return item.component || null;
			}
		}
		return null;
	}

	// Update active component when activeTab changes
	$effect(() => {
		activeComponent = findComponentForTab(activeTab);
	});

	let mainNavItems = $derived(filterByPosition(navConfig, 'main'));
	let bottomNavItems = $derived(filterByPosition(navConfig, 'bottom'));

	onMount(() => {
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
				baseNavConfig.forEach((item) => {
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
			activeTab = item.id;
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
				onclick={toggleCollapse}
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
									onclick={() => toggleSection(configItem.id)}
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
												onclick={() => handleItemClick(item)}
												class="{baseClasses} {activeTab === item.id
													? 'text-primary border border-blue-600 bg-blue-700'
													: inactiveButtonClass}"
												style="height: 2.5rem; padding: 0.5rem 0.75rem;"
												title={collapsed ? item.label : ''}
											>
												<item.icon class="h-5 w-5 flex-shrink-0" />
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
								onclick={() => handleItemClick(configItem)}
								class="{baseClasses} {activeTab === configItem.id ||
								(configItem.id === 'account' && showAuthSettings)
									? 'text-primary border border-blue-600 bg-blue-700'
									: inactiveButtonClass}"
								style="height: 2.5rem; padding: 0.5rem 0.75rem;"
								title={collapsed ? configItem.label : ''}
							>
								<configItem.icon class="h-5 w-5 flex-shrink-0" />
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
	<div class="flex-shrink-0 border-t border-gray-700 px-2 py-2">
		<ul class="space-y-1">
			{#each bottomNavItems as item (item.id)}
				{#if !isSection(item)}
					<li>
						<button
							onclick={() => handleItemClick(item)}
							class="{baseClasses} {activeTab === item.id ||
							(item.id === 'account' && showAuthSettings)
								? 'text-primary border border-blue-600 bg-blue-700'
								: inactiveButtonClass}"
							style="height: 2.5rem; padding: 0.5rem 0.75rem;"
							title={collapsed ? item.label : ''}
						>
							<item.icon class="h-5 w-5 flex-shrink-0" />
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
<SupportModal isOpen={showSupport} onClose={() => (showSupport = false)} />
<BillingSettingsModal isOpen={showBilling} onClose={() => (showBilling = false)} />
<OrganizationSettingsModal isOpen={showOrgSettings} onClose={() => (showOrgSettings = false)} />
