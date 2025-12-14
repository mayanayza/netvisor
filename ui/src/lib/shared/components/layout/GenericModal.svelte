<script lang="ts">
	import { X } from 'lucide-svelte';
	import { onDestroy } from 'svelte';

	export let title: string = 'Modal';
	export let centerTitle: boolean = false;
	export let isOpen: boolean = false;
	export let onClose: (() => void) | null = null;
	export let size: 'sm' | 'md' | 'lg' | 'xl' | 'full' = 'lg';
	export let preventCloseOnClickOutside: boolean = false;
	export let showCloseButton: boolean = true;
	export let showBackdrop: boolean = true;

	$: if (typeof window !== 'undefined' && isOpen) {
		document.body.style.overflow = 'hidden';
	} else if (typeof window !== 'undefined') {
		document.body.style.overflow = '';
	}

	onDestroy(() => {
		if (typeof window !== 'undefined') {
			document.body.style.overflow = '';
		}
	});

	// Size classes
	const sizeClasses = {
		sm: 'max-w-md',
		md: 'max-w-lg',
		lg: 'max-w-2xl',
		xl: 'max-w-4xl',
		full: 'max-w-7xl'
	};

	function handleClose() {
		onClose?.();
	}

	function handleBackdropClick(event: MouseEvent) {
		if (!preventCloseOnClickOutside && event.target === event.currentTarget) {
			handleClose();
		}
	}

	function handleKeydown(event: KeyboardEvent) {
		if (event.key === 'Escape' && isOpen) {
			handleClose();
		}
	}
</script>

<svelte:window on:keydown={handleKeydown} />

{#if isOpen}
	<!-- Modal backdrop -->
	<div
		class={showBackdrop ? 'modal-page modal-background' : 'modal-page'}
		on:click={handleBackdropClick}
		role="dialog"
		aria-modal="true"
		aria-labelledby="modal-title"
		on:keydown={(e) => e.key === 'Escape' && handleClose()}
		tabindex="-1"
	>
		<!-- Modal content -->
		<div
			class="modal-container {sizeClasses[size]} {size === 'full'
				? 'h-[calc(100vh-8rem)]'
				: 'max-h-[calc(100vh-8rem)]'} flex flex-col"
		>
			<!-- Header -->
			<div class="modal-header">
				{#if centerTitle}
					{#if $$slots['header-icon']}
						<slot name="header-icon" />
					{/if}
					<h2
						id="modal-title"
						class="text-primary absolute left-1/2 -translate-x-1/2 text-xl font-semibold"
					>
						{title}
					</h2>
				{:else}
					<div class="flex items-center gap-3">
						{#if $$slots['header-icon']}
							<slot name="header-icon" />
						{/if}
						<h2 id="modal-title" class="text-primary text-xl font-semibold">
							{title}
						</h2>
					</div>
				{/if}

				{#if showCloseButton}
					<button type="button" on:click={handleClose} class="btn-icon" aria-label="Close modal">
						<X class="h-5 w-5" />
					</button>
				{/if}
			</div>

			<!-- Content slot -->
			<div class="modal-content">
				<slot />
			</div>

			<!-- Footer slot -->
			{#if $$slots.footer}
				<div class="modal-footer">
					<slot name="footer" />
				</div>
			{/if}
		</div>
	</div>
{/if}
