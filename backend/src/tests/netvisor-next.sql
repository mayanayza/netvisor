--
-- PostgreSQL database dump
--

\restrict Hxy3svrae5UVumE8LD8WywdNrEl930CrmXn0GlOF9nSYneYp5aK5E6bbNCl2zED

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
20251006215000	users	2025-11-13 15:04:01.80244+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2287083
20251006215100	networks	2025-11-13 15:04:01.80565+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2610834
20251006215151	create hosts	2025-11-13 15:04:01.808476+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1333500
20251006215155	create subnets	2025-11-13 15:04:01.81+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1654166
20251006215201	create groups	2025-11-13 15:04:01.811818+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1398542
20251006215204	create daemons	2025-11-13 15:04:01.813415+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1698750
20251006215212	create services	2025-11-13 15:04:01.815314+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1616750
20251029193448	user-auth	2025-11-13 15:04:01.817089+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6110250
20251030044828	daemon api	2025-11-13 15:04:01.8234+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	683833
20251030170438	host-hide	2025-11-13 15:04:01.824294+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	541792
20251102224919	create discovery	2025-11-13 15:04:01.824984+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	5750583
20251106235621	normalize-daemon-cols	2025-11-13 15:04:01.830926+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	683250
20251107034459	api keys	2025-11-13 15:04:01.831754+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	4362541
20251107222650	oidc-auth	2025-11-13 15:04:01.836301+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	15089666
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
aed47149-92ca-4d61-91bc-6e8361143013	46255ae437d748c3a88d734207703510	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	Integrated Daemon API Key	2025-11-13 15:04:01.90424+00	2025-11-13 15:04:47.611567+00	2025-11-13 15:04:47.611431+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
686e4083-41de-4526-b3ab-a01b7c8b2e61	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	ed3f60e9-022b-4e93-a2fd-7e7b42fb1739	"172.25.0.4"	60073	2025-11-13 15:04:01.959888+00	2025-11-13 15:04:01.959887+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["20c79a55-a1c9-4db8-876f-d66ee7058889"]}	2025-11-13 15:04:01.968964+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
d88366f0-0cf6-42b0-bc39-025faa81baaf	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	686e4083-41de-4526-b3ab-a01b7c8b2e61	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739"}	Self Report @ 172.25.0.4	2025-11-13 15:04:01.960742+00	2025-11-13 15:04:01.960742+00
05e8bc9a-ec35-44f6-9c37-c079bf964fb6	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	686e4083-41de-4526-b3ab-a01b7c8b2e61	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-13 15:04:01.964291+00	2025-11-13 15:04:01.964291+00
34160f17-dba7-4d85-b1ae-9645ab798b24	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	686e4083-41de-4526-b3ab-a01b7c8b2e61	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "processed": 1, "network_id": "496a1e81-f881-4d3f-9f9d-2ddb8881fedf", "session_id": "81064632-ac6c-43bd-8e84-5e66f0b17d2b", "started_at": "2025-11-13T15:04:01.964127048Z", "finished_at": "2025-11-13T15:04:01.978234382Z", "discovery_type": {"type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739"}	Discovery Run	2025-11-13 15:04:01.964127+00	2025-11-13 15:04:01.979264+00
f0ed9ac1-0198-4ff3-851b-369def69119a	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	686e4083-41de-4526-b3ab-a01b7c8b2e61	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "processed": 11, "network_id": "496a1e81-f881-4d3f-9f9d-2ddb8881fedf", "session_id": "ad9e5c64-11ed-436e-9ccd-1d69f872b28b", "started_at": "2025-11-13T15:04:01.984664798Z", "finished_at": "2025-11-13T15:04:47.610891375Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-13 15:04:01.984664+00	2025-11-13 15:04:47.611546+00
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
9873f016-10cc-4511-8bcc-203d61c5acb3	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "069ad633-561f-45cb-b81e-15cde84ea475"}	[{"id": "b73fa3c0-e68c-48e4-b44a-c62a06de4b9c", "name": "Internet", "subnet_id": "168f0db1-8e23-45da-93f6-26a3ba1c8cfc", "ip_address": "1.1.1.1", "mac_address": null}]	["8fd01826-a2c6-4a5f-b8d8-87e21c63ed6b"]	[{"id": "7c4a81e9-e632-41ed-bd53-cd727986f082", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-13 15:04:01.893573+00	2025-11-13 15:04:01.899059+00	f
16c07186-48bb-40dd-8f85-8534205d1f10	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	Google.com	\N	\N	{"type": "ServiceBinding", "config": "25b46537-fa01-4f25-9de7-ff3469913d67"}	[{"id": "ef18f5ff-8f2f-43aa-b307-9ea15bd9dd2a", "name": "Internet", "subnet_id": "168f0db1-8e23-45da-93f6-26a3ba1c8cfc", "ip_address": "203.0.113.200", "mac_address": null}]	["bf46fdb5-b4ef-46a5-9e13-53d0e17088dd"]	[{"id": "4b01289d-ebab-4d11-a675-45bcf7446dbe", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:04:01.893577+00	2025-11-13 15:04:01.90225+00	f
5f2caf45-0065-4fee-b0ae-a85917c0d8f2	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "a480b762-546a-4aa6-b6cd-7bd9fabbb0d3"}	[{"id": "8097c969-724a-46dc-9f9a-2496e7e8b287", "name": "Remote Network", "subnet_id": "f0a49f36-0920-4d2e-a791-8f45763f052a", "ip_address": "203.0.113.119", "mac_address": null}]	["d0fa73c4-3ec0-4e85-a270-99b6e8157df3"]	[{"id": "d8949e6d-6432-4973-b3d8-b3d54ace1494", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 15:04:01.893579+00	2025-11-13 15:04:01.903884+00	f
a32d62f0-3b88-47e1-9a94-fcea3606a78f	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "db45c48d-17a0-4f61-a4de-3a72f2061fa6", "name": null, "subnet_id": "20c79a55-a1c9-4db8-876f-d66ee7058889", "ip_address": "172.25.0.5", "mac_address": "C6:29:BB:9C:AC:3F"}]	["48f48ff3-762f-4b1f-997a-665b706d8d7f"]	[{"id": "5e340b5c-33aa-45e6-b94d-88b129937978", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:13.822434554Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:04:13.822444+00	2025-11-13 15:04:23.227817+00	f
b8930f82-c50b-40e9-8136-851f551dee47	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "cfed6a9b-3336-4d2e-ac95-2a8f7c0df3db", "name": null, "subnet_id": "20c79a55-a1c9-4db8-876f-d66ee7058889", "ip_address": "172.25.0.3", "mac_address": "E6:C5:A0:87:18:BE"}]	["cdc3eff7-1ed6-48bb-b1a1-8bf992fa0c26"]	[{"id": "6851f7da-ed5a-4baa-bb7f-f9b20808e670", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:04.179419008Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:04:04.17942+00	2025-11-13 15:04:23.247048+00	f
ed3f60e9-022b-4e93-a2fd-7e7b42fb1739	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	172.25.0.4	8ce16b67c2de	NetVisor daemon	{"type": "None"}	[{"id": "34bfd206-27de-4afe-a509-d0db244a62aa", "name": "eth0", "subnet_id": "20c79a55-a1c9-4db8-876f-d66ee7058889", "ip_address": "172.25.0.4", "mac_address": "AE:42:89:44:47:A9"}]	["ce1649e8-e740-482d-99f6-650f34ff8e59", "e2cb68a0-d498-4067-bb22-92396f9ab3d6"]	[{"id": "749bbee4-1427-4eb7-9bfe-38e7c4a01e5a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:04.175010299Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-13T15:04:01.969987298Z", "type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61"}]}	null	2025-11-13 15:04:01.925642+00	2025-11-13 15:04:04.179112+00	f
72248cec-15d2-4f14-973b-fc008b497789	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	netvisor-postgres-1.netvisor_netvisor-dev	netvisor-postgres-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "01abf52e-6c37-4ee8-b6ff-e7cf6f581a7b", "name": null, "subnet_id": "20c79a55-a1c9-4db8-876f-d66ee7058889", "ip_address": "172.25.0.6", "mac_address": "76:52:7F:8A:D0:A6"}]	["562b3fb9-62b3-4122-a8ee-2111fcf69ef4"]	[{"id": "43376a8e-ffe3-414d-8db9-f66e3cdc6e8c", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:23.167956919Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:04:23.167959+00	2025-11-13 15:04:32.393546+00	f
10ee27ef-d2ab-4ca6-92af-9213087bebe4	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "53d5ac80-cb78-47a5-b6ec-0dbd125024e3", "name": null, "subnet_id": "20c79a55-a1c9-4db8-876f-d66ee7058889", "ip_address": "172.25.0.1", "mac_address": "A6:90:39:D7:CE:F5"}]	["51ec5936-00cb-4782-abb3-ad93a9f8748f", "5d046a40-3b45-4fa7-9800-02062d443f41", "e8edeac9-2e15-4992-9888-4a858f1cf271"]	[{"id": "889d70c0-ce32-422d-9a16-d96011fffe63", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "8ab1912d-7c07-4f66-be12-318a5735e048", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "47307ec7-b69c-40f0-8f4e-9bb1ef4e986d", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:38.542703593Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-13 15:04:38.542715+00	2025-11-13 15:04:47.60922+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
496a1e81-f881-4d3f-9f9d-2ddb8881fedf	My Network	2025-11-13 15:04:01.892836+00	2025-11-13 15:04:01.892836+00	t	58b9e9c0-b85e-4600-bca3-552d5288c9f7
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
8fd01826-a2c6-4a5f-b8d8-87e21c63ed6b	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.893574+00	2025-11-13 15:04:01.893574+00	Cloudflare DNS	9873f016-10cc-4511-8bcc-203d61c5acb3	[{"id": "069ad633-561f-45cb-b81e-15cde84ea475", "type": "Port", "port_id": "7c4a81e9-e632-41ed-bd53-cd727986f082", "interface_id": "b73fa3c0-e68c-48e4-b44a-c62a06de4b9c"}]	"Dns Server"	null	{"type": "System"}
bf46fdb5-b4ef-46a5-9e13-53d0e17088dd	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.893577+00	2025-11-13 15:04:01.893577+00	Google.com	16c07186-48bb-40dd-8f85-8534205d1f10	[{"id": "25b46537-fa01-4f25-9de7-ff3469913d67", "type": "Port", "port_id": "4b01289d-ebab-4d11-a675-45bcf7446dbe", "interface_id": "ef18f5ff-8f2f-43aa-b307-9ea15bd9dd2a"}]	"Web Service"	null	{"type": "System"}
d0fa73c4-3ec0-4e85-a270-99b6e8157df3	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.89358+00	2025-11-13 15:04:01.89358+00	Mobile Device	5f2caf45-0065-4fee-b0ae-a85917c0d8f2	[{"id": "a480b762-546a-4aa6-b6cd-7bd9fabbb0d3", "type": "Port", "port_id": "d8949e6d-6432-4973-b3d8-b3d54ace1494", "interface_id": "8097c969-724a-46dc-9f9a-2496e7e8b287"}]	"Client"	null	{"type": "System"}
ce1649e8-e740-482d-99f6-650f34ff8e59	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.970026+00	2025-11-13 15:04:04.178673+00	NetVisor Daemon API	ed3f60e9-022b-4e93-a2fd-7e7b42fb1739	[{"id": "f2a8e605-b1ff-4b67-a108-47c94729b894", "type": "Port", "port_id": "749bbee4-1427-4eb7-9bfe-38e7c4a01e5a", "interface_id": "34bfd206-27de-4afe-a509-d0db244a62aa"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-13T15:04:04.175439883Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-13T15:04:01.970020090Z", "type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61"}]}
48f48ff3-762f-4b1f-997a-665b706d8d7f	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:20.37981+00	2025-11-13 15:04:20.37981+00	Home Assistant	a32d62f0-3b88-47e1-9a94-fcea3606a78f	[{"id": "243f6d68-8113-4242-bb29-d764e198a3ff", "type": "Port", "port_id": "5e340b5c-33aa-45e6-b94d-88b129937978", "interface_id": "db45c48d-17a0-4f61-a4de-3a72f2061fa6"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/tcp/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:04:20.379793584Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
cdc3eff7-1ed6-48bb-b1a1-8bf992fa0c26	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:05.642997+00	2025-11-13 15:04:05.642997+00	NetVisor Server API	b8930f82-c50b-40e9-8136-851f551dee47	[{"id": "0f67fb35-ea32-4031-96c3-3319e3a18e26", "type": "Port", "port_id": "6851f7da-ed5a-4baa-bb7f-f9b20808e670", "interface_id": "cfed6a9b-3336-4d2e-ac95-2a8f7c0df3db"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/tcp/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:04:05.642990967Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
562b3fb9-62b3-4122-a8ee-2111fcf69ef4	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:32.387123+00	2025-11-13 15:04:32.387123+00	PostgreSQL	72248cec-15d2-4f14-973b-fc008b497789	[{"id": "d0e172b6-5197-41fd-977d-5615ed055108", "type": "Port", "port_id": "43376a8e-ffe3-414d-8db9-f66e3cdc6e8c", "interface_id": "01abf52e-6c37-4ee8-b6ff-e7cf6f581a7b"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:04:32.387114673Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
51ec5936-00cb-4782-abb3-ad93a9f8748f	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:39.992972+00	2025-11-13 15:04:39.992972+00	NetVisor Server API	10ee27ef-d2ab-4ca6-92af-9213087bebe4	[{"id": "b8bf1f7a-4daf-4acd-a903-03bee2303ada", "type": "Port", "port_id": "889d70c0-ce32-422d-9a16-d96011fffe63", "interface_id": "53d5ac80-cb78-47a5-b6ec-0dbd125024e3"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/tcp/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:04:39.992967010Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
e8edeac9-2e15-4992-9888-4a858f1cf271	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:47.578833+00	2025-11-13 15:04:47.578833+00	PostgreSQL	10ee27ef-d2ab-4ca6-92af-9213087bebe4	[{"id": "737c1e7e-ea12-40ac-bbd2-d8ba62fcc6ad", "type": "Port", "port_id": "47307ec7-b69c-40f0-8f4e-9bb1ef4e986d", "interface_id": "53d5ac80-cb78-47a5-b6ec-0dbd125024e3"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-13T15:04:47.578825875Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5d046a40-3b45-4fa7-9800-02062d443f41	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:44.874967+00	2025-11-13 15:04:44.874967+00	Home Assistant	10ee27ef-d2ab-4ca6-92af-9213087bebe4	[{"id": "c10c1097-0747-4931-931d-f4c7ef02ba5b", "type": "Port", "port_id": "8ab1912d-7c07-4f66-be12-318a5735e048", "interface_id": "53d5ac80-cb78-47a5-b6ec-0dbd125024e3"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/tcp/auth/authorize contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-13T15:04:44.874957971Z", "type": "Network", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
168f0db1-8e23-45da-93f6-26a3ba1c8cfc	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.893538+00	2025-11-13 15:04:01.893538+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
f0a49f36-0920-4d2e-a791-8f45763f052a	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.893539+00	2025-11-13 15:04:01.893539+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
20c79a55-a1c9-4db8-876f-d66ee7058889	496a1e81-f881-4d3f-9f9d-2ddb8881fedf	2025-11-13 15:04:01.965057+00	2025-11-13 15:04:01.965057+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-13T15:04:01.965053840Z", "type": "SelfReport", "host_id": "ed3f60e9-022b-4e93-a2fd-7e7b42fb1739", "daemon_id": "686e4083-41de-4526-b3ab-a01b7c8b2e61"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
58b9e9c0-b85e-4600-bca3-552d5288c9f7	2025-11-13 15:04:01.892172+00	2025-11-13 15:04:02.893136+00	$argon2id$v=19$m=19456,t=2,p=1$zaJrRJQMish8m+8jcNu/bA$HuzjiRU8o1j/qwMCc/gq8gQI7KIif7DORnh/NZ/oM1s	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
BtK7B8IgBW8a5g2FVy9kPQ	\\x93c4103d642f57850de61a6f0520c207bbd20681a7757365725f6964d92435386239653963302d623835652d343630302d626361332d35353264353238386339663799cd07e9cd015b0f0402ce354f63f6000000	2025-12-13 15:04:02.894395+00
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

\unrestrict Hxy3svrae5UVumE8LD8WywdNrEl930CrmXn0GlOF9nSYneYp5aK5E6bbNCl2zED

