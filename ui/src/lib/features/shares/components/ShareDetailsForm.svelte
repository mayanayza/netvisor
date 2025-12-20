<script lang="ts">
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { maxLength } from '$lib/shared/components/forms/validators';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import type { Share, ShareType } from '../types/base';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import { Code, Link, Globe } from 'lucide-svelte';
	import DateInput from '$lib/shared/components/forms/input/DateInput.svelte';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';

	export let formApi: FormApi;
	export let formData: Partial<Share>;
	export let isEditing: boolean = false;
	export let passwordValue: string = '';
	export let showShowcase: boolean = false;
	export let blockEmbeds: boolean = false;

	// Form fields
	const name = field('name', formData.name || '', [required(), maxLength(100)]);
	const password = field('password', '', []);

	// Sync password field to exported value
	$: passwordValue = $password.value;
	const allowedDomains = field('allowedDomains', formData.allowed_domains?.join(', ') || '', []);
	const expiresAt = field('expiresAt', formData.expires_at || '', []);
	const showZoomControls = field(
		'showZoomControls',
		formData.embed_options?.show_zoom_controls ?? true,
		[]
	);
	const showInspectPanel = field(
		'showInspectPanel',
		formData.embed_options?.show_inspect_panel ?? true,
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
	$: if (formData.embed_options) {
		formData.embed_options.show_zoom_controls = $showZoomControls.value;
		formData.embed_options.show_inspect_panel = $showInspectPanel.value;
	}
	$: formData.is_enabled = $isEnabled.value;

	function handleTypeChange(type: ShareType | 'showcase') {
		if (type === 'showcase') {
			showShowcase = true;
			return;
		}
		showShowcase = false;
		formData.share_type = type;
		// Reset type-specific fields
		if (type === 'link') {
			allowedDomains.set('');
		} else {
			password.set('');
		}
	}
</script>

<div class="space-y-6">
	<!-- Share Type Selector (only for new shares) -->
	{#if !isEditing}
		<div>
			<span class="mb-2 block text-sm font-medium text-gray-300">Share Type</span>
			<div class="flex gap-3">
				<button
					type="button"
					on:click={() => handleTypeChange('link')}
					class="flex flex-1 items-center justify-center gap-2 rounded-lg border-2 px-4 py-3 transition-colors {!showShowcase &&
					formData.share_type === 'link'
						? 'border-blue-500 bg-blue-500/10 text-blue-400'
						: 'border-gray-600 bg-gray-700 text-gray-400 hover:border-gray-500'}"
				>
					<Link class="h-5 w-5" />
					<span>Link</span>
				</button>
				<button
					type="button"
					on:click={() => handleTypeChange('embed')}
					class="flex flex-1 items-center justify-center gap-2 rounded-lg border-2 px-4 py-3 transition-colors {!showShowcase &&
					formData.share_type === 'embed'
						? 'border-purple-500 bg-purple-500/10 text-purple-400'
						: 'border-gray-600 bg-gray-700 text-gray-400 hover:border-gray-500'}"
				>
					<Code class="h-5 w-5" />
					<span>Embed</span>
				</button>
				<button
					type="button"
					on:click={() => handleTypeChange('showcase')}
					class="flex flex-1 items-center justify-center gap-2 rounded-lg border-2 px-4 py-3 transition-colors {showShowcase
						? 'border-emerald-500 bg-emerald-500/10 text-emerald-400'
						: 'border-gray-600 bg-gray-700 text-gray-400 hover:border-gray-500'}"
				>
					<Globe class="h-5 w-5" />
					<span>Showcase</span>
				</button>
			</div>
		</div>
	{/if}

	{#if showShowcase}
		<InlineInfo
			title="Share on Scanopy"
			body="Want to showcase your topology on the Scanopy website? Submit your topology for review and it may be featured in our <a class='underline hover:text-blue-300 transition-colors' href='https://scanopy.net/showcase' target='_blank' rel='noopener noreferrer'>public gallery</a>."
		/>
		<a
			href="https://tally.so/r/lbqLAv"
			target="_blank"
			rel="noopener noreferrer"
			class="btn-primary inline-flex w-full justify-center"
		>
			Submit for Community Showcase
		</a>
	{/if}

	{#if !showShowcase}
		{#if blockEmbeds}
			<InlineWarning
				title="Embeds not available on your plan"
				body="Embeds are not available on your current plan. Please upgrade your plan to use this feature."
			/>
		{/if}
		<!-- Name -->
		<TextInput
			label="Name"
			id="share-name"
			{formApi}
			placeholder="My shared topology"
			required={true}
			field={name}
		/>

		<!-- Password (Link only) -->
		<div class="space-y-3">
			<TextInput
				label="Password"
				id="share-password"
				type="password"
				{formApi}
				placeholder="Enter password"
				field={password}
				helpText={isEditing
					? 'Leave empty to keep the current password'
					: 'Leave empty to allow public access with no password'}
			/>
		</div>

		<!-- Allowed Domains (Embed only) -->
		{#if formData.share_type === 'embed'}
			<TextInput
				label="Allowed Domains"
				id="allowed-domains"
				{formApi}
				placeholder="example.com, *.mysite.com"
				field={allowedDomains}
				helpText="Comma-separated list. Supports wildcards (*.example.com). Leave empty to allow all domains."
			/>
		{/if}

		<!-- Enabled -->
		<Checkbox
			label="Enabled"
			id="is-enabled"
			{formApi}
			field={isEnabled}
			helpText="Disable to temporarily prevent access to this share"
		/>

		<!-- Expiration -->
		<div class="space-y-3">
			<div>
				<DateInput
					{formApi}
					field={expiresAt}
					label="Expiration Date"
					id="expires-at"
					helpText="Leave empty to never expire"
				/>
			</div>
		</div>

		<!-- Embed Options -->
		{#if formData.embed_options}
			<div class="space-y-3">
				<span class="block text-sm font-medium text-gray-300">Display Options</span>
				<Checkbox
					label="Show zoom controls"
					id="show-zoom-controls"
					{formApi}
					field={showZoomControls}
				/>
				<Checkbox
					label="Show inspect panel"
					id="show-inspect-panel"
					{formApi}
					field={showInspectPanel}
				/>
			</div>
		{/if}
	{/if}
</div>
