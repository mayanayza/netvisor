<script lang="ts" context="module">
	import type { Host } from '$lib/features/hosts/types/base';
	import { entities, groupTypes } from '$lib/shared/stores/metadata';

	export const GroupDisplay: EntityDisplayComponent<Group, object> = {
		getId: (group: Group) => group.id,
		getLabel: (group: Group) => group.name,
		getDescription: (group: Group) => "",
		getIcon: (group: Group) => groupTypes.getIconComponent(group.group_type),
		getIconColor: () => entities.getColorHelper("Group").icon,
		getTags: (group: Group) => [
			{
				label: groupTypes.getName(group.group_type),
				color: groupTypes.getColorHelper(group.group_type).string,
			}
		],
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
