<script lang="ts">
	import { Bug, AlertTriangle, Lightbulb, LifeBuoy, BookOpen, Mail } from 'lucide-svelte';
	import GenericModal from '$lib/shared/components/layout/GenericModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { VERSION } from '$lib/version';
	import { createColorHelper, type Color } from '$lib/shared/utils/styling';
	import type { IconComponent } from '$lib/shared/utils/types';
	import { useOrganizationQuery } from '../organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';
	import { useCurrentUserQuery } from '$lib/features/auth/queries';
	import InfoCard from '$lib/shared/components/data/InfoCard.svelte';
	import InfoRow from '$lib/shared/components/data/InfoRow.svelte';

	type SupportOption = {
		title: string;
		description: string;
		url: string;
		color: Color;
		icon: IconComponent | string;
	};

	let {
		isOpen = false,
		onClose
	}: {
		isOpen: boolean;
		onClose: () => void;
	} = $props();

	// TanStack Query for current user and organization
	const currentUserQuery = useCurrentUserQuery();
	let currentUser = $derived(currentUserQuery.data);

	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let hasEmailSupport = $derived.by(() => {
		if (!organization || !organization.plan) return false;

		let features = billingPlans.getMetadata(organization.plan.type).features;
		return features.email_support;
	});

	let supportOptions = $derived.by(() => {
		const options: SupportOption[] = [
			{
				title: 'User Guide',
				description: 'Read the full documentation and guides',
				url: 'https://scanopy.net/docs/',
				color: 'Gray',
				icon: BookOpen
			},
			{
				title: 'Incorrect Service Detection',
				description: 'Report a service that was incorrectly identified',
				url: 'https://github.com/scanopy/scanopy/issues/new?template=service-detection-issue.md',
				color: 'Yellow',
				icon: AlertTriangle
			},
			{
				title: 'Request a Feature',
				description: 'Suggest a new feature or improvement',
				url: 'https://github.com/scanopy/scanopy/issues/new?template=feature_request.md',
				color: 'Green',
				icon: Lightbulb
			},
			{
				title: 'Report a Bug',
				description: 'Found an issue? Let us know so we can fix it',
				url: 'https://github.com/scanopy/scanopy/issues/new?template=bug_report.md',
				color: 'Red',
				icon: Bug
			},
			{
				title: 'Discord',
				description: 'Join our community for help and discussions',
				url: 'https://discord.gg/b7ffQr8AcZ',
				color: 'Indigo',
				icon: 'https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/discord.svg'
			}
		];

		if (hasEmailSupport) {
			options.push({
				title: 'Email',
				description: 'Email the Scanopy team directly',
				url: 'mailto:support@scanopy.net',
				color: 'Blue',
				icon: Mail
			});
		}

		return options;
	});

	function handleCardClick(url: string) {
		window.open(url, '_blank', 'noopener,noreferrer');
	}
</script>

<GenericModal {isOpen} title="Support & Help" {onClose} size="xl">
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={LifeBuoy} color="Blue" />
	</svelte:fragment>

	<div class="space-y-6">
		<p class="text-secondary text-sm">
			Need help with Scanopy? Choose one of the options below to get support.
		</p>

		<div class="grid grid-cols-2 gap-3">
			{#each supportOptions as option (option.description)}
				{@const colors = createColorHelper(option.color)}
				<button onclick={() => handleCardClick(option.url)} class="card w-full text-left">
					<div class="flex items-center gap-3">
						<div
							class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg {colors.bg}"
						>
							{#if typeof option.icon === 'string'}
								<img src={option.icon} alt={option.title} class="h-5 w-5" />
							{:else}
								<option.icon class="h-5 w-5 {colors.icon}" />
							{/if}
						</div>
						<div class="min-w-0 flex-1">
							<p class="text-primary text-sm font-medium">{option.title}</p>
							<p class="text-secondary truncate text-xs">{option.description}</p>
						</div>
					</div>
				</button>
			{/each}
		</div>
		<InfoCard title="Support Information">
			<InfoRow label="Version">{VERSION}</InfoRow>
			<InfoRow label="Organization ID" mono={true}>
				{organization?.id ?? '—'}
			</InfoRow>
			<InfoRow label="User ID" mono={true}>{currentUser?.id ?? '—'}</InfoRow>
		</InfoCard>
	</div>

	<svelte:fragment slot="footer">
		<div class="flex justify-end">
			<button type="button" onclick={onClose} class="btn-secondary">Close</button>
		</div>
	</svelte:fragment>
</GenericModal>
