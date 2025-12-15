<script lang="ts">
	import { networks } from '$lib/features/networks/store';
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import EditModal from '$lib/shared/components/forms/EditModal.svelte';
	import ModalHeaderIcon from '$lib/shared/components/layout/ModalHeaderIcon.svelte';
	import { pushError } from '$lib/shared/stores/feedback';
	import { entities } from '$lib/shared/stores/metadata';
	import { writable, derived, type Writable } from 'svelte/store';
	import type { Daemon } from '../types/base';
	import SelectNetwork from '$lib/features/networks/components/SelectNetwork.svelte';
	import { ChevronDown, ChevronRight, RotateCcwKey, SatelliteDish } from 'lucide-svelte';
	import { createEmptyApiKeyFormData, createNewApiKey } from '$lib/features/api_keys/store';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { field } from 'svelte-forms';
	import { config } from '$lib/shared/stores/config';
	import InlineInfo from '$lib/shared/components/feedback/InlineInfo.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import type {
		TextFieldType,
		NumberFieldType,
		BooleanFieldType
	} from '$lib/shared/components/forms/types';
	import { fieldDefs } from '../config';

	export let isOpen = false;
	export let onClose: () => void;
	export let daemon: Daemon | null = null;

	// Onboarding mode props
	export let onboardingMode = false;
	export let onSkip: (() => void) | null = null;
	export let onContinue: (() => void) | null = null;
	export let provisionalApiKey: string | null = null;
	export let provisionalNetworkId: string | null = null;

	// Separate field defs
	const basicFieldDefs = fieldDefs.filter((d) => !d.section);
	const advancedFieldDefs = fieldDefs.filter((d) => d.section);

	// Get unique section names in order of appearance
	const sectionNames = [...new Set(advancedFieldDefs.map((d) => d.section!))];

	// Group advanced fields by section
	const advancedSections = sectionNames.map((name) => ({
		name,
		fields: advancedFieldDefs.filter((d) => d.section === name)
	}));

	// Track which sections are expanded
	let advancedExpanded = false;

	// Create form fields dynamically
	const formFields: Record<string, TextFieldType | NumberFieldType | BooleanFieldType> = {};
	for (const def of fieldDefs) {
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		const initial = daemon ? ((daemon as any)[def.id] ?? def.defaultValue) : def.defaultValue;
		formFields[def.id] = field(def.id, initial, def.validators, { checkOnInit: false });
	}

	// Derive combined values from all form fields
	const values = derived([...Object.values(formFields)], (stores) => {
		const result: Record<string, string | number | boolean> = {};

		fieldDefs.forEach((def, i) => {
			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			result[def.id] = (stores[i] as any).value;
		});

		return result;
	});

	// Derive validity from all form fields
	const valids = derived([...Object.values(formFields)], (stores) => {
		const result: Record<string, boolean> = {};

		fieldDefs.forEach((def, i) => {
			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			result[def.id] = (stores[i] as any).valid;
		});

		return result;
	});

	let keyStore: Writable<string | null> = writable(null);
	// In onboarding mode, use the provisionalApiKey; otherwise use keyStore
	$: key = onboardingMode ? provisionalApiKey : $keyStore;
	// In onboarding mode, use the provisionalNetworkId; otherwise use first network or daemon's network
	let selectedNetworkId = '';

	$: if (daemon) {
		selectedNetworkId = daemon.network_id;
	} else if (onboardingMode && provisionalNetworkId) {
		selectedNetworkId = provisionalNetworkId;
	} else if (!selectedNetworkId && $networks[0]?.id) {
		selectedNetworkId = $networks[0].id;
	}

	let isNewDaemon = daemon === null;

	let serverUrl = $config.public_url;

	function handleOnClose() {
		keyStore.set(null);
		onClose();
	}

	async function handleCreateNewApiKey() {
		let newApiKey = createEmptyApiKeyFormData();
		newApiKey.network_id = selectedNetworkId;
		newApiKey.name = `${$values['name'] as string} Api Key`;

		const generatedKey = await createNewApiKey(newApiKey);
		if (generatedKey) {
			keyStore.set(generatedKey);
		} else {
			pushError('Failed to generate API key');
		}
	}

	const installCommand = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;

	$: runCommand = buildRunCommand(serverUrl, selectedNetworkId, key, $values, daemon);
	$: dockerCompose = key
		? buildDockerCompose(serverUrl, selectedNetworkId, key, $values, $valids)
		: '';

	function buildRunCommand(
		serverUrl: string,
		networkId: string,
		key: string | null,
		values: Record<string, string | number | boolean>,
		daemon: Daemon | null
	): string {
		let cmd = `sudo scanopy-daemon --server-url ${serverUrl}`;

		if (!daemon && networkId) {
			cmd += ` --network-id ${networkId}`;
		}

		if (key) {
			cmd += ` --daemon-api-key ${key}`;
		}

		for (const def of fieldDefs) {
			const value = values[def.id];

			if (value === '' || value === null || value === undefined) {
				continue;
			}

			// Skip advanced fields (those with a section) that match their default value
			if (def.section && value === def.defaultValue) {
				continue;
			}

			if (def.id === 'mode') {
				cmd += ` ${def.cliFlag} ${String(value).toLowerCase()}`;
			} else if (def.type === 'boolean') {
				if (value) cmd += ` ${def.cliFlag} true`;
			} else {
				cmd += ` ${def.cliFlag} ${value}`;
			}
		}

		return cmd;
	}

	function buildDockerCompose(
		serverUrl: string,
		networkId: string,
		key: string,
		values: Record<string, string | number | boolean>,
		valids: Record<string, boolean>
	): string {
		const envVars: string[] = [`SCANOPY_SERVER_URL=${serverUrl}`, `SCANOPY_DAEMON_API_KEY=${key}`];

		if (networkId) {
			envVars.splice(1, 0, `SCANOPY_NETWORK_ID=${networkId}`);
		}

		for (const def of fieldDefs) {
			const value = values[def.id];
			const valid = valids[def.id];

			if (value === '' || value === null || value === undefined || !valid) {
				continue;
			}

			// Skip advanced fields (those with a section) that match their default value
			if (def.section && value === def.defaultValue) {
				continue;
			}

			if (def.type === 'boolean') {
				if (value) envVars.push(`${def.envVar}=true`);
			} else {
				envVars.push(`${def.envVar}=${value}`);
			}
		}

		const hasDockerProxy = values.dockerProxy && values.dockerProxy !== '' && valids.dockerProxy;
		const volumeMounts = ['daemon-config:/root/.config/daemon'];
		if (!hasDockerProxy) {
			volumeMounts.push('/var/run/docker.sock:/var/run/docker.sock:ro');
		}

		const lines = [
			'services:',
			'  daemon:',
			'    image: ghcr.io/scanopy/scanopy/daemon:latest',
			'    container_name: scanopy-daemon',
			'    network_mode: host',
			'    privileged: true',
			'    restart: unless-stopped',
			'    environment:',
			...envVars.map((v) => `      - ${v}`),
			'    volumes:',
			...volumeMounts.map((v) => `      - ${v}`),
			'',
			'volumes:',
			'  daemon-config:'
		];

		return lines.join('\n');
	}

	let colorHelper = entities.getColorHelper('Daemon');
</script>

<EditModal
	{isOpen}
	title={onboardingMode ? 'Set up network scanning' : 'Create Daemon'}
	cancelLabel={onboardingMode ? 'Continue' : 'Close'}
	onCancel={onboardingMode && onContinue ? onContinue : handleOnClose}
	showSave={false}
	showBackdrop={onboardingMode}
	size="xl"
	let:formApi
>
	<svelte:fragment slot="header-icon">
		{#if onboardingMode}
			<ModalHeaderIcon Icon={SatelliteDish} color="#10b981" />
		{:else}
			<ModalHeaderIcon Icon={entities.getIconComponent('Daemon')} color={colorHelper.string} />
		{/if}
	</svelte:fragment>

	<div class="space-y-4">
		{#if onboardingMode}
			<!-- Onboarding mode: show info banner -->
			<InlineInfo
				title="Your daemon will activate after account creation"
				body="To visualize your network, Scanopy needs to discover what's on it. Install the daemon below—after registration, it'll connect and start mapping automatically."
			/>
		{:else if !daemon}
			<SelectNetwork bind:selectedNetworkId />
		{/if}

		<!-- Basic Fields -->
		{#each basicFieldDefs as def (def.id)}
			{#if def.type === 'string'}
				<TextInput
					label={def.label}
					id={def.id}
					{formApi}
					field={formFields[def.id] as TextFieldType}
					placeholder={(def.placeholder as string) ?? ''}
					helpText={def.helpText}
					required={def.required}
				/>
			{:else if def.type === 'select'}
				<SelectInput
					label={def.label}
					id={def.id}
					{formApi}
					field={formFields[def.id] as TextFieldType}
					options={def.options ?? []}
					helpText={def.helpText}
					disabled={def.disabled?.(isNewDaemon) ?? false}
				/>
			{/if}
		{/each}

		<!-- API Key Section (hidden in onboarding mode) -->
		{#if !onboardingMode}
			<div class="pb-2">
				<div class="flex items-start gap-2">
					<button
						class="btn-primary m-1 flex-shrink-0 self-stretch"
						disabled={!!key}
						type="button"
						on:click={handleCreateNewApiKey}
					>
						<RotateCcwKey />
						<span>Generate Key</span>
					</button>

					<div class="flex-1">
						<CodeContainer
							language="bash"
							expandable={false}
							code={key ? key : 'Press Generate Key...'}
						/>
					</div>
				</div>
				{#if !key}
					<div class="text-tertiary mt-1 text-xs">
						This will create a new API key, which you can manage later in the API Keys tab.
					</div>
				{/if}
			</div>
		{/if}

		<!-- Advanced Configuration -->
		<div class="border-tertiary border-t pt-4">
			<button
				type="button"
				class="text-secondary hover:text-primary flex w-full items-center gap-2 text-sm font-medium"
				on:click={() => (advancedExpanded = !advancedExpanded)}
			>
				{#if advancedExpanded}
					<ChevronDown class="h-4 w-4" />
				{:else}
					<ChevronRight class="h-4 w-4" />
				{/if}
				Advanced Configuration
			</button>

			{#if advancedExpanded}
				<div class="mt-4 space-y-6">
					{#each advancedSections as section (section.name)}
						<div class="card card-static">
							<div class="text-secondary text-m mb-3 font-medium">{section.name}</div>
							<div class="grid grid-cols-2 gap-4">
								{#each section.fields as def (def.id)}
									{#if def.type === 'string'}
										<TextInput
											label={def.label}
											id={def.id}
											{formApi}
											field={formFields[def.id] as TextFieldType}
											placeholder={(def.placeholder as string) ?? ''}
											helpText={def.helpText}
										/>
									{:else if def.type === 'number'}
										<TextInput
											label={def.label}
											id={def.id}
											{formApi}
											field={formFields[def.id] as NumberFieldType}
											type="number"
											placeholder={(def.placeholder as string) ?? ''}
											helpText={def.helpText}
										/>
									{:else if def.type === 'select'}
										<SelectInput
											label={def.label}
											id={def.id}
											{formApi}
											field={formFields[def.id] as TextFieldType}
											options={def.options ?? []}
											helpText={def.helpText}
										/>
									{:else if def.type === 'boolean'}
										<div class="flex items-center pb-2">
											<Checkbox
												field={formFields[def.id] as BooleanFieldType}
												id={def.id}
												{formApi}
												label={def.label}
												helpText={def.helpText}
											/>
										</div>
									{/if}
								{/each}
							</div>
						</div>
					{/each}
				</div>
			{/if}
		</div>

		{#if !daemon && key}
			<div class="text-secondary mt-3">
				<b>Option 1.</b> Run the install script, then start the daemon
			</div>

			<CodeContainer language="bash" expandable={false} code={installCommand} />
			<CodeContainer language="bash" expandable={false} code={runCommand} />

			<div class="text-secondary mt-3"><b>Option 2.</b> Run this docker-compose</div>
			<CodeContainer language="yaml" expandable={false} code={dockerCompose} />
		{:else if daemon && key && selectedNetworkId}
			<InlineWarning
				title="This API key will not be available once you close this modal. Please use the provided run command or update your docker compose with the API key as depicted below."
			/>

			<div class="text-secondary mt-3">
				<b>Option 1.</b> Stop the daemon process, and use this command to start it
			</div>
			<CodeContainer language="bash" expandable={false} code={runCommand} />
			<div class="text-secondary mt-3">
				<b>Option 2.</b> Stop the daemon container, and add this environment variable
			</div>
			<CodeContainer
				language="bash"
				expandable={false}
				code={`- SCANOPY_DAEMON_API_KEY=${key}\n`}
			/>
		{/if}
	</div>

	<!-- Custom footer for onboarding mode -->
	<svelte:fragment slot="footer">
		{#if onboardingMode}
			<div class="flex w-full items-center justify-between gap-4">
				{#if onSkip}
					<button type="button" class="btn-secondary" on:click={onSkip}>
						I'll do this later
					</button>
				{/if}
				<button type="button" class="btn-primary ml-auto" on:click={onContinue ?? handleOnClose}>
					Continue
				</button>
			</div>
		{/if}
	</svelte:fragment>
</EditModal>
