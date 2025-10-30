--
-- PostgreSQL database dump
--

\restrict in3yZs1LRRUzoDCtu64WfeQQqDV3bvrxxaCSuWPPm2iUI1huLWxHALL1XCBYzLy

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
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_name_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
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
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS tower_sessions.session;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.groups;
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
    registered_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    api_key text
);


ALTER TABLE public.daemons OWNER TO postgres;

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
    updated_at timestamp with time zone NOT NULL
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
20251006215000	users	2025-10-30 15:38:02.031206+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3600458
20251006215100	networks	2025-10-30 15:38:02.035676+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3165333
20251006215151	create hosts	2025-10-30 15:38:02.039111+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1714083
20251006215155	create subnets	2025-10-30 15:38:02.041155+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2280833
20251006215201	create groups	2025-10-30 15:38:02.043645+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1615709
20251006215204	create daemons	2025-10-30 15:38:02.045474+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1846875
20251006215212	create services	2025-10-30 15:38:02.047525+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1782625
20251029193448	user-auth	2025-10-30 15:38:02.049506+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	8610667
20251030044828	daemon api	2025-10-30 15:38:02.058405+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	730791
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, registered_at, last_seen, api_key) FROM stdin;
3f9573cb-160c-456a-b79b-7a20b1e8a627	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	0c019c10-5130-4005-a1fb-810fcfa8e93e	"172.25.0.4"	60073	2025-10-30 15:38:02.158297+00	2025-10-30 15:38:02.158296+00	faacb396244c498096e748709bc50424
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at) FROM stdin;
d2bfda09-4366-4383-bdcb-4ea0c61a39eb	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	Cloudflare DNS	\N	Cloudflare DNS	{"type": "ServiceBinding", "config": "5a57c09f-8484-461f-9a17-6e16996191c5"}	[{"id": "8def9192-d1f2-4ae8-85e8-bd434608771e", "name": "Internet", "subnet_id": "5271b1ef-4424-45d1-a11f-288a4c7c0ccc", "ip_address": "1.1.1.1", "mac_address": null}]	["40466dd1-6c8d-4813-870d-4f48a9962875"]	[{"id": "c5d57b73-0cda-430d-a817-5fbac8aa10b6", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-10-30 15:38:02.108993+00	2025-10-30 15:38:02.120585+00
519f6256-b95d-46e9-819e-3f1ac5d8facd	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	Google.com	google.com	Google.com	{"type": "ServiceBinding", "config": "60be6dc9-c439-41b3-aa60-f1556368fd94"}	[{"id": "1269fd5a-a88a-4d29-ac82-dc50b6e45456", "name": "Internet", "subnet_id": "5271b1ef-4424-45d1-a11f-288a4c7c0ccc", "ip_address": "203.0.113.234", "mac_address": null}]	["0c35eec1-889d-410f-8198-cd4c767ff03b"]	[{"id": "7b35a8e5-2947-4cb9-bb76-8615474b1b2c", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-30 15:38:02.108998+00	2025-10-30 15:38:02.128074+00
3b9d915f-f4ba-4801-9302-7772e49924f1	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "7c646858-9e6d-4cfb-bb51-461e99afe5ad"}	[{"id": "e4e220d6-fa72-4f43-9adf-9f3b47e5c819", "name": "Remote Network", "subnet_id": "03fd25fe-1ba0-405f-b915-0afac2f2d528", "ip_address": "203.0.113.90", "mac_address": null}]	["de9d33e6-7ce6-425c-a0e7-d2ecff82e0ce"]	[{"id": "70c47ecf-3a96-42ee-9eba-d7171611c9ec", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-30 15:38:02.109002+00	2025-10-30 15:38:02.133661+00
0c019c10-5130-4005-a1fb-810fcfa8e93e	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	172.25.0.4	\N	\N	{"type": "None"}	[]	[]	[]	{"type": "Unknown"}	null	2025-10-30 15:38:02.153264+00	2025-10-30 15:38:02.157557+00
b248e52c-ec17-47ec-99c7-ab25a98fd3a1	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	NetVisor Daemon API	6b9202cb2426	\N	{"type": "Hostname"}	[{"id": "f39828ba-2a76-4a94-bbb6-3f7c4bab5ea6", "name": null, "subnet_id": "76766e55-ac07-4b35-a77f-c2cc084723fe", "ip_address": "172.25.0.4", "mac_address": null}]	["07b0011e-b808-4d9a-ae00-d821fcf8e630"]	[{"id": "abe28c41-1dd7-4d53-8166-aaa7524f4494", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T15:38:09.906023043Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}	null	2025-10-30 15:38:09.906058+00	2025-10-30 15:38:21.3426+00
02617a61-3a32-47b7-961e-9d602a98c86a	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	Home Assistant	\N	\N	{"type": "None"}	[{"id": "b2a8c8b6-b58a-43a8-977f-abe44705656f", "name": null, "subnet_id": "76766e55-ac07-4b35-a77f-c2cc084723fe", "ip_address": "172.25.0.1", "mac_address": "BE:FF:51:3F:11:10"}]	["f0a7ec49-7d38-45a9-80cf-4f9df45e0ccd", "277806ed-0fbd-48e4-9868-e48bceaed730"]	[{"id": "7706e2e7-a9ec-4e70-b5c5-9fd0f115f80c", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "069190fc-31fb-4c42-9eb1-0dfe07ce0122", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T15:38:30.846385887Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}	null	2025-10-30 15:38:30.846386+00	2025-10-30 15:38:40.524994+00
8c3615ac-1502-423c-a76f-14da824d7ce3	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e04a170e-75fc-41a2-a5f0-49dc1f416da1", "name": null, "subnet_id": "76766e55-ac07-4b35-a77f-c2cc084723fe", "ip_address": "172.25.0.5", "mac_address": "4E:20:99:2E:E3:B2"}]	["9f392f02-08af-4dc2-9b89-c9fb549c1a42"]	[{"id": "21d8a87f-d44b-4eac-8a19-2c5f30a758ab", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T15:38:21.331806924Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}	null	2025-10-30 15:38:21.331809+00	2025-10-30 15:38:40.525275+00
407ce7ce-ae5c-443d-a2a4-beebfbfd7c61	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "dab156f8-1d20-4d51-94e9-6ca62f418982", "name": null, "subnet_id": "76766e55-ac07-4b35-a77f-c2cc084723fe", "ip_address": "172.25.0.3", "mac_address": "86:0B:55:DC:6B:61"}]	["abab7c05-5955-470f-a57d-665a9ed62fe8"]	[{"id": "a11953c5-853b-4dff-8c18-ac6fe842a28a", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T15:38:09.907871168Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}	null	2025-10-30 15:38:09.907871+00	2025-10-30 15:38:40.534196+00
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	My Network	2025-10-30 15:38:02.107487+00	2025-10-30 15:38:02.10749+00	t	b60e7679-ee19-40e8-a05d-f8cb63922c66
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
40466dd1-6c8d-4813-870d-4f48a9962875	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.108995+00	2025-10-30 15:38:02.119532+00	Cloudflare DNS	d2bfda09-4366-4383-bdcb-4ea0c61a39eb	[{"id": "5a57c09f-8484-461f-9a17-6e16996191c5", "type": "Port", "port_id": "c5d57b73-0cda-430d-a817-5fbac8aa10b6", "interface_id": "8def9192-d1f2-4ae8-85e8-bd434608771e"}]	"Dns Server"	null	{"type": "System"}
0c35eec1-889d-410f-8198-cd4c767ff03b	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.109+00	2025-10-30 15:38:02.127291+00	Google.com	519f6256-b95d-46e9-819e-3f1ac5d8facd	[{"id": "60be6dc9-c439-41b3-aa60-f1556368fd94", "type": "Port", "port_id": "7b35a8e5-2947-4cb9-bb76-8615474b1b2c", "interface_id": "1269fd5a-a88a-4d29-ac82-dc50b6e45456"}]	"Web Service"	null	{"type": "System"}
de9d33e6-7ce6-425c-a0e7-d2ecff82e0ce	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.109003+00	2025-10-30 15:38:02.133123+00	Mobile Device	3b9d915f-f4ba-4801-9302-7772e49924f1	[{"id": "7c646858-9e6d-4cfb-bb51-461e99afe5ad", "type": "Port", "port_id": "70c47ecf-3a96-42ee-9eba-d7171611c9ec", "interface_id": "e4e220d6-fa72-4f43-9adf-9f3b47e5c819"}]	"Client"	null	{"type": "System"}
07b0011e-b808-4d9a-ae00-d821fcf8e630	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:09.906959+00	2025-10-30 15:38:21.341876+00	NetVisor Daemon API	b248e52c-ec17-47ec-99c7-ab25a98fd3a1	[{"id": "854a9068-7fbb-4454-9860-8dcee90dfde6", "type": "Port", "port_id": "abe28c41-1dd7-4d53-8166-aaa7524f4494", "interface_id": "f39828ba-2a76-4a94-bbb6-3f7c4bab5ea6"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T15:38:09.906909002Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}
f0a7ec49-7d38-45a9-80cf-4f9df45e0ccd	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:40.435187+00	2025-10-30 15:38:40.523656+00	Home Assistant	02617a61-3a32-47b7-961e-9d602a98c86a	[{"id": "b838ba1d-d780-4cd4-8e09-29d709969276", "type": "Port", "port_id": "069190fc-31fb-4c42-9eb1-0dfe07ce0122", "interface_id": "b2a8c8b6-b58a-43a8-977f-abe44705656f"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T15:38:40.435163127Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}
277806ed-0fbd-48e4-9868-e48bceaed730	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:34.551197+00	2025-10-30 15:38:40.52379+00	NetVisor Server API	02617a61-3a32-47b7-961e-9d602a98c86a	[{"id": "12695e14-bc9c-48c2-9095-f44d865ad953", "type": "Port", "port_id": "7706e2e7-a9ec-4e70-b5c5-9fd0f115f80c", "interface_id": "b2a8c8b6-b58a-43a8-977f-abe44705656f"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T15:38:34.551183180Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}
abab7c05-5955-470f-a57d-665a9ed62fe8	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:15.636642+00	2025-10-30 15:38:40.53372+00	NetVisor Server API	407ce7ce-ae5c-443d-a2a4-beebfbfd7c61	[{"id": "6bad5fe7-57d5-4b4a-850f-910f1dfaba65", "type": "Port", "port_id": "a11953c5-853b-4dff-8c18-ac6fe842a28a", "interface_id": "dab156f8-1d20-4d51-94e9-6ca62f418982"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T15:38:15.636619546Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}
9f392f02-08af-4dc2-9b89-c9fb549c1a42	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:30.842674+00	2025-10-30 15:38:40.523845+00	Home Assistant	8c3615ac-1502-423c-a76f-14da824d7ce3	[{"id": "2f25087f-5818-4634-a420-614ce5c89fd6", "type": "Port", "port_id": "21d8a87f-d44b-4eac-8a19-2c5f30a758ab", "interface_id": "e04a170e-75fc-41a2-a5f0-49dc1f416da1"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T15:38:30.842648803Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "Network"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
5271b1ef-4424-45d1-a11f-288a4c7c0ccc	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.108934+00	2025-10-30 15:38:02.108934+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
03fd25fe-1ba0-405f-b915-0afac2f2d528	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.108939+00	2025-10-30 15:38:02.108939+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
76766e55-ac07-4b35-a77f-c2cc084723fe	7e6121a3-b870-4dfa-af64-3d2eb1c17ff8	2025-10-30 15:38:02.170702+00	2025-10-30 15:38:02.170702+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-10-30T15:38:02.170692304Z", "daemon_id": "3f9573cb-160c-456a-b79b-7a20b1e8a627", "discovery_type": "SelfReport"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
b60e7679-ee19-40e8-a05d-f8cb63922c66	testuser	2025-10-30 15:38:02.106216+00	2025-10-30 15:38:05.797149+00	$argon2id$v=19$m=19456,t=2,p=1$oGnxwFo2a0Jn4EHyNE0IUA$C3tOdhqCZrJnWX/nzwfFG7SfgcvGfSm0ZEkEsqBa+Gk	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
OPYplfh2f-hWPnlKf-o3aA	\\x93c4106837ea7f4a793e56e87f76f89529f63881a7757365725f6964d92462363065373637392d656531392d343065382d613035642d66386362363339323263363699cd07e9cd014d0f2605ce2fe320ea000000	2025-11-29 15:38:05.803414+00
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

\unrestrict in3yZs1LRRUzoDCtu64WfeQQqDV3bvrxxaCSuWPPm2iUI1huLWxHALL1XCBYzLy

