<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getServiceForBinding } from '$lib/features/services/store';
	import { getPortFromId } from '$lib/features/ports/store';
	import { getInterfaceFromId } from '$lib/features/interfaces/store';

	// Context for binding display within form editing (inline editor needs host form data)
	interface ServiceAndHost {
		service: Service;
		host: HostFormData;
	}

	export const PortBindingDisplay: EntityDisplayComponent<PortBinding, ServiceAndHost> = {
		getId: (binding: PortBinding) => binding.id,
		getLabel: (binding: PortBinding) => {
			// Use store lookups for display - don't rely on embedded children
			const port = get(getPortFromId(binding.port_id));
			const iface = binding.interface_id
				? get(getInterfaceFromId(binding.interface_id))
				: ALL_INTERFACES;
			const portFormatted = port ? formatPort(port) : 'Unknown Port';
			const interfaceFormatted = iface ? formatInterface(iface) : 'Unknown Interface';
			return interfaceFormatted + ' · ' + portFormatted;
		},
		getDescription: () => '',
		getIcon: () => Link2,
		getIconColor: () => entities.getColorHelper('Port').icon,
		getTags: () => [],
		getCategory: (binding: PortBinding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		},
		supportsInlineEdit: true,
		renderInlineEdit: (
			binding: PortBinding,
			onUpdate: (updates: Partial<PortBinding>) => void,
			formApi: FormApi,
			context
		) => {
			return {
				component: Layer4BindingInlineEditor,
				props: {
					binding,
					formApi,
					onUpdate,
					service: context?.service,
					host: context?.host
				}
			};
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import { formatInterface } from '$lib/features/hosts/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import type { PortBinding, Service } from '$lib/features/services/types/base';
	import { Link2 } from 'lucide-svelte';
	import { ALL_INTERFACES, type HostFormData } from '$lib/features/hosts/types/base';
	import Layer4BindingInlineEditor from './PortBindingInlineEditor.svelte';
	import { get } from 'svelte/store';
	import type { FormApi } from '../../types';

	export let item: PortBinding;
	export let context: ServiceAndHost;
</script>

<ListSelectItem {item} {context} displayComponent={PortBindingDisplay} />
