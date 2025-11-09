--
-- PostgreSQL database dump
--

\restrict DdVmfd4D8PzgeTa8OWTaCo5lFcayb3SVfPNT7jM6H3bXfWgjoxPaPnwVSqc2jiI

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
20251006215000	users	2025-11-09 23:35:08.30905+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4128006
20251006215100	networks	2025-11-09 23:35:08.315116+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	6006366
20251006215151	create hosts	2025-11-09 23:35:08.321472+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3809880
20251006215155	create subnets	2025-11-09 23:35:08.325611+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3826310
20251006215201	create groups	2025-11-09 23:35:08.330312+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4735134
20251006215204	create daemons	2025-11-09 23:35:08.335558+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4200662
20251006215212	create services	2025-11-09 23:35:08.340116+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4902819
20251029193448	user-auth	2025-11-09 23:35:08.345341+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	8263467
20251030044828	daemon api	2025-11-09 23:35:08.35512+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1576735
20251030170438	host-hide	2025-11-09 23:35:08.357069+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1511502
20251102224919	create discovery	2025-11-09 23:35:08.359427+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11647178
20251106235621	normalize-daemon-cols	2025-11-09 23:35:08.371416+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	3503577
20251107034459	api keys	2025-11-09 23:35:08.375263+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8453485
20251107222650	oidc-auth	2025-11-09 23:35:08.384122+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	31426072
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
bc326b59-6b02-496e-9599-121dcec6b604	882494a8f0e5495db0d6f27387521de1	357cc9a8-717c-459d-b84e-d1836ed828a1	Integrated Daemon API Key	2025-11-09 23:35:08.499535+00	2025-11-09 23:35:47.363279+00	2025-11-09 23:35:47.363024+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
f78a3fd2-5615-467a-a03d-cf7dc7bfd26a	357cc9a8-717c-459d-b84e-d1836ed828a1	7327e150-8ff2-4c6d-b035-0e606acd8789	"172.25.0.4"	60073	2025-11-09 23:35:08.552745+00	2025-11-09 23:35:08.552744+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["fc63c936-dd4c-42ba-82c5-b5e2105555b5"]}	2025-11-09 23:35:08.566644+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
ff22b12a-3f58-45f5-a30f-c228f0a3b851	357cc9a8-717c-459d-b84e-d1836ed828a1	f78a3fd2-5615-467a-a03d-cf7dc7bfd26a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789"}	Self Report @ 172.25.0.4	2025-11-09 23:35:08.554549+00	2025-11-09 23:35:08.554549+00
0deaaa92-08c5-42fd-bdb9-7d36641888e2	357cc9a8-717c-459d-b84e-d1836ed828a1	f78a3fd2-5615-467a-a03d-cf7dc7bfd26a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-09 23:35:08.558987+00	2025-11-09 23:35:08.558987+00
6800e1c8-582b-4f12-8b37-a7d58101f882	357cc9a8-717c-459d-b84e-d1836ed828a1	f78a3fd2-5615-467a-a03d-cf7dc7bfd26a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "processed": 1, "network_id": "357cc9a8-717c-459d-b84e-d1836ed828a1", "session_id": "ae452193-addf-404f-9b5a-e97fad6daf38", "started_at": "2025-11-09T23:35:08.558714923Z", "finished_at": "2025-11-09T23:35:08.580633946Z", "discovery_type": {"type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789"}	Discovery Run	2025-11-09 23:35:08.558714+00	2025-11-09 23:35:08.581656+00
d534292c-a33e-48e3-836b-fee9c04d5927	357cc9a8-717c-459d-b84e-d1836ed828a1	f78a3fd2-5615-467a-a03d-cf7dc7bfd26a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "processed": 13, "network_id": "357cc9a8-717c-459d-b84e-d1836ed828a1", "session_id": "0a316836-3f88-4131-8a09-e3f82931efee", "started_at": "2025-11-09T23:35:08.587335863Z", "finished_at": "2025-11-09T23:35:47.361937262Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-09 23:35:08.587335+00	2025-11-09 23:35:47.363254+00
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
796937f7-d9b5-4c1d-bcf3-38ddc63f2679	357cc9a8-717c-459d-b84e-d1836ed828a1	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "4ee0a69e-0d50-437f-a820-76c4193f5375"}	[{"id": "f5206588-cbbe-47e8-a259-6bb40e66aa68", "name": "Internet", "subnet_id": "bc4d4fc9-0ad2-41d6-ad02-6a22a750da53", "ip_address": "1.1.1.1", "mac_address": null}]	["0ade1afd-9d55-494f-ac34-c7244f2647da"]	[{"id": "f5bc88aa-f786-485e-8c8a-2743df959f69", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-09 23:35:08.471625+00	2025-11-09 23:35:08.485256+00	f
268bf3e7-f33f-404d-95e7-c688d880b27e	357cc9a8-717c-459d-b84e-d1836ed828a1	Google.com	\N	\N	{"type": "ServiceBinding", "config": "54518a13-624c-4445-8f67-cbc06c4562e8"}	[{"id": "7ccf8841-a16a-44b9-b45b-14dc307ef553", "name": "Internet", "subnet_id": "bc4d4fc9-0ad2-41d6-ad02-6a22a750da53", "ip_address": "203.0.113.227", "mac_address": null}]	["11414e2b-3ddf-4d48-8508-7fcc496038df"]	[{"id": "0e262c71-f181-40dd-8ec1-88d6f50e7744", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-09 23:35:08.471635+00	2025-11-09 23:35:08.49215+00	f
e3b6fdc4-a143-46bb-b47e-f1165da74ce3	357cc9a8-717c-459d-b84e-d1836ed828a1	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "561086ee-9ef2-410e-a5bd-64fdcb9bc848"}	[{"id": "197cf993-8364-4e0e-98be-cb0693e5773b", "name": "Remote Network", "subnet_id": "7289b16d-6376-406e-aabf-ae1ec314d952", "ip_address": "203.0.113.152", "mac_address": null}]	["4ff73094-8ff6-44b1-a3bf-317e1af87ac8"]	[{"id": "bac36cbc-afd7-4a88-8efe-c0c04b7b746d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-09 23:35:08.471642+00	2025-11-09 23:35:08.498735+00	f
a403c8f7-7470-4785-80a0-aeb52eedb8d1	357cc9a8-717c-459d-b84e-d1836ed828a1	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "a1c6612f-e2df-43d2-bc42-cd67954147ba", "name": null, "subnet_id": "fc63c936-dd4c-42ba-82c5-b5e2105555b5", "ip_address": "172.25.0.3", "mac_address": "36:75:0C:7B:47:24"}]	["3a420838-32ce-4e5e-a857-faba17f27b8d"]	[{"id": "f34289de-e4cc-4936-9af0-956fe0259e86", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-09T23:35:10.706784675Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-09 23:35:10.706787+00	2025-11-09 23:35:25.124948+00	f
50b8ee49-e86b-403b-ab27-f369ae2d36e8	357cc9a8-717c-459d-b84e-d1836ed828a1	runnervmw9dnm	runnervmw9dnm	\N	{"type": "Hostname"}	[{"id": "1ba17c48-c8a8-44c7-9480-dc155f2507a7", "name": null, "subnet_id": "fc63c936-dd4c-42ba-82c5-b5e2105555b5", "ip_address": "172.25.0.1", "mac_address": "FE:BD:65:DD:48:33"}]	["3bc66346-7d20-48b6-b715-242703216001", "df3ced4b-679b-4cb5-b484-7e0c98999bfb"]	[{"id": "7c89a0cd-30d7-4497-a979-a151f02955c2", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "f6cce77a-3777-4418-8b15-b6527fcb00ac", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-09T23:35:33.131089143Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-09 23:35:33.131092+00	2025-11-09 23:35:47.359652+00	f
7327e150-8ff2-4c6d-b035-0e606acd8789	357cc9a8-717c-459d-b84e-d1836ed828a1	172.25.0.4	22146810328d	NetVisor daemon	{"type": "None"}	[{"id": "1911d0da-7528-4dba-aa06-494c41e5c115", "name": "eth0", "subnet_id": "fc63c936-dd4c-42ba-82c5-b5e2105555b5", "ip_address": "172.25.0.4", "mac_address": "AA:79:BE:EA:6B:EA"}]	["7a100dce-21a4-4569-941d-2c91f955687e", "d470cdf6-8c8f-4664-ba46-9fdc68423cfd"]	[{"id": "5f9b38f9-6da4-4d42-a329-e7859ec4006b", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-09T23:35:25.054704141Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-09T23:35:08.568061334Z", "type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a"}]}	null	2025-11-09 23:35:08.507389+00	2025-11-09 23:35:25.068091+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
357cc9a8-717c-459d-b84e-d1836ed828a1	My Network	2025-11-09 23:35:08.470441+00	2025-11-09 23:35:08.470441+00	t	877373c3-3307-490d-867e-904664c58d5d
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
0ade1afd-9d55-494f-ac34-c7244f2647da	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.471628+00	2025-11-09 23:35:08.48412+00	Cloudflare DNS	796937f7-d9b5-4c1d-bcf3-38ddc63f2679	[{"id": "4ee0a69e-0d50-437f-a820-76c4193f5375", "type": "Port", "port_id": "f5bc88aa-f786-485e-8c8a-2743df959f69", "interface_id": "f5206588-cbbe-47e8-a259-6bb40e66aa68"}]	"Dns Server"	null	{"type": "System"}
11414e2b-3ddf-4d48-8508-7fcc496038df	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.471637+00	2025-11-09 23:35:08.49137+00	Google.com	268bf3e7-f33f-404d-95e7-c688d880b27e	[{"id": "54518a13-624c-4445-8f67-cbc06c4562e8", "type": "Port", "port_id": "0e262c71-f181-40dd-8ec1-88d6f50e7744", "interface_id": "7ccf8841-a16a-44b9-b45b-14dc307ef553"}]	"Web Service"	null	{"type": "System"}
4ff73094-8ff6-44b1-a3bf-317e1af87ac8	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.471644+00	2025-11-09 23:35:08.497973+00	Mobile Device	e3b6fdc4-a143-46bb-b47e-f1165da74ce3	[{"id": "561086ee-9ef2-410e-a5bd-64fdcb9bc848", "type": "Port", "port_id": "bac36cbc-afd7-4a88-8efe-c0c04b7b746d", "interface_id": "197cf993-8364-4e0e-98be-cb0693e5773b"}]	"Client"	null	{"type": "System"}
3bc66346-7d20-48b6-b715-242703216001	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:33.131272+00	2025-11-09 23:35:47.357974+00	Home Assistant	50b8ee49-e86b-403b-ab27-f369ae2d36e8	[{"id": "81c95cb1-db0a-4f40-a233-2440aae090e0", "type": "Port", "port_id": "7c89a0cd-30d7-4497-a979-a151f02955c2", "interface_id": "1ba17c48-c8a8-44c7-9480-dc155f2507a7"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-09T23:35:33.131265093Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
df3ced4b-679b-4cb5-b484-7e0c98999bfb	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:40.966474+00	2025-11-09 23:35:47.35846+00	NetVisor Server API	50b8ee49-e86b-403b-ab27-f369ae2d36e8	[{"id": "d5d2b638-b19d-4373-ba94-36c30a7fef70", "type": "Port", "port_id": "f6cce77a-3777-4418-8b15-b6527fcb00ac", "interface_id": "1ba17c48-c8a8-44c7-9480-dc155f2507a7"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-09T23:35:40.966464626Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7a100dce-21a4-4569-941d-2c91f955687e	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.568072+00	2025-11-09 23:35:25.06681+00	NetVisor Daemon API	7327e150-8ff2-4c6d-b035-0e606acd8789	[{"id": "5c1cdec2-73b9-43c6-9578-59cf487a2dc7", "type": "Port", "port_id": "5f9b38f9-6da4-4d42-a329-e7859ec4006b", "interface_id": "1911d0da-7528-4dba-aa06-494c41e5c115"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-09T23:35:25.055398429Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-09T23:35:08.568071824Z", "type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a"}]}
3a420838-32ce-4e5e-a857-faba17f27b8d	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:18.65885+00	2025-11-09 23:35:25.124069+00	NetVisor Server API	a403c8f7-7470-4785-80a0-aeb52eedb8d1	[{"id": "999de70a-334e-4dc7-820a-e318741d972a", "type": "Port", "port_id": "f34289de-e4cc-4936-9af0-956fe0259e86", "interface_id": "a1c6612f-e2df-43d2-bc42-cd67954147ba"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-09T23:35:18.658839773Z", "type": "Network", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
bc4d4fc9-0ad2-41d6-ad02-6a22a750da53	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.471576+00	2025-11-09 23:35:08.471576+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
7289b16d-6376-406e-aabf-ae1ec314d952	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.471581+00	2025-11-09 23:35:08.471581+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
fc63c936-dd4c-42ba-82c5-b5e2105555b5	357cc9a8-717c-459d-b84e-d1836ed828a1	2025-11-09 23:35:08.558855+00	2025-11-09 23:35:08.558855+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-09T23:35:08.558848994Z", "type": "SelfReport", "host_id": "7327e150-8ff2-4c6d-b035-0e606acd8789", "daemon_id": "f78a3fd2-5615-467a-a03d-cf7dc7bfd26a"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
877373c3-3307-490d-867e-904664c58d5d	2025-11-09 23:35:08.469512+00	2025-11-09 23:35:11.621653+00	$argon2id$v=19$m=19456,t=2,p=1$HmIuT/aZuVY1xy4LclYdCg$DZ1nfdMg+eU+Xzvx2kZlqpgRv4BDc3vkJfJ0JIJFrKg	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
DDoKyLO5Ii-i5B8QvuLX2A	\\x93c410d8d7e2be101fe4a22f22b9b3c80a3a0c81a7757365725f6964d92438373733373363332d333330372d343930642d383637652d39303436363463353864356499cd07e9cd015717230bce25293491000000	2025-12-09 23:35:11.623457+00
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

\unrestrict DdVmfd4D8PzgeTa8OWTaCo5lFcayb3SVfPNT7jM6H3bXfWgjoxPaPnwVSqc2jiI

