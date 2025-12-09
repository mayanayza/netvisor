import { field, form } from 'svelte-forms';
import { required } from 'svelte-forms/validators';

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const dummyTextField = field('dummyText', 'a', [required()]);
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const dummyNumberField = field('dummyNumber', 0, [required()]);
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const dummyBooleanField = field('dummyBoolean', true, [required()]);
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const dummyMultiField = field('dummyMulti', [] as string[], []);
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const dummyForm = form();

export type FormType = typeof dummyForm;

export type TextFieldType = typeof dummyTextField;
export type NumberFieldType = typeof dummyNumberField;
export type BooleanFieldType = typeof dummyBooleanField;
export type MultiSelectFieldType = typeof dummyMultiField;

export interface FormApi {
	registerField: (
		id: string,
		field: TextFieldType | NumberFieldType | BooleanFieldType | MultiSelectFieldType
	) => void;
	unregisterField: (id: string) => void;
}
