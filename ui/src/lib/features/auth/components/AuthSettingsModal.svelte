<script lang="ts">
	import { currentUser, logout } from '$lib/features/auth/store';
	import { api } from '$lib/shared/utils/api';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { Link, Key, LogOut, User } from 'lucide-svelte';
	import { field } from 'svelte-forms';
	import { email as emailValidator, required } from 'svelte-forms/validators';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { loadData } from '$lib/shared/utils/dataLoader';

	export let isOpen = false;
	export let onClose: () => void;

	const loading = loadData([getConfig]);

	$: user = $currentUser;

	$: enableOidc = $loading ? true : $config.oidc_enabled;
	let activeSection: 'main' | 'credentials' = 'main';
	let isLinkingOidc = false;
	let savingCredentials = false;

	let formData: { email: string; password: string; confirmPassword: string } = {
		email: '',
		password: '',
		confirmPassword: ''
	};

	// Email field with validation
	const email = field('email', formData.email, [required(), emailValidator()]);

	// Update formData when field value changes
	$: formData.email = $email.value;

	// Reset to main view when modal opens
	$: if (isOpen) {
		resetModal();
	}

	function resetModal() {
		activeSection = 'main';
		formData = { email: '', password: '', confirmPassword: '' };
		isLinkingOidc = false;
		email.set(user?.email || '');
	}

	async function linkOidcAccount() {
		isLinkingOidc = true;
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

	async function handleSaveCredentials() {
		savingCredentials = true;
		try {
			// Build request with only changed/provided fields
			const updateRequest: { email?: string; password?: string } = {};

			// Add email if it changed and OIDC is not linked
			if (formData.email !== user?.email) {
				updateRequest.email = formData.email;
			}

			// Add password if provided
			if (formData.password) {
				updateRequest.password = formData.password;
			}

			// Check if there's anything to update
			if (Object.keys(updateRequest).length === 0) {
				pushError('No changes to save');
				return;
			}

			const result = await api.request('/auth/update', currentUser, (user) => user, {
				method: 'POST',
				body: JSON.stringify(updateRequest)
			});

			if (result?.success) {
				pushSuccess('Credentials updated successfully');
				activeSection = 'main';
				formData = { email: '', password: '', confirmPassword: '' };
			} else {
				pushError(result?.error || 'Failed to update credentials');
			}
		} finally {
			savingCredentials = false;
		}
	}

	function handleCancel() {
		if (activeSection === 'credentials') {
			activeSection = 'main';
			formData = { email: '', password: '', confirmPassword: '' };
			email.set(user?.email || '');
		} else {
			onClose();
		}
	}

	async function handleLogout() {
		await logout();
		window.location.reload();
		onClose();
	}

	$: hasOidc = !!user?.oidc_provider;
	$: modalTitle = activeSection === 'main' ? 'Account Settings' : 'Update Credentials';
	$: showSave = activeSection === 'credentials';
	$: cancelLabel = activeSection === 'main' ? 'Close' : 'Back';
</script>

<EditModal
	{isOpen}
	title={modalTitle}
	loading={savingCredentials}
	saveLabel="Save Changes"
	{showSave}
	showCancel={true}
	{cancelLabel}
	onSave={showSave ? handleSaveCredentials : null}
	onCancel={handleCancel}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={activeSection === 'main' ? User : Key} color="#3b82f6" />
	</svelte:fragment>

	{#if activeSection === 'main'}
		{#if user}
			<div class="space-y-6">
				<!-- User Info -->
				<div class="card card-static">
					<h3 class="text-primary mb-3 text-sm font-semibold">User Information</h3>
					<div class="space-y-2">
						<div class="flex justify-between">
							<span class="text-secondary text-sm">Email:</span>
							<span class="text-primary text-sm">{user.email}</span>
						</div>
						<div class="flex justify-between">
							<span class="text-secondary text-sm">User ID:</span>
							<span class="text-primary font-mono text-xs">{user.id}</span>
						</div>
					</div>
				</div>

				<!-- Authentication Methods -->
				<div>
					<h3 class="text-primary mb-3 text-sm font-semibold">Authentication Methods</h3>
					<div class="space-y-3">
						<!-- Email & Password -->
						<div class="card card-static">
							<div class="flex items-center justify-between">
								<div class="flex items-center gap-2">
									<Key class="text-secondary h-4 w-4 flex-shrink-0" />
									<div>
										<p class="text-primary text-sm font-medium">Email & Password</p>
										<p class="text-secondary text-xs">Update email and password</p>
									</div>
								</div>
								<button
									on:click={() => {
										activeSection = 'credentials';
										email.set(user.email);
									}}
									class="btn-primary"
								>
									Update
								</button>
							</div>
						</div>

						<!-- OIDC -->
						{#if enableOidc}
							<div class="card card-static">
								<div class="flex items-center justify-between">
									<div class="mr-2 flex items-center gap-2">
										<Link class="text-secondary h-4 w-4 flex-shrink-0" />
										<div>
											<p class="text-primary text-sm font-medium">{$config.oidc_provider_name}</p>
											{#if hasOidc}
												<p class="text-secondary text-xs">
													{user.oidc_provider} - Linked on {new Date(
														user.oidc_linked_at || ''
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
						{/if}
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
		{:else}
			<div class="text-secondary py-8 text-center">Loading user information...</div>
		{/if}
	{:else if activeSection === 'credentials'}
		<div class="space-y-2">
			<p class="text-secondary mb-2 text-sm">Update your email address and/or password</p>
			<div class="space-y-6">
				<!-- Email field  -->
				<TextInput label="Email" id="email" {formApi} placeholder="Enter email" field={email} />

				<!-- Password fields -->
				<div class="space-y-2">
					<Password
						{formApi}
						bind:value={formData.password}
						bind:confirmValue={formData.confirmPassword}
						showConfirm={true}
						required={false}
					/>
				</div>
			</div>
		</div>
	{/if}
</EditModal>
