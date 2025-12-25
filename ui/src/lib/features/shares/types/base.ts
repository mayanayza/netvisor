// Re-export generated types from OpenAPI schema
import type { components } from '$lib/api/schema';
import type { Topology } from '$lib/features/topology/types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export type Share = components['schemas']['Share'];
export type ShareOptions = components['schemas']['ShareOptions'];
export type CreateUpdateShareRequest = components['schemas']['CreateUpdateShareRequest'];
export type PublicShareMetadata = components['schemas']['PublicShareMetadata'];

// Frontend-specific type: combines share metadata with topology data
export interface ShareWithTopology {
	share: PublicShareMetadata;
	topology: Topology;
}

export const defaultShareOptions: ShareOptions = {
	show_inspect_panel: true,
	show_zoom_controls: true,
	show_export_button: true
};

export function createEmptyShare(topology_id: string, network_id: string): Share {
	return {
		topology_id,
		network_id,
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		created_by: uuidv4Sentinel,
		expires_at: null,
		allowed_domains: null,
		name: '',
		is_enabled: true,
		options: { ...defaultShareOptions }
	};
}
