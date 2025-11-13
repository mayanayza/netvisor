--
-- PostgreSQL database dump
--

\restrict 7E2VYoK0QURfIJaRz6kwbP8xmKpQz7iZ26Nftm28bDTmoMJ3F0SIu9dMeJbnMUa

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
20251006215000	users	2025-11-13 15:45:26.290945+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2613458
20251006215100	networks	2025-11-13 15:45:26.294708+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2136000
20251006215151	create hosts	2025-11-13 15:45:26.297042+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1287791
20251006215155	create subnets	2025-11-13 15:45:26.298648+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2259042
20251006215201	create groups	2025-11-13 15:45:26.301137+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1268208
20251006215204	create daemons	2025-11-13 15:45:26.302562+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1535625
20251006215212	create services	2025-11-13 15:45:26.304265+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1514833
20251029193448	user-auth	2025-11-13 15:45:26.305926+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5927833
20251030044828	daemon api	2025-11-13 15:45:26.312024+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	538750
20251030170438	host-hide	2025-11-13 15:45:26.3127+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	445042
20251102224919	create discovery	2025-11-13 15:45:26.313282+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	4326916
20251106235621	normalize-daemon-cols	2025-11-13 15:45:26.31776+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	567541
20251107034459	api keys	2025-11-13 15:45:26.318459+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	4569958
20251107222650	oidc-auth	2025-11-13 15:45:26.32319+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	17585250
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
47470baf-c595-46d4-869e-59311337250d	4036180c47b1403e965f4c97ea0963d5	421c6c81-180d-44dc-8ccd-eef1c991c4a3	Integrated Daemon API Key	2025-11-13 15:45:26.387934+00	2025-11-13 15:46:04.97541+00	2025-11-13 15:46:04.975107+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
8137a37d-d15b-43fc-a253-5884b81bc944	421c6c81-180d-44dc-8ccd-eef1c991c4a3	e026d83a-d560-414c-80f0-2aae1dce713f	"172.25.0.4"	60073	2025-11-13 15:45:26.437718+00	2025-11-13 15:45:26.437717+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["c523541c-a4d0-46f9-aaff-c932af8a04ef"]}	2025-11-13 15:45:26.451835+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
e8a3957e-6ce0-4009-b7cb-4c326c35077c	421c6c81-180d-44dc-8ccd-eef1c991c4a3	8137a37d-d15b-43fc-a253-5884b81bc944	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f"}	Self Report @ 172.25.0.4	2025-11-13 15:45:26.438421+00	2025-11-13 15:45:26.438421+00
1129568c-8e7e-4df0-b88c-6ee0eef6818c	421c6c81-180d-44dc-8ccd-eef1c991c4a3	8137a37d-d15b-43fc-a253-5884b81bc944	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-13 15:45:26.441887+00	2025-11-13 15:45:26.441887+00
38753db6-4346-45fd-b802-5e6cc177f525	421c6c81-180d-44dc-8ccd-eef1c991c4a3	8137a37d-d15b-43fc-a253-5884b81bc944	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "processed": 1, "network_id": "421c6c81-180d-44dc-8ccd-eef1c991c4a3", "session_id": "173051e8-9da8-44c4-9373-9e29f1261beb", "started_at": "2025-11-13T15:45:26.441760420Z", "finished_at": "2025-11-13T15:45:26.457143295Z", "discovery_type": {"type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f"}	Discovery Run	2025-11-13 15:45:26.44176+00	2025-11-13 15:45:26.45777+00
9a7f5d0c-a8d9-4600-aad4-4a9cd1424299	421c6c81-180d-44dc-8ccd-eef1c991c4a3	8137a37d-d15b-43fc-a253-5884b81bc944	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "processed": 13, "network_id": "421c6c81-180d-44dc-8ccd-eef1c991c4a3", "session_id": "cfa22837-e1c1-487b-9816-d7dbc934b7be", "started_at": "2025-11-13T15:45:26.462238170Z", "finished_at": "2025-11-13T15:46:04.974547632Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-13 15:45:26.462238+00	2025-11-13 15:46:04.975397+00
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
4bfd861c-d331-4c49-af54-2ae5c86dbbe9	421c6c81-180d-44dc-8ccd-eef1c991c4a3	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "814c3620-1c76-4d9b-a25d-1f2751fcf48f"}	[{"id": "9472133a-e340-4e88-967f-6e1a7aa2c29a", "name": "Internet", "subnet_id": "42ca3380-5c22-46b3-a71e-5b1c6df66325", "ip_address": "1.1.1.1", "mac_address": null}]	["b9b3803a-0baf-4bc2-bd3e-aaeb155ca0ef"]	[{"id": "8e37c644-de0c-4e44-9e92-fca8e0214712", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-13 15:45:26.37957+00	2025-11-13 15:45:26.383744+00	f
2070b615-0b89-4199-b6c6-aa4ed5655031	421c6c81-180d-44dc-8ccd-eef1c991c4a3	Google.com	\N	\N	{"type": "ServiceBinding", "config": "5af6e8ba-e772-4f71-8318-a6115adb2dcb"}	[{"id": "24c5895f-677e-4786-9cd9-c11b37cf1143", "name": "Internet", "subnet_id": "42ca3380-5c22-46b3-a71e-5b1c6df66325", "ip_address": "203.0.113.16", "mac_address": null}]	["a4eb6fd2-f203-485d-936c-9d1334928ef4"]	[{"id": "88ba22e2-f44e-40d2-a4d1-7379beedf62f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:45:26.379578+00	2025-11-13 15:45:26.385905+00	f
1aada6bd-bc3e-4c44-b1ee-2518612594d7	421c6c81-180d-44dc-8ccd-eef1c991c4a3	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "a60b987d-eba2-4c55-b2ee-86e56f27f1d4"}	[{"id": "5973338b-58c1-4e77-b781-9e7143d95b58", "name": "Remote Network", "subnet_id": "f0c77c8f-733a-4941-b908-f765f2fcf510", "ip_address": "203.0.113.166", "mac_address": null}]	["634eb8a6-480d-43b0-b17d-4a2c6f7dd13e"]	[{"id": "e789abf0-b0a0-45a1-b429-9a74b0692d5b", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:45:26.379585+00	2025-11-13 15:45:26.387599+00	f
8d15720b-7636-420b-9321-d65775a10e50	421c6c81-180d-44dc-8ccd-eef1c991c4a3	netvisor-postgres-1.netvisor_netvisor-dev	netvisor-postgres-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "2adc31b1-ece4-48c0-a184-7fa49e5d1b62", "name": null, "subnet_id": "c523541c-a4d0-46f9-aaff-c932af8a04ef", "ip_address": "172.25.0.6", "mac_address": "4A:1E:66:18:C6:36"}]	["256e7d49-1085-46dc-b442-0710fc3692f5"]	[{"id": "284b8cfb-8748-46c9-b8c7-ed94e5d7c90f", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:45:38.186675176Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:45:38.186676+00	2025-11-13 15:45:49.001534+00	f
e026d83a-d560-414c-80f0-2aae1dce713f	421c6c81-180d-44dc-8ccd-eef1c991c4a3	172.25.0.4	0195166e2e4d	NetVisor daemon	{"type": "None"}	[{"id": "2ce61659-8566-4690-9cf5-684aca91c4f8", "name": "eth0", "subnet_id": "c523541c-a4d0-46f9-aaff-c932af8a04ef", "ip_address": "172.25.0.4", "mac_address": "2A:CE:5E:99:3A:04"}]	["594f18c5-c2b9-4fa4-a004-64720504239b"]	[{"id": "7411eb3a-019f-4611-9293-64664da74e40", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:45:26.452938170Z", "type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944"}]}	null	2025-11-13 15:45:26.406729+00	2025-11-13 15:45:26.455952+00	f
0da7e513-362d-429d-9196-c5729b154e41	421c6c81-180d-44dc-8ccd-eef1c991c4a3	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8ad9c3d7-6305-45e5-ba71-bb8e9e18ebe0", "name": null, "subnet_id": "c523541c-a4d0-46f9-aaff-c932af8a04ef", "ip_address": "172.25.0.3", "mac_address": "6A:43:A1:24:52:B4"}]	["6061ab95-a7c2-4a1b-9b10-b6454da0bcaf"]	[{"id": "6a0cc389-4357-4da1-b454-0bbd72d248e7", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:45:28.618757629Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:45:28.618772+00	2025-11-13 15:45:38.138628+00	f
477bc363-ab95-4cff-8708-d79c4152a8b9	421c6c81-180d-44dc-8ccd-eef1c991c4a3	Home Assistant	\N	\N	{"type": "None"}	[{"id": "32b56aa1-3922-4dde-b971-b8e47a26d5aa", "name": null, "subnet_id": "c523541c-a4d0-46f9-aaff-c932af8a04ef", "ip_address": "172.25.0.1", "mac_address": "22:7E:A3:CC:31:73"}]	["70528e23-bbb9-48cc-ab13-3867771ae86d", "82f3e7c3-d958-4cb0-9bc8-7ae495423ffb", "2e2adcea-0545-42fc-951c-f692c82cfd08"]	[{"id": "24629e78-0f29-490b-9e41-ee034c55dca0", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a6e0acb9-a344-49c5-875f-e521d75c65a0", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "b5db9e15-07d3-4d8d-b6ef-846739a72808", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:45:55.140472128Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:45:55.140476+00	2025-11-13 15:46:04.971922+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
421c6c81-180d-44dc-8ccd-eef1c991c4a3	My Network	2025-11-13 15:45:26.378739+00	2025-11-13 15:45:26.378739+00	t	3486f678-937d-4e82-b946-291ace73ce95
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
b9b3803a-0baf-4bc2-bd3e-aaeb155ca0ef	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.379575+00	2025-11-13 15:45:26.379575+00	Cloudflare DNS	4bfd861c-d331-4c49-af54-2ae5c86dbbe9	[{"id": "814c3620-1c76-4d9b-a25d-1f2751fcf48f", "type": "Port", "port_id": "8e37c644-de0c-4e44-9e92-fca8e0214712", "interface_id": "9472133a-e340-4e88-967f-6e1a7aa2c29a"}]	"Dns Server"	null	{"type": "System"}
a4eb6fd2-f203-485d-936c-9d1334928ef4	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.379584+00	2025-11-13 15:45:26.379584+00	Google.com	2070b615-0b89-4199-b6c6-aa4ed5655031	[{"id": "5af6e8ba-e772-4f71-8318-a6115adb2dcb", "type": "Port", "port_id": "88ba22e2-f44e-40d2-a4d1-7379beedf62f", "interface_id": "24c5895f-677e-4786-9cd9-c11b37cf1143"}]	"Web Service"	null	{"type": "System"}
634eb8a6-480d-43b0-b17d-4a2c6f7dd13e	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.379586+00	2025-11-13 15:45:26.379586+00	Mobile Device	1aada6bd-bc3e-4c44-b1ee-2518612594d7	[{"id": "a60b987d-eba2-4c55-b2ee-86e56f27f1d4", "type": "Port", "port_id": "e789abf0-b0a0-45a1-b429-9a74b0692d5b", "interface_id": "5973338b-58c1-4e77-b781-9e7143d95b58"}]	"Client"	null	{"type": "System"}
594f18c5-c2b9-4fa4-a004-64720504239b	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.452966+00	2025-11-13 15:45:26.452966+00	NetVisor Daemon API	e026d83a-d560-414c-80f0-2aae1dce713f	[{"id": "1dc30e8d-4ca2-4669-9b63-903fef42e553", "type": "Port", "port_id": "7411eb3a-019f-4611-9293-64664da74e40", "interface_id": "2ce61659-8566-4690-9cf5-684aca91c4f8"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-13T15:45:26.452965795Z", "type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944"}]}
6061ab95-a7c2-4a1b-9b10-b6454da0bcaf	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:36.321366+00	2025-11-13 15:45:36.321366+00	NetVisor Server API	0da7e513-362d-429d-9196-c5729b154e41	[{"id": "d46a89a7-80c6-4372-a228-3ef3529d5d8c", "type": "Port", "port_id": "6a0cc389-4357-4da1-b454-0bbd72d248e7", "interface_id": "8ad9c3d7-6305-45e5-ba71-bb8e9e18ebe0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:45:36.321340966Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
256e7d49-1085-46dc-b442-0710fc3692f5	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:48.957505+00	2025-11-13 15:45:48.957505+00	PostgreSQL	8d15720b-7636-420b-9321-d65775a10e50	[{"id": "b5736cac-4f30-45c3-b795-eb813c2c2b40", "type": "Port", "port_id": "284b8cfb-8748-46c9-b8c7-ed94e5d7c90f", "interface_id": "2adc31b1-ece4-48c0-a184-7fa49e5d1b62"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:45:48.957480833Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
82f3e7c3-d958-4cb0-9bc8-7ae495423ffb	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:46:02.983036+00	2025-11-13 15:46:02.983036+00	NetVisor Server API	477bc363-ab95-4cff-8708-d79c4152a8b9	[{"id": "90dc8526-2ca1-4408-bcba-e17a6c45b501", "type": "Port", "port_id": "a6e0acb9-a344-49c5-875f-e521d75c65a0", "interface_id": "32b56aa1-3922-4dde-b971-b8e47a26d5aa"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:46:02.983029590Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
70528e23-bbb9-48cc-ab13-3867771ae86d	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:58.540917+00	2025-11-13 15:45:58.540917+00	Home Assistant	477bc363-ab95-4cff-8708-d79c4152a8b9	[{"id": "e97f67aa-cf58-43ed-9912-fb61dcf53b4f", "type": "Port", "port_id": "24629e78-0f29-490b-9e41-ee034c55dca0", "interface_id": "32b56aa1-3922-4dde-b971-b8e47a26d5aa"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:45:58.540892046Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
2e2adcea-0545-42fc-951c-f692c82cfd08	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:46:04.888532+00	2025-11-13 15:46:04.888532+00	PostgreSQL	477bc363-ab95-4cff-8708-d79c4152a8b9	[{"id": "75fb0f57-4f5d-4ea2-b516-997aed40ba4d", "type": "Port", "port_id": "b5db9e15-07d3-4d8d-b6ef-846739a72808", "interface_id": "32b56aa1-3922-4dde-b971-b8e47a26d5aa"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:46:04.888525174Z", "type": "Network", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
42ca3380-5c22-46b3-a71e-5b1c6df66325	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.379472+00	2025-11-13 15:45:26.379472+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
f0c77c8f-733a-4941-b908-f765f2fcf510	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.379474+00	2025-11-13 15:45:26.379474+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
c523541c-a4d0-46f9-aaff-c932af8a04ef	421c6c81-180d-44dc-8ccd-eef1c991c4a3	2025-11-13 15:45:26.443781+00	2025-11-13 15:45:26.443781+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:45:26.443769128Z", "type": "SelfReport", "host_id": "e026d83a-d560-414c-80f0-2aae1dce713f", "daemon_id": "8137a37d-d15b-43fc-a253-5884b81bc944"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
3486f678-937d-4e82-b946-291ace73ce95	2025-11-13 15:45:26.378196+00	2025-11-13 15:45:27.711453+00	$argon2id$v=19$m=19456,t=2,p=1$12MHa0p6CQWTJuGzpDn8oA$bpMXTMF2UyGkI2ECj/zPJ7AJdIwagcKqirQrj6yQ6Fw	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
cPpBjdQ-qwCEjbrs4d5Dmg	\\x93c4109a43dee1ecba8d8400ab3ed48d41fa7081a7757365725f6964d92433343836663637382d393337642d346538322d623934362d32393161636537336365393599cd07e9cd015b0f2d1bce2a7bcdbf000000	2025-12-13 15:45:27.712756+00
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

\unrestrict 7E2VYoK0QURfIJaRz6kwbP8xmKpQz7iZ26Nftm28bDTmoMJ3F0SIu9dMeJbnMUa

