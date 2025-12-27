<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { formatPort } from '$lib/shared/utils/formatting';
	import type { PortBinding, Service } from '$lib/features/services/types/base';
	import {
		ALL_INTERFACES,
		type HostFormData,
		type Interface,
		type Port
	} from '$lib/features/hosts/types/base';
	import { Link2 } from 'lucide-svelte';

	// Context for binding display within form editing (inline editor needs host form data)
	export interface PortBindingDisplayContext {
		service: Service;
		host: HostFormData;
		services: Service[];
		interfaces: Interface[];
		ports: Port[];
		isContainerSubnet: (subnetId: string) => boolean;
	}

	// Helper to format interface for display
	function formatInterfaceForBinding(
		iface: Interface | typeof ALL_INTERFACES,
		isContainerSubnet: (subnetId: string) => boolean
	): string {
		if (iface.id == null) return iface.name;
		return isContainerSubnet(iface.subnet_id)
			? (iface.name ?? iface.ip_address)
			: (iface.name ? iface.name + ': ' : '') + iface.ip_address;
	}

	export const PortBindingDisplay: EntityDisplayComponent<PortBinding, PortBindingDisplayContext> =
		{
			getId: (binding: PortBinding) => binding.id,
			getLabel: (binding: PortBinding, context: PortBindingDisplayContext) => {
				const portsData = context?.ports ?? [];
				const interfacesData = context?.interfaces ?? [];
				const isContainerSubnetFn = context?.isContainerSubnet ?? (() => false);

				const port = portsData.find((p) => p.id === binding.port_id);
				const iface = binding.interface_id
					? interfacesData.find((i) => i.id === binding.interface_id)
					: ALL_INTERFACES;
				const portFormatted = port ? formatPort(port) : 'Unknown Port';
				const interfaceFormatted = iface
					? formatInterfaceForBinding(iface, isContainerSubnetFn)
					: 'Unknown Interface';
				return interfaceFormatted + ' · ' + portFormatted;
			},
			getDescription: () => '',
			getIcon: () => Link2,
			getIconColor: () => entities.getColorHelper('Port').icon,
			getTags: () => [],
			getCategory: (binding: PortBinding, context: PortBindingDisplayContext) => {
				const servicesData = context?.services ?? [];
				const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
				if (!service) return null;

				const serviceType = serviceDefinitions.getItem(service.service_definition);
				return serviceType?.category || null;
			},
			supportsInlineEdit: true,
			renderInlineEdit: (
				binding: PortBinding,
				onUpdate: (updates: Partial<PortBinding>) => void,
				formApi: FormApi,
				context: PortBindingDisplayContext
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
	import Layer4BindingInlineEditor from './PortBindingInlineEditor.svelte';
	import type { FormApi } from '../../types';

	export let item: PortBinding;
	export let context: PortBindingDisplayContext;
</script>

<ListSelectItem {item} {context} displayComponent={PortBindingDisplay} />
