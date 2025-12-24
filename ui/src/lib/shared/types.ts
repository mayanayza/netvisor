// Re-export generated types from backend
export type {
	EntitySource,
	DiscoveryMetadata,
	DiscoveryType,
	MatchDetails,
	MatchConfidence,
	MatchReason,
	HostNamingFallback
} from '$lib/generated';

import type { MatchConfidence, MatchDetails, MatchReason } from '$lib/generated';

// Frontend-specific types
export interface GetAllEntitiesRequest {
	network_id: string;
}

export function matchConfidenceColor(confidence: MatchConfidence): string {
	const confidenceColor: Record<MatchConfidence, string> = {
		NotApplicable: 'gray',
		Low: 'red',
		Medium: 'yellow',
		High: 'green',
		Certain: 'green'
	};
	return confidenceColor[confidence];
}

export function matchConfidenceLabel(confidence: MatchConfidence): string {
	const confidenceLabel: Record<MatchConfidence, string> = {
		NotApplicable: 'Not Applicable',
		Low: 'Low Confidence',
		Medium: 'Medium Confidence',
		High: 'High Confidence',
		Certain: 'Certain'
	};
	return confidenceLabel[confidence];
}

/** Get a display string for a MatchReason */
export function matchReasonLabel(reason: MatchReason): string {
	if (reason.type === 'reason') {
		return reason.data;
	} else {
		// Container type: [name, children]
		return reason.data[0];
	}
}

export function matchDetailsLabel(details: MatchDetails): string {
	return `${matchConfidenceLabel(details.confidence)} - ${matchReasonLabel(details.reason)}`;
}
