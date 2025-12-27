<script lang="ts">
	import { toPng } from 'html-to-image';
	import { useSvelteFlow, type Node } from '@xyflow/svelte';
	import { Download } from 'lucide-svelte';
	import { pushError, pushSuccess } from '$lib/shared/stores/feedback';
	import { useOrganizationQuery } from '$lib/features/organizations/queries';
	import { billingPlans } from '$lib/shared/stores/metadata';

	const { getNodes, getEdges, getViewport, setViewport } = useSvelteFlow();

	// TanStack Query for organization
	const organizationQuery = useOrganizationQuery();
	let organization = $derived(organizationQuery.data);

	let hideCreatedWith = $derived.by(() => {
		if (organization && organization.plan && organization.plan.type) {
			return billingPlans.getMetadata(organization.plan.type).features.remove_created_with;
		} else {
			return false;
		}
	});

	function downloadImage(dataUrl: string) {
		const link = document.createElement('a');
		link.download = `scanopy-topology-${new Date().toISOString().split('T')[0]}.png`;
		link.href = dataUrl;
		link.click();
		pushSuccess('Export complete! Check your downloads folder.');
	}

	function getAbsolutePosition(node: Node, nodes: Node[]) {
		if (node.parentId) {
			const parent = nodes.find((n) => n.id === node.parentId);
			if (parent) {
				return {
					x: parent.position.x + node.position.x,
					y: parent.position.y + node.position.y
				};
			}
		}
		return { x: node.position.x, y: node.position.y };
	}

	async function handleClick() {
		const nodes = getNodes();
		const edges = getEdges();

		if (nodes.length === 0) {
			pushError('No nodes to export');
			return;
		}

		const originalViewport = getViewport();
		const flowElement = document.querySelector('.svelte-flow') as HTMLElement;

		if (!flowElement) {
			pushError('Flow element not found');
			return;
		}

		// Separate nodes by type
		const childNodes = nodes.filter((n) => n.parentId);
		const parentNodes = nodes.filter((n) => !n.parentId);
		const parentIdsWithChildren = new Set(childNodes.map((n) => n.parentId));
		const standaloneNodes = parentNodes.filter((n) => !parentIdsWithChildren.has(n.id));

		let minX = Infinity,
			minY = Infinity,
			maxX = -Infinity,
			maxY = -Infinity;

		// Calculate bounds from child nodes (absolute positions)
		childNodes.forEach((child) => {
			const absPos = getAbsolutePosition(child, nodes);
			const width = child.measured?.width || child.width || 150;
			const height = child.measured?.height || child.height || 50;

			minX = Math.min(minX, absPos.x);
			minY = Math.min(minY, absPos.y);
			maxX = Math.max(maxX, absPos.x + width);
			maxY = Math.max(maxY, absPos.y + height);
		});

		// Include standalone nodes
		standaloneNodes.forEach((node) => {
			const x = node.position.x;
			const y = node.position.y;
			const width = node.measured?.width || node.width || 150;
			const height = node.measured?.height || node.height || 50;

			minX = Math.min(minX, x);
			minY = Math.min(minY, y);
			maxX = Math.max(maxX, x + width);
			maxY = Math.max(maxY, y + height);
		});

		// Add small margin for parent container borders
		const parentBorderMargin = 20;
		parentNodes
			.filter((n) => parentIdsWithChildren.has(n.id))
			.forEach((parent) => {
				minX = Math.min(minX, parent.position.x - parentBorderMargin);
				minY = Math.min(minY, parent.position.y - parentBorderMargin);
			});

		// Include edge bounds using ABSOLUTE positions
		edges.forEach((edge) => {
			const sourceNode = nodes.find((n) => n.id === edge.source);
			const targetNode = nodes.find((n) => n.id === edge.target);

			if (sourceNode && targetNode) {
				const sourcePos = getAbsolutePosition(sourceNode, nodes);
				const targetPos = getAbsolutePosition(targetNode, nodes);

				const sourceWidth = sourceNode.measured?.width || sourceNode.width || 150;
				const sourceHeight = sourceNode.measured?.height || sourceNode.height || 50;
				const targetWidth = targetNode.measured?.width || targetNode.width || 150;
				const targetHeight = targetNode.measured?.height || targetNode.height || 50;

				const sourceCenterX = sourcePos.x + sourceWidth / 2;
				const sourceCenterY = sourcePos.y + sourceHeight / 2;
				const targetCenterX = targetPos.x + targetWidth / 2;
				const targetCenterY = targetPos.y + targetHeight / 2;

				minX = Math.min(minX, sourceCenterX, targetCenterX);
				minY = Math.min(minY, sourceCenterY, targetCenterY);
				maxX = Math.max(maxX, sourceCenterX, targetCenterX);
				maxY = Math.max(maxY, sourceCenterY, targetCenterY);
			}
		});

		// Add margin for labels and edge curves
		const edgeMargin = 150;
		minX -= edgeMargin;
		minY -= edgeMargin;
		maxX += edgeMargin;
		maxY += edgeMargin;

		const boundsWidth = maxX - minX;
		const boundsHeight = maxY - minY;

		const targetZoom = 0.75;
		const imageWidth = Math.round(boundsWidth * targetZoom);
		const imageHeight = Math.round(boundsHeight * targetZoom);

		const boundsCenterX = minX + boundsWidth / 2;
		const boundsCenterY = minY + boundsHeight / 2;

		const x = imageWidth / 2 - boundsCenterX * targetZoom;
		const y = imageHeight / 2 - boundsCenterY * targetZoom;

		const newViewport = { x, y, zoom: targetZoom };

		const originalWidth = flowElement.style.width;
		const originalHeight = flowElement.style.height;

		flowElement.style.width = `${imageWidth}px`;
		flowElement.style.height = `${imageHeight}px`;
		setViewport(newViewport, { duration: 0 });
		flowElement.classList.add('hide-for-export');

		let watermark = document.createElement('div');

		if (!hideCreatedWith) {
			watermark = document.createElement('div');
			watermark.style.cssText = `
				position: absolute;
				bottom: 15px;
				right: 15px;
				display: flex;
				align-items: center;
				gap: 8px;
				color: rgba(255, 255, 255, 0.5);
				font-size: 14px;
				font-family: system-ui;
				pointer-events: none;
				z-index: 9999;
			`;

			const logo = document.createElement('img');
			logo.src = 'https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png';
			logo.style.cssText = `
				height: 18px;
				width: auto;
			`;

			const text = document.createElement('span');
			text.textContent = 'Created using scanopy.net';

			watermark.appendChild(logo);
			watermark.appendChild(text);
			flowElement.appendChild(watermark);

			// Wait for logo to load
			await new Promise<void>((resolve) => {
				if (logo.complete) {
					resolve();
				} else {
					logo.onload = () => resolve();
					logo.onerror = () => resolve(); // Continue even if logo fails
				}
			});
		}

		await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));

		try {
			const dataUrl = await toPng(flowElement, {
				width: imageWidth,
				height: imageHeight,
				pixelRatio: 2
			});
			downloadImage(dataUrl);
		} catch (err) {
			console.error('Export failed:', err);
			pushError('Export failed');
		} finally {
			watermark.remove();
			flowElement.classList.remove('hide-for-export');
			flowElement.style.width = originalWidth;
			flowElement.style.height = originalHeight;
			setTimeout(() => setViewport(originalViewport, { duration: 0 }), 50);
		}
	}
</script>

<button class="btn-secondary" onclick={handleClick}>
	<Download class="my-1 h-5 w-5" />
</button>
