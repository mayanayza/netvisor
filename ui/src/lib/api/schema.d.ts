export interface paths {
	'/api/auth/daemon-setup': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Store pre-registration daemon setup data in session and generate provisional API key
		 *     Supports multiple calls to configure daemons for different networks
		 */
		post: operations['daemon_setup'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/forgot-password': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['forgot_password'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/keys': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all api_keys */
		get: operations['list_api_keys'];
		put?: never;
		/** Create API key */
		post: operations['create_api_key'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/keys/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete api_keys */
		post: operations['bulk_delete_api_keys'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/keys/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get api_key by ID */
		get: operations['get_api_key_by_id'];
		/** Update an API key */
		put: operations['update_api_key'];
		post?: never;
		/** Delete api_key */
		delete: operations['delete_api_key'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/keys/{id}/rotate': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Rotate an API key */
		post: operations['rotate_key_handler'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/login': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['login'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/logout': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['logout'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/me': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['get_current_user'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/oidc/{slug}/unlink': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['unlink_oidc_account'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/register': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['register'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/reset-password': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['reset_password'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/setup': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Store pre-registration setup data (org name, networks, seed preference) in session */
		post: operations['setup'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/auth/update': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post: operations['update_password_auth'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/billing/checkout': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Create a checkout session */
		post: operations['create_checkout_session'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/billing/plans': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get available billing plans */
		get: operations['get_billing_plans'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/billing/portal': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Create a billing portal session */
		post: operations['create_portal_session'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/billing/webhooks': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Handle Stripe webhook
		 * @description Internal endpoint for Stripe webhook callbacks.
		 */
		post: operations['handle_webhook'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/bindings': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all bindings */
		get: operations['list_bindings'];
		put?: never;
		/**
		 * Create a new binding
		 * @description Creates a binding that associates a service with a port or interface.
		 *
		 *     ### Binding Types
		 *
		 *     - **Interface binding**: Service is present at an interface (IP address) without a specific port.
		 *       Used for non-port-bound services like gateways.
		 *     - **Port binding (specific interface)**: Service listens on a specific port on a specific interface.
		 *     - **Port binding (all interfaces)**: Service listens on a specific port on all interfaces
		 *       (`interface_id: null`).
		 *
		 *     ### Validation and Deduplication Rules
		 *
		 *     - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
		 *       A port binding on all interfaces conflicts with any interface binding for the same service.
		 *     - **All-interfaces precedence**: When creating a port binding with `interface_id: null`,
		 *       any existing specific-interface bindings for the same port are automatically removed,
		 *       as they are superseded by the all-interfaces binding.
		 */
		post: operations['create_binding'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/bindings/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete bindings */
		post: operations['bulk_delete_bindings'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/bindings/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get binding by ID */
		get: operations['get_binding_by_id'];
		/**
		 * Update a binding
		 * @description Updates an existing binding. The same conflict detection rules from binding creation apply.
		 *
		 *     ## Validation Rules
		 *
		 *     - **Conflict detection**: The updated binding must not conflict with other bindings on the
		 *       same service. Interface bindings conflict with port bindings on the same interface.
		 */
		put: operations['update_binding'];
		post?: never;
		/** Delete binding */
		delete: operations['delete_binding'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/config': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * Get public server configuration
		 * @description Returns public configuration settings like OIDC providers, billing status, etc.
		 */
		get: operations['get_public_config'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all daemons */
		get: operations['list_daemons'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete daemons */
		post: operations['bulk_delete_daemons'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/register': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Register a new daemon
		 * @description Internal endpoint for daemon self-registration. Creates a host entry
		 *     and sets up default discovery jobs for the daemon.
		 */
		post: operations['register_daemon'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get daemon by ID */
		get: operations['get_daemon_by_id'];
		put?: never;
		post?: never;
		/** Delete daemon */
		delete: operations['delete_daemon'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/{id}/heartbeat': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Receive daemon heartbeat
		 * @description Internal endpoint for daemons to send periodic heartbeats.
		 *     Updates the daemon's last_seen timestamp and current status.
		 */
		post: operations['receive_heartbeat'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/{id}/request-work': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Request work from server
		 * @description Internal endpoint for daemons to poll for pending discovery sessions.
		 *     Also updates heartbeat and returns any pending cancellation requests.
		 *     Returns tuple of (next_session, should_cancel).
		 */
		post: operations['receive_work_request'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/daemons/{id}/update-capabilities': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Update daemon capabilities
		 * @description Internal endpoint for daemons to report their current capabilities.
		 */
		post: operations['update_capabilities'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all discoveries */
		get: operations['list_discoveries'];
		put?: never;
		/** Create new discovery */
		post: operations['create_discovery'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/active-sessions': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get active discovery sessions */
		get: operations['get_active_sessions'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete discoveries */
		post: operations['bulk_delete_discoveries'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/start-session': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Start a discovery session */
		post: operations['start_session'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get discovery by ID */
		get: operations['get_discovery_by_id'];
		/** Update discovery */
		put: operations['update_discovery'];
		post?: never;
		/** Delete discovery */
		delete: operations['delete_discovery'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/{session_id}/cancel': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Cancel a discovery session */
		post: operations['cancel_discovery'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/discovery/{session_id}/update': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Receive discovery progress update from daemon
		 * @description Internal endpoint for daemons to report discovery progress.
		 */
		post: operations['receive_discovery_update'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/github-stars': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * Get GitHub star count
		 * @description Returns the current star count for the Scanopy GitHub repository.
		 */
		get: operations['get_stars'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/groups': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all groups */
		get: operations['list_groups'];
		put?: never;
		/** Create a new group */
		post: operations['create_group'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/groups/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete groups */
		post: operations['bulk_delete_groups'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/groups/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get group by ID */
		get: operations['get_group_by_id'];
		/** Update a group */
		put: operations['update_group'];
		post?: never;
		/** Delete group */
		delete: operations['delete_group'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/hosts': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * List all hosts
		 * @description Returns all hosts the authenticated user has access to, with their
		 *     interfaces, ports, and services included.
		 */
		get: operations['get_all_hosts'];
		put?: never;
		/**
		 * Create a new host
		 * @description Creates a host with optional interfaces, ports, and services.
		 *     The `source` field is automatically set to `Manual`.
		 *     IDs for the host and all children are generated server-side.
		 */
		post: operations['create_host'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/hosts/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Bulk delete hosts
		 * @description Deletes multiple hosts in a single request. The request body should be
		 *     an array of host IDs to delete. Fails if any host has an associated daemon.
		 */
		post: operations['bulk_delete_hosts'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/hosts/discovery': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/**
		 * Internal endpoint for daemon discovery
		 * @description Used by daemons to report discovered hosts. Accepts full entities with
		 *     pre-generated IDs. Uses upsert behavior to merge with existing hosts.
		 *
		 *     Tagged as "internal" - included in OpenAPI spec for client generation
		 *     but hidden from public documentation.
		 */
		post: operations['create_host_discovery'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/hosts/{destination_host}/consolidate/{other_host}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		/**
		 * Consolidate hosts
		 * @description Merges all interfaces, ports, and services from `other_host` into
		 *     `destination_host`, then deletes `other_host`. Both hosts must be
		 *     on the same network.
		 *
		 *     ### Merge Behavior
		 *
		 *     - **Interfaces**: Transferred to destination. If an interface with matching subnet+IP or MAC
		 *       already exists on destination, bindings are remapped to use the existing interface.
		 *     - **Ports**: Transferred to destination. If a port with the same number and protocol already
		 *       exists, bindings are remapped to use the existing port.
		 *     - **Services**: Transferred to destination with deduplication.
		 *       See [upsert behavior](https://scanopy.net/docs/discovery/#upsert-behavior) for details.
		 *
		 *     ### Restrictions
		 *
		 *     - Cannot consolidate a host with itself.
		 *     - Cannot consolidate a host that has a daemon - consolidate into it instead.
		 */
		put: operations['consolidate_hosts'];
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/hosts/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * Get a host by ID
		 * @description Returns a single host with its interfaces, ports, and services.
		 */
		get: operations['get_host_by_id'];
		/**
		 * Update a host
		 * @description Updates host properties. Children (interfaces, ports, services)
		 *     are managed via their own endpoints.
		 */
		put: operations['update_host'];
		post?: never;
		/**
		 * Delete a host
		 * @description Prevents deletion if the host has a daemon associated with it
		 */
		delete: operations['delete_host'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/interfaces': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all interfaces */
		get: operations['list_interfaces'];
		put?: never;
		/** Create a new interface */
		post: operations['create_interface'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/interfaces/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete interfaces */
		post: operations['bulk_delete_interfaces'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/interfaces/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get interface by ID */
		get: operations['get_interface_by_id'];
		/** Update an interface */
		put: operations['update_interface'];
		post?: never;
		/** Delete interface */
		delete: operations['delete_interface'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/invites': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all invites */
		get: operations['get_invites'];
		put?: never;
		/** Create invite */
		post: operations['create_invite'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/invites/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get an invite by ID */
		get: operations['get_invite'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/invites/{id}/revoke': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		post?: never;
		/** Revoke an invite */
		delete: operations['revoke_invite'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/metadata': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * Get metadata registry
		 * @description Returns metadata about all entity types, service definitions, and other system metadata.
		 */
		get: operations['get_metadata_registry'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/networks': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all networks */
		get: operations['list_networks'];
		put?: never;
		/** Create a new network */
		post: operations['create_network'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/networks/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete networks */
		post: operations['bulk_delete_networks'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/networks/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get network by ID */
		get: operations['get_network_by_id'];
		/** Update a network */
		put: operations['update_network'];
		post?: never;
		/** Delete a network */
		delete: operations['delete_network'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/organizations': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get the current user's organization */
		get: operations['get_organization'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/organizations/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		/** Update organization name */
		put: operations['update_org_name'];
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/organizations/{id}/populate-demo': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Populate demo data (only available for demo organizations) */
		post: operations['populate_demo_data'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/organizations/{id}/reset': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Reset all organization data (delete all entities except organization and owner user) */
		post: operations['reset'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/ports': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all ports */
		get: operations['list_ports'];
		put?: never;
		/** Create a new port */
		post: operations['create_port'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/ports/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete ports */
		post: operations['bulk_delete_ports'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/ports/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get port by ID */
		get: operations['get_port_by_id'];
		/** Update a port */
		put: operations['update_port'];
		post?: never;
		/** Delete port */
		delete: operations['delete_port'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/services': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all services */
		get: operations['list_services'];
		put?: never;
		/**
		 * Create a new service
		 * @description Creates a service with optional bindings to interfaces or ports.
		 *     The `id`, `created_at`, `updated_at`, and `source` fields are generated server-side.
		 *     Bindings are specified without `service_id` or `network_id` - these are assigned automatically.
		 *
		 *     ### Binding Validation Rules
		 *
		 *     - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
		 *       service's host. Bindings referencing entities from other hosts will be rejected.
		 *     - **Deduplication**: Duplicate bindings in the same request are automatically deduplicated.
		 *     - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
		 *       is included, any specific-interface bindings for the same port are automatically removed.
		 *     - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
		 *       A port binding on all interfaces conflicts with any interface binding.
		 */
		post: operations['create_service'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/services/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete services */
		post: operations['bulk_delete_services'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/services/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get service by ID */
		get: operations['get_service_by_id'];
		/**
		 * Update a service
		 * @description Updates an existing service. All binding validation rules from service creation apply here as well.
		 *
		 *     ## Binding Validation Rules
		 *
		 *     - **Cross-host validation**: All bindings must reference ports/interfaces that belong to the
		 *       service's host. Bindings referencing entities from other hosts will be rejected.
		 *     - **Deduplication**: Duplicate bindings are automatically deduplicated.
		 *     - **All-interfaces precedence**: If a port binding with `interface_id: null` (all interfaces)
		 *       is included, any specific-interface bindings for the same port are automatically removed.
		 *     - **Conflict detection**: Interface bindings conflict with port bindings on the same interface.
		 */
		put: operations['update_service'];
		post?: never;
		/** Delete service */
		delete: operations['delete_service'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/shares': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all shares */
		get: operations['list_shares'];
		put?: never;
		/** Create a new share */
		post: operations['create_share'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/shares/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete shares */
		post: operations['bulk_delete_shares'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/shares/public/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/**
		 * Get share metadata
		 * @description Does not include any topology data
		 */
		get: operations['get_public_share_metadata'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/shares/public/{id}/verify': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Verify password for a password-protected share (returns success/failure only) */
		post: operations['verify_share_password'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/shares/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get share by ID */
		get: operations['get_share_by_id'];
		/** Update a share */
		put: operations['update_share'];
		post?: never;
		/** Delete share */
		delete: operations['delete_share'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/subnets': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all subnets */
		get: operations['list_subnets'];
		put?: never;
		/** Create a new subnet */
		post: operations['create_subnet'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/subnets/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete subnets */
		post: operations['bulk_delete_subnets'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/subnets/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get subnet by ID */
		get: operations['get_subnet_by_id'];
		/**
		 * Update a subnet
		 * @description Updates subnet properties. If the CIDR is being changed, validates that
		 *     all existing interfaces on this subnet have IPs within the new CIDR range.
		 */
		put: operations['update_subnet'];
		post?: never;
		/** Delete subnet */
		delete: operations['delete_subnet'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/tags': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all tags */
		get: operations['list_tags'];
		put?: never;
		/** Create a new tag */
		post: operations['create_tag'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/tags/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete tags */
		post: operations['bulk_delete_tags'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/tags/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get tag by ID */
		get: operations['get_tag_by_id'];
		/** Update tag */
		put: operations['update_tag'];
		post?: never;
		/** Delete tag */
		delete: operations['delete_tag'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get all topologies */
		get: operations['get_all_topologies'];
		put?: never;
		/** Create topology */
		post: operations['create_topology'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get topology by ID */
		get: operations['get_topology_by_id'];
		put: operations['update_topology'];
		post?: never;
		/** Delete topology */
		delete: operations['delete_topology'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology/{id}/lock': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Lock a topology */
		post: operations['lock'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology/{id}/rebuild': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Rebuild topology layout */
		post: operations['rebuild'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology/{id}/refresh': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Refresh topology data */
		post: operations['refresh'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/topology/{id}/unlock': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Unlock a topology */
		post: operations['unlock'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/users': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** List all users */
		get: operations['get_all_users'];
		put?: never;
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/users/bulk-delete': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		put?: never;
		/** Bulk delete users */
		post: operations['bulk_delete_users'];
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/users/{id}': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** Get user by ID */
		get: operations['get_user_by_id'];
		/** Update your own user record */
		put: operations['update_user'];
		post?: never;
		/** Delete a user */
		delete: operations['delete_user'];
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
	'/api/users/{id}/admin': {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		get?: never;
		/** Admin update user (for changing permissions) */
		put: operations['admin_update_user'];
		post?: never;
		delete?: never;
		options?: never;
		head?: never;
		patch?: never;
		trace?: never;
	};
}
export type webhooks = Record<string, never>;
export interface components {
	schemas: {
		/** @description Error response type for API errors (no data field) */
		ApiErrorResponse: {
			error?: string | null;
			success: boolean;
		};
		ApiKey: components['schemas']['ApiKeyBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		ApiKeyBase: {
			/** Format: date-time */
			expires_at?: string | null;
			is_enabled?: boolean;
			readonly key: string;
			/** Format: date-time */
			readonly last_used: string | null;
			name: string;
			/** Format: uuid */
			network_id: string;
			tags: string[];
		};
		ApiKeyResponse: {
			api_key: components['schemas']['ApiKey'];
			key: string;
		};
		ApiResponse: {
			data?: null;
			error?: string | null;
			success: boolean;
		};
		ApiResponse_ApiKey: {
			data?: components['schemas']['ApiKeyBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_ApiKeyResponse: {
			data?: {
				api_key: components['schemas']['ApiKey'];
				key: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Binding: {
			/**
			 * @description Association between a service and a port / interface that the service is listening on
			 * @example {
			 *       "created_at": "2025-12-27T04:06:57.113246Z",
			 *       "id": "853312ae-886d-4620-b30a-fb4605df7b7d",
			 *       "interface_id": "550e8400-e29b-41d4-a716-446655440005",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "port_id": "550e8400-e29b-41d4-a716-446655440006",
			 *       "service_id": "550e8400-e29b-41d4-a716-446655440007",
			 *       "type": "Port",
			 *       "updated_at": "2025-12-27T04:06:57.113246Z"
			 *     }
			 */
			data?: components['schemas']['BindingBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_BulkDeleteResponse: {
			data?: {
				deleted_count: number;
				requested_count: number;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Daemon: {
			data?: components['schemas']['DaemonBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_DaemonRegistrationResponse: {
			/** @description Daemon registration response from server to daemon */
			data?: {
				daemon: components['schemas']['Daemon'];
				/** Format: uuid */
				host_id: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_DaemonSetupResponse: {
			/** @description Response from daemon setup endpoint */
			data?: {
				api_key?: string | null;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Discovery: {
			data?: components['schemas']['DiscoveryBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_DiscoveryUpdatePayload: {
			/** @description Progress update from daemon to server during discovery */
			data?: {
				/** Format: uuid */
				daemon_id: string;
				discovery_type: components['schemas']['DiscoveryType'];
				error?: string | null;
				/** Format: date-time */
				finished_at?: string | null;
				/** Format: uuid */
				network_id: string;
				phase: components['schemas']['DiscoveryPhase'];
				/** Format: int32 */
				progress: number;
				/** Format: uuid */
				session_id: string;
				/** Format: date-time */
				started_at?: string | null;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Group: {
			/**
			 * @example {
			 *       "binding_ids": [],
			 *       "color": "Blue",
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "description": "HTTP/HTTPS services group",
			 *       "edge_style": "Bezier",
			 *       "group_type": "RequestPath",
			 *       "id": "550e8400-e29b-41d4-a716-446655440008",
			 *       "name": "Web Services",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "source": {
			 *         "type": "Manual"
			 *       },
			 *       "tags": [],
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['GroupBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_HostResponse: {
			/**
			 * @description Response type for host endpoints.
			 *     Includes hydrated children (interfaces, ports, services).
			 * @example {
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "description": "Primary web server",
			 *       "hidden": false,
			 *       "hostname": "web-server-01.local",
			 *       "id": "550e8400-e29b-41d4-a716-446655440003",
			 *       "interfaces": [
			 *         {
			 *           "created_at": "2026-01-15T10:30:00Z",
			 *           "host_id": "550e8400-e29b-41d4-a716-446655440003",
			 *           "id": "550e8400-e29b-41d4-a716-446655440005",
			 *           "ip_address": "192.168.1.100",
			 *           "mac_address": "DE:AD:BE:EF:12:34",
			 *           "name": "eth0",
			 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *           "subnet_id": "550e8400-e29b-41d4-a716-446655440004",
			 *           "updated_at": "2026-01-15T10:30:00Z"
			 *         }
			 *       ],
			 *       "name": "web-server-01",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "ports": [
			 *         {
			 *           "created_at": "2026-01-15T10:30:00Z",
			 *           "host_id": "550e8400-e29b-41d4-a716-446655440003",
			 *           "id": "550e8400-e29b-41d4-a716-446655440006",
			 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *           "number": 80,
			 *           "protocol": "Tcp",
			 *           "type": "Http",
			 *           "updated_at": "2026-01-15T10:30:00Z"
			 *         }
			 *       ],
			 *       "services": [],
			 *       "source": {
			 *         "type": "Manual"
			 *       },
			 *       "tags": [],
			 *       "updated_at": "2026-01-15T10:30:00Z",
			 *       "virtualization": null
			 *     }
			 */
			data?: {
				/** Format: date-time */
				created_at: string;
				description?: string | null;
				hidden: boolean;
				hostname?: string | null;
				/** Format: uuid */
				id: string;
				interfaces: components['schemas']['Interface'][];
				name: string;
				/** Format: uuid */
				network_id: string;
				ports: components['schemas']['Port'][];
				services: components['schemas']['Service'][];
				source: components['schemas']['EntitySource'];
				tags: string[];
				/** Format: date-time */
				updated_at: string;
				virtualization?: null | components['schemas']['HostVirtualization'];
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Interface: {
			/**
			 * @example {
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
			 *       "id": "550e8400-e29b-41d4-a716-446655440005",
			 *       "ip_address": "192.168.1.100",
			 *       "mac_address": "DE:AD:BE:EF:12:34",
			 *       "name": "eth0",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "subnet_id": "550e8400-e29b-41d4-a716-446655440004",
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['InterfaceBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Invite: {
			data?: components['schemas']['InviteBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_MetadataRegistry: {
			data?: {
				billing_plans: components['schemas']['TypeMetadata'][];
				concepts: components['schemas']['EntityMetadata'][];
				discovery_types: components['schemas']['TypeMetadata'][];
				edge_types: components['schemas']['TypeMetadata'][];
				entities: components['schemas']['EntityMetadata'][];
				features: components['schemas']['TypeMetadata'][];
				group_types: components['schemas']['TypeMetadata'][];
				permissions: components['schemas']['TypeMetadata'][];
				ports: components['schemas']['TypeMetadata'][];
				service_definitions: components['schemas']['TypeMetadata'][];
				subnet_types: components['schemas']['TypeMetadata'][];
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Network: {
			/**
			 * @example {
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "name": "Home Network",
			 *       "organization_id": "550e8400-e29b-41d4-a716-446655440001",
			 *       "tags": [],
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['NetworkBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Organization: {
			data?: components['schemas']['OrganizationBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Port: {
			/**
			 * @description Port entity with custom serialization that flattens PortType fields.
			 * @example {
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
			 *       "id": "550e8400-e29b-41d4-a716-446655440006",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "number": 80,
			 *       "protocol": "Tcp",
			 *       "type": "Http",
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['PortBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_PublicConfigResponse: {
			data?: {
				billing_enabled: boolean;
				deployment_type: components['schemas']['DeploymentType'];
				disable_registration: boolean;
				has_email_opt_in: boolean;
				has_email_service: boolean;
				has_integrated_daemon: boolean;
				needs_cookie_consent: boolean;
				oidc_providers: components['schemas']['OidcProviderMetadata'][];
				plunk_key?: string | null;
				posthog_key?: string | null;
				public_url: string;
				/** Format: int32 */
				server_port: number;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_PublicShareMetadata: {
			/** @description Public share metadata (returned without authentication) */
			data?: {
				/** Format: uuid */
				id: string;
				name: string;
				options: components['schemas']['ShareOptions'];
				requires_password: boolean;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Service: {
			/**
			 * @example {
			 *       "bindings": [
			 *         {
			 *           "created_at": "2025-12-27T04:06:57.109411Z",
			 *           "id": "68096bd4-c1d2-45cd-9310-bbf4f87ab826",
			 *           "interface_id": "550e8400-e29b-41d4-a716-446655440005",
			 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *           "port_id": "550e8400-e29b-41d4-a716-446655440006",
			 *           "service_id": "550e8400-e29b-41d4-a716-446655440007",
			 *           "type": "Port",
			 *           "updated_at": "2025-12-27T04:06:57.109411Z"
			 *         }
			 *       ],
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
			 *       "id": "550e8400-e29b-41d4-a716-446655440007",
			 *       "name": "nginx",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "service_definition": "Bitwarden",
			 *       "source": {
			 *         "type": "Manual"
			 *       },
			 *       "tags": [],
			 *       "updated_at": "2026-01-15T10:30:00Z",
			 *       "virtualization": null
			 *     }
			 */
			data?: components['schemas']['ServiceBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_SetupResponse: {
			/** @description Response from setup endpoint */
			data?: {
				network_ids: string[];
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Share: {
			data?: components['schemas']['ShareBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_String: {
			data?: string;
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Subnet: {
			/**
			 * @example {
			 *       "cidr": "192.168.1.0/24",
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "description": "Local area network",
			 *       "id": "550e8400-e29b-41d4-a716-446655440004",
			 *       "name": "LAN",
			 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
			 *       "source": {
			 *         "type": "Manual"
			 *       },
			 *       "subnet_type": "Lan",
			 *       "tags": [],
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['SubnetBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Tag: {
			/**
			 * @example {
			 *       "color": "Green",
			 *       "created_at": "2026-01-15T10:30:00Z",
			 *       "description": "Production environment resources",
			 *       "id": "550e8400-e29b-41d4-a716-44665544000a",
			 *       "name": "production",
			 *       "organization_id": "550e8400-e29b-41d4-a716-446655440001",
			 *       "updated_at": "2026-01-15T10:30:00Z"
			 *     }
			 */
			data?: components['schemas']['TagBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Topology: {
			data?: components['schemas']['TopologyBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_User: {
			data?: components['schemas']['UserBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			};
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_ApiKey: {
			data?: (components['schemas']['ApiKeyBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_BillingPlan: {
			data?: (
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Community';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Starter';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Pro';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Team';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Business';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Enterprise';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'Demo';
				  })
				| (components['schemas']['PlanConfig'] & {
						/** @enum {string} */
						type: 'CommercialSelfHosted';
				  })
			)[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Binding: {
			data?: (components['schemas']['BindingBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Daemon: {
			data?: (components['schemas']['DaemonBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Discovery: {
			data?: (components['schemas']['DiscoveryBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_DiscoveryUpdatePayload: {
			data?: {
				/** Format: uuid */
				daemon_id: string;
				discovery_type: components['schemas']['DiscoveryType'];
				error?: string | null;
				/** Format: date-time */
				finished_at?: string | null;
				/** Format: uuid */
				network_id: string;
				phase: components['schemas']['DiscoveryPhase'];
				/** Format: int32 */
				progress: number;
				/** Format: uuid */
				session_id: string;
				/** Format: date-time */
				started_at?: string | null;
			}[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Group: {
			data?: (components['schemas']['GroupBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_HostResponse: {
			data?: {
				/** Format: date-time */
				created_at: string;
				description?: string | null;
				hidden: boolean;
				hostname?: string | null;
				/** Format: uuid */
				id: string;
				interfaces: components['schemas']['Interface'][];
				name: string;
				/** Format: uuid */
				network_id: string;
				ports: components['schemas']['Port'][];
				services: components['schemas']['Service'][];
				source: components['schemas']['EntitySource'];
				tags: string[];
				/** Format: date-time */
				updated_at: string;
				virtualization?: null | components['schemas']['HostVirtualization'];
			}[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Interface: {
			data?: (components['schemas']['InterfaceBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Invite: {
			data?: (components['schemas']['InviteBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Network: {
			data?: (components['schemas']['NetworkBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Port: {
			data?: (components['schemas']['PortBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Service: {
			data?: (components['schemas']['ServiceBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Share: {
			data?: (components['schemas']['ShareBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Subnet: {
			data?: (components['schemas']['SubnetBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Tag: {
			data?: (components['schemas']['TagBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_Topology: {
			data?: (components['schemas']['TopologyBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_Vec_User: {
			data?: (components['schemas']['UserBase'] & {
				/** Format: date-time */
				readonly created_at: string;
				/** Format: uuid */
				readonly id: string;
				/** Format: date-time */
				readonly updated_at: string;
			})[];
			error?: string | null;
			success: boolean;
		};
		ApiResponse_bool: {
			data?: boolean;
			error?: string | null;
			success: boolean;
		};
		ApiResponse_u32: {
			/** Format: int32 */
			data?: number;
			error?: string | null;
			success: boolean;
		};
		BillingPlan:
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Community';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Starter';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Pro';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Team';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Business';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Enterprise';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'Demo';
			  })
			| (components['schemas']['PlanConfig'] & {
					/** @enum {string} */
					type: 'CommercialSelfHosted';
			  });
		/** @enum {string} */
		BillingRate: 'Month' | 'Year';
		/**
		 * @description Association between a service and a port / interface that the service is listening on
		 * @example {
		 *       "created_at": "2025-12-27T04:06:57.099953Z",
		 *       "id": "c28cef63-dce4-4a93-bb96-4a5d2a655059",
		 *       "interface_id": "550e8400-e29b-41d4-a716-446655440005",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "port_id": "550e8400-e29b-41d4-a716-446655440006",
		 *       "service_id": "550e8400-e29b-41d4-a716-446655440007",
		 *       "type": "Port",
		 *       "updated_at": "2025-12-27T04:06:57.099953Z"
		 *     }
		 */
		Binding: components['schemas']['BindingBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		/** @description The base data for a Binding entity (everything except id, created_at, updated_at) */
		BindingBase: components['schemas']['BindingType'] & {
			/** Format: uuid */
			network_id: string;
			/** Format: uuid */
			service_id: string;
		};
		/**
		 * @description The type of binding - either to an interface or to a port.
		 *
		 *     Bindings associate a service with network resources (interfaces/ports) on a host.
		 *
		 *     ## Validation Rules
		 *
		 *     - All bindings must reference ports/interfaces that belong to the same host as the service.
		 *     - Interface bindings conflict with port bindings on the same interface.
		 *     - A port binding on all interfaces (`interface_id: null`) conflicts with any interface binding.
		 *     - When a port binding with `interface_id: null` is created, it supersedes (removes) any
		 *       existing specific-interface bindings for the same port.
		 */
		BindingType:
			| {
					/** Format: uuid */
					interface_id: string;
					/** @enum {string} */
					type: 'Interface';
			  }
			| {
					/**
					 * Format: uuid
					 * @description The interface this port binding applies to. If `null`, the binding applies to all
					 *     interfaces on the host (and supersedes specific-interface bindings for this port).
					 */
					interface_id: string | null;
					/** Format: uuid */
					port_id: string;
					/** @enum {string} */
					type: 'Port';
			  };
		BulkDeleteResponse: {
			deleted_count: number;
			requested_count: number;
		};
		/** @enum {string} */
		Color:
			| 'Pink'
			| 'Rose'
			| 'Red'
			| 'Orange'
			| 'Yellow'
			| 'Green'
			| 'Emerald'
			| 'Teal'
			| 'Cyan'
			| 'Blue'
			| 'Indigo'
			| 'Purple'
			| 'Gray';
		/**
		 * @description Input for creating a binding with a service.
		 *     `service_id` and `network_id` are assigned by the server after the service is created.
		 */
		CreateBindingInput:
			| {
					/** Format: uuid */
					interface_id: string;
					/** @enum {string} */
					type: 'Interface';
			  }
			| {
					/** Format: uuid */
					interface_id?: string | null;
					/** Format: uuid */
					port_id: string;
					/** @enum {string} */
					type: 'Port';
			  };
		CreateCheckoutRequest: {
			plan: components['schemas']['BillingPlan'];
			url: string;
		};
		/**
		 * @description Request type for creating a host with its associated interfaces and ports.
		 *     Server assigns `host_id`, `network_id`, and `source` to all children.
		 *     Source is automatically set based on how the entity was created (API vs UI).
		 *
		 *     Note: Services are created separately via `POST /api/services` after the host exists,
		 *     as service bindings require the real IDs of the interfaces/ports to reference.
		 * @example {
		 *       "description": "Primary web server",
		 *       "hidden": false,
		 *       "hostname": "web-server-01.local",
		 *       "interfaces": [
		 *         {
		 *           "ip_address": "192.168.1.100",
		 *           "mac_address": "DE:AD:BE:EF:12:34",
		 *           "name": "eth0",
		 *           "subnet_id": "550e8400-e29b-41d4-a716-446655440004"
		 *         }
		 *       ],
		 *       "name": "web-server-01",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "ports": [
		 *         {
		 *           "number": 80,
		 *           "protocol": "Tcp"
		 *         }
		 *       ],
		 *       "tags": [],
		 *       "virtualization": null
		 *     }
		 */
		CreateHostRequest: {
			description?: string | null;
			hidden?: boolean;
			hostname?: string | null;
			interfaces?: components['schemas']['CreateInterfaceInput'][];
			name: string;
			/** Format: uuid */
			network_id: string;
			ports?: components['schemas']['CreatePortInput'][];
			tags: string[];
			virtualization?: null | components['schemas']['HostVirtualization'];
		};
		/**
		 * @description Input for creating an interface with a host.
		 *     `host_id` and `network_id` are assigned by the server.
		 */
		CreateInterfaceInput: {
			ip_address: string;
			mac_address?: string | null;
			name?: string | null;
			/** Format: uuid */
			subnet_id: string;
		};
		CreateInviteRequest: {
			/** Format: int64 */
			expiration_hours?: number | null;
			network_ids: string[];
			permissions: components['schemas']['UserOrgPermissions'];
			send_to?: string | null;
		};
		/**
		 * @description Input for creating a port with a host.
		 *     `host_id` and `network_id` are assigned by the server.
		 *     The port is specified by number and protocol (e.g., 80/tcp, 443/tcp).
		 */
		CreatePortInput: {
			/**
			 * Format: int32
			 * @description Port number (1-65535)
			 */
			number: number;
			/** @description Transport protocol (Tcp or Udp) */
			protocol: components['schemas']['TransportProtocol'];
		};
		/**
		 * @description Request type for creating a service.
		 *     Server assigns `id`, `created_at`, `updated_at`, and `source`.
		 *     Server also assigns `service_id` and `network_id` to all bindings.
		 */
		CreateServiceRequest: {
			/**
			 * @description Bindings to create with the service.
			 *     `service_id` and `network_id` are assigned by the server.
			 */
			bindings?: components['schemas']['CreateBindingInput'][];
			/** Format: uuid */
			host_id: string;
			name: string;
			/** Format: uuid */
			network_id: string;
			service_definition: string;
			tags: string[];
			virtualization?: null | components['schemas']['ServiceVirtualization'];
		};
		CreateUpdateShareRequest: {
			password?: string | null;
			share: components['schemas']['Share'];
		};
		Daemon: components['schemas']['DaemonBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		DaemonBase: {
			capabilities: components['schemas']['DaemonCapabilities'];
			/** Format: uuid */
			host_id: string;
			/** Format: date-time */
			readonly last_seen: string;
			mode: components['schemas']['DaemonMode'];
			name: string;
			/** Format: uuid */
			network_id: string;
			tags: string[];
			readonly url: string;
		};
		/** @description Daemon capabilities */
		DaemonCapabilities: {
			has_docker_socket?: boolean;
			interfaced_subnet_ids: string[];
		};
		DaemonHeartbeatPayload: {
			mode: components['schemas']['DaemonMode'];
			name: string;
			url: string;
		};
		/** @enum {string} */
		DaemonMode: 'Push' | 'Pull';
		/** @description Daemon registration request from daemon to server */
		DaemonRegistrationRequest: {
			capabilities: components['schemas']['DaemonCapabilities'];
			/** Format: uuid */
			daemon_id: string;
			mode: components['schemas']['DaemonMode'];
			name: string;
			/** Format: uuid */
			network_id: string;
			url: string;
		};
		/** @description Daemon registration response from server to daemon */
		DaemonRegistrationResponse: {
			daemon: components['schemas']['Daemon'];
			/** Format: uuid */
			host_id: string;
		};
		/** @description Daemon setup request for pre-registration daemon configuration */
		DaemonSetupRequest: {
			daemon_name: string;
			install_later?: boolean;
			/** Format: uuid */
			network_id: string;
		};
		/** @description Response from daemon setup endpoint */
		DaemonSetupResponse: {
			api_key?: string | null;
		};
		/** @enum {string} */
		DeploymentType: 'cloud' | 'commercial' | 'community';
		Discovery: components['schemas']['DiscoveryBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		DiscoveryBase: {
			/** Format: uuid */
			daemon_id: string;
			discovery_type: components['schemas']['DiscoveryType'];
			name: string;
			/** Format: uuid */
			network_id: string;
			run_type: components['schemas']['RunType'];
			tags: string[];
		};
		/**
		 * @description Request type for daemon discovery - accepts full entities with IDs.
		 *     Used internally by daemons for host creation/upsert, NOT the external API.
		 *     This supports the discovery workflow where daemons manage entity IDs.
		 */
		DiscoveryHostRequest: {
			host: components['schemas']['Host'];
			interfaces: components['schemas']['Interface'][];
			ports: components['schemas']['Port'][];
			services: components['schemas']['Service'][];
		};
		DiscoveryMetadata: components['schemas']['DiscoveryType'] & {
			/** Format: uuid */
			daemon_id: string;
			/** Format: date-time */
			date: string;
		};
		/** @enum {string} */
		DiscoveryPhase:
			| 'Pending'
			| 'Starting'
			| 'Started'
			| 'Scanning'
			| 'Complete'
			| 'Failed'
			| 'Cancelled';
		DiscoveryType:
			| {
					/** Format: uuid */
					host_id: string;
					/** @enum {string} */
					type: 'SelfReport';
			  }
			| {
					host_naming_fallback: components['schemas']['HostNamingFallback'];
					subnet_ids: string[] | null;
					/** @enum {string} */
					type: 'Network';
			  }
			| {
					/** Format: uuid */
					host_id: string;
					host_naming_fallback: components['schemas']['HostNamingFallback'];
					/** @enum {string} */
					type: 'Docker';
			  };
		/** @description Progress update from daemon to server during discovery */
		DiscoveryUpdatePayload: {
			/** Format: uuid */
			daemon_id: string;
			discovery_type: components['schemas']['DiscoveryType'];
			error?: string | null;
			/** Format: date-time */
			finished_at?: string | null;
			/** Format: uuid */
			network_id: string;
			phase: components['schemas']['DiscoveryPhase'];
			/** Format: int32 */
			progress: number;
			/** Format: uuid */
			session_id: string;
			/** Format: date-time */
			started_at?: string | null;
		};
		DockerVirtualization: {
			container_id?: string | null;
			container_name?: string | null;
			/** Format: uuid */
			service_id: string;
		};
		Edge: components['schemas']['EdgeType'] & {
			/** Format: uuid */
			id: string;
			is_multi_hop: boolean;
			label: string | null;
			/** Format: uuid */
			source: string;
			source_handle: components['schemas']['EdgeHandle'];
			/** Format: uuid */
			target: string;
			target_handle: components['schemas']['EdgeHandle'];
		};
		/** @enum {string} */
		EdgeHandle: 'Top' | 'Bottom' | 'Left' | 'Right';
		/** @enum {string} */
		EdgeStyle: 'Straight' | 'SmoothStep' | 'Step' | 'Bezier' | 'SimpleBezier';
		EdgeType:
			| {
					/** @enum {string} */
					edge_type: 'Interface';
					/** Format: uuid */
					host_id: string;
			  }
			| {
					/** @enum {string} */
					edge_type: 'HostVirtualization';
					/** Format: uuid */
					vm_service_id: string;
			  }
			| {
					/** Format: uuid */
					containerizing_service_id: string;
					/** @enum {string} */
					edge_type: 'ServiceVirtualization';
					/** Format: uuid */
					host_id: string;
			  }
			| {
					/** @enum {string} */
					edge_type: 'RequestPath';
					/** Format: uuid */
					group_id: string;
					/** Format: uuid */
					source_binding_id: string;
					/** Format: uuid */
					target_binding_id: string;
			  }
			| {
					/** @enum {string} */
					edge_type: 'HubAndSpoke';
					/** Format: uuid */
					group_id: string;
					/** Format: uuid */
					source_binding_id: string;
					/** Format: uuid */
					target_binding_id: string;
			  };
		/** @enum {string} */
		EdgeTypeDiscriminants:
			| 'Interface'
			| 'HostVirtualization'
			| 'ServiceVirtualization'
			| 'RequestPath'
			| 'HubAndSpoke';
		EntityMetadata: {
			color: components['schemas']['Color'];
			icon: string;
			id: string;
		};
		EntitySource:
			| {
					/** @enum {string} */
					type: 'Manual';
			  }
			| {
					/** @enum {string} */
					type: 'System';
			  }
			| {
					metadata: components['schemas']['DiscoveryMetadata'][];
					/** @enum {string} */
					type: 'Discovery';
			  }
			| {
					details: components['schemas']['MatchDetails'];
					metadata: components['schemas']['DiscoveryMetadata'][];
					/** @enum {string} */
					type: 'DiscoveryWithMatch';
			  }
			| {
					/** @enum {string} */
					type: 'Unknown';
			  };
		ForgotPasswordRequest: {
			/** Format: email */
			email: string;
		};
		/**
		 * @example {
		 *       "binding_ids": [],
		 *       "color": "Blue",
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "description": "HTTP/HTTPS services group",
		 *       "edge_style": "Bezier",
		 *       "group_type": "RequestPath",
		 *       "id": "550e8400-e29b-41d4-a716-446655440008",
		 *       "name": "Web Services",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "source": {
		 *         "type": "Manual"
		 *       },
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Group: components['schemas']['GroupBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		GroupBase: {
			/** @description Ordered list of binding IDs for this group. */
			binding_ids: string[];
			color: components['schemas']['Color'];
			description?: string | null;
			edge_style: components['schemas']['EdgeStyle'];
			group_type: components['schemas']['GroupType'];
			name: string;
			/** Format: uuid */
			network_id: string;
			/** @description Will be automatically set to Manual for creation through API */
			source?: components['schemas']['EntitySource'];
			tags: string[];
		};
		/** @enum {string} */
		GroupType: 'RequestPath' | 'HubAndSpoke';
		/**
		 * @example {
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "description": "Primary web server",
		 *       "hidden": false,
		 *       "hostname": "web-server-01.local",
		 *       "id": "550e8400-e29b-41d4-a716-446655440003",
		 *       "name": "web-server-01",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "source": {
		 *         "type": "Manual"
		 *       },
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z",
		 *       "virtualization": null
		 *     }
		 */
		Host: components['schemas']['HostBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		/**
		 * @description Base data for a Host entity (stored in database).
		 *     Child entities (interfaces, ports, services) are stored in their own tables
		 *     and queried by `host_id`. They are NOT stored on the host.
		 */
		HostBase: {
			description: string | null;
			hidden: boolean;
			hostname: string | null;
			name: string;
			/** Format: uuid */
			network_id: string;
			source: components['schemas']['EntitySource'];
			tags: string[];
			virtualization: null | components['schemas']['HostVirtualization'];
		};
		/** @enum {string} */
		HostNamingFallback: 'Ip' | 'BestService';
		/**
		 * @description Response type for host endpoints.
		 *     Includes hydrated children (interfaces, ports, services).
		 * @example {
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "description": "Primary web server",
		 *       "hidden": false,
		 *       "hostname": "web-server-01.local",
		 *       "id": "550e8400-e29b-41d4-a716-446655440003",
		 *       "interfaces": [
		 *         {
		 *           "created_at": "2026-01-15T10:30:00Z",
		 *           "host_id": "550e8400-e29b-41d4-a716-446655440003",
		 *           "id": "550e8400-e29b-41d4-a716-446655440005",
		 *           "ip_address": "192.168.1.100",
		 *           "mac_address": "DE:AD:BE:EF:12:34",
		 *           "name": "eth0",
		 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *           "subnet_id": "550e8400-e29b-41d4-a716-446655440004",
		 *           "updated_at": "2026-01-15T10:30:00Z"
		 *         }
		 *       ],
		 *       "name": "web-server-01",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "ports": [
		 *         {
		 *           "created_at": "2026-01-15T10:30:00Z",
		 *           "host_id": "550e8400-e29b-41d4-a716-446655440003",
		 *           "id": "550e8400-e29b-41d4-a716-446655440006",
		 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *           "number": 80,
		 *           "protocol": "Tcp",
		 *           "type": "Http",
		 *           "updated_at": "2026-01-15T10:30:00Z"
		 *         }
		 *       ],
		 *       "services": [],
		 *       "source": {
		 *         "type": "Manual"
		 *       },
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z",
		 *       "virtualization": null
		 *     }
		 */
		HostResponse: {
			/** Format: date-time */
			created_at: string;
			description?: string | null;
			hidden: boolean;
			hostname?: string | null;
			/** Format: uuid */
			id: string;
			interfaces: components['schemas']['Interface'][];
			name: string;
			/** Format: uuid */
			network_id: string;
			ports: components['schemas']['Port'][];
			services: components['schemas']['Service'][];
			source: components['schemas']['EntitySource'];
			tags: string[];
			/** Format: date-time */
			updated_at: string;
			virtualization?: null | components['schemas']['HostVirtualization'];
		};
		/** HostVirtualization */
		HostVirtualization: {
			details: components['schemas']['ProxmoxVirtualization'];
			/** @enum {string} */
			type: 'Proxmox';
		};
		/**
		 * @example {
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
		 *       "id": "550e8400-e29b-41d4-a716-446655440005",
		 *       "ip_address": "192.168.1.100",
		 *       "mac_address": "DE:AD:BE:EF:12:34",
		 *       "name": "eth0",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "subnet_id": "550e8400-e29b-41d4-a716-446655440004",
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Interface: components['schemas']['InterfaceBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		InterfaceBase: {
			/** Format: uuid */
			host_id: string;
			ip_address: string;
			mac_address: string | null;
			name: string | null;
			/** Format: uuid */
			network_id: string;
			/** Format: uuid */
			subnet_id: string;
		};
		Invite: components['schemas']['InviteBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		InviteBase: {
			/** Format: uuid */
			created_by: string;
			/** Format: date-time */
			expires_at: string;
			network_ids: string[];
			/** Format: uuid */
			organization_id: string;
			permissions: components['schemas']['UserOrgPermissions'];
			/** @description Optional email address to send the invite to */
			send_to: string | null;
			url: string;
		};
		Ixy: {
			x: number;
			y: number;
		};
		/** @description Login request from client */
		LoginRequest: {
			/** Format: email */
			email: string;
			password: string;
		};
		/** @enum {string} */
		MatchConfidence: 'NotApplicable' | 'Low' | 'Medium' | 'High' | 'Certain';
		MatchDetails: {
			confidence: components['schemas']['MatchConfidence'];
			reason: components['schemas']['MatchReason'];
		};
		/** @description Match reason - either a simple reason string or a container with nested reasons */
		MatchReason:
			| {
					data: string;
					/** @enum {string} */
					type: 'reason';
			  }
			| {
					/** @description Tuple of [name: string, children: MatchReason[]] */
					data: unknown[];
					/** @enum {string} */
					type: 'container';
			  };
		MetadataRegistry: {
			billing_plans: components['schemas']['TypeMetadata'][];
			concepts: components['schemas']['EntityMetadata'][];
			discovery_types: components['schemas']['TypeMetadata'][];
			edge_types: components['schemas']['TypeMetadata'][];
			entities: components['schemas']['EntityMetadata'][];
			features: components['schemas']['TypeMetadata'][];
			group_types: components['schemas']['TypeMetadata'][];
			permissions: components['schemas']['TypeMetadata'][];
			ports: components['schemas']['TypeMetadata'][];
			service_definitions: components['schemas']['TypeMetadata'][];
			subnet_types: components['schemas']['TypeMetadata'][];
		};
		/**
		 * @example {
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "name": "Home Network",
		 *       "organization_id": "550e8400-e29b-41d4-a716-446655440001",
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Network: components['schemas']['NetworkBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		NetworkBase: {
			name: string;
			/** Format: uuid */
			organization_id: string;
			tags: string[];
		};
		/** @description Network configuration for setup */
		NetworkSetup: {
			name: string;
		};
		Node: components['schemas']['NodeType'] & {
			header?: string | null;
			/** Format: uuid */
			id: string;
			position: components['schemas']['Ixy'];
			size: components['schemas']['Uxy'];
		};
		NodeType:
			| {
					infra_width: number;
					/** @enum {string} */
					node_type: 'SubnetNode';
			  }
			| {
					/** Format: uuid */
					host_id: string;
					/** Format: uuid */
					interface_id?: string | null;
					is_infra: boolean;
					/** @enum {string} */
					node_type: 'InterfaceNode';
					/** Format: uuid */
					subnet_id: string;
			  };
		OidcProviderMetadata: {
			logo?: string | null;
			name: string;
			slug: string;
		};
		Organization: components['schemas']['OrganizationBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		OrganizationBase: {
			name: string;
			onboarding: components['schemas']['TelemetryOperation'][];
			plan: null | components['schemas']['BillingPlan'];
			readonly plan_status: string | null;
		};
		PlanConfig: {
			/** Format: int64 */
			base_cents: number;
			/** Format: int64 */
			included_networks?: number | null;
			/** Format: int64 */
			included_seats?: number | null;
			/** Format: int64 */
			network_cents?: number | null;
			rate: components['schemas']['BillingRate'];
			/** Format: int64 */
			seat_cents?: number | null;
			/** Format: int32 */
			trial_days: number;
		};
		/**
		 * @description Port entity with custom serialization that flattens PortType fields.
		 * @example {
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
		 *       "id": "550e8400-e29b-41d4-a716-446655440006",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "number": 80,
		 *       "protocol": "Tcp",
		 *       "type": "Http",
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Port: components['schemas']['PortBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		/** @description The base data for a Port entity (everything except id, created_at, updated_at) */
		PortBase: components['schemas']['PortType'] & {
			/** Format: uuid */
			host_id: string;
			/** Format: uuid */
			network_id: string;
		};
		/** @description Port type with number, protocol, and optional type identifier */
		PortType: {
			number: number;
			/** @enum {string} */
			protocol: 'Udp' | 'Tcp';
			/** @description Auto-derived from number+protocol; optional on create */
			type?: string;
		};
		ProxmoxVirtualization: {
			/** Format: uuid */
			service_id: string;
			vm_id?: string | null;
			vm_name?: string | null;
		};
		PublicConfigResponse: {
			billing_enabled: boolean;
			deployment_type: components['schemas']['DeploymentType'];
			disable_registration: boolean;
			has_email_opt_in: boolean;
			has_email_service: boolean;
			has_integrated_daemon: boolean;
			needs_cookie_consent: boolean;
			oidc_providers: components['schemas']['OidcProviderMetadata'][];
			plunk_key?: string | null;
			posthog_key?: string | null;
			public_url: string;
			/** Format: int32 */
			server_port: number;
		};
		/** @description Public share metadata (returned without authentication) */
		PublicShareMetadata: {
			/** Format: uuid */
			id: string;
			name: string;
			options: components['schemas']['ShareOptions'];
			requires_password: boolean;
		};
		/** @description Registration request from client */
		RegisterRequest: {
			/** Format: email */
			email: string;
			password: string;
			terms_accepted: boolean;
		};
		ResetPasswordRequest: {
			password: string;
			token: string;
		};
		RunType:
			| {
					cron_schedule: string;
					enabled: boolean;
					/** Format: date-time */
					readonly last_run?: string | null;
					/** @enum {string} */
					type: 'Scheduled';
			  }
			| {
					results: components['schemas']['DiscoveryUpdatePayload'];
					/** @enum {string} */
					type: 'Historical';
			  }
			| {
					/** Format: date-time */
					readonly last_run?: string | null;
					/** @enum {string} */
					type: 'AdHoc';
			  };
		/**
		 * @example {
		 *       "bindings": [
		 *         {
		 *           "created_at": "2025-12-27T04:06:57.099859Z",
		 *           "id": "8575863f-6058-4824-a668-4e5f741e7ddf",
		 *           "interface_id": "550e8400-e29b-41d4-a716-446655440005",
		 *           "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *           "port_id": "550e8400-e29b-41d4-a716-446655440006",
		 *           "service_id": "550e8400-e29b-41d4-a716-446655440007",
		 *           "type": "Port",
		 *           "updated_at": "2025-12-27T04:06:57.099859Z"
		 *         }
		 *       ],
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "host_id": "550e8400-e29b-41d4-a716-446655440003",
		 *       "id": "550e8400-e29b-41d4-a716-446655440007",
		 *       "name": "nginx",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "service_definition": "Bitwarden",
		 *       "source": {
		 *         "type": "Manual"
		 *       },
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z",
		 *       "virtualization": null
		 *     }
		 */
		Service: components['schemas']['ServiceBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		ServiceBase: {
			bindings: components['schemas']['Binding'][];
			/** Format: uuid */
			host_id: string;
			name: string;
			/** Format: uuid */
			network_id: string;
			service_definition: string;
			/** @description Will be automatically set to Manual for creation through API */
			source: components['schemas']['EntitySource'];
			tags: string[];
			virtualization?: null | components['schemas']['ServiceVirtualization'];
		};
		/** @enum {string} */
		ServiceCategory:
			| 'NetworkCore'
			| 'NetworkAccess'
			| 'NetworkSecurity'
			| 'Storage'
			| 'Backup'
			| 'Media'
			| 'HomeAutomation'
			| 'Virtualization'
			| 'DNS'
			| 'VPN'
			| 'Monitoring'
			| 'AdBlock'
			| 'ReverseProxy'
			| 'Workstation'
			| 'Mobile'
			| 'IoT'
			| 'Printer'
			| 'Database'
			| 'Development'
			| 'Dashboard'
			| 'MessageQueue'
			| 'IdentityAndAccess'
			| 'Office'
			| 'ProjectManagement'
			| 'Messaging'
			| 'Conferencing'
			| 'Telephony'
			| 'Email'
			| 'Publishing'
			| 'Unknown'
			| 'Custom'
			| 'Scanopy'
			| 'OpenPorts';
		/** ServiceVirtualization */
		ServiceVirtualization: {
			details: components['schemas']['DockerVirtualization'];
			/** @enum {string} */
			type: 'Docker';
		};
		/** @description Setup request for pre-registration org/network configuration */
		SetupRequest: {
			networks: components['schemas']['NetworkSetup'][];
			organization_name: string;
		};
		/** @description Response from setup endpoint */
		SetupResponse: {
			network_ids: string[];
		};
		Share: components['schemas']['ShareBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		ShareBase: {
			allowed_domains: string[] | null;
			/** Format: uuid */
			created_by: string;
			/** Format: date-time */
			expires_at: string | null;
			is_enabled: boolean;
			name: string;
			/** Format: uuid */
			network_id: string;
			options: components['schemas']['ShareOptions'];
			/** Format: uuid */
			topology_id: string;
		};
		/** @description Share display options */
		ShareOptions: {
			show_export_button: boolean;
			show_inspect_panel: boolean;
			show_zoom_controls: boolean;
		};
		/**
		 * @example {
		 *       "cidr": "192.168.1.0/24",
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "description": "Local area network",
		 *       "id": "550e8400-e29b-41d4-a716-446655440004",
		 *       "name": "LAN",
		 *       "network_id": "550e8400-e29b-41d4-a716-446655440002",
		 *       "source": {
		 *         "type": "Manual"
		 *       },
		 *       "subnet_type": "Lan",
		 *       "tags": [],
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Subnet: components['schemas']['SubnetBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		SubnetBase: {
			cidr: string;
			description?: string | null;
			name: string;
			/** Format: uuid */
			network_id: string;
			/** @description Will be automatically set to Manual for creation through API */
			source: components['schemas']['EntitySource'];
			subnet_type: components['schemas']['SubnetType'];
			tags: string[];
		};
		/** @enum {string} */
		SubnetType:
			| 'Internet'
			| 'Remote'
			| 'Gateway'
			| 'VpnTunnel'
			| 'Dmz'
			| 'Lan'
			| 'WiFi'
			| 'IoT'
			| 'Guest'
			| 'DockerBridge'
			| 'Management'
			| 'Storage'
			| 'Unknown'
			| 'None';
		/**
		 * @example {
		 *       "color": "Green",
		 *       "created_at": "2026-01-15T10:30:00Z",
		 *       "description": "Production environment resources",
		 *       "id": "550e8400-e29b-41d4-a716-44665544000a",
		 *       "name": "production",
		 *       "organization_id": "550e8400-e29b-41d4-a716-446655440001",
		 *       "updated_at": "2026-01-15T10:30:00Z"
		 *     }
		 */
		Tag: components['schemas']['TagBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		TagBase: {
			color: components['schemas']['Color'];
			description?: string | null;
			name: string;
			/** Format: uuid */
			organization_id: string;
		};
		/** @enum {string} */
		TelemetryOperation:
			| 'OrgCreated'
			| 'OnboardingModalCompleted'
			| 'PersonalPlanSelected'
			| 'CommercialPlanSelected'
			| 'FirstApiKeyCreated'
			| 'FirstDaemonRegistered'
			| 'FirstTopologyRebuild';
		Topology: components['schemas']['TopologyBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		TopologyBase: {
			bindings: components['schemas']['Binding'][];
			edges: components['schemas']['Edge'][];
			groups: components['schemas']['Group'][];
			hosts: components['schemas']['Host'][];
			interfaces: components['schemas']['Interface'][];
			is_locked: boolean;
			is_stale: boolean;
			/** Format: date-time */
			last_refreshed: string;
			/** Format: date-time */
			locked_at?: string | null;
			/** Format: uuid */
			locked_by?: string | null;
			name: string;
			/** Format: uuid */
			network_id: string;
			nodes: components['schemas']['Node'][];
			options: components['schemas']['TopologyOptions'];
			/** Format: uuid */
			parent_id?: string | null;
			ports: components['schemas']['Port'][];
			removed_bindings: string[];
			removed_groups: string[];
			removed_hosts: string[];
			removed_interfaces: string[];
			removed_ports: string[];
			removed_services: string[];
			removed_subnets: string[];
			services: components['schemas']['Service'][];
			subnets: components['schemas']['Subnet'][];
			tags: string[];
		};
		TopologyLocalOptions: {
			hide_edge_types: components['schemas']['EdgeTypeDiscriminants'][];
			hide_resize_handles: boolean;
			left_zone_title: string;
			no_fade_edges: boolean;
		};
		TopologyOptions: {
			local: components['schemas']['TopologyLocalOptions'];
			request: components['schemas']['TopologyRequestOptions'];
		};
		TopologyRequestOptions: {
			group_docker_bridges_by_host: boolean;
			hide_ports: boolean;
			hide_service_categories: components['schemas']['ServiceCategory'][];
			hide_vm_title_on_docker_container: boolean;
			left_zone_service_categories: components['schemas']['ServiceCategory'][];
			show_gateway_in_left_zone: boolean;
		};
		/** @enum {string} */
		TransportProtocol: 'Udp' | 'Tcp';
		TypeMetadata: {
			category?: string | null;
			color: components['schemas']['Color'];
			description?: string | null;
			icon?: string | null;
			id: string;
			metadata?: unknown;
			name?: string | null;
		};
		UpdateEmailPasswordRequest: {
			/** Format: email */
			email?: string | null;
			password?: string | null;
		};
		/**
		 * @description Request type for updating a host.
		 *     Optionally includes interfaces and ports to sync (create/update/delete).
		 */
		UpdateHostRequest: {
			description?: string | null;
			/**
			 * Format: date-time
			 * @description Optional: expected updated_at timestamp for optimistic locking.
			 *     If provided, the update will fail with a conflict error if the host
			 *     has been modified since this timestamp (e.g., by discovery running
			 *     while the user was editing).
			 */
			expected_updated_at?: string | null;
			hidden: boolean;
			hostname?: string | null;
			/** Format: uuid */
			id: string;
			/**
			 * @description Optional: interfaces to sync with this host.
			 *     If provided, the server will:
			 *     - Create interfaces without an `id` (or with nil UUID)
			 *     - Keep/update interfaces with matching `id`
			 *     - Delete existing interfaces not in this list
			 *     If not provided (None), interfaces are left unchanged.
			 */
			interfaces?: components['schemas']['UpdateInterfaceInput'][] | null;
			name: string;
			/**
			 * @description Optional: ports to sync with this host.
			 *     If provided, the server will:
			 *     - Create ports without an `id` (or with nil UUID)
			 *     - Keep/update ports with matching `id`
			 *     - Delete existing ports not in this list
			 *     If not provided (None), ports are left unchanged.
			 */
			ports?: components['schemas']['UpdatePortInput'][] | null;
			tags: string[];
			virtualization?: null | components['schemas']['HostVirtualization'];
		};
		/**
		 * @description Input for syncing an interface during host update.
		 *     If `id` is None or nil UUID, a new interface is created.
		 *     If `id` matches an existing interface, it is updated.
		 */
		UpdateInterfaceInput: {
			/**
			 * Format: uuid
			 * @description ID of existing interface to update, or None/nil for new interface
			 */
			id?: string | null;
			ip_address: string;
			mac_address?: string | null;
			name?: string | null;
			/** Format: uuid */
			subnet_id: string;
		};
		/**
		 * @description Input for syncing a port during host update.
		 *     If `id` is None or nil UUID, a new port is created.
		 *     If `id` matches an existing port, it is kept.
		 */
		UpdatePortInput: {
			/**
			 * Format: uuid
			 * @description ID of existing port to keep, or None/nil for new port
			 */
			id?: string | null;
			/**
			 * Format: int32
			 * @description Port number (1-65535)
			 */
			number: number;
			/** @description Transport protocol (Tcp or Udp) */
			protocol: components['schemas']['TransportProtocol'];
		};
		User: components['schemas']['UserBase'] & {
			/** Format: date-time */
			readonly created_at: string;
			/** Format: uuid */
			readonly id: string;
			/** Format: date-time */
			readonly updated_at: string;
		};
		UserBase: {
			email: string;
			network_ids: string[];
			/** Format: date-time */
			oidc_linked_at?: string | null;
			oidc_provider?: string | null;
			oidc_subject?: string | null;
			/** Format: uuid */
			organization_id: string;
			permissions: components['schemas']['UserOrgPermissions'];
			/** Format: date-time */
			readonly terms_accepted_at?: string | null;
		};
		/** @enum {string} */
		UserOrgPermissions: 'Owner' | 'Admin' | 'Member' | 'Viewer';
		Uxy: {
			x: number;
			y: number;
		};
	};
	responses: never;
	parameters: never;
	requestBodies: never;
	headers: never;
	pathItems: never;
}
export type $defs = Record<string, never>;
export interface operations {
	daemon_setup: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DaemonSetupRequest'];
			};
		};
		responses: {
			/** @description Daemon setup data stored */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_DaemonSetupResponse'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	forgot_password: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['ForgotPasswordRequest'];
			};
		};
		responses: {
			/** @description Password reset email sent */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	list_api_keys: {
		parameters: {
			query?: {
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of api_keys */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_ApiKey'];
				};
			};
		};
	};
	create_api_key: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['ApiKey'];
			};
		};
		responses: {
			/** @description API key created */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_ApiKeyResponse'];
				};
			};
			/** @description Bad request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Insufficient permissions (admin+ required) */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Internal server error */
			500: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_api_keys: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of api_keys IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description ApiKeys deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_api_key_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description ApiKey ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description ApiKey found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_ApiKey'];
				};
			};
			/** @description ApiKey not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_api_key: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description API key ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['ApiKey'];
			};
		};
		responses: {
			/** @description API key updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_ApiKey'];
				};
			};
			/** @description API key not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_api_key: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description ApiKey ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description ApiKey deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description ApiKey not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	rotate_key_handler: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description API key ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description API key rotated, returns new key */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_String'];
				};
			};
			/** @description API key not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	login: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['LoginRequest'];
			};
		};
		responses: {
			/** @description Login successful */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Invalid credentials */
			401: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Login forbidden */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	logout: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Logout successful */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	get_current_user: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Current user */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Not authenticated */
			401: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	unlink_oidc_account: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description OIDC provider slug */
				slug: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description OIDC account unlinked */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Not authenticated */
			401: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Blocked in demo mode */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Provider not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	register: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['RegisterRequest'];
			};
		};
		responses: {
			/** @description User registered successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Registration disabled */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Email already exists */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	reset_password: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['ResetPasswordRequest'];
			};
		};
		responses: {
			/** @description Password reset successful */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Invalid or expired token */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	setup: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['SetupRequest'];
			};
		};
		responses: {
			/** @description Setup data stored */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_SetupResponse'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_password_auth: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['UpdateEmailPasswordRequest'];
			};
		};
		responses: {
			/** @description Password updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Not authenticated */
			401: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Blocked in demo mode */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	create_checkout_session: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateCheckoutRequest'];
			};
		};
		responses: {
			/** @description Checkout session URL */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_String'];
				};
			};
			/** @description Invalid plan or billing not enabled */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_billing_plans: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of available billing plans */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_BillingPlan'];
				};
			};
			/** @description Billing not enabled */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	create_portal_session: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'text/plain': string;
			};
		};
		responses: {
			/** @description Portal session URL */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_String'];
				};
			};
			/** @description Billing not enabled */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	handle_webhook: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Webhook processed */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Invalid signature or billing not enabled */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_bindings: {
		parameters: {
			query?: {
				/** @description Filter by service ID */
				service_id?: string | null;
				/** @description Filter by network ID */
				network_id?: string | null;
				/** @description Filter by port ID */
				port_id?: string | null;
				/** @description Filter by interface ID */
				interface_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of bindings */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Binding'];
				};
			};
		};
	};
	create_binding: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Binding'];
			};
		};
		responses: {
			/** @description Binding created (superseded bindings may be removed) */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Binding'];
				};
			};
			/** @description Referenced port or interface does not exist */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Conflict with existing binding type */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_bindings: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of bindings IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Bindings deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_binding_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Binding ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Binding found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Binding'];
				};
			};
			/** @description Binding not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_binding: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Binding ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Binding'];
			};
		};
		responses: {
			/** @description Binding updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Binding'];
				};
			};
			/** @description Referenced port or interface does not exist */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Conflict with existing binding type */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_binding: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Binding ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Binding deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Binding not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_public_config: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Public server configuration */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_PublicConfigResponse'];
				};
			};
		};
	};
	list_daemons: {
		parameters: {
			query?: {
				/** @description Filter by host ID */
				host_id?: string | null;
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of daemons */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Daemon'];
				};
			};
		};
	};
	bulk_delete_daemons: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of daemons IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Daemons deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	register_daemon: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DaemonRegistrationRequest'];
			};
		};
		responses: {
			/** @description Daemon registered successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_DaemonRegistrationResponse'];
				};
			};
			/** @description Daemon registration disabled in demo mode */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_daemon_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Daemon ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Daemon found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Daemon'];
				};
			};
			/** @description Daemon not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_daemon: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Daemon ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Daemon deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Daemon not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	receive_heartbeat: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Daemon ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DaemonHeartbeatPayload'];
			};
		};
		responses: {
			/** @description Heartbeat received */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Daemon not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	receive_work_request: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Daemon ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DaemonHeartbeatPayload'];
			};
		};
		responses: {
			/** @description Work request processed - returns (Option<DiscoveryUpdatePayload>, bool) */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content?: never;
			};
			/** @description Daemon not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_capabilities: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Daemon ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DaemonCapabilities'];
			};
		};
		responses: {
			/** @description Capabilities updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Daemon not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_discoveries: {
		parameters: {
			query?: {
				/** @description Filter by network ID */
				network_id?: string | null;
				/** @description Filter by daemon ID */
				daemon_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of discoveries */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Discovery'];
				};
			};
		};
	};
	create_discovery: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Discovery'];
			};
		};
		responses: {
			/** @description Discovery created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Discovery'];
				};
			};
			/** @description Can't create historical discovery */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_active_sessions: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of active discovery sessions */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_DiscoveryUpdatePayload'];
				};
			};
		};
	};
	bulk_delete_discoveries: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of discoveries IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Discoverys deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	start_session: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'text/plain': string;
			};
		};
		responses: {
			/** @description Discovery session started */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_DiscoveryUpdatePayload'];
				};
			};
			/** @description Discovery not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_discovery_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Discovery ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Discovery found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Discovery'];
				};
			};
			/** @description Discovery not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_discovery: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Discovery ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Discovery'];
			};
		};
		responses: {
			/** @description Discovery updated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Discovery'];
				};
			};
			/** @description Can't update historical discovery */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_discovery: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Discovery ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Discovery deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Discovery not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	cancel_discovery: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Session ID */
				session_id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Discovery session cancelled */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	receive_discovery_update: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Discovery session ID */
				session_id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DiscoveryUpdatePayload'];
			};
		};
		responses: {
			/** @description Update received */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	get_stars: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description GitHub star count */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_u32'];
				};
			};
		};
	};
	list_groups: {
		parameters: {
			query?: {
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of groups */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Group'];
				};
			};
		};
	};
	create_group: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Group'];
			};
		};
		responses: {
			/** @description Group created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Group'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_groups: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of groups IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Groups deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_group_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Group ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Group found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Group'];
				};
			};
			/** @description Group not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_group: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Group ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Group'];
			};
		};
		responses: {
			/** @description Group updated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Group'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Group not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_group: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Group ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Group deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Group not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_all_hosts: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of hosts with their children */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_HostResponse'];
				};
			};
		};
	};
	create_host: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateHostRequest'];
			};
		};
		responses: {
			/** @description Host created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_HostResponse'];
				};
			};
			/** @description Invalid request - network not found or subnet mismatch */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_hosts: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of host IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Hosts deleted successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
			/** @description One or more hosts has an associated daemon - delete daemons first */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	create_host_discovery: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['DiscoveryHostRequest'];
			};
		};
		responses: {
			/** @description Host discovered/updated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_HostResponse'];
				};
			};
			/** @description Daemon cannot create hosts on other networks */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	consolidate_hosts: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Destination host ID - will receive all children */
				destination_host: string;
				/** @description Host to merge into destination - will be deleted */
				other_host: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Hosts consolidated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_HostResponse'];
				};
			};
			/** @description Validation error: same host, has daemon, or different networks */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description One or both hosts not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_host_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Host ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Host found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_HostResponse'];
				};
			};
			/** @description Host not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_host: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Host ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['UpdateHostRequest'];
			};
		};
		responses: {
			/** @description Host updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_HostResponse'];
				};
			};
			/** @description Host not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_host: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Host ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Host deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Host not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Host has associated daemon */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_interfaces: {
		parameters: {
			query?: {
				/** @description Filter by host ID */
				host_id?: string | null;
				/** @description Filter by subnet ID */
				subnet_id?: string | null;
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of interfaces */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Interface'];
				};
			};
		};
	};
	create_interface: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Interface'];
			};
		};
		responses: {
			/** @description Interface created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Interface'];
				};
			};
			/** @description Network mismatch or invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_interfaces: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of interfaces IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Interfaces deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_interface_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Interface ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Interface found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Interface'];
				};
			};
			/** @description Interface not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_interface: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Interface ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Interface'];
			};
		};
		responses: {
			/** @description Interface updated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Interface'];
				};
			};
			/** @description Network mismatch or invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Interface not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_interface: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Interface ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Interface deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Interface not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_invites: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of active invites */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Invite'];
				};
			};
		};
	};
	create_invite: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateInviteRequest'];
			};
		};
		responses: {
			/** @description Invite created */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Invite'];
				};
			};
			/** @description Cannot create invite with higher permissions */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_invite: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Invite ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Invite details */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Invite'];
				};
			};
			/** @description Invalid or expired invite */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	revoke_invite: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Invite ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Invite revoked */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Invalid invite */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Cannot revoke this invite */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_metadata_registry: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Metadata registry */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_MetadataRegistry'];
				};
			};
		};
	};
	list_networks: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of networks */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Network'];
				};
			};
		};
	};
	create_network: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Network'];
			};
		};
		responses: {
			/** @description Network created */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Network'];
				};
			};
		};
	};
	bulk_delete_networks: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of network IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Networks deleted successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
			/** @description User not admin */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_network_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Network ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Network found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Network'];
				};
			};
			/** @description Network not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_network: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Network ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Network'];
			};
		};
		responses: {
			/** @description Network updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Network'];
				};
			};
			/** @description User not admin */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Network not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_network: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Network ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Network deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description User not admin */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Network not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_organization: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Organization details */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Organization'];
				};
			};
			/** @description Organization not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_org_name: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Organization ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'text/plain': string;
			};
		};
		responses: {
			/** @description Organization updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Organization'];
				};
			};
			/** @description Only owners can update organization */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Organization not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	populate_demo_data: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Organization ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Demo data populated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Only available for demo organizations */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Organization not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	reset: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Organization ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Organization reset */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Cannot reset another organization */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Organization not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_ports: {
		parameters: {
			query?: {
				/** @description Filter by host ID */
				host_id?: string | null;
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of ports */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Port'];
				};
			};
		};
	};
	create_port: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Port'];
			};
		};
		responses: {
			/** @description Port created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Port'];
				};
			};
			/** @description Network mismatch or duplicate port */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_ports: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of ports IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Ports deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_port_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Port ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Port found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Port'];
				};
			};
			/** @description Port not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_port: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Port ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Port'];
			};
		};
		responses: {
			/** @description Port updated successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Port'];
				};
			};
			/** @description Network mismatch or invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Port not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_port: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Port ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Port deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Port not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_services: {
		parameters: {
			query?: {
				/** @description Filter by host ID */
				host_id?: string | null;
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of services */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Service'];
				};
			};
		};
	};
	create_service: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateServiceRequest'];
			};
		};
		responses: {
			/** @description Service created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Service'];
				};
			};
			/** @description Validation error: host network mismatch, cross-host binding, or binding conflict */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_services: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of services IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Services deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_service_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Service ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Service found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Service'];
				};
			};
			/** @description Service not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_service: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Service ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Service'];
			};
		};
		responses: {
			/** @description Service updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Service'];
				};
			};
			/** @description Validation error: host network mismatch, cross-host binding, or binding conflict */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Service not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_service: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Service ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Service deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Service not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_shares: {
		parameters: {
			query?: {
				/** @description Filter by network ID */
				network_id?: string | null;
				/** @description Filter by topology ID */
				topology_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of shares */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Share'];
				};
			};
		};
	};
	create_share: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateUpdateShareRequest'];
			};
		};
		responses: {
			/** @description Share created */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Share'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_shares: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of shares IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Shares deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_public_share_metadata: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Share ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Share metadata */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_PublicShareMetadata'];
				};
			};
			/** @description Share not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	verify_share_password: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Share ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'text/plain': string;
			};
		};
		responses: {
			/** @description Password verified */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_bool'];
				};
			};
			/** @description Invalid password */
			401: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Share not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_share_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Share ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Share found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Share'];
				};
			};
			/** @description Share not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_share: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Share ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['CreateUpdateShareRequest'];
			};
		};
		responses: {
			/** @description Share updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Share'];
				};
			};
			/** @description Share not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_share: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Share ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Share deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Share not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_subnets: {
		parameters: {
			query?: {
				/** @description Filter by network ID */
				network_id?: string | null;
			};
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of subnets */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Subnet'];
				};
			};
		};
	};
	create_subnet: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Subnet'];
			};
		};
		responses: {
			/** @description Subnet created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Subnet'];
				};
			};
			/** @description Invalid request */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_subnets: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of subnets IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Subnets deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_subnet_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Subnet ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Subnet found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Subnet'];
				};
			};
			/** @description Subnet not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_subnet: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Subnet ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Subnet'];
			};
		};
		responses: {
			/** @description Subnet updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Subnet'];
				};
			};
			/** @description CIDR change would orphan existing interfaces */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Subnet not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_subnet: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Subnet ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Subnet deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Subnet not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	list_tags: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of tags */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Tag'];
				};
			};
		};
	};
	create_tag: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Tag'];
			};
		};
		responses: {
			/** @description Tag created successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Tag'];
				};
			};
			/** @description Tag name already exists */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	bulk_delete_tags: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of tags IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Tags deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
		};
	};
	get_tag_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Tag ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Tag found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Tag'];
				};
			};
			/** @description Tag not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_tag: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Tag ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Tag'];
			};
		};
		responses: {
			/** @description Tag updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Tag'];
				};
			};
			/** @description Tag not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_tag: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Tag ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Tag deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Tag not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_all_topologies: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of topologies */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_Topology'];
				};
			};
		};
	};
	create_topology: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology created */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Topology'];
				};
			};
			/** @description Validation failed */
			400: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_topology_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Topology found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Topology'];
				};
			};
			/** @description Topology not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_topology: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Topology'];
				};
			};
			/** @description Topology not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_topology: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description Topology deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Topology not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	lock: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology locked */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Topology'];
				};
			};
		};
	};
	rebuild: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology rebuilt */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	refresh: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology refreshed */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
		};
	};
	unlock: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description Topology ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['Topology'];
			};
		};
		responses: {
			/** @description Topology unlocked */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Topology'];
				};
			};
		};
	};
	get_all_users: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description List of users */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_Vec_User'];
				};
			};
		};
	};
	bulk_delete_users: {
		parameters: {
			query?: never;
			header?: never;
			path?: never;
			cookie?: never;
		};
		/** @description Array of user IDs to delete */
		requestBody: {
			content: {
				'application/json': string[];
			};
		};
		responses: {
			/** @description Users deleted successfully */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_BulkDeleteResponse'];
				};
			};
			/** @description Cannot delete users with higher permissions */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	get_user_by_id: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description User ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description User found */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description User not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	update_user: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description User ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['User'];
			};
		};
		responses: {
			/** @description User updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Cannot update another user's record */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description User not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	delete_user: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description User ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody?: never;
		responses: {
			/** @description User deleted */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse'];
				};
			};
			/** @description Cannot delete user with higher permissions */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description User not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description Cannot delete the only owner */
			409: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
	admin_update_user: {
		parameters: {
			query?: never;
			header?: never;
			path: {
				/** @description User ID */
				id: string;
			};
			cookie?: never;
		};
		requestBody: {
			content: {
				'application/json': components['schemas']['User'];
			};
		};
		responses: {
			/** @description User updated */
			200: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiResponse_User'];
				};
			};
			/** @description Cannot update user with higher permissions */
			403: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
			/** @description User not found */
			404: {
				headers: {
					[name: string]: unknown;
				};
				content: {
					'application/json': components['schemas']['ApiErrorResponse'];
				};
			};
		};
	};
}
