--
-- PostgreSQL database dump
--

\restrict 1YnBT1O5VpjqQPw2vKX6FyxPZCml03aqGWAjG1u2UeEFdSRm2YOMD0gIH4bpD15

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
20251006215000	users	2025-11-13 15:26:58.372931+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	1794750
20251006215100	networks	2025-11-13 15:26:58.375445+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2140041
20251006215151	create hosts	2025-11-13 15:26:58.377821+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1574875
20251006215155	create subnets	2025-11-13 15:26:58.379553+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1366042
20251006215201	create groups	2025-11-13 15:26:58.381078+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1317792
20251006215204	create daemons	2025-11-13 15:26:58.382549+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1637791
20251006215212	create services	2025-11-13 15:26:58.384359+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1537584
20251029193448	user-auth	2025-11-13 15:26:58.386037+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5257958
20251030044828	daemon api	2025-11-13 15:26:58.391446+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	515417
20251030170438	host-hide	2025-11-13 15:26:58.392094+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	430209
20251102224919	create discovery	2025-11-13 15:26:58.392644+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	4179416
20251106235621	normalize-daemon-cols	2025-11-13 15:26:58.396975+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	613625
20251107034459	api keys	2025-11-13 15:26:58.397715+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	3589000
20251107222650	oidc-auth	2025-11-13 15:26:58.40147+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	10811958
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
2390539b-85cb-4e27-96a8-ea9efb4d40b5	e34f0449f1284cfe8c5221904593a9a6	71fc4049-1eff-4d1f-b919-81feb32dbf1d	Integrated Daemon API Key	2025-11-13 15:26:58.455766+00	2025-11-13 15:27:44.573472+00	2025-11-13 15:27:44.57329+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
8fe82881-7ef1-4034-972f-dc10c0bc5702	71fc4049-1eff-4d1f-b919-81feb32dbf1d	7e3fa236-1b74-4972-9b9b-87e3072fe0aa	"172.25.0.4"	60073	2025-11-13 15:26:58.495938+00	2025-11-13 15:26:58.495938+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["b6ca4c80-dcff-40ef-bcad-97963b032d95"]}	2025-11-13 15:26:58.509004+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
a881d068-7fc1-40ce-a054-33b2659f6ff6	71fc4049-1eff-4d1f-b919-81feb32dbf1d	8fe82881-7ef1-4034-972f-dc10c0bc5702	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa"}	Self Report @ 172.25.0.4	2025-11-13 15:26:58.496592+00	2025-11-13 15:26:58.496592+00
74423779-2f9e-4e52-a3a1-659b80b5110b	71fc4049-1eff-4d1f-b919-81feb32dbf1d	8fe82881-7ef1-4034-972f-dc10c0bc5702	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-13 15:26:58.499588+00	2025-11-13 15:26:58.499588+00
454d2062-d9d1-4bf7-943a-d23af6515342	71fc4049-1eff-4d1f-b919-81feb32dbf1d	8fe82881-7ef1-4034-972f-dc10c0bc5702	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "processed": 1, "network_id": "71fc4049-1eff-4d1f-b919-81feb32dbf1d", "session_id": "8c2d9b1d-8446-4825-b708-a0925353aec9", "started_at": "2025-11-13T15:26:58.499445921Z", "finished_at": "2025-11-13T15:26:58.514616880Z", "discovery_type": {"type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa"}	Discovery Run	2025-11-13 15:26:58.499445+00	2025-11-13 15:26:58.515077+00
a2829897-d7f1-4e5b-9c6f-30817f19ddd0	71fc4049-1eff-4d1f-b919-81feb32dbf1d	8fe82881-7ef1-4034-972f-dc10c0bc5702	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "processed": 11, "network_id": "71fc4049-1eff-4d1f-b919-81feb32dbf1d", "session_id": "22c3d752-a68b-4279-8dc2-35f084edf9ef", "started_at": "2025-11-13T15:26:58.519241421Z", "finished_at": "2025-11-13T15:27:44.572794054Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-13 15:26:58.519241+00	2025-11-13 15:27:44.573443+00
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
a2cc3c9d-a9a7-4af3-9165-2379ce12c0b8	71fc4049-1eff-4d1f-b919-81feb32dbf1d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "a2af0bd3-f699-4f8b-9d2e-a19b9ba76d7e"}	[{"id": "5533fb5c-92a0-4a67-a660-64988157b218", "name": "Internet", "subnet_id": "19e1ba25-517e-4554-9538-f7d6cad19e21", "ip_address": "1.1.1.1", "mac_address": null}]	["4f6aec21-c19e-4d7c-84a7-0c76a4cf689e"]	[{"id": "67dcf6ca-e8ec-4af0-a6fc-d3906cd6bbab", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-13 15:26:58.448065+00	2025-11-13 15:26:58.451553+00	f
54dd028d-a01d-4cf6-b078-feddc8f95b45	71fc4049-1eff-4d1f-b919-81feb32dbf1d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "aaf92ae6-e287-4bd8-8a16-aabc084f89b4"}	[{"id": "78c79b3f-d46a-4408-9e6f-d02d9c3330e1", "name": "Internet", "subnet_id": "19e1ba25-517e-4554-9538-f7d6cad19e21", "ip_address": "203.0.113.227", "mac_address": null}]	["3bb78b22-a77d-4433-942f-e44b3ed85d6d"]	[{"id": "e90938f2-dece-47de-8670-3559eda19093", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:26:58.448068+00	2025-11-13 15:26:58.453826+00	f
e329820e-a977-4c99-ac0e-2e610e58ea83	71fc4049-1eff-4d1f-b919-81feb32dbf1d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "073afffd-9213-4b1d-84ed-62113084f54c"}	[{"id": "1a4d0642-9ab8-456b-898b-14669faede45", "name": "Remote Network", "subnet_id": "541ea0a4-2f27-4756-996d-fbfc1322ea0e", "ip_address": "203.0.113.204", "mac_address": null}]	["6422c01b-b057-45cd-81ed-bd9bc5cf9ed3"]	[{"id": "544a4776-ceb6-4c63-b827-ff429d77f600", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:26:58.44807+00	2025-11-13 15:26:58.455445+00	f
2bee478a-84c5-435d-b14f-72227415dc3d	71fc4049-1eff-4d1f-b919-81feb32dbf1d	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "479c4162-0899-4230-b8fc-4acc3e3360b0", "name": null, "subnet_id": "b6ca4c80-dcff-40ef-bcad-97963b032d95", "ip_address": "172.25.0.3", "mac_address": "12:3E:97:C6:76:A8"}]	["104e8e47-3568-4c00-9082-3767f5bc5593"]	[{"id": "0a685adf-4ada-45b9-84f9-b2cf02a1b292", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:27:00.678328881Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:27:00.678331+00	2025-11-13 15:27:10.393622+00	f
e1605729-f0ab-4130-9d10-37c293328e38	71fc4049-1eff-4d1f-b919-81feb32dbf1d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "a4aa2b18-c596-4c6e-bc16-332cac8a338f", "name": null, "subnet_id": "b6ca4c80-dcff-40ef-bcad-97963b032d95", "ip_address": "172.25.0.5", "mac_address": "26:9C:4C:00:EA:96"}]	["66df3f99-1a21-44dd-8e1f-dda029251731"]	[{"id": "7236b8a1-0aa8-4899-97ee-294aef4f6417", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:27:10.425669094Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:27:10.42567+00	2025-11-13 15:27:28.827431+00	f
7e3fa236-1b74-4972-9b9b-87e3072fe0aa	71fc4049-1eff-4d1f-b919-81feb32dbf1d	172.25.0.4	5c222dae3dd9	NetVisor daemon	{"type": "None"}	[{"id": "4fe1f1cc-8891-45c9-938d-335320fdba27", "name": "eth0", "subnet_id": "b6ca4c80-dcff-40ef-bcad-97963b032d95", "ip_address": "172.25.0.4", "mac_address": "4E:B6:5A:65:5D:D1"}]	["5b65fead-e3cc-4481-a84e-e2bccf3b6c81", "032200b0-96e7-48e4-884d-1517eda0760e"]	[{"id": "e96559fd-de27-470b-b802-ff1e491e3a50", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:27:00.605613297Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-13T15:26:58.510062796Z", "type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702"}]}	null	2025-11-13 15:26:58.46561+00	2025-11-13 15:27:00.674956+00	f
c021a3ad-8188-439b-923c-ac3c0a70feab	71fc4049-1eff-4d1f-b919-81feb32dbf1d	netvisor-postgres-1.netvisor_netvisor-dev	netvisor-postgres-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1ea87794-db78-474a-8cea-5d4b624cd388", "name": null, "subnet_id": "b6ca4c80-dcff-40ef-bcad-97963b032d95", "ip_address": "172.25.0.6", "mac_address": "6E:9C:E6:63:07:3C"}]	["d5d8614d-704d-4b5b-87cf-e1745339757b"]	[{"id": "c5eec6ff-68cd-4dc3-9db9-396718b79068", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:27:19.801049959Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:27:19.801052+00	2025-11-13 15:27:28.83253+00	f
420a5b1f-011b-49e0-a794-0ffbf2aa62d1	71fc4049-1eff-4d1f-b919-81feb32dbf1d	Home Assistant	\N	\N	{"type": "None"}	[{"id": "bbba32ce-5034-439f-893b-48a14fc45436", "name": null, "subnet_id": "b6ca4c80-dcff-40ef-bcad-97963b032d95", "ip_address": "172.25.0.1", "mac_address": "9E:DD:21:45:0A:E3"}]	["66d1ec8b-6a74-44c6-83f6-5bb05d4ccfbd", "4689af98-1b01-4688-9c0a-84fed4195eb4", "c4bc6419-4c5e-45ae-8235-5c6b6b835d87"]	[{"id": "f63ffda2-e56e-4b28-bfb3-a2486d6a48f2", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6699e898-91c9-47cf-bf95-e1b1e63430e3", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "ee227665-fdf0-4e56-ae7c-8cdaaa649da8", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:27:34.962671133Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:27:34.962676+00	2025-11-13 15:27:44.571129+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
71fc4049-1eff-4d1f-b919-81feb32dbf1d	My Network	2025-11-13 15:26:58.447521+00	2025-11-13 15:26:58.447521+00	t	66be4e2c-fc01-45df-a93f-d151f4924baa
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
4f6aec21-c19e-4d7c-84a7-0c76a4cf689e	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.448066+00	2025-11-13 15:26:58.448066+00	Cloudflare DNS	a2cc3c9d-a9a7-4af3-9165-2379ce12c0b8	[{"id": "a2af0bd3-f699-4f8b-9d2e-a19b9ba76d7e", "type": "Port", "port_id": "67dcf6ca-e8ec-4af0-a6fc-d3906cd6bbab", "interface_id": "5533fb5c-92a0-4a67-a660-64988157b218"}]	"Dns Server"	null	{"type": "System"}
3bb78b22-a77d-4433-942f-e44b3ed85d6d	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.448069+00	2025-11-13 15:26:58.448069+00	Google.com	54dd028d-a01d-4cf6-b078-feddc8f95b45	[{"id": "aaf92ae6-e287-4bd8-8a16-aabc084f89b4", "type": "Port", "port_id": "e90938f2-dece-47de-8670-3559eda19093", "interface_id": "78c79b3f-d46a-4408-9e6f-d02d9c3330e1"}]	"Web Service"	null	{"type": "System"}
6422c01b-b057-45cd-81ed-bd9bc5cf9ed3	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.448071+00	2025-11-13 15:26:58.448071+00	Mobile Device	e329820e-a977-4c99-ac0e-2e610e58ea83	[{"id": "073afffd-9213-4b1d-84ed-62113084f54c", "type": "Port", "port_id": "544a4776-ceb6-4c63-b827-ff429d77f600", "interface_id": "1a4d0642-9ab8-456b-898b-14669faede45"}]	"Client"	null	{"type": "System"}
5b65fead-e3cc-4481-a84e-e2bccf3b6c81	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.510167+00	2025-11-13 15:27:00.673586+00	NetVisor Daemon API	7e3fa236-1b74-4972-9b9b-87e3072fe0aa	[{"id": "bd4c9c53-8737-4e40-9bc6-c6e08fb356a4", "type": "Port", "port_id": "e96559fd-de27-470b-b802-ff1e491e3a50", "interface_id": "4fe1f1cc-8891-45c9-938d-335320fdba27"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-13T15:27:00.605895339Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-13T15:26:58.510087630Z", "type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702"}]}
104e8e47-3568-4c00-9082-3767f5bc5593	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:08.559332+00	2025-11-13 15:27:08.559332+00	NetVisor Server API	2bee478a-84c5-435d-b14f-72227415dc3d	[{"id": "c83f8106-82bb-48c5-ac88-426655ba634b", "type": "Port", "port_id": "0a685adf-4ada-45b9-84f9-b2cf02a1b292", "interface_id": "479c4162-0899-4230-b8fc-4acc3e3360b0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/tcp/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:27:08.559290676Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
66df3f99-1a21-44dd-8e1f-dda029251731	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:13.746311+00	2025-11-13 15:27:13.746311+00	Home Assistant	e1605729-f0ab-4130-9d10-37c293328e38	[{"id": "2157e864-1b33-4314-94ec-f0bc46cec57b", "type": "Port", "port_id": "7236b8a1-0aa8-4899-97ee-294aef4f6417", "interface_id": "a4aa2b18-c596-4c6e-bc16-332cac8a338f"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/tcp/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:27:13.746300679Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d5d8614d-704d-4b5b-87cf-e1745339757b	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:28.820421+00	2025-11-13 15:27:28.820421+00	PostgreSQL	c021a3ad-8188-439b-923c-ac3c0a70feab	[{"id": "28b8a884-58e7-4e98-b08d-2d9da8b73100", "type": "Port", "port_id": "c5eec6ff-68cd-4dc3-9db9-396718b79068", "interface_id": "1ea87794-db78-474a-8cea-5d4b624cd388"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:27:28.820414505Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
4689af98-1b01-4688-9c0a-84fed4195eb4	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:42.679779+00	2025-11-13 15:27:42.679779+00	NetVisor Server API	420a5b1f-011b-49e0-a794-0ffbf2aa62d1	[{"id": "f774636c-5d5d-47aa-970f-7c21f95838a1", "type": "Port", "port_id": "6699e898-91c9-47cf-bf95-e1b1e63430e3", "interface_id": "bbba32ce-5034-439f-893b-48a14fc45436"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/tcp/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:27:42.679764345Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
66d1ec8b-6a74-44c6-83f6-5bb05d4ccfbd	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:38.554375+00	2025-11-13 15:27:38.554375+00	Home Assistant	420a5b1f-011b-49e0-a794-0ffbf2aa62d1	[{"id": "85527b00-c285-41f8-9cc8-b54b68b6213e", "type": "Port", "port_id": "f63ffda2-e56e-4b28-bfb3-a2486d6a48f2", "interface_id": "bbba32ce-5034-439f-893b-48a14fc45436"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/tcp/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:27:38.554357843Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c4bc6419-4c5e-45ae-8235-5c6b6b835d87	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:27:44.551296+00	2025-11-13 15:27:44.551296+00	PostgreSQL	420a5b1f-011b-49e0-a794-0ffbf2aa62d1	[{"id": "28c8bb7c-f0c5-45f7-b9ca-a755c011a42b", "type": "Port", "port_id": "ee227665-fdf0-4e56-ae7c-8cdaaa649da8", "interface_id": "bbba32ce-5034-439f-893b-48a14fc45436"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:27:44.551289679Z", "type": "Network", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
19e1ba25-517e-4554-9538-f7d6cad19e21	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.448035+00	2025-11-13 15:26:58.448035+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
541ea0a4-2f27-4756-996d-fbfc1322ea0e	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.448036+00	2025-11-13 15:26:58.448036+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
b6ca4c80-dcff-40ef-bcad-97963b032d95	71fc4049-1eff-4d1f-b919-81feb32dbf1d	2025-11-13 15:26:58.502834+00	2025-11-13 15:26:58.502834+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:26:58.502721296Z", "type": "SelfReport", "host_id": "7e3fa236-1b74-4972-9b9b-87e3072fe0aa", "daemon_id": "8fe82881-7ef1-4034-972f-dc10c0bc5702"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
66be4e2c-fc01-45df-a93f-d151f4924baa	2025-11-13 15:26:58.447069+00	2025-11-13 15:27:00.669986+00	$argon2id$v=19$m=19456,t=2,p=1$Yq0q2x0iczSZpnNP2R4B0w$dZx0facQBmqeFdhTZ8V5mWw5AhRv6Ij8TfAh3tQ7cdI	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
NjIl_fLfgBRWzlChkbpdCA	\\x93c410085dba91a150ce561480dff2fd25323681a7757365725f6964d92436366265346532632d666330312d343564662d613933662d64313531663439323462616199cd07e9cd015b0f1b00ce28077a5a000000	2025-12-13 15:27:00.671578+00
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

\unrestrict 1YnBT1O5VpjqQPw2vKX6FyxPZCml03aqGWAjG1u2UeEFdSRm2YOMD0gIH4bpD15

