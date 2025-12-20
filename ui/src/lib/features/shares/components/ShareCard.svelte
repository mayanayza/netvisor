<script lang="ts">
	import { Copy, Edit, ExternalLink, Trash2, Check, Link, Code } from 'lucide-svelte';
	import type { Share } from '../types/base';
	import { generateShareUrl, generateEmbedUrl } from '../store';
	import GenericCard from '$lib/shared/components/data/GenericCard.svelte';
	import { topologies } from '$lib/features/topology/store';
	import { networks } from '$lib/features/networks/store';
	import { entities } from '$lib/shared/stores/metadata';

	let {
		share,
		onEdit = () => {},
		onDelete = () => {},
		viewMode = 'card',
		selected = false,
		onSelectionChange = () => {}
	}: {
		share: Share;
		onEdit?: (share: Share) => void;
		onDelete?: (share: Share) => void;
		viewMode?: 'card' | 'list';
		selected?: boolean;
		onSelectionChange?: (selected: boolean) => void;
	} = $props();

	let copied = $state(false);

	function getUrl(): string {
		return share.share_type === 'embed' ? generateEmbedUrl(share.id) : generateShareUrl(share.id);
	}

	async function copyUrl() {
		await navigator.clipboard.writeText(getUrl());
		copied = true;
		setTimeout(() => (copied = false), 2000);
	}

	function openUrl() {
		window.open(getUrl(), '_blank');
	}

	function formatExpiry(date: string | null): string {
		if (!date) return 'Never';
		const d = new Date(date);
		return d.toLocaleDateString();
	}

	let cardData = $derived.by(() => {
		const topology = $topologies.find((t) => t.id === share.topology_id);
		const network = $networks.find((n) => n.id === share.network_id);

		return {
			title: share.name,
			subtitle: share.has_password ? 'Password Protected' : undefined,
			iconColor: entities.getColorHelper('Share').icon,
			Icon: share.share_type === 'embed' ? Code : Link,
			fields: [
				{
					label: 'Type',
					value: share.share_type === 'link' ? 'Link Share' : 'Embed'
				},
				{
					label: 'Topology',
					value: topology
						? [
								{
									id: topology.id,
									label: topology.name,
									color: entities.getColorHelper('Topology').string
								}
							]
						: 'Unknown Topology'
				},
				{
					label: 'Network',
					value: network
						? [
								{
									id: network.id,
									label: network.name,
									color: entities.getColorHelper('Network').string
								}
							]
						: 'Unknown Network'
				},
				{
					label: 'Status',
					value: share.is_enabled ? 'Enabled' : 'Disabled'
				},
				{
					label: 'Expires',
					value: formatExpiry(share.expires_at)
				},
				...(share.share_type === 'embed' &&
				share.allowed_domains &&
				share.allowed_domains.length > 0
					? [{ label: 'Allowed Domains', value: share.allowed_domains.join(', ') }]
					: [])
			],
			actions: [
				{
					label: 'Delete',
					icon: Trash2,
					class: 'btn-icon-danger',
					onClick: () => onDelete(share)
				},
				{
					label: copied ? 'Copied!' : 'Copy URL',
					icon: copied ? Check : Copy,
					class: copied ? 'text-green-400' : '',
					onClick: copyUrl
				},
				{
					label: 'Open',
					icon: ExternalLink,
					onClick: openUrl
				},
				{
					label: 'Edit',
					icon: Edit,
					onClick: () => onEdit(share)
				}
			]
		};
	});
</script>

<GenericCard {...cardData} {viewMode} {selected} {onSelectionChange} />
