import { writable } from 'svelte/store';
import { pushError } from '../stores/feedback';

interface LoadDataOptions {
	/** Delay before showing loading state (ms). Set to 0 to show immediately. Default: 500 */
	loadingDelay?: number;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function loadData(loaders: (() => Promise<any>)[], options: LoadDataOptions = {}) {
	const { loadingDelay = 500 } = options;

	const loading = writable(false);

	const loadingTimeout = setTimeout(() => {
		loading.set(true);
	}, loadingDelay);

	// Start loading immediately
	(async () => {
		try {
			await Promise.all(loaders.map((loader) => loader()));
			clearTimeout(loadingTimeout);
			loading.set(false);
		} catch (error) {
			pushError(`Data loading failed: ${error}`);
			clearTimeout(loadingTimeout);
			loading.set(false);
		}
	})();

	return loading;
}
