<script lang="ts">
	import type { CardAction, CardField, TagProps } from './types';
	import Tag from './Tag.svelte';
	import type { Snippet } from 'svelte';
	import { type IconComponent } from '$lib/shared/utils/types';
	import GrowIconButton from './GrowIconButton.svelte';

	interface Props {
		title: string;
		link?: string;
		subtitle?: string;
		status?: TagProps | null;
		Icon?: IconComponent | null;
		iconColor?: string;
		actions?: CardAction[];
		fields?: CardField[];
		children?: Snippet;
		viewMode?: 'card' | 'list';
		selected?: boolean;
		onSelectionChange?: (selected: boolean) => void;
		selectable?: boolean;
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
		children,
		viewMode = 'card',
		selected = false,
		selectable = true,
		onSelectionChange = () => {}
	}: Props = $props();

	// Configuration for list view
	const MAX_ITEMS_IN_LIST_VIEW = 3;

	// Helper to check if value is an array
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	function isArrayValue(value: string | any[]): value is any[] {
		return Array.isArray(value);
	}

	function handleCheckboxChange(e: Event) {
		const target = e.target as HTMLInputElement;
		onSelectionChange(target.checked);
	}
</script>

<div
	class="card flex {viewMode === 'list' ? 'flex-row items-center gap-4 p-4' : 'h-full flex-col'}"
	class:ring-2={selected}
	class:ring-blue-500={selected}
>
	<!-- Checkbox (shown when selectable) -->
	{#if selectable}
		<div class="flex-shrink-0 {viewMode === 'list' ? '' : 'absolute right-4 top-4'}">
			<input
				type="checkbox"
				checked={selected}
				onchange={handleCheckboxChange}
				onclick={(e) => e.stopPropagation()}
				class="h-5 w-5 cursor-pointer rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-2 focus:ring-blue-500"
			/>
		</div>
	{/if}

	<!-- Header - Fixed width in list view -->
	<div
		class={viewMode === 'list'
			? 'flex w-64 flex-shrink-0 items-center space-x-3'
			: 'mb-4 flex items-start'}
	>
		<div class="flex items-center space-x-3 {viewMode === 'list' ? 'min-w-0 flex-1' : ''}">
			{#if Icon}
				<Icon size={viewMode === 'list' ? 20 : 28} class={iconColor} />
			{/if}
			<div class="min-w-0 flex-1">
				<div class="flex items-center gap-2">
					<div class="min-w-0 {viewMode === 'list' ? 'flex-1' : ''}">
						{#if link}
							<a
								href={link}
								class="text-primary hover:text-info {viewMode === 'list'
									? 'block truncate text-base'
									: 'text-lg'} font-semibold"
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
					</div>
					{#if status}
						<div class="flex-shrink-0">
							<Tag {...status} />
						</div>
					{/if}
				</div>
				{#if subtitle}
					<p class="text-secondary {viewMode === 'list' ? 'truncate text-xs' : 'text-sm'}">
						{subtitle}
					</p>
				{/if}
			</div>
		</div>
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
						{#if field.snippet}
							{@render field.snippet()}
						{:else}
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
						{/if}
					</div>
				{/each}
			</div>
		{:else}
			<!-- Card view: vertical layout -->
			{#each fields as field, i (field.label + i)}
				{#if field.snippet}
					<div>
						{@render field.snippet()}
					</div>
				{:else}
					<div class="text-sm">
						{#if field.value}
							{#if isArrayValue(field.value)}
								<div class="flex flex-wrap items-center gap-2">
									<span class="text-secondary">{field.label}:</span>
									{#if field.value.length > 0}
										{#each field.value as item (item.id)}
											<Tag
												icon={item.icon}
												disabled={item.disabled}
												color={field.color || item.color}
												badge={item.badge}
												label={item.label}
											/>
										{/each}
									{:else}
										<span class="text-muted"
											>{field.emptyText || `No ${field.label.toLowerCase()}`}</span
										>
									{/if}
								</div>
							{:else}
								<div class="text-sm">
									<span class="text-secondary">{field.label}: </span><span
										class="text-tertiary ml-2"
										style="word-wrap: break-word; word-break: break-word;">{field.value}</span
									>
								</div>
							{/if}
						{/if}
					</div>
				{/if}
			{/each}
		{/if}
	</div>

	<!-- Optional additional content -->
	{#if children}
		<div class={viewMode === 'list' ? 'flex items-center' : ''}>
			{@render children()}
		</div>
	{/if}

	<!-- Action Buttons - Fixed width in list view -->
	{#if actions.length > 0}
		<div
			class={viewMode === 'list'
				? 'flex w-32 flex-shrink-0 items-center justify-end gap-1'
				: 'card-divider-h mt-4 flex items-center justify-between pt-4'}
		>
			{#each actions as action, index (action.label)}
				{@const isLeftEdge = index === 0}
				{@const isRightEdge = index === actions.length - 1}
				<GrowIconButton {action} {isLeftEdge} {isRightEdge} />
			{/each}
		</div>
	{/if}
</div>
