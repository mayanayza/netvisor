<script lang="ts">
	import { topologyOptions } from '../../../store';
	import OptionsCheckbox from '../../../../../shared/components/forms/input/Checkbox.svelte';
	import OptionsMultiSelect from '../../../../../shared/components/forms/input/MultiSelect.svelte';
	import OptionsSection from './OptionsSection.svelte';
	import { onMount } from 'svelte';
	import { edgeTypes, serviceDefinitions } from '$lib/shared/stores/metadata';

	// Get unique service categories
	let serviceCategories: string[] = [];
	let eTypes: string[] = [];

	onMount(() => {
		const serviceDefinitionItems = serviceDefinitions.getItems() || [];
		const categoriesSet = new Set(
			serviceDefinitionItems.map((i) => serviceDefinitions.getCategory(i.id))
		);
		serviceCategories = Array.from(categoriesSet)
			.filter((c) => c)
			.sort();

		eTypes = edgeTypes.getItems().map((e) => e.id) || [];
	});

	function handleLeftZoneCategoriesChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.request.left_zone_service_categories = selectedOptions;
			return opts;
		});
	}

	function handleHideEdgeTypeChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.local.hide_edge_types = selectedOptions;
			return opts;
		});
	}

	function handleHideServiceCategoryChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.request.hide_service_categories = selectedOptions;
			return opts;
		});
	}

	function handleLeftZoneTitleChange(event: Event) {
		const target = event.target as HTMLInputElement;
		topologyOptions.update((opts) => {
			opts.local.left_zone_title = target.value;
			return opts;
		});
	}
</script>

<div class="space-y-4">
	<!-- Helper text -->
	<div class="rounded bg-gray-800/50 pt-2">
		<p class="text-tertiary text-[10px] leading-tight">
			Hold Ctrl (Windows/Linux) or Cmd (Mac) to select/deselect multiple options
		</p>
	</div>

	<OptionsSection title="Visual">
		<OptionsCheckbox
			bind:field={$topologyOptions.local.no_fade_edges}
			title="Don't Fade Edges"
			description="Show edges at full opacity at all times"
		/>
		<OptionsCheckbox
			bind:field={$topologyOptions.local.hide_resize_handles}
			title="Hide Resize Handles"
			description="Hide subnet resize handles"
		/>
	</OptionsSection>

	<OptionsSection title="Docker">
		<OptionsCheckbox
			bind:field={$topologyOptions.request.group_docker_bridges_by_host}
			title="Group Docker Bridges"
			description="Display Docker containers running on a single host in a single subnet grouping"
		/>
		<OptionsCheckbox
			bind:field={$topologyOptions.request.hide_vm_title_on_docker_container}
			title="Hide VM provider on containers"
			description="If a docker container is running on a host that is a VM, don't indicate this on the container node"
		/>
	</OptionsSection>

	<OptionsSection title="Left Zone">
		<div>
			<span class="text-secondary block text-sm font-medium">Title</span>
			<input
				type="text"
				value={$topologyOptions.local.left_zone_title}
				on:input={handleLeftZoneTitleChange}
				class="input-field"
			/>
			<p class="text-tertiary mt-1 text-xs">Customize the label for each subnet's left zone</p>
		</div>

		<!-- Infrastructure Service Categories -->
		<OptionsMultiSelect
			bind:field={$topologyOptions.request.left_zone_service_categories}
			options={serviceCategories}
			onChange={handleLeftZoneCategoriesChange}
			title="Categories"
			description="Select service categories that should be displayed in the left zone of subnets they interface with"
		/>

		<OptionsCheckbox
			bind:field={$topologyOptions.request.show_gateway_in_left_zone}
			title="Show gateways in left zone"
			description="Display gateway services in the subnet's left zone"
		/>
	</OptionsSection>

	<OptionsSection title="Hide Stuff">
		<OptionsCheckbox
			bind:field={$topologyOptions.request.hide_ports}
			title="Hide Ports"
			description="Don't show open ports next to services"
		/>
		<OptionsMultiSelect
			bind:field={$topologyOptions.request.hide_service_categories}
			onChange={handleHideServiceCategoryChange}
			options={serviceCategories}
			title="Service Categories"
			description="Select service categories that should be hidden"
		/>
		<OptionsMultiSelect
			bind:field={$topologyOptions.local.hide_edge_types}
			options={eTypes}
			onChange={handleHideEdgeTypeChange}
			title="Edge Types"
			description="Choose which edge types you would like to hide"
		/>
	</OptionsSection>
</div>
