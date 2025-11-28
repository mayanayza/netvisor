import type { Validator } from 'svelte-forms';
import pkg from 'ipaddr.js';
import { validate } from 'email-validator';

const { isValid, isValidCIDR, parse, parseCIDR } = pkg;

// IP Address validator
export const emailValidator = (): Validator => (value: string) => {
	if (!value) return { valid: true, name: 'Valid email' }; // Allow empty if not required

	if (!validate(value)) {
		return { name: 'Invalid email', message: 'Invalid email address format', valid: false };
	}

	return {
		valid: true,
		name: 'Valid email'
	};
};

// IP Address validator
export const ipAddress = (): Validator => (value: string) => {
	if (!value) return { valid: true, name: 'Valid IP' }; // Allow empty if not required

	if (!isValid(value)) {
		return { name: 'Invalid IP', message: 'Invalid IP address format', valid: false };
	}

	return {
		valid: true,
		name: 'Valid IP'
	};
};

// CIDR validator
export const cidr = (): Validator => (value: string) => {
	if (!value) return { valid: true, name: 'Valid CIDR' }; // Allow empty if not required

	if (!isValidCIDR(value))
		return { valid: false, name: 'Invalid CIDR', message: `${cidr} is not valid CIDR notation` };

	return {
		valid: true,
		name: 'Valid CIDR'
	};
};

// IP in CIDR validator
export const ipAddressInCidr =
	(cidr: string): Validator =>
	(value: string) => {
		if (!isValidCIDR(cidr)) return { valid: false, name: `${cidr} is not valid CIDR notation` };
		if (!isValid(value))
			return { valid: true, name: `IP invalid, ipAddress validator will handle` };
		if (!parse(value).match(parseCIDR(cidr)))
			return { valid: false, name: `IP not in range of ${cidr}` };

		return {
			valid: true,
			name: 'IP in CIDR range'
		};
	};

// MAC address validator
export const mac = (): Validator => (value: string) => {
	if (!value) return { name: 'validMac', valid: true }; // Optional field

	const macRegex = /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/;
	if (!macRegex.test(value)) {
		return { name: 'Invalid MAC', message: 'Invalid MAC address format', valid: false };
	}

	return { name: 'Valid MAC', valid: true };
};

// Hostname validator
export const hostname = (): Validator => (value: string) => {
	if (!value) return { valid: true, name: 'hostname' }; // Allow empty if not required

	const hostnameRegex =
		/^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$/;
	return {
		valid: hostnameRegex.test(value.trim()),
		name: 'Please enter a valid hostname',
		message: 'Please enter a valid hostname'
	};
};

// Max length validator with custom message
export const maxLength =
	(max: number): Validator =>
	(value: string) => {
		if (!value) return { valid: true, name: 'maxLength' };

		return {
			valid: value.length <= max,
			name: `Must be less than ${max} characters`,
			message: `Must be less than ${max} characters`
		};
	};

// Port range validator
export const portRange = (): Validator => (value: number | string) => {
	if (!value && value !== 0) return { valid: true, name: 'portRange' };

	const port = typeof value === 'string' ? parseInt(value) : value;
	return {
		valid: Number.isInteger(port) && port >= 1 && port <= 65535,
		name: 'Port must be between 1 and 65535',
		message: 'Port must be between 1 and 65535'
	};
};

// Minimum length validator
export const minLength =
	(min: number): Validator =>
	(value: string) => {
		if (!value) return { valid: true, name: 'minLength' };

		return {
			valid: value.length >= min,
			name: `Must be at least ${min} characters`,
			message: `Must be at least ${min} characters`
		};
	};

export const passwordComplexity = (): Validator => (value: string) => {
	// Don't return invalid for empty values - let required() handle that
	if (!value) return { valid: true, name: 'passwordComplexity' };

	const hasUppercase = /[A-Z]/.test(value);
	const hasLowercase = /[a-z]/.test(value);
	const hasNumber = /[0-9]/.test(value);
	const hasSpecial = /[^A-Za-z0-9]/.test(value);

	if (!hasUppercase || !hasLowercase || !hasNumber || !hasSpecial) {
		return {
			valid: false,
			name: 'Password must contain uppercase, lowercase, number, and special character',
			message: 'Password must contain uppercase, lowercase, number, and special character'
		};
	}

	return { valid: true, name: 'passwordComplexity' };
};

// Password match validator (for confirm password)
export const passwordMatch =
	(getPasswordValue: () => string): Validator =>
	(value: string) => {
		const passwordValue = getPasswordValue();

		// If password is empty, confirm can be empty
		if (!passwordValue || passwordValue.trim() === '') {
			return { valid: true, name: 'passwordMatch' };
		}

		// If password has value but confirm is empty, that's invalid
		if (!value || value.trim() === '') {
			return {
				valid: false,
				name: 'Passwords do not match',
				message: 'Passwords do not match'
			};
		}

		// Both have values - check if they match
		return {
			valid: value === passwordValue,
			name: 'Passwords do not match',
			message: 'Passwords do not match'
		};
	};
