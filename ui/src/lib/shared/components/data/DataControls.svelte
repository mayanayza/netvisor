<script lang="ts" generics="T">
	import {
		Search,
		SlidersHorizontal,
		X,
		ChevronDown,
		ChevronUp,
		LayoutGrid,
		List,
		Trash2,
		CheckSquare,
		Square
	} from 'lucide-svelte';
	import type { FieldConfig } from './types';
	import { onMount, type Snippet } from 'svelte';
	import Tag from './Tag.svelte';
	import { SvelteMap, SvelteSet } from 'svelte/reactivity';

	let {
		items = $bindable([]),
		fields = $bindable([]),
		storageKey = null,
		onBulkDelete = null,
		allowBulkDelete = true,
		children,
		getItemId
	}: {
		items: T[];
		fields: FieldConfig<T>[];
		storageKey?: string | null;
		onBulkDelete?: ((ids: string[]) => Promise<void>) | null;
		allowBulkDelete?: boolean;
		children: Snippet<[T, 'card' | 'list', boolean, (selected: boolean) => void]>;
		getItemId: (item: T) => string;
	} = $props();

	// Search state
	let searchQuery = $state('');

	// Filter state
	interface FilterState {
		[key: string]: {
			type: 'string' | 'boolean' | 'array';
			values: SvelteSet<string>;
			showTrue?: boolean;
			showFalse?: boolean;
		};
	}

	let filterState = $state<FilterState>({});
	let showFilters = $state(false);

	// Sort state
	interface SortState {
		field: string | null;
		direction: 'asc' | 'desc';
	}

	let sortState = $state<SortState>({
		field: null,
		direction: 'asc'
	});

	// Grouping state
	let selectedGroupField = $state<string | null>(null);

	// View mode state
	let viewMode = $state<'card' | 'list'>('card');

	// Bulk selection state (always enabled when onBulkDelete is provided)
	let selectedIds = new SvelteSet<string>();

	// Serializable version of state for localStorage
	interface SerializableState {
		searchQuery: string;
		filterState: {
			[key: string]: {
				type: 'string' | 'boolean' | 'array';
				values: string[];
				showTrue?: boolean;
				showFalse?: boolean;
			};
		};
		sortState: SortState;
		selectedGroupField: string | null;
		showFilters: boolean;
		viewMode: 'card' | 'list';
	}

	// Load state from localStorage
	function loadState() {
		if (!storageKey || typeof localStorage === 'undefined') return;

		try {
			const saved = localStorage.getItem(storageKey);
			if (!saved) return;

			const state: SerializableState = JSON.parse(saved);

			// Restore search
			searchQuery = state.searchQuery || '';

			// Restore filters
			if (state.filterState) {
				const restoredFilterState: FilterState = {};
				Object.keys(state.filterState).forEach((key) => {
					const saved = state.filterState[key];
					restoredFilterState[key] = {
						...saved,
						values: new SvelteSet(saved.values)
					};
				});
				filterState = restoredFilterState;
			}

			// Restore sort
			if (state.sortState) {
				sortState = state.sortState;
			}

			// Restore grouping
			if (state.selectedGroupField) {
				selectedGroupField = state.selectedGroupField;
			}

			// Restore filter panel state
			if (state.showFilters !== undefined) {
				showFilters = state.showFilters;
			}

			// Restore view mode
			if (state.viewMode) {
				viewMode = state.viewMode;
			}
		} catch (e) {
			console.warn('Failed to load DataControls state from localStorage:', e);
		}
	}

	// Save state to localStorage
	function saveState() {
		if (!storageKey || typeof localStorage === 'undefined') return;

		try {
			const serializableFilterState: SerializableState['filterState'] = {};
			Object.keys(filterState).forEach((key) => {
				const filter = filterState[key];
				serializableFilterState[key] = {
					...filter,
					values: Array.from(filter.values)
				};
			});

			const state: SerializableState = {
				searchQuery,
				filterState: serializableFilterState,
				sortState,
				selectedGroupField,
				showFilters,
				viewMode
			};

			localStorage.setItem(storageKey, JSON.stringify(state));
		} catch (e) {
			console.warn('Failed to save DataControls state to localStorage:', e);
		}
	}

	// Initialize filter state from fields
	$effect(() => {
		fields.forEach((field) => {
			if (field.filterable && !filterState[field.key]) {
				if (field.type === 'boolean') {
					filterState[field.key] = {
						type: 'boolean',
						values: new SvelteSet(),
						showTrue: true,
						showFalse: true
					};
				} else if (field.type === 'array') {
					filterState[field.key] = {
						type: 'array',
						values: new SvelteSet()
					};
				} else {
					filterState[field.key] = {
						type: 'string',
						values: new SvelteSet()
					};
				}
			}
		});
	});

	// Load state on mount and set up auto-save
	onMount(() => {
		loadState();

		// Set up reactive save (debounced)
		let saveTimeout: ReturnType<typeof setTimeout>;

		const unsubscribe = $effect.root(() => {
			$effect(() => {
				if (storageKey) {
					// Track all state that should trigger saves
					void searchQuery;
					void filterState;
					void sortState;
					void selectedGroupField;
					void showFilters;
					void viewMode;

					// Debounce saves
					clearTimeout(saveTimeout);
					saveTimeout = setTimeout(saveState, 100);
				}
			});
		});

		return () => {
			clearTimeout(saveTimeout);
			unsubscribe();
		};
	});

	// Get value from item using field config
	function getFieldValue(
		item: T,
		field: FieldConfig<T>
	): string | boolean | Date | string[] | null {
		if (field.getValue) {
			return field.getValue(item);
		}
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		return (item as any)[field.key] ?? null;
	}

	// Get unique string values for a field (handles arrays by flattening)
	function getUniqueValues(field: FieldConfig<T>): string[] {
		const values = new SvelteSet<string>();
		items.forEach((item) => {
			const value = getFieldValue(item, field);
			if (value === null || value === undefined) return;

			if (field.type === 'array' && Array.isArray(value)) {
				value.forEach((v) => {
					if (v !== null && v !== undefined && v !== '') {
						values.add(String(v));
					}
				});
			} else if (value !== '') {
				values.add(String(value));
			}
		});
		return Array.from(values).sort();
	}

	// Get groupable fields (only string type fields, not arrays)
	let groupableFields = $derived(
		fields.filter((f) => f.type === 'string' && f.filterable !== false)
	);

	// Apply all filters, sorting, and grouping
	let processedItems = $derived.by(() => {
		let result = items.filter((item) => {
			// Search filter
			if (searchQuery.trim()) {
				const q = searchQuery.toLowerCase();
				const searchableFields = fields.filter((f) => f.searchable !== false);
				const matchesQ = searchableFields.some((field) => {
					const value = getFieldValue(item, field);
					if (value === null || value === undefined) return false;

					// Handle array values in search
					if (field.type === 'array' && Array.isArray(value)) {
						return value.some((v) => String(v).toLowerCase().includes(q));
					}

					return String(value).toLowerCase().includes(q);
				});
				if (!matchesQ) return false;
			}

			// Field filters
			const matchesF = fields.every((field) => {
				if (!field.filterable) return true;

				const filterConfig = filterState[field.key];
				if (!filterConfig) return true;

				const value = getFieldValue(item, field);

				if (field.type === 'boolean') {
					if (value === null || value === undefined) return true;
					const boolValue = Boolean(value);
					if (boolValue && !filterConfig.showTrue) return false;
					if (!boolValue && !filterConfig.showFalse) return false;
					return true;
				} else if (field.type === 'array') {
					// Array filter: item matches if ANY of its values are in the filter set
					if (filterConfig.values.size === 0) return true;
					if (!Array.isArray(value) || value.length === 0) return false;
					return value.some((v) => filterConfig.values.has(String(v)));
				} else if (field.type === 'string') {
					if (filterConfig.values.size === 0) return true;
					if (value === null || value === undefined) return false;
					return filterConfig.values.has(String(value));
				}

				return true;
			});

			return matchesF;
		});

		// Sort
		if (sortState.field) {
			const field = fields.find((f) => f.key === sortState.field);
			if (field) {
				result = [...result].sort((a, b) => {
					const aVal = getFieldValue(a, field);
					const bVal = getFieldValue(b, field);

					// Handle nulls
					if (aVal === null || aVal === undefined) return 1;
					if (bVal === null || bVal === undefined) return -1;

					let comparison = 0;

					if (field.type === 'date') {
						const aDate = aVal instanceof Date ? aVal : new Date(String(aVal));
						const bDate = bVal instanceof Date ? bVal : new Date(String(bVal));
						comparison = aDate.getTime() - bDate.getTime();
					} else if (field.type === 'boolean') {
						comparison = (aVal ? 1 : 0) - (bVal ? 1 : 0);
					} else if (field.type === 'array') {
						// Sort arrays by length, then by first element
						const aArr = aVal as string[];
						const bArr = bVal as string[];
						comparison = aArr.length - bArr.length;
						if (comparison === 0 && aArr.length > 0 && bArr.length > 0) {
							comparison = aArr[0].localeCompare(bArr[0], undefined, {
								sensitivity: 'base',
								numeric: true
							});
						}
					} else {
						// String comparison
						comparison = String(aVal).localeCompare(String(bVal), undefined, {
							sensitivity: 'base',
							numeric: true
						});
					}

					return sortState.direction === 'asc' ? comparison : -comparison;
				});
			}
		}

		return result;
	});

	// Group items by selected field
	let groupedItems = $derived.by(() => {
		if (!selectedGroupField) {
			return new SvelteMap([['All', processedItems]]);
		}

		const field = fields.find((f) => f.key === selectedGroupField);
		if (!field) {
			return new SvelteMap([['All', processedItems]]);
		}

		const groups = new SvelteMap<string, T[]>();

		processedItems.forEach((item) => {
			const value = getFieldValue(item, field);
			const groupKey = value !== null && value !== undefined ? String(value) : 'Ungrouped';

			if (!groups.has(groupKey)) {
				groups.set(groupKey, []);
			}
			groups.get(groupKey)!.push(item);
		});

		// Sort groups by key
		return new SvelteMap([...groups.entries()].sort((a, b) => a[0].localeCompare(b[0])));
	});

	// Toggle sort
	function toggleSort(fieldKey: string) {
		if (sortState.field === fieldKey) {
			sortState = {
				...sortState,
				direction: sortState.direction === 'asc' ? 'desc' : 'asc'
			};
		} else {
			sortState = {
				field: fieldKey,
				direction: 'asc'
			};
		}
	}

	// Toggle string/array filter value
	function toggleStringFilter(fieldKey: string, value: string) {
		const filter = filterState[fieldKey];
		if (!filter || (filter.type !== 'string' && filter.type !== 'array')) return;

		const newValues = new SvelteSet(filter.values);
		if (newValues.has(value)) {
			newValues.delete(value);
		} else {
			newValues.add(value);
		}

		filterState = {
			...filterState,
			[fieldKey]: {
				...filter,
				values: newValues
			}
		};
	}

	// Toggle boolean filter
	function toggleBooleanFilter(fieldKey: string, type: 'showTrue' | 'showFalse') {
		const filter = filterState[fieldKey];
		if (!filter || filter.type !== 'boolean') return;

		filterState = {
			...filterState,
			[fieldKey]: {
				...filter,
				[type]: !filter[type]
			}
		};
	}

	// Clear all filters
	function clearFilters() {
		const newFilterState: FilterState = {};

		fields.forEach((field) => {
			if (field.filterable) {
				if (field.type === 'boolean') {
					newFilterState[field.key] = {
						type: 'boolean',
						values: new SvelteSet(),
						showTrue: true,
						showFalse: true
					};
				} else if (field.type === 'array') {
					newFilterState[field.key] = {
						type: 'array',
						values: new SvelteSet()
					};
				} else {
					newFilterState[field.key] = {
						type: 'string',
						values: new SvelteSet()
					};
				}
			}
		});

		filterState = newFilterState;
	}

	// Clear search
	function clearSearch() {
		searchQuery = '';
	}

	// Clear grouping
	function clearGrouping() {
		selectedGroupField = null;
	}

	// Select all visible items
	function selectAll() {
		processedItems.forEach((item) => {
			const itemId = getItemId(item);
			if (itemId) selectedIds.add(itemId);
		});
	}

	// Deselect all items
	function selectNone() {
		selectedIds.clear();
	}

	// Handle bulk delete
	async function handleBulkDelete() {
		if (!allowBulkDelete) return;
		if (!onBulkDelete || selectedIds.size === 0) return;

		try {
			await onBulkDelete(Array.from(selectedIds));
			selectedIds.clear();
		} catch (error) {
			console.error('Bulk delete failed:', error);
		}
	}

	// Derived states
	let allSelected = $derived(
		processedItems.length > 0 && selectedIds.size === processedItems.length
	);

	// Check if any filters are active
	let hasActiveFilters = $derived(
		fields.some((field) => {
			if (!field.filterable) return false;
			const filter = filterState[field.key];
			if (!filter) return false;

			if (field.type === 'boolean') {
				return !filter.showTrue || !filter.showFalse;
			} else {
				return filter.values.size > 0;
			}
		})
	);

	let hasActiveSearch = $derived(searchQuery.trim().length > 0);
	let hasActiveGrouping = $derived(selectedGroupField !== null);
</script>

<div class="space-y-4">
	<!-- Search and Filter Controls Bar -->
	<div class="flex items-center gap-3">
		<!-- Search Input -->
		<div class="relative flex-1">
			<Search class="text-tertiary absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2" />
			<input
				type="text"
				bind:value={searchQuery}
				placeholder="Search..."
				class="input-field w-full pl-10 pr-10"
			/>
			{#if hasActiveSearch}
				<button
					onclick={clearSearch}
					class="text-tertiary hover:text-secondary absolute right-3 top-1/2 -translate-y-1/2 transition-colors"
				>
					<X class="h-4 w-4" />
				</button>
			{/if}
		</div>

		<!-- Filter Toggle Button -->
		{#if fields.some((f) => f.filterable)}
			<button
				onclick={() => (showFilters = !showFilters)}
				class="btn-secondary flex items-center gap-2"
			>
				<SlidersHorizontal class="h-4 w-4" />
				Filters
				{#if hasActiveFilters}
					<Tag label="Active" color="Blue" />
				{/if}
			</button>
		{/if}

		<!-- Select All/None Buttons (only show if onBulkDelete is provided) -->
		{#if onBulkDelete}
			<button
				onclick={allSelected ? selectNone : selectAll}
				class="btn-secondary flex items-center gap-2"
				title={allSelected ? 'Deselect all' : 'Select all'}
			>
				{#if allSelected}
					<Square class="h-4 w-4" />
				{:else}
					<CheckSquare class="h-4 w-4" />
				{/if}
				{allSelected ? 'None' : 'All'}
			</button>
		{/if}

		<!-- View Mode Toggle -->
		<button
			onclick={() => (viewMode = viewMode === 'card' ? 'list' : 'card')}
			class="btn-secondary flex items-center gap-2"
			title={viewMode === 'card' ? 'Switch to list view' : 'Switch to card view'}
		>
			{#if viewMode === 'card'}
				<List class="h-4 w-4" />
			{:else}
				<LayoutGrid class="h-4 w-4" />
			{/if}
		</button>

		<!-- Group By Dropdown -->
		{#if groupableFields.length > 0}
			<div class="relative">
				<select bind:value={selectedGroupField} class="input-field appearance-none pr-8">
					<option value={null}>No grouping</option>
					{#each groupableFields as field (field.key)}
						<option value={field.key}>Group by {field.label}</option>
					{/each}
				</select>
				{#if hasActiveGrouping}
					<button
						onclick={clearGrouping}
						class="text-tertiary hover:text-secondary absolute right-8 top-1/2 -translate-y-1/2 transition-colors"
					>
						<X class="h-3 w-3" />
					</button>
				{/if}
			</div>
		{/if}

		<!-- Sort Dropdown -->
		{#if fields.some((f) => f.sortable !== false)}
			<div class="relative">
				<select
					bind:value={sortState.field}
					onchange={() => {
						if (!sortState.field) sortState = { ...sortState, direction: 'asc' };
					}}
					class="input-field appearance-none pr-8"
				>
					<option value={null}>Sort by...</option>
					{#each fields.filter((f) => f.sortable !== false) as field (field.key)}
						<option value={field.key}>{field.label}</option>
					{/each}
				</select>
			</div>
		{/if}

		<!-- Sort Direction Toggle -->
		{#if sortState.field}
			<button onclick={() => toggleSort(sortState.field || '')} class="btn-secondary">
				{#if sortState.direction === 'asc'}
					<ChevronUp class="h-4 w-4" />
				{:else}
					<ChevronDown class="h-4 w-4" />
				{/if}
			</button>
		{/if}
	</div>

	<!-- Bulk Action Bar (shown when items are selected) -->
	{#if onBulkDelete && selectedIds.size > 0}
		<div class="card flex items-center justify-between p-4">
			<div class="flex items-center gap-4">
				<span class="text-primary text-sm font-medium">
					{selectedIds.size}
					{selectedIds.size === 1 ? 'item' : 'items'} selected
				</span>
				<button
					onclick={selectNone}
					class="text-tertiary hover:text-secondary text-sm transition-colors"
				>
					Clear selection
				</button>
			</div>
			{#if allowBulkDelete}
				<button onclick={handleBulkDelete} class="btn-danger flex items-center gap-2">
					<Trash2 class="h-4 w-4" />
					Delete Selected
				</button>
			{/if}
		</div>
	{/if}

	<!-- Filter Panel -->
	{#if showFilters}
		<div class="card space-y-4 p-4">
			<div class="flex items-center justify-between">
				<h3 class="text-primary text-sm font-semibold">Filters</h3>
				{#if hasActiveFilters}
					<button
						onclick={clearFilters}
						class="text-tertiary hover:text-secondary text-xs transition-colors"
					>
						Clear all
					</button>
				{/if}
			</div>

			<div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
				{#each fields.filter((f) => f.filterable) as field (field.key)}
					<div class="space-y-2">
						<div class="text-secondary text-sm font-medium">{field.label}</div>

						{#if field.type === 'boolean'}
							{@const filter = filterState[field.key]}
							<div class="space-y-1">
								<label class="flex items-center gap-2">
									<input
										type="checkbox"
										checked={filter?.showTrue}
										onchange={() => toggleBooleanFilter(field.key, 'showTrue')}
										class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-2 focus:ring-blue-500"
									/>
									<span class="text-secondary text-sm">Show True</span>
								</label>
								<label class="flex items-center gap-2">
									<input
										type="checkbox"
										checked={filter?.showFalse}
										onchange={() => toggleBooleanFilter(field.key, 'showFalse')}
										class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-2 focus:ring-blue-500"
									/>
									<span class="text-secondary text-sm">Show False</span>
								</label>
							</div>
						{:else}
							{@const uniqueValues = getUniqueValues(field)}
							{@const filter = filterState[field.key]}
							<div
								class="max-h-40 space-y-1 overflow-y-auto rounded border border-gray-600 bg-gray-800 p-2"
							>
								{#if uniqueValues.length === 0}
									<p class="text-tertiary text-xs">No values available</p>
								{:else}
									{#each uniqueValues as value (value)}
										<label class="flex items-center gap-2">
											<input
												type="checkbox"
												checked={filter?.values.has(value)}
												onchange={() => toggleStringFilter(field.key, value)}
												class="h-4 w-4 rounded border-gray-600 bg-gray-700 text-blue-600 focus:ring-2 focus:ring-blue-500"
											/>
											<span class="text-secondary truncate text-sm" title={value}>{value}</span>
										</label>
									{/each}
								{/if}
							</div>
						{/if}
					</div>
				{/each}
			</div>
		</div>
	{/if}

	<!-- Results Count -->
	<div class="text-tertiary flex items-center justify-between text-sm">
		<span>
			Showing {processedItems.length} of {items.length}
			{items.length === 1 ? 'item' : 'items'}
		</span>
		{#if hasActiveGrouping}
			<span>
				{groupedItems.size}
				{groupedItems.size === 1 ? 'group' : 'groups'}
			</span>
		{/if}
	</div>

	<!-- Content -->
	{#if hasActiveGrouping}
		<!-- Grouped view -->
		<div class="space-y-6">
			{#each [...groupedItems.entries()] as [groupName, groupItems] (groupName)}
				<div class="space-y-3">
					<!-- Group Header -->
					<div class="flex items-center gap-3">
						<h3 class="text-primary text-lg font-semibold">{groupName}</h3>
						<span class="text-tertiary text-sm">({groupItems.length})</span>
					</div>

					<!-- Group Items -->
					<div
						class={viewMode === 'list'
							? 'space-y-2'
							: 'grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3'}
					>
						{#each groupItems as item (item)}
							<!-- eslint-disable-next-line @typescript-eslint/no-explicit-any -->
							{@const itemId = getItemId(item)}
							{@const isSelected = selectedIds.has(itemId)}
							{@render children(item, viewMode, isSelected, (selected) => {
								if (selected) {
									selectedIds.add(itemId);
								} else {
									selectedIds.delete(itemId);
								}
							})}
						{/each}
					</div>
				</div>
			{/each}
		</div>
	{:else}
		<!-- Ungrouped view -->
		<div
			class={viewMode === 'list'
				? 'space-y-2'
				: 'grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3'}
		>
			{#each processedItems as item (item)}
				{@const itemId = getItemId(item)}
				{@const isSelected = selectedIds.has(itemId)}
				{@render children(item, viewMode, isSelected, (selected) => {
					if (selected) {
						selectedIds.add(itemId);
					} else {
						selectedIds.delete(itemId);
					}
				})}
			{/each}
		</div>
	{/if}
</div>
