<script lang="ts" context="module">
	import { entities, groupTypes } from '$lib/shared/stores/metadata';

	export const GroupDisplay: EntityDisplayComponent<Group, object> = {
		getId: (group: Group) => group.id,
		getLabel: (group: Group) => group.name,
		getDescription: (group: Group) =>
			`${(group.binding_ids ?? []).length} binding${(group.binding_ids ?? []).length > 0 ? 's' : ''} in group`,
		getIcon: (group: Group) => groupTypes.getIconComponent(group.group_type),
		getIconColor: () => entities.getColorHelper('Group').icon,
		getTags: (group: Group) => [
			{
				label: groupTypes.getName(group.group_type),
				color: groupTypes.getColorHelper(group.group_type).color
			}
		]
	};
</script>

<script lang="ts">
	import type { EntityDisplayComponent } from '../types';
	import ListSelectItem from '../ListSelectItem.svelte';
	import type { Group } from '$lib/features/groups/types/base';

	export let item: Group;
	export let context = {};
</script>

<ListSelectItem {item} {context} displayComponent={GroupDisplay} />
