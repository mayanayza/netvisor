<script lang="ts" generics="T, V, C">
	import { ArrowUp, ArrowDown, Trash2, Plus, Edit, Square, CheckSquare } from 'lucide-svelte';
	import RichSelect from './RichSelect.svelte';
	import ListSelectItem from './ListSelectItem.svelte';
	import type { EntityDisplayComponent } from './types';
	import type { FormApi } from '../types';
	import type { Snippet } from 'svelte';

	interface Props {
		// Global
		label: string;
		helpText?: string;
		placeholder?: string;
		required?: boolean;
		allowReorder?: boolean;
		allowAddFromOptions?: boolean;
		allowCreateNew?: boolean;
		allowSelection?: boolean;
		disableCreateNewButton?: boolean;
		createNewLabel?: string;
		highlightedIndex?: number;
		emptyMessage?: string;
		error?: string;

		// Options (dropdown)
		options?: V[];
		optionDisplayComponent: EntityDisplayComponent<V, C>;
		showSearch?: boolean;

		// Items
		items?: T[];
		itemDisplayComponent: EntityDisplayComponent<T, C>;
		getItemContext?: (item: T, index: number) => C;
		formApi: FormApi;

		// Item interaction
		allowDuplicates?: boolean;
		itemClickAction?: 'edit' | 'select' | null;
		allowItemEdit?: (item: T) => boolean;
		allowItemRemove?: (item: T) => boolean;
		selectedItems?: T[];

		// Interaction handlers
		onCreateNew?: (() => void) | null;
		onEdit?: (item: T, index: number) => void;
		onAdd?: (selectOptionId: string) => void;
		onMoveUp?: (fromIndex: number, toIndex: number) => void;
		onMoveDown?: (fromIndex: number, toIndex: number) => void;
		onRemove?: (index: number) => void;
		onClick?: (item: T, index: number) => void;

		// Snippets (slots)
		itemSnippet?: Snippet<[{ item: T; index: number }]>;
	}

	let {
		// Global
		label,
		helpText = '',
		placeholder = 'Select an item to add',
		required = false,
		allowReorder = true,
		allowAddFromOptions = true,
		allowCreateNew = false,
		allowSelection = false,
		disableCreateNewButton = false,
		createNewLabel = 'Create New',
		highlightedIndex = -1,
		emptyMessage = '',
		error = '',

		// Options (dropdown)
		options = [] as V[],
		optionDisplayComponent,
		showSearch = false,

		// Items
		items = [] as T[],
		itemDisplayComponent,
		getItemContext = () => ({}) as C,
		formApi,
		selectedItems = $bindable([]),

		// Item interaction
		allowDuplicates = false,
		itemClickAction = null,
		allowItemEdit = () => true,
		allowItemRemove = () => true,

		// Interaction handlers
		onCreateNew = null,
		onEdit = () => {},
		onAdd = () => {},
		onMoveUp = () => {},
		onMoveDown = () => {},
		onRemove = () => {},
		onClick = () => {},

		itemSnippet
	}: Props = $props();

	// Internal state
	let selectedOptionId = $state('');
	let editingIndex: number = $state(-1);

	let computedEmptyMessage = $derived(emptyMessage || `No ${label.toLowerCase()} added yet`);

	function addItem() {
		if (selectedOptionId) {
			// Check for duplicates only if allowDuplicates is false
			if (!allowDuplicates) {
				const isDuplicate = items.some((item) => {
					const itemId = itemDisplayComponent.getId(item);
					return itemId === selectedOptionId;
				});

				if (isDuplicate) {
					return; // Don't add duplicates
				}
			}

			// Call the parent's onAdd callback with the option ID
			onAdd(selectedOptionId);
			selectedOptionId = '';
		}
	}

	function removeItem(index: number) {
		onRemove(index);
	}

	function moveItemUp(index: number) {
		if (index > 0 && allowReorder) {
			const newItems = [...items];
			[newItems[index - 1], newItems[index]] = [newItems[index], newItems[index - 1]];
			items = newItems;
			onMoveUp(index, index - 1);
		}
	}

	function moveItemDown(index: number) {
		if (index < items.length - 1 && allowReorder) {
			const newItems = [...items];
			[newItems[index], newItems[index + 1]] = [newItems[index + 1], newItems[index]];
			items = newItems;
			onMoveDown(index, index + 1);
		}
	}

	function handleDropdownSelectChange(value: string) {
		selectedOptionId = value;
		if (value) {
			addItem();
		}
	}

	function isItemSelected(item: T): boolean {
		const itemId = itemDisplayComponent.getId(item);
		return selectedItems.some((selected) => itemDisplayComponent.getId(selected) === itemId);
	}

	function toggleItemSelection(item: T) {
		const itemId = itemDisplayComponent.getId(item);
		const isCurrentlySelected = isItemSelected(item);

		if (isCurrentlySelected) {
			selectedItems = selectedItems.filter((s) => itemDisplayComponent.getId(s) !== itemId);
		} else {
			selectedItems = [...selectedItems, item];
		}
	}

	function selectAll() {
		selectedItems = [...items];
	}

	function selectNone() {
		selectedItems = [];
	}
</script>

<div>
	<div class="mb-2 flex items-start justify-between gap-4">
		<div class="min-w-0 flex-1">
			<div class="text-secondary block text-sm font-medium">
				{label}
				{#if required}<span class="text-danger">*</span>{/if}
			</div>
			{#if helpText}
				<p class="text-tertiary mt-1 text-sm">
					{helpText}
				</p>
			{/if}
		</div>

		{#if allowSelection && items.length > 0}
			{@const anySelected = selectedItems.length > 0}
			<button
				onclick={anySelected ? selectNone : selectAll}
				class="btn-secondary flex items-center gap-2"
				type="button"
				title={anySelected ? 'Deselect all' : 'Select all'}
			>
				{#if anySelected}
					<Square class="h-4 w-4" />
				{:else}
					<CheckSquare class="h-4 w-4" />
				{/if}
				{anySelected ? 'None' : 'All'}
			</button>
		{/if}

		{#if allowCreateNew && onCreateNew}
			<button
				type="button"
				disabled={disableCreateNewButton}
				onclick={() => onCreateNew()}
				class="btn-primary"
			>
				<Plus size={16} />
				{createNewLabel}
			</button>
		{/if}
	</div>

	<!-- Add Item Section with RichSelect -->
	{#if allowAddFromOptions}
		<div class="mb-3 mt-4">
			<div class="flex gap-2">
				<!-- RichSelect Component -->
				<div class="flex-1">
					<RichSelect
						selectedValue={selectedOptionId}
						{showSearch}
						{options}
						{placeholder}
						onSelect={handleDropdownSelectChange}
						displayComponent={optionDisplayComponent}
					/>
				</div>
			</div>
		</div>
	{/if}

	<!-- Current Items -->
	{#if items.length > 0}
		<div class="mb-3 space-y-2">
			{#each items as item, index (index)}
				{@const isHighlighted = highlightedIndex === index}

				<!-- svelte-ignore a11y_no_noninteractive_tabindex -->
				<div
					class="
						card flex items-center gap-3 rounded-lg border p-3 transition-all
						{itemClickAction != null ? 'cursor-pointer' : ''} 
						{isHighlighted ? 'card-focused' : isItemSelected(item) ? 'card-selected' : ''}"
					onclick={() => {
						onClick(item, index);
						if (allowSelection && itemClickAction == 'select') {
							toggleItemSelection(item);
						} else if (allowItemEdit(item) && !itemDisplayComponent.supportsInlineEdit) {
							onEdit(item, index);
						}
					}}
					tabindex={allowItemEdit(item) || allowSelection ? 0 : -1}
					role={allowSelection ? 'checkbox' : allowItemEdit(item) ? 'button' : undefined}
					aria-checked={allowSelection ? isItemSelected(item) : undefined}
				>
					<!-- Selection checkbox -->
					{#if allowSelection && itemClickAction != 'select'}
						<div class="flex-shrink-0">
							<input
								type="checkbox"
								checked={isItemSelected(item)}
								onclick={() => toggleItemSelection(item)}
								class="checkbox-card h-4 w-4"
							/>
						</div>
					{/if}

					<!-- Use slot if provided, otherwise check for inline editing -->
					<div class="min-w-0 flex-1 overflow-hidden">
						{#if itemSnippet}
							{@render itemSnippet({ item, index })}
						{:else if editingIndex === index && itemDisplayComponent.supportsInlineEdit && itemDisplayComponent.renderInlineEdit}
							{@const context = getItemContext(item, index)}
							{@const inlineEditConfig = itemDisplayComponent.renderInlineEdit(
								item,
								(updates) => {
									const updatedItem = { ...item, ...updates };
									onEdit(updatedItem, index);
								},
								formApi,
								context
							)}
							<inlineEditConfig.component {...inlineEditConfig.props} />
						{:else}
							{@const context = getItemContext(item, index)}
							<ListSelectItem {item} {context} displayComponent={itemDisplayComponent} />
						{/if}
					</div>

					<!-- Action Buttons -->
					<div class="flex items-center gap-1">
						{#if allowItemEdit(item) && itemClickAction != 'edit'}
							{#if itemDisplayComponent.supportsInlineEdit}
								<button
									type="button"
									onclick={(e) => {
										e.stopPropagation();
										editingIndex = editingIndex === index ? -1 : index;
									}}
									class="btn-icon"
									title={editingIndex === index ? 'Done editing' : 'Edit'}
								>
									<Edit size={16} />
								</button>
							{:else}
								<button
									type="button"
									onclick={(e) => {
										e.stopPropagation();
										onEdit(item, index);
									}}
									class="btn-icon"
									title="Edit"
								>
									<Edit size={16} />
								</button>
							{/if}
						{/if}

						{#if allowReorder}
							<button
								type="button"
								onclick={(e) => {
									e.stopPropagation();
									moveItemUp(index);
								}}
								disabled={index === 0}
								class="btn-icon"
								title="Move up"
							>
								<ArrowUp size={16} />
							</button>

							<button
								type="button"
								onclick={(e) => {
									e.stopPropagation();
									moveItemDown(index);
								}}
								disabled={index === items.length - 1}
								class="btn-icon"
								title="Move down"
							>
								<ArrowDown size={16} />
							</button>
						{/if}

						{#if allowItemRemove(item)}
							<button
								type="button"
								onclick={(e) => {
									e.stopPropagation();
									removeItem(index);
								}}
								class="btn-icon-danger"
								title="Remove"
							>
								<Trash2 size={16} />
							</button>
						{/if}
					</div>
				</div>
			{/each}
		</div>
	{:else if computedEmptyMessage}
		<div
			class="text-secondary rounded-lg border border-dashed border-gray-600 bg-gray-700/10 py-4 text-center text-sm"
		>
			{computedEmptyMessage}
		</div>
	{/if}

	<!-- Error Message -->
	{#if error}
		<div class="text-danger mt-2 text-sm">
			{error}
		</div>
	{/if}
</div>
