<script lang="ts">
	import { goto } from '$app/navigation';
	import { login, register } from '$lib/features/auth/store';
	import LoginModal from '$lib/features/auth/components/LoginModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import type { LoginRequest, RegisterRequest } from '$lib/features/auth/types/base';
	import { resolve } from '$app/paths';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';

	let showLogin = true;

	async function handleLogin(data: LoginRequest) {
		const success = await login(data);
		if (success) {
			await goto(resolve('/'));
		}
	}

	async function handleRegister(data: RegisterRequest) {
		const success = await register(data);
		if (success) {
			await goto(resolve('/'));
		}
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

<div class="flex min-h-screen items-center justify-center bg-gray-900">
	{#if showLogin}
		<LoginModal
			isOpen={true}
			onLogin={handleLogin}
			onClose={handleClose}
			onSwitchToRegister={switchToRegister}
		/>
	{:else}
		<RegisterModal
			isOpen={true}
			onRegister={handleRegister}
			onClose={handleClose}
			onSwitchToLogin={switchToLogin}
		/>
	{/if}

	<Toast />
</div>
