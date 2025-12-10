import { derived, get, writable, type Readable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { ApiKey } from './types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';
import { networks } from '../networks/store';

export const apiKeys = writable<ApiKey[]>([]);

export async function getApiKeys() {
	return await api.request<ApiKey[]>(`/auth/keys`, apiKeys, (apiKeys) => apiKeys, {
		method: 'GET'
	});
}

export async function deleteApiKey(id: string) {
	const result = await api.request<void, ApiKey[]>(
		`/auth/keys/${id}`,
		apiKeys,
		(_, current) => current.filter((k) => k.id !== id),
		{ method: 'DELETE' }
	);

	return result;
}

export async function bulkDeleteApiKeys(ids: string[]) {
	const result = await api.request<void, ApiKey[]>(
		`/auth/keys/bulk-delete`,
		apiKeys,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

export async function updateApiKey(apiKey: ApiKey) {
	const result = await api.request<ApiKey, ApiKey[]>(
		`/auth/keys/${apiKey.id}`,
		apiKeys,
		(updatedKey, current) => current.map((k) => (k.id == apiKey.id ? updatedKey : k)),
		{ method: 'PUT', body: JSON.stringify(apiKey) }
	);

	return result;
}

export async function rotateKey(key_id: string) {
	const response = await api.request<string, void>(`/auth/keys/${key_id}/rotate`, null, () => {}, {
		method: 'POST'
	});

	if (response && response?.success && response.data) {
		return response.data;
	}
}

export interface ApiKeyReponse {
	key: string;
	api_key: ApiKey;
}

export async function createNewApiKey(api_key: ApiKey) {
	const response = await api.request<ApiKeyReponse, ApiKey[]>(
		`/auth/keys`,
		apiKeys,
		(newKey, current) => [...current, newKey.api_key],
		{ method: 'POST', body: JSON.stringify(api_key) }
	);

	if (response && response?.success && response.data) {
		return response.data.key;
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
		network_id: get(networks)[0].id || '',
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
