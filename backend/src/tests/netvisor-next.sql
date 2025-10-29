--
-- PostgreSQL database dump
--

\restrict utJ6YF0AIe7cYJA12rCeMbnRPGDV4UkUYjoqq2ScVXnvsVji7x5aDTHEnMQQ8H4

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
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.groups;
DROP TABLE IF EXISTS public.daemons;
DROP TABLE IF EXISTS public._sqlx_migrations;
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
    last_seen timestamp with time zone NOT NULL
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
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: _sqlx_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) FROM stdin;
20251006215000	users	2025-10-29 14:13:40.189405+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	1852167
20251006215100	networks	2025-10-29 14:13:40.19196+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	1847708
20251006215151	create hosts	2025-10-29 14:13:40.194011+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1334167
20251006215155	create subnets	2025-10-29 14:13:40.195497+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1469792
20251006215201	create groups	2025-10-29 14:13:40.197119+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1243750
20251006215204	create daemons	2025-10-29 14:13:40.198517+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1425375
20251006215212	create services	2025-10-29 14:13:40.200113+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1504167
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, registered_at, last_seen) FROM stdin;
26aa9085-73bb-4f88-8eaf-dc0031f2e5c8	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	1eb5dfda-263c-4510-be4d-fef6928415ea	"172.25.0.4"	60073	2025-10-29 14:13:40.264574+00	2025-10-29 14:14:11.258723+00
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
14bb93ec-9d59-4d0b-a86c-8f3c259b8c2c	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	Cloudflare DNS	\N	Cloudflare DNS	{"type": "ServiceBinding", "config": "3b0fb892-d5c6-4924-94c2-dec893e86292"}	[{"id": "dee80cd6-f369-4e3f-9af9-6f93b773f345", "name": "Internet", "subnet_id": "6878568c-aa7e-4d6a-a23b-4fea69501c8a", "ip_address": "1.1.1.1", "mac_address": null}]	["f2b726e6-6db5-48f5-a13e-fef8809c521f"]	[{"id": "19fc6bfa-c656-450a-903b-eef7ae47fea3", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-10-29 14:13:40.234323+00	2025-10-29 14:13:40.241616+00
d1c0d7bf-0c4f-48cc-9d8c-7f81c5d69816	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	Google.com	google.com	Google.com	{"type": "ServiceBinding", "config": "84ca18b9-0999-44a1-a48c-5c90f0a75452"}	[{"id": "6d150ce9-385c-4f88-8885-dde1ca95dbf5", "name": "Internet", "subnet_id": "6878568c-aa7e-4d6a-a23b-4fea69501c8a", "ip_address": "203.0.113.193", "mac_address": null}]	["bcb58ad1-d335-4901-93b6-1407a4f03d07"]	[{"id": "7f20b9e3-899a-4deb-8655-b6619edbfe92", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-29 14:13:40.234326+00	2025-10-29 14:13:40.244256+00
a118bdf8-d1b2-480a-ab9b-dc25609eede6	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "04a6d2f5-3c53-4fc8-88fe-27dedcf04551"}	[{"id": "533d32bc-08dd-4f5e-8356-d3649402d672", "name": "Remote Network", "subnet_id": "6f2140b4-c161-4f77-bb5c-4224436c9ea6", "ip_address": "203.0.113.247", "mac_address": null}]	["0945765c-2519-46a5-9fd6-b764ec36dd4c"]	[{"id": "c5fddca0-7e3d-4ba3-a8e4-0f3c9dc3bd60", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-29 14:13:40.234329+00	2025-10-29 14:13:40.246714+00
06fff7ac-1057-4566-9c6b-65651160c9f0	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "5edfdeeb-fc50-4650-8a60-b215d2e0f3d5", "name": null, "subnet_id": "d27048e0-582d-441e-84c9-a183381807ff", "ip_address": "172.25.0.5", "mac_address": "92:00:C7:C8:67:93"}]	["dca6102b-1370-4244-98e3-ec64f3bc344c"]	[{"id": "c61a353f-81c3-446c-a4e8-3cb74c9b0fd7", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-29T14:14:01.516696253Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}	null	2025-10-29 14:14:01.5167+00	2025-10-29 14:14:19.731021+00
1eb5dfda-263c-4510-be4d-fef6928415ea	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	bac7cf377d6d	bac7cf377d6d	NetVisor daemon	{"type": "Hostname"}	[{"id": "7d8ce4c1-c190-4065-8c37-e4e2f70eaffe", "name": "eth0", "subnet_id": "d27048e0-582d-441e-84c9-a183381807ff", "ip_address": "172.25.0.4", "mac_address": "B6:D0:26:50:BA:A0"}]	["95601b27-86e5-4606-ad04-ef34c326636e", "84e95d67-9f47-4670-a9ab-48ea44f44ae5"]	[{"id": "6f3ab913-430c-4bb0-9948-72b90a5df8a5", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-29T14:13:52.206082763Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}, {"date": "2025-10-29T14:13:40.260104257Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "SelfReport"}]}	null	2025-10-29 14:13:40.260105+00	2025-10-29 14:14:01.531728+00
1e1a1f98-0fdf-4e96-a4c0-430c81f9ed15	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "80421f5d-d254-40cf-9252-7e71726e2e9b", "name": null, "subnet_id": "d27048e0-582d-441e-84c9-a183381807ff", "ip_address": "172.25.0.3", "mac_address": "46:42:82:76:E9:53"}]	["7cadf061-e574-4e4a-a92a-e5958be75d05"]	[{"id": "18ce1727-b2f2-46fd-9996-a63e5d1066fb", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-29T14:13:52.208648305Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}	null	2025-10-29 14:13:52.20865+00	2025-10-29 14:14:19.763292+00
f9476b7f-a809-4f9b-bc02-08d52ca6619b	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	Home Assistant	\N	\N	{"type": "None"}	[{"id": "a4662414-f561-465c-b25f-c15081b1ea33", "name": null, "subnet_id": "d27048e0-582d-441e-84c9-a183381807ff", "ip_address": "172.25.0.1", "mac_address": "76:16:69:A9:A0:60"}]	["4b2b9432-30fd-423a-965e-c9ac9d19539a", "7f390419-5f7a-41b0-920e-169d9ddda332"]	[{"id": "aa3e5974-c2ac-45f4-a991-13a7fd27934e", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "378f3b4d-863e-4b0c-992a-06617f6ee1ce", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-29T14:14:10.569843591Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}	null	2025-10-29 14:14:10.569844+00	2025-10-29 14:14:19.793746+00
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	My Network	2025-10-29 14:13:40.204279+00	2025-10-29 14:13:40.20428+00	t	76d0b364-5af0-42ff-ac92-bab3def3f471
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
f2b726e6-6db5-48f5-a13e-fef8809c521f	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.234324+00	2025-10-29 14:13:40.241148+00	Cloudflare DNS	14bb93ec-9d59-4d0b-a86c-8f3c259b8c2c	[{"id": "3b0fb892-d5c6-4924-94c2-dec893e86292", "type": "Port", "port_id": "19fc6bfa-c656-450a-903b-eef7ae47fea3", "interface_id": "dee80cd6-f369-4e3f-9af9-6f93b773f345"}]	"Dns Server"	null	{"type": "System"}
bcb58ad1-d335-4901-93b6-1407a4f03d07	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.234327+00	2025-10-29 14:13:40.243955+00	Google.com	d1c0d7bf-0c4f-48cc-9d8c-7f81c5d69816	[{"id": "84ca18b9-0999-44a1-a48c-5c90f0a75452", "type": "Port", "port_id": "7f20b9e3-899a-4deb-8655-b6619edbfe92", "interface_id": "6d150ce9-385c-4f88-8885-dde1ca95dbf5"}]	"Web Service"	null	{"type": "System"}
0945765c-2519-46a5-9fd6-b764ec36dd4c	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.234329+00	2025-10-29 14:13:40.246393+00	Mobile Device	a118bdf8-d1b2-480a-ab9b-dc25609eede6	[{"id": "04a6d2f5-3c53-4fc8-88fe-27dedcf04551", "type": "Port", "port_id": "c5fddca0-7e3d-4ba3-a8e4-0f3c9dc3bd60", "interface_id": "533d32bc-08dd-4f5e-8356-d3649402d672"}]	"Client"	null	{"type": "System"}
7cadf061-e574-4e4a-a92a-e5958be75d05	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:53.326304+00	2025-10-29 14:14:19.762953+00	NetVisor Server API	1e1a1f98-0fdf-4e96-a4c0-430c81f9ed15	[{"id": "6803a61a-55c8-4309-b714-584b71bb5156", "type": "Port", "port_id": "18ce1727-b2f2-46fd-9996-a63e5d1066fb", "interface_id": "80421f5d-d254-40cf-9252-7e71726e2e9b"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-29T14:13:53.326294014Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}
95601b27-86e5-4606-ad04-ef34c326636e	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.260117+00	2025-10-29 14:14:01.531262+00	NetVisor Daemon API	1eb5dfda-263c-4510-be4d-fef6928415ea	[{"id": "e655bff6-bd97-42cd-985e-b7f2fc123d47", "type": "Port", "port_id": "6f3ab913-430c-4bb0-9948-72b90a5df8a5", "interface_id": "7d8ce4c1-c190-4065-8c37-e4e2f70eaffe"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Updated match data on 2025-10-29 14:13:52.207131305 UTC", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-10-29T14:13:52.207131305Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}, {"date": "2025-10-29T14:13:40.260117591Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "SelfReport"}]}
dca6102b-1370-4244-98e3-ec64f3bc344c	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:14:06.843101+00	2025-10-29 14:14:19.730499+00	Home Assistant	06fff7ac-1057-4566-9c6b-65651160c9f0	[{"id": "f6c9a765-442d-42c2-b89d-a6ab741b9911", "type": "Port", "port_id": "c61a353f-81c3-446c-a4e8-3cb74c9b0fd7", "interface_id": "5edfdeeb-fc50-4650-8a60-b215d2e0f3d5"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-29T14:14:06.843086381Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}
7f390419-5f7a-41b0-920e-169d9ddda332	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:14:11.474507+00	2025-10-29 14:14:19.79316+00	NetVisor Server API	f9476b7f-a809-4f9b-bc02-08d52ca6619b	[{"id": "18b364c2-101c-42ce-aa97-9781b4ee52d5", "type": "Port", "port_id": "aa3e5974-c2ac-45f4-a991-13a7fd27934e", "interface_id": "a4662414-f561-465c-b25f-c15081b1ea33"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-29T14:14:11.474500675Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}
4b2b9432-30fd-423a-965e-c9ac9d19539a	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:14:16.042544+00	2025-10-29 14:14:19.793341+00	Home Assistant	f9476b7f-a809-4f9b-bc02-08d52ca6619b	[{"id": "9f879a54-f9f3-408a-8c4b-181d32009d14", "type": "Port", "port_id": "378f3b4d-863e-4b0c-992a-06617f6ee1ce", "interface_id": "a4662414-f561-465c-b25f-c15081b1ea33"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-29T14:14:16.042532427Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "Network"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
6878568c-aa7e-4d6a-a23b-4fea69501c8a	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.234287+00	2025-10-29 14:13:40.234287+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
6f2140b4-c161-4f77-bb5c-4224436c9ea6	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.234289+00	2025-10-29 14:13:40.234289+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
d27048e0-582d-441e-84c9-a183381807ff	b1e2d4c2-1610-4467-9e02-a8f5d6ed81ad	2025-10-29 14:13:40.256996+00	2025-10-29 14:13:40.256996+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-10-29T14:13:40.256981382Z", "daemon_id": "26aa9085-73bb-4f88-8eaf-dc0031f2e5c8", "discovery_type": "SelfReport"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at) FROM stdin;
76d0b364-5af0-42ff-ac92-bab3def3f471	Default Username	2025-10-29 14:13:40.203752+00	2025-10-29 14:13:40.203754+00
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
-- Name: idx_daemon_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemon_host_id ON public.daemons USING btree (host_id);


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

\unrestrict utJ6YF0AIe7cYJA12rCeMbnRPGDV4UkUYjoqq2ScVXnvsVji7x5aDTHEnMQQ8H4

