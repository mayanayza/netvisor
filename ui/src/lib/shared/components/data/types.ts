import type { IconComponent } from '$lib/shared/utils/types';
import type { Component } from 'svelte';

export interface TagProps {
	label: string;
	textColor?: string;
	bgColor?: string;
	color?: string;
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
	color?: string;
	disabled?: boolean;
	metadata?: Record<string, unknown>;
	badge?: string; // For things like "5m", "Critical", etc.
	badgeColor?: string;
}

export interface CardField {
	label: string;
	value: string | CardFieldItem[] | undefined | null;
	color?: string; // Used for tags when value is an array
	emptyText?: string; // Used when value is empty array
}

// Field configuration for data controls
export interface FieldConfig<T> {
	key: string;
	type: 'string' | 'boolean' | 'date';
	searchable?: boolean; // Whether this field should be included in text search
	filterable?: boolean; // Whether to show filter controls for this field
	sortable?: boolean; // Whether this field can be sorted
	getValue?: (item: T) => string | boolean | Date | null; // Custom getter function
	label: string;
}
