import { max, min, required } from 'svelte-forms/validators';
import { ipAddress, maxLength, portRange } from '$lib/shared/components/forms/validators';
import type { Validator } from 'svelte-forms';

interface FieldDef {
	id: string;
	label: string;
	type: 'string' | 'number' | 'boolean' | 'select';
	defaultValue?: string | number | boolean;
	cliFlag: string;
	envVar: string;
	helpText: string;
	section?: string; // undefined = basic field, string = advanced section name
	placeholder?: string | number;
	options?: { label: string; value: string }[];
	disabled?: (isNew: boolean) => boolean;
	validators?: Validator[];
	required?: boolean;
}

export const fieldDefs: FieldDef[] = [
	{
		id: 'name',
		label: 'Name',
		type: 'string',
		cliFlag: '--name',
		envVar: 'NETVISOR_NAME',
		helpText: 'Name for this daemon',
		placeholder: 'Enter a name for this daemon...',
		validators: [required(), maxLength(100)],
		required: true
	},
	{
		id: 'mode',
		label: 'Daemon Mode',
		type: 'select',
		defaultValue: 'Push',
		cliFlag: '--mode',
		envVar: 'NETVISOR_MODE',
		helpText:
			'Select whether the daemon will Pull work from the server or have work Pushed to it. If set to Push, you will need to ensure that network you are deploying the daemon on can be reached by the server by opening/forwarding the port to the daemon. If set to Pull, no port opening/forwarding is needed.',
		options: [
			{ label: 'Push', value: 'Push' },
			{ label: 'Pull', value: 'Pull' }
		],
		disabled: (isNew) => !isNew
	},
	// Network section
	{
		id: 'daemonPort',
		label: 'Port',
		type: 'number',
		placeholder: 60073,
		cliFlag: '--daemon-port',
		envVar: 'NETVISOR_DAEMON_PORT',
		helpText: 'Port for daemon to listen on',
		section: 'Network',
		validators: [portRange()]
	},
	{
		id: 'bindAddress',
		label: 'Bind Address',
		type: 'string',
		defaultValue: '',
		cliFlag: '--bind-address',
		envVar: 'NETVISOR_BIND_ADDRESS',
		helpText: 'IP address to bind daemon to',
		placeholder: '0.0.0.0',
		section: 'Network',
		validators: [ipAddress()]
	},
	{
		id: 'daemonUrl',
		label: 'Daemon URL',
		type: 'string',
		defaultValue: '',
		cliFlag: '--daemon-url',
		envVar: 'NETVISOR_DAEMON_URL',
		helpText:
			'Public URL where server can reach daemon. Defaults to auto-detected IP + Daemon Port if not set',
		placeholder: 'https://daemon.example.com',
		section: 'Network',
		validators: []
	},
	{
		id: 'allowSelfSignedCerts',
		label: 'Allow Self-Signed Certificates',
		type: 'boolean',
		defaultValue: false,
		cliFlag: '--allow-self-signed-certs',
		envVar: 'NETVISOR_ALLOW_SELF_SIGNED_CERTS',
		helpText: 'Allow self-signed certs for daemon -> server connections',
		section: 'Network'
	},
	// Performance section
	{
		id: 'logLevel',
		label: 'Log Level',
		type: 'select',
		defaultValue: 'info',
		cliFlag: '--log-level',
		envVar: 'NETVISOR_LOG_LEVEL',
		helpText: 'Logging verbosity',
		section: 'Performance',
		options: [
			{ label: 'Trace', value: 'trace' },
			{ label: 'Debug', value: 'debug' },
			{ label: 'Info', value: 'info' },
			{ label: 'Warn', value: 'warn' },
			{ label: 'Error', value: 'error' }
		]
	},
	{
		id: 'heartbeatInterval',
		label: 'Heartbeat Interval',
		type: 'number',
		placeholder: 30,
		cliFlag: '--heartbeat-interval',
		envVar: 'NETVISOR_HEARTBEAT_INTERVAL',
		helpText:
			'Seconds between heartbeat updates / work requests (for daemons in pull mode) to server',
		section: 'Performance',
		validators: [min(0), max(300)]
	},
	{
		id: 'concurrentScans',
		label: 'Concurrent Scans',
		type: 'number',
		cliFlag: '--concurrent-scans',
		envVar: 'NETVISOR_CONCURRENT_SCANS',
		helpText: 'Maximum parallel host scans',
		placeholder: 'Auto',
		section: 'Performance'
	},
	// Docker section
	{
		id: 'dockerProxy',
		label: 'Docker Proxy',
		type: 'string',
		defaultValue: '',
		cliFlag: '--docker-proxy',
		envVar: 'NETVISOR_DOCKER_PROXY',
		helpText:
			'Optional proxy for Docker API. Can use both non-SSL and SSL proxy; SSL proxy requires additional SSL config vars',
		placeholder: 'http://localhost:80/',
		section: 'Docker Proxy',
		validators: []
	},
	{
		id: 'dockerProxySslCert',
		label: 'Docker Proxy SSL Cert',
		type: 'string',
		defaultValue: '',
		cliFlag: '--docker-proxy-ssl-cert',
		envVar: 'NETVISOR_DOCKER_PROXY_SSL_CERT',
		helpText: 'Path to SSL certificate if using a docker proxy with SSL',
		placeholder: '/certs/cert.pem',
		section: 'Docker Proxy',
		validators: []
	},
	{
		id: 'dockerProxySslKey',
		label: 'Docker Proxy SSL Key',
		type: 'string',
		defaultValue: '',
		cliFlag: '--docker-proxy-ssl-key',
		envVar: 'NETVISOR_DOCKER_PROXY_SSL_KEY',
		helpText: 'Path to SSL private key if using a docker proxy with SSL',
		placeholder: '/certs/key.pem',
		section: 'Docker Proxy',
		validators: []
	},
	{
		id: 'dockerProxySslChain',
		label: 'Docker Proxy SSL Chain',
		type: 'string',
		defaultValue: '',
		cliFlag: '--docker-proxy-ssl-chain',
		envVar: 'NETVISOR_DOCKER_PROXY_SSL_CHAIN',
		helpText: 'Path to SSL chain if using a docker proxy with SSL',
		placeholder: '/certs/ca.pem',
		section: 'Docker Proxy',
		validators: []
	}
];
