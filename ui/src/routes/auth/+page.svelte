<script lang="ts">
	import { onMount } from 'svelte';
	import {
		checkAuth,
		forgotPassword,
		login,
		register,
		resetPassword
	} from '$lib/features/auth/store';
	import LoginModal from '$lib/features/auth/components/LoginModal.svelte';
	import RegisterModal from '$lib/features/auth/components/RegisterModal.svelte';
	import ForgotPasswordModal from '$lib/features/auth/components/ForgotPasswordModal.svelte';
	import ResetPasswordModal from '$lib/features/auth/components/ResetPasswordModal.svelte';
	import type { LoginRequest, RegisterRequest } from '$lib/features/auth/types/base';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import GithubStars from '$lib/shared/components/data/GithubStars.svelte';
	import { page } from '$app/stores';
	import { getOrganization } from '$lib/features/organizations/store';
	import { navigate } from '$lib/shared/utils/navigation';

	type ModalType = 'login' | 'register' | 'forgot' | 'reset';
	let activeModal = $state<ModalType>('login');
	let resetToken = $state<string>('');

	let orgName = $derived($page.url.searchParams.get('org_name'));
	let invitedBy = $derived($page.url.searchParams.get('invited_by'));

	onMount(() => {
		// Check if we have a reset token in the URL
		const token = $page.url.searchParams.get('token');
		if (token) {
			activeModal = 'reset';
			resetToken = token;
		}
	});

	async function handleLogin(data: LoginRequest) {
		const user = await login(data);
		if (!user) return;

		// Refresh auth state and organization
		await Promise.all([checkAuth(), getOrganization()]);

		// Navigate to correct destination
		await navigate();
	}

	async function handleRegister(data: RegisterRequest) {
		const user = await register(data);
		if (!user) return;

		// Refresh auth state and organization
		await Promise.all([checkAuth(), getOrganization()]);

		// Navigate to correct destination
		await navigate();
	}

	async function handleRequestReset(email: string) {
		await forgotPassword(email);
		console.log('Requesting password reset for:', email);
	}

	async function handleResetPassword(token: string, password: string) {
		await resetPassword(password, token);
		console.log('Resetting password with token:', token);
	}

	function switchToRegister() {
		activeModal = 'register';
	}

	function switchToLogin() {
		activeModal = 'login';
	}

	function switchToForgot() {
		activeModal = 'forgot';
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
			{#if activeModal === 'login'}
				<LoginModal
					isOpen={true}
					onLogin={handleLogin}
					onClose={handleClose}
					onSwitchToRegister={switchToRegister}
					onSwitchToForgot={switchToForgot}
					{orgName}
					{invitedBy}
				/>
			{:else if activeModal === 'register'}
				<RegisterModal
					isOpen={true}
					onRegister={handleRegister}
					onClose={handleClose}
					onSwitchToLogin={switchToLogin}
					{orgName}
					{invitedBy}
				/>
			{:else if activeModal === 'forgot'}
				<ForgotPasswordModal
					isOpen={true}
					onRequestReset={handleRequestReset}
					onClose={handleClose}
					onBackToLogin={switchToLogin}
				/>
			{:else if activeModal === 'reset'}
				<ResetPasswordModal
					isOpen={true}
					token={resetToken}
					onResetPassword={handleResetPassword}
					onClose={handleClose}
					onBackToLogin={switchToLogin}
				/>
			{/if}
		</div>
	</div>

	<Toast />
</div>
