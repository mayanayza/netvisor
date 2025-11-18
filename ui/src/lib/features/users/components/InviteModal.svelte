<script lang="ts">
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { UserPlus, Copy, Check, Calendar, Link as LinkIcon, RotateCcw } from 'lucide-svelte';
	import { pushSuccess, pushError } from '$lib/shared/stores/feedback';
	import { formatTimestamp } from '$lib/shared/utils/formatting';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import type { OrganizationInvite } from '$lib/features/organizations/types';
	import { createInvite, formatInviteUrl } from '$lib/features/organizations/store';
	import type { UserOrgPermissions } from '../types';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { permissions, metadata, entities } from '$lib/shared/stores/metadata';
	import { currentUser } from '$lib/features/auth/store';

	let { isOpen = $bindable(false), onClose }: { isOpen: boolean; onClose: () => void } = $props();

	// Force Svelte to track reactivity
	$effect(() => {
		void $metadata;
		void $currentUser;
	});

	let copied = $state(false);
	let copyTimeoutId = $state<ReturnType<typeof setTimeout> | null>(null);
	let generatingInvite = $state(false);
	let invite = $state<OrganizationInvite | null>(null);

	// Make permission options reactive to metadata and currentUser changes
	let permissionOptions = $derived(
		permissions
			.getItems()
			.filter((p) =>
				$currentUser
					? permissions.getMetadata($currentUser.permissions).can_manage.includes(p.id)
					: false
			)
			.map((p) => ({ value: p.id, label: p.name, description: p.description }))
	);

	// Create form field with validation
	const permissionsField = field('permissions', 'Visualizer', [required()]);

	// Reset form when modal opens
	$effect(() => {
		if (isOpen && !invite) {
			permissionsField.set('Visualizer');
		}
	});

	function handleClose() {
		invite = null;
		onClose();
	}

	async function handleGenerateInvite() {
		generatingInvite = true;
		try {
			invite = await createInvite($permissionsField.value as UserOrgPermissions);
			if (invite) {
				pushSuccess('Invite generated successfully');
			}
		} catch (err) {
			pushError('Failed to generate invite');
			console.error('Failed to generate invite:', err);
		} finally {
			generatingInvite = false;
		}
	}

	const isSecureContext =
		window.isSecureContext ||
		window.location.hostname === 'localhost' ||
		window.location.hostname === '127.0.0.1';

	async function handleCopy() {
		if (!invite) return;

		try {
			await navigator.clipboard.writeText(formatInviteUrl(invite));
			copied = true;
			pushSuccess('Invite link copied to clipboard');

			// Reset copied state after 2 seconds
			if (copyTimeoutId) {
				clearTimeout(copyTimeoutId);
			}
			copyTimeoutId = setTimeout(() => {
				copied = false;
			}, 2000);
		} catch (err) {
			pushError('Failed to copy link to clipboard');
			console.error('Failed to copy:', err);
		}
	}

	// Cleanup timeout on component destroy
	$effect(() => {
		if (!isOpen && copyTimeoutId) {
			clearTimeout(copyTimeoutId);
			copyTimeoutId = null;
			copied = false;
		}
	});
</script>

<EditModal
	{isOpen}
	title="Invite User"
	showSave={false}
	showCancel={true}
	cancelLabel="Close"
	onCancel={handleClose}
	size="md"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={UserPlus} color={entities.getColorHelper('User').icon} />
	</svelte:fragment>

	<div class="space-y-6">
		<p class="text-secondary text-sm">
			Select the permissions level for the new user, then generate an invite link. They can use it
			to register or join your organization.
		</p>

		<!-- Permissions Selection -->
		<SelectInput
			label="Permissions Level"
			id="permissions"
			{formApi}
			field={permissionsField}
			options={permissionOptions}
			disabled={!!invite}
			helpText="Choose the access level for the invited user"
		/>

		<!-- Generate Invite Button (shown when no invite exists) -->
		{#if !invite}
			<button onclick={handleGenerateInvite} disabled={generatingInvite} class="btn-primary w-full">
				<RotateCcw class="mr-2 h-4 w-4" />
				{generatingInvite ? 'Generating...' : 'Generate Invite Link'}
			</button>
		{/if}

		<!-- Invite URL Card (shown when invite exists) -->
		{#if invite}
			<div class="card card-static">
				<div class="space-y-3">
					<div class="flex items-center gap-2">
						<LinkIcon class="text-secondary h-4 w-4 flex-shrink-0" />
						<h3 class="text-primary text-sm font-semibold">Invite Link</h3>
					</div>

					<!-- URL Display -->
					<div class="rounded-md border border-gray-600 bg-gray-800/50 p-3">
						<code class="text-primary block break-all text-sm">{formatInviteUrl(invite)}</code>
					</div>

					<!-- Copy Button -->
					{#if isSecureContext}
						<button onclick={handleCopy} class="btn-primary w-full" disabled={copied}>
							{#if copied}
								<Check class="mr-2 h-4 w-4" />
								Copied!
							{:else}
								<Copy class="mr-2 h-4 w-4" />
								Copy Link
							{/if}
						</button>
					{/if}
				</div>
			</div>

			<!-- Expiration Info -->
			<div class="card card-static">
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-blue-500/10"
					>
						<Calendar class="h-5 w-5 text-blue-400" />
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">
							{'Expires ' + formatTimestamp(invite.expires_at)}
						</p>
					</div>
				</div>
			</div>

			<InlineWarning
				title="Sensitive Link"
				body="Anyone with this link can join your organization with {$permissionsField.value} permissions. Keep it secure and only share it with people you trust."
			/>
		{/if}
	</div>
</EditModal>
