<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { InterfaceBinding, Service } from '$lib/features/services/types/base';
	import type { HostFormData, Interface } from '$lib/features/hosts/types/base';
	import { Link2 } from 'lucide-svelte';

	// Context for binding display within form editing (inline editor needs host form data)
	export interface InterfaceBindingDisplayContext {
		service: Service;
		host: HostFormData;
		services: Service[];
		interfaces: Interface[];
		isContainerSubnet: (subnetId: string) => boolean;
	}

	// Helper to format interface for display
	function formatInterfaceForBinding(
		iface: Interface,
		isContainerSubnet: (subnetId: string) => boolean
	): string {
		return isContainerSubnet(iface.subnet_id)
			? (iface.name ?? iface.ip_address)
			: (iface.name ? iface.name + ': ' : '') + iface.ip_address;
	}

	export const InterfaceBindingDisplay: EntityDisplayComponent<
		InterfaceBinding,
		InterfaceBindingDisplayContext
	> = {
		getId: (binding: InterfaceBinding) => binding.id,
		getLabel: (binding: InterfaceBinding, context: InterfaceBindingDisplayContext) => {
			const interfacesData = context?.interfaces ?? [];
			const isContainerSubnetFn = context?.isContainerSubnet ?? (() => false);
			const iface = interfacesData.find((i) => i.id === binding.interface_id);
			const interfaceFormatted = iface
				? formatInterfaceForBinding(iface, isContainerSubnetFn)
				: 'Unknown Interface';
			return interfaceFormatted;
		},
		getDescription: () => '',
		getIcon: () => Link2,
		getIconColor: () => entities.getColorHelper('Interface').icon,
		getTags: () => [],
		getCategory: (binding: InterfaceBinding, context: InterfaceBindingDisplayContext) => {
			const servicesData = context?.services ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			if (!service) return null;

			const serviceType = serviceDefinitions.getItem(service.service_definition);
			return serviceType?.category || null;
		},
		supportsInlineEdit: true,
		renderInlineEdit: (
			binding: InterfaceBinding,
			onUpdate: (updates: Partial<InterfaceBinding>) => void,
			formApi: FormApi,
			context: InterfaceBindingDisplayContext
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
	import InterfaceBindingInlineEditor from './InterfaceBindingInlineEditor.svelte';
	import type { FormApi } from '../../types';

	export let item: InterfaceBinding;
	export let context: InterfaceBindingDisplayContext;
</script>

<ListSelectItem {item} {context} displayComponent={InterfaceBindingDisplay} />
