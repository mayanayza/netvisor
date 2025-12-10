<script lang="ts">
	import { Bug, AlertTriangle, Lightbulb, LifeBuoy, BookOpen } from 'lucide-svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { VERSION } from '$lib/version';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';

	export let isOpen = false;
	export let onClose: () => void;

	function handleCardClick(url: string) {
		window.open(url, '_blank', 'noopener,noreferrer');
	}
</script>

<EditModal
	{isOpen}
	title="Support & Help"
	loading={false}
	showSave={false}
	showCancel={true}
	cancelLabel="Close"
	onCancel={onClose}
	size="md"
>
	<svelte:fragment slot="header-icon">
		<ModalHeaderIcon Icon={LifeBuoy} color="blue" />
	</svelte:fragment>

	<div class="space-y-6">
		<p class="text-secondary text-sm">
			Need help with NetVisor? Choose one of the options below to get support.
		</p>

		<div class="space-y-3">
			<!-- Documentation -->
			<button
				on:click={() => handleCardClick('https://github.com/netvisor-io/netvisor#readme')}
				class="card card-static card-focused w-full text-left"
			>
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-blue-500/10"
					>
						<BookOpen class="h-5 w-5 text-blue-500" />
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">Documentation</p>
						<p class="text-secondary text-xs">Read the full documentation and guides</p>
					</div>
				</div>
			</button>

			<!-- Incorrect Service Detection -->
			<button
				on:click={() =>
					handleCardClick(
						'https://github.com/netvisor-io/netvisor/issues/new?template=service-detection-issue.md'
					)}
				class="card card-static card-focused w-full text-left"
			>
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-yellow-500/10"
					>
						<AlertTriangle class="h-5 w-5 text-yellow-500" />
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">Incorrect Service Detection</p>
						<p class="text-secondary text-xs">Report a service that was incorrectly identified</p>
					</div>
				</div>
			</button>

			<!-- Request a Feature -->
			<button
				on:click={() =>
					handleCardClick(
						'https://github.com/netvisor-io/netvisor/issues/new?template=feature_request.md'
					)}
				class="card card-static card-focused w-full text-left"
			>
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-green-500/10"
					>
						<Lightbulb class="h-5 w-5 text-green-500" />
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">Request a Feature</p>
						<p class="text-secondary text-xs">Suggest a new feature or improvement</p>
					</div>
				</div>
			</button>

			<!-- Report a Bug -->
			<button
				on:click={() =>
					handleCardClick(
						'https://github.com/netvisor-io/netvisor/issues/new?template=bug_report.md'
					)}
				class="card card-static card-focused w-full text-left"
			>
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-red-500/10"
					>
						<Bug class="h-5 w-5 text-red-500" />
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">Report a Bug</p>
						<p class="text-secondary text-xs">Found an issue? Let us know so we can fix it</p>
					</div>
				</div>
			</button>

			<!-- Discord -->
			<button
				on:click={() => handleCardClick('https://discord.gg/b7ffQr8AcZ')}
				class="card card-static card-focused w-full text-left"
			>
				<div class="flex items-center gap-3">
					<div
						class="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-indigo-500/10"
					>
						<img
							src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/discord.svg"
							alt="Discord"
							class="h-5 w-5"
						/>
					</div>
					<div class="flex-1">
						<p class="text-primary text-sm font-medium">Discord</p>
						<p class="text-secondary text-xs">Join our community for help and discussions</p>
					</div>
				</div>
			</button>
		</div>

		<InlineInfo title={`NetVisor v${VERSION}`} />
	</div>
</EditModal>
