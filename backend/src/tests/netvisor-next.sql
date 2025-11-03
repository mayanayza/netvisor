--
-- PostgreSQL database dump
--

\restrict brxEathm4MntaT898C3iHDRcR2lRaW5gnlk4STJQqDqEXTucnLLgyRBGwzrLJDr

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
    registered_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    api_key text,
    capabilities jsonb DEFAULT '{}'::jsonb
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
20251006215000	users	2025-11-03 13:22:22.254313+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2053917
20251006215100	networks	2025-11-03 13:22:22.257031+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	1861125
20251006215151	create hosts	2025-11-03 13:22:22.259088+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1265542
20251006215155	create subnets	2025-11-03 13:22:22.260536+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1637542
20251006215201	create groups	2025-11-03 13:22:22.26235+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1293958
20251006215204	create daemons	2025-11-03 13:22:22.263815+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1515083
20251006215212	create services	2025-11-03 13:22:22.265515+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1535875
20251029193448	user-auth	2025-11-03 13:22:22.267213+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	9030875
20251030044828	daemon api	2025-11-03 13:22:22.276397+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	545667
20251030170438	host-hide	2025-11-03 13:22:22.277083+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	399625
20251102224919	create discovery	2025-11-03 13:22:22.277621+00	t	\\x1713d197725e0068b7b49bcfe1c902fc8642c27830921b107eba657072c2d39da9cc8995302bac42700ff696245be83a	1897667
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, registered_at, last_seen, api_key, capabilities) FROM stdin;
cd16398a-f095-44c5-92df-2bc8eae3d414	09805543-1591-4064-81dc-cb70d5926fea	e7b32329-2b30-448d-9d18-42a8d6f5bb3a	"172.25.0.4"	60073	2025-11-03 13:22:22.343715+00	2025-11-03 13:22:22.343714+00	013966f6a44d463ab6f570237d159a37	{"has_docker_socket": false, "interfaced_subnet_ids": ["cf7c4e79-228c-4755-b3bb-060fb6d74450"]}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
f0a25c56-359e-489a-a619-cfa28913213e	09805543-1591-4064-81dc-cb70d5926fea	cd16398a-f095-44c5-92df-2bc8eae3d414	{"type": "Scheduled", "enabled": true, "last_run": "2025-11-03T13:22:22.345258637Z", "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a"}	Self Report @ 172.25.0.4	2025-11-03 13:22:22.344488+00	2025-11-03 13:22:22.345784+00
d0358bc3-b2b4-4e14-8c38-50fa1cd77521	09805543-1591-4064-81dc-cb70d5926fea	cd16398a-f095-44c5-92df-2bc8eae3d414	{"type": "Scheduled", "enabled": true, "last_run": "2025-11-03T13:22:22.348556304Z", "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null}	Network Scan @ 172.25.0.4	2025-11-03 13:22:22.348018+00	2025-11-03 13:22:22.348758+00
2b763282-7eaf-481a-a053-39d836844531	09805543-1591-4064-81dc-cb70d5926fea	cd16398a-f095-44c5-92df-2bc8eae3d414	{"type": "Historical", "results": {"error": null, "phase": "Complete", "total": 1, "completed": 1, "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "network_id": "09805543-1591-4064-81dc-cb70d5926fea", "session_id": "a587609c-644d-4249-bed8-c47e9fb76dac", "started_at": "2025-11-03T13:22:22.347879346Z", "finished_at": "2025-11-03T13:22:22.363017429Z", "discovery_type": {"type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a"}, "discovered_count": 1}}	{"type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a"}	Discovery Run	2025-11-03 13:22:22.363051+00	2025-11-03 13:22:22.363052+00
1a45fc7e-23b3-47a3-8ecf-8f66d816031f	09805543-1591-4064-81dc-cb70d5926fea	cd16398a-f095-44c5-92df-2bc8eae3d414	{"type": "Historical", "results": {"error": null, "phase": "Complete", "total": 16, "completed": 12, "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "network_id": "09805543-1591-4064-81dc-cb70d5926fea", "session_id": "e6634fa4-783e-4522-9a4c-64d43a0d296a", "started_at": "2025-11-03T13:22:22.368814762Z", "finished_at": "2025-11-03T13:23:10.264536673Z", "discovery_type": {"type": "Network", "subnet_ids": null}, "discovered_count": 4}}	{"type": "Network", "subnet_ids": null}	Discovery Run	2025-11-03 13:23:10.265028+00	2025-11-03 13:23:10.265061+00
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
0660fe8a-5773-4c8e-8bb9-343eb9145fd2	09805543-1591-4064-81dc-cb70d5926fea	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "42dbe92e-2da0-4427-a169-62fe224a712e"}	[{"id": "06567b6a-3226-4e5e-8263-2104b68fdb66", "name": "Internet", "subnet_id": "56fca330-612f-42d3-8378-fd282fa74936", "ip_address": "1.1.1.1", "mac_address": null}]	["d88fd10d-260c-4f09-a95f-b5ed9b5b6402"]	[{"id": "4160801b-11ee-4175-811e-034408a4ca57", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-03 13:22:22.321716+00	2025-11-03 13:22:22.327689+00	f
a37ce933-5bac-4449-846c-f3550d89ec29	09805543-1591-4064-81dc-cb70d5926fea	Google.com	\N	\N	{"type": "ServiceBinding", "config": "888f5e62-fa86-43bd-a771-ceca1a240450"}	[{"id": "9d576b32-ac63-4138-b7dc-1f8735d720f7", "name": "Internet", "subnet_id": "56fca330-612f-42d3-8378-fd282fa74936", "ip_address": "203.0.113.221", "mac_address": null}]	["2e77f9dc-6f32-4722-9b78-9d83b261c810"]	[{"id": "1c919a3e-73b1-4b59-81ad-a9c5a37536c2", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-03 13:22:22.321719+00	2025-11-03 13:22:22.330298+00	f
01b8d3ec-c237-4d09-b2f2-9a32d50944a3	09805543-1591-4064-81dc-cb70d5926fea	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "f90946ed-59ea-4c05-a312-8815c8f05c70"}	[{"id": "36255a07-cea2-45a7-b57a-b6e3de8e165a", "name": "Remote Network", "subnet_id": "a9227146-db9b-4a0d-96cd-9f96b0d65a9a", "ip_address": "203.0.113.125", "mac_address": null}]	["cbdfa1e2-d2b4-4d7d-96d0-a4a4815accc4"]	[{"id": "a71a54c8-d9df-48aa-84be-a3a5c58b829e", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-03 13:22:22.321722+00	2025-11-03 13:22:22.332842+00	f
eaa7e25f-6beb-4761-ac0c-3edb25ef90bf	09805543-1591-4064-81dc-cb70d5926fea	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "23dc5766-eed1-4a73-83be-5063126b81ff", "name": null, "subnet_id": "cf7c4e79-228c-4755-b3bb-060fb6d74450", "ip_address": "172.25.0.3", "mac_address": "9A:20:BC:88:6D:EB"}]	["d9e8e5fc-8d56-444e-a88a-891f83ef1794"]	[{"id": "4e0da387-1346-416b-b8a6-32a4fdaef460", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-03T13:22:26.407809542Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}	null	2025-11-03 13:22:26.407812+00	2025-11-03 13:22:35.363158+00	f
3d7a05b8-52b7-4ffe-b179-690fedd73e89	09805543-1591-4064-81dc-cb70d5926fea	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "bd47196e-be56-429f-bfa8-c52c89981c9c", "name": null, "subnet_id": "cf7c4e79-228c-4755-b3bb-060fb6d74450", "ip_address": "172.25.0.5", "mac_address": "06:28:0E:B4:09:70"}]	["c74f71df-d1f7-4590-be63-6429a6e0b43e"]	[{"id": "0016b5f4-d024-4d62-a4a5-798c6ae8f881", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-03T13:22:35.359099213Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}	null	2025-11-03 13:22:35.359101+00	2025-11-03 13:22:44.274643+00	f
e7b32329-2b30-448d-9d18-42a8d6f5bb3a	09805543-1591-4064-81dc-cb70d5926fea	172.25.0.4	baa0279fe9c6	NetVisor daemon	{"type": "None"}	[{"id": "0b293675-5c81-48b9-bab3-e25424f47c95", "name": "eth0", "subnet_id": "cf7c4e79-228c-4755-b3bb-060fb6d74450", "ip_address": "172.25.0.4", "mac_address": "F6:68:61:24:0C:5E"}]	["472d5ee4-b73e-4cd3-9310-57cf3a116862", "6308c119-e381-4f55-bb99-8b63f113ab9a"]	[{"id": "c079a8cd-3729-41ab-8844-ffefa1e379db", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-03T13:22:26.403948917Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}, {"date": "2025-11-03T13:22:22.356034679Z", "type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414"}]}	null	2025-11-03 13:22:22.342143+00	2025-11-03 13:22:26.42208+00	f
e31859c4-f2d6-44fe-b77f-4305470356c0	09805543-1591-4064-81dc-cb70d5926fea	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "15008021-989b-4d47-bcd6-2e029c889d2e", "name": null, "subnet_id": "cf7c4e79-228c-4755-b3bb-060fb6d74450", "ip_address": "172.25.0.1", "mac_address": "72:77:0B:07:B4:53"}]	["7f2c09c6-3819-4c3a-bf9e-7ddc345e7758", "e0a2a35b-3994-49dd-81fa-6ac2fe56bb81"]	[{"id": "5c2c27c3-236a-4157-874e-023e995f6428", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "0a0b4470-0ac8-446c-a7d6-fd760b253d06", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-03T13:22:44.269551092Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}	null	2025-11-03 13:22:44.269552+00	2025-11-03 13:22:53.341706+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
09805543-1591-4064-81dc-cb70d5926fea	My Network	2025-11-03 13:22:22.320525+00	2025-11-03 13:22:22.320526+00	t	72b35348-c0c3-4f87-93cd-8a251c7769db
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
d88fd10d-260c-4f09-a95f-b5ed9b5b6402	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.321717+00	2025-11-03 13:22:22.327231+00	Cloudflare DNS	0660fe8a-5773-4c8e-8bb9-343eb9145fd2	[{"id": "42dbe92e-2da0-4427-a169-62fe224a712e", "type": "Port", "port_id": "4160801b-11ee-4175-811e-034408a4ca57", "interface_id": "06567b6a-3226-4e5e-8263-2104b68fdb66"}]	"Dns Server"	null	{"type": "System"}
2e77f9dc-6f32-4722-9b78-9d83b261c810	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.32172+00	2025-11-03 13:22:22.329978+00	Google.com	a37ce933-5bac-4449-846c-f3550d89ec29	[{"id": "888f5e62-fa86-43bd-a771-ceca1a240450", "type": "Port", "port_id": "1c919a3e-73b1-4b59-81ad-a9c5a37536c2", "interface_id": "9d576b32-ac63-4138-b7dc-1f8735d720f7"}]	"Web Service"	null	{"type": "System"}
cbdfa1e2-d2b4-4d7d-96d0-a4a4815accc4	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.321722+00	2025-11-03 13:22:22.332529+00	Mobile Device	01b8d3ec-c237-4d09-b2f2-9a32d50944a3	[{"id": "f90946ed-59ea-4c05-a312-8815c8f05c70", "type": "Port", "port_id": "a71a54c8-d9df-48aa-84be-a3a5c58b829e", "interface_id": "36255a07-cea2-45a7-b57a-b6e3de8e165a"}]	"Client"	null	{"type": "System"}
c74f71df-d1f7-4590-be63-6429a6e0b43e	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:41.182314+00	2025-11-03 13:22:44.274285+00	Home Assistant	3d7a05b8-52b7-4ffe-b179-690fedd73e89	[{"id": "a4b9957b-5051-41e6-aa53-ba83b257b0d6", "type": "Port", "port_id": "0016b5f4-d024-4d62-a4a5-798c6ae8f881", "interface_id": "bd47196e-be56-429f-bfa8-c52c89981c9c"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-03T13:22:41.182304215Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}
472d5ee4-b73e-4cd3-9310-57cf3a116862	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.356125+00	2025-11-03 13:22:26.421123+00	NetVisor Daemon API	e7b32329-2b30-448d-9d18-42a8d6f5bb3a	[{"id": "cce163f1-bd4a-4c85-9e06-6ca0a87a7312", "type": "Port", "port_id": "c079a8cd-3729-41ab-8844-ffefa1e379db", "interface_id": "0b293675-5c81-48b9-bab3-e25424f47c95"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Updated match data on 2025-11-03 13:22:26.405770500 UTC", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-03T13:22:26.405770500Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}, {"date": "2025-11-03T13:22:22.356124471Z", "type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414"}]}
d9e8e5fc-8d56-444e-a88a-891f83ef1794	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:27.423529+00	2025-11-03 13:22:35.362828+00	NetVisor Server API	eaa7e25f-6beb-4761-ac0c-3edb25ef90bf	[{"id": "f623f8ae-7967-47dc-bd47-51f41dcedc1b", "type": "Port", "port_id": "4e0da387-1346-416b-b8a6-32a4fdaef460", "interface_id": "23dc5766-eed1-4a73-83be-5063126b81ff"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-03T13:22:27.423522834Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}
7f2c09c6-3819-4c3a-bf9e-7ddc345e7758	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:45.152645+00	2025-11-03 13:22:53.313129+00	NetVisor Server API	e31859c4-f2d6-44fe-b77f-4305470356c0	[{"id": "2a2fb3a6-c0d2-46d6-9020-7753a9cc69c9", "type": "Port", "port_id": "5c2c27c3-236a-4157-874e-023e995f6428", "interface_id": "15008021-989b-4d47-bcd6-2e029c889d2e"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-03T13:22:45.152639884Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}
e0a2a35b-3994-49dd-81fa-6ac2fe56bb81	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:50.116517+00	2025-11-03 13:22:53.341251+00	Home Assistant	e31859c4-f2d6-44fe-b77f-4305470356c0	[{"id": "bc7c6b16-5c43-465d-8e8c-be4413eb17e4", "type": "Port", "port_id": "0a0b4470-0ac8-446c-a7d6-fd760b253d06", "interface_id": "15008021-989b-4d47-bcd6-2e029c889d2e"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-03T13:22:50.116503970Z", "type": "Network", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414", "subnet_ids": null}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
56fca330-612f-42d3-8378-fd282fa74936	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.321666+00	2025-11-03 13:22:22.321666+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
a9227146-db9b-4a0d-96cd-9f96b0d65a9a	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.321667+00	2025-11-03 13:22:22.321667+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
cf7c4e79-228c-4755-b3bb-060fb6d74450	09805543-1591-4064-81dc-cb70d5926fea	2025-11-03 13:22:22.34824+00	2025-11-03 13:22:22.34824+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-03T13:22:22.348235804Z", "type": "SelfReport", "host_id": "e7b32329-2b30-448d-9d18-42a8d6f5bb3a", "daemon_id": "cd16398a-f095-44c5-92df-2bc8eae3d414"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
72b35348-c0c3-4f87-93cd-8a251c7769db	testuser	2025-11-03 13:22:22.319901+00	2025-11-03 13:22:26.741282+00	$argon2id$v=19$m=19456,t=2,p=1$pDDipM99zy8ETwXVwNtP6g$peZGIFHDE7+DJMtMywI4CGTLZL87aGfH9QzxGFn/kB0	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
d5kuzGgjIXzuDSLG6V9jww	\\x93c410c3635fe9c6220dee7c212368cc2e997781a7757365725f6964d92437326233353334382d633063332d346638372d393363642d38613235316337373639646299cd07e9cd01510d161ace2c49ca9c000000	2025-12-03 13:22:26.743033+00
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

\unrestrict brxEathm4MntaT898C3iHDRcR2lRaW5gnlk4STJQqDqEXTucnLLgyRBGwzrLJDr

