import { writable } from 'svelte/store';
import { api } from '../utils/api';

export const config = writable<PublicServerConfig>();

export interface OidcProviderMetadata {
	name: string;
	slug: string;
	logo: string;
}

export type DeploymentType = 'cloud' | 'commercial' | 'community';

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
	deployment_type: DeploymentType;
	plunk_key: string | null;
}

// Helper functions for deployment type checks
export const isCloud = (cfg: PublicServerConfig) => cfg.deployment_type === 'cloud';
export const isCommercial = (cfg: PublicServerConfig) => cfg.deployment_type === 'commercial';
export const isCommunity = (cfg: PublicServerConfig) => cfg.deployment_type === 'community';
export const isSelfHosted = (cfg: PublicServerConfig) =>
	cfg.deployment_type === 'commercial' || cfg.deployment_type === 'community';

export async function getConfig() {
	await api.request<PublicServerConfig>('/config', config, (config) => config, {
		method: 'GET'
	});
}
