import type { Topology } from '$lib/features/topology/types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export type ShareType = 'link' | 'embed';

export interface EmbedOptions {
	show_inspect_panel: boolean;
	show_zoom_controls: boolean;
}

export interface CreateUpdateShareRequest {
	share: Share;
	password?: string;
}

export interface Share {
	id: string;
	topology_id: string;
	network_id: string;
	created_by: string;
	share_type: ShareType;
	name: string;
	is_enabled: boolean;
	expires_at: string | null;
	allowed_domains: string[] | null;
	has_password: boolean;
	embed_options: EmbedOptions;
	created_at: string;
	updated_at: string;
}

export interface PublicShareMetadata {
	id: string;
	name: string;
	share_type: ShareType;
	requires_password: boolean;
	embed_options: EmbedOptions;
}

export interface ShareWithTopology {
	share: PublicShareMetadata;
	topology: Topology;
}

export const defaultEmbedOptions: EmbedOptions = {
	show_inspect_panel: true,
	show_zoom_controls: true
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
		share_type: 'link',
		has_password: false,
		name: '',
		is_enabled: true,
		embed_options: { ...defaultEmbedOptions }
	};
}
