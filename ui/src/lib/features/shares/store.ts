import { writable } from 'svelte/store';
import { apiClient, type ApiResponse } from '$lib/api/client';
import type {
	Share,
	PublicShareMetadata,
	ShareWithTopology,
	CreateUpdateShareRequest
} from './types/base';

export const shares = writable<Share[]>([]);

// Authenticated API calls

export async function getShares() {
	const { data } = await apiClient.GET('/api/shares');
	if (data?.success && data.data) {
		shares.set(data.data);
	}
	return data as ApiResponse<Share[]>;
}

export async function createShare(request: CreateUpdateShareRequest) {
	const { data: result } = await apiClient.POST('/api/shares', { body: request });
	if (result?.success && result.data) {
		shares.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Share>;
}

export async function updateShare(id: string, request: CreateUpdateShareRequest) {
	const { data: result } = await apiClient.PUT('/api/shares/{id}', {
		params: { path: { id } },
		body: request
	});
	if (result?.success && result.data) {
		shares.update((current) => current.map((s) => (s.id === id ? result.data! : s)));
	}
	return result as ApiResponse<Share>;
}

export async function deleteShare(id: string) {
	const { data: result } = await apiClient.DELETE('/api/shares/{id}', {
		params: { path: { id } }
	});
	if (result?.success) {
		shares.update((current) => current.filter((s) => s.id !== id));
	}
	return result;
}

export async function bulkDeleteShares(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/shares/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		shares.update((current) => current.filter((s) => !ids.includes(s.id)));
	}
	return result;
}

// Public API calls (no auth required)

export async function getPublicShareMetadata(
	shareId: string
): Promise<{ success: boolean; data?: PublicShareMetadata; error?: string }> {
	try {
		const response = await fetch(`/api/shares/public/${shareId}`, {
			method: 'GET',
			headers: {
				'Content-Type': 'application/json'
			}
		});

		const result = await response.json();

		if (!response.ok || result.error) {
			return { success: false, error: result.error || 'Failed to fetch share' };
		}

		return { success: true, data: result.data };
	} catch {
		return { success: false, error: 'Failed to fetch share' };
	}
}

export async function verifySharePassword(
	shareId: string,
	password: string
): Promise<{ success: boolean; error?: string }> {
	try {
		const response = await fetch(`/api/shares/public/${shareId}/verify`, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify(password)
		});

		const result = await response.json();

		if (!response.ok || result.error) {
			return { success: false, error: result.error || 'Invalid password' };
		}

		return { success: true };
	} catch {
		return { success: false, error: 'Failed to verify password' };
	}
}

export async function getPublicShareTopology(
	shareId: string,
	options: { embed?: boolean; password?: string } = {}
): Promise<{ success: boolean; data?: ShareWithTopology; error?: string }> {
	try {
		const url = options.embed
			? `/api/shares/public/${shareId}/topology?embed=true`
			: `/api/shares/public/${shareId}/topology`;
		const response = await fetch(url, {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json'
			},
			body: JSON.stringify({ password: options.password })
		});

		const result = await response.json();

		if (!response.ok || result.error) {
			return { success: false, error: result.error || 'Failed to fetch topology' };
		}

		return { success: true, data: result.data };
	} catch {
		return { success: false, error: 'Failed to fetch topology' };
	}
}

export function generateShareUrl(shareId: string): string {
	if (typeof window !== 'undefined') {
		return `${window.location.origin}/share/${shareId}`;
	}
	return `/share/${shareId}`;
}

export function generateEmbedUrl(shareId: string): string {
	if (typeof window !== 'undefined') {
		return `${window.location.origin}/share/${shareId}/embed`;
	}
	return `/share/${shareId}/embed`;
}

export function generateEmbedCode(shareId: string, width = 800, height = 600): string {
	const url = generateEmbedUrl(shareId);
	return `<iframe src="${url}" width="${width}" height="${height}" frameborder="0"></iframe>`;
}

// Session storage helpers for password persistence
const SHARE_PASSWORD_PREFIX = 'share_password_';

export function getStoredSharePassword(shareId: string): string | null {
	if (typeof sessionStorage === 'undefined') return null;
	return sessionStorage.getItem(`${SHARE_PASSWORD_PREFIX}${shareId}`);
}

export function storeSharePassword(shareId: string, password: string): void {
	if (typeof sessionStorage === 'undefined') return;
	sessionStorage.setItem(`${SHARE_PASSWORD_PREFIX}${shareId}`, password);
}

export function clearStoredSharePassword(shareId: string): void {
	if (typeof sessionStorage === 'undefined') return;
	sessionStorage.removeItem(`${SHARE_PASSWORD_PREFIX}${shareId}`);
}
