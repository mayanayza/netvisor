--
-- PostgreSQL database dump
--

\restrict W3q98DSNGlZX47WJu1q4Y4Av4sMbWt44CbbTuz55h93R4pKBG3e9TLkgyxjgdGf

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
DROP INDEX IF EXISTS public.idx_users_name_lower;
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
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    password_hash text,
    username text
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
20251006215000	users	2025-11-07 17:56:15.20566+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2024167
20251006215100	networks	2025-11-07 17:56:15.208338+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	1785625
20251006215151	create hosts	2025-11-07 17:56:15.210296+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1222041
20251006215155	create subnets	2025-11-07 17:56:15.211716+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1483667
20251006215201	create groups	2025-11-07 17:56:15.213362+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1338375
20251006215204	create daemons	2025-11-07 17:56:15.214889+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1493666
20251006215212	create services	2025-11-07 17:56:15.216567+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1490708
20251029193448	user-auth	2025-11-07 17:56:15.218219+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5759250
20251030044828	daemon api	2025-11-07 17:56:15.224139+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	598167
20251030170438	host-hide	2025-11-07 17:56:15.224891+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	472250
20251102224919	create discovery	2025-11-07 17:56:15.225517+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	4234041
20251106235621	normalize-daemon-cols	2025-11-07 17:56:15.229919+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	563792
20251107034459	api keys	2025-11-07 17:56:15.230653+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	3927458
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
71b68374-5339-4ea0-bce3-b1ae66ff36f5	82f926bcaf214b5e9e475af72a233c80	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	Integrated Daemon API Key	2025-11-07 17:56:15.287064+00	2025-11-07 17:57:22.534686+00	2025-11-07 17:57:22.532925+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
89ff8a1d-ab03-42f9-9ff4-58906242e198	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	ff3a869b-7ff4-4ab4-870e-9cd19c536bc9	"172.25.0.4"	60073	2025-11-07 17:56:15.33727+00	2025-11-07 17:56:15.33727+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["18e4ccc3-6522-4ceb-af90-924d3e529197"]}	2025-11-07 17:56:15.346306+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
6d4c4b75-1769-4a2e-afd8-e3fef54cc5cf	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	89ff8a1d-ab03-42f9-9ff4-58906242e198	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9"}	Self Report @ 172.25.0.4	2025-11-07 17:56:15.337817+00	2025-11-07 17:56:15.337817+00
11601fce-7081-46b5-a8e6-44b0e7fe7bcb	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	89ff8a1d-ab03-42f9-9ff4-58906242e198	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-07 17:56:15.341739+00	2025-11-07 17:56:15.341739+00
3eaa2dd6-d0e8-410a-a22b-1d2a3c4bda2e	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	89ff8a1d-ab03-42f9-9ff4-58906242e198	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "processed": 1, "network_id": "34a11e2d-c6a5-4c99-ae3a-8652cefb3006", "session_id": "89e4f14f-d1aa-45ad-a139-705e2df77588", "started_at": "2025-11-07T17:56:15.341590211Z", "finished_at": "2025-11-07T17:56:15.352356753Z", "discovery_type": {"type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9"}	Discovery Run	2025-11-07 17:56:15.34159+00	2025-11-07 17:56:15.352754+00
4a3e88d3-99f9-4646-ad23-294c35e2a39b	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	89ff8a1d-ab03-42f9-9ff4-58906242e198	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "processed": 12, "network_id": "34a11e2d-c6a5-4c99-ae3a-8652cefb3006", "session_id": "7d58c112-d20a-4891-b1f1-ac35950466d3", "started_at": "2025-11-07T17:56:15.359730669Z", "finished_at": "2025-11-07T17:57:22.526707298Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-07 17:56:15.35973+00	2025-11-07 17:57:22.534589+00
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
61f22e20-ccb6-4c86-a714-e85e9cadd583	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "7e15044c-f83c-42bb-9b0d-9ae5d1112dd9"}	[{"id": "fe0e4f16-da04-4c51-8795-b8864ac03e62", "name": "Internet", "subnet_id": "e563d2d5-a92f-46c6-8650-65aacffdae15", "ip_address": "1.1.1.1", "mac_address": null}]	["e76505fc-6725-4591-bab7-d6950b90a3ab"]	[{"id": "744c8245-07df-43cd-b4ca-542248f6768b", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-07 17:56:15.27529+00	2025-11-07 17:56:15.281331+00	f
dee0e25e-d971-464a-8e67-e82c0192c302	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	Google.com	\N	\N	{"type": "ServiceBinding", "config": "96ad8b00-5b85-4486-b99e-585f60c4bdcd"}	[{"id": "9e4ad041-bc86-4838-b34a-e73e40a71618", "name": "Internet", "subnet_id": "e563d2d5-a92f-46c6-8650-65aacffdae15", "ip_address": "203.0.113.197", "mac_address": null}]	["79153558-fd49-4e95-8e01-da0329840fc1"]	[{"id": "59ae5ea2-961a-4706-9886-89fd07bc2487", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-07 17:56:15.275294+00	2025-11-07 17:56:15.28415+00	f
5dcb5b79-8ec3-4f60-8a9e-68b956f927a6	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "40b23445-a9f9-43c8-b348-294599caa6cf"}	[{"id": "fa04358c-fc8c-4ea1-8728-341a2cfa2081", "name": "Remote Network", "subnet_id": "f59b14bf-53da-49cf-99a5-5cac15359db6", "ip_address": "203.0.113.187", "mac_address": null}]	["714d1dc1-7ce6-4c8c-bc74-d4069788503e"]	[{"id": "f26354f3-fb79-4bd1-b7ad-71589556720e", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-07 17:56:15.275297+00	2025-11-07 17:56:15.286741+00	f
2881fe85-fce0-48fb-8716-ecb54132299f	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "7385100e-0d8e-470e-bbd3-bd70eb3efe61", "name": null, "subnet_id": "18e4ccc3-6522-4ceb-af90-924d3e529197", "ip_address": "172.25.0.3", "mac_address": "86:87:D3:B7:CC:C7"}]	["e67048b8-07f5-4bdc-ba02-1c835148a722"]	[{"id": "dbed6bcd-53d2-4fd0-8564-bcca03db384f", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T17:56:19.392783255Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-07 17:56:19.392783+00	2025-11-07 17:56:28.589005+00	f
7e59ef02-6432-42b9-8d53-69899308a026	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "37f60ce2-5f2f-4229-b50c-ff9a91f4a2c7", "name": null, "subnet_id": "18e4ccc3-6522-4ceb-af90-924d3e529197", "ip_address": "172.25.0.5", "mac_address": "8E:2F:B0:D3:76:D6"}]	["822285a2-273c-462a-ba79-4c30ceb94505"]	[{"id": "569c0e3c-169d-4ad9-97eb-6fd843898ef1", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T17:56:28.554981759Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-07 17:56:28.554986+00	2025-11-07 17:56:37.644739+00	f
ff3a869b-7ff4-4ab4-870e-9cd19c536bc9	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	172.25.0.4	6f0f13a11741	NetVisor daemon	{"type": "None"}	[{"id": "7cd206ca-2627-4f92-af3c-8b79d376fe03", "name": "eth0", "subnet_id": "18e4ccc3-6522-4ceb-af90-924d3e529197", "ip_address": "172.25.0.4", "mac_address": "FA:36:21:BC:95:65"}]	["45308010-ef93-4987-ba1d-8371f260b8f8", "cbbc4ba9-a85b-474a-8dce-aad129c3752d"]	[{"id": "948ad210-939e-4245-8f23-8df160a6bf9a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T17:56:19.391258255Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-07T17:56:15.346900253Z", "type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198"}]}	null	2025-11-07 17:56:15.304497+00	2025-11-07 17:56:19.398815+00	f
de02c34d-491a-40fd-b1d0-a827f66a617a	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	Home Assistant	\N	\N	{"type": "None"}	[{"id": "9cbf2d34-2a1f-4a10-9c45-572bb1b56103", "name": null, "subnet_id": "18e4ccc3-6522-4ceb-af90-924d3e529197", "ip_address": "172.25.0.1", "mac_address": "06:05:EF:47:B0:D4"}]	["c618967a-7ece-4d86-9879-cd6d2f47d9c4", "fcec642b-9ef5-4157-be8a-ffc7d136e913"]	[{"id": "ee4908b9-1c4f-467a-b056-02fe93c94467", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "df7fc0eb-f0c3-4488-be94-44a9dc5000b9", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T17:56:37.631990972Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-07 17:56:37.631992+00	2025-11-07 17:56:46.862456+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
34a11e2d-c6a5-4c99-ae3a-8652cefb3006	My Network	2025-11-07 17:56:15.274263+00	2025-11-07 17:56:15.274263+00	t	99161829-d067-4bc1-894f-6363f9188046
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
e76505fc-6725-4591-bab7-d6950b90a3ab	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.275291+00	2025-11-07 17:56:15.280818+00	Cloudflare DNS	61f22e20-ccb6-4c86-a714-e85e9cadd583	[{"id": "7e15044c-f83c-42bb-9b0d-9ae5d1112dd9", "type": "Port", "port_id": "744c8245-07df-43cd-b4ca-542248f6768b", "interface_id": "fe0e4f16-da04-4c51-8795-b8864ac03e62"}]	"Dns Server"	null	{"type": "System"}
79153558-fd49-4e95-8e01-da0329840fc1	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.275296+00	2025-11-07 17:56:15.283792+00	Google.com	dee0e25e-d971-464a-8e67-e82c0192c302	[{"id": "96ad8b00-5b85-4486-b99e-585f60c4bdcd", "type": "Port", "port_id": "59ae5ea2-961a-4706-9886-89fd07bc2487", "interface_id": "9e4ad041-bc86-4838-b34a-e73e40a71618"}]	"Web Service"	null	{"type": "System"}
714d1dc1-7ce6-4c8c-bc74-d4069788503e	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.275298+00	2025-11-07 17:56:15.286355+00	Mobile Device	5dcb5b79-8ec3-4f60-8a9e-68b956f927a6	[{"id": "40b23445-a9f9-43c8-b348-294599caa6cf", "type": "Port", "port_id": "f26354f3-fb79-4bd1-b7ad-71589556720e", "interface_id": "fa04358c-fc8c-4ea1-8728-341a2cfa2081"}]	"Client"	null	{"type": "System"}
822285a2-273c-462a-ba79-4c30ceb94505	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:30.8869+00	2025-11-07 17:56:37.644024+00	Home Assistant	7e59ef02-6432-42b9-8d53-69899308a026	[{"id": "61ae7203-ca55-4f4b-8089-7e730c8c084c", "type": "Port", "port_id": "569c0e3c-169d-4ad9-97eb-6fd843898ef1", "interface_id": "37f60ce2-5f2f-4229-b50c-ff9a91f4a2c7"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T17:56:30.886893385Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
45308010-ef93-4987-ba1d-8371f260b8f8	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.346916+00	2025-11-07 17:56:19.398251+00	NetVisor Daemon API	ff3a869b-7ff4-4ab4-870e-9cd19c536bc9	[{"id": "b8c4b842-e881-41f1-9dbe-aa7fb2b76537", "type": "Port", "port_id": "948ad210-939e-4245-8f23-8df160a6bf9a", "interface_id": "7cd206ca-2627-4f92-af3c-8b79d376fe03"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["NetVisor Daemon self-report", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-07T17:56:19.392086171Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-07T17:56:15.346910128Z", "type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198"}]}
e67048b8-07f5-4bdc-ba02-1c835148a722	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:28.101058+00	2025-11-07 17:56:28.58831+00	NetVisor Server API	2881fe85-fce0-48fb-8716-ecb54132299f	[{"id": "668770c2-7b5c-4a84-8c34-b12e427b5b30", "type": "Port", "port_id": "dbed6bcd-53d2-4fd0-8564-bcca03db384f", "interface_id": "7385100e-0d8e-470e-bbd3-bd70eb3efe61"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T17:56:28.101047342Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c618967a-7ece-4d86-9879-cd6d2f47d9c4	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:39.85792+00	2025-11-07 17:56:46.861544+00	Home Assistant	de02c34d-491a-40fd-b1d0-a827f66a617a	[{"id": "57a14a1c-53ed-4e17-a6c0-2f51221dc169", "type": "Port", "port_id": "ee4908b9-1c4f-467a-b056-02fe93c94467", "interface_id": "9cbf2d34-2a1f-4a10-9c45-572bb1b56103"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T17:56:39.857914125Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
fcec642b-9ef5-4157-be8a-ffc7d136e913	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:46.384413+00	2025-11-07 17:56:46.86182+00	NetVisor Server API	de02c34d-491a-40fd-b1d0-a827f66a617a	[{"id": "bc7ad126-1cb3-4e63-8499-337feeae5955", "type": "Port", "port_id": "df7fc0eb-f0c3-4488-be94-44a9dc5000b9", "interface_id": "9cbf2d34-2a1f-4a10-9c45-572bb1b56103"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T17:56:46.384401295Z", "type": "Network", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
e563d2d5-a92f-46c6-8650-65aacffdae15	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.275245+00	2025-11-07 17:56:15.275245+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
f59b14bf-53da-49cf-99a5-5cac15359db6	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.275246+00	2025-11-07 17:56:15.275246+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
18e4ccc3-6522-4ceb-af90-924d3e529197	34a11e2d-c6a5-4c99-ae3a-8652cefb3006	2025-11-07 17:56:15.342164+00	2025-11-07 17:56:15.342164+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-07T17:56:15.342158086Z", "type": "SelfReport", "host_id": "ff3a869b-7ff4-4ab4-870e-9cd19c536bc9", "daemon_id": "89ff8a1d-ab03-42f9-9ff4-58906242e198"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
99161829-d067-4bc1-894f-6363f9188046	testuser	2025-11-07 17:56:15.273335+00	2025-11-07 17:56:19.336681+00	$argon2id$v=19$m=19456,t=2,p=1$0sjZTxphWxdsaKVjXiJsnw$fwrvVaMN35bXf3kONAOgzlPxZAl4oMDPHr6FVVV6pJY	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
hYA9Q8xKGziQ7Qx4kM_tfA	\\x93c4107cedcf90780ced90381b4acc433d808581a7757365725f6964d92439393136313832392d643036372d346263312d383934662d36333633663931383830343699cd07e9cd0155113813ce147ba758000000	2025-12-07 17:56:19.343648+00
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
-- Name: idx_users_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_name_lower ON public.users USING btree (lower(name));


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

\unrestrict W3q98DSNGlZX47WJu1q4Y4Av4sMbWt44CbbTuz55h93R4pKBG3e9TLkgyxjgdGf

