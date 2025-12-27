/**
 * Typed API client using openapi-fetch
 *
 * This client provides type-safe API calls based on the OpenAPI spec.
 * It includes middleware for request caching, error handling, and credentials.
 */

import createClient, { type Middleware } from 'openapi-fetch';
import type { paths, components } from './schema';
import { pushError } from '$lib/shared/stores/feedback';
import { env } from '$env/dynamic/public';

// Re-export schema types for convenience
export type { paths, components };

// Common type aliases
export type ApiResponse<T> = {
	success: boolean;
	data: T | null;
	error: string | null;
};

/**
 * Get the server URL based on environment configuration
 */
export function getServerUrl(): string {
	// If API is on a different host/port, use explicit config
	if (env.PUBLIC_SERVER_HOSTNAME && env.PUBLIC_SERVER_HOSTNAME !== 'default') {
		const protocol = env.PUBLIC_SERVER_PROTOCOL || 'http';
		const port = env.PUBLIC_SERVER_PORT ? `:${env.PUBLIC_SERVER_PORT}` : '';
		return `${protocol}://${env.PUBLIC_SERVER_HOSTNAME}${port}`;
	}

	// Otherwise, use the exact same origin as the browser
	if (typeof window !== 'undefined') {
		return window.location.origin;
	}

	// SSR fallback
	return '';
}

// Request cache for debouncing duplicate requests
interface CacheEntry {
	promise: Promise<Response>;
	timestamp: number;
	completed: boolean;
	result?: Response;
}

const requestCache = new Map<string, CacheEntry>();
const DEBOUNCE_MS = 250;

function getRequestKey(request: Request): string {
	const method = request.method;
	const url = request.url;
	// For GET requests, just use method + url
	// For mutations, we don't cache (each should execute)
	if (method === 'GET') {
		return `${method}:${url}`;
	}
	return ''; // Don't cache mutations
}

function cleanupExpiredRequests() {
	const now = Date.now();
	for (const [key, cache] of requestCache.entries()) {
		if (now - cache.timestamp > DEBOUNCE_MS) {
			requestCache.delete(key);
		}
	}
}

/**
 * Caching middleware - debounces identical GET requests within 250ms
 */
const cachingMiddleware: Middleware = {
	async onRequest({ request }) {
		cleanupExpiredRequests();

		const cacheKey = getRequestKey(request);
		if (!cacheKey) return undefined; // Don't cache mutations

		const cached = requestCache.get(cacheKey);
		if (cached) {
			const timeSinceRequest = Date.now() - cached.timestamp;
			if (timeSinceRequest < DEBOUNCE_MS) {
				if (cached.completed && cached.result) {
					// Return cached response (clone to allow re-reading body)
					return cached.result.clone();
				}
				// Request is still in progress, wait for it
				const result = await cached.promise;
				return result.clone();
			}
		}

		return undefined;
	},
	async onResponse({ request, response }) {
		const cacheKey = getRequestKey(request);
		if (!cacheKey) return response;

		// Store in cache
		const entry = requestCache.get(cacheKey);
		if (entry) {
			entry.completed = true;
			entry.result = response.clone();
		}

		return response;
	}
};

/**
 * Error handling middleware - shows toast notifications on errors
 */
const errorMiddleware: Middleware = {
	async onResponse({ response, options }) {
		if (!response.ok) {
			// Don't show error toasts for 401 (expected when not logged in)
			if (response.status === 401) {
				return response;
			}
			try {
				const errorData = await response.clone().json();
				const errorMsg = errorData.error || `HTTP ${response.status}: ${response.statusText}`;
				// Only show error if not silenced
				if (!(options as { silenceErrors?: boolean }).silenceErrors) {
					pushError(errorMsg);
				}
			} catch {
				if (!(options as { silenceErrors?: boolean }).silenceErrors) {
					pushError(`HTTP ${response.status}: ${response.statusText}`);
				}
			}
		}
		return response;
	}
};

/**
 * Create the typed API client
 *
 * Note: baseUrl does NOT include '/api' because the OpenAPI schema paths
 * already include the '/api' prefix (e.g., '/api/hosts', '/api/networks').
 */
export const apiClient = createClient<paths>({
	baseUrl: getServerUrl(),
	credentials: 'include',
	headers: {
		'Content-Type': 'application/json'
	}
});

// Add middleware (order matters - logging first, then caching, then error handling)
apiClient.use(cachingMiddleware);
apiClient.use(errorMiddleware);

export default apiClient;
