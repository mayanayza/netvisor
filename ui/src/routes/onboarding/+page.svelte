<!-- ui/src/routes/onboarding/+page.svelte -->
<script lang="ts">
	import Toast from '$lib/shared/components/feedback/Toast.svelte';
	import OnboardingModal from '$lib/features/auth/components/OnboardingModal.svelte';
	import GithubStars from '$lib/shared/components/data/GithubStars.svelte';
	import type { OnboardingRequest } from '$lib/features/auth/types/base';
	import { onboard } from '$lib/features/organizations/store';
	import { navigate } from '$lib/shared/utils/navigation';

	async function handleSubmit(formData: OnboardingRequest) {
		await onboard(formData);
		await navigate();
	}

	function handleClose() {
		// Don't allow closing during onboarding
	}
</script>

<div class="relative flex min-h-screen flex-col items-center bg-gray-900 p-4">
	<!-- Background image with overlay -->
	<div class="absolute inset-0 z-0">
		<div
			class="h-full w-full bg-cover bg-center bg-no-repeat"
			style="background-image: url('/images/diagram.png')"
		></div>
	</div>

	<!-- GitHub Stars Island - positioned absolutely at top -->
	<div class="absolute bottom-10 left-10 z-[100]">
		<div
			class="inline-flex items-center gap-2 rounded-2xl border border-gray-700 bg-gray-800/90 px-4 py-3 shadow-xl backdrop-blur-sm"
		>
			<span class="text-secondary text-sm">Open source on GitHub</span>
			<GithubStars />
		</div>
	</div>

	<!-- Spacer to push modal down -->
	<div class="flex flex-1 items-center justify-center">
		<!-- Modal Content -->
		<div class="relative z-10">
			<OnboardingModal isOpen={true} onClose={handleClose} onSubmit={handleSubmit} />
		</div>
	</div>

	<Toast />
</div>
