import { writable, get } from 'svelte/store';
import type { UseCase, BlockerType, NetworkSetup } from '../types/base';

export interface DaemonSetupState {
	name: string;
	installNow: boolean;
	apiKey?: string;
}

export interface OnboardingState {
	useCase: UseCase | null;
	readyToScan: boolean | null;
	organizationName: string;
	networks: NetworkSetup[];
	daemonSetups: Map<string, DaemonSetupState>; // keyed by network id
	populateSeedData: boolean;
	currentBlocker: BlockerType | null;
}

const initialState: OnboardingState = {
	useCase: null,
	readyToScan: null,
	organizationName: '',
	networks: [{ name: '' }],
	daemonSetups: new Map(),
	populateSeedData: true,
	currentBlocker: null
};

function createOnboardingStore() {
	const { subscribe, update } = writable<OnboardingState>({ ...initialState });

	return {
		subscribe,
		// Reset clears most state but preserves useCase for billing page
		reset: () =>
			update((state) => ({
				...initialState,
				networks: [{ name: '' }],
				daemonSetups: new Map(),
				useCase: state.useCase // Preserve for billing page
			})),

		setUseCase: (useCase: UseCase) =>
			update((state) => ({
				...state,
				useCase
			})),

		setReadyToScan: (ready: boolean) =>
			update((state) => ({
				...state,
				readyToScan: ready
			})),

		setOrganizationName: (name: string) =>
			update((state) => ({
				...state,
				organizationName: name
			})),

		setNetworks: (networks: NetworkSetup[]) =>
			update((state) => ({
				...state,
				networks
			})),

		addNetwork: () =>
			update((state) => ({
				...state,
				networks: [...state.networks, { name: '' }]
			})),

		removeNetwork: (index: number) =>
			update((state) => ({
				...state,
				networks: state.networks.filter((_, i) => i !== index)
			})),

		updateNetworkName: (index: number, name: string) =>
			update((state) => ({
				...state,
				networks: state.networks.map((n, i) => (i === index ? { ...n, name } : n))
			})),

		setNetworkIds: (networkIds: string[]) =>
			update((state) => ({
				...state,
				networks: state.networks.map((n, i) => ({
					...n,
					id: networkIds[i]
				}))
			})),

		setPopulateSeedData: (populate: boolean) =>
			update((state) => ({
				...state,
				populateSeedData: populate
			})),

		setDaemonSetup: (networkId: string, setup: DaemonSetupState) =>
			update((state) => {
				const newDaemonSetups = new Map(state.daemonSetups);
				newDaemonSetups.set(networkId, setup);
				return {
					...state,
					daemonSetups: newDaemonSetups
				};
			}),

		clearDaemonSetup: (networkId: string) =>
			update((state) => {
				const newDaemonSetups = new Map(state.daemonSetups);
				newDaemonSetups.delete(networkId);
				return {
					...state,
					daemonSetups: newDaemonSetups
				};
			}),

		setCurrentBlocker: (blocker: BlockerType | null) =>
			update((state) => ({
				...state,
				currentBlocker: blocker
			})),

		// Get the current state synchronously
		getState: () => get({ subscribe })
	};
}

export const onboardingStore = createOnboardingStore();
