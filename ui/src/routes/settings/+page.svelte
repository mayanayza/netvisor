<!-- ui/src/routes/settings/+page.svelte -->
<script lang="ts">
	import { currentUser, logout } from '$lib/features/auth/store';
	import { api } from '$lib/shared/utils/api';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { Link } from 'lucide-svelte';
	import Toast from '$lib/shared/components/feedback/Toast.svelte';

	let isLinkingOidc = false;

	async function linkOidcAccount() {
		isLinkingOidc = true;
		// Redirect to OIDC authorization endpoint
		window.location.href = '/api/auth/oidc/authorize';
	}

	async function unlinkOidcAccount() {
		const confirmed = confirm('Are you sure you want to unlink your OIDC account? You will need a password to log in.');
		if (!confirmed) return;

		const result = await api.request('/api/auth/oidc/unlink', currentUser, (user) => user, {
			method: 'POST'
		});

		if (result?.success) {
			pushSuccess('OIDC account unlinked successfully');
		} else {
			pushError('Failed to unlink OIDC account');
		}
	}

	async function handleLogout() {
		await logout();
	}
</script>

<div class="min-h-screen bg-gray-900 p-8">
	<div class="mx-auto max-w-4xl">
		<h1 class="mb-8 text-3xl font-bold text-white">Account Settings</h1>

		<!-- Connected Accounts Section -->
		<div class="rounded-lg bg-gray-800 p-6 shadow-lg">
			<h2 class="mb-4 flex items-center text-xl font-semibold text-white">
				<Link class="mr-2 h-5 w-5" />
				Connected Accounts
			</h2>

			{#if $currentUser?.oidc_provider}
				<div class="flex items-center justify-between rounded-lg bg-gray-700 p-4">
					<div>
						<p class="font-medium text-white">
							{$currentUser.oidc_provider || 'OIDC Provider'} Account
						</p>
						<p class="text-sm text-gray-400">
							Linked on {new Date($currentUser.oidc_linked_at || '').toLocaleDateString()}
						</p>
					</div>
					<button
						on:click={unlinkOidcAccount}
						class="rounded bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700"
					>
						Unlink
					</button>
				</div>
			{:else}
				<div class="rounded-lg bg-gray-700 p-4">
					<p class="mb-4 text-gray-300">
						Link an OIDC provider to enable single sign-on for your account.
					</p>
					<button
						on:click={linkOidcAccount}
						disabled={isLinkingOidc}
						class="rounded bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
					>
						{isLinkingOidc ? 'Redirecting...' : 'Link OIDC Account'}
					</button>
				</div>
			{/if}
		</div>

		<!-- User Info Section -->
		<div class="mt-6 rounded-lg bg-gray-800 p-6 shadow-lg">
			<h2 class="mb-4 text-xl font-semibold text-white">User Information</h2>
			<div class="space-y-3">
				<div>
					<span class="text-sm text-gray-400">Username:</span>
					<span class="ml-2 text-white">{$currentUser?.username}</span>
				</div>
				<div>
					<span class="text-sm text-gray-400">User ID:</span>
					<span class="ml-2 font-mono text-sm text-white">{$currentUser?.id}</span>
				</div>
			</div>
		</div>

		<!-- Logout Button -->
		<div class="mt-6">
			<button
				on:click={handleLogout}
				class="rounded bg-gray-700 px-4 py-2 text-sm font-medium text-white hover:bg-gray-600"
			>
				Logout
			</button>
		</div>
	</div>

	<Toast />
</div>