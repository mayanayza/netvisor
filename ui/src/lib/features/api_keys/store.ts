import { derived, get, writable, type Readable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type { ApiKey } from './types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { networks } from '../networks/store';

export const apiKeys = writable<ApiKey[]>([]);

export async function getApiKeys() {
	const { data } = await apiClient.GET('/api/auth/keys');
	if (data?.success && data.data) {
		apiKeys.set(data.data);
	}
	return data as ApiResponse<ApiKey[]>;
}

export async function deleteApiKey(id: string) {
	const { data: result } = await apiClient.DELETE('/api/auth/keys/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		apiKeys.update((current) => current.filter((k) => k.id !== id));
	}
	return result;
}

export async function bulkDeleteApiKeys(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/auth/keys/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		apiKeys.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export async function updateApiKey(apiKey: ApiKey) {
	const { data: result } = await apiClient.PUT('/api/auth/keys/{id}', {
		params: { path: { id: apiKey.id } },
		body: apiKey
	});
	if (result?.success && result.data) {
		apiKeys.update((current) => current.map((k) => (k.id == apiKey.id ? result.data! : k)));
	}
	return result as ApiResponse<ApiKey>;
}

export async function rotateKey(key_id: string) {
	const { data: result } = await apiClient.POST('/api/auth/keys/{id}/rotate', {
		params: { path: { id: key_id } }
	});
	if (result?.success && result.data) {
		return result.data;
	}
}

export interface ApiKeyReponse {
	key: string;
	api_key: ApiKey;
}

export async function createNewApiKey(api_key: ApiKey) {
	const { data: result } = await apiClient.POST('/api/auth/keys', { body: api_key });
	if (result?.success && result.data) {
		apiKeys.update((current) => [...current, result.data!.api_key]);
		return result.data.key;
	}
}

export function createEmptyApiKeyFormData(): ApiKey {
	return {
		id: uuidv4Sentinel,
		name: 'My Api Key',
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		expires_at: null,
		last_used: null,
		network_id: get(networks)[0]?.id || '',
		key: '',
		is_enabled: true,
		tags: []
	};
}

export function getKeyById(id: string): Readable<ApiKey | null> {
	return derived([apiKeys], ([$apiKeys]) => {
		return $apiKeys.find((k) => k.id == id) || null;
	});
}
