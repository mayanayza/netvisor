<script lang="ts">
	import { currentUser, logout } from '$lib/features/auth/store';
	import { apiClient } from '$lib/api/client';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { Link, Key, LogOut, User } from 'lucide-svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import Password from '$lib/shared/components/forms/input/Password.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { config, getConfig } from '$lib/shared/stores/config';
	import { loadData } from '$lib/shared/utils/dataLoader';
	import { organization } from '$lib/features/organizations/store';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';
	import { emailValidator } from '$lib/shared/components/forms/validators';

	export let isOpen = false;
	export let onClose: () => void;

	const loading = loadData([getConfig]);

	$: user = $currentUser;
	$: oidcProviders = $loading ? [] : ($config?.oidc_providers ?? []);
	$: hasOidcProviders = oidcProviders.length > 0;

	let activeSection: 'main' | 'credentials' = 'main';
	let linkingProviderSlug: string | null = null;
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

	// Find which provider (if any) is linked to this user
	$: linkedProvider = user?.oidc_provider
		? oidcProviders.find((p) => p.slug === user.oidc_provider)
		: null;

	function resetModal() {
		activeSection = 'main';
		formData = { email: '', password: '', confirmPassword: '' };
		linkingProviderSlug = null;
		email.set(user?.email || '');
	}

	function linkOidcAccount(providerSlug: string) {
		linkingProviderSlug = providerSlug;
		const returnUrl = encodeURIComponent(window.location.origin);
		window.location.href = `/api/auth/oidc/${providerSlug}/authorize?flow=link&return_url=${returnUrl}`;
	}

	async function unlinkOidcAccount(providerSlug: string) {
		const { data } = await apiClient.POST('/api/auth/oidc/{slug}/unlink', {
			params: { path: { slug: providerSlug } }
		});

		if (data?.success && data.data) {
			currentUser.set(data.data);
			pushSuccess('OIDC account unlinked successfully');
		} else {
			pushError(data?.error || 'Failed to unlink OIDC account');
		}
	}

	async function handleSaveCredentials() {
		savingCredentials = true;
		try {
			// Build request with only changed/provided fields
			const updateRequest: { email?: string; password?: string } = {};

			// Add email if it changed
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

			const { data } = await apiClient.POST('/api/auth/update', {
				body: updateRequest
			});

			if (data?.success && data.data) {
				currentUser.set(data.data);
				pushSuccess('Credentials updated successfully');
				activeSection = 'main';
				formData = { email: '', password: '', confirmPassword: '' };
			} else {
				pushError(data?.error || 'Failed to update credentials');
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

	$: hasLinkedOidc = !!user?.oidc_provider;
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
				<InfoCard title="User Information">
					<InfoRow label="Organization">{$organization?.name}</InfoRow>
					<InfoRow label="Email">{user.email}</InfoRow>
					<InfoRow label="Permissions" mono={true}>{user.permissions}</InfoRow>
					<InfoRow label="User ID" mono={true}>{user.id}</InfoRow>
				</InfoCard>

				<!-- Authentication Methods -->
				<div>
					<h3 class="text-primary mb-3 text-sm font-semibold">Authentication Methods</h3>
					<div class="space-y-3">
						<!-- Email & Password -->
						<InfoCard variant="compact">
							<div class="flex items-center justify-between">
								<div class="flex items-center gap-4">
									<Key class="text-secondary h-5 w-5 flex-shrink-0" />
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
						</InfoCard>

						<!-- OIDC Providers -->
						{#if hasOidcProviders}
							<div class="space-y-3">
								<p class="text-secondary text-xs">
									Link your account with an identity provider for faster sign-in. You can only link
									one provider at a time.
								</p>

								{#each oidcProviders as provider (provider.slug)}
									{@const isLinked = hasLinkedOidc && user.oidc_provider === provider.slug}
									{@const isDisabled = hasLinkedOidc && !isLinked}
									<InfoCard variant="compact">
										<div class="flex items-center justify-between">
											<div class="mr-2 flex items-center gap-4">
												{#if provider.logo}
													<img src={provider.logo} alt={provider.name} class="h-5 w-5" />
												{:else}
													<Link class="text-secondary h-5 w-5 flex-shrink-0" />
												{/if}
												<div>
													<p class="text-primary text-sm font-medium">{provider.name}</p>
													{#if isLinked}
														<p class="text-secondary text-xs">
															Linked on {new Date(user.oidc_linked_at || '').toLocaleDateString()}
														</p>
													{:else if isDisabled}
														<p class="text-secondary text-xs">
															Unlink {linkedProvider?.name} first to link this provider
														</p>
													{:else}
														<p class="text-secondary text-xs">Not linked</p>
													{/if}
												</div>
											</div>
											{#if isLinked}
												<button
													on:click={() => unlinkOidcAccount(provider.slug)}
													class="btn-danger"
												>
													Unlink
												</button>
											{:else if !hasLinkedOidc}
												<button
													on:click={() => linkOidcAccount(provider.slug)}
													disabled={(linkingProviderSlug && linkingProviderSlug != provider.slug) ||
														isDisabled}
													class={isDisabled ? 'btn-disabled' : 'btn-primary'}
												>
													{linkingProviderSlug == provider.slug ? 'Redirecting...' : 'Link'}
												</button>
											{:else}
												<button disabled={isDisabled} class="btn-primary"> Link </button>
											{/if}
										</div>
									</InfoCard>
								{/each}
							</div>
						{/if}
					</div>
				</div>

				<!-- Logout -->
				<InfoCard variant="compact">
					<div class="flex items-center justify-between">
						<div class="flex items-center gap-4">
							<LogOut class="text-secondary h-5 w-5" />
							<span class="text-primary text-sm">Sign out of your account</span>
						</div>
						<button on:click={handleLogout} class="btn-secondary"> Logout </button>
					</div>
				</InfoCard>
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
