--
-- PostgreSQL database dump
--

\restrict eBSnQ02bTJJqBWf84vAslrtSFRhVu7kiaRFTHpaqJGK3AZClXEDcKsrVWzI35Hs

-- Dumped from database version 17.7
-- Dumped by pg_dump version 17.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_organization;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_organizations_stripe_customer;
DROP INDEX IF EXISTS public.idx_networks_owner_organization;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_discovery_network;
DROP INDEX IF EXISTS public.idx_discovery_daemon;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
DROP INDEX IF EXISTS public.idx_api_keys_network;
DROP INDEX IF EXISTS public.idx_api_keys_key;
ALTER TABLE IF EXISTS ONLY tower_sessions.session DROP CONSTRAINT IF EXISTS session_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_pkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_pkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_key_key;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS tower_sessions.session;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.organizations;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.groups;
DROP TABLE IF EXISTS public.discovery;
DROP TABLE IF EXISTS public.daemons;
DROP TABLE IF EXISTS public.api_keys;
DROP TABLE IF EXISTS public._sqlx_migrations;
DROP SCHEMA IF EXISTS tower_sessions;
--
-- Name: tower_sessions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tower_sessions;


ALTER SCHEMA tower_sessions OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _sqlx_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._sqlx_migrations (
    version bigint NOT NULL,
    description text NOT NULL,
    installed_on timestamp with time zone DEFAULT now() NOT NULL,
    success boolean NOT NULL,
    checksum bytea NOT NULL,
    execution_time bigint NOT NULL
);


ALTER TABLE public._sqlx_migrations OWNER TO postgres;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_keys (
    id uuid NOT NULL,
    key text NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used timestamp with time zone,
    expires_at timestamp with time zone,
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.api_keys OWNER TO postgres;

--
-- Name: daemons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daemons (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    ip text NOT NULL,
    port integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text
);


ALTER TABLE public.daemons OWNER TO postgres;

--
-- Name: discovery; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.discovery (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    daemon_id uuid NOT NULL,
    run_type jsonb NOT NULL,
    discovery_type jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.discovery OWNER TO postgres;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    group_type jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    source jsonb NOT NULL,
    color text NOT NULL,
    edge_style text DEFAULT '"SmoothStep"'::text
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: hosts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hosts (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    hostname text,
    description text,
    target jsonb NOT NULL,
    interfaces jsonb,
    services jsonb,
    ports jsonb,
    source jsonb NOT NULL,
    virtualization jsonb,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    hidden boolean DEFAULT false
);


ALTER TABLE public.hosts OWNER TO postgres;

--
-- Name: networks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.networks (
    id uuid NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_default boolean NOT NULL,
    organization_id uuid NOT NULL
);


ALTER TABLE public.networks OWNER TO postgres;

--
-- Name: COLUMN networks.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.networks.organization_id IS 'The organization that owns and pays for this network';


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    stripe_customer_id text,
    plan jsonb NOT NULL,
    plan_status text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_onboarded boolean
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: TABLE organizations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organizations IS 'Organizations that own networks and have Stripe subscriptions';


--
-- Name: COLUMN organizations.plan; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.plan IS 'The current billing plan for the organization (e.g., Community, Pro)';


--
-- Name: services; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.services (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    host_id uuid NOT NULL,
    bindings jsonb,
    service_definition text NOT NULL,
    virtualization jsonb,
    source jsonb NOT NULL
);


ALTER TABLE public.services OWNER TO postgres;

--
-- Name: subnets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subnets (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    cidr text NOT NULL,
    name text NOT NULL,
    description text,
    subnet_type text NOT NULL,
    source jsonb NOT NULL
);


ALTER TABLE public.subnets OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    password_hash text,
    oidc_provider text,
    oidc_subject text,
    oidc_linked_at timestamp with time zone,
    email text NOT NULL,
    organization_id uuid NOT NULL,
    permissions text DEFAULT 'Member'::text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.organization_id IS 'The single organization this user belongs to';


--
-- Name: COLUMN users.permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.permissions IS 'User role within their organization: Owner, Member, Viewer';


--
-- Name: session; Type: TABLE; Schema: tower_sessions; Owner: postgres
--

CREATE TABLE tower_sessions.session (
    id text NOT NULL,
    data bytea NOT NULL,
    expiry_date timestamp with time zone NOT NULL
);


ALTER TABLE tower_sessions.session OWNER TO postgres;

--
-- Data for Name: _sqlx_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) FROM stdin;
20251006215000	users	2025-11-19 18:09:54.036441+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3457532
20251006215100	networks	2025-11-19 18:09:54.040861+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4459430
20251006215151	create hosts	2025-11-19 18:09:54.045676+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3753176
20251006215155	create subnets	2025-11-19 18:09:54.049755+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3588988
20251006215201	create groups	2025-11-19 18:09:54.053697+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3718311
20251006215204	create daemons	2025-11-19 18:09:54.057761+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4217908
20251006215212	create services	2025-11-19 18:09:54.062345+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4890819
20251029193448	user-auth	2025-11-19 18:09:54.067551+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4327893
20251030044828	daemon api	2025-11-19 18:09:54.072173+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1501956
20251030170438	host-hide	2025-11-19 18:09:54.073966+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1093561
20251102224919	create discovery	2025-11-19 18:09:54.075355+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9345210
20251106235621	normalize-daemon-cols	2025-11-19 18:09:54.084974+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1723481
20251107034459	api keys	2025-11-19 18:09:54.087073+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7741403
20251107222650	oidc-auth	2025-11-19 18:09:54.095103+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21897441
20251110181948	orgs-billing	2025-11-19 18:09:54.117385+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10576408
20251113223656	group-enhancements	2025-11-19 18:09:54.12827+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1012308
20251117032720	daemon-mode	2025-11-19 18:09:54.129679+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1067802
20251118143058	set-default-plan	2025-11-19 18:09:54.131027+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1149295
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
2ab8b86f-73b1-4f5f-95ae-3534a4562f46	144edd5bff8d4bf19325f95a25ab3dcb	61b521cb-415f-4067-9a9d-eccfc3d3c38b	Integrated Daemon API Key	2025-11-19 18:09:57.843792+00	2025-11-19 18:10:50.668673+00	2025-11-19 18:10:50.668351+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
887ae705-1262-4e8c-af47-08fe31eba9d9	61b521cb-415f-4067-9a9d-eccfc3d3c38b	9ea137d0-3ee2-40d2-9d75-bf12697689a5	"172.25.0.4"	60073	2025-11-19 18:09:57.893368+00	2025-11-19 18:09:57.893367+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340"]}	2025-11-19 18:09:57.944998+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
faf4cc0f-ed0b-4416-81f8-9b71a5cd1d11	61b521cb-415f-4067-9a9d-eccfc3d3c38b	887ae705-1262-4e8c-af47-08fe31eba9d9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5"}	Self Report @ 172.25.0.4	2025-11-19 18:09:57.895007+00	2025-11-19 18:09:57.895007+00
654adb92-da61-47cf-aa91-f7ec10733bc9	61b521cb-415f-4067-9a9d-eccfc3d3c38b	887ae705-1262-4e8c-af47-08fe31eba9d9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-19 18:09:57.900776+00	2025-11-19 18:09:57.900776+00
4e534407-db5c-4255-9518-cc9de43d8036	61b521cb-415f-4067-9a9d-eccfc3d3c38b	887ae705-1262-4e8c-af47-08fe31eba9d9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "processed": 1, "network_id": "61b521cb-415f-4067-9a9d-eccfc3d3c38b", "session_id": "ece32baf-d4b7-424b-a015-596d51edc068", "started_at": "2025-11-19T18:09:57.900482908Z", "finished_at": "2025-11-19T18:09:57.996170361Z", "discovery_type": {"type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5"}	Discovery Run	2025-11-19 18:09:57.900482+00	2025-11-19 18:09:57.997215+00
9b22049b-2d1f-479b-8b94-65afc2b570aa	61b521cb-415f-4067-9a9d-eccfc3d3c38b	887ae705-1262-4e8c-af47-08fe31eba9d9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "processed": 12, "network_id": "61b521cb-415f-4067-9a9d-eccfc3d3c38b", "session_id": "93c02bc4-3e17-4cf4-bf86-19f526d44ec2", "started_at": "2025-11-19T18:09:58.006390394Z", "finished_at": "2025-11-19T18:10:50.667475089Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-19 18:09:58.00639+00	2025-11-19 18:10:50.668607+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
d0bb5250-767e-4dc7-88ae-c9095b54203e	61b521cb-415f-4067-9a9d-eccfc3d3c38b	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "40ee608a-deef-4d9a-beb4-3caaa606fce1"}	[{"id": "142b853f-a36a-4c4a-8a46-27281ddee5bf", "name": "Internet", "subnet_id": "6eb9bbef-c490-4b4e-adf0-adbb0b48f20f", "ip_address": "1.1.1.1", "mac_address": null}]	["11aad073-4c5e-4959-9174-d410f226156f"]	[{"id": "f868e848-5015-4dbc-995e-1a169ee68809", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-19 18:09:57.826214+00	2025-11-19 18:09:57.834746+00	f
783bcaf9-0f86-4c93-a9a5-73aed8152e53	61b521cb-415f-4067-9a9d-eccfc3d3c38b	Google.com	\N	\N	{"type": "ServiceBinding", "config": "c61d2d7f-bfc4-4ecb-b96d-8274777ed603"}	[{"id": "000217e1-59e6-461d-a4f0-0040cf9dd2df", "name": "Internet", "subnet_id": "6eb9bbef-c490-4b4e-adf0-adbb0b48f20f", "ip_address": "203.0.113.182", "mac_address": null}]	["f7294413-4733-427b-a7f8-6150d7743d36"]	[{"id": "bebb25b3-49bb-45cc-b577-2173ad35695b", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 18:09:57.826223+00	2025-11-19 18:09:57.839541+00	f
01c2d4f7-4dbf-4e17-84e8-ac898b65ac8f	61b521cb-415f-4067-9a9d-eccfc3d3c38b	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "715adaf4-b3e5-4005-8b13-3ac9c1b208fd"}	[{"id": "2daaaf54-66ba-41c4-8f86-ccf3fdbe4f8e", "name": "Remote Network", "subnet_id": "1bf05386-4748-4352-8260-85b9c9daa773", "ip_address": "203.0.113.32", "mac_address": null}]	["b2f10d32-a6db-4f96-92ae-f0eddbadc99d"]	[{"id": "b369f9a4-b9cb-4961-8f4f-626c5db1fe1d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 18:09:57.826231+00	2025-11-19 18:09:57.843025+00	f
19be1245-29c0-49a1-9826-744962d53b13	61b521cb-415f-4067-9a9d-eccfc3d3c38b	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "461342db-91ec-4258-9cfa-d62310c5afc0", "name": null, "subnet_id": "d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340", "ip_address": "172.25.0.3", "mac_address": "F2:50:68:08:25:7D"}]	["9ac07a7c-26ee-4556-9470-3fb819a8cb6a"]	[{"id": "adb2d1d2-acd4-418d-8fde-b32b67b6c20a", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T18:10:00.150306693Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 18:10:00.150308+00	2025-11-19 18:10:14.228034+00	f
26c2861f-c3a3-45c7-8e72-287795e7be96	61b521cb-415f-4067-9a9d-eccfc3d3c38b	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "90702814-e01d-430e-9e67-35ec7cb0f2c3", "name": null, "subnet_id": "d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340", "ip_address": "172.25.0.6", "mac_address": "DA:90:29:34:E2:75"}]	["23706bbb-bd9f-4f3e-bde8-ec40c04d017c"]	[{"id": "1d2b2ec9-b302-4433-a6ba-9f1353904c86", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T18:10:14.381228463Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 18:10:14.381229+00	2025-11-19 18:10:28.589679+00	f
9ea137d0-3ee2-40d2-9d75-bf12697689a5	61b521cb-415f-4067-9a9d-eccfc3d3c38b	172.25.0.4	e4c4a864ff5f	NetVisor daemon	{"type": "None"}	[{"id": "b964011d-d5bf-45fa-9a64-3a2d0a7f2d49", "name": "eth0", "subnet_id": "d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340", "ip_address": "172.25.0.4", "mac_address": "E2:0D:DC:D7:11:0C"}]	["7a9926dc-e2a3-4286-9a7c-4f20a2f35b9d", "6b03ba8d-1716-46b2-8a48-10963a8db3bd"]	[{"id": "6794d133-6c59-459b-8c90-e169929212f6", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T18:10:00.071231303Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T18:09:57.946606781Z", "type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9"}]}	null	2025-11-19 18:09:57.850784+00	2025-11-19 18:10:00.0784+00	f
0b9266bf-ecb7-49a0-8407-ce6c7a6ee3ce	61b521cb-415f-4067-9a9d-eccfc3d3c38b	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "d7557d1a-9d49-4bd2-8388-d8737e54b522", "name": null, "subnet_id": "d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340", "ip_address": "172.25.0.1", "mac_address": "3E:0C:A5:C4:F8:9E"}]	["af77c50b-bc33-4faf-8d23-c93ec0773b2d", "998b4a83-1a2b-4ced-9324-416ca32c8c2c"]	[{"id": "00152464-ff69-46d7-bfd4-16c0de01dfc5", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "3fc07f84-a587-4d9d-86b8-79a9de33ac31", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "c1357b5d-12d4-402e-9646-9d24d230dd10", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T18:10:36.737214837Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 18:10:36.737217+00	2025-11-19 18:10:50.665517+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
61b521cb-415f-4067-9a9d-eccfc3d3c38b	My Network	2025-11-19 18:09:57.82488+00	2025-11-19 18:09:57.82488+00	f	c379f097-a967-4d9a-8050-020258ac5899
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
c379f097-a967-4d9a-8050-020258ac5899	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-19 18:09:54.184605+00	2025-11-19 18:09:57.823371+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
11aad073-4c5e-4959-9174-d410f226156f	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.826216+00	2025-11-19 18:09:57.826216+00	Cloudflare DNS	d0bb5250-767e-4dc7-88ae-c9095b54203e	[{"id": "40ee608a-deef-4d9a-beb4-3caaa606fce1", "type": "Port", "port_id": "f868e848-5015-4dbc-995e-1a169ee68809", "interface_id": "142b853f-a36a-4c4a-8a46-27281ddee5bf"}]	"Dns Server"	null	{"type": "System"}
f7294413-4733-427b-a7f8-6150d7743d36	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.826225+00	2025-11-19 18:09:57.826225+00	Google.com	783bcaf9-0f86-4c93-a9a5-73aed8152e53	[{"id": "c61d2d7f-bfc4-4ecb-b96d-8274777ed603", "type": "Port", "port_id": "bebb25b3-49bb-45cc-b577-2173ad35695b", "interface_id": "000217e1-59e6-461d-a4f0-0040cf9dd2df"}]	"Web Service"	null	{"type": "System"}
b2f10d32-a6db-4f96-92ae-f0eddbadc99d	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.826232+00	2025-11-19 18:09:57.826232+00	Mobile Device	01c2d4f7-4dbf-4e17-84e8-ac898b65ac8f	[{"id": "715adaf4-b3e5-4005-8b13-3ac9c1b208fd", "type": "Port", "port_id": "b369f9a4-b9cb-4961-8f4f-626c5db1fe1d", "interface_id": "2daaaf54-66ba-41c4-8f86-ccf3fdbe4f8e"}]	"Client"	null	{"type": "System"}
7a9926dc-e2a3-4286-9a7c-4f20a2f35b9d	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.946623+00	2025-11-19 18:10:00.077424+00	NetVisor Daemon API	9ea137d0-3ee2-40d2-9d75-bf12697689a5	[{"id": "ea1a68e9-801b-489e-9571-b26390060e96", "type": "Port", "port_id": "6794d133-6c59-459b-8c90-e169929212f6", "interface_id": "b964011d-d5bf-45fa-9a64-3a2d0a7f2d49"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-19T18:10:00.071843802Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T18:09:57.946622481Z", "type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9"}]}
9ac07a7c-26ee-4556-9470-3fb819a8cb6a	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:10:07.94262+00	2025-11-19 18:10:07.94262+00	NetVisor Server API	19be1245-29c0-49a1-9826-744962d53b13	[{"id": "2a5bfbde-f79c-41a0-acb3-4787da50de51", "type": "Port", "port_id": "adb2d1d2-acd4-418d-8fde-b32b67b6c20a", "interface_id": "461342db-91ec-4258-9cfa-d62310c5afc0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T18:10:07.942613021Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
23706bbb-bd9f-4f3e-bde8-ec40c04d017c	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:10:28.580996+00	2025-11-19 18:10:28.580996+00	PostgreSQL	26c2861f-c3a3-45c7-8e72-287795e7be96	[{"id": "bde0065c-40a1-4ad2-b310-0bcca565fa68", "type": "Port", "port_id": "1d2b2ec9-b302-4433-a6ba-9f1353904c86", "interface_id": "90702814-e01d-430e-9e67-35ec7cb0f2c3"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-19T18:10:28.580986289Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
af77c50b-bc33-4faf-8d23-c93ec0773b2d	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:10:42.330668+00	2025-11-19 18:10:42.330668+00	Home Assistant	0b9266bf-ecb7-49a0-8407-ce6c7a6ee3ce	[{"id": "f3ac1b5d-ec99-41e7-aa76-e8d32f65bbb3", "type": "Port", "port_id": "00152464-ff69-46d7-bfd4-16c0de01dfc5", "interface_id": "d7557d1a-9d49-4bd2-8388-d8737e54b522"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T18:10:42.330656434Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
998b4a83-1a2b-4ced-9324-416ca32c8c2c	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:10:44.405631+00	2025-11-19 18:10:44.405631+00	NetVisor Server API	0b9266bf-ecb7-49a0-8407-ce6c7a6ee3ce	[{"id": "1d8605ec-586e-4423-8b7c-020b816d7129", "type": "Port", "port_id": "3fc07f84-a587-4d9d-86b8-79a9de33ac31", "interface_id": "d7557d1a-9d49-4bd2-8388-d8737e54b522"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T18:10:44.405621740Z", "type": "Network", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
6eb9bbef-c490-4b4e-adf0-adbb0b48f20f	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.826162+00	2025-11-19 18:09:57.826162+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
1bf05386-4748-4352-8260-85b9c9daa773	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.826166+00	2025-11-19 18:09:57.826166+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
d3c4eb6c-bf62-4299-8f8f-4c1a0c44a340	61b521cb-415f-4067-9a9d-eccfc3d3c38b	2025-11-19 18:09:57.900631+00	2025-11-19 18:09:57.900631+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-19T18:09:57.900630135Z", "type": "SelfReport", "host_id": "9ea137d0-3ee2-40d2-9d75-bf12697689a5", "daemon_id": "887ae705-1262-4e8c-af47-08fe31eba9d9"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
0453c0db-81ca-47cc-b498-6bbf0aee617d	2025-11-19 18:09:54.186464+00	2025-11-19 18:09:57.812318+00	$argon2id$v=19$m=19456,t=2,p=1$WrqgKWj4pAwpZKyJ57YxZQ$Q/TPXWvkgUjasHZhsxryNLxJ/DkaxUZ8rC+CjATFpbY	\N	\N	\N	user@example.com	c379f097-a967-4d9a-8050-020258ac5899	Owner
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
1rdFiyAMLLw9RDDiSvWODA	\\x93c4100c8ef54ae230443dbc2c0c208b45b7d681a7757365725f6964d92430343533633064622d383163612d343763632d623439382d36626266306165653631376499cd07e9cd0161120939ce30825520000000	2025-12-19 18:09:57.813847+00
\.


--
-- Name: _sqlx_migrations _sqlx_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._sqlx_migrations
    ADD CONSTRAINT _sqlx_migrations_pkey PRIMARY KEY (version);


--
-- Name: api_keys api_keys_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_key_key UNIQUE (key);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: daemons daemons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_pkey PRIMARY KEY (id);


--
-- Name: discovery discovery_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: hosts hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: networks networks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: subnets subnets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnets
    ADD CONSTRAINT subnets_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: tower_sessions; Owner: postgres
--

ALTER TABLE ONLY tower_sessions.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: idx_api_keys_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_key ON public.api_keys USING btree (key);


--
-- Name: idx_api_keys_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_api_keys_network ON public.api_keys USING btree (network_id);


--
-- Name: idx_daemon_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemon_host_id ON public.daemons USING btree (host_id);


--
-- Name: idx_daemons_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_network ON public.daemons USING btree (network_id);


--
-- Name: idx_discovery_daemon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_discovery_daemon ON public.discovery USING btree (daemon_id);


--
-- Name: idx_discovery_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_discovery_network ON public.discovery USING btree (network_id);


--
-- Name: idx_groups_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_groups_network ON public.groups USING btree (network_id);


--
-- Name: idx_hosts_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hosts_network ON public.hosts USING btree (network_id);


--
-- Name: idx_networks_owner_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_networks_owner_organization ON public.networks USING btree (organization_id);


--
-- Name: idx_organizations_stripe_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organizations_stripe_customer ON public.organizations USING btree (stripe_customer_id);


--
-- Name: idx_services_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_services_host_id ON public.services USING btree (host_id);


--
-- Name: idx_services_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_services_network ON public.services USING btree (network_id);


--
-- Name: idx_subnets_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subnets_network ON public.subnets USING btree (network_id);


--
-- Name: idx_users_email_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email_lower ON public.users USING btree (lower(email));


--
-- Name: idx_users_oidc_provider_subject; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_oidc_provider_subject ON public.users USING btree (oidc_provider, oidc_subject) WHERE ((oidc_provider IS NOT NULL) AND (oidc_subject IS NOT NULL));


--
-- Name: idx_users_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_organization ON public.users USING btree (organization_id);


--
-- Name: api_keys api_keys_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: daemons daemons_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: discovery discovery_daemon_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_daemon_id_fkey FOREIGN KEY (daemon_id) REFERENCES public.daemons(id) ON DELETE CASCADE;


--
-- Name: discovery discovery_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.discovery
    ADD CONSTRAINT discovery_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: groups groups_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: hosts hosts_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hosts
    ADD CONSTRAINT hosts_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: networks organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: services services_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_host_id_fkey FOREIGN KEY (host_id) REFERENCES public.hosts(id) ON DELETE CASCADE;


--
-- Name: services services_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: subnets subnets_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subnets
    ADD CONSTRAINT subnets_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict eBSnQ02bTJJqBWf84vAslrtSFRhVu7kiaRFTHpaqJGK3AZClXEDcKsrVWzI35Hs

