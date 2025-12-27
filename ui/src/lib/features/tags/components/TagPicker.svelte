<script lang="ts">
	import { X, Plus } from 'lucide-svelte';
	import { useTagsQuery, useCreateTagMutation } from '$lib/features/tags/queries';
	import { createDefaultTag } from '$lib/features/tags/types/base';
	import { createColorHelper, AVAILABLE_COLORS, type Color } from '$lib/shared/utils/styling';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import { permissions } from '$lib/shared/stores/metadata';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';

	let {
		selectedTagIds = $bindable([]),
		label = 'Tags',
		placeholder = 'Type to add tags...',
		disabled = false
	}: {
		selectedTagIds?: string[];
		label?: string;
		placeholder?: string;
		disabled?: boolean;
	} = $props();

	let inputValue = $state('');
	let isFocused = $state(false);
	let inputElement: HTMLInputElement | undefined = $state();

	// Query and mutation
	const tagsQuery = useTagsQuery();
	const createTagMutation = useCreateTagMutation();
	const organizationQuery = useOrganizationQuery();
	const currentUserQuery = useCurrentUserQuery();

	// Derived state
	let tags = $derived(tagsQuery.data ?? []);
	let isCreating = $derived(createTagMutation.isPending);
	let organization = $derived(organizationQuery.data);
	let currentUser = $derived(currentUserQuery.data);

	// Check if user can create tags
	let canCreateTags = $derived(
		currentUser && permissions.getMetadata(currentUser.permissions).manage_org_entities
	);

	// Check if typed value matches an existing tag name exactly
	let exactMatch = $derived(
		tags.some((t) => t.name.toLowerCase() === inputValue.trim().toLowerCase())
	);

	// Show create option if user typed something, can create, and no exact match exists
	let showCreateOption = $derived(inputValue.trim().length > 0 && canCreateTags && !exactMatch);

	// Get tag by ID, returns null if not found
	function getTag(id: string) {
		return tags.find((t) => t.id === id) ?? null;
	}

	// Filter available tags based on input and exclude already selected
	let availableTags = $derived(
		tags.filter(
			(tag) =>
				!selectedTagIds.includes(tag.id) &&
				tag.name.toLowerCase().includes(inputValue.toLowerCase())
		)
	);

	let showDropdown = $derived(isFocused && (availableTags.length > 0 || showCreateOption));

	function getRandomColor(): Color {
		return AVAILABLE_COLORS[Math.floor(Math.random() * AVAILABLE_COLORS.length)];
	}

	async function handleCreateTag() {
		if (!organization || isCreating) return;

		const name = inputValue.trim();
		if (!name) return;

		try {
			const newTag = createDefaultTag(organization.id);
			newTag.name = name;
			newTag.color = getRandomColor();

			const result = await createTagMutation.mutateAsync(newTag);
			selectedTagIds = [...selectedTagIds, result.id];
			inputValue = '';
		} finally {
			inputElement?.focus();
		}
	}

	function addTag(tagId: string) {
		if (!selectedTagIds.includes(tagId)) {
			selectedTagIds = [...selectedTagIds, tagId];
		}
		inputValue = '';
		inputElement?.focus();
	}

	function removeTag(tagId: string) {
		selectedTagIds = selectedTagIds.filter((id) => id !== tagId);
	}

	function handleKeydown(e: KeyboardEvent) {
		if (e.key === 'Enter') {
			e.preventDefault();
			if (showCreateOption && availableTags.length === 0) {
				// No matches, create new tag
				handleCreateTag();
			} else if (availableTags.length > 0) {
				// Add first matching tag
				addTag(availableTags[0].id);
			} else if (showCreateOption) {
				// Create new tag
				handleCreateTag();
			}
		} else if (e.key === 'Backspace' && inputValue === '' && selectedTagIds.length > 0) {
			removeTag(selectedTagIds[selectedTagIds.length - 1]);
		} else if (e.key === 'Escape') {
			inputValue = '';
			inputElement?.blur();
		}
	}

	function handleBlur() {
		// Delay to allow click on dropdown item
		setTimeout(() => {
			isFocused = false;
		}, 150);
	}
</script>

<div class="space-y-2">
	{#if label}
		<div class="text-secondary block text-sm font-medium">{label}</div>
	{/if}

	<div class="relative">
		<!-- Input container with selected tags -->
		<div
			class="input-field flex h-[42px] items-center overflow-hidden p-0"
			class:opacity-50={disabled}
			class:cursor-not-allowed={disabled}
			class:border-blue-500={isFocused}
			class:outline-none={isFocused}
			class:ring-2={isFocused}
			class:ring-blue-500={isFocused}
		>
			<!-- Selected tags (horizontal scroll) -->
			<div class="flex shrink-0 items-center overflow-x-auto">
				{#each selectedTagIds as tagId (tagId)}
					{@const tag = getTag(tagId)}
					{#if tag}
						{@const colorHelper = createColorHelper(tag.color)}
						<span
							class="mx-1 inline-flex shrink-0 items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium {colorHelper.bg} {colorHelper.text}"
						>
							{tag.name}
							{#if !disabled}
								<button
									type="button"
									onclick={() => removeTag(tagId)}
									class="rounded-full p-0.5 transition-colors hover:bg-white/20"
								>
									<X class="h-3 w-3" />
								</button>
							{/if}
						</span>
					{:else}
						<span
							class="inline-flex shrink-0 items-center gap-1 rounded-full bg-gray-600 px-2 py-0.5 text-xs font-medium text-gray-300"
						>
							Unknown tag
							{#if !disabled}
								<button
									type="button"
									onclick={() => removeTag(tagId)}
									class="rounded-full p-0.5 transition-colors hover:bg-white/20"
								>
									<X class="h-3 w-3" />
								</button>
							{/if}
						</span>
					{/if}
				{/each}
			</div>

			<!-- Text input -->
			<input
				bind:this={inputElement}
				bind:value={inputValue}
				type="text"
				placeholder={selectedTagIds.length === 0 ? placeholder : ''}
				{disabled}
				class="input-field border-0 bg-transparent ring-0"
				style="--tw-ring-shadow: none; --tw-ring-color: none;"
				onfocus={() => (isFocused = true)}
				onblur={handleBlur}
				onkeydown={handleKeydown}
			/>
		</div>

		<!-- Dropdown -->
		{#if showDropdown}
			<div
				class="absolute left-0 right-0 top-full z-50 mt-1 max-h-48 overflow-y-auto rounded-md border border-gray-600 bg-gray-700 shadow-lg"
			>
				<!-- Create new tag option -->
				{#if showCreateOption}
					<button
						type="button"
						class="flex w-full items-center gap-2 border-b border-gray-600 px-3 py-2 text-left text-sm transition-colors hover:bg-gray-600"
						onmousedown={handleCreateTag}
						disabled={isCreating}
					>
						<Plus class="h-4 w-4 shrink-0 text-green-400" />
						<span class="text-primary">
							{isCreating ? 'Creating...' : `Create "${inputValue.trim()}"`}
						</span>
					</button>
				{/if}

				<!-- Existing tags -->
				{#each availableTags as tag (tag.id)}
					{@const colorHelper = createColorHelper(tag.color)}
					<button
						type="button"
						class="flex w-full items-center gap-2 px-3 py-2 text-left text-sm transition-colors hover:bg-gray-600"
						onmousedown={() => addTag(tag.id)}
					>
						<span class="h-3 w-3 shrink-0 rounded-full" style="background-color: {colorHelper.rgb};"
						></span>
						<span class="text-primary">{tag.name}</span>
						{#if tag.description}
							<span class="text-tertiary truncate text-xs">— {tag.description}</span>
						{/if}
					</button>
				{/each}
			</div>
		{/if}
	</div>
</div>
