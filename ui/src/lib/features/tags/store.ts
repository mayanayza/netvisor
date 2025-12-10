import { api } from '$lib/shared/utils/api';
import { writable } from 'svelte/store';
import type { Tag } from './types/base';

export const tags = writable<Tag[]>([]);

export async function getTags() {
	return await api.request<Tag[]>(`/tags`, tags, (tags) => tags, { method: 'GET' });
}

export async function createTag(tag: Tag) {
	const result = await api.request<Tag, Tag[]>(
		'/tags',
		tags,
		(response, currentTags) => [...currentTags, response],
		{
			method: 'POST',
			body: JSON.stringify(tag)
		}
	);

	return result;
}

export async function bulkDeleteTags(ids: string[]) {
	const result = await api.request<void, Tag[]>(
		`/tags/bulk-delete`,
		tags,
		(_, current) => current.filter((k) => !ids.includes(k.id)),
		{ method: 'POST', body: JSON.stringify(ids) }
	);

	return result;
}

export async function updateTag(tag: Tag) {
	const result = await api.request<Tag, Tag[]>(
		`/tags/${tag.id}`,
		tags,
		(response, currentTags) => currentTags.map((s) => (s.id === tag.id ? response : s)),
		{
			method: 'PUT',
			body: JSON.stringify(tag)
		}
	);

	return result;
}

export async function deleteTag(tagId: string) {
	const result = await api.request<void, Tag[]>(
		`/tags/${tagId}`,
		tags,
		(_, currentTags) => currentTags.filter((s) => s.id !== tagId),
		{ method: 'DELETE' }
	);

	return result;
}
