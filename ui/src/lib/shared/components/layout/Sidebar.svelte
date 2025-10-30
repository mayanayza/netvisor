<script lang="ts">
	import { goto } from '$app/navigation';
	import { resolve } from '$app/paths';
	import { logout } from '$lib/features/auth/store';
	import { entities } from '$lib/shared/stores/metadata';
	import { LogOut } from 'lucide-svelte';

	export let activeTab: string = 'hosts';
	export let onTabChange: (tab: string) => void;

	const navItems = [
		{ id: 'networks', label: 'Networks', icon: entities.getIconComponent('Network') },
		{ id: 'discovery', label: 'Discovery', icon: entities.getIconComponent('Discovery') },
		{ id: 'hosts', label: 'Hosts', icon: entities.getIconComponent('Host') },
		{ id: 'subnets', label: 'Subnets', icon: entities.getIconComponent('Subnet') },
		{ id: 'groups', label: 'Groups', icon: entities.getIconComponent('Group') },
		{ id: 'topology', label: 'Topology', icon: entities.getIconComponent('Topology') }
	];

	async function onLogoutClick() {
		logout();
		await goto(resolve('/auth'));
	}

	const inactiveButtonClass = 'text-tertiary hover:text-secondary hover:bg-gray-800';
</script>

<div class="sidebar flex flex-col justify-end">
	<!-- Logo/Brand -->
	<div class="flex-1">
		<div class="sidebar-section">
			<h1 class="text-primary text-xl font-bold">NetVisor</h1>
		</div>

		<!-- Navigation -->
		<nav class="flex-1 p-4">
			<ul class="space-y-2">
				{#each navItems as item (item.id)}
					<li>
						<button
							on:click={() => onTabChange(item.id)}
							class={`flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left font-medium transition-colors ${
								activeTab === item.id
									? 'text-primary border border-blue-600 bg-blue-700'
									: inactiveButtonClass
							}`}
						>
							<svelte:component this={item.icon} class="h-5 w-5" />
							{item.label}
						</button>
					</li>
				{/each}
			</ul>
		</nav>
	</div>

	<div class="p-4">
		<button
			class={`flex w-full items-center gap-3 rounded-lg px-3 py-2 text-left font-medium ${inactiveButtonClass}`}
			on:click={onLogoutClick}
		>
			<LogOut class="h-5 w-5" />
			<div class="ml-2">Log Out</div>
		</button>
	</div>
</div>
