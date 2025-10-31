<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getServiceForBinding } from '$lib/features/services/store';

	export const PortBindingDisplay: EntityDisplayComponent<PortBinding> = {
		getId: (binding: PortBinding) => binding.id,
		getLabel: (binding: PortBinding) => {
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
		getIsDisabled: () => false,
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
			context: { service?: Service; host?: Host }
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
	import { formatInterface, getInterfaceFromId, getPortFromId } from '$lib/features/hosts/store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import type { PortBinding, Service } from '$lib/features/services/types/base';
	import { Link2 } from 'lucide-svelte';
	import { ALL_INTERFACES, type Host } from '$lib/features/hosts/types/base';
	import Layer4BindingInlineEditor from './PortBindingInlineEditor.svelte';
	import { get } from 'svelte/store';
	import type { FormApi } from '../../types';

	export let item: PortBinding;
</script>

<ListSelectItem {item} displayComponent={PortBindingDisplay} />
