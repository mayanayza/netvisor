--
-- PostgreSQL database dump
--

\restrict 9zlq296xiNdF9PmdSeVUG7Ghhv8bHkM3NkX57LL5hUpI85gkr2bX8Rpqlglt1Dy

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
20251006215000	users	2025-11-08 00:10:31.22871+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3590504
20251006215100	networks	2025-11-08 00:10:31.233349+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5028805
20251006215151	create hosts	2025-11-08 00:10:31.238725+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3824263
20251006215155	create subnets	2025-11-08 00:10:31.242877+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3621032
20251006215201	create groups	2025-11-08 00:10:31.246848+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4028878
20251006215204	create daemons	2025-11-08 00:10:31.251247+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4281602
20251006215212	create services	2025-11-08 00:10:31.255884+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4936903
20251029193448	user-auth	2025-11-08 00:10:31.261128+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6295946
20251030044828	daemon api	2025-11-08 00:10:31.267737+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1545817
20251030170438	host-hide	2025-11-08 00:10:31.269613+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1095889
20251102224919	create discovery	2025-11-08 00:10:31.270986+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10595151
20251106235621	normalize-daemon-cols	2025-11-08 00:10:31.281889+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2009414
20251107034459	api keys	2025-11-08 00:10:31.284216+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8561932
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
48854c08-de39-4478-aa2c-567f294c9058	e5d22c36f80442969f967b18064d789a	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	Integrated Daemon API Key	2025-11-08 00:10:31.378518+00	2025-11-08 00:11:38.513152+00	2025-11-08 00:11:38.512798+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
cbb1c204-d3bc-45c0-a1ef-574e44a2568c	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	ffb48695-a67c-4a58-8ccb-046ffc31f7dd	"172.25.0.4"	60073	2025-11-08 00:10:31.433043+00	2025-11-08 00:10:31.433042+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["fa86094e-11ad-42b6-bf78-d6aa56d2ddae"]}	2025-11-08 00:10:31.448109+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
b52e0902-d8eb-4d41-9176-0e084ccfc787	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	cbb1c204-d3bc-45c0-a1ef-574e44a2568c	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd"}	Self Report @ 172.25.0.4	2025-11-08 00:10:31.434402+00	2025-11-08 00:10:31.434402+00
9fc6a8be-1c21-462a-bcf0-00df7b3da3ac	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	cbb1c204-d3bc-45c0-a1ef-574e44a2568c	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-08 00:10:31.440036+00	2025-11-08 00:10:31.440036+00
953b2813-0cf4-413b-bff6-f5714769f884	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	cbb1c204-d3bc-45c0-a1ef-574e44a2568c	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "processed": 1, "network_id": "9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d", "session_id": "05a66916-402b-409a-b774-e6bb5ab2e6c8", "started_at": "2025-11-08T00:10:31.439768777Z", "finished_at": "2025-11-08T00:10:31.463875357Z", "discovery_type": {"type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd"}	Discovery Run	2025-11-08 00:10:31.439768+00	2025-11-08 00:10:31.464961+00
f47a7e0d-8491-4cc2-860b-023d580dbd11	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	cbb1c204-d3bc-45c0-a1ef-574e44a2568c	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "processed": 12, "network_id": "9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d", "session_id": "8cc636f6-e506-4356-b7ea-93c9c7ffc93d", "started_at": "2025-11-08T00:10:31.470761150Z", "finished_at": "2025-11-08T00:11:38.510999329Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-08 00:10:31.470761+00	2025-11-08 00:11:38.513129+00
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
f639d1b9-b553-40ea-bcd9-84dd8a847942	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "0b603187-abee-4be7-9b25-d9921488bc70"}	[{"id": "89161ade-782a-4a79-9a27-06bbd50fea97", "name": "Internet", "subnet_id": "efae3c7b-085d-405b-a581-047eddb1fdb5", "ip_address": "1.1.1.1", "mac_address": null}]	["935962f3-12ba-473f-ac26-ffaf8b02258b"]	[{"id": "431ca078-7532-4e86-94ce-41e0e2b2082d", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-08 00:10:31.350602+00	2025-11-08 00:10:31.364599+00	f
24340328-8098-4e50-b5a3-d31032f207fa	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "9b1314ec-0692-4837-9f19-f9be145724ad"}	[{"id": "6018c193-a2d6-4dfe-98e0-327682badcdb", "name": "Internet", "subnet_id": "efae3c7b-085d-405b-a581-047eddb1fdb5", "ip_address": "203.0.113.231", "mac_address": null}]	["15cbb183-7e45-4ab6-9475-3551d00b26e7"]	[{"id": "b52baa7b-e379-420c-bbe8-f5b0e4d8b7b5", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 00:10:31.350617+00	2025-11-08 00:10:31.371233+00	f
8646b9bd-4382-4aba-8a4a-4e2ca6e39b04	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "e9de7d19-c42a-47e1-a021-7787688945ae"}	[{"id": "c0a5521c-8e2c-4f8a-9cbd-fc206d6a1f83", "name": "Remote Network", "subnet_id": "374dcd04-bdb2-457d-b28a-b50e53099a47", "ip_address": "203.0.113.132", "mac_address": null}]	["28d8560f-ee9a-49fc-8cd9-586dc60cf739"]	[{"id": "0631541a-6aba-454c-b4ab-80d9bde5ca7d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 00:10:31.350625+00	2025-11-08 00:10:31.377684+00	f
3dd3da64-4c23-4d56-8a5d-90ffff4b0535	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "129d3194-488f-471d-ae6c-1773b7b59531", "name": null, "subnet_id": "fa86094e-11ad-42b6-bf78-d6aa56d2ddae", "ip_address": "172.25.0.3", "mac_address": "8A:65:0C:CA:77:8C"}]	["4cb6750f-b9cd-445c-ab67-53e0dc17f1db"]	[{"id": "481c0979-413a-4701-a721-88686c9acb55", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T00:10:35.508834263Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 00:10:35.508835+00	2025-11-08 00:10:50.505626+00	f
582364ec-d180-4c0f-abc3-3b0296f0970f	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	runnervmf2e7y	runnervmf2e7y	\N	{"type": "Hostname"}	[{"id": "38d74c9e-3bf2-4f59-a28e-8a6eaefe3da9", "name": null, "subnet_id": "fa86094e-11ad-42b6-bf78-d6aa56d2ddae", "ip_address": "172.25.0.1", "mac_address": "42:55:02:EA:C1:3F"}]	["e0262571-e819-447e-8595-f64263c5fdf6", "52d66d71-c30e-4ec3-af63-17daf922f45f"]	[{"id": "e42becdf-9796-490e-9fe2-aef1560c247a", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "479d45e3-5cfc-4313-9fd2-250fe0a31cd6", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T00:11:05.372285097Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 00:11:05.372287+00	2025-11-08 00:11:20.567206+00	f
ffb48695-a67c-4a58-8ccb-046ffc31f7dd	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	172.25.0.4	ee372bf7aa1a	NetVisor daemon	{"type": "None"}	[{"id": "10671fa2-37fa-4b30-8e20-d78ea2cc91b1", "name": "eth0", "subnet_id": "fa86094e-11ad-42b6-bf78-d6aa56d2ddae", "ip_address": "172.25.0.4", "mac_address": "EA:FD:6D:DD:96:A2"}]	["96145f27-f37e-4cd9-ad86-7ae8f46e1cb1", "0807cb8d-6cb7-48fb-81f8-94bb39d8598a"]	[{"id": "5d8733d0-efe7-4c98-b3eb-ea3f706518e6", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T00:10:35.506368742Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T00:10:31.449667588Z", "type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c"}]}	null	2025-11-08 00:10:31.386334+00	2025-11-08 00:10:35.521691+00	f
34658506-a174-4b36-8855-645f4f61b30d	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "bed7cccd-8c46-4652-a85a-a7be42d36a17", "name": null, "subnet_id": "fa86094e-11ad-42b6-bf78-d6aa56d2ddae", "ip_address": "172.25.0.5", "mac_address": "66:3C:7F:88:A1:39"}]	["c5a8b590-d982-427c-941d-f7f943467cc1"]	[{"id": "b8e2931c-25a4-4e10-bc33-f3a0dd183ece", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T00:10:50.496081695Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 00:10:50.496083+00	2025-11-08 00:11:20.60969+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	My Network	2025-11-08 00:10:31.348823+00	2025-11-08 00:10:31.348823+00	t	01706aef-dc7e-4aea-a093-af06aaa906a6
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
935962f3-12ba-473f-ac26-ffaf8b02258b	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.35061+00	2025-11-08 00:10:31.363493+00	Cloudflare DNS	f639d1b9-b553-40ea-bcd9-84dd8a847942	[{"id": "0b603187-abee-4be7-9b25-d9921488bc70", "type": "Port", "port_id": "431ca078-7532-4e86-94ce-41e0e2b2082d", "interface_id": "89161ade-782a-4a79-9a27-06bbd50fea97"}]	"Dns Server"	null	{"type": "System"}
15cbb183-7e45-4ab6-9475-3551d00b26e7	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.350619+00	2025-11-08 00:10:31.370409+00	Google.com	24340328-8098-4e50-b5a3-d31032f207fa	[{"id": "9b1314ec-0692-4837-9f19-f9be145724ad", "type": "Port", "port_id": "b52baa7b-e379-420c-bbe8-f5b0e4d8b7b5", "interface_id": "6018c193-a2d6-4dfe-98e0-327682badcdb"}]	"Web Service"	null	{"type": "System"}
28d8560f-ee9a-49fc-8cd9-586dc60cf739	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.350627+00	2025-11-08 00:10:31.376943+00	Mobile Device	8646b9bd-4382-4aba-8a4a-4e2ca6e39b04	[{"id": "e9de7d19-c42a-47e1-a021-7787688945ae", "type": "Port", "port_id": "0631541a-6aba-454c-b4ab-80d9bde5ca7d", "interface_id": "c0a5521c-8e2c-4f8a-9cbd-fc206d6a1f83"}]	"Client"	null	{"type": "System"}
e0262571-e819-447e-8595-f64263c5fdf6	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:11:05.372521+00	2025-11-08 00:11:20.564476+00	NetVisor Server API	582364ec-d180-4c0f-abc3-3b0296f0970f	[{"id": "b07c2020-6464-4e63-acd2-4dc1a0d1993e", "type": "Port", "port_id": "e42becdf-9796-490e-9fe2-aef1560c247a", "interface_id": "38d74c9e-3bf2-4f59-a28e-8a6eaefe3da9"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T00:11:05.372511211Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
96145f27-f37e-4cd9-ad86-7ae8f46e1cb1	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.449683+00	2025-11-08 00:10:35.520506+00	NetVisor Daemon API	ffb48695-a67c-4a58-8ccb-046ffc31f7dd	[{"id": "25b67b28-10f2-4c10-9cf2-d4ae69fae8b0", "type": "Port", "port_id": "5d8733d0-efe7-4c98-b3eb-ea3f706518e6", "interface_id": "10671fa2-37fa-4b30-8e20-d78ea2cc91b1"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["NetVisor Daemon self-report", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-08T00:10:35.507084026Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T00:10:31.449679160Z", "type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c"}]}
4cb6750f-b9cd-445c-ab67-53e0dc17f1db	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:35.509+00	2025-11-08 00:10:50.504787+00	NetVisor Server API	3dd3da64-4c23-4d56-8a5d-90ffff4b0535	[{"id": "5940f390-df80-4fda-aeb1-3b3b70c56dfb", "type": "Port", "port_id": "481c0979-413a-4701-a721-88686c9acb55", "interface_id": "129d3194-488f-471d-ae6c-1773b7b59531"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T00:10:35.508994044Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c5a8b590-d982-427c-941d-f7f943467cc1	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:52.682643+00	2025-11-08 00:11:20.608748+00	Home Assistant	34658506-a174-4b36-8855-645f4f61b30d	[{"id": "12825dce-e428-414c-b9e1-4ce4763a5e9b", "type": "Port", "port_id": "b8e2931c-25a4-4e10-bc33-f3a0dd183ece", "interface_id": "bed7cccd-8c46-4652-a85a-a7be42d36a17"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T00:10:52.682633786Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
52d66d71-c30e-4ec3-af63-17daf922f45f	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:11:07.673928+00	2025-11-08 00:11:20.566052+00	Home Assistant	582364ec-d180-4c0f-abc3-3b0296f0970f	[{"id": "3a254ff1-d374-40a6-9bb8-8e811dc71ace", "type": "Port", "port_id": "479d45e3-5cfc-4313-9fd2-250fe0a31cd6", "interface_id": "38d74c9e-3bf2-4f59-a28e-8a6eaefe3da9"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T00:11:07.673916802Z", "type": "Network", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
efae3c7b-085d-405b-a581-047eddb1fdb5	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.350546+00	2025-11-08 00:10:31.350546+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
374dcd04-bdb2-457d-b28a-b50e53099a47	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.350551+00	2025-11-08 00:10:31.350551+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
fa86094e-11ad-42b6-bf78-d6aa56d2ddae	9b01cdf7-c2dc-417e-ba5a-d095f8d2c02d	2025-11-08 00:10:31.439932+00	2025-11-08 00:10:31.439932+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-08T00:10:31.439930671Z", "type": "SelfReport", "host_id": "ffb48695-a67c-4a58-8ccb-046ffc31f7dd", "daemon_id": "cbb1c204-d3bc-45c0-a1ef-574e44a2568c"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
01706aef-dc7e-4aea-a093-af06aaa906a6	testuser	2025-11-08 00:10:31.34765+00	2025-11-08 00:10:34.031022+00	$argon2id$v=19$m=19456,t=2,p=1$3Q3VD0iSNuTrPzccnuRSng$/9PYzHB9FdoUeKVWkLdsTzI/6RiGUoUpwBU/E26fdCY	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
Iyz0e7As4Nri-Zf1ZmZOCQ	\\x93c410094e6666f597f9e2dae02cb07bf42c2381a7757365725f6964d92430313730366165662d646337652d346165612d613039332d61663036616161393036613699cd07e9cd0156000a22ce01fd1346000000	2025-12-08 00:10:34.033362+00
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

\unrestrict 9zlq296xiNdF9PmdSeVUG7Ghhv8bHkM3NkX57LL5hUpI85gkr2bX8Rpqlglt1Dy

