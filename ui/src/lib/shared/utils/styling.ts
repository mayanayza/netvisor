import * as LucideIcons from 'lucide-svelte';
import type { IconComponent } from './types';
import colors from 'tailwindcss/colors';
import LogoIcon from '$lib/shared/components/data/LogoIcon.svelte';

export interface ColorStyle {
	text: string;
	bg: string;
	border: string;
	icon: string;
	ring: string;
	stroke: string;
	string: string;
	rgb: string; // Added RGB value
}

// Map backend color names to Tailwind classes with RGB values
export const COLOR_MAP: Record<string, ColorStyle> = {
	pink: {
		string: 'pink',
		text: 'text-pink-400',
		bg: 'bg-pink-900/50 border-pink-600',
		border: 'border-pink-600',
		icon: 'text-pink-400',
		ring: 'ring-pink-400',
		stroke: 'stroke-pink-400',
		rgb: 'rgb(244, 114, 182)' // pink-400
	},
	rose: {
		string: 'rose',
		text: 'text-rose-400',
		bg: 'bg-rose-900/50 border-rose-600',
		border: 'border-rose-600',
		icon: 'text-rose-400',
		ring: 'ring-rose-400',
		stroke: 'stroke-rose-400',
		rgb: 'rgb(251, 113, 133)' // rose-400
	},
	red: {
		string: 'red',
		text: 'text-red-400',
		bg: 'bg-red-900/50 border-red-600',
		border: 'border-red-600',
		icon: 'text-red-400',
		ring: 'ring-red-400',
		stroke: 'stroke-red-400',
		rgb: 'rgb(248, 113, 113)' // red-400
	},
	orange: {
		string: 'orange',
		text: 'text-orange-400',
		bg: 'bg-orange-900/50 border-orange-600',
		border: 'border-orange-600',
		icon: 'text-orange-400',
		ring: 'ring-orange-400',
		stroke: 'stroke-orange-400',
		rgb: 'rgb(251, 146, 60)' // orange-400
	},
	yellow: {
		string: 'yellow',
		text: 'text-yellow-400',
		bg: 'bg-yellow-900/50 border-yellow-600',
		border: 'border-yellow-600',
		icon: 'text-yellow-400',
		ring: 'ring-yellow-400',
		stroke: 'stroke-yellow-400',
		rgb: 'rgb(250, 204, 21)' // yellow-400
	},
	green: {
		string: 'green',
		text: 'text-green-400',
		bg: 'bg-green-900/50 border-green-600',
		border: 'border-green-600',
		icon: 'text-green-400',
		ring: 'ring-green-400',
		stroke: 'stroke-green-400',
		rgb: 'rgb(74, 222, 128)' // green-400
	},
	emerald: {
		string: 'emerald',
		text: 'text-emerald-400',
		bg: 'bg-emerald-900/50 border-emerald-600',
		border: 'border-emerald-600',
		icon: 'text-emerald-400',
		ring: 'ring-emerald-400',
		stroke: 'stroke-emerald-400',
		rgb: 'rgb(52, 211, 153)' // emerald-400
	},
	teal: {
		string: 'teal',
		text: 'text-teal-400',
		bg: 'bg-teal-900/50 border-teal-600',
		border: 'border-teal-600',
		icon: 'text-teal-400',
		ring: 'ring-teal-400',
		stroke: 'stroke-teal-400',
		rgb: 'rgb(45, 212, 191)' // teal-400
	},
	cyan: {
		string: 'cyan',
		text: 'text-cyan-400',
		bg: 'bg-cyan-900/50 border-cyan-600',
		border: 'border-cyan-600',
		icon: 'text-cyan-400',
		ring: 'ring-cyan-400',
		stroke: 'stroke-cyan-400',
		rgb: 'rgb(34, 211, 238)' // cyan-400
	},
	blue: {
		string: 'blue',
		text: 'text-blue-400',
		bg: 'bg-blue-900/50 border-blue-600',
		border: 'border-blue-600',
		icon: 'text-blue-400',
		ring: 'ring-blue-400',
		stroke: 'stroke-blue-400',
		rgb: 'rgb(96, 165, 250)' // blue-400
	},
	indigo: {
		string: 'indigo',
		text: 'text-indigo-400',
		bg: 'bg-indigo-900/50 border-indigo-600',
		border: 'border-indigo-600',
		icon: 'text-indigo-400',
		ring: 'ring-indigo-400',
		stroke: 'stroke-indigo-400',
		rgb: 'rgb(129, 140, 248)' // indigo-400
	},
	purple: {
		string: 'purple',
		text: 'text-purple-400',
		bg: 'bg-purple-900/50 border-purple-600',
		border: 'border-purple-600',
		icon: 'text-purple-400',
		ring: 'ring-purple-400',
		stroke: 'stroke-purple-400',
		rgb: 'rgb(196, 181, 253)' // purple-400
	},
	gray: {
		string: 'gray',
		text: 'text-gray-400',
		bg: 'bg-gray-900/50 border-gray-600',
		border: 'border-gray-600',
		icon: 'text-gray-400',
		ring: 'ring-gray-400',
		stroke: 'stroke-gray-400',
		rgb: 'rgb(156, 163, 175)' // gray-400
	}
};

// Export available colors array derived from COLOR_MAP keys
export const AVAILABLE_COLORS = Object.keys(COLOR_MAP) as Array<keyof typeof COLOR_MAP>;

export type AvailableColor = keyof typeof COLOR_MAP;

// Unified color helper - works everywhere!
export function createColorHelper(colorName: string | null): ColorStyle {
	const color = colorName && COLOR_MAP[colorName] ? colorName : 'gray';

	return COLOR_MAP[color];
}

// Icon helper that converts string to component
export function createIconComponent(iconName: string | null): IconComponent {
	if (!iconName || iconName == null) return LucideIcons.HelpCircle;

	// Convert kebab-case to PascalCase for Lucide component names
	const componentName = iconName
		.split('-')
		.map((word) => word.charAt(0).toUpperCase() + word.slice(1))
		.join('');

	// Return the component or fallback
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	return (LucideIcons as any)[componentName] || LucideIcons.HelpCircle;
}

// Icon helper that turns a string into an SVG
export function createLogoIconComponent(
	iconName: string | null,
	iconUrl: string,
	useWhiteBackground: boolean = false
): IconComponent {
	if (!iconName || iconName == null) return LucideIcons.HelpCircle;

	// Create a wrapper component that pre-binds the iconName
	// eslint-disable-next-line @typescript-eslint/no-explicit-any
	const BoundLogoIcon = ($$payload: any, $$props: Omit<any, 'iconName'>) => {
		return LogoIcon($$payload, { iconName, iconUrl, useWhiteBackground, ...$$props });
	};

	return BoundLogoIcon;
}

// Convenience wrapper that returns both color and icon
export function createStyle(color: string | null, icon: string | null) {
	return {
		colors: createColorHelper(color),
		IconComponent: createIconComponent(icon),
		iconName: icon
	};
}

/**
 * Converts a Tailwind color string (e.g. "text-blue-400", "bg-blue-900/50", "blue-500")
 * to an rgba() string with optional alpha override.
 */
export function twColorToRgba(twColor: string, alphaOverride?: number): string | null {
	const match = twColor.match(/([a-zA-Z]+)-(\d{2,3})(?:\/(\d{1,3}))?/);
	if (!match) return null;

	const [, colorName, shade, opacityRaw] = match;

	const palette = (colors as unknown as Record<string, Record<number, string>>)[colorName];
	if (!palette) return null;

	const hex = palette[parseInt(shade)];
	if (!hex) return null;

	const alpha =
		typeof alphaOverride === 'number'
			? alphaOverride
			: opacityRaw
				? parseInt(opacityRaw, 10) / 100
				: 1;

	return hexToRgba(hex, alpha);
}

function hexToRgba(hex: string, alpha = 1): string {
	const cleanHex = hex.replace('#', '');
	const bigint = parseInt(cleanHex, 16);
	const r = (bigint >> 16) & 255;
	const g = (bigint >> 8) & 255;
	const b = bigint & 255;
	return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}
