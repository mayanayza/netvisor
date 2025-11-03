<script lang="ts" generics="V, C">
	import { ChevronDown } from 'lucide-svelte';
	import ListSelectItem from './ListSelectItem.svelte';
	import type { EntityDisplayComponent } from './types';
	import { tick } from 'svelte';
	import { SvelteMap } from 'svelte/reactivity';

	export let label: string = '';
	export let selectedValue: string | null = '';
	export let options: V[] = [];
	export let placeholder: string = 'Select an option...';
	export let required: boolean = false;
	export let disabled: boolean = false;
	export let error: string | null = null;
	export let onSelect: (value: string) => void;
	export let showSearch: boolean = false;
	export let displayComponent: EntityDisplayComponent<V, C>;
	export let getOptionContext: (option: V, index: number) => C = () => new Object() as C;

	let isOpen = false;
	let dropdownElement: HTMLDivElement;
	let triggerElement: HTMLButtonElement;
	let inputElement: HTMLInputElement;
	let dropdownPosition = { top: 0, left: 0, width: 0 };
	let openUpward = false;
	let filterText = '';

	$: selectedItem = options.find((i) => displayComponent.getId(i) === selectedValue);

	// Filter options based on search text
	$: filteredOptions = options.filter((option, index) => {
		if (!filterText.trim()) return true;

		const context = getOptionContext(option, index);

		const searchTerm = filterText.toLowerCase();
		const label = displayComponent.getLabel(option).toLowerCase();
		const description = displayComponent.getDescription?.(option, context)?.toLowerCase() || '';

		return label.includes(searchTerm) || description.includes(searchTerm);
	});

	// Group filtered options by category when getCategory is provided
	$: groupedOptions = (() => {
		const optionsToGroup = filteredOptions;

		if (!displayComponent.getCategory) {
			return [{ category: null, options: optionsToGroup }];
		}

		const groups = new SvelteMap<string | null, V[]>();

		optionsToGroup.forEach((option, index) => {
			const context = getOptionContext(option, index);
			const category = displayComponent.getCategory!(option, context);
			if (!groups.has(category)) {
				groups.set(category, []);
			}
			groups.get(category)!.push(option);
		});

		// Sort categories alphabetically, with null category first
		const sortedEntries = Array.from(groups.entries()).sort(([a], [b]) => {
			if (a === null) return -1;
			if (b === null) return 1;
			return a.localeCompare(b);
		});

		return sortedEntries.map(([category, options]) => ({ category, options }));
	})();

	// Simple one-time positioning when dropdown opens
	async function calculatePosition() {
		if (!triggerElement) return;

		await tick();
		const rect = triggerElement.getBoundingClientRect();
		const viewportHeight = window.innerHeight;
		const dropdownHeight = 384; // max-h-96 = 24rem = 384px
		const gap = 1; // Minimal gap to prevent overlap

		// Simple logic: if not enough space below, open upward
		const spaceBelow = viewportHeight - rect.bottom - gap;
		openUpward = spaceBelow < dropdownHeight && rect.top > spaceBelow;

		dropdownPosition = {
			top: openUpward ? rect.top - gap : rect.bottom + gap,
			left: rect.left,
			width: rect.width
		};
	}

	async function handleToggle(e: MouseEvent) {
		e.preventDefault();
		e.stopPropagation();
		if (!disabled) {
			if (!isOpen) {
				isOpen = true;
				filterText = ''; // Reset filter when opening
				await calculatePosition(); // Calculate once when opening
				// Focus the input after the dropdown is positioned
				setTimeout(() => inputElement?.focus(), 0);
			} else {
				isOpen = false;
				filterText = '';
			}
		}
	}

	function handleSelect(value: string) {
		try {
			let index: number | undefined;
			const item = options.find((o, i) => {
				if (displayComponent.getId(o) === value) {
					index = i;
					return true;
				}
				return false;
			});
			if (item && index !== undefined) {
				const context = getOptionContext(item, index);
				if (!displayComponent.getIsDisabled?.(item, context)) {
					isOpen = false;
					filterText = '';
					onSelect(value);
				}
			}
		} catch (e) {
			console.warn('Error in handleSelect:', e);
			isOpen = false;
			filterText = '';
		}
	}

	function handleClickOutside(event: MouseEvent) {
		if (
			dropdownElement &&
			!dropdownElement.contains(event.target as Node) &&
			triggerElement &&
			!triggerElement.contains(event.target as Node)
		) {
			isOpen = false;
			filterText = '';
		}
	}

	function handleInputKeydown(e: KeyboardEvent) {
		if (e.key === 'Escape') {
			isOpen = false;
			filterText = '';
			triggerElement?.focus(); // Return focus to trigger
		}
		// Prevent the input keydown from bubbling to parent components
		e.stopPropagation();
	}
</script>

<!-- Only handle outside clicks -->
<svelte:window on:click={handleClickOutside} />

<div class="relative">
	<!-- Label -->
	{#if label}
		<div class="text-secondary mb-2 block text-sm font-medium">
			{label}
			{#if required}
				<span class="text-danger ml-1">*</span>
			{/if}
		</div>
	{/if}

	<!-- Dropdown Trigger -->
	<button
		bind:this={triggerElement}
		type="button"
		on:click={handleToggle}
		class="text-primary flex w-full items-center justify-between rounded-md border border-gray-600
           bg-gray-700 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500
           {error ? 'border-red-500' : ''}
           {disabled || options.length == 0 ? 'cursor-not-allowed opacity-50' : ''}"
		disabled={disabled || options.length == 0}
	>
		<div class="flex min-w-0 flex-1 items-center gap-3">
			{#if selectedItem}
				{@const context = getOptionContext(selectedItem, 0)}
				<ListSelectItem {context} item={selectedItem} {displayComponent} />
			{:else}
				<span class="text-secondary"
					>{options.length == 0 ? 'No options available' : placeholder}</span
				>
			{/if}
		</div>

		<ChevronDown
			class="text-tertiary h-4 w-4 flex-shrink-0 transition-transform {isOpen ? 'rotate-180' : ''}"
		/>
	</button>

	<!-- Error Message -->
	{#if error}
		<div class="text-danger mt-1 flex items-center gap-2 text-sm">
			<span>{error}</span>
		</div>
	{/if}
</div>

<!-- Portal dropdown - positioned once, no scroll tracking -->
{#if isOpen && !disabled}
	<div
		bind:this={dropdownElement}
		class="fixed z-[9999] max-h-96 overflow-hidden scroll-smooth rounded-md border border-gray-600 bg-gray-700 shadow-lg"
		style="top: {dropdownPosition.top}px; left: {dropdownPosition.left}px; width: {dropdownPosition.width}px;
           {openUpward ? 'transform: translateY(-100%);' : ''}"
	>
		<!-- Search Input -->
		{#if showSearch}
			<div class="sticky top-0 border-b border-gray-600 bg-gray-700 p-2">
				<input
					bind:this={inputElement}
					bind:value={filterText}
					type="text"
					placeholder="Type to filter options..."
					class="text-primary w-full rounded border border-gray-600 bg-gray-800 px-2 py-1 text-sm placeholder-gray-400 focus:outline-none focus:ring-1 focus:ring-blue-500"
					on:keydown={handleInputKeydown}
					on:click|stopPropagation
				/>
			</div>
		{/if}

		<!-- Options list with scroll container -->
		<div class="max-h-80 overflow-y-auto">
			{#if groupedOptions.length === 0 || groupedOptions.every((group) => group.options.length === 0)}
				<div class="text-tertiary px-3 py-4 text-center text-sm">
					No options match "{filterText}"
				</div>
			{:else}
				{#each groupedOptions as group, groupIndex (group.category ?? '__ungrouped__')}
					{#if group.options.length > 0}
						<!-- Category Header -->
						{#if group.category !== null}
							<div
								class="text-secondary sticky top-0 border-b border-gray-600 bg-gray-800 px-3 py-2 text-xs font-semibold uppercase tracking-wide"
							>
								{group.category}
							</div>
						{/if}

						<!-- Options in this category -->
						{#each group.options as option, optionIndex (displayComponent.getId(option))}
							{@const context = getOptionContext(option, optionIndex)}
							{@const isLastInGroup = optionIndex === group.options.length - 1}
							{@const isLastGroup = groupIndex === groupedOptions.length - 1}
							<button
								type="button"
								on:click={(e) => {
									e.preventDefault();
									e.stopPropagation();
									if (!displayComponent.getIsDisabled?.(option, context)) {
										handleSelect(displayComponent.getId(option));
									}
								}}
								class="w-full px-3 py-3 text-left transition-colors
                       {!isLastInGroup || !isLastGroup ? 'border-b border-gray-600' : ''}
                       {displayComponent.getIsDisabled?.(option, context)
									? 'cursor-not-allowed opacity-50'
									: 'hover:bg-gray-600'}"
								disabled={displayComponent.getIsDisabled?.(option, context)}
							>
								<ListSelectItem {context} item={option} {displayComponent} />
							</button>
						{/each}
					{/if}
				{/each}
			{/if}
		</div>
	</div>
{/if}
