<script lang="ts">
	import type { CardAction, CardSection, CardList, TagProps } from './types';
	import Tag from './Tag.svelte';
	import type { Component } from 'svelte';
	import { type IconComponent } from '$lib/shared/utils/types';

	export let title: string;
	export let link: string = '';
	export let subtitle: string = '';
	export let status: TagProps | null = null;
	export let icon: IconComponent | null = null; // Expects Svelte component, not string
	export let iconColor: string = 'text-blue-400';
	export let actions: CardAction[] = [];
	export let sections: CardSection[] = [];
	export let lists: CardList[] = [];
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	export let footerComponent: Component<any> | null = null; // Optional footer component
	export let footerProps: Record<string, unknown> = {}; // Props to pass to footer component
	export let viewMode: 'card' | 'list' = 'card'; // View mode toggle

	// Configuration for list view
	const MAX_ITEMS_IN_LIST_VIEW = 3;
</script>

<div
	class="card flex {viewMode === 'list' ? 'flex-row items-center gap-4 p-4' : 'h-full flex-col'}"
>
	<!-- Header - Fixed width in list view -->
	<div
		class={viewMode === 'list'
			? 'flex w-48 flex-shrink-0 items-center space-x-3'
			: 'mb-4 flex items-start justify-between'}
	>
		<div class="flex items-center space-x-3 {viewMode === 'list' ? 'min-w-0 flex-1' : ''}">
			{#if icon}
				<svelte:component
					this={icon}
					size={viewMode === 'list' ? 20 : 28}
					class="{iconColor} flex-shrink-0"
				/>
			{/if}
			<div class={viewMode === 'list' ? 'min-w-0 flex-1' : ''}>
				{#if link}
					<a
						href={link}
						class="text-primary hover:text-info {viewMode === 'list'
							? 'text-base'
							: 'text-lg'} font-semibold {viewMode === 'list' ? 'block truncate' : ''}"
						target="_blank"
					>
						{title}
					</a>
				{:else}
					<h3
						class="text-primary {viewMode === 'list'
							? 'truncate text-base'
							: 'text-lg'} font-semibold"
					>
						{title}
					</h3>
				{/if}
				{#if subtitle}
					<p class="text-secondary {viewMode === 'list' ? 'truncate text-xs' : 'text-sm'}">
						{subtitle}
					</p>
				{/if}
			</div>
		</div>
		{#if status && viewMode === 'card'}
			<Tag {...status} />
		{/if}
	</div>

	<!-- Content - grows to fill available space -->
	<div class={viewMode === 'list' ? 'flex min-w-0 flex-1 items-center' : 'flex-grow space-y-3'}>
		{#if viewMode === 'list'}
			<!-- List view: horizontal layout with consistent spacing -->
			<div class="flex min-w-0 flex-1 items-center">
				<!-- Status tag in list view - Fixed width -->
				{#if status}
					<div class="mr-4 w-12 flex-shrink-0">
						<Tag {...status} />
					</div>
				{:else}
					<div class="mr-4 w-12 flex-shrink-0"></div>
				{/if}

				<!-- Sections -->
				<div class="w-15 mr-4 flex-1">
					<div class="items-left flex gap-3">
						{#each sections as section, i ((section.value, i))}
							<div class="flex flex-shrink flex-col">
								<span class="text-secondary text-xs">{section.label}:</span>
								<div class="text-tertiary ml-1 text-xs">{section.value}</div>
							</div>
						{/each}
					</div>
				</div>

				<!-- Lists - Takes remaining space with consistent layout -->
				{#if lists.length > 0}
					<div class="mr-4 flex-grow">
						<div class="flex w-full justify-evenly">
							{#each lists as list (list.label)}
								{#if list.label || list.items}
									<div class="items-left flex w-32 flex-col gap-2">
										{#if list.label}
											<span class="text-secondary flex-shrink-0 whitespace-nowrap text-xs"
												>{list.label}:</span
											>
										{/if}
										{#if list.items.length > 0}
											<div class="items-left flex min-w-0 flex-col flex-wrap gap-1">
												{#each list.items.slice(0, MAX_ITEMS_IN_LIST_VIEW) as item, i ((item.id, i))}
													<Tag
														icon={item.icon}
														disabled={item.disabled}
														color={item.color}
														badge={item.badge}
														label={item.label}
													/>
												{/each}
												{#if list.items.length > MAX_ITEMS_IN_LIST_VIEW}
													<span class="text-tertiary flex-shrink-0 text-xs"
														>+{list.items.length - MAX_ITEMS_IN_LIST_VIEW}</span
													>
												{/if}
											</div>
										{:else if list.label}
											<span class="text-muted text-xs"
												>{list.emptyText || `No ${list.label.toLowerCase()}`}</span
											>
										{/if}
									</div>
								{/if}
							{/each}
						</div>
					</div>
				{/if}
			</div>
		{:else}
			<!-- Card view: vertical layout -->
			<!-- Basic info sections -->
			{#each sections as section, i ((section.value, i))}
				<div class="text-sm">
					<span class="text-secondary">{section.label}:</span>
					<span class="text-tertiary ml-2">{section.value}</span>
				</div>
			{/each}

			<!-- List sections -->
			{#each lists as list (list.label)}
				{#if list.label || list.items}
					<div class="text-sm">
						<div class="flex flex-wrap items-center gap-2">
							{#if list.label}
								<span class="text-secondary">{list.label}:</span>
							{/if}
							{#if list.items.length > 0}
								{#each list.items as item, i ((item.id, i))}
									<div class="flex items-center justify-between">
										<div class="flex items-center space-x-2">
											<Tag
												icon={item.icon}
												disabled={item.disabled}
												color={item.color}
												badge={item.badge}
												label={item.label}
											/>
										</div>
									</div>
								{/each}
							{:else if list.label}
								<span class="text-muted">{list.emptyText || `No ${list.label.toLowerCase()}`}</span>
							{/if}
						</div>
					</div>
				{/if}
			{/each}
		{/if}
	</div>

	<!-- Footer Component (only in card view) -->
	{#if footerComponent && viewMode === 'card'}
		<div class="card-divider-h mt-4 pt-4">
			<svelte:component this={footerComponent} {...footerProps} />
		</div>
	{/if}

	<!-- Action Buttons - Fixed width in list view -->
	{#if actions.length > 0}
		<div
			class={viewMode === 'list'
				? 'flex w-32 flex-shrink-0 items-center justify-end gap-1'
				: 'card-divider-h mt-4 flex items-center justify-between pt-4'}
		>
			{#each actions as action (action.label)}
				<button
					on:click={action.onClick}
					disabled={action.disabled}
					class={(action.class ? action.class : 'btn-icon') + ' ' + action.animation || ''}
					title={action.label}
				>
					<svelte:component this={action.icon} size={16} />
				</button>
			{/each}
		</div>
	{/if}
</div>

<style>
	button:disabled {
		opacity: 0.5;
		cursor: not-allowed;
	}

	button:disabled:hover {
		background-color: transparent;
		color: inherit;
	}
</style>
