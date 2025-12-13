<script lang="ts">
	import posthog from 'posthog-js';
	import { dev } from '$app/environment';
	import { onMount } from 'svelte';

	const COOKIE_NAME = 'netvisor_gdpr';
	const COOKIE_DOMAIN = dev ? '' : '.netvisor.io';
	const COOKIE_DAYS = 365;

	interface CookiePreferences {
		necessary: boolean;
		analytics: boolean;
	}

	let preferences: CookiePreferences = $state({
		necessary: true,
		analytics: false
	});

	let showBanner = $state(false);
	let showSettings = $state(false);
	let mounted = $state(false);
	let hasConsented = $state(false);

	onMount(() => {
		mounted = true;
		const saved = getCookie(COOKIE_NAME);
		if (saved) {
			try {
				const parsed = JSON.parse(saved) as CookiePreferences;
				preferences = { ...preferences, ...parsed };
				hasConsented = true;
				applyPreferences();
			} catch {
				showBanner = true;
			}
		} else {
			showBanner = true;
		}
	});

	function getCookie(name: string): string | null {
		const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
		return match ? decodeURIComponent(match[2]) : null;
	}

	function setCookie(name: string, value: string, days: number) {
		const expires = new Date(Date.now() + days * 864e5).toUTCString();
		const domain = COOKIE_DOMAIN ? `; domain=${COOKIE_DOMAIN}` : '';
		document.cookie = `${name}=${encodeURIComponent(value)}; expires=${expires}; path=/${domain}; SameSite=Lax`;
	}

	function applyPreferences() {
		if (posthog.__loaded) {
			if (preferences.analytics) {
				posthog.opt_in_capturing();
			} else {
				posthog.opt_out_capturing();
			}
		}
	}

	function savePreferences() {
		setCookie(COOKIE_NAME, JSON.stringify(preferences), COOKIE_DAYS);
		hasConsented = true;
		showBanner = false;
		showSettings = false;
		applyPreferences();
	}

	function acceptAll() {
		preferences = { necessary: true, analytics: true };
		savePreferences();
	}

	function rejectAll() {
		preferences = { necessary: true, analytics: false };
		savePreferences();
	}

	function openSettings() {
		showSettings = true;
		showBanner = true;
	}

	function closeSettings() {
		showSettings = false;
		if (hasConsented) {
			showBanner = false;
		}
	}
</script>

{#if mounted}
	{#if showBanner && !showSettings}
		<div class="spacer"></div>
	{/if}
	{#if showBanner}
		<div class="overlay" class:visible={showSettings}></div>
		<div class="banner" class:settings-open={showSettings}>
			{#if showSettings}
				<div class="settings-panel">
					<div class="settings-header">
						<h3 class="title">Cookie Preferences</h3>
						<button class="close-btn" onclick={closeSettings} aria-label="Close">
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="20"
								height="20"
								viewBox="0 0 24 24"
								fill="none"
								stroke="currentColor"
								stroke-width="2"
								stroke-linecap="round"
								stroke-linejoin="round"
							>
								<line x1="18" y1="6" x2="6" y2="18"></line>
								<line x1="6" y1="6" x2="18" y2="18"></line>
							</svg>
						</button>
					</div>
					<p class="settings-description">
						Manage your cookie preferences below. You can enable or disable different types of
						cookies. See our <a href="https://netvisor.io/privacy">privacy policy</a> for more details.
					</p>

					<div class="cookie-options">
						<div class="cookie-option">
							<div class="option-header">
								<label class="option-label">
									<input type="checkbox" checked disabled />
									<span class="checkbox disabled"></span>
									<span class="option-title">Necessary</span>
								</label>
								<span class="always-on">Always on</span>
							</div>
							<p class="option-description">
								Essential cookies required for the website to function. These cannot be disabled.
							</p>
						</div>

						<div class="cookie-option">
							<div class="option-header">
								<label class="option-label">
									<input type="checkbox" bind:checked={preferences.analytics} />
									<span class="checkbox"></span>
									<span class="option-title">Analytics</span>
								</label>
							</div>
							<p class="option-description">
								Help us understand how visitors interact with our website by collecting anonymous
								usage data.
							</p>
						</div>
					</div>

					<div class="settings-buttons">
						<button class="btn btn-secondary" onclick={rejectAll}>Reject All</button>
						<button class="btn btn-secondary" onclick={acceptAll}>Accept All</button>
						<button class="btn btn-primary" onclick={savePreferences}>Save Preferences</button>
					</div>
				</div>
			{:else}
				<div class="content">
					<div class="text-content">
						<h3 class="title">Cookie Settings</h3>
						<p class="description">
							We use cookies to improve your experience and analyze site traffic. See our <a
								href="https://netvisor.io/privacy">privacy policy</a
							> for details.
						</p>
					</div>
					<div class="buttons">
						<button class="btn btn-link" onclick={openSettings}>Customize</button>
						<button class="btn btn-secondary" onclick={rejectAll}>Reject All</button>
						<button class="btn btn-primary" onclick={acceptAll}>Accept All</button>
					</div>
				</div>
			{/if}
		</div>
	{:else if hasConsented}
		<button class="toggle" onclick={openSettings} aria-label="Cookie settings">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				width="20"
				height="20"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
			>
				<circle cx="12" cy="12" r="10" />
				<circle cx="8" cy="9" r="1.5" fill="currentColor" />
				<circle cx="15" cy="8" r="1.5" fill="currentColor" />
				<circle cx="10" cy="14" r="1.5" fill="currentColor" />
				<circle cx="16" cy="13" r="1.5" fill="currentColor" />
				<circle cx="13" cy="17" r="1" fill="currentColor" />
			</svg>
		</button>
	{/if}
{/if}

<style>
	.spacer {
		height: 100px;
	}

	@media (min-width: 768px) {
		.spacer {
			height: 72px;
		}
	}

	.overlay {
		position: fixed;
		inset: 0;
		background: rgba(0, 0, 0, 0);
		z-index: 9998;
		pointer-events: none;
		transition: background 200ms;
	}

	.overlay.visible {
		background: rgba(0, 0, 0, 0.5);
		pointer-events: auto;
	}

	.banner {
		position: fixed;
		bottom: 0;
		left: 0;
		right: 0;
		background: #1f2937;
		border-top: 1px solid #374151;
		padding: 1.25rem;
		z-index: 9999;
	}

	.banner.settings-open {
		bottom: auto;
		top: 50%;
		left: 50%;
		right: auto;
		transform: translate(-50%, -50%);
		max-width: 500px;
		width: calc(100% - 2rem);
		border: 1px solid #374151;
		border-radius: 0.5rem;
		max-height: 90vh;
		overflow-y: auto;
	}

	.content {
		max-width: 1200px;
		margin: 0 auto;
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.text-content {
		flex: 1;
	}

	@media (min-width: 768px) {
		.content {
			flex-direction: row;
			align-items: center;
			justify-content: space-between;
		}
	}

	.title {
		color: white;
		font-size: 1rem;
		font-weight: 600;
		margin: 0 0 0.25rem 0;
	}

	.description {
		color: #9ca3af;
		font-size: 0.875rem;
		margin: 0;
	}

	.description a,
	.settings-description a {
		color: #60a5fa;
		text-decoration: underline;
	}

	.description a:hover,
	.settings-description a:hover {
		color: #93c5fd;
	}

	.buttons {
		display: flex;
		gap: 0.5rem;
		flex-shrink: 0;
		flex-wrap: wrap;
	}

	.btn {
		padding: 0.5rem 1rem;
		border-radius: 0.375rem;
		font-weight: 500;
		font-size: 0.875rem;
		cursor: pointer;
		transition:
			background-color 150ms,
			border-color 150ms,
			color 150ms;
	}

	.btn-primary {
		background: #1d4ed8;
		color: white;
		border: 1px solid #2563eb;
	}

	.btn-primary:hover {
		background: #2563eb;
		border-color: #3b82f6;
	}

	.btn-secondary {
		background: transparent;
		color: #9ca3af;
		border: 1px solid #374151;
	}

	.btn-secondary:hover {
		background: #374151;
		border-color: #4b5563;
		color: #e5e7eb;
	}

	.btn-link {
		background: transparent;
		color: #9ca3af;
		border: 1px solid transparent;
		text-decoration: underline;
	}

	.btn-link:hover {
		color: #e5e7eb;
	}

	/* Settings panel styles */
	.settings-panel {
		display: flex;
		flex-direction: column;
		gap: 1rem;
	}

	.settings-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
	}

	.close-btn {
		background: transparent;
		border: none;
		color: #9ca3af;
		cursor: pointer;
		padding: 0.25rem;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: 0.25rem;
	}

	.close-btn:hover {
		color: white;
		background: #374151;
	}

	.settings-description {
		color: #9ca3af;
		font-size: 0.875rem;
		margin: 0;
	}

	.cookie-options {
		display: flex;
		flex-direction: column;
		gap: 1rem;
		margin: 0.5rem 0;
	}

	.cookie-option {
		background: #111827;
		border: 1px solid #374151;
		border-radius: 0.375rem;
		padding: 1rem;
	}

	.option-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 0.5rem;
	}

	.option-label {
		display: flex;
		align-items: center;
		gap: 0.75rem;
		cursor: pointer;
	}

	.option-label input {
		position: absolute;
		opacity: 0;
		pointer-events: none;
	}

	.checkbox {
		width: 1.25rem;
		height: 1.25rem;
		border: 1px solid #4b5563;
		border-radius: 0.25rem;
		background: #374151;
		display: flex;
		align-items: center;
		justify-content: center;
		flex-shrink: 0;
		transition:
			background 150ms,
			border-color 150ms;
	}

	.checkbox.disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.option-label input:checked + .checkbox {
		background: #2563eb;
		border-color: #2563eb;
	}

	.option-label input:checked + .checkbox::after {
		content: '';
		width: 0.5rem;
		height: 0.75rem;
		border: solid white;
		border-width: 0 2px 2px 0;
		transform: rotate(45deg) translateY(-1px);
	}

	.option-label:hover .checkbox:not(.disabled) {
		border-color: #6b7280;
	}

	.option-title {
		color: white;
		font-weight: 500;
		font-size: 0.9375rem;
	}

	.always-on {
		color: #6b7280;
		font-size: 0.75rem;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.option-description {
		color: #9ca3af;
		font-size: 0.8125rem;
		margin: 0;
		line-height: 1.4;
	}

	.settings-buttons {
		display: flex;
		gap: 0.5rem;
		justify-content: flex-end;
		flex-wrap: wrap;
		padding-top: 0.5rem;
		border-top: 1px solid #374151;
	}

	/* Toggle button */
	.toggle {
		position: fixed;
		bottom: 1rem;
		left: 1rem;
		width: 3rem;
		height: 3rem;
		border-radius: 50%;
		background: #1f2937;
		border: 1px solid #374151;
		color: #9ca3af;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3);
		z-index: 9999;
		transition:
			background-color 150ms,
			color 150ms;
	}

	.toggle:hover {
		background: #374151;
		color: white;
	}
</style>
