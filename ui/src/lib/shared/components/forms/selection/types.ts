import type { Component } from 'svelte';
import type { TagProps } from '../../data/types';
import type { IconComponent } from '$lib/shared/utils/types';
import type { FormApi } from '../types';
// @typescript-eslint/no-explicit-any
export interface EntityDisplayComponent<T, C> {
	// Required methods
	getId(item: T): string;
	getLabel(item: T, context?: C): string;

	// Optional methods with defaults
	getDescription?(item: T, context: C): string;
	getIcon?(item: T, context: C): IconComponent | null;
	getIconColor?(item: T, context: C): string | null;
	getTags?(item: T, context: C): TagProps[];
	getIsDisabled?(item: T, context: C): boolean;
	getCategory?(item: T, context: C): string | null;

	// Optional inline editing support
	supportsInlineEdit?: boolean;
	renderInlineEdit?(
		item: T,
		onUpdate: (updates: Partial<T>) => void,
		formApi: FormApi,
		context?: C
	): {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		component: Component<any>;
		props: Record<string, unknown>;
	};
}
