import type { Component } from 'svelte';
import type { TagProps } from '../../data/types';
import type { IconComponent } from '$lib/shared/utils/types';
import type { FormApi } from '../types';

export interface EntityDisplayComponent<T> {
	// Required methods
	getId(item: T): string;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getLabel(item: T, context?: Record<string, any>): string;

	// Optional methods with defaults
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getDescription?(item: T, context?: Record<string, any>): string;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getIcon?(item: T, context?: Record<string, any>): IconComponent | null;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getIconColor?(item: T, context?: Record<string, any>): string | null;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getTags?(item: T, context?: Record<string, any>): TagProps[];
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getIsDisabled?(item: T, context?: Record<string, any>): boolean;
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	getCategory?(item: T, context?: Record<string, any>): string | null;

	// Optional inline editing support
	supportsInlineEdit?: boolean;
	renderInlineEdit?(
		item: T,
		onUpdate: (updates: Partial<T>) => void,
		formApi: FormApi,
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		context?: Record<string, any>
	): {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		component: Component<any>;
		props: Record<string, unknown>;
	};
}

export interface DisplayComponentProps<T> {
	item: T;
}
