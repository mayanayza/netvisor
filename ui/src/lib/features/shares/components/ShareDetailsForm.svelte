<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import type { Share } from '../types/base';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import DateInput from '$lib/shared/components/forms/input/DateInput.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import { generateShareUrl, generateEmbedCode } from '../store';
	import InlineSuccess from '$lib/shared/components/feedback/InlineSuccess.svelte';

	export let formApi: FormApi;
	export let formData: Partial<Share>;
	export let isEditing: boolean = false;
	export let passwordValue: string = '';
	export let hasEmbedsFeature: boolean = true;
	export let createdShare: Share | null = null;

	// Form fields
	const name = field('name', formData.name || '', [required(), maxLength(100)]);
	const embedWidth = field('embedWidth', '800', []);
	const embedHeight = field('embedHeight', '600', []);
	const password = field('password', '', []);

	// Sync password field to exported value
	$: passwordValue = $password.value;
	const allowedDomains = field('allowedDomains', formData.allowed_domains?.join(', ') || '', []);
	const expiresAt = field('expiresAt', formData.expires_at || '', []);
	const showZoomControls = field(
		'showZoomControls',
		formData.options?.show_zoom_controls ?? true,
		[]
	);
	const showInspectPanel = field(
		'showInspectPanel',
		formData.options?.show_inspect_panel ?? true,
		[]
	);
	const showExportButton = field(
		'showExportButton',
		formData.options?.show_export_button ?? true,
		[]
	);
	const isEnabled = field('isEnabled', formData.is_enabled ?? true, []);

	// Sync form fields to formData
	$: formData.name = $name.value;
	$: formData.allowed_domains = $allowedDomains.value.trim()
		? $allowedDomains.value
				.split(',')
				.map((d: string) => d.trim())
				.filter(Boolean)
		: undefined;
	$: formData.expires_at = $expiresAt.value ? $expiresAt.value : undefined;
	$: if (formData.options) {
		formData.options.show_zoom_controls = $showZoomControls.value;
		formData.options.show_inspect_panel = $showInspectPanel.value;
		formData.options.show_export_button = $showExportButton.value;
	}
	$: formData.is_enabled = $isEnabled.value;
</script>

<div class="space-y-6">
	{#if isEditing}
		<InlineInfo
			title="Changes may take up to 5 minutes to appear"
			body="Share links and embeds are cached. Any updates you make won't be visible immediately."
			dismissableKey="share-cache-info"
		/>
	{/if}
	<!-- Name -->
	<div class="card card-static">
		<TextInput
			label="Name"
			id="share-name"
			{formApi}
			placeholder="My shared topology"
			required={true}
			field={name}
			disabled={!!createdShare}
		/>
	</div>

	<div class="card card-static space-y-3">
		<span class="text-secondary text-m">Access Control</span>
		<!-- Password -->
		<TextInput
			label="Password"
			id="share-password"
			type="password"
			{formApi}
			placeholder="Enter password"
			field={password}
			disabled={!!createdShare}
			helpText={isEditing
				? 'Leave empty to keep the current password'
				: 'Leave empty to allow public access with no password'}
		/>

		<!-- Enabled & Expiration -->
		<div class="grid grid-cols-2 gap-4">
			<DateInput
				{formApi}
				field={expiresAt}
				label="Expiration Date"
				id="expires-at"
				disabled={!!createdShare}
				helpText="Leave empty to never expire"
			/>
			<div class="flex items-center">
				<Checkbox
					label="Enabled"
					id="is-enabled"
					{formApi}
					field={isEnabled}
					disabled={!!createdShare}
					helpText="Disable to temporarily prevent access"
				/>
			</div>
		</div>
		<!-- Allowed Domains -->
		<TextInput
			label="Allowed Embed Domains"
			id="allowed-domains"
			{formApi}
			placeholder="example.com, *.mysite.com"
			field={allowedDomains}
			disabled={!!createdShare}
			helpText="Restrict which domains can embed this share. Leave empty to allow all domains."
		/>
	</div>

	<div class="card card-static space-y-3">
		<span class="text-secondary text-m">Display Options</span>
		<Checkbox
			label="Show zoom controls"
			id="show-zoom-controls"
			{formApi}
			field={showZoomControls}
			disabled={!!createdShare}
		/>
		<Checkbox
			label="Show inspect panel"
			id="show-inspect-panel"
			{formApi}
			field={showInspectPanel}
			disabled={!!createdShare}
		/>
		<Checkbox
			label="Show export button"
			id="show-export-button"
			{formApi}
			field={showExportButton}
			disabled={!!createdShare}
		/>
		<span class="block text-sm font-medium text-gray-300">Embed Dimensions</span>
		<div class="grid grid-cols-2 gap-4">
			<TextInput
				label="Width"
				id="embed-width"
				type="number"
				{formApi}
				field={embedWidth}
				placeholder="800"
			/>
			<TextInput
				label="Height"
				id="embed-height"
				type="number"
				{formApi}
				field={embedHeight}
				placeholder="600"
			/>
		</div>
	</div>

	<!-- Share URL / Embed Code (shown after creation or when editing) -->
	{#if createdShare || isEditing}
		{@const shareId = createdShare?.id || formData.id || ''}
		<div class="space-y-4">
			{#if createdShare}
				<InlineSuccess
					title="Share created"
					body="To edit this share's settings, go to the Sharing tab."
				/>
			{/if}
			<div>
				<span class="mb-1 block text-sm font-medium text-gray-300">Share URL</span>
				<CodeContainer language="bash" expandable={false} code={generateShareUrl(shareId)} />
			</div>
			<div class="space-y-2">
				<span class="mb-1 block text-sm font-medium text-gray-300">Embed Code</span>
				{#if !hasEmbedsFeature}
					<InlineInfo
						title="Embeds require an upgraded plan"
						body="Upgrade your plan to embed this share on external websites."
					/>
				{:else}
					<CodeContainer
						language="html"
						expandable={false}
						code={generateEmbedCode(
							shareId,
							parseInt($embedWidth.value) || 800,
							parseInt($embedHeight.value) || 600
						)}
					/>
				{/if}
			</div>
		</div>
	{/if}
</div>
