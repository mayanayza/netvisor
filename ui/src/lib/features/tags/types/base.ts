import { utcTimeZoneSentinel, uuidv4Sentinel } from '$lib/shared/utils/formatting';

export interface Tag {
	name: string;
	description: string | null;
	color: string;
	id: string;
	created_at: string;
	updated_at: string;
	organization_id: string;
}

export function createDefaultTag(organization_id: string): Tag {
	return {
		name: 'New Tag',
		description: null,
		color: 'yellow',
		id: uuidv4Sentinel,
		created_at: utcTimeZoneSentinel,
		updated_at: utcTimeZoneSentinel,
		organization_id
	};
}
