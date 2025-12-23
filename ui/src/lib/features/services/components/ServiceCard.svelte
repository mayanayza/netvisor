<script lang="ts">
	import { Edit, Trash2 } from 'lucide-svelte';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { entities, serviceDefinitions } from '$lib/shared/stores/metadata';
	import type { Service } from '../types/base';
	import type { Host, Interface, Port } from '$lib/features/hosts/types/base';
	import { formatPort } from '$lib/shared/utils/formatting';
	import { formatInterface } from '$lib/features/hosts/store';
	import { matchConfidenceColor, matchConfidenceLabel } from '$lib/shared/types';
	import { SvelteMap } from 'svelte/reactivity';
	import { tags } from '$lib/features/tags/store';

	export let service: Service;
	export let host: Host;
	export let onDelete: (service: Service) => void = () => {};
	export let onEdit: (service: Service) => void = () => {};
	export let viewMode: 'card' | 'list';
	export let selected: boolean;
	export let onSelectionChange: (selected: boolean) => void = () => {};

	// Replace the existing $: ports reactive statement with this:
	$: groupedPortBindings = (() => {
		const portBindings = service.bindings.filter((b) => b.type === 'Port');
		const grouped = new SvelteMap<string | null, { iface: Interface | null; ports: Port[] }>();

		for (const binding of portBindings) {
			const port = host.ports.find((p) => p.id === binding.port_id);
			if (!port) continue;

			const interfaceId = binding.interface_id;
			if (!grouped.has(interfaceId)) {
				const iface = interfaceId ? host.interfaces.find((i) => i.id === interfaceId) : null;
				grouped.set(interfaceId, { iface: iface ?? null, ports: [] });
			}
			grouped.get(interfaceId)!.ports.push(port);
		}

		return Array.from(grouped.values()).map(({ iface, ports }) => {
			const portList = ports.map((p) => formatPort(p)).join(', ');
			const label = iface
				? `${iface.name ? iface.name + ': ' : ''} ${iface.ip_address} (${portList})`
				: `Unbound (${portList})`;
			return {
				id: iface?.id ?? 'unbound',
				label,
				color: entities.getColorHelper('Port').string
			};
		});
	})();

	$: ifaces = host.interfaces.filter((i) =>
		service.bindings
			.filter((b) => b.type == 'Interface')
			.map((b) => b.interface_id)
			.filter((b) => b !== null)
			.includes(i.id)
	);

	// Build card data
	$: cardData = {
		title: service.name,
		subtitle: 'On host ' + host.name,
		iconColor: serviceDefinitions.getColorHelper(service.service_definition).icon,
		Icon: serviceDefinitions.getIconComponent(service.service_definition),
		fields: [
			{
				label: 'Port Bindings',
				value: groupedPortBindings,
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
								? matchConfidenceLabel(service.source.details.confidence)
								: 'N/A (Not a discovered service)',
						color:
							service.source.type == 'DiscoveryWithMatch'
								? matchConfidenceColor(service.source.details.confidence)
								: 'gray'
					}
				],
				emptyText: 'Confidence value unavailable'
			},
			{
				label: 'Tags',
				value: service.tags.map((t) => {
					const tag = $tags.find((tag) => tag.id == t);
					return tag
						? { id: tag.id, color: tag.color, label: tag.name }
						: { id: t, color: 'gray', label: 'Unknown Tag' };
				})
			}
		],
		actions: [
			{
				label: 'Delete',
				icon: Trash2,
				class: 'btn-icon-danger',
				onClick: () => onDelete(service)
			},
			{
				label: 'Edit',
				icon: Edit,
				class: 'btn-icon',
				onClick: () => onEdit(service)
			}
		]
	};
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
