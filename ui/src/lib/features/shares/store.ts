import { writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type {
	Share,
	PublicShareMetadata,
	ShareWithTopology,
	CreateUpdateShareRequest
} from './types/base';

export const shares = writable<Share[]>([]);

// Authenticated API calls

export async function getShares(topologyId?: string) {
	const url = topologyId ? `/shares` : '/shares';
	return await api.request<Share[]>(url, shares, (data) => data, {
		method: 'GET'
	});
}

export async function createShare(request: CreateUpdateShareRequest) {
	const response = await api.request<Share, Share[]>(
		'/shares',
		shares,
		(newShare, current) => [...current, newShare],
		{ method: 'POST', body: JSON.stringify(request) }
	);

	return response;
}

export async function updateShare(id: string, request: CreateUpdateShareRequest) {
	const response = await api.request<Share, Share[]>(
		`/shares/${id}`,
		shares,
		(updatedShare, current) => current.map((s) => (s.id === id ? updatedShare : s)),
		{ method: 'PUT', body: JSON.stringify(request) }
	);

	return response;
}

export async function deleteShare(id: string) {
	const result = await api.request<void, Share[]>(
		`/shares/${id}`,
		shares,
		(_, current) => current.filter((s) => s.id !== id),
		{ method: 'DELETE' }
	);

	return result;
}

export async function bulkDeleteShares(ids: string[]) {
	const result = await api.request<void, Share[]>(
		'/shares/bulk-delete',
		shares,
		(_, current) => current.filter((s) => !ids.includes(s.id)),
		{ method: 'POST', body: JSON.stringify({ ids }) }
	);

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
): Promise<{ success: boolean; data?: ShareWithTopology; error?: string }> {
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

		return { success: true, data: result.data };
	} catch {
		return { success: false, error: 'Failed to verify password' };
	}
}

export async function getPublicShareTopology(
	shareId: string
): Promise<{ success: boolean; data?: ShareWithTopology; error?: string }> {
	try {
		const response = await fetch(`/api/shares/public/${shareId}/topology`, {
			method: 'GET',
			headers: {
				'Content-Type': 'application/json'
			}
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
