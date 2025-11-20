import type { Writable } from 'svelte/store';
import { pushError } from '../stores/feedback';
import { env } from '$env/dynamic/public';

export function getServerUrl() {
	// If API is on a different host/port, use explicit config
	if (env.PUBLIC_SERVER_HOSTNAME && env.PUBLIC_SERVER_HOSTNAME !== 'default') {
		const protocol = env.PUBLIC_SERVER_PROTOCOL || 'http';
		const port = env.PUBLIC_SERVER_PORT ? `:${env.PUBLIC_SERVER_PORT}` : '';
		return `${protocol}://${env.PUBLIC_SERVER_HOSTNAME}${port}`;
	}

	// Otherwise, use the exact same origin as the browser
	return window.location.origin;
}

interface ApiResponse<T> {
	success: boolean;
	data?: T;
	error?: string;
}

interface RequestCache {
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	promise: Promise<any>;
	timestamp: number;
	completed: boolean;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	result?: any;
}

class ApiClient {
	private requestCache = new Map<string, RequestCache>();
	private debounceMs: number = 250;

	private getRequestKey(endpoint: string, method: string, body?: string): string {
		// For GET requests, just use endpoint + method
		// For POST/PUT/DELETE, include body hash to allow different payloads
		if (method === 'GET') {
			return `${method}:${endpoint}`;
		}
		return `${method}:${endpoint}:${body || ''}`;
	}

	private cleanupExpiredRequests() {
		const now = Date.now();
		for (const [key, cache] of this.requestCache.entries()) {
			if (now - cache.timestamp > this.debounceMs) {
				this.requestCache.delete(key);
			}
		}
	}

	/**
	 * request<TResponseData, TStoreData>
	 * TResponseData: Type of data returned by the API
	 * TStoreData: Type of data stored in the Svelte store (can be different)
	 * @param endpoint - will be prefixd with {endpoint}/api
	 * @param dataStore - store that will be updated with the response data
	 * @param storeAction - function to update the store with new data. Takes response data and current store data (as defined in dataStore), returns updated store data
	 * @param options - fetch options like method, body, headers
	 * @returns
	 */
	async request<TResponseData, TStoreData = TResponseData>(
		endpoint: string,
		dataStore: Writable<TStoreData> | null,
		storeAction: ((data: TResponseData, current: TStoreData) => TStoreData) | null,
		options: RequestInit = {},
		silenceResponseLogs: boolean = false
	): Promise<ApiResponse<TResponseData> | null> {
		const method = options.method || 'GET';
		const body = options.body as string;
		const requestKey = this.getRequestKey(endpoint, method, body);

		// Clean up expired requests first
		this.cleanupExpiredRequests();

		// Check if we have a cached request within the debounce window
		const cached = this.requestCache.get(requestKey);
		if (cached) {
			const timeSinceRequest = Date.now() - cached.timestamp;
			if (timeSinceRequest < this.debounceMs) {
				if (cached.completed && cached.result) {
					// Return cached result immediately if request completed
					if (dataStore && storeAction && cached.result.success) {
						dataStore.update((current) => storeAction(cached.result.data!, current));
					}
					return cached.result;
				} else {
					// Return the pending promise
					return cached.promise;
				}
			}
		}

		const url = new URL(getServerUrl() + `/api${endpoint}`);

		const baseErrorMessage = `Failed to ${method} from ${endpoint}`;

		if (!url) {
			pushError('Invalid url');
			return null;
		}

		const requestPromise = this.executeRequest<TResponseData, TStoreData>(
			url,
			dataStore,
			storeAction,
			options,
			baseErrorMessage,
			silenceResponseLogs
		);

		// Cache the request
		const cacheEntry: RequestCache = {
			promise: requestPromise,
			timestamp: Date.now(),
			completed: false,
			result: undefined
		};

		this.requestCache.set(requestKey, cacheEntry);

		// Store the result when the request completes
		requestPromise
			.then((result) => {
				cacheEntry.completed = true;
				cacheEntry.result = result;
			})
			.catch(() => {
				cacheEntry.completed = true;
				cacheEntry.result = null;
			});

		return requestPromise;
	}

	private async executeRequest<TResponseData, TStoreData = TResponseData>(
		url: URL,
		dataStore: Writable<TStoreData> | null,
		storeAction: ((data: TResponseData, current: TStoreData) => TStoreData) | null,
		options: RequestInit,
		baseErrorMessage: string,
		silenceResponseLogs: boolean = false
	): Promise<ApiResponse<TResponseData> | null> {
		try {
			const response = await fetch(url, {
				headers: {
					'Content-Type': 'application/json',
					...options.headers
				},
				credentials: 'include',
				...options
			});

			if (!response.ok) {
				const errorData = await response.json().catch(() => ({
					success: false,
					error: `HTTP ${response.status}: ${response.statusText}`
				}));
				const errorMsg = errorData.error || `HTTP ${response.status}`;
				if (!silenceResponseLogs) pushError(errorMsg);
				return null;
			}

			const jsonResponse: ApiResponse<TResponseData> = await response.json();
			if (jsonResponse.success) {
				if (dataStore && storeAction) {
					dataStore.update((current) => storeAction(jsonResponse.data!, current));
				}
				return jsonResponse;
			} else if (jsonResponse?.error) {
				if (!silenceResponseLogs) pushError(`${baseErrorMessage}: ${jsonResponse.error}`);
				return null;
			} else {
				if (!silenceResponseLogs) pushError(`${baseErrorMessage}: Unknown error`);
				return null;
			}
		} catch (err) {
			if (!silenceResponseLogs) pushError(`${baseErrorMessage}: ${err}`);
			return null;
		}
	}

	// Allow configuration of debounce interval
	setDebounceInterval(ms: number) {
		this.debounceMs = ms;
	}

	// Method to clear cache manually if needed
	clearCache() {
		this.requestCache.clear();
	}
}

export const api = new ApiClient();
