<script lang="ts">
	import { topologyOptions } from '../../../store';
	import { field } from 'svelte-forms';
	import Checkbox from '$lib/shared/components/forms/input/Checkbox.svelte';
	import MultiSelect from '$lib/shared/components/forms/input/MultiSelect.svelte';
	import TextInput from '$lib/shared/components/forms/input/TextInput.svelte';
	import { edgeTypes, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type {
		TextFieldType,
		BooleanFieldType,
		FormApi,
		MultiSelectFieldType
	} from '$lib/shared/components/forms/types';
	import { ChevronDown, ChevronRight } from 'lucide-svelte';

	// Dynamic options loaded on mount
	let serviceCategories: { value: string; label: string }[] = $derived.by(() => {
		const serviceDefinitionItems = serviceDefinitions.getItems() || [];
		const categoriesSet = new Set(
			serviceDefinitionItems.map((i) => serviceDefinitions.getCategory(i.id))
		);
		return Array.from(categoriesSet)
			.filter((c) => c)
			.sort()
			.map((c) => ({ value: c, label: c }));
	});
	let eTypes: { value: string; label: string }[] = $derived.by(() => {
		return (edgeTypes.getItems() || []).map((e) => ({ value: e.id, label: e.id }));
	});

	interface TopologyFieldDef {
		id: string;
		label: string;
		type: 'boolean' | 'string' | 'multiselect';
		path: 'local' | 'request';
		key: string;
		helpText: string;
		section: string;
		getOptions?: () => { value: string; label: string }[];
		placeholder?: string;
	}

	const fieldDefs: TopologyFieldDef[] = [
		// Visual section
		{
			id: 'no_fade_edges',
			label: "Don't Fade Edges",
			type: 'boolean',
			path: 'local',
			key: 'no_fade_edges',
			helpText: 'Show edges at full opacity at all times',
			section: 'Visual'
		},
		{
			id: 'hide_resize_handles',
			label: 'Hide Resize Handles',
			type: 'boolean',
			path: 'local',
			key: 'hide_resize_handles',
			helpText: 'Hide subnet resize handles',
			section: 'Visual'
		},
		// Docker section
		{
			id: 'group_docker_bridges_by_host',
			label: 'Group Docker Bridges',
			type: 'boolean',
			path: 'request',
			key: 'group_docker_bridges_by_host',
			helpText: 'Display Docker containers running on a single host in a single subnet grouping',
			section: 'Docker'
		},
		{
			id: 'hide_vm_title_on_docker_container',
			label: 'Hide VM provider on containers',
			type: 'boolean',
			path: 'request',
			key: 'hide_vm_title_on_docker_container',
			helpText:
				"If a docker container is running on a host that is a VM, don't indicate this on the container node",
			section: 'Docker'
		},
		// Left Zone section
		{
			id: 'left_zone_title',
			label: 'Title',
			type: 'string',
			path: 'local',
			key: 'left_zone_title',
			helpText: "Customize the label for each subnet's left zone",
			section: 'Left Zone',
			placeholder: 'Infrastructure'
		},
		{
			id: 'left_zone_service_categories',
			label: 'Categories',
			type: 'multiselect',
			path: 'request',
			key: 'left_zone_service_categories',
			helpText:
				'Select service categories that should be displayed in the left zone of subnets they interface with',
			section: 'Left Zone',
			getOptions: () => serviceCategories
		},
		{
			id: 'show_gateway_in_left_zone',
			label: 'Show gateways in left zone',
			type: 'boolean',
			path: 'request',
			key: 'show_gateway_in_left_zone',
			helpText: "Display gateway services in the subnet's left zone",
			section: 'Left Zone'
		},
		// Hide Stuff section
		{
			id: 'hide_ports',
			label: 'Hide Ports',
			type: 'boolean',
			path: 'request',
			key: 'hide_ports',
			helpText: "Don't show open ports next to services",
			section: 'Hide Stuff'
		},
		{
			id: 'hide_service_categories',
			label: 'Service Categories',
			type: 'multiselect',
			path: 'request',
			key: 'hide_service_categories',
			helpText: 'Select service categories that should be hidden',
			section: 'Hide Stuff',
			getOptions: () => serviceCategories
		},
		{
			id: 'hide_edge_types',
			label: 'Edge Types',
			type: 'multiselect',
			path: 'local',
			key: 'hide_edge_types',
			helpText: 'Choose which edge types you would like to hide',
			section: 'Hide Stuff',
			getOptions: () => eTypes
		}
	];

	// Get unique section names in order
	const sectionNames = [...new Set(fieldDefs.map((d) => d.section))];

	// Group fields by section
	const sections = sectionNames.map((name) => ({
		name,
		fields: fieldDefs.filter((d) => d.section === name)
	}));

	// Track expanded sections
	let expandedSections: Record<string, boolean> = Object.fromEntries(
		sectionNames.map((name) => [name, true])
	);

	// Create form fields initialized from topologyOptions
	const formFields: Record<string, TextFieldType | BooleanFieldType | MultiSelectFieldType> = {};

	for (const def of fieldDefs) {
		const opts = $topologyOptions;
		const initialValue =
			def.path === 'local'
				? opts.local[def.key as keyof typeof opts.local]
				: opts.request[def.key as keyof typeof opts.request];
		// Type assertion needed because TS can't narrow from fieldDefs
		// eslint-disable-next-line @typescript-eslint/no-explicit-any
		formFields[def.id] = field(def.id, initialValue as any, [], { checkOnInit: false });
	}

	// Sync form field changes back to topologyOptions
	for (const def of fieldDefs) {
		let isFirst = true;
		formFields[def.id].subscribe((fieldState) => {
			if (isFirst) {
				isFirst = false;
				return;
			}
			topologyOptions.update((opts) => {
				if (def.path === 'local') {
					// eslint-disable-next-line @typescript-eslint/no-explicit-any
					(opts.local as any)[def.key] = fieldState.value;
				} else {
					// eslint-disable-next-line @typescript-eslint/no-explicit-any
					(opts.request as any)[def.key] = fieldState.value;
				}
				return opts;
			});
		});
	}

	// Form API (no-op since we're not using form validation here)
	const formApi: FormApi = {
		registerField: () => {},
		unregisterField: () => {}
	};

	function toggleSection(sectionName: string) {
		expandedSections[sectionName] = !expandedSections[sectionName];
	}
</script>

<div class="space-y-4">
	<!-- Helper text -->
	<div class="rounded bg-gray-800/50 pt-2">
		<p class="text-tertiary text-[10px] leading-tight">
			Hold Ctrl (Windows/Linux) or Cmd (Mac) to select/deselect multiple options
		</p>
	</div>

	{#each sections as section (section.name)}
		<div class="card card-static px-0 py-2">
			<button
				type="button"
				class="text-secondary hover:text-primary flex w-full items-center gap-2 px-3 py-2 text-sm font-medium"
				onclick={() => toggleSection(section.name)}
			>
				{#if expandedSections[section.name]}
					<ChevronDown class="h-4 w-4" />
				{:else}
					<ChevronRight class="h-4 w-4" />
				{/if}
				{section.name}
			</button>

			{#if expandedSections[section.name]}
				<div class="space-y-3 px-3 pb-3">
					{#each section.fields as def (def.id)}
						{#if def.type === 'boolean'}
							<Checkbox
								{formApi}
								field={formFields[def.id] as BooleanFieldType}
								label={def.label}
								id={def.id}
								helpText={def.helpText}
							/>
						{:else if def.type === 'string'}
							<TextInput
								{formApi}
								field={formFields[def.id] as TextFieldType}
								label={def.label}
								id={def.id}
								helpText={def.helpText}
								placeholder={def.placeholder ?? ''}
							/>
						{:else if def.type === 'multiselect'}
							<MultiSelect
								{formApi}
								field={formFields[def.id] as MultiSelectFieldType}
								label={def.label}
								id={def.id}
								helpText={def.helpText}
								options={def.getOptions?.() ?? []}
							/>
						{/if}
					{/each}
				</div>
			{/if}
		</div>
	{/each}
</div>
