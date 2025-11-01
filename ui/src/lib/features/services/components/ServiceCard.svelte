<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import { get } from 'svelte/store';
	import type { Service } from '../types/base';
	import type { Host, Interface, Port } from '$lib/features/hosts/types/base';
	import { getBindingDisplayName } from '../store';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { formatInterface } from '$lib/features/hosts/store';
	import { matchConfidenceColor, matchConfidenceLabel } from '$lib/shared/types';

	export let service: Service;
	export let host: Host;
	export let onDelete: (service: Service) => void = () => {};
	export let onEdit: (service: Service) => void = () => {};
	export let viewMode: 'card' | 'list';

	$: ports = host.ports.filter((p) =>
		service.bindings
			.map((b) => (b.type == 'Port' ? b.port_id : null))
			.filter((b) => b !== null)
			.includes(p.id)
	);
	$: ifaces = host.interfaces.filter((i) =>
		service.bindings
			.map((b) => b.interface_id)
			.filter((b) => b !== null)
			.includes(i.id)
	);
	$: firstTcpPortBinding = service.bindings.find((b) => {
		if (b.type == 'Port') {
			const port = host.ports.find((p) => p.id == b.port_id);
			if (port) {
				port.protocol = 'Tcp';
			}
		}
		return false;
	});

	// Build card data
	$: cardData = {
		title: service.name,
		subtitle: 'On host ' + host.name,
		link: firstTcpPortBinding
			? `http://${get(getBindingDisplayName(firstTcpPortBinding))}`
			: undefined,
		iconColor: serviceDefinitions.getColorHelper(service.service_definition).icon,
		icon: serviceDefinitions.getIconComponent(service.service_definition),
		fields: [
			{
				label: 'Port Bindings',
				value: ports.map((port: Port) => ({
					id: port.id,
					label: formatPort(port),
					color: entities.getColorHelper('Port').string
				})),
				emptyText: 'No ports assigned'
			},
			{
				label: 'Interface Bindings',
				value: ifaces.map((iface: Interface) => ({
					id: iface.id,
					label: formatInterface(iface),
					color: entities.getColorHelper('Interface').string
				})),
				emptyText: 'No interfaces assigned'
			},
			{
				label: 'Match Confidence',
				value: [
					{
						id: service.id,
						label:
							service.source.type == 'DiscoveryWithMatch'
								? matchConfidenceLabel(service.source.details)
								: 'N/A (Not a discovered service)',
						color:
							service.source.type == 'DiscoveryWithMatch'
								? matchConfidenceColor(service.source.details.confidence)
								: 'gray'
					}
				],
				emptyText: 'Confidence value unavailable'
			}
		],
		actions: [
			{
				label: 'Edit Service',
				icon: Edit,
				class: 'btn-icon',
				onClick: () => onEdit(service)
			},
			{
				label: 'Delete Service',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(service)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} />
