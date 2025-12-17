<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { sessions, discoverySSEManager, getActiveSessions } from '../sse';
	import { Loader2, SatelliteDish } from 'lucide-svelte';
	import { entities } from '$lib/shared/stores/metadata';

	// Track the session ID we're showing (stick to first session until done)
	let currentSessionId = $state<string | null>(null);

	// Update tracking when sessions change (separate from derived to avoid mutation in derived)
	$effect(() => {
		// If we have a tracked session, check if it's still valid
		if (currentSessionId) {
			const tracked = $sessions.find((s) => s.session_id === currentSessionId);
			if (tracked) {
				// If session completed (100%), clear tracking to pick up new one
				if ((tracked.progress ?? 0) >= 100) {
					currentSessionId = null;
				}
				// Otherwise keep tracking it
			} else {
				// Session no longer in list, clear tracking
				currentSessionId = null;
			}
		}

		// If no tracked session and there are sessions available, track the first one
		if (!currentSessionId && $sessions.length > 0) {
			currentSessionId = $sessions[0].session_id;
		}
	});

	// Get the session to display based on tracked ID
	let activeSession = $derived(
		currentSessionId ? ($sessions.find((s) => s.session_id === currentSessionId) ?? null) : null
	);

	let scanProgress = $derived(activeSession?.progress ?? 0);
	let scanType = $derived(activeSession?.discovery_type?.type ?? 'Network');
	let hasActiveSession = $derived(activeSession !== null && scanProgress > 0);

	// Check if user set up a daemon but it hasn't connected yet
	let pendingDaemonSetup = $state(false);

	// Show indicator if there's an active scan OR if waiting for daemon connection
	let showIndicator = $derived(hasActiveSession || pendingDaemonSetup);

	// Rotating status text (toggles between 0 and 1)
	let currentMessageIndex = $state(0);
	let intervalId: ReturnType<typeof setInterval> | null = null;

	onMount(async () => {
		// Check if user chose to set up a daemon during onboarding
		if (typeof localStorage !== 'undefined') {
			pendingDaemonSetup = localStorage.getItem('pendingDaemonSetup') === 'true';
		}

		await getActiveSessions();
		discoverySSEManager.connect();

		// Toggle messages every 4 seconds
		intervalId = setInterval(() => {
			currentMessageIndex = currentMessageIndex === 0 ? 1 : 0;
		}, 4000);
	});

	onDestroy(() => {
		discoverySSEManager.disconnect();
		if (intervalId) clearInterval(intervalId);
	});

	// Clear pending flag once scan starts
	$effect(() => {
		if (hasActiveSession && pendingDaemonSetup) {
			pendingDaemonSetup = false;
			if (typeof localStorage !== 'undefined') {
				localStorage.removeItem('pendingDaemonSetup');
			}
		}
	});

	const discoveryColor = entities.getColorHelper('Discovery');
</script>

{#if showIndicator}
	<div class="card relative z-10 flex items-center gap-2 rounded-full px-4 py-2">
		<div class={`flex items-center gap-1.5 ${discoveryColor.text}`}>
			<SatelliteDish class="h-4 w-4" />
			<Loader2 class="h-3.5 w-3.5 animate-spin" />
		</div>
		{#if hasActiveSession}
			<!-- Active scan in progress -->
			<div class="relative h-5 w-40 overflow-hidden">
				<span
					class="absolute left-0 top-0 flex h-full items-center whitespace-nowrap text-sm text-gray-300 transition-transform duration-300 ease-in-out"
					style="transform: translateY({currentMessageIndex === 0 ? '0' : '-100%'})"
				>
					Scanning {scanType}...
				</span>
				<span
					class="absolute left-0 top-0 flex h-full items-center whitespace-nowrap text-sm text-gray-300 transition-transform duration-300 ease-in-out"
					style="transform: translateY({currentMessageIndex === 1 ? '0' : '100%'})"
				>
					Building visualization...
				</span>
			</div>
			<div class="flex items-center gap-2">
				<div class="h-1.5 w-16 overflow-hidden rounded-full bg-gray-700">
					<div
						class="h-full bg-emerald-500 transition-all duration-300 ease-out"
						style="width: {scanProgress}%"
					></div>
				</div>
				<span class="text-xs font-medium text-gray-300">{scanProgress}%</span>
			</div>
		{:else}
			<!-- Waiting for daemon to connect -->
			<span class="text-sm text-gray-300">Waiting for daemon connection...</span>
		{/if}
	</div>
{/if}
