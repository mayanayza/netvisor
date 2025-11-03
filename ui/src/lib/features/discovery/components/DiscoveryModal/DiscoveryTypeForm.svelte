<script lang="ts">
	import type { FormApi } from '$lib/shared/components/forms/types';
	import SelectInput from '$lib/shared/components/forms/input/SelectInput.svelte';
	import { field } from 'svelte-forms';
	import { required } from 'svelte-forms/validators';
	import { subnets } from '$lib/features/subnets/store';
	import { SubnetDisplay } from '$lib/shared/components/forms/selection/display/SubnetDisplay.svelte';
	import ListManager from '$lib/shared/components/forms/selection/ListManager.svelte';
	import type { Docker, Network, SelfReport } from '../../types/api';
	import type { Discovery } from '../../types/base';
	import InlineWarning from '$lib/shared/components/feedback/InlineWarning.svelte';
	import { discoveryTypes } from '$lib/shared/stores/metadata';
	import type { Daemon } from '$lib/features/daemons/types/base';
	import { generateCronSchedule, parseCronToHours } from '../../store';

	export let formApi: FormApi;
	export let formData: Discovery;
	export let readOnly: boolean = false;
	export let daemonHostId: string | null;
	export let daemon: Daemon;

	// Discovery type options
	const discoveryTypeField = field('discovery_type', formData.discovery_type.type, [required()]);

	$: discoveryTypeOptions = [
		{ value: 'Network', label: 'Network Scan', disabled: false },
		{
			value: 'Docker',
			label: 'Docker Scan',
			disabled: daemonHostId == null || !daemon.capabilities.has_docker_socket
		},
		{ value: 'SelfReport', label: 'Self Report', disabled: daemonHostId == null }
	];

	// Run type toggle
	const runTypeField = field('run_type', formData.run_type.type, [required()]);

	const runTypeOptions = [
		{ value: 'AdHoc', label: 'AdHoc (Run on Demand)' },
		{ value: 'Scheduled', label: 'Scheduled (Automatic)' }
	];

	// Handle run type changes
	$: {
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
	}

	// Handle discovery type changes
	$: {
		const type = $discoveryTypeField.value;
		if (type === 'Network' && formData.discovery_type.type !== 'Network') {
			formData.discovery_type = {
				type: 'Network',
				subnet_ids: []
			} as Network;
		} else if (type === 'Docker' && formData.discovery_type.type !== 'Docker') {
			formData.discovery_type = {
				type: 'Docker',
				host_id: daemonHostId
			} as Docker;
		} else if (type === 'SelfReport' && formData.discovery_type.type !== 'SelfReport') {
			formData.discovery_type = {
				type: 'SelfReport',
				host_id: daemonHostId
			} as SelfReport;
		}
	}

	// Subnet management for Network
	$: availableSubnets = $subnets.filter(
		(s) =>
			formData.discovery_type.type === 'Network' &&
			!formData.discovery_type.subnet_ids?.includes(s.id) &&
			s.source.type != 'System' &&
			s.subnet_type != 'DockerBridge'
	);

	$: selectedSubnets =
		formData.discovery_type.type === 'Network' && formData.discovery_type.subnet_ids
			? formData.discovery_type.subnet_ids
					.map((id) => $subnets.find((s) => s.id === id))
					.filter(Boolean)
			: $subnets.filter((s) => daemon.capabilities.interfaced_subnet_ids.includes(s.id));

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
	let selectedDays = 0;
	let selectedHours = 1;

	// Parse existing cron schedule on mount/update
	$: if (formData.run_type.type === 'Scheduled' && formData.run_type.cron_schedule) {
		const totalHours = parseCronToHours(formData.run_type.cron_schedule);
		if (totalHours !== null) {
			selectedDays = Math.floor(totalHours / 24);
			selectedHours = totalHours % 24;
		}
	}

	// Generate cron schedule from selected hours
	$: if (formData.run_type.type === 'Scheduled') {
		const totalHours = selectedDays * 24 + selectedHours;
		formData.run_type = {
			...formData.run_type,
			cron_schedule: generateCronSchedule(totalHours)
		};
	}

	// Day and hour options
	const dayOptions = Array.from({ length: 31 }, (_, i) => ({
		value: String(i),
		label: i === 0 ? 'No days' : i === 1 ? '1 day' : `${i} days`
	}));

	const hourOptions = Array.from({ length: 24 }, (_, i) => ({
		value: String(i),
		label: i === 0 ? 'No hours' : i === 1 ? '1 hour' : `${i} hours`
	}));

	const daysField = field('frequency_days', String(selectedDays), []);
	const hoursField = field('frequency_hours', String(selectedHours), []);

	$: selectedDays = parseInt($daysField.value) || 0;
	$: selectedHours = parseInt($hoursField.value) || 0;
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
			{#if formData.discovery_type.type === 'Network'}
				<div class="rounded-lg bg-gray-800/50 p-4">
					<ListManager
						label="Target Subnets"
						helpText="Select specific subnets to scan, or leave empty to scan all"
						placeholder="Select a subnet..."
						emptyMessage="All subnets in network will be scanned"
						allowReorder={false}
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
						disabled={readOnly}
					/>

					<SelectInput
						label="Hours"
						id="frequency_hours"
						{formApi}
						field={hoursField}
						options={hourOptions}
						disabled={readOnly}
					/>
				</div>

				<div class="rounded-lg border border-blue-800 bg-blue-900/20 p-3">
					<p class="text-sm text-blue-300">
						Discovery will run every <strong>{selectedDays * 24 + selectedHours}</strong> hours
						{#if selectedDays > 0 || selectedHours > 0}
							({#if selectedDays > 0}{selectedDays} day{selectedDays !== 1 ? 's' : ''}{/if}
							{#if selectedDays > 0 && selectedHours > 0}and
							{/if}
							{#if selectedHours > 0}{selectedHours} hour{selectedHours !== 1 ? 's' : ''}{/if})
						{/if}
					</p>
					{#if formData.run_type.cron_schedule}
						<p class="mt-1 font-mono text-xs text-blue-400">
							Cron: {formData.run_type.cron_schedule}
						</p>
					{/if}
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
