import { writable } from 'svelte/store';
import { api } from '../utils/api';

export const config = writable<PublicServerConfig>();

export interface PublicServerConfig {
	server_port: number;
	disable_registration: boolean;
	oidc_enabled: boolean;
	oidc_provider_name: string;
}

export async function getConfig() {
	await api.request<PublicServerConfig>('/config', config, (config) => config, {
		method: 'GET'
	});
}
