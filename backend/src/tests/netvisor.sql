--
-- PostgreSQL database dump
--

\restrict poGhmCuSRAXTQJNbpwMNN9YrPoDfZV6vZaRfaRMBfyylBcleLwj3xE9zc9lM74m

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
    plan jsonb,
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
20251006215000	users	2025-11-17 06:27:58.591942+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2956002
20251006215100	networks	2025-11-17 06:27:58.595527+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3667534
20251006215151	create hosts	2025-11-17 06:27:58.599515+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3034433
20251006215155	create subnets	2025-11-17 06:27:58.602921+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2927687
20251006215201	create groups	2025-11-17 06:27:58.606267+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2967125
20251006215204	create daemons	2025-11-17 06:27:58.609556+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3419499
20251006215212	create services	2025-11-17 06:27:58.613446+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3545225
20251029193448	user-auth	2025-11-17 06:27:58.617257+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3303296
20251030044828	daemon api	2025-11-17 06:27:58.620908+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1365491
20251030170438	host-hide	2025-11-17 06:27:58.622569+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	901614
20251102224919	create discovery	2025-11-17 06:27:58.6238+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	7640443
20251106235621	normalize-daemon-cols	2025-11-17 06:27:58.631733+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1613645
20251107034459	api keys	2025-11-17 06:27:58.633669+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	6353367
20251107222650	oidc-auth	2025-11-17 06:27:58.640317+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	18351144
20251110181948	orgs-billing	2025-11-17 06:27:58.658968+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	7576251
20251113223656	group-enhancements	2025-11-17 06:27:58.666936+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	972868
20251117032720	daemon-mode	2025-11-17 06:27:58.668166+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1105746
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
35788a7b-a0b3-41a4-ab97-81f5287c0980	86e9c9ee896d42dfbec0de8bc9190282	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	Integrated Daemon API Key	2025-11-17 06:28:02.59662+00	2025-11-17 06:29:05.932219+00	2025-11-17 06:29:05.931889+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
79a3ddde-8141-4436-95ac-ce7558eb75d5	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2c294bf3-ae33-4798-999b-66947ba73b11	"172.25.0.4"	60073	2025-11-17 06:28:02.637893+00	2025-11-17 06:28:02.637891+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["4dfcff66-c70f-4028-9ed8-841525fe0932"]}	2025-11-17 06:28:02.652604+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
6caf0fc1-70d2-4427-9498-d866e0b61b57	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	79a3ddde-8141-4436-95ac-ce7558eb75d5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11"}	Self Report @ 172.25.0.4	2025-11-17 06:28:02.639085+00	2025-11-17 06:28:02.639085+00
0af807c3-c2b1-4a2f-ad8d-a9882021d23f	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	79a3ddde-8141-4436-95ac-ce7558eb75d5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 06:28:02.644129+00	2025-11-17 06:28:02.644129+00
6f224f1b-accd-4d00-bacf-b1214238c326	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	79a3ddde-8141-4436-95ac-ce7558eb75d5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "processed": 1, "network_id": "125bd7ef-a6bf-4d49-b807-5ad13b3e866a", "session_id": "a70ac7f6-913d-49bb-9a42-30ec0f2a833c", "started_at": "2025-11-17T06:28:02.643853734Z", "finished_at": "2025-11-17T06:28:02.691170109Z", "discovery_type": {"type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11"}	Discovery Run	2025-11-17 06:28:02.643853+00	2025-11-17 06:28:02.692966+00
6d1fa532-4b9f-46f9-b50c-82c5148118be	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	79a3ddde-8141-4436-95ac-ce7558eb75d5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "processed": 11, "network_id": "125bd7ef-a6bf-4d49-b807-5ad13b3e866a", "session_id": "eed5f2fe-bcdf-4d3b-9651-6db503bf2422", "started_at": "2025-11-17T06:28:02.699822400Z", "finished_at": "2025-11-17T06:29:05.931033629Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 06:28:02.699822+00	2025-11-17 06:29:05.932146+00
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
63f6c88f-dfff-4724-945e-9596d61d5e20	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "be6a2fa1-adf3-4c01-a2a6-8e487360eca1"}	[{"id": "17599f63-e548-4bad-b15e-72582bb31318", "name": "Internet", "subnet_id": "71a67969-3a6a-4ecc-8925-e1874e341d43", "ip_address": "1.1.1.1", "mac_address": null}]	["4618112d-54d1-4eb5-827c-4f7334a31bc4"]	[{"id": "35663258-b474-4d0e-a634-dfd576a636a8", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 06:28:02.580441+00	2025-11-17 06:28:02.588642+00	f
563e3961-038b-4c1b-8dbf-f7f408f68fab	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	Google.com	\N	\N	{"type": "ServiceBinding", "config": "dd94df43-4f48-4e20-9db3-a6328c46cf8f"}	[{"id": "63dc4787-e904-47c3-94ce-ccdd8da2c82b", "name": "Internet", "subnet_id": "71a67969-3a6a-4ecc-8925-e1874e341d43", "ip_address": "203.0.113.111", "mac_address": null}]	["1a4d0e97-8e3b-40eb-a8a7-daf88d5fb2f0"]	[{"id": "d0011961-7571-481d-9f4d-a3e13e2db03a", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:28:02.580447+00	2025-11-17 06:28:02.592787+00	f
6086b18c-b1e7-4117-8d66-4b7960664236	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "5a4ea48e-84c0-4c69-93b8-55dbdabfe4a7"}	[{"id": "1499cb10-f5dc-4fd6-a84f-0325651970dd", "name": "Remote Network", "subnet_id": "4cc998aa-16a3-4554-9d70-bd52d8d6d76f", "ip_address": "203.0.113.18", "mac_address": null}]	["36511c96-aabc-440a-ae53-cc3d293b38d4"]	[{"id": "bd1f51a4-ae08-402f-8b31-e961c87e1f47", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:28:02.58045+00	2025-11-17 06:28:02.595884+00	f
1ef20c06-4ddd-40eb-b359-159abe3bb388	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ca24d197-e05a-4b20-9812-73e5c4f86467", "name": null, "subnet_id": "4dfcff66-c70f-4028-9ed8-841525fe0932", "ip_address": "172.25.0.3", "mac_address": "9E:A1:B8:0A:EF:56"}]	["d725838f-b3d0-4657-bc96-1190d36d9788"]	[{"id": "ab4e8bcf-827b-4a08-84d5-d6b47ba8c0a7", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:18.633867459Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:28:18.63387+00	2025-11-17 06:28:32.339612+00	f
2c294bf3-ae33-4798-999b-66947ba73b11	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	172.25.0.4	0188339c2028	NetVisor daemon	{"type": "None"}	[{"id": "1f9d1e9c-3209-46a2-a808-4434adf0e177", "name": "eth0", "subnet_id": "4dfcff66-c70f-4028-9ed8-841525fe0932", "ip_address": "172.25.0.4", "mac_address": "5E:70:CF:00:DA:AF"}]	["f738bf01-147d-4ea8-8be1-c5d35e52124c", "9f8bf9ae-e535-41c3-aad7-5a28becde706"]	[{"id": "c587dc95-773e-4a9b-ba4a-518520420aba", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:32.331958245Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-17T06:28:02.653968110Z", "type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5"}]}	null	2025-11-17 06:28:02.60296+00	2025-11-17 06:28:46.107305+00	f
520dc01f-6e13-460e-ba25-f02d0bef27b8	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "51cf9309-661b-4fe1-991d-38be88fcc1bc", "name": null, "subnet_id": "4dfcff66-c70f-4028-9ed8-841525fe0932", "ip_address": "172.25.0.5", "mac_address": "7E:68:6B:D4:E8:32"}]	["b7529b78-8738-40fd-97ad-f0a0b3c2e09d"]	[{"id": "59018701-5c11-4eb0-a110-48e221258677", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:04.897007090Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:28:04.897009+00	2025-11-17 06:28:32.333161+00	f
1b3c2b8f-e360-48c3-a072-b87f700b139c	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1a0c3971-3e31-4c6a-89f8-47e1db06292e", "name": null, "subnet_id": "4dfcff66-c70f-4028-9ed8-841525fe0932", "ip_address": "172.25.0.6", "mac_address": "96:30:D9:96:08:A8"}]	["3be42324-3374-45ec-9d8e-7e05275b3a71"]	[{"id": "4c18b3ec-9baf-4ba0-8724-6ee09603f285", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:32.426386745Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:28:32.426388+00	2025-11-17 06:28:46.097572+00	f
2e71aada-0374-4aec-9b67-e0a358b6eced	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "124ce36d-325a-4640-bc1a-d9963e381233", "name": null, "subnet_id": "4dfcff66-c70f-4028-9ed8-841525fe0932", "ip_address": "172.25.0.1", "mac_address": "BE:74:4A:B0:F9:83"}]	["b802f412-61c5-4fd0-973e-4851cb686b92", "23e5b433-90e2-4b86-8bd9-334180f66097"]	[{"id": "5a013b22-fd36-4a7a-b520-05f92ee40540", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c7207979-f98e-4631-b516-9ef15dd69cd5", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "6d0f24ca-666d-4bf1-8584-983b3b55f1da", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:52.223515199Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:28:52.223518+00	2025-11-17 06:29:05.928814+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
125bd7ef-a6bf-4d49-b807-5ad13b3e866a	My Network	2025-11-17 06:28:02.579284+00	2025-11-17 06:28:02.579284+00	f	6303bb93-779a-4728-999c-f52cee70ad33
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
6303bb93-779a-4728-999c-f52cee70ad33	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 06:27:58.719531+00	2025-11-17 06:28:02.577943+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
4618112d-54d1-4eb5-827c-4f7334a31bc4	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.580443+00	2025-11-17 06:28:02.580443+00	Cloudflare DNS	63f6c88f-dfff-4724-945e-9596d61d5e20	[{"id": "be6a2fa1-adf3-4c01-a2a6-8e487360eca1", "type": "Port", "port_id": "35663258-b474-4d0e-a634-dfd576a636a8", "interface_id": "17599f63-e548-4bad-b15e-72582bb31318"}]	"Dns Server"	null	{"type": "System"}
1a4d0e97-8e3b-40eb-a8a7-daf88d5fb2f0	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.580448+00	2025-11-17 06:28:02.580448+00	Google.com	563e3961-038b-4c1b-8dbf-f7f408f68fab	[{"id": "dd94df43-4f48-4e20-9db3-a6328c46cf8f", "type": "Port", "port_id": "d0011961-7571-481d-9f4d-a3e13e2db03a", "interface_id": "63dc4787-e904-47c3-94ce-ccdd8da2c82b"}]	"Web Service"	null	{"type": "System"}
36511c96-aabc-440a-ae53-cc3d293b38d4	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.580451+00	2025-11-17 06:28:02.580451+00	Mobile Device	6086b18c-b1e7-4117-8d66-4b7960664236	[{"id": "5a4ea48e-84c0-4c69-93b8-55dbdabfe4a7", "type": "Port", "port_id": "bd1f51a4-ae08-402f-8b31-e961c87e1f47", "interface_id": "1499cb10-f5dc-4fd6-a84f-0325651970dd"}]	"Client"	null	{"type": "System"}
b7529b78-8738-40fd-97ad-f0a0b3c2e09d	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:06.296728+00	2025-11-17 06:28:06.296728+00	Home Assistant	520dc01f-6e13-460e-ba25-f02d0bef27b8	[{"id": "663b48c2-47e5-4eeb-939b-92e1ee6b0c01", "type": "Port", "port_id": "59018701-5c11-4eb0-a110-48e221258677", "interface_id": "51cf9309-661b-4fe1-991d-38be88fcc1bc"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:28:06.296720961Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d725838f-b3d0-4657-bc96-1190d36d9788	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:27.527812+00	2025-11-17 06:28:27.527812+00	NetVisor Server API	1ef20c06-4ddd-40eb-b359-159abe3bb388	[{"id": "787b603c-6f16-487d-8e66-0125a674cbbb", "type": "Port", "port_id": "ab4e8bcf-827b-4a08-84d5-d6b47ba8c0a7", "interface_id": "ca24d197-e05a-4b20-9812-73e5c4f86467"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:28:27.527805668Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
3be42324-3374-45ec-9d8e-7e05275b3a71	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:46.090613+00	2025-11-17 06:28:46.090613+00	PostgreSQL	1b3c2b8f-e360-48c3-a072-b87f700b139c	[{"id": "3e9cb27d-ac79-4782-a638-85e9d941ba23", "type": "Port", "port_id": "4c18b3ec-9baf-4ba0-8724-6ee09603f285", "interface_id": "1a0c3971-3e31-4c6a-89f8-47e1db06292e"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T06:28:46.090605045Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
f738bf01-147d-4ea8-8be1-c5d35e52124c	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.653983+00	2025-11-17 06:28:46.106315+00	NetVisor Daemon API	2c294bf3-ae33-4798-999b-66947ba73b11	[{"id": "e75472bb-4e60-4aa8-8002-f5afc71b6f9a", "type": "Port", "port_id": "c587dc95-773e-4a9b-ba4a-518520420aba", "interface_id": "1f9d1e9c-3209-46a2-a808-4434adf0e177"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T06:28:32.332922610Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-17T06:28:02.653982005Z", "type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5"}]}
b802f412-61c5-4fd0-973e-4851cb686b92	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:53.593592+00	2025-11-17 06:28:53.593592+00	Home Assistant	2e71aada-0374-4aec-9b67-e0a358b6eced	[{"id": "920f8b10-f610-4ab8-a8c8-e158e93ce5cb", "type": "Port", "port_id": "5a013b22-fd36-4a7a-b520-05f92ee40540", "interface_id": "124ce36d-325a-4640-bc1a-d9963e381233"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:28:53.593582142Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
23e5b433-90e2-4b86-8bd9-334180f66097	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:29:01.133799+00	2025-11-17 06:29:01.133799+00	NetVisor Server API	2e71aada-0374-4aec-9b67-e0a358b6eced	[{"id": "d3857dfc-a0b5-464c-9949-4ece4a6014d5", "type": "Port", "port_id": "c7207979-f98e-4631-b516-9ef15dd69cd5", "interface_id": "124ce36d-325a-4640-bc1a-d9963e381233"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:29:01.133790046Z", "type": "Network", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
71a67969-3a6a-4ecc-8925-e1874e341d43	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.58039+00	2025-11-17 06:28:02.58039+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
4cc998aa-16a3-4554-9d70-bd52d8d6d76f	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.580395+00	2025-11-17 06:28:02.580395+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
4dfcff66-c70f-4028-9ed8-841525fe0932	125bd7ef-a6bf-4d49-b807-5ad13b3e866a	2025-11-17 06:28:02.643969+00	2025-11-17 06:28:02.643969+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:28:02.643968262Z", "type": "SelfReport", "host_id": "2c294bf3-ae33-4798-999b-66947ba73b11", "daemon_id": "79a3ddde-8141-4436-95ac-ce7558eb75d5"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
7c26aecc-25e6-47f4-8188-194e18dc3bc6	2025-11-17 06:27:58.721155+00	2025-11-17 06:28:02.567899+00	$argon2id$v=19$m=19456,t=2,p=1$VAu5q5oHX8yDqC89mm3h4w$33PA0qvKT3enX+v/8lPZwNtqOF12nyk2S+I+zjA/4Rs	\N	\N	\N	user@example.com	6303bb93-779a-4728-999c-f52cee70ad33	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
zWxEKFite_v9mRtX3K-TsQ	\\x93c410b193afdc571b99fdfb7bad5828446ccd81a7757365725f6964d92437633236616563632d323565362d343766342d383138382d31393465313864633362633699cd07e9cd015f061c02ce21ef9e11000000	2025-12-17 06:28:02.569351+00
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

\unrestrict poGhmCuSRAXTQJNbpwMNN9YrPoDfZV6vZaRfaRMBfyylBcleLwj3xE9zc9lM74m

