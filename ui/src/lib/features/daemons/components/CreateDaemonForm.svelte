<script lang="ts">
	import CodeContainer from '$lib/shared/components/data/CodeContainer.svelte';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { field } from 'svelte-forms';
	import { config } from '$lib/shared/stores/config';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import type {
		TextFieldType,
		NumberFieldType,
		BooleanFieldType,
		FormApi
	} from '$lib/shared/components/forms/types';
	import { fieldDefs } from '../config';
	import { derived } from 'svelte/store';
	import type { Daemon } from '../types/base';

	export let formApi: FormApi;
	export let daemon: Daemon | null = null;
	export let networkId: string;
	export let apiKey: string | null = null;
	export let showAdvanced: boolean = true;
	export let initialName: string = '';
	export let showModeSelect: boolean = true;

	// Separate field defs - conditionally exclude mode if showModeSelect is false
	$: basicFieldDefs = fieldDefs.filter((d) => !d.section && (d.id !== 'mode' || showModeSelect));
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
		let initial;
		if (def.id === 'name' && initialName) {
			initial = initialName;
		} else if (daemon) {
			// eslint-disable-next-line @typescript-eslint/no-explicit-any
			initial = (daemon as any)[def.id] ?? def.defaultValue;
		} else {
			initial = def.defaultValue;
		}
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

	let isNewDaemon = daemon === null;
	let serverUrl = $config.public_url;

	const installScript = `bash -c "$(curl -fsSL https://raw.githubusercontent.com/scanopy/scanopy/refs/heads/main/install.sh)"`;

	$: runCommand = buildRunCommand(serverUrl, networkId, apiKey, $values, daemon);
	$: dockerCompose = apiKey
		? buildDockerCompose(serverUrl, networkId, apiKey, $values, $valids)
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

	// Export the daemon name value for parent components
	export function getDaemonName(): string {
		return $values['name'] as string;
	}
</script>

<div class="space-y-4">
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

	<!-- Advanced Configuration -->
	{#if showAdvanced}
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
	{/if}

	<!-- Installation Instructions (shown when API key is available) -->
	{#if apiKey}
		<div class="space-y-4">
			<div class="text-secondary">
				<b>Option 1.</b> Run the install script, then start the daemon
			</div>
			<CodeContainer language="bash" expandable={false} code={installScript} />
			<CodeContainer language="bash" expandable={false} code={runCommand} />

			<div class="text-secondary">
				<b>Option 2.</b> Run with Docker Compose
				<span class="text-tertiary">(Linux only)</span>
			</div>
			<CodeContainer language="yaml" expandable={false} code={dockerCompose} />
		</div>
	{/if}
</div>
