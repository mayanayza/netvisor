<script lang="ts" generics="TItem">
	import Loading from '../../feedback/Loading.svelte';

	// Core data
	export let items: TItem[] = [];

	// Layout configuration
	export let listPanelWidth: string = 'w-2/5';
	export let configPanelWidth: string = 'w-3/5';
	export let loading: boolean = false;

	// Event handlers
	export let onReorder: (fromIndex: number, toIndex: number) => void = () => {};
	export let onChange: (item: TItem, index: number) => void = () => {};
	export let onItemAdded: (newIndex: number) => void = (newIndex) => {
		selectedIndex = newIndex;
	};

	// Internal state
	let selectedIndex: number = -1;

	// Computed values for slot consumers
	$: selectedItem = selectedIndex >= 0 ? items[selectedIndex] : null;

	// Track previous items length to detect when items are added
	let previousItemsLength = 0;
	$: {
		if (items.length > previousItemsLength) {
			// Items were added, select the last one
			onItemAdded(items.length - 1);
		} else if (items.length === 1 && selectedIndex === -1) {
			// Auto-select the first (and only) item when there's exactly one item
			selectedIndex = 0;
		} else if (items.length === 0) {
			// Clear selection when no items
			selectedIndex = -1;
		}
		previousItemsLength = items.length;
	}

	// Event handlers
	function handleEdit(item: TItem, index: number) {
		selectedIndex = index;
	}

	function handleItemChange(updatedItem: TItem) {
		if (selectedIndex >= 0 && selectedIndex < items.length) {
			items[selectedIndex] = updatedItem;
			items = items; // Trigger reactivity

			onChange(updatedItem, selectedIndex);
		}
	}

	function handleMoveUp(fromIndex: number, toIndex: number) {
		// When an item moves up: fromIndex > toIndex
		if (selectedIndex === fromIndex) {
			// The selected item moved up
			selectedIndex = toIndex;
		} else if (selectedIndex >= toIndex && selectedIndex < fromIndex) {
			// Selected item got pushed down by the moving item
			selectedIndex = selectedIndex + 1;
		}
		onReorder(fromIndex, toIndex);
	}

	function handleMoveDown(fromIndex: number, toIndex: number) {
		// When an item moves down: fromIndex < toIndex
		if (selectedIndex === fromIndex) {
			// The selected item moved down
			selectedIndex = toIndex;
		} else if (selectedIndex > fromIndex && selectedIndex <= toIndex) {
			// Selected item got pushed up by the moving item
			selectedIndex = selectedIndex - 1;
		}
		onReorder(fromIndex, toIndex);
	}
</script>

{#if loading}
	<div class="flex h-full items-center justify-center">
		<Loading />
	</div>
{:else}
	<div class="flex h-full gap-6">
		<!-- Left Panel - List Manager (Full Height) -->
		<div class="{listPanelWidth} relative flex flex-col">
			<div class="p-6">
				<slot
					name="list"
					{items}
					{selectedIndex}
					onEdit={handleEdit}
					onMoveUp={handleMoveUp}
					onMoveDown={handleMoveDown}
					highlightedIndex={selectedIndex}
				>
					<!-- Default slot content if no list slot provided -->
					<div class="text-danger">No list component provided</div>
				</slot>
			</div>

			<!-- Spacer to make left panel take full height -->
			<div class="flex-1"></div>
		</div>

		<!-- Right Panel - Configuration -->
		<div class="{configPanelWidth} overflow-y-auto border-l border-gray-600 p-6">
			<slot name="config" {selectedItem} {selectedIndex} onChange={handleItemChange}>
				<div class="text-tertiary flex h-32 items-center justify-center">
					<p>Select an item to configure</p>
				</div>
			</slot>
		</div>
	</div>
{/if}
