--
-- PostgreSQL database dump
--

\restrict AboSGC5z0TJHejpGxGzbaWfB6VAlsXFWHyHen8QxAzFpDpdfjwLDjhW7CzRx2Dw

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
20251006215000	users	2025-11-14 22:16:49.600081+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2460167
20251006215100	networks	2025-11-14 22:16:49.603443+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2767000
20251006215151	create hosts	2025-11-14 22:16:49.60647+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1537125
20251006215155	create subnets	2025-11-14 22:16:49.60821+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2567041
20251006215201	create groups	2025-11-14 22:16:49.610951+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1323250
20251006215204	create daemons	2025-11-14 22:16:49.612461+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1616583
20251006215212	create services	2025-11-14 22:16:49.614275+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1686583
20251029193448	user-auth	2025-11-14 22:16:49.616133+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	13088834
20251030044828	daemon api	2025-11-14 22:16:49.629401+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	548958
20251030170438	host-hide	2025-11-14 22:16:49.630091+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	422708
20251102224919	create discovery	2025-11-14 22:16:49.630649+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	5598250
20251106235621	normalize-daemon-cols	2025-11-14 22:16:49.636455+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	673167
20251107034459	api keys	2025-11-14 22:16:49.637272+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	3883417
20251107222650	oidc-auth	2025-11-14 22:16:49.64139+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	14642917
20251113223656	group-enhancements	2025-11-14 22:16:49.656209+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	449500
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
560c3331-f5a3-438f-9106-d7487c496dff	0ed73d4d5f154f86902cf977d78788f6	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	Integrated Daemon API Key	2025-11-14 22:16:49.705711+00	2025-11-14 22:17:39.192707+00	2025-11-14 22:17:39.192524+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
1af42567-82b6-4caf-a2bc-07c97b53f649	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	d8c0edfe-1132-4f67-91d9-9dbbbc88f231	"172.25.0.4"	60073	2025-11-14 22:16:49.756573+00	2025-11-14 22:16:49.756572+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["fb88a2e2-5092-49d8-8180-0ce5be260ca0"]}	2025-11-14 22:16:49.769515+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
b402272f-de24-4785-9656-bc17d253557a	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	1af42567-82b6-4caf-a2bc-07c97b53f649	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231"}	Self Report @ 172.25.0.4	2025-11-14 22:16:49.75748+00	2025-11-14 22:16:49.75748+00
6eeb9e3b-ea96-41a1-a1f2-62aa38dd8fc3	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	1af42567-82b6-4caf-a2bc-07c97b53f649	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-14 22:16:49.761912+00	2025-11-14 22:16:49.761912+00
1b03137c-40f5-400d-824e-eafd814bd1aa	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	1af42567-82b6-4caf-a2bc-07c97b53f649	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "processed": 1, "network_id": "b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d", "session_id": "5bed057b-ec1b-46e9-b639-e2470ab1a501", "started_at": "2025-11-14T22:16:49.762047926Z", "finished_at": "2025-11-14T22:16:49.773672217Z", "discovery_type": {"type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231"}	Discovery Run	2025-11-14 22:16:49.762047+00	2025-11-14 22:16:49.774068+00
a6d39504-7961-49b3-8d94-1cf22c845d18	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	1af42567-82b6-4caf-a2bc-07c97b53f649	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "processed": 11, "network_id": "b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d", "session_id": "de90469d-739a-41b8-9705-4fa36330f0e4", "started_at": "2025-11-14T22:16:49.780169759Z", "finished_at": "2025-11-14T22:17:39.191798712Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-14 22:16:49.780169+00	2025-11-14 22:17:39.192689+00
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
dc34a9b6-c525-4f58-a4b8-f199b3d2bbc3	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "672a1f3a-1da5-49eb-84c1-dac54618aea3"}	[{"id": "3bc28dbc-c31c-4bf9-baba-b71e0f982c8b", "name": "Internet", "subnet_id": "5c782260-b337-4173-a76b-70a438c0cb01", "ip_address": "1.1.1.1", "mac_address": null}]	["74c5810f-a62f-4336-a06b-f405fe27e3c6"]	[{"id": "09df4962-c85e-4bcd-a347-e6b577860ad4", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-14 22:16:49.696944+00	2025-11-14 22:16:49.701581+00	f
d6edcd40-ad4d-46c5-8908-a750d5736914	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "1c89e643-049a-4043-98a6-d7ea5f2449e7"}	[{"id": "b27ecaf6-aa08-4d73-a4fb-1d3df9f196df", "name": "Internet", "subnet_id": "5c782260-b337-4173-a76b-70a438c0cb01", "ip_address": "203.0.113.251", "mac_address": null}]	["c4cca6a5-f036-4312-be1a-ff99a01f95d2"]	[{"id": "ceb6fadd-ee20-45f2-a7d9-afff80da3dfa", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-14 22:16:49.696948+00	2025-11-14 22:16:49.703879+00	f
bed67fd4-fda3-46d7-930a-1d48f9eea0b1	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "f7d04eaf-b42d-47a2-a4d2-81ded45ca68a"}	[{"id": "f94596bc-fba2-42e3-9f03-c4ac782c7a81", "name": "Remote Network", "subnet_id": "c0edc5bf-03e6-4549-95cf-7cf807378072", "ip_address": "203.0.113.58", "mac_address": null}]	["b57ba8d3-142c-4c33-9658-ff2103ca76c3"]	[{"id": "e9b65096-b9f6-42e6-b2c1-b5d9667da50d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-14 22:16:49.696951+00	2025-11-14 22:16:49.705376+00	f
b940a995-df65-4dc0-9f56-720b1c6bafab	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "72510c7c-ddd0-4375-8153-005944f92e43", "name": null, "subnet_id": "fb88a2e2-5092-49d8-8180-0ce5be260ca0", "ip_address": "172.25.0.3", "mac_address": "56:22:5F:9F:6A:67"}]	["ae1b2eb2-3c56-477d-8540-62be2c5c6e3a"]	[{"id": "c2ebc0df-af62-446c-811f-ff1c546759ab", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:16:51.999434010Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-14 22:16:51.999438+00	2025-11-14 22:17:03.954019+00	f
2c3cd6ab-142a-4e5d-b739-20c288e28a27	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	netvisor-postgres-1.netvisor_netvisor-dev	netvisor-postgres-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ce5db145-d0d5-4f10-a655-2ce56c485f55", "name": null, "subnet_id": "fb88a2e2-5092-49d8-8180-0ce5be260ca0", "ip_address": "172.25.0.6", "mac_address": "D6:F3:3F:DE:A5:EA"}]	["cd88798a-0022-4830-99e9-0c0434e79d8a"]	[{"id": "f2906758-0882-429c-b484-e1ceab535a9c", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:17:04.010978627Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-14 22:17:04.010981+00	2025-11-14 22:17:16.244041+00	f
d8c0edfe-1132-4f67-91d9-9dbbbc88f231	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	172.25.0.4	a56a6eb13cbc	NetVisor daemon	{"type": "None"}	[{"id": "441261e0-23c3-49cc-842f-0247ff04725a", "name": "eth0", "subnet_id": "fb88a2e2-5092-49d8-8180-0ce5be260ca0", "ip_address": "172.25.0.4", "mac_address": "DE:A5:60:B1:11:9B"}]	["7d5f0799-3654-445f-9200-1e3fd0b3f4b1", "b723a8dd-37f4-45f1-bd12-bdae4464b227"]	[{"id": "4e9ba7d5-64a0-41ae-b291-5f66072a45d4", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:16:51.985982552Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-14T22:16:49.770508467Z", "type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649"}]}	null	2025-11-14 22:16:49.723219+00	2025-11-14 22:16:52.03882+00	f
3305c299-57d2-4070-bda9-ae4abfe45fcc	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1be6cb8b-a1d3-4cfd-aa84-da96cdcbce90", "name": null, "subnet_id": "fb88a2e2-5092-49d8-8180-0ce5be260ca0", "ip_address": "172.25.0.5", "mac_address": "FA:4B:6D:DA:94:20"}]	["fc69392f-1534-4073-a8be-ada01b68aaaf"]	[{"id": "a3680ab8-91f9-44e6-9dd9-2b37d5701cbe", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:17:16.083894299Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-14 22:17:16.083897+00	2025-11-14 22:17:25.642186+00	f
faa44871-ae90-478c-823d-019317d4703a	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "f2d264a1-8c12-45da-b3d9-f00c19a0300a", "name": null, "subnet_id": "fb88a2e2-5092-49d8-8180-0ce5be260ca0", "ip_address": "172.25.0.1", "mac_address": "46:86:A6:DE:C4:C8"}]	["69ef1882-b99d-4dd5-831f-4a6d1662ba23", "38221ad4-c94d-4be8-8406-90eb00bc510d", "07d9d61b-0887-4622-8322-ba51c9e217a2"]	[{"id": "23be0c41-ea7c-44f2-855a-0ebc68ece8fc", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "243909cb-1d63-4b60-95c7-ac780cb61db4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "d2495a16-185d-4d5a-8c05-42f941ad8093", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:17:29.797165041Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-14 22:17:29.797169+00	2025-11-14 22:17:39.18949+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	My Network	2025-11-14 22:16:49.696206+00	2025-11-14 22:16:49.696206+00	t	e3ece293-adb6-483c-a02c-6aab8ebbf59b
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
74c5810f-a62f-4336-a06b-f405fe27e3c6	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.696945+00	2025-11-14 22:16:49.696945+00	Cloudflare DNS	dc34a9b6-c525-4f58-a4b8-f199b3d2bbc3	[{"id": "672a1f3a-1da5-49eb-84c1-dac54618aea3", "type": "Port", "port_id": "09df4962-c85e-4bcd-a347-e6b577860ad4", "interface_id": "3bc28dbc-c31c-4bf9-baba-b71e0f982c8b"}]	"Dns Server"	null	{"type": "System"}
c4cca6a5-f036-4312-be1a-ff99a01f95d2	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.696949+00	2025-11-14 22:16:49.696949+00	Google.com	d6edcd40-ad4d-46c5-8908-a750d5736914	[{"id": "1c89e643-049a-4043-98a6-d7ea5f2449e7", "type": "Port", "port_id": "ceb6fadd-ee20-45f2-a7d9-afff80da3dfa", "interface_id": "b27ecaf6-aa08-4d73-a4fb-1d3df9f196df"}]	"Web Service"	null	{"type": "System"}
b57ba8d3-142c-4c33-9658-ff2103ca76c3	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.696952+00	2025-11-14 22:16:49.696952+00	Mobile Device	bed67fd4-fda3-46d7-930a-1d48f9eea0b1	[{"id": "f7d04eaf-b42d-47a2-a4d2-81ded45ca68a", "type": "Port", "port_id": "e9b65096-b9f6-42e6-b2c1-b5d9667da50d", "interface_id": "f94596bc-fba2-42e3-9f03-c4ac782c7a81"}]	"Client"	null	{"type": "System"}
7d5f0799-3654-445f-9200-1e3fd0b3f4b1	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.770528+00	2025-11-14 22:16:52.037921+00	NetVisor Daemon API	d8c0edfe-1132-4f67-91d9-9dbbbc88f231	[{"id": "bb52fc4a-19ed-4b2f-810f-665a6e586fce", "type": "Port", "port_id": "4e9ba7d5-64a0-41ae-b291-5f66072a45d4", "interface_id": "441261e0-23c3-49cc-842f-0247ff04725a"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-14T22:16:51.986690093Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-14T22:16:49.770525634Z", "type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649"}]}
ae1b2eb2-3c56-477d-8540-62be2c5c6e3a	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:59.145083+00	2025-11-14 22:16:59.145083+00	NetVisor Server API	b940a995-df65-4dc0-9f56-720b1c6bafab	[{"id": "ae34ef12-28fa-4673-9251-fb075d801e68", "type": "Port", "port_id": "c2ebc0df-af62-446c-811f-ff1c546759ab", "interface_id": "72510c7c-ddd0-4375-8153-005944f92e43"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-14T22:16:59.145048472Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
cd88798a-0022-4830-99e9-0c0434e79d8a	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:17:16.033244+00	2025-11-14 22:17:16.033244+00	PostgreSQL	2c3cd6ab-142a-4e5d-b739-20c288e28a27	[{"id": "a95dd4c7-98f5-4c21-8cae-876285a7cc73", "type": "Port", "port_id": "f2906758-0882-429c-b484-e1ceab535a9c", "interface_id": "ce5db145-d0d5-4f10-a655-2ce56c485f55"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-14T22:17:16.033211091Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
fc69392f-1534-4073-a8be-ada01b68aaaf	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:17:25.603909+00	2025-11-14 22:17:25.603909+00	Home Assistant	3305c299-57d2-4070-bda9-ae4abfe45fcc	[{"id": "df86df08-d55e-4164-bf83-cbfbcc17d9fe", "type": "Port", "port_id": "a3680ab8-91f9-44e6-9dd9-2b37d5701cbe", "interface_id": "1be6cb8b-a1d3-4cfd-aa84-da96cdcbce90"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-14T22:17:25.603841178Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
69ef1882-b99d-4dd5-831f-4a6d1662ba23	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:17:35.909837+00	2025-11-14 22:17:35.909837+00	NetVisor Server API	faa44871-ae90-478c-823d-019317d4703a	[{"id": "37ba8a96-42fe-4ce7-8c7b-92e6a287d558", "type": "Port", "port_id": "23be0c41-ea7c-44f2-855a-0ebc68ece8fc", "interface_id": "f2d264a1-8c12-45da-b3d9-f00c19a0300a"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-14T22:17:35.909830586Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
07d9d61b-0887-4622-8322-ba51c9e217a2	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:17:39.145016+00	2025-11-14 22:17:39.145016+00	PostgreSQL	faa44871-ae90-478c-823d-019317d4703a	[{"id": "6177cf12-7c9e-4508-868f-2248d7781dea", "type": "Port", "port_id": "d2495a16-185d-4d5a-8c05-42f941ad8093", "interface_id": "f2d264a1-8c12-45da-b3d9-f00c19a0300a"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-14T22:17:39.145014462Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
38221ad4-c94d-4be8-8406-90eb00bc510d	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:17:39.144612+00	2025-11-14 22:17:39.144612+00	Home Assistant	faa44871-ae90-478c-823d-019317d4703a	[{"id": "d631f800-0c38-4ddd-8ac8-718f060a05cf", "type": "Port", "port_id": "243909cb-1d63-4b60-95c7-ac780cb61db4", "interface_id": "f2d264a1-8c12-45da-b3d9-f00c19a0300a"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-14T22:17:39.144596171Z", "type": "Network", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
5c782260-b337-4173-a76b-70a438c0cb01	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.696896+00	2025-11-14 22:16:49.696896+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
c0edc5bf-03e6-4549-95cf-7cf807378072	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.696897+00	2025-11-14 22:16:49.696897+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
fb88a2e2-5092-49d8-8180-0ce5be260ca0	b01fe8ac-afa9-4492-9c0c-76ac2ab63a4d	2025-11-14 22:16:49.764876+00	2025-11-14 22:16:49.764876+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-14T22:16:49.764872134Z", "type": "SelfReport", "host_id": "d8c0edfe-1132-4f67-91d9-9dbbbc88f231", "daemon_id": "1af42567-82b6-4caf-a2bc-07c97b53f649"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
e3ece293-adb6-483c-a02c-6aab8ebbf59b	2025-11-14 22:16:49.695495+00	2025-11-14 22:16:55.714623+00	$argon2id$v=19$m=19456,t=2,p=1$+kNplng1fuNyy2R807jWgA$oJ+2syepKjuwdSlpiLGXfm6R40BGy18F5DUS7oUzhQE	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
cfjCL365hjn6vlN6x9qU4A	\\x93c410e094dac77a53befa3986b97e2fc2f87181a7757365725f6964d92465336563653239332d616462362d343833632d613032632d36616162386562626635396299cd07e9cd015c161037ce2ab8945f000000	2025-12-14 22:16:55.716739+00
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

\unrestrict AboSGC5z0TJHejpGxGzbaWfB6VAlsXFWHyHen8QxAzFpDpdfjwLDjhW7CzRx2Dw

