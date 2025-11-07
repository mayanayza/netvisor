--
-- PostgreSQL database dump
--

\restrict K7i5alqpP8ztnYZvsgQOdMs9dLzVEM8g59gQhUCZn9JOtVwzSMrnDqrdCBgBdJ8

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
DROP INDEX IF EXISTS public.idx_users_name_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_discovery_network;
DROP INDEX IF EXISTS public.idx_discovery_daemon;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemons_api_key_hash;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
ALTER TABLE IF EXISTS ONLY tower_sessions.session DROP CONSTRAINT IF EXISTS session_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_pkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
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
    api_key text,
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
20251006215000	users	2025-11-07 02:08:32.054283+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4443542
20251006215100	networks	2025-11-07 02:08:32.05966+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2690542
20251006215151	create hosts	2025-11-07 02:08:32.062665+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1998000
20251006215155	create subnets	2025-11-07 02:08:32.064875+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1932292
20251006215201	create groups	2025-11-07 02:08:32.06697+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1607750
20251006215204	create daemons	2025-11-07 02:08:32.068752+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1630792
20251006215212	create services	2025-11-07 02:08:32.070561+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1507208
20251029193448	user-auth	2025-11-07 02:08:32.072218+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6834542
20251030044828	daemon api	2025-11-07 02:08:32.079198+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	545791
20251030170438	host-hide	2025-11-07 02:08:32.079891+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	449000
20251102224919	create discovery	2025-11-07 02:08:32.080471+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	4995042
20251106235621	normalize-daemon-cols	2025-11-07 02:08:32.085644+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	636791
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, api_key, capabilities, updated_at) FROM stdin;
9509473a-f57b-4688-8f96-de46a42d5bf2	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	c355e0af-f69e-417c-a9cd-10e31075ea14	"172.25.0.4"	60073	2025-11-07 02:08:32.154169+00	2025-11-07 02:08:32.154168+00	ec97366f658246a8880c9dfdf3fa620f	{"has_docker_socket": false, "interfaced_subnet_ids": ["eb1fc196-3555-4b79-9b20-e8ab205b8260"]}	2025-11-07 02:08:32.164772+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
d937d4c4-a0df-4167-a56f-ab09a296b398	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	9509473a-f57b-4688-8f96-de46a42d5bf2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14"}	Self Report @ 172.25.0.4	2025-11-07 02:08:32.154995+00	2025-11-07 02:08:32.154995+00
38502f69-8523-4ab4-bc67-45777bd72559	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	9509473a-f57b-4688-8f96-de46a42d5bf2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null}	Network Scan @ 172.25.0.4	2025-11-07 02:08:32.158723+00	2025-11-07 02:08:32.158723+00
db7b861b-8e68-48fb-b773-c76f006bdb9b	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	9509473a-f57b-4688-8f96-de46a42d5bf2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "processed": 1, "network_id": "6a35f4e9-fb9f-4f33-9514-7d35cd7552bf", "session_id": "b45d9540-0457-4358-ba35-96cfe119a652", "started_at": "2025-11-07T02:08:32.158863593Z", "finished_at": "2025-11-07T02:08:32.171283134Z", "discovery_type": {"type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14"}	Discovery Run	2025-11-07 02:08:32.158863+00	2025-11-07 02:08:32.172271+00
71b8c15d-637d-427b-a768-94f13492096f	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	9509473a-f57b-4688-8f96-de46a42d5bf2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "processed": 12, "network_id": "6a35f4e9-fb9f-4f33-9514-7d35cd7552bf", "session_id": "f5d793a2-1fb0-4254-a27c-1fd99844f1c3", "started_at": "2025-11-07T02:08:32.179002134Z", "finished_at": "2025-11-07T02:09:39.311029929Z", "discovery_type": {"type": "Network", "subnet_ids": null}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null}	Discovery Run	2025-11-07 02:08:32.179002+00	2025-11-07 02:09:39.326677+00
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
a2a0e3df-29c6-4d74-9b11-b315072a8bb2	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "4bd689bc-db1b-4cea-a816-24946c49e451"}	[{"id": "16bf2a8d-7dd5-4b8f-a58f-50e47e02564a", "name": "Internet", "subnet_id": "0100571b-fc3e-4797-b338-3489c9c8c04c", "ip_address": "1.1.1.1", "mac_address": null}]	["2b65b135-f3c9-4d9d-b234-dd9cbe25c107"]	[{"id": "ed53c0d7-61aa-4291-aa10-3cfad4e468a0", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-07 02:08:32.124084+00	2025-11-07 02:08:32.130196+00	f
da06c54f-0dec-4595-94c7-a1f26120cbd6	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	Google.com	\N	\N	{"type": "ServiceBinding", "config": "51f58140-2315-4c1b-8cf3-4f1a90256d6d"}	[{"id": "bec9d067-cfe4-4bc3-9bb6-f4f980628626", "name": "Internet", "subnet_id": "0100571b-fc3e-4797-b338-3489c9c8c04c", "ip_address": "203.0.113.245", "mac_address": null}]	["b894bd99-ae47-47d0-8df2-100c8cdbdb1e"]	[{"id": "c93454c6-bc67-479d-bab5-ae764c6da001", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-07 02:08:32.124086+00	2025-11-07 02:08:32.13296+00	f
9edc9ccd-2ef1-4d23-969c-27a0d68ce015	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "c155fa07-35da-4016-9195-8d3771d7061c"}	[{"id": "cb9cfd5e-4db3-4c57-9247-07ef664e52cf", "name": "Remote Network", "subnet_id": "5e250056-37e7-46bf-9c0a-b11131d19547", "ip_address": "203.0.113.74", "mac_address": null}]	["82e532f1-372e-4d22-a05c-19a779009888"]	[{"id": "10ae57ca-b710-46f7-883a-345abfe677df", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-07 02:08:32.124088+00	2025-11-07 02:08:32.135718+00	f
c355e0af-f69e-417c-a9cd-10e31075ea14	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	172.25.0.4	9b7c9ae4e210	NetVisor daemon	{"type": "None"}	[{"id": "1c24885b-b8c9-4547-b310-183b30cc5bca", "name": "eth0", "subnet_id": "eb1fc196-3555-4b79-9b20-e8ab205b8260", "ip_address": "172.25.0.4", "mac_address": "36:CD:41:9C:95:A4"}]	["2d11902c-f081-4e23-ab14-1a1925be90f6", "55defcfe-3cb1-42f9-9cb6-1cba6635b510"]	[{"id": "77110c21-12a8-4c7a-a904-668ab1cb64d7", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T02:08:45.267297918Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}, {"date": "2025-11-07T02:08:32.165523718Z", "type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2"}]}	null	2025-11-07 02:08:32.15174+00	2025-11-07 02:08:54.332018+00	f
599f1a25-ac98-4592-ba99-fd6af98cfb93	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c3dccc58-b3b8-49e9-b389-c9076831a579", "name": null, "subnet_id": "eb1fc196-3555-4b79-9b20-e8ab205b8260", "ip_address": "172.25.0.3", "mac_address": "1A:8E:C2:48:CD:6F"}]	["7a14ff5f-f199-4506-a95d-9df8ba224657"]	[{"id": "eb9ebd6e-4eb6-44bf-b81b-9eb212f0bc89", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T02:08:36.232239136Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}	null	2025-11-07 02:08:36.232249+00	2025-11-07 02:08:45.273669+00	f
2236a7b6-79c1-47c9-916c-6b40d5bd874b	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "81deb246-1284-4987-a49f-332cd74c7348", "name": null, "subnet_id": "eb1fc196-3555-4b79-9b20-e8ab205b8260", "ip_address": "172.25.0.5", "mac_address": "AE:65:70:85:57:41"}]	["87beb3e1-ddac-4417-be0f-926abaa61376"]	[{"id": "2280be47-f0ea-459c-96fd-e197d6b16f3d", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T02:08:45.268064460Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}	null	2025-11-07 02:08:45.268064+00	2025-11-07 02:09:04.107021+00	f
337ecdec-6234-4243-acd8-2d7f64d5c4e5	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "fc118e64-4301-4bb8-b511-935c7b405ad8", "name": null, "subnet_id": "eb1fc196-3555-4b79-9b20-e8ab205b8260", "ip_address": "172.25.0.1", "mac_address": "F6:A5:5F:30:AB:E4"}]	["14c9cb0b-40ff-4a9d-b107-dc3bb1e73307", "d5a72f83-b0d2-4a04-aa47-78a78e84bdf8"]	[{"id": "63145d20-c4b3-4859-97aa-4293b2ac3fc7", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "7c6e57f9-dc17-4aa0-a16a-fb1f4047250a", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-07T02:08:54.327002547Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}	null	2025-11-07 02:08:54.327004+00	2025-11-07 02:09:04.110374+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	My Network	2025-11-07 02:08:32.123062+00	2025-11-07 02:08:32.123062+00	t	836a7095-17c2-405f-854e-430cdd84d659
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
2b65b135-f3c9-4d9d-b234-dd9cbe25c107	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.124085+00	2025-11-07 02:08:32.129683+00	Cloudflare DNS	a2a0e3df-29c6-4d74-9b11-b315072a8bb2	[{"id": "4bd689bc-db1b-4cea-a816-24946c49e451", "type": "Port", "port_id": "ed53c0d7-61aa-4291-aa10-3cfad4e468a0", "interface_id": "16bf2a8d-7dd5-4b8f-a58f-50e47e02564a"}]	"Dns Server"	null	{"type": "System"}
b894bd99-ae47-47d0-8df2-100c8cdbdb1e	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.124087+00	2025-11-07 02:08:32.132647+00	Google.com	da06c54f-0dec-4595-94c7-a1f26120cbd6	[{"id": "51f58140-2315-4c1b-8cf3-4f1a90256d6d", "type": "Port", "port_id": "c93454c6-bc67-479d-bab5-ae764c6da001", "interface_id": "bec9d067-cfe4-4bc3-9bb6-f4f980628626"}]	"Web Service"	null	{"type": "System"}
82e532f1-372e-4d22-a05c-19a779009888	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.124089+00	2025-11-07 02:08:32.1354+00	Mobile Device	9edc9ccd-2ef1-4d23-969c-27a0d68ce015	[{"id": "c155fa07-35da-4016-9195-8d3771d7061c", "type": "Port", "port_id": "10ae57ca-b710-46f7-883a-345abfe677df", "interface_id": "cb9cfd5e-4db3-4c57-9247-07ef664e52cf"}]	"Client"	null	{"type": "System"}
d5a72f83-b0d2-4a04-aa47-78a78e84bdf8	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:59.664365+00	2025-11-07 02:09:04.109631+00	Home Assistant	337ecdec-6234-4243-acd8-2d7f64d5c4e5	[{"id": "e5cc2fc8-56e9-4540-a3ca-4c3641ecebe8", "type": "Port", "port_id": "7c6e57f9-dc17-4aa0-a16a-fb1f4047250a", "interface_id": "fc118e64-4301-4bb8-b511-935c7b405ad8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T02:08:59.664352800Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}
7a14ff5f-f199-4506-a95d-9df8ba224657	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:36.807744+00	2025-11-07 02:08:45.273096+00	NetVisor Server API	599f1a25-ac98-4592-ba99-fd6af98cfb93	[{"id": "df5ce4c0-2279-4305-a664-d0b3cee86fe1", "type": "Port", "port_id": "eb9ebd6e-4eb6-44bf-b81b-9eb212f0bc89", "interface_id": "c3dccc58-b3b8-49e9-b389-c9076831a579"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T02:08:36.807733220Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}
2d11902c-f081-4e23-ab14-1a1925be90f6	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.165541+00	2025-11-07 02:08:54.331557+00	NetVisor Daemon API	c355e0af-f69e-417c-a9cd-10e31075ea14	[{"id": "9a7b1f2a-e545-47e8-bdd7-e21fde833518", "type": "Port", "port_id": "77110c21-12a8-4c7a-a904-668ab1cb64d7", "interface_id": "1c24885b-b8c9-4547-b310-183b30cc5bca"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["NetVisor Daemon self-report", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-07T02:08:45.267502085Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}, {"date": "2025-11-07T02:08:32.165536884Z", "type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2"}]}
87beb3e1-ddac-4417-be0f-926abaa61376	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:50.259714+00	2025-11-07 02:09:04.105766+00	Home Assistant	2236a7b6-79c1-47c9-916c-6b40d5bd874b	[{"id": "0eec6ead-5610-4012-95ae-96f69687d647", "type": "Port", "port_id": "2280be47-f0ea-459c-96fd-e197d6b16f3d", "interface_id": "81deb246-1284-4987-a49f-332cd74c7348"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T02:08:50.259706920Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}
14c9cb0b-40ff-4a9d-b107-dc3bb1e73307	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:54.776754+00	2025-11-07 02:09:04.110018+00	NetVisor Server API	337ecdec-6234-4243-acd8-2d7f64d5c4e5	[{"id": "722f3b76-e1b9-48a2-83e5-203a6eab5059", "type": "Port", "port_id": "63145d20-c4b3-4859-97aa-4293b2ac3fc7", "interface_id": "fc118e64-4301-4bb8-b511-935c7b405ad8"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-07T02:08:54.776746464Z", "type": "Network", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2", "subnet_ids": null}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
0100571b-fc3e-4797-b338-3489c9c8c04c	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.124052+00	2025-11-07 02:08:32.124052+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
5e250056-37e7-46bf-9c0a-b11131d19547	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.124054+00	2025-11-07 02:08:32.124054+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
eb1fc196-3555-4b79-9b20-e8ab205b8260	6a35f4e9-fb9f-4f33-9514-7d35cd7552bf	2025-11-07 02:08:32.159888+00	2025-11-07 02:08:32.159888+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-07T02:08:32.159882218Z", "type": "SelfReport", "host_id": "c355e0af-f69e-417c-a9cd-10e31075ea14", "daemon_id": "9509473a-f57b-4688-8f96-de46a42d5bf2"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
836a7095-17c2-405f-854e-430cdd84d659	testuser	2025-11-07 02:08:32.122536+00	2025-11-07 02:08:33.273325+00	$argon2id$v=19$m=19456,t=2,p=1$GvJ01asFune6PBGSpF1vvw$E7n4DFlEj59ZUpE3yxvUG2UdjiIZDJUzqfX/HWkRobA	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
jWwP77agln0RQbUVDwvi0A	\\x93c410d0e20b0f15b541117d96a0b6ef0f6c8d81a7757365725f6964d92438333661373039352d313763322d343035662d383534652d34333063646438346436353999cd07e9cd0155020821ce1080662a000000	2025-12-07 02:08:33.27685+00
\.


--
-- Name: _sqlx_migrations _sqlx_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._sqlx_migrations
    ADD CONSTRAINT _sqlx_migrations_pkey PRIMARY KEY (version);


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
-- Name: idx_daemon_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemon_host_id ON public.daemons USING btree (host_id);


--
-- Name: idx_daemons_api_key_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_api_key_hash ON public.daemons USING btree (api_key);


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

\unrestrict K7i5alqpP8ztnYZvsgQOdMs9dLzVEM8g59gQhUCZn9JOtVwzSMrnDqrdCBgBdJ8

