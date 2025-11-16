import { writable } from 'svelte/store';
import { pushError } from '../stores/feedback';

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export function loadData(loaders: (() => Promise<any>)[]) {
	const loading = writable(true); // Start as true immediately

	// Start loading
	(async () => {
		try {
			await Promise.all(loaders.map((loader) => loader()));
			loading.set(false);
		} catch (error) {
			pushError(`Data loading failed: ${error}`);
			loading.set(false);
		}
	})();

	return loading;
}
