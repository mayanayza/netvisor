--
-- PostgreSQL database dump
--

\restrict zmb8SW9Y0bY5W2IsIvXT1GiDqIy4vsL4XViecEDXAGE492Cl0QNksaJoPr5WfQT

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

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_organization;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_organizations_stripe_customer;
DROP INDEX IF EXISTS public.idx_networks_owner_organization;
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
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
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
DROP TABLE IF EXISTS public.organizations;
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
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text
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
    organization_id uuid NOT NULL
);


ALTER TABLE public.networks OWNER TO postgres;

--
-- Name: COLUMN networks.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.networks.organization_id IS 'The organization that owns and pays for this network';


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    stripe_customer_id text,
    plan jsonb,
    plan_status text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_onboarded boolean
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: TABLE organizations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organizations IS 'Organizations that own networks and have Stripe subscriptions';


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
    email text NOT NULL,
    organization_id uuid NOT NULL,
    permissions text DEFAULT 'Member'::text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: COLUMN users.organization_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.organization_id IS 'The single organization this user belongs to';


--
-- Name: COLUMN users.permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.users.permissions IS 'User role within their organization: Owner, Member, Viewer';


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
20251006215000	users	2025-11-17 07:28:29.698012+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3493779
20251006215100	networks	2025-11-17 07:28:29.702198+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4053974
20251006215151	create hosts	2025-11-17 07:28:29.706581+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3837815
20251006215155	create subnets	2025-11-17 07:28:29.71078+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3854859
20251006215201	create groups	2025-11-17 07:28:29.715023+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3747577
20251006215204	create daemons	2025-11-17 07:28:29.719141+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4311749
20251006215212	create services	2025-11-17 07:28:29.723964+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4914767
20251029193448	user-auth	2025-11-17 07:28:29.729307+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3713111
20251030044828	daemon api	2025-11-17 07:28:29.733422+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1830006
20251030170438	host-hide	2025-11-17 07:28:29.735581+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1278956
20251102224919	create discovery	2025-11-17 07:28:29.7372+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9542820
20251106235621	normalize-daemon-cols	2025-11-17 07:28:29.74706+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1935735
20251107034459	api keys	2025-11-17 07:28:29.749538+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8201175
20251107222650	oidc-auth	2025-11-17 07:28:29.758042+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	22113331
20251110181948	orgs-billing	2025-11-17 07:28:29.780526+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	11180643
20251113223656	group-enhancements	2025-11-17 07:28:29.792034+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1067461
20251117032720	daemon-mode	2025-11-17 07:28:29.793495+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1314075
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
1e5bbd21-5fec-4765-ae3b-c027fcecc8ca	a521a275a05c4be0b8792a4d51c1fa42	83403511-b4c3-48b6-abd8-ea6492848f9d	Integrated Daemon API Key	2025-11-17 07:28:33.823492+00	2025-11-17 07:29:26.192913+00	2025-11-17 07:29:26.19261+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
4616cad9-571d-4667-b85f-72f94bb45924	83403511-b4c3-48b6-abd8-ea6492848f9d	cf0c0440-c887-4714-b9ed-e549ff1c0f6f	"172.25.0.4"	60073	2025-11-17 07:28:33.876886+00	2025-11-17 07:28:33.876885+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["3eaf4985-6fc8-43d7-a1c4-df5368643fa4"]}	2025-11-17 07:28:33.936801+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
1f69b5ee-df0a-4b9c-a9e2-2b7394f0a73c	83403511-b4c3-48b6-abd8-ea6492848f9d	4616cad9-571d-4667-b85f-72f94bb45924	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f"}	Self Report @ 172.25.0.4	2025-11-17 07:28:33.878558+00	2025-11-17 07:28:33.878558+00
a4b69478-f361-4dac-92cb-58d67fe8e35a	83403511-b4c3-48b6-abd8-ea6492848f9d	4616cad9-571d-4667-b85f-72f94bb45924	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 07:28:33.884524+00	2025-11-17 07:28:33.884524+00
7d8a8bc9-bd49-4e15-b346-41a6c428d2c5	83403511-b4c3-48b6-abd8-ea6492848f9d	4616cad9-571d-4667-b85f-72f94bb45924	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "processed": 1, "network_id": "83403511-b4c3-48b6-abd8-ea6492848f9d", "session_id": "188b7984-82b3-4d00-9e6a-4fd0bd2708ae", "started_at": "2025-11-17T07:28:33.884239084Z", "finished_at": "2025-11-17T07:28:33.947568908Z", "discovery_type": {"type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f"}	Discovery Run	2025-11-17 07:28:33.884239+00	2025-11-17 07:28:33.948589+00
56a08de8-061a-4df4-b2ce-81ff553e1b0b	83403511-b4c3-48b6-abd8-ea6492848f9d	4616cad9-571d-4667-b85f-72f94bb45924	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "processed": 13, "network_id": "83403511-b4c3-48b6-abd8-ea6492848f9d", "session_id": "a3c9a821-d6b9-4550-b172-2f349e6c2e8d", "started_at": "2025-11-17T07:28:33.955772963Z", "finished_at": "2025-11-17T07:29:26.191815649Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 07:28:33.955772+00	2025-11-17 07:29:26.192856+00
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
f92560ff-a96d-4854-be0a-1c09d3222158	83403511-b4c3-48b6-abd8-ea6492848f9d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "0820e427-6b38-4e10-984e-83aeef0b16e6"}	[{"id": "37f96f3f-2d21-4a68-9e97-46ac54aa72f7", "name": "Internet", "subnet_id": "2cf290ce-20a9-4310-b074-53de8d7cab46", "ip_address": "1.1.1.1", "mac_address": null}]	["29abeaf8-d8ba-4ef9-bdd8-f51c6b06008e"]	[{"id": "9495a90f-d752-4cd5-a247-e455dab69676", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 07:28:33.804102+00	2025-11-17 07:28:33.813688+00	f
05885737-8688-45db-8765-120f8608ae0e	83403511-b4c3-48b6-abd8-ea6492848f9d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "8f9a53d6-98d7-4559-90ce-ef06d74788fe"}	[{"id": "12b8fb37-03c8-421a-a0d6-d1c7a504fded", "name": "Internet", "subnet_id": "2cf290ce-20a9-4310-b074-53de8d7cab46", "ip_address": "203.0.113.88", "mac_address": null}]	["34b7fecd-c0f6-45d0-9e7c-b2cdd1effb42"]	[{"id": "aab0a9c6-d0e2-452f-bad7-77918bb565f3", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 07:28:33.804109+00	2025-11-17 07:28:33.818717+00	f
26ed47f8-de42-42b7-859a-50e50b49336a	83403511-b4c3-48b6-abd8-ea6492848f9d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "efcd2b85-631b-49a9-b694-3b7afc291498"}	[{"id": "efcba6f2-74ec-4450-b234-46c564d27cd8", "name": "Remote Network", "subnet_id": "fef3ecc1-c8de-43da-bea8-0c1d7484760e", "ip_address": "203.0.113.245", "mac_address": null}]	["49eb5f3f-10df-42a5-b3e1-12769dab4ddf"]	[{"id": "f8186207-39a4-4cae-93b4-79def4bd11a2", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 07:28:33.804114+00	2025-11-17 07:28:33.822687+00	f
096eab85-5bea-4aca-adbb-b96d91a0b3f9	83403511-b4c3-48b6-abd8-ea6492848f9d	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8a30bf94-9e9f-4d4d-b319-ad5640441803", "name": null, "subnet_id": "3eaf4985-6fc8-43d7-a1c4-df5368643fa4", "ip_address": "172.25.0.6", "mac_address": "06:46:72:7E:43:A8"}]	["a5dcdf9b-58ae-4e7c-b716-4b8bb72c5e13"]	[{"id": "9d9f3ebe-33ef-43d0-aa8b-20460f74c31f", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:28:50.844522057Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 07:28:50.844523+00	2025-11-17 07:29:05.559897+00	f
cf0c0440-c887-4714-b9ed-e549ff1c0f6f	83403511-b4c3-48b6-abd8-ea6492848f9d	172.25.0.4	bcad12affdae	NetVisor daemon	{"type": "None"}	[{"id": "d5493dc7-6163-41dd-9d49-193a13122727", "name": "eth0", "subnet_id": "3eaf4985-6fc8-43d7-a1c4-df5368643fa4", "ip_address": "172.25.0.4", "mac_address": "A6:7A:1F:CD:3B:4F"}]	["6df60566-8585-424f-b986-051b1e5b3854"]	[{"id": "391ad35e-f845-41a0-b30c-93cd367217f2", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:28:33.938763316Z", "type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924"}]}	null	2025-11-17 07:28:33.831754+00	2025-11-17 07:28:33.944923+00	f
b9cc070a-b78b-4f9a-b83a-5f2fe605618a	83403511-b4c3-48b6-abd8-ea6492848f9d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "2f47dc3f-3570-41ed-bc44-6e17502b60ad", "name": null, "subnet_id": "3eaf4985-6fc8-43d7-a1c4-df5368643fa4", "ip_address": "172.25.0.5", "mac_address": "B6:5A:00:C5:FA:22"}]	["ccf717e6-58b6-4234-a817-2f6611b4e9bd"]	[{"id": "4c6d6af6-0f17-4690-ba21-ae9315400ed6", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:28:36.155784892Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 07:28:36.155787+00	2025-11-17 07:28:50.703128+00	f
beeae968-6a22-45b4-84f6-89cca8f697ed	83403511-b4c3-48b6-abd8-ea6492848f9d	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "a03b5c20-87c3-4ff6-9fa6-7ff57cb8a2d8", "name": null, "subnet_id": "3eaf4985-6fc8-43d7-a1c4-df5368643fa4", "ip_address": "172.25.0.1", "mac_address": "BA:2F:B5:D1:85:33"}]	["e7c872b9-471a-4e17-a47b-29f29bf9e2ea", "eee85ea9-761f-4901-97bd-97becd3e1856"]	[{"id": "c2787d8b-7d31-496c-b8cb-659927a8fa20", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "77958032-026d-4ce1-be05-e7ca40b78875", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "f2745a22-f29a-43d1-82ca-5c469f3fb43c", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:29:11.686624417Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 07:29:11.686627+00	2025-11-17 07:29:26.189457+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
83403511-b4c3-48b6-abd8-ea6492848f9d	My Network	2025-11-17 07:28:33.802678+00	2025-11-17 07:28:33.802678+00	f	738947b2-f6cc-48b5-b33c-b26098cb8c4b
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
738947b2-f6cc-48b5-b33c-b26098cb8c4b	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 07:28:29.847925+00	2025-11-17 07:28:33.801031+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
29abeaf8-d8ba-4ef9-bdd8-f51c6b06008e	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.804104+00	2025-11-17 07:28:33.804104+00	Cloudflare DNS	f92560ff-a96d-4854-be0a-1c09d3222158	[{"id": "0820e427-6b38-4e10-984e-83aeef0b16e6", "type": "Port", "port_id": "9495a90f-d752-4cd5-a247-e455dab69676", "interface_id": "37f96f3f-2d21-4a68-9e97-46ac54aa72f7"}]	"Dns Server"	null	{"type": "System"}
34b7fecd-c0f6-45d0-9e7c-b2cdd1effb42	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.80411+00	2025-11-17 07:28:33.80411+00	Google.com	05885737-8688-45db-8765-120f8608ae0e	[{"id": "8f9a53d6-98d7-4559-90ce-ef06d74788fe", "type": "Port", "port_id": "aab0a9c6-d0e2-452f-bad7-77918bb565f3", "interface_id": "12b8fb37-03c8-421a-a0d6-d1c7a504fded"}]	"Web Service"	null	{"type": "System"}
49eb5f3f-10df-42a5-b3e1-12769dab4ddf	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.804115+00	2025-11-17 07:28:33.804115+00	Mobile Device	26ed47f8-de42-42b7-859a-50e50b49336a	[{"id": "efcd2b85-631b-49a9-b694-3b7afc291498", "type": "Port", "port_id": "f8186207-39a4-4cae-93b4-79def4bd11a2", "interface_id": "efcba6f2-74ec-4450-b234-46c564d27cd8"}]	"Client"	null	{"type": "System"}
6df60566-8585-424f-b986-051b1e5b3854	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.938777+00	2025-11-17 07:28:33.938777+00	NetVisor Daemon API	cf0c0440-c887-4714-b9ed-e549ff1c0f6f	[{"id": "f05132b0-c94d-47d1-9e4d-4d4cf1991538", "type": "Port", "port_id": "391ad35e-f845-41a0-b30c-93cd367217f2", "interface_id": "d5493dc7-6163-41dd-9d49-193a13122727"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T07:28:33.938776170Z", "type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924"}]}
ccf717e6-58b6-4234-a817-2f6611b4e9bd	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:50.692333+00	2025-11-17 07:28:50.692333+00	Home Assistant	b9cc070a-b78b-4f9a-b83a-5f2fe605618a	[{"id": "d76364cd-ea3d-41aa-8ca5-f8720d995152", "type": "Port", "port_id": "4c6d6af6-0f17-4690-ba21-ae9315400ed6", "interface_id": "2f47dc3f-3570-41ed-bc44-6e17502b60ad"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T07:28:50.692325625Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
a5dcdf9b-58ae-4e7c-b716-4b8bb72c5e13	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:29:05.529392+00	2025-11-17 07:29:05.529392+00	PostgreSQL	096eab85-5bea-4aca-adbb-b96d91a0b3f9	[{"id": "7640316b-aad1-4dc4-849d-2f730b4646fc", "type": "Port", "port_id": "9d9f3ebe-33ef-43d0-aa8b-20460f74c31f", "interface_id": "8a30bf94-9e9f-4d4d-b319-ad5640441803"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T07:29:05.529384636Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
eee85ea9-761f-4901-97bd-97becd3e1856	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:29:26.181101+00	2025-11-17 07:29:26.181101+00	Home Assistant	beeae968-6a22-45b4-84f6-89cca8f697ed	[{"id": "8ddbd1a3-916c-4991-9c81-76063c2ae34c", "type": "Port", "port_id": "77958032-026d-4ce1-be05-e7ca40b78875", "interface_id": "a03b5c20-87c3-4ff6-9fa6-7ff57cb8a2d8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T07:29:26.181091739Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
e7c872b9-471a-4e17-a47b-29f29bf9e2ea	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:29:18.942599+00	2025-11-17 07:29:18.942599+00	NetVisor Server API	beeae968-6a22-45b4-84f6-89cca8f697ed	[{"id": "378358ea-1df5-464f-815f-47de5479de80", "type": "Port", "port_id": "c2787d8b-7d31-496c-b8cb-659927a8fa20", "interface_id": "a03b5c20-87c3-4ff6-9fa6-7ff57cb8a2d8"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T07:29:18.942592310Z", "type": "Network", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
2cf290ce-20a9-4310-b074-53de8d7cab46	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.804041+00	2025-11-17 07:28:33.804041+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
fef3ecc1-c8de-43da-bea8-0c1d7484760e	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.804045+00	2025-11-17 07:28:33.804045+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
3eaf4985-6fc8-43d7-a1c4-df5368643fa4	83403511-b4c3-48b6-abd8-ea6492848f9d	2025-11-17 07:28:33.88444+00	2025-11-17 07:28:33.88444+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:28:33.884438640Z", "type": "SelfReport", "host_id": "cf0c0440-c887-4714-b9ed-e549ff1c0f6f", "daemon_id": "4616cad9-571d-4667-b85f-72f94bb45924"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
d33debdf-e2e5-42a4-aef9-d14e6bcd477e	2025-11-17 07:28:29.84991+00	2025-11-17 07:28:33.790007+00	$argon2id$v=19$m=19456,t=2,p=1$IMQoFIw21zv+x3I/YuwusA$nxwLGc35ftNeHDa3Od4x+kHUtdZZ+lkXQ7XJ1YZOtmw	\N	\N	\N	user@example.com	738947b2-f6cc-48b5-b33c-b26098cb8c4b	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
6u1xxzO9bBTYQ2w2WK3fow	\\x93c410a3dfad58366c43d8146cbd33c771edea81a7757365725f6964d92464333364656264662d653265352d343261342d616566392d64313465366263643437376599cd07e9cd015f071c21ce2f2e15a7000000	2025-12-17 07:28:33.791549+00
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
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


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
-- Name: idx_networks_owner_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_networks_owner_organization ON public.networks USING btree (organization_id);


--
-- Name: idx_organizations_stripe_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_organizations_stripe_customer ON public.organizations USING btree (stripe_customer_id);


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
-- Name: idx_users_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_organization ON public.users USING btree (organization_id);


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
-- Name: networks organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict zmb8SW9Y0bY5W2IsIvXT1GiDqIy4vsL4XViecEDXAGE492Cl0QNksaJoPr5WfQT

