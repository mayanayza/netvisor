import { writable } from 'svelte/store';
import { api } from '../../shared/utils/api';
import type { Organization } from './types';

export const organization = writable<Organization | null>();

export async function getOrganization(organization_id: string): Promise<Organization | null> {
	const result = await api.request<Organization | null>(
		`/organizations/${organization_id}`,
		organization,
		(organization) => organization,
		{
			method: 'GET'
		}
	);

	if (result && result.success && result.data) {
		return result.data;
	}
	return null;
}
