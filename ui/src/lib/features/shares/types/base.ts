import type { Topology } from '$lib/features/topology/types/base';
import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export interface ShareOptions {
	show_inspect_panel: boolean;
	show_zoom_controls: boolean;
	show_export_button: boolean;
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
	name: string;
	is_enabled: boolean;
	expires_at: string | null;
	allowed_domains: string[] | null;
	options: ShareOptions;
	created_at: string;
	updated_at: string;
}

export interface PublicShareMetadata {
	id: string;
	name: string;
	requires_password: boolean;
	options: ShareOptions;
}

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
