import type { components } from '$lib/api/schema';
import type { IconComponent } from '$lib/shared/utils/types';
import {
	Building,
	CreditCard,
	MessageCircleQuestion,
	MonitorPlay,
	ServerOff,
	Settings,
	Shield,
	Signature,
	Telescope
} from 'lucide-svelte';

// Re-export generated types
export type LoginRequest = components['schemas']['LoginRequest'];
export type RegisterRequest = components['schemas']['RegisterRequest'];
export type SetupRequest = components['schemas']['SetupRequest'];
export type SetupResponse = components['schemas']['SetupResponse'];
export type DaemonSetupRequest = components['schemas']['DaemonSetupRequest'];
export type DaemonSetupResponse = components['schemas']['DaemonSetupResponse'];
export type ForgotPasswordRequest = components['schemas']['ForgotPasswordRequest'];
export type ResetPasswordRequest = components['schemas']['ResetPasswordRequest'];

// NetworkSetup extended with optional id (assigned after setup API returns network_ids)
export type NetworkSetup = components['schemas']['NetworkSetup'] & {
	id?: string;
};

// Frontend-only types (not in backend)
export interface SessionUser {
	user_id: string;
	name: string;
}

// Onboarding use case types
export type UseCase = 'homelab' | 'company' | 'msp';

export type BlockerType =
	| 'no_host'
	| 'compatibility'
	| 'security'
	| 'team_approval'
	| 'something_else'
	| 'exploring'
	| 'pricing'
	| 'demo' // Company/MSP only
	| 'not_ready_customers'; // MSP only

// Consolidated use case configuration
// Icons are mapped separately in components (Svelte component references)
export interface UseCaseConfig {
	label: string;
	description: string;
	orgLabel: string;
	orgPlaceholder: string;
	networkLabel: string;
	networkPlaceholder: string;
	colors: {
		ring: string;
		bg: string;
		text: string;
	};
}

export const USE_CASES: Record<UseCase, UseCaseConfig> = {
	homelab: {
		label: 'Homelab',
		description: 'Personal network at home',
		orgLabel: 'What should we call your setup?',
		orgPlaceholder: 'My Homelab',
		networkLabel: 'Network name',
		networkPlaceholder: 'Home Network',
		colors: {
			ring: 'ring-emerald-500',
			bg: 'bg-emerald-500/20',
			text: 'text-emerald-400'
		}
	},
	company: {
		label: 'Company',
		description: 'Internal business network',
		orgLabel: 'Organization name',
		orgPlaceholder: 'Acme Inc',
		networkLabel: 'Network / Location',
		networkPlaceholder: 'HQ, Branch Office',
		colors: {
			ring: 'ring-blue-500',
			bg: 'bg-blue-500/20',
			text: 'text-blue-400'
		}
	},
	msp: {
		label: 'MSP / IT Service Provider',
		description: 'Managing customer networks',
		orgLabel: 'Your company name',
		orgPlaceholder: 'Acme MSP',
		networkLabel: 'Customer network',
		networkPlaceholder: 'Customer - Location',
		colors: {
			ring: 'ring-violet-500',
			bg: 'bg-violet-500/20',
			text: 'text-violet-400'
		}
	}
};

// Consolidated blocker configuration
// Icons are mapped separately in components (Svelte component references)
export interface BlockerConfig {
	label: string;
	title: string;
	description: string;
	linkText?: string;
	linkUrl?: string;
	Icon: IconComponent;
}

export const BLOCKERS: Record<BlockerType, BlockerConfig> = {
	no_host: {
		label: "I don't have access to a host on the network I want to scan",
		title: 'No worries!',
		Icon: ServerOff,
		description:
			'Scanopy requires a host running Linux, macOS, or Windows to scan your network. Any device on your network works - a desktop, laptop, NAS, Raspberry Pi, or VM. The daemon is lightweight and runs in the background.'
	},
	compatibility: {
		label: "I'm not sure if my host is compatible with Scanopy's scanning tool",
		Icon: Settings,
		title: 'Check compatibility',
		description: "Let's verify your setup is compatible with Scanopy."
	},
	security: {
		label: 'I have security/compliance questions',
		title: 'Security information',
		Icon: Shield,
		description:
			'Scanopy is open source and designed with security in mind. Review our security documentation for details.',
		linkText: 'View security docs',
		linkUrl: 'https://github.com/scanopy/scanopy/blob/main/docs/SECURITY.md'
	},
	team_approval: {
		label: 'I need to get approval from my team',
		title: 'Take your time',
		Icon: Signature,
		description:
			"A free trial is available so your team can evaluate Scanopy, and we'll send you a link to schedule a demo/onboarding call for your team when you sign up for a trial. You can also invite team members to try it together once you're set up."
	},
	exploring: {
		label: "I'm just exploring",
		title: 'Explore freely',
		Icon: Telescope,
		description:
			"No problem! You can continue setup and install a daemon whenever you're ready. Or try it on your home network first - many users start there."
	},
	something_else: {
		label: 'Something else',
		title: 'I have a concern not addressed by this list',
		Icon: MessageCircleQuestion,
		description:
			"A free trial is available so you can explore Scanopy's features. Continue when you're ready to scan your network."
	},
	pricing: {
		label: 'I have questions about pricing',
		title: 'Pricing information',
		Icon: CreditCard,
		description: 'Review our pricing plans to find the right fit for your needs.',
		linkText: 'View pricing',
		linkUrl: 'https://scanopy.net/pricing'
	},
	demo: {
		label: 'I want to see a demo first',
		title: 'Schedule a demo',
		Icon: MonitorPlay,
		description:
			"We'd love to show you around! Schedule a call and we'll walk you through Scanopy's features and answer any questions.",
		linkText: 'Schedule a demo',
		linkUrl: 'https://cal.com/mferrandiz/scanopy-demo'
	},
	not_ready_customers: {
		label: "I'm not ready to deploy for my customers yet",
		title: 'Start with your own network',
		Icon: Building,
		description:
			'You can try Scanopy on your own infrastructure first to get familiar with the features. You can add customer networks later.'
	}
};

// Helper to get blocker options for a use case
export function getBlockerOptions(useCase: UseCase): BlockerType[] {
	const base: BlockerType[] = ['no_host', 'compatibility', 'exploring', 'pricing'];
	const business: BlockerType[] = ['security', 'team_approval', 'demo'];

	if (useCase === 'msp') {
		return [...base, 'not_ready_customers', ...business, 'something_else'];
	}

	if (useCase === 'company') {
		return [...base, ...business, 'something_else'];
	}

	// Homelab: no security/team_approval/demo options
	return [...base, 'something_else'];
}
