import { Lock, Radio, RefreshCcw } from 'lucide-svelte';
import type { Topology } from './types/base';
import type { IconComponent } from '$lib/shared/utils/types';
import type { Color } from '$lib/shared/utils/styling';

export type TopologyStateType = 'locked' | 'fresh' | 'stale_safe' | 'stale_conflicts';

export interface TopologyStateInfo {
	type: TopologyStateType;
	icon: IconComponent;
	hoverIcon?: IconComponent;
	color: Color;
	class: string;
	label: string;
	buttonText: string;
	disabled?: boolean;
}

export interface TopologyStateConfig extends TopologyStateInfo {
	action: (() => void) | null;
}

/**
 * Determine the state info for a topology (without actions)
 * This can be used in displays, lists, etc.
 */
export function getTopologyStateInfo(topology: Topology, autoRebuild: boolean): TopologyStateInfo {
	// Locked state
	if (topology.is_locked) {
		return {
			type: 'locked',
			icon: Lock,
			color: 'Blue',
			class: 'btn-info',
			buttonText: 'Locked',
			label: 'Locked',
			disabled: true
		};
	}

	// Auto rebuild state
	if (autoRebuild) {
		return {
			type: 'fresh',
			icon: Radio,
			color: 'Green',
			class: 'btn-success',
			buttonText: 'Auto',
			label: 'Auto',
			disabled: true
		};
	}

	// Fresh state
	if (!topology.is_stale) {
		return {
			type: 'fresh',
			icon: RefreshCcw,
			class: 'btn-secondary',
			color: 'Green',
			buttonText: 'Rebuild',
			label: 'Up to date'
		};
	}

	// Check for conflicts
	const hasConflicts =
		topology.removed_hosts.length > 0 ||
		topology.removed_services.length > 0 ||
		topology.removed_subnets.length > 0 ||
		topology.removed_groups.length > 0;

	// Stale with conflicts
	if (hasConflicts) {
		return {
			type: 'stale_conflicts',
			icon: RefreshCcw,
			color: 'Red',
			class: 'btn-danger',
			buttonText: 'Rebuild',
			label: 'Conflicts'
		};
	}

	// Stale without conflicts
	return {
		type: 'stale_safe',
		icon: RefreshCcw,
		color: 'Yellow',
		class: 'btn-warning',
		buttonText: 'Rebuild',
		label: 'Stale'
	};
}

/**
 * Get full topology state config with actions
 * This is used in the main topology page where actions are needed
 */
export function getTopologyState(
	topology: Topology,
	autoRebuild: boolean,
	handlers: {
		onRefresh: () => void;
		onReset: () => void;
	}
): TopologyStateConfig {
	const stateInfo = getTopologyStateInfo(topology, autoRebuild);

	// Map state types to actions
	const actionMap: Record<TopologyStateType, (() => void) | null> = {
		locked: null,
		fresh: handlers.onReset,
		stale_safe: handlers.onRefresh,
		stale_conflicts: handlers.onRefresh
	};

	return {
		...stateInfo,
		action: actionMap[stateInfo.type]
	};
}
