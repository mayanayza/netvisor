--
-- PostgreSQL database dump
--

\restrict LgVWVh6nIgZR8xWbLxMayNoQ7ubriF8m2h1vgyGbgV4LSDmoDoLMNLQF8BDKOGs

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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

ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
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
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
    color text NOT NULL
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
    user_id uuid NOT NULL
);


ALTER TABLE public.networks OWNER TO postgres;

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
    email text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

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
20251006215000	users	2025-11-08 20:48:03.355498+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3920326
20251006215100	networks	2025-11-08 20:48:03.360158+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4055999
20251006215151	create hosts	2025-11-08 20:48:03.364967+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4435177
20251006215155	create subnets	2025-11-08 20:48:03.370149+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4296318
20251006215201	create groups	2025-11-08 20:48:03.37483+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4068062
20251006215204	create daemons	2025-11-08 20:48:03.379294+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4522506
20251006215212	create services	2025-11-08 20:48:03.384171+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5149929
20251029193448	user-auth	2025-11-08 20:48:03.389675+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4385032
20251030044828	daemon api	2025-11-08 20:48:03.394386+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1787481
20251030170438	host-hide	2025-11-08 20:48:03.396498+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1168016
20251102224919	create discovery	2025-11-08 20:48:03.397962+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10391247
20251106235621	normalize-daemon-cols	2025-11-08 20:48:03.408704+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1968770
20251107034459	api keys	2025-11-08 20:48:03.411002+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8338017
20251107222650	oidc-auth	2025-11-08 20:48:03.419905+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21440990
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
9a24629d-4e1d-487a-9020-de1096a27bcd	72858b3228284064a81ce10fbed9243a	e045e1f0-46b3-4075-aca0-0b350fac813e	Integrated Daemon API Key	2025-11-08 20:48:03.529092+00	2025-11-08 20:49:10.669873+00	2025-11-08 20:49:10.669528+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
2881484b-d8a5-4135-b1f8-8a0dc39388f5	e045e1f0-46b3-4075-aca0-0b350fac813e	519e0540-d008-4a7a-ad69-01f9758d2e53	"172.25.0.4"	60073	2025-11-08 20:48:03.58372+00	2025-11-08 20:48:03.583718+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["e77f7199-e39b-4e75-b3eb-b6588098830b"]}	2025-11-08 20:48:03.60074+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
eb36756a-3487-4b88-b01c-54bf916c5056	e045e1f0-46b3-4075-aca0-0b350fac813e	2881484b-d8a5-4135-b1f8-8a0dc39388f5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53"}	Self Report @ 172.25.0.4	2025-11-08 20:48:03.585105+00	2025-11-08 20:48:03.585105+00
b7fcfb34-d9da-48ed-a9df-376dc3a07152	e045e1f0-46b3-4075-aca0-0b350fac813e	2881484b-d8a5-4135-b1f8-8a0dc39388f5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-08 20:48:03.591213+00	2025-11-08 20:48:03.591213+00
7cd8e81e-dc79-439c-b0e8-81b35ae71758	e045e1f0-46b3-4075-aca0-0b350fac813e	2881484b-d8a5-4135-b1f8-8a0dc39388f5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "processed": 1, "network_id": "e045e1f0-46b3-4075-aca0-0b350fac813e", "session_id": "12035646-dfaa-4eaa-8bbf-016869251fb1", "started_at": "2025-11-08T20:48:03.590863736Z", "finished_at": "2025-11-08T20:48:03.617160155Z", "discovery_type": {"type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53"}	Discovery Run	2025-11-08 20:48:03.590863+00	2025-11-08 20:48:03.618557+00
57e9c11b-5992-4606-9230-6b13053cdedb	e045e1f0-46b3-4075-aca0-0b350fac813e	2881484b-d8a5-4135-b1f8-8a0dc39388f5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "processed": 12, "network_id": "e045e1f0-46b3-4075-aca0-0b350fac813e", "session_id": "247953e7-4b55-4102-bb2e-2726a7a83303", "started_at": "2025-11-08T20:48:03.626301243Z", "finished_at": "2025-11-08T20:49:10.667908365Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-08 20:48:03.626301+00	2025-11-08 20:49:10.669849+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
92ea016f-24ff-445c-9831-323b45bd2936	e045e1f0-46b3-4075-aca0-0b350fac813e	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "48e23b33-411a-4e53-b0b7-21db5d79ccd8"}	[{"id": "161a9ba7-98ec-4e7d-b31d-4ba205cb6922", "name": "Internet", "subnet_id": "cfcbf082-d7cc-4e6d-bebb-ae0090b67910", "ip_address": "1.1.1.1", "mac_address": null}]	["521d068f-371e-42f4-a2e7-442dbb503c1f"]	[{"id": "c3a45564-ca65-4b16-9116-5dc3398844fb", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-08 20:48:03.497972+00	2025-11-08 20:48:03.512995+00	f
5d592dfb-4489-4c9c-898d-2831fd6208d8	e045e1f0-46b3-4075-aca0-0b350fac813e	Google.com	\N	\N	{"type": "ServiceBinding", "config": "96bed666-2ce2-4636-89d5-cb05f2c94cdf"}	[{"id": "97ba341e-be24-472c-81fa-1282832e0862", "name": "Internet", "subnet_id": "cfcbf082-d7cc-4e6d-bebb-ae0090b67910", "ip_address": "203.0.113.191", "mac_address": null}]	["b9753272-e16a-458c-ae86-4289a78a0aab"]	[{"id": "fbb33cbe-dc30-4e5d-b1e3-5e8d1833772d", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 20:48:03.497982+00	2025-11-08 20:48:03.520817+00	f
96949c42-2ede-48fb-8842-78a3ddf5a50d	e045e1f0-46b3-4075-aca0-0b350fac813e	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "ab578051-0cd9-41c8-960b-db594e470638"}	[{"id": "13a8dbfa-b843-4a74-ac0d-720317bcd4b4", "name": "Remote Network", "subnet_id": "c3f8f3d7-7d56-4adf-bfc5-23eaccb7778a", "ip_address": "203.0.113.215", "mac_address": null}]	["5d293ae4-8834-48de-b7fe-47a3cd777b94"]	[{"id": "1912f7e5-7814-4a2e-a52c-624d03554a8e", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 20:48:03.497992+00	2025-11-08 20:48:03.528207+00	f
519e0540-d008-4a7a-ad69-01f9758d2e53	e045e1f0-46b3-4075-aca0-0b350fac813e	172.25.0.4	1ff6b15a82c9	NetVisor daemon	{"type": "None"}	[{"id": "15e20b6f-45e4-409f-bf2b-9ee168d73849", "name": "eth0", "subnet_id": "e77f7199-e39b-4e75-b3eb-b6588098830b", "ip_address": "172.25.0.4", "mac_address": "E2:57:22:70:03:25"}]	["b4a120e2-e87f-4692-bda6-d981d673a0fa", "b93e894d-2f92-4741-b226-b1ee5cdc8e3b"]	[{"id": "ab468fd8-0358-4361-8ff1-ccb431b094bf", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:48:23.636201035Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T20:48:03.602532494Z", "type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5"}]}	null	2025-11-08 20:48:03.537278+00	2025-11-08 20:48:23.72832+00	f
17ee98fb-993a-4884-848c-e1cbef498429	e045e1f0-46b3-4075-aca0-0b350fac813e	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "3e0d5619-1d16-4c43-bdc7-2a5e3b9bb844", "name": null, "subnet_id": "e77f7199-e39b-4e75-b3eb-b6588098830b", "ip_address": "172.25.0.3", "mac_address": "E6:A5:30:32:00:F5"}]	["0bed03e1-f0ab-4916-a6ca-f739b6b81c18"]	[{"id": "f9c3c804-984d-415b-9e06-8a2f67a59b61", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:48:07.672099403Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:48:07.672103+00	2025-11-08 20:48:23.711931+00	f
051b18a7-9fec-4bfd-93dc-048378f3b0a8	e045e1f0-46b3-4075-aca0-0b350fac813e	runnervmw9dnm	runnervmw9dnm	\N	{"type": "Hostname"}	[{"id": "d088fceb-b323-427d-adac-fc2b804d20ee", "name": null, "subnet_id": "e77f7199-e39b-4e75-b3eb-b6588098830b", "ip_address": "172.25.0.1", "mac_address": "E6:4D:AE:34:4F:11"}]	["bd0a5a64-e316-4498-9633-0da11db15ada", "1334304f-cbab-4b00-8778-0906b72b5c1f"]	[{"id": "92726fbf-0469-4e7f-bfad-ac86e7bd59de", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "86f549ce-a711-4bb2-8e62-89c34f70a017", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:48:39.531639938Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:48:39.531642+00	2025-11-08 20:48:55.381216+00	f
a1df7088-80d4-4c5d-9f15-f32971589bef	e045e1f0-46b3-4075-aca0-0b350fac813e	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "9ed183bd-ad3f-48c8-b9ec-8664ef2dec26", "name": null, "subnet_id": "e77f7199-e39b-4e75-b3eb-b6588098830b", "ip_address": "172.25.0.5", "mac_address": "F6:F8:63:31:9A:86"}]	["1cc27218-19a3-4170-8673-9e3c76d66c92"]	[{"id": "8880c897-afd1-4759-b388-5dbc173810a7", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:48:23.637976965Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:48:23.637978+00	2025-11-08 20:48:55.383032+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
e045e1f0-46b3-4075-aca0-0b350fac813e	My Network	2025-11-08 20:48:03.496298+00	2025-11-08 20:48:03.496298+00	t	0db47965-2f0f-47c3-a386-9388d7caf3a8
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
521d068f-371e-42f4-a2e7-442dbb503c1f	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.497975+00	2025-11-08 20:48:03.511779+00	Cloudflare DNS	92ea016f-24ff-445c-9831-323b45bd2936	[{"id": "48e23b33-411a-4e53-b0b7-21db5d79ccd8", "type": "Port", "port_id": "c3a45564-ca65-4b16-9116-5dc3398844fb", "interface_id": "161a9ba7-98ec-4e7d-b31d-4ba205cb6922"}]	"Dns Server"	null	{"type": "System"}
b9753272-e16a-458c-ae86-4289a78a0aab	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.497984+00	2025-11-08 20:48:03.519808+00	Google.com	5d592dfb-4489-4c9c-898d-2831fd6208d8	[{"id": "96bed666-2ce2-4636-89d5-cb05f2c94cdf", "type": "Port", "port_id": "fbb33cbe-dc30-4e5d-b1e3-5e8d1833772d", "interface_id": "97ba341e-be24-472c-81fa-1282832e0862"}]	"Web Service"	null	{"type": "System"}
5d293ae4-8834-48de-b7fe-47a3cd777b94	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.497993+00	2025-11-08 20:48:03.527225+00	Mobile Device	96949c42-2ede-48fb-8842-78a3ddf5a50d	[{"id": "ab578051-0cd9-41c8-960b-db594e470638", "type": "Port", "port_id": "1912f7e5-7814-4a2e-a52c-624d03554a8e", "interface_id": "13a8dbfa-b843-4a74-ac0d-720317bcd4b4"}]	"Client"	null	{"type": "System"}
bd0a5a64-e316-4498-9633-0da11db15ada	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:48.999001+00	2025-11-08 20:48:55.379174+00	Home Assistant	051b18a7-9fec-4bfd-93dc-048378f3b0a8	[{"id": "9643dddc-5135-4f91-9b80-727c74c88109", "type": "Port", "port_id": "92726fbf-0469-4e7f-bfad-ac86e7bd59de", "interface_id": "d088fceb-b323-427d-adac-fc2b804d20ee"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:48:48.998991344Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
0bed03e1-f0ab-4916-a6ca-f739b6b81c18	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:17.287675+00	2025-11-08 20:48:23.710525+00	NetVisor Server API	17ee98fb-993a-4884-848c-e1cbef498429	[{"id": "bf513d6b-1519-4ccc-bed4-1addae66df79", "type": "Port", "port_id": "f9c3c804-984d-415b-9e06-8a2f67a59b61", "interface_id": "3e0d5619-1d16-4c43-bdc7-2a5e3b9bb844"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:48:17.287663360Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
b4a120e2-e87f-4692-bda6-d981d673a0fa	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.602549+00	2025-11-08 20:48:23.727376+00	NetVisor Daemon API	519e0540-d008-4a7a-ad69-01f9758d2e53	[{"id": "dbe95351-fb22-4bb0-91dd-a2ac09e65ea8", "type": "Port", "port_id": "ab468fd8-0358-4361-8ff1-ccb431b094bf", "interface_id": "15e20b6f-45e4-409f-bf2b-9ee168d73849"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["NetVisor Daemon self-report", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-08T20:48:23.636479154Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T20:48:03.602549075Z", "type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5"}]}
1334304f-cbab-4b00-8778-0906b72b5c1f	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:48.999132+00	2025-11-08 20:48:55.379702+00	NetVisor Server API	051b18a7-9fec-4bfd-93dc-048378f3b0a8	[{"id": "d5373146-5961-47f6-8720-04e28ca51ba2", "type": "Port", "port_id": "86f549ce-a711-4bb2-8e62-89c34f70a017", "interface_id": "d088fceb-b323-427d-adac-fc2b804d20ee"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:48:48.999128038Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
1cc27218-19a3-4170-8673-9e3c76d66c92	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:33.196055+00	2025-11-08 20:48:55.381696+00	Home Assistant	a1df7088-80d4-4c5d-9f15-f32971589bef	[{"id": "70785d95-2cb3-493e-bde3-2b850b026d1b", "type": "Port", "port_id": "8880c897-afd1-4759-b388-5dbc173810a7", "interface_id": "9ed183bd-ad3f-48c8-b9ec-8664ef2dec26"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:48:33.196043273Z", "type": "Network", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
cfcbf082-d7cc-4e6d-bebb-ae0090b67910	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.497906+00	2025-11-08 20:48:03.497906+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
c3f8f3d7-7d56-4adf-bfc5-23eaccb7778a	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.497911+00	2025-11-08 20:48:03.497911+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
e77f7199-e39b-4e75-b3eb-b6588098830b	e045e1f0-46b3-4075-aca0-0b350fac813e	2025-11-08 20:48:03.591029+00	2025-11-08 20:48:03.591029+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:48:03.591028564Z", "type": "SelfReport", "host_id": "519e0540-d008-4a7a-ad69-01f9758d2e53", "daemon_id": "2881484b-d8a5-4135-b1f8-8a0dc39388f5"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
0db47965-2f0f-47c3-a386-9388d7caf3a8	2025-11-08 20:48:03.494894+00	2025-11-08 20:48:08.51722+00	$argon2id$v=19$m=19456,t=2,p=1$GwHAMsEZOnUl5wj6ocmk/g$/zbccYj8hQsgDJxWoE94sVq7cEf7J2mpjiguJioWhF0	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
0Q7im5WlZ2pJvypMm-PGmA	\\x93c41098c6e39b4c2abf496a67a5959be20ed181a7757365725f6964d92430646234373936352d326630662d343763332d613338362d39333838643763616633613899cd07e9cd0156143008ce1efba236000000	2025-12-08 20:48:08.519807+00
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
-- Name: networks networks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- PostgreSQL database dump complete
--

\unrestrict LgVWVh6nIgZR8xWbLxMayNoQ7ubriF8m2h1vgyGbgV4LSDmoDoLMNLQF8BDKOGs

