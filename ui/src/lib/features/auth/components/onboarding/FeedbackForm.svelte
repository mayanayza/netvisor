<script lang="ts">
	import { config } from '$lib/shared/stores/config';
	import { trackEvent } from '$lib/shared/utils/analytics';
	import { pushSuccess, pushError } from '$lib/shared/stores/feedback';
	import { field } from 'svelte-forms';
	import { email as emailValidator } from 'svelte-forms/validators';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import TextArea from '$lib/shared/components/forms/input/TextArea.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';

	export let blocker: string;
	export let showActions: boolean = true;
	export let onOtherIssue: (() => void) | null = null;

	const feedbackField = field('feedback', '', []);
	const emailField = field('email', '', [emailValidator()]);
	const subscribeField = field('subscribe', true, []);

	let isSubmitting = false;
	let hasSubmitted = false;

	// Simple formApi stub for standalone use
	const formApi: FormApi = {
		registerField: () => {},
		unregisterField: () => {}
	};

	export async function handleSubmit() {
		const feedbackText = $feedbackField.value;
		const email = $emailField.value;

		if (!feedbackText.trim()) return;

		isSubmitting = true;

		try {
			// Submit to Plunk if configured
			if ($config?.plunk_key && email.trim()) {
				await fetch('https://api.useplunk.com/v1/track', {
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
						Authorization: `Bearer ${$config.plunk_key}`
					},
					body: JSON.stringify({
						event: 'onboarding_feedback',
						email: email.trim(),
						subscribed: $subscribeField.value,
						data: {
							blocker,
							message: feedbackText.trim()
						}
					})
				});
			}

			// Track analytics
			trackEvent('onboarding_feedback_submitted', {
				email_provided: !!email.trim(),
				blocker,
				message: feedbackText.trim()
			});

			pushSuccess('Thank you for your feedback!');
			hasSubmitted = true;
		} catch (error) {
			console.error('Failed to submit feedback:', error);
			pushError('Failed to submit feedback. Please try again.');
		} finally {
			isSubmitting = false;
		}
	}

	$: canSubmit = $feedbackField.value.trim() !== '' && !isSubmitting && !hasSubmitted;
</script>

<div class="space-y-3">
	<TextArea
		label="What's blocking you from getting started?"
		id="feedback"
		{formApi}
		field={feedbackField}
		placeholder="Tell us what you need help with..."
		rows={3}
	/>

	<TextInput
		label="Email"
		id="email"
		{formApi}
		field={emailField}
		placeholder="your@email.com"
		helpText="Optional - we'll follow up if we can help"
	/>

	<Checkbox
		field={subscribeField}
		id="subscribe"
		{formApi}
		label="Also email me about product news and updates"
	/>

	{#if showActions}
		<div class="flex items-center justify-between pt-2">
			{#if onOtherIssue}
				<button
					type="button"
					class="text-secondary hover:text-primary text-sm"
					on:click={onOtherIssue}
				>
					I have another issue
				</button>
			{:else}
				<div></div>
			{/if}
			<button type="button" class="btn-primary" disabled={!canSubmit} on:click={handleSubmit}>
				{#if hasSubmitted}
					Submitted
				{:else if isSubmitting}
					Sending...
				{:else}
					Submit
				{/if}
			</button>
		</div>
	{/if}
</div>
