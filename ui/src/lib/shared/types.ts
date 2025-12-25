import type { components } from '$lib/api/schema';

// Re-export generated types
export type EntitySource = components['schemas']['EntitySource'];
export type DiscoveryMetadata = components['schemas']['DiscoveryMetadata'];
export type DiscoveryType = components['schemas']['DiscoveryType'];
export type MatchDetails = components['schemas']['MatchDetails'];
export type MatchConfidence = components['schemas']['MatchConfidence'];
export type MatchReason = components['schemas']['MatchReason'];
export type HostNamingFallback = components['schemas']['HostNamingFallback'];

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
		// Container type: [name, children] - data is typed as unknown[] in schema
		return reason.data[0] as string;
	}
}

export function matchDetailsLabel(details: MatchDetails): string {
	return `${matchConfidenceLabel(details.confidence)} - ${matchReasonLabel(details.reason)}`;
}
