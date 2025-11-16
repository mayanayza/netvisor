<script lang="ts">
	import { login, register } from '$lib/features/auth/store';
	import LoginModal from '$lib/features/auth/components/LoginModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import type { LoginRequest, RegisterRequest } from '$lib/features/auth/types/base';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import GithubStars from '$lib/shared/components/data/GithubStars.svelte';
	import { page } from '$app/stores';

	let showLogin = $state(true);

	let orgName = $derived($page.url.searchParams.get('org_name'));
	let invitedBy = $derived($page.url.searchParams.get('invited_by'));

	async function handleLogin(data: LoginRequest) {
		const user = await login(data);
		if (!user) {
			return;
		}
		window.location.href = '/';
	}

	async function handleRegister(data: RegisterRequest) {
		const user = await register(data);
		if (!user) {
			return;
		}
		window.location.href = '/';
	}

	function switchToRegister() {
		showLogin = false;
	}

	function switchToLogin() {
		showLogin = true;
	}

	// Dummy onClose since we don't want to close these modals
	function handleClose() {}
</script>

<div class="relative flex min-h-screen flex-col items-center bg-gray-900 p-4">
	<!-- Background image with overlay -->
	<div class="absolute inset-0 z-0">
		<div
			class="h-full w-full bg-cover bg-center bg-no-repeat"
			style="background-image: url('/images/diagram.png')"
		></div>
	</div>

	<!-- GitHub Stars Island - positioned absolutely at top -->
	<div class="absolute bottom-10 left-10 z-[100]">
		<div
			class="inline-flex items-center gap-2 rounded-2xl border border-gray-700 bg-gray-800/90 px-4 py-3 shadow-xl backdrop-blur-sm"
		>
			<span class="text-secondary text-sm">Open source on GitHub</span>
			<GithubStars />
		</div>
	</div>

	<!-- Spacer to push modal down -->
	<div class="flex flex-1 items-center justify-center">
		<!-- Modal Content -->
		<div class="relative z-10">
			{#if showLogin}
				<LoginModal
					isOpen={true}
					onLogin={handleLogin}
					onClose={handleClose}
					onSwitchToRegister={switchToRegister}
					{orgName}
					{invitedBy}
				/>
			{:else}
				<RegisterModal
					isOpen={true}
					onRegister={handleRegister}
					onClose={handleClose}
					onSwitchToLogin={switchToLogin}
					{orgName}
					{invitedBy}
				/>
			{/if}
		</div>
	</div>

	<Toast />
</div>
