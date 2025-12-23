// Re-export generated types from backend
export type {
	EntitySource,
	DiscoveryMetadata,
	DiscoveryType,
	MatchDetails,
	MatchConfidence,
	HostNamingFallback
} from '$lib/generated';

import type { MatchConfidence, MatchDetails } from '$lib/generated';

// Frontend-specific types
export interface GetAllEntitiesRequest {
	network_id: string;
}

export function matchConfidenceColor(confidence: MatchConfidence): string {
	const confidenceColor: Record<MatchConfidence, string> = {
		Low: 'red',
		Medium: 'yellow',
		High: 'green'
	};
	return confidenceColor[confidence];
}

export function matchConfidenceLabel(confidence: MatchConfidence): string {
	const confidenceLabel: Record<MatchConfidence, string> = {
		Low: 'Low Confidence',
		Medium: 'Medium Confidence',
		High: 'High Confidence'
	};
	return confidenceLabel[confidence];
}

export function matchDetailsLabel(details: MatchDetails): string {
	return `${matchConfidenceLabel(details.confidence)} - ${details.pattern_name}`;
}
