<script lang="ts" context="module">
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Binding, Service } from '$lib/features/services/types/base';
	import type { Host, Interface, Port } from '$lib/features/hosts/types/base';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { ALL_INTERFACES } from '$lib/features/hosts/types/base';

	// Context for binding display - needs access to services, hosts, interfaces, ports
	export interface BindingWithServiceContext {
		services: Service[];
		hosts: Host[];
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

	// Helper to get binding display name
	function getBindingDisplayNameFromContext(
		binding: Binding,
		context: BindingWithServiceContext
	): string {
		if (binding.type === 'Interface') {
			const iface = context.interfaces.find((i) => i.id === binding.interface_id);
			return iface
				? formatInterfaceForBinding(iface, context.isContainerSubnet)
				: 'Unknown Interface';
		} else {
			const port = context.ports.find((p) => p.id === binding.port_id);
			const iface = binding.interface_id
				? context.interfaces.find((i) => i.id === binding.interface_id)
				: ALL_INTERFACES;
			const portFormatted = port ? formatPort(port) : 'Unknown Port';
			const interfaceFormatted = iface
				? formatInterfaceForBinding(iface, context.isContainerSubnet)
				: 'Unknown Interface';
			return interfaceFormatted + ' · ' + portFormatted;
		}
	}

	export const BindingWithServiceDisplay: EntityDisplayComponent<
		Binding,
		BindingWithServiceContext
	> = {
		getId: (binding: Binding) => binding.id,
		getLabel: (binding: Binding, context: BindingWithServiceContext) => {
			const servicesData = context?.services ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			return service?.name || 'Unknown Service';
		},
		getDescription: () => '',
		getIcon: (binding: Binding, context: BindingWithServiceContext) => {
			const servicesData = context?.services ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			if (!service) return entities.getIconComponent('Service');

			return serviceDefinitions.getIconComponent(service.service_definition);
		},
		getIconColor: (binding: Binding, context: BindingWithServiceContext) => {
			const servicesData = context?.services ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			if (!service) return 'text-secondary';

			return serviceDefinitions.getColorHelper(service.service_definition).icon;
		},
		getTags: (binding: Binding, context: BindingWithServiceContext) => [
			{
				label: getBindingDisplayNameFromContext(binding, context),
				color: entities.getColorHelper('Interface').color
			}
		],
		getCategory: (binding: Binding, context: BindingWithServiceContext) => {
			const servicesData = context?.services ?? [];
			const hostsData = context?.hosts ?? [];
			const service = servicesData.find((s) => s.bindings.some((b) => b.id === binding.id));
			if (!service) return null;
			const host = hostsData.find((h) => h.id === service.host_id);
			if (!host) return null;

			return host.name;
		}
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';

	export let item: Binding;
	export let context: BindingWithServiceContext = {
		services: [],
		hosts: [],
		interfaces: [],
		ports: [],
		isContainerSubnet: () => false
	};
</script>

<ListSelectItem {context} {item} displayComponent={BindingWithServiceDisplay} />
