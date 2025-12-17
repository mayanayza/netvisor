<script lang="ts">
	import { trackEvent } from '$lib/shared/utils/analytics';
	import InlineDanger from '$lib/shared/components/feedback/InlineDanger.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import InlineSuccess from '$lib/shared/components/feedback/InlineSuccess.svelte';

	export let onResolved: () => void;
	export let showActions: boolean = true;

	type OS = 'linux' | 'macos' | 'windows' | 'freebsd' | 'openbsd' | null;
	type InstallMethod = 'binary' | 'docker' | null;

	let selectedOS: OS = null;
	let selectedMethod: InstallMethod = null;

	const osOptions: { id: OS; label: string }[] = [
		{ id: 'linux', label: 'Linux' },
		{ id: 'macos', label: 'macOS' },
		{ id: 'windows', label: 'Windows' },
		{ id: 'freebsd', label: 'FreeBSD' },
		{ id: 'openbsd', label: 'OpenBSD' }
	];

	const methodOptions: { id: InstallMethod; label: string }[] = [
		{ id: 'binary', label: 'Binary / Executable' },
		{ id: 'docker', label: 'Docker Compose' }
	];

	// Check if OS is unsupported (BSD variants)
	$: isUnsupportedOS = selectedOS === 'freebsd' || selectedOS === 'openbsd';

	// Compatibility matrix
	$: compatibility = getCompatibility(selectedOS, selectedMethod);

	function getCompatibility(
		os: OS,
		method: InstallMethod
	): 'compatible' | 'warning' | 'incompatible' | null {
		if (!os) return null;

		// FreeBSD and OpenBSD are not supported
		if (os === 'freebsd' || os === 'openbsd') {
			return 'incompatible';
		}

		if (!method) return null;

		// Docker Compose is only fully supported on Linux
		if (method === 'docker' && os !== 'linux') {
			return 'warning';
		}

		// All other combinations are compatible
		return 'compatible';
	}

	$: warningBody =
		selectedOS === 'macos'
			? "Docker Compose deployment with network_mode: host is only fully supported on Linux. On macOS, you'll need to use the binary install method."
			: selectedOS === 'windows'
				? "Docker Compose deployment with network_mode: host is only fully supported on Linux. On Windows, you'll need to use the binary install method."
				: 'Docker Compose deployment with network_mode: host is only fully supported on Linux.';

	$: incompatibleBody =
		selectedOS === 'freebsd'
			? "Scanopy's daemon currently doesn't support FreeBSD. We recommend running the daemon on a Linux host or VM on your network instead."
			: selectedOS === 'openbsd'
				? "Scanopy's daemon currently doesn't support OpenBSD. We recommend running the daemon on a Linux host or VM on your network instead."
				: 'This operating system is not currently supported.';

	function handleContinue() {
		trackEvent('onboarding_compatibility_check', {
			os: selectedOS,
			install_method: selectedMethod,
			result: compatibility
		});
		onResolved();
	}
</script>

<div class="space-y-6">
	<!-- OS Selection -->
	<div class="space-y-3" role="group" aria-label="Operating system selection">
		<span class="text-secondary block text-sm font-medium"
			>What is your host's operating system?</span
		>
		<div class="flex gap-2">
			{#each osOptions as option (option.id)}
				<button
					type="button"
					class="btn-secondary flex-1 {selectedOS === option.id ? 'ring-primary ring-2' : ''}"
					on:click={() => (selectedOS = option.id)}
				>
					{option.label}
				</button>
			{/each}
		</div>
	</div>

	<!-- Install Method Selection (only for supported OSes) -->
	{#if selectedOS && !isUnsupportedOS}
		<div class="space-y-3" role="group" aria-label="Install method selection">
			<span class="text-secondary block text-sm font-medium"
				>How will you install the network scanner?</span
			>
			<div class="flex gap-2">
				{#each methodOptions as option (option.id)}
					<button
						type="button"
						class="btn-secondary flex-1 {selectedMethod === option.id ? 'ring-primary ring-2' : ''}"
						on:click={() => (selectedMethod = option.id)}
					>
						{option.label}
					</button>
				{/each}
			</div>
		</div>
	{/if}

	<!-- Compatibility Result -->
	{#if compatibility === 'compatible'}
		<InlineSuccess title="Great, you're all set!" body="Scanopy can be deployed on your host." />
	{:else if compatibility === 'warning'}
		<InlineWarning
			title="Docker Compose installation is only compatible with Linux hosts"
			body={warningBody}
		/>
	{:else if compatibility === 'incompatible'}
		<InlineDanger title="Not currently supported" body={incompatibleBody} />
	{/if}

	<!-- Actions -->
	{#if showActions && compatibility}
		<div class="flex justify-end pt-2">
			<button type="button" class="btn-primary" on:click={handleContinue}> Continue Setup </button>
		</div>
	{/if}
</div>
