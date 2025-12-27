<script lang="ts">
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import { AlertTriangle } from 'lucide-svelte';

	export let isOpen: boolean = false;
	export let title: string = 'Confirm Action';
	export let message: string = 'Are you sure you want to proceed?';
	export let details: string[] = [];
	export let confirmLabel: string = 'Confirm';
	export let cancelLabel: string = 'Cancel';
	export let variant: 'danger' | 'warning' | 'info' = 'warning';
	export let onConfirm: () => void;
	export let onCancel: () => void;

	const variantClasses = {
		danger: 'bg-red-900/20 border-red-600 text-red-400',
		warning: 'bg-yellow-900/20 border-yellow-600 text-yellow-400',
		info: 'bg-blue-900/20 border-blue-600 text-blue-400'
	};

	const iconColors = {
		danger: 'text-red-400',
		warning: 'text-yellow-400',
		info: 'text-blue-400'
	};

	const confirmButtonClasses = {
		danger: 'btn-danger',
		warning: 'btn-primary',
		info: 'btn-primary'
	};
</script>

<GenericModal {isOpen} {title} onClose={onCancel} size="sm">
	<div class="space-y-4">
		<div class="flex items-start gap-3">
			<AlertTriangle class="h-5 w-5 flex-shrink-0 {iconColors[variant]}" />
			<p class="text-secondary text-sm">{message}</p>
		</div>

		{#if details.length > 0}
			<div class="rounded border px-3 py-2 {variantClasses[variant]}">
				<ul class="list-inside list-disc space-y-1 text-sm">
					{#each details as detail, i (i)}
						<li>{detail}</li>
					{/each}
				</ul>
			</div>
		{/if}
	</div>

	<svelte:fragment slot="footer">
		<div class="flex justify-end gap-3">
			<button type="button" class="btn-secondary" on:click={onCancel}>
				{cancelLabel}
			</button>
			<button type="button" class={confirmButtonClasses[variant]} on:click={onConfirm}>
				{confirmLabel}
			</button>
		</div>
	</svelte:fragment>
</GenericModal>
