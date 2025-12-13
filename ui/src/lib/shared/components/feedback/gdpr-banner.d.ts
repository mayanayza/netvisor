declare module '@beyonk/gdpr-cookie-consent-banner' {
	import type { SvelteComponent } from 'svelte';

	interface GdprBannerProps {
		cookieName?: string;
		description?: string;
		heading?: string;
		acceptAllLabel?: string;
		acceptSelectedLabel?: string;
		rejectLabel?: string;
		settingsLabel?: string;
		closeLabel?: string;
		editLabel?: string;
		canRejectCookies?: boolean;
		showEditIcon?: boolean;
		visible?: boolean;
		choices?: Record<string, boolean | { label: string; description: string; value: boolean }>;
		cookieConfig?: Record<string, unknown>;
	}

	interface GdprBannerEvents {
		analytics: CustomEvent<{ agreed: boolean }>;
		marketing: CustomEvent<{ agreed: boolean }>;
		tracking: CustomEvent<{ agreed: boolean }>;
		necessary: CustomEvent<{ agreed: boolean }>;
		all: CustomEvent<{ agreed: boolean }>;
	}

	export default class GdprBanner extends SvelteComponent<GdprBannerProps, GdprBannerEvents> {}
}
