import { writable } from 'svelte/store';
import { api } from '../utils/api';

export const config = writable<PublicServerConfig>();

export interface OidcProviderMetadata {
	name: string;
	slug: string;
	logo: string;
}

export interface PublicServerConfig {
	server_port: number;
	disable_registration: boolean;
	oidc_providers: OidcProviderMetadata[];
	billing_enabled: boolean;
	has_integrated_daemon: boolean;
	has_email_service: boolean;
	has_email_opt_in: boolean;
	public_url: string;
	posthog_key: string | null;
	needs_cookie_consent: boolean;
}

export async function getConfig() {
	await api.request<PublicServerConfig>('/config', config, (config) => config, {
		method: 'GET'
	});
}
