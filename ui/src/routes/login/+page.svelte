<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { goto } from '$app/navigation';
	import { checkAuth, forgotPassword, login, resetPassword } from '$lib/features/auth/store';
	import LoginModal from '$lib/features/auth/components/LoginModal.svelte';
	import ForgotPasswordModal from '$lib/features/auth/components/ForgotPasswordModal.svelte';
	import ResetPasswordModal from '$lib/features/auth/components/ResetPasswordModal.svelte';
	import type { LoginRequest } from '$lib/features/auth/types/base';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import GithubStars from '$lib/shared/components/data/GithubStars.svelte';
	import { getOrganization } from '$lib/features/organizations/store';
	import { navigate } from '$lib/shared/utils/navigation';
	import { resolve } from '$app/paths';

	type ModalType = 'login' | 'forgot' | 'reset';
	let activeModal = $state<ModalType>('login');
	let resetToken = $state<string>('');

	onMount(() => {
		// Check if we have a reset token in the URL
		const token = $page.url.searchParams.get('token');
		if (token) {
			activeModal = 'reset';
			resetToken = token;
		}
		// Note: Auth check is handled by +layout.svelte - no need to check here
	});

	async function handleLogin(data: LoginRequest) {
		const user = await login(data);
		if (!user) return;

		// Refresh auth state and organization
		await Promise.all([checkAuth(), getOrganization()]);

		// Navigate to correct destination
		await navigate();
	}

	async function handleRequestReset(email: string) {
		await forgotPassword({ email });
	}

	async function handleResetPassword(token: string, password: string) {
		const user = await resetPassword({ password, token });
		if (!user) return;

		// Refresh auth state and organization
		await Promise.all([checkAuth(), getOrganization()]);

		// Navigate to correct destination
		await navigate();
	}

	function switchToForgot() {
		activeModal = 'forgot';
	}

	function switchToLogin() {
		activeModal = 'login';
	}

	function switchToSignUp() {
		goto(resolve('/onboarding'));
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
		<div class="absolute inset-0 bg-black/70"></div>
	</div>

	<!-- GitHub Stars - positioned absolutely at bottom -->
	<div class="absolute bottom-10 left-10 z-[100] hidden md:block">
		<GithubStars />
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
					onSwitchToRegister={switchToSignUp}
					onSwitchToForgot={switchToForgot}
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
