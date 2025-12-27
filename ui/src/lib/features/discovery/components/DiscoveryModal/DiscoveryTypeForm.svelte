<script lang="ts">
	import { untrack } from 'svelte';
	import type { FormApi } from '$lib/shared/components/forms/types';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { useSubnetsQuery } from '$lib/features/subnets/queries';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { DockerDiscovery, NetworkDiscovery, SelfReportDiscovery } from '../../types/api';
	import type { Discovery } from '../../types/base';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { discoveryTypes, subnetTypes } from '$lib/shared/stores/metadata';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { generateCronSchedule, parseCronToHours } from '../../store';

	// Props
	let {
		formApi,
		formData = $bindable(),
		readOnly = false,
		daemonHostId,
		daemon
	}: {
		formApi: FormApi;
		formData: Discovery;
		readOnly?: boolean;
		daemonHostId: string | null;
		daemon: Daemon;
	} = $props();

	// Queries
	const subnetsQuery = useSubnetsQuery();

	// Derived data
	let subnetsData = $derived(subnetsQuery.data ?? []);

	// Discovery type options
	const discoveryTypeField = field('discovery_type', formData.discovery_type.type, [required()]);

	let discoveryTypeOptions = $derived([
		{ value: 'Network', label: 'Network Scan', disabled: false },
		{
			value: 'Docker',
			label: 'Docker Scan',
			disabled: daemonHostId == null || !daemon.capabilities.has_docker_socket
		},
		{ value: 'SelfReport', label: 'Self Report', disabled: daemonHostId == null }
	]);

	const hostNameFallbackField = field('host_name_fallback', 'BestService', [required()]);

	const hostNameFallbackOptions = [
		{ value: 'Ip', label: 'IP Address' },
		{ value: 'BestService', label: 'Best Service' }
	];

	// Run type toggle
	const runTypeField = field('run_type', formData.run_type.type, [required()]);

	const runTypeOptions = [
		{ value: 'AdHoc', label: 'AdHoc (Run on Demand)' },
		{ value: 'Scheduled', label: 'Scheduled (Automatic)' }
	];

	// Handle run type changes
	$effect(() => {
		const type = $runTypeField.value;
		if (type === 'AdHoc' && formData.run_type.type !== 'AdHoc') {
			formData.run_type = {
				type: 'AdHoc',
				last_run: null
			};
		} else if (type === 'Scheduled' && formData.run_type.type !== 'Scheduled') {
			formData.run_type = {
				type: 'Scheduled',
				cron_schedule: '0 0 */1 * * *', // Default: every hour
				last_run: null,
				enabled: true
			};
		}
	});

	// Handle discovery type changes
	$effect(() => {
		const type = $discoveryTypeField.value;
		if (type === 'Network' && formData.discovery_type.type !== 'Network') {
			formData.discovery_type = {
				type: 'Network',
				subnet_ids: daemon.capabilities.interfaced_subnet_ids,
				host_naming_fallback: 'BestService'
			} as NetworkDiscovery;
			hostNameFallbackField.set('BestService');
		} else if (type === 'Docker' && formData.discovery_type.type !== 'Docker') {
			formData.discovery_type = {
				type: 'Docker',
				host_id: daemonHostId,
				host_naming_fallback: 'BestService'
			} as DockerDiscovery;
			hostNameFallbackField.set('BestService');
		} else if (type === 'SelfReport' && formData.discovery_type.type !== 'SelfReport') {
			formData.discovery_type = {
				type: 'SelfReport',
				host_id: daemonHostId
			} as SelfReportDiscovery;
		}
	});

	// Handle host naming fallback changes
	$effect(() => {
		const fallbackValue = $hostNameFallbackField.value;
		if (formData.discovery_type.type == 'Docker' || formData.discovery_type.type == 'Network') {
			formData.discovery_type = {
				...formData.discovery_type,
				host_naming_fallback: fallbackValue as 'BestService' | 'Ip'
			};
		}
	});

	// Subnet management for Network
	let availableSubnets = $derived(
		subnetsData.filter(
			(s) =>
				formData.discovery_type.type === 'Network' &&
				s.network_id == formData.network_id &&
				!formData.discovery_type.subnet_ids?.includes(s.id) &&
				subnetTypes.getMetadata(s.subnet_type).network_scan_discovery_eligible
		)
	);

	let selectedSubnets = $derived(
		formData.discovery_type.type === 'Network' && formData.discovery_type.subnet_ids
			? formData.discovery_type.subnet_ids
					.map((id) => subnetsData.find((s) => s.id === id))
					.filter(Boolean)
			: []
	);

	let nonInterfacedSubnets = $derived(
		formData.discovery_type.type == 'Network' &&
			formData.discovery_type.subnet_ids &&
			formData.discovery_type.subnet_ids.length > 0
			? formData.discovery_type.subnet_ids
					.filter((s) => !daemon.capabilities.interfaced_subnet_ids.includes(s))
					.map((s) => subnetsData.find((subnet) => subnet.id == s))
					.filter((s) => s != undefined)
					.map((s) => s.name + ` (${s.cidr})`)
			: []
	);

	function handleAddSubnet(subnetId: string) {
		if (formData.discovery_type.type === 'Network') {
			const currentIds = formData.discovery_type.subnet_ids || [];
			formData.discovery_type = {
				...formData.discovery_type,
				subnet_ids: [...currentIds, subnetId]
			};
		}
	}

	function handleRemoveSubnet(index: number) {
		if (formData.discovery_type.type === 'Network' && formData.discovery_type.subnet_ids) {
			formData.discovery_type = {
				...formData.discovery_type,
				subnet_ids: formData.discovery_type.subnet_ids.filter((_, i) => i !== index)
			};
		}
	}

	// Frequency configuration - convert between hours and cron
	// These are bidirectional: updated from cron_schedule AND used to generate it
	// eslint-disable-next-line svelte/prefer-writable-derived
	let selectedDays = $state(1);
	// eslint-disable-next-line svelte/prefer-writable-derived
	let selectedHours = $state(0);

	// Parse existing cron schedule on mount/update
	$effect(() => {
		if (formData.run_type.type === 'Scheduled' && formData.run_type.cron_schedule) {
			const totalHours = parseCronToHours(formData.run_type.cron_schedule);
			if (totalHours !== null) {
				selectedDays = Math.floor(totalHours / 24);
				selectedHours = totalHours % 24;
			}
		}
	});

	// Generate cron schedule from selected hours
	$effect(() => {
		if (formData.run_type.type === 'Scheduled') {
			const totalHours = selectedDays * 24 + selectedHours;
			formData.run_type = {
				...formData.run_type,
				cron_schedule: generateCronSchedule(totalHours)
			};
		}
	});

	// Day and hour options
	const dayOptions = Array.from({ length: 31 }, (_, i) => ({
		value: String(i),
		label: i === 0 ? 'No days' : i === 1 ? '1 day' : `${i} days`
	}));

	const hourOptions = Array.from({ length: 24 }, (_, i) => ({
		value: String(i),
		label: i === 0 ? 'No hours' : i === 1 ? '1 hour' : `${i} hours`
	}));

	// untrack since we sync via $effect and don't need reactive field recreation
	const daysField = field(
		'frequency_days',
		untrack(() => String(selectedDays)),
		[]
	);
	const hoursField = field(
		'frequency_hours',
		untrack(() => String(selectedHours)),
		[]
	);

	$effect(() => {
		selectedDays = parseInt($daysField.value) || 0;
	});

	$effect(() => {
		selectedHours = parseInt($hoursField.value) || 0;
	});
</script>

<div class="space-y-6">
	<div class="border-t border-gray-700 pt-6">
		<h3 class="text-primary mb-4 text-lg font-medium">Discovery Configuration</h3>

		<div class="space-y-4">
			<!-- Run Type Selection -->
			<SelectInput
				label="Run Type"
				id="run_type"
				{formApi}
				field={runTypeField}
				options={runTypeOptions}
				disabled={readOnly}
				helpText={$runTypeField.value === 'AdHoc'
					? 'This discovery will only run when manually triggered'
					: 'This discovery will run automatically on a schedule'}
			/>

			<!-- Discovery Type Selection -->
			<SelectInput
				label="Discovery Type"
				id="discovery_type"
				{formApi}
				helpText={discoveryTypes.getDescription($discoveryTypeField.value)}
				field={discoveryTypeField}
				options={discoveryTypeOptions}
				disabled={readOnly}
			/>

			{#if daemonHostId == null}
				<InlineWarning
					title="Daemon host is missing"
					body="Could not find a host associated to the selected daemon. It may have been deleted or corrupted. Please recreate the daemon."
				/>
			{/if}

			<!-- Type-specific configuration -->

			{#if formData.discovery_type.type == 'Docker' || formData.discovery_type.type == 'Network'}
				<SelectInput
					label="Host Name Fallback"
					id="host_name_fallback"
					{formApi}
					helpText="In the event that hostname can't be resolved, what name should be set for discovered hosts? IP Address, or best service (the highest confidence service match)?"
					field={hostNameFallbackField}
					options={hostNameFallbackOptions}
				/>
			{/if}

			{#if formData.discovery_type.type === 'Network'}
				<div class="rounded-lg bg-gray-800/50 p-4">
					<ListManager
						label="Target Subnets"
						helpText="Select specific subnets to scan, or leave empty to scan all subnets that the daemon has an interface with."
						placeholder="Select a subnet..."
						emptyMessage="All subnets in network will be scanned"
						allowReorder={false}
						allowItemEdit={() => false}
						{formApi}
						showSearch={true}
						options={availableSubnets}
						items={selectedSubnets}
						optionDisplayComponent={SubnetDisplay}
						itemDisplayComponent={SubnetDisplay}
						onAdd={handleAddSubnet}
						onRemove={handleRemoveSubnet}
					/>
				</div>
				{#if nonInterfacedSubnets.length > 0}
					<InlineWarning
						title="Non-Interfaced Subnet Added"
						body={`The selected daemon does not have a direct network interface with the following subnets: \n${nonInterfacedSubnets.join('\n')}. \nYou can still include them, but hostnames and MAC addresses will not be available for any discovered hosts.`}
					/>
				{/if}
			{/if}
		</div>
	</div>

	<!-- Frequency Configuration (only for scheduled runs) -->
	{#if formData.run_type.type === 'Scheduled'}
		<div class="border-t border-gray-700 pt-6">
			<h3 class="text-primary mb-4 text-lg font-medium">Schedule Configuration</h3>

			<div class="space-y-4">
				<p class="text-tertiary text-sm">
					Configure how often this discovery should run automatically
				</p>

				<div class="grid grid-cols-2 gap-4">
					<SelectInput
						label="Days"
						id="frequency_days"
						{formApi}
						field={daysField}
						options={dayOptions}
					/>

					<SelectInput
						label="Hours"
						id="frequency_hours"
						{formApi}
						field={hoursField}
						options={hourOptions}
					/>
				</div>
			</div>
		</div>
	{:else if formData.run_type.type === 'AdHoc'}
		<div class="border-t border-gray-700 pt-6">
			<div class="rounded-lg bg-gray-800/50 p-4">
				<div class="flex items-start gap-3">
					<svg
						class="mt-0.5 h-5 w-5 flex-shrink-0 text-gray-400"
						fill="none"
						stroke="currentColor"
						viewBox="0 0 24 24"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
					<div>
						<h4 class="mb-1 text-sm font-medium text-gray-300">Manual Discovery</h4>
						<p class="text-sm text-gray-400">
							This discovery will only run when you manually trigger it from the discoveries page.
							No automatic scheduling is configured.
						</p>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
