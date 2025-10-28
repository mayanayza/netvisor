<script lang="ts">
	import { optionsPanelExpanded, topologyOptions } from '../../store';
	import { networks } from '$lib/features/networks/store';
	import { ChevronDown, ChevronRight, Settings } from 'lucide-svelte';
	import OptionsCheckbox from './OptionsCheckbox.svelte';
	import OptionsMultiSelect from './OptionsMultiSelect.svelte';
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

	function handleNetworkChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.request_options.network_ids = selectedOptions;
			return opts;
		});
	}

	function handleLeftZoneCategoriesChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.request_options.left_zone_service_categories = selectedOptions;
			return opts;
		});
	}

	function handleHideEdgeTypeChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.hide_edge_types = selectedOptions;
			return opts;
		});
	}

	function handleHideServiceCategoryChange(event: Event) {
		const target = event.target as HTMLSelectElement;
		const selectedOptions = Array.from(target.selectedOptions).map((opt) => opt.value);
		topologyOptions.update((opts) => {
			opts.request_options.hide_service_categories = selectedOptions;
			return opts;
		});
	}

	function handleLeftZoneTitleChange(event: Event) {
		const target = event.target as HTMLInputElement;
		topologyOptions.update((opts) => {
			opts.left_zone_title = target.value;
			return opts;
		});
	}
</script>

<!-- Floating Panel -->
<div class="topology-options absolute left-4 top-4 z-10 max-w-80 duration-300">
	<div class="card p-0 shadow-lg">
		<!-- Toggle Button -->
		<button
			class="btn-icon w-full items-center rounded-2xl text-left"
			on:click={() => optionsPanelExpanded.set(!$optionsPanelExpanded)}
		>
			{#if $optionsPanelExpanded}
				<div class="flex w-full gap-2 p-3">
					<ChevronDown class="text-secondary h-5 w-5" />
					<Settings class="text-primary h-5 w-5" />
					<span class="text-primary text-sm font-medium">Options</span>
				</div>
			{:else}
				<div class="flex w-full gap-2 p-3">
					<ChevronRight class="text-secondary h-5 w-5" />
					<Settings class="text-primary h-5 w-5" />
				</div>
			{/if}
		</button>

		<!-- Content -->
		{#if $optionsPanelExpanded}
			<div
				class="space-y-4 overflow-y-auto border-t border-gray-700 p-3"
				style="max-height: calc(100vh - 250px);"
			>
				<!-- Helper text -->
				<div class="rounded bg-gray-800/50 pt-2">
					<p class="text-tertiary text-[10px] leading-tight">
						Hold Ctrl (Windows/Linux) or Cmd (Mac) to select/deselect multiple options
					</p>
				</div>

				<!-- Network Selection -->
				<div class="space-y-1.5" style="display: none">
					<label for="network-select" class="text-primary text-s block font-medium">
						Networks
					</label>
					<select id="network-select" multiple on:change={handleNetworkChange} class="input-field">
						{#each $networks as network (network.id)}
							<option
								class="select-option"
								value={network.id}
								selected={$topologyOptions.request_options.network_ids.includes(network.id)}
							>
								{network.name}{network.is_default ? ' (Default)' : ''}
							</option>
						{/each}
					</select>
				</div>

				<OptionsSection title="Docker">
					<OptionsCheckbox
						bind:topologyOption={$topologyOptions.request_options.group_docker_bridges_by_host}
						title="Group Docker Bridges"
						description="Display Docker containers running on a single host in a single subnet grouping"
					/>
					<OptionsCheckbox
						bind:topologyOption={$topologyOptions.request_options.hide_vm_title_on_docker_container}
						title="Hide VM provider on containers"
						description="If a docker container is running on a host that is a VM, don't indicate this on the container node"
					/>
				</OptionsSection>

				<OptionsSection title="Left Zone">
					<div>
						<span class="text-secondary block text-sm font-medium">Title</span>
						<input
							type="text"
							value={$topologyOptions.left_zone_title}
							on:input={handleLeftZoneTitleChange}
							class="input-field"
						/>
						<p class="text-tertiary mt-1 text-xs">
							Customize the label for each subnet's left zone
						</p>
					</div>

					<!-- Infrastructure Service Categories -->
					<OptionsMultiSelect
						bind:topologyOption={$topologyOptions.request_options.left_zone_service_categories}
						options={serviceCategories}
						onChange={handleLeftZoneCategoriesChange}
						title="Categories"
						description="Select service categories that should be displayed in the left zone of subnets they interface with"
					/>

					<OptionsCheckbox
						bind:topologyOption={$topologyOptions.request_options.show_gateway_in_left_zone}
						title="Show gateways in left zone"
						description="Display gateway services in the subnet's left zone"
					/>
				</OptionsSection>

				<OptionsSection title="Hide Stuff">
					<OptionsCheckbox
						bind:topologyOption={$topologyOptions.request_options.hide_ports}
						title="Hide Ports"
						description="Don't show open ports next to services"
					/>
					<OptionsMultiSelect
						bind:topologyOption={$topologyOptions.request_options.hide_service_categories}
						onChange={handleHideServiceCategoryChange}
						options={serviceCategories}
						title="Service Categories"
						description="Select service categories that should be hidden"
					/>
					<OptionsMultiSelect
						bind:topologyOption={$topologyOptions.hide_edge_types}
						options={eTypes}
						onChange={handleHideEdgeTypeChange}
						title="Edge Types"
						description="Choose which edge types you would like to hide"
					/>
				</OptionsSection>
			</div>
		{/if}
	</div>
</div>
