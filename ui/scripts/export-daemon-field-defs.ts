import { fieldDefs } from '../src/lib/features/daemons/config.ts';

function toSnakeCase(s: string): string {
	return s
		.replace(/([A-Z])/g, '_$1')
		.toLowerCase()
		.replace(/^_/, '');
}

const exported = fieldDefs.map((f) => ({
	id: toSnakeCase(f.id),
	cliFlag: f.cliFlag,
	envVar: f.envVar,
	helpText: f.helpText
}));

console.log(JSON.stringify(exported, null, 2));
