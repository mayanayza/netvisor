import { writable } from 'svelte/store';
import { pushError } from '../stores/feedback';

interface LoadDataOptions {
	/** Delay before showing loading state (ms). Set to 0 to show immediately. Default: 500 */
	loadingDelay?: number;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function loadData(loaders: (() => Promise<any>)[], options: LoadDataOptions = {}) {
	const { loadingDelay = 750 } = options;

	// If loadingDelay is 0, start with loading = true immediately
	const loading = writable(loadingDelay === 0);

	let loadingTimeout: ReturnType<typeof setTimeout> | null = null;

	// Only set timeout if delay > 0
	if (loadingDelay > 0) {
		loadingTimeout = setTimeout(() => {
			loading.set(true);
		}, loadingDelay);
	}

	// Start loading immediately
	(async () => {
		try {
			await Promise.all(loaders.map((loader) => loader()));
			if (loadingTimeout) clearTimeout(loadingTimeout);

			// Wait for next tick to ensure all store updates have propagated
			await new Promise((resolve) => setTimeout(resolve, 0));

			loading.set(false);
		} catch (error) {
			pushError(`Data loading failed: ${error}`);
			if (loadingTimeout) clearTimeout(loadingTimeout);
			loading.set(false);
		}
	})();

	return loading;
}
