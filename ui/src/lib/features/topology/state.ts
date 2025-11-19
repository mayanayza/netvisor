import { Lock, RefreshCcw, AlertTriangle } from 'lucide-svelte';
import type { Topology } from './types/base';
import type { IconComponent } from '$lib/shared/utils/types';

export type TopologyStateType = 'locked' | 'fresh' | 'stale_safe' | 'stale_conflicts';

export interface TopologyStateConfig {
	type: TopologyStateType;
	icon: IconComponent;
	color: 'blue' | 'green' | 'yellow' | 'red';
	getLabel: (topology: Topology) => string;
	primaryAction: 'refresh' | 'unlock' | null;
	secondaryAction: 'lock' | null;
}

export function getTopologyState(topology: Topology): TopologyStateConfig {
	// Locked state
	if (topology.is_locked) {
		const lockedDate = topology.locked_at ? new Date(topology.locked_at).toLocaleDateString() : '';
		return {
			type: 'locked',
			icon: Lock,
			color: 'blue',
			getLabel: () => `Locked ${lockedDate}`.trim(),
			primaryAction: 'unlock',
			secondaryAction: null
		};
	}

	// Fresh state
	if (!topology.is_stale) {
		return {
			type: 'fresh',
			icon: RefreshCcw,
			color: 'green',
			getLabel: () => 'Up to date',
			primaryAction: null,
			secondaryAction: 'lock'
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
			icon: AlertTriangle,
			color: 'red',
			getLabel: () => 'Conflicts detected',
			primaryAction: 'refresh',
			secondaryAction: 'lock'
		};
	}

	// Stale without conflicts
	return {
		type: 'stale_safe',
		icon: RefreshCcw,
		color: 'yellow',
		getLabel: () => 'Refresh available',
		primaryAction: 'refresh',
		secondaryAction: 'lock'
	};
}
