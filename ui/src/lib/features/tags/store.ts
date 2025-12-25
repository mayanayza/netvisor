import { apiClient, type ApiResponse } from '$lib/api/client';
import { writable } from 'svelte/store';
import type { Tag } from './types/base';

export const tags = writable<Tag[]>([]);

export async function getTags() {
	const { data } = await apiClient.GET('/api/tags');
	if (data?.success && data.data) {
		tags.set(data.data);
	}
	return data as ApiResponse<Tag[]>;
}

export async function createTag(tag: Tag) {
	const { data: result } = await apiClient.POST('/api/tags', { body: tag });
	if (result?.success && result.data) {
		tags.update((current) => [...current, result.data!]);
	}
	return result as ApiResponse<Tag>;
}

export async function bulkDeleteTags(ids: string[]) {
	const { data: result } = await apiClient.POST('/api/tags/bulk-delete', {
		body: ids
	});
	if (result?.success) {
		tags.update((current) => current.filter((k) => !ids.includes(k.id)));
	}
	return result;
}

export async function updateTag(tag: Tag) {
	const { data: result } = await apiClient.PUT('/api/tags/{id}', {
		params: { path: { id: tag.id } },
		body: tag
	});
	if (result?.success && result.data) {
		tags.update((current) => current.map((s) => (s.id === tag.id ? result.data! : s)));
	}
	return result as ApiResponse<Tag>;
}

export async function deleteTag(tagId: string) {
	const { data: result } = await apiClient.DELETE('/api/tags/{id}', {
		params: { path: { id: tagId } }
	});
	if (result?.success) {
		tags.update((current) => current.filter((s) => s.id !== tagId));
	}
	return result;
}
