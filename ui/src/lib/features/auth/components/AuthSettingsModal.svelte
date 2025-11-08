<!-- ui/src/lib/features/auth/components/AuthSettingsModal.svelte -->
<script lang="ts">
	import { currentUser, logout } from '$lib/features/auth/store';
	import { api } from '$lib/shared/utils/api';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { Link, Key, LogOut, User } from 'lucide-svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';

	export let isOpen = false;
	export let onClose: () => void;

	let activeSection: 'main' | 'password' = 'main';
	let isLinkingOidc = false;
	let loading = false;

	let formData: { password: string; confirmPassword: string } = {
		password: '',
		confirmPassword: ''
	};

	// Reset to main view when modal opens
	$: if (isOpen) {
		resetModal();
	}

	function resetModal() {
		activeSection = 'main';
		formData = { password: '', confirmPassword: '' };
		isLinkingOidc = false;
	}

	async function linkOidcAccount() {
		isLinkingOidc = true;
		// Pass current URL as return_url parameter
		const returnUrl = encodeURIComponent(window.location.origin);
		window.location.href = `/api/auth/oidc/authorize?link=true&return_url=${returnUrl}`;
	}

	async function unlinkOidcAccount() {
		const result = await api.request('/auth/oidc/unlink', currentUser, (user) => user, {
			method: 'POST'
		});

		if (result?.success) {
			pushSuccess('OIDC account unlinked successfully');
		} else {
			pushError(result?.error || 'Failed to unlink OIDC account');
		}
	}

	async function handleSavePassword() {
		loading = true;
		try {
			const result = await api.request('/auth/set-password', currentUser, (user) => user, {
				method: 'POST',
				body: JSON.stringify({ password: formData.password })
			});

			if (result?.success) {
				pushSuccess('Password updated successfully');
				activeSection = 'main';
				formData = { password: '', confirmPassword: '' };
			} else {
				pushError('Failed to set password');
			}
		} finally {
			loading = false;
		}
	}

	function handleCancel() {
		if (activeSection === 'password') {
			activeSection = 'main';
			formData = { password: '', confirmPassword: '' };
		} else {
			onClose();
		}
	}

	async function handleLogout() {
		await logout();
		window.location.reload();
		onClose();
	}

	$: hasOidc = !!$currentUser?.oidc_provider;
	$: modalTitle = activeSection === 'main' ? 'Account Settings' : 'Set Password';
	$: showSave = activeSection === 'password';
	$: cancelLabel = activeSection === 'main' ? 'Close' : 'Back';
</script>

<EditModal
	{isOpen}
	title={modalTitle}
	{loading}
	saveLabel="Save Password"
	{showSave}
	showCancel={true}
	{cancelLabel}
	onSave={showSave ? handleSavePassword : null}
	onCancel={handleCancel}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={activeSection === 'main' ? User : Key} color="#3b82f6" />
	</svelte:fragment>

	{#if activeSection === 'main'}
		<div class="space-y-6">
			<!-- User Info -->
			<div class="card card-static">
				<h3 class="text-primary mb-3 text-sm font-semibold">User Information</h3>
				<div class="space-y-2">
					<div class="flex justify-between">
						<span class="text-secondary text-sm">Email:</span>
						<span class="text-primary text-sm">{$currentUser?.email}</span>
					</div>
					<div class="flex justify-between">
						<span class="text-secondary text-sm">User ID:</span>
						<span class="text-primary font-mono text-xs">{$currentUser?.id}</span>
					</div>
				</div>
			</div>

			<!-- Authentication Methods -->
			<div>
				<h3 class="text-primary mb-3 text-sm font-semibold">Authentication Methods</h3>
				<div class="space-y-3">
					<!-- Password -->
					<div class="card card-static">
						<div class="flex items-center justify-between">
							<div class="flex items-center gap-2">
								<Key class="text-secondary h-4 w-4 flex-shrink-0" />
								<div>
									<p class="text-primary text-sm font-medium">Password</p>
									<p class="text-secondary text-xs">Set or update your password</p>
								</div>
							</div>
							<button on:click={() => (activeSection = 'password')} class="btn-primary">
								Set Password
							</button>
						</div>
					</div>

					<!-- OIDC -->
					<div class="card card-static">
						<div class="flex items-center justify-between">
							<div class="mr-2 flex items-center gap-2">
								<Link class="text-secondary h-4 w-4 flex-shrink-0" />
								<div>
									<p class="text-primary text-sm font-medium">OIDC Provider</p>
									{#if hasOidc}
										<p class="text-secondary text-xs">
											{$currentUser?.oidc_provider} - Linked on {new Date(
												$currentUser?.oidc_linked_at || ''
											).toLocaleDateString()}
										</p>
									{:else}
										<p class="text-secondary text-xs">Not linked</p>
									{/if}
								</div>
							</div>
							{#if hasOidc}
								<button on:click={unlinkOidcAccount} class="btn-danger"> Unlink </button>
							{:else}
								<button on:click={linkOidcAccount} disabled={isLinkingOidc} class="btn-primary">
									{isLinkingOidc ? 'Redirecting...' : 'Link'}
								</button>
							{/if}
						</div>
					</div>
				</div>
			</div>

			<!-- Logout -->
			<div class="card card-static">
				<div class="flex items-center justify-between">
					<div class="flex items-center gap-2">
						<LogOut class="text-secondary h-4 w-4" />
						<span class="text-primary text-sm">Sign out of your account</span>
					</div>
					<button on:click={handleLogout} class="btn-secondary"> Logout </button>
				</div>
			</div>
		</div>
	{:else if activeSection === 'password'}
		<Password
			{formApi}
			bind:value={formData.password}
			bind:confirmValue={formData.confirmPassword}
			showConfirm={true}
		/>
	{/if}
</EditModal>
