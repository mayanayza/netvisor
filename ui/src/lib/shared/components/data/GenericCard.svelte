<script lang="ts">
	import type { CardAction, CardField, TagProps } from './types';
	import Tag from './Tag.svelte';
	import type { Snippet } from 'svelte';
	import { type IconComponent } from '$lib/shared/utils/types';

	interface Props {
		title: string;
		link?: string;
		subtitle?: string;
		status?: TagProps | null;
		Icon?: IconComponent | null;
		iconColor?: string;
		actions?: CardAction[];
		fields?: CardField[];
		footer?: Snippet; // Snippet for footer
		viewMode?: 'card' | 'list';
	}

	let {
		title,
		link = '',
		subtitle = '',
		status = null,
		Icon = null,
		iconColor = 'text-blue-400',
		actions = [],
		fields = [],
		footer,
		viewMode = 'card'
	}: Props = $props();

	// Configuration for list view
	const MAX_ITEMS_IN_LIST_VIEW = 3;

	// Helper to check if value is an array
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	function isArrayValue(value: string | any[]): value is any[] {
		return Array.isArray(value);
	}
</script>

<div
	class="card flex {viewMode === 'list' ? 'flex-row items-center gap-4 p-4' : 'h-full flex-col'}"
>
	<!-- Header - Fixed width in list view -->
	<div
		class={viewMode === 'list'
			? 'flex w-64 flex-shrink-0 items-center space-x-3'
			: 'mb-4 flex items-start justify-between'}
	>
		<div class="flex items-center space-x-3 {viewMode === 'list' ? 'min-w-0 flex-1' : ''}">
			{#if Icon}
				<Icon size={viewMode === 'list' ? 20 : 28} class={iconColor} />
			{/if}
			<div>
				{#if link}
					<a
						href={link}
						class="text-primary hover:text-info {viewMode === 'list'
							? 'text-base'
							: 'text-lg'} font-semibold {viewMode === 'list' ? 'block' : ''}"
						target="_blank"
					>
						{title}
					</a>
				{:else}
					<h3 class="text-primary {viewMode === 'list' ? 'text-base' : 'text-lg'} font-semibold">
						{title}
					</h3>
				{/if}
				{#if subtitle}
					<p class="text-secondary {viewMode === 'list' ? 'truncate text-xs' : 'text-sm'}">
						{subtitle}
					</p>
				{/if}
				{#if status}
					<div class="mr-4 flex-shrink-0">
						<Tag {...status} />
					</div>
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
			<div
				class="grid flex-1 items-center gap-3"
				style="grid-template-columns: repeat({fields.length}, 1fr);"
			>
				{#each fields as field, i (field.label + i)}
					<div class="flex min-w-0 flex-col">
						<span class="text-secondary text-xs">{field.label}:</span>
						<div class="text-tertiary break-all text-xs">
							{#if field.value === null || field.value === undefined || field.value === ''}
								<span class="text-muted text-xs">—</span>
							{:else if isArrayValue(field.value)}
								{#if field.value.length > 0}
									<div class="flex flex-wrap gap-1">
										{#each field.value.slice(0, MAX_ITEMS_IN_LIST_VIEW) as item (item.id)}
											<Tag
												icon={item.icon}
												disabled={item.disabled}
												color={field.color || item.color}
												badge={item.badge}
												label={item.label}
											/>
										{/each}
										{#if field.value.length > MAX_ITEMS_IN_LIST_VIEW}
											<span class="text-tertiary flex-shrink-0 text-xs"
												>+{field.value.length - MAX_ITEMS_IN_LIST_VIEW}</span
											>
										{/if}
									</div>
								{:else}
									<span class="text-muted text-xs"
										>{field.emptyText || `No ${field.label.toLowerCase()}`}</span
									>
								{/if}
							{:else}
								{field.value}
							{/if}
						</div>
					</div>
				{/each}
			</div>
		{:else}
			<!-- Card view: vertical layout -->
			{#each fields as field, i (field.label + i)}
				<div class="text-sm">
					<span class="text-secondary">{field.label}:</span>
					{#if field.value}
						{#if isArrayValue(field.value)}
							{#if field.value.length > 0}
								<div class="ml-2 inline-flex flex-wrap items-center gap-2">
									{#each field.value as item (item.id)}
										<Tag
											icon={item.icon}
											disabled={item.disabled}
											color={field.color || item.color}
											badge={item.badge}
											label={item.label}
										/>
									{/each}
								</div>
							{:else}
								<span class="text-muted ml-2"
									>{field.emptyText || `No ${field.label.toLowerCase()}`}</span
								>
							{/if}
						{:else}
							<span class="text-tertiary ml-2 break-all">{field.value}</span>
						{/if}
					{/if}
				</div>
			{/each}
		{/if}
	</div>

	<!-- Footer Component (only in card view) -->
	{#if footer && viewMode === 'card'}
		{@render footer()}
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
					onclick={action.onClick}
					disabled={action.disabled}
					class={(action.class ? action.class : 'btn-icon') + ' ' + action.animation || ''}
					title={action.label}
				>
					<action.icon size={16} />
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
