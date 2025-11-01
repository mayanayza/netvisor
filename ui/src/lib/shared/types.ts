export interface GetAllEntitiesRequest {
	network_id: string;
}

export type EntitySource =
	| { type: 'Manual' }
	| { type: 'System' }
	| { type: 'Unknown' }
	| {
			type: 'Discovery';
			metadata: {
				discovery_type: DiscoveryType;
				daemon_id: string;
			}[];
	  }
	| {
			type: 'DiscoveryWithMatch';
			metadata: {
				discovery_type: DiscoveryType;
				daemon_id: string;
			}[];
			details: MatchDetails;
	  };

export type MatchReason =
	| { type: 'reason'; data: string }
	| { type: 'container'; data: [string, MatchReason[]] };

export interface MatchDetails {
	reason: MatchReason;
	confidence: 'NotApplicable' | 'Low' | 'Medium' | 'High' | 'Certain';
}

export function matchConfidenceColor(confidence: MatchDetails['confidence']): string {
	const confidenceColor: Record<MatchDetails['confidence'], string> = {
		NotApplicable: 'gray',
		Low: 'red',
		Medium: 'yellow',
		High: 'green',
		Certain: 'blue'
	};
	return confidenceColor[confidence];
}

export function matchConfidenceLabel(details: MatchDetails): string {
	const notApplicableReason =
		details.reason.type == 'container' ? details.reason.data[0] : 'Unknown Reason';

	const confidenceLabel: Record<MatchDetails['confidence'], string> = {
		NotApplicable: `N/A (${notApplicableReason})`,
		Low: 'Low Confidence',
		Medium: 'Medium Confidence',
		High: 'High Confidence',
		Certain: 'Certain'
	};
	return confidenceLabel[details.confidence];
}

export type DiscoveryType =
	| { type: 'SelfReport' }
	| { type: 'Network' }
	| { type: 'Docker'; host_id: string }
	| { type: 'Proxmox'; host_id: string };
