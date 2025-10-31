<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { getServiceForBinding } from '$lib/features/services/store';

	export const InterfaceBindingDisplay: EntityDisplayComponent<InterfaceBinding> = {
		getId: (binding: InterfaceBinding) => binding.id,
		getLabel: (binding: InterfaceBinding) => {
			const iface = get(getInterfaceFromId(binding.interface_id));
			const interfaceFormatted = iface ? formatInterface(iface) : 'Unknown Interface';
			return interfaceFormatted;
		},
		getDescription: () => '',
		getIcon: () => Link2,
		getIconColor: () => entities.getColorHelper('Interface').icon,
		getTags: () => [],
		getIsDisabled: () => false,
		getCategory: (binding: InterfaceBinding) => {
			const service = get(getServiceForBinding(binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		},
		supportsInlineEdit: true,
		renderInlineEdit: (
			binding: InterfaceBinding,
			onUpdate: (updates: Partial<InterfaceBinding>) => void,
			formApi: FormApi,
			context: { service?: Service; host?: Host }
		) => {
			return {
				component: InterfaceBindingInlineEditor,
				props: {
					binding,
					onUpdate,
					formApi,
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
	import { formatInterface, getInterfaceFromId } from '$lib/features/hosts/store';
	import type { InterfaceBinding, Service } from '$lib/features/services/types/base';
	import { Link2 } from 'lucide-svelte';
	import type { Host } from '$lib/features/hosts/types/base';
	import InterfaceBindingInlineEditor from './InterfaceBindingInlineEditor.svelte';
	import { get } from 'svelte/store';
	import type { FormApi } from '../../types';

	export let item: InterfaceBinding;
</script>

<ListSelectItem {item} displayComponent={InterfaceBindingDisplay} />
