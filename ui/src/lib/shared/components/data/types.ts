import type { IconComponent } from '$lib/shared/utils/types';
import type { Component, Snippet } from 'svelte';
import type { Color } from '$lib/shared/utils/styling';

export interface TagProps {
	label: string;
	textColor?: string;
	bgColor?: string;
	color?: Color;
}

export interface CardAction {
	label: string;
	icon: IconComponent; // Svelte component
	class?: string;
	onClick: () => void;
	disabled?: boolean;
	animation?: string;
}

export interface CardFieldItem {
	id: string;
	label: string;
	icon?: Component; // Svelte component instead of HTML
	iconColor?: string;
	bgColor?: string;
	color?: Color;
	disabled?: boolean;
	metadata?: Record<string, unknown>;
	badge?: string; // For things like "5m", "Critical", etc.
	badgeColor?: string;
}

export interface CardField {
	label: string;
	value?: string | CardFieldItem[] | undefined | null;
	snippet?: Snippet; // Allow snippet as an alternative to value
	color?: Color; // Used for tags when value is an array
	emptyText?: string; // Used when value is empty array
}

// Field configuration for data controls
export interface FieldConfig<T> {
	key: string;
	type: 'string' | 'boolean' | 'date' | 'array';
	searchable?: boolean;
	filterable?: boolean;
	sortable?: boolean;
	getValue?: (item: T) => string | boolean | Date | string[] | null;
	label: string;
}
