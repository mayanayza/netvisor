--
-- PostgreSQL database dump
--

\restrict HDmUXJDUYqeJHDaUt13NFHPxl4NYqze8pdmdR8xilL3yHde2K3bUfparbZyeSmC

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
ALTER TABLE IF EXISTS ONLY public.topologies DROP CONSTRAINT IF EXISTS topologies_network_id_fkey;
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
DROP INDEX IF EXISTS public.idx_users_network_ids;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_topologies_network;
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
ALTER TABLE IF EXISTS ONLY public.topologies DROP CONSTRAINT IF EXISTS topologies_pkey;
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
DROP TABLE IF EXISTS public.topologies;
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
    services uuid[],
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
    plan jsonb NOT NULL,
    plan_status text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    onboarding jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: TABLE organizations; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.organizations IS 'Organizations that own networks and have Stripe subscriptions';


--
-- Name: COLUMN organizations.plan; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.organizations.plan IS 'The current billing plan for the organization (e.g., Community, Pro)';


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
-- Name: topologies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topologies (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    network_id uuid NOT NULL,
    name text NOT NULL,
    edges jsonb NOT NULL,
    nodes jsonb NOT NULL,
    options jsonb NOT NULL,
    hosts jsonb NOT NULL,
    subnets jsonb NOT NULL,
    services jsonb NOT NULL,
    groups jsonb NOT NULL,
    is_stale boolean,
    last_refreshed timestamp with time zone DEFAULT now() NOT NULL,
    is_locked boolean,
    locked_at timestamp with time zone,
    locked_by uuid,
    removed_hosts uuid[],
    removed_services uuid[],
    removed_subnets uuid[],
    removed_groups uuid[],
    parent_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.topologies OWNER TO postgres;

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
    permissions text DEFAULT 'Member'::text NOT NULL,
    network_ids uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-07 01:48:55.766999+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	5786320
20251006215100	networks	2025-12-07 01:48:55.77355+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3871917
20251006215151	create hosts	2025-12-07 01:48:55.777769+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3831231
20251006215155	create subnets	2025-12-07 01:48:55.781952+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3688906
20251006215201	create groups	2025-12-07 01:48:55.786211+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3756542
20251006215204	create daemons	2025-12-07 01:48:55.790345+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4197843
20251006215212	create services	2025-12-07 01:48:55.794882+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4672275
20251029193448	user-auth	2025-12-07 01:48:55.79986+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3676113
20251030044828	daemon api	2025-12-07 01:48:55.803834+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1517992
20251030170438	host-hide	2025-12-07 01:48:55.805638+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1171899
20251102224919	create discovery	2025-12-07 01:48:55.807128+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9493296
20251106235621	normalize-daemon-cols	2025-12-07 01:48:55.816949+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1827828
20251107034459	api keys	2025-12-07 01:48:55.819092+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7353077
20251107222650	oidc-auth	2025-12-07 01:48:55.826907+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	19990497
20251110181948	orgs-billing	2025-12-07 01:48:55.847195+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10288314
20251113223656	group-enhancements	2025-12-07 01:48:55.857803+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1038210
20251117032720	daemon-mode	2025-12-07 01:48:55.859147+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1261364
20251118143058	set-default-plan	2025-12-07 01:48:55.860727+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1257558
20251118225043	save-topology	2025-12-07 01:48:55.862317+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9347054
20251123232748	network-permissions	2025-12-07 01:48:55.871974+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2912799
20251125001342	billing-updates	2025-12-07 01:48:55.875178+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	914640
20251128035448	org-onboarding-status	2025-12-07 01:48:55.876381+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1497744
20251129180942	nfs-consolidate	2025-12-07 01:48:55.87816+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1251316
20251206052641	discovery-progress	2025-12-07 01:48:55.879684+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	3371927
20251206202200	plan-fix	2025-12-07 01:48:55.883404+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	969092
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
8095ab4b-1447-466e-acd9-f6831f2c2205	457a1d5a435949e7912d012af7008cad	3329f84c-1651-4583-93af-089fb8ec3a79	Integrated Daemon API Key	2025-12-07 01:48:57.682189+00	2025-12-07 01:50:33.818201+00	2025-12-07 01:50:33.817364+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab	3329f84c-1651-4583-93af-089fb8ec3a79	616ab26e-bae0-4a2d-930f-9a417673dd11	"172.25.0.4"	60073	2025-12-07 01:48:57.847566+00	2025-12-07 01:50:13.19644+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["1ce8d22b-ca79-441b-8bce-26f45e365ce0"]}	2025-12-07 01:50:13.197328+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
bac5721b-7730-49a7-9703-3637cd69bb61	3329f84c-1651-4583-93af-089fb8ec3a79	80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11"}	Self Report @ 172.25.0.4	2025-12-07 01:48:57.857103+00	2025-12-07 01:48:57.857103+00
ff8ab064-f049-49dc-a569-b14dcff55f52	3329f84c-1651-4583-93af-089fb8ec3a79	80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-12-07 01:48:57.863795+00	2025-12-07 01:48:57.863795+00
67fcdde1-8397-4428-9919-fd7a3909af45	3329f84c-1651-4583-93af-089fb8ec3a79	80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "session_id": "6cccb0dc-69d3-40f6-b102-cc929137a92e", "started_at": "2025-12-07T01:48:57.863423692Z", "finished_at": "2025-12-07T01:48:57.892793842Z", "discovery_type": {"type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11"}}}	{"type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11"}	Discovery Run	2025-12-07 01:48:57.863423+00	2025-12-07 01:48:57.895699+00
4130c38b-ab96-4c5b-b923-af0188fa1e32	3329f84c-1651-4583-93af-089fb8ec3a79	80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "session_id": "f1bc081e-1480-405c-912e-cd34f489b281", "started_at": "2025-12-07T01:48:57.906184710Z", "finished_at": "2025-12-07T01:50:33.814765184Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-12-07 01:48:57.906184+00	2025-12-07 01:50:33.817737+00
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
949e616a-0a44-40b8-bcfd-cf0a1af9d5f0	3329f84c-1651-4583-93af-089fb8ec3a79	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "73bf4928-2ecd-4c5d-8352-f75501b5da20"}	[{"id": "0d03d028-4514-4754-be84-5488916aabf4", "name": "Internet", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "ip_address": "1.1.1.1", "mac_address": null}]	{fe36636b-1315-4295-9524-ec30f178f9ba}	[{"id": "841a225f-d77a-4b2b-9b02-5e0967c5d04a", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-07 01:48:57.657346+00	2025-12-07 01:48:57.666343+00	f
2353ae54-2b93-4a85-b4f6-448f4ccabc02	3329f84c-1651-4583-93af-089fb8ec3a79	Google.com	\N	\N	{"type": "ServiceBinding", "config": "461ccb03-bd8e-4a95-b01c-49ff5866b6af"}	[{"id": "19a56061-ec46-494e-ab97-980fa20521f9", "name": "Internet", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "ip_address": "203.0.113.94", "mac_address": null}]	{f643cc8e-9c5c-48f1-8d89-093d773a0f49}	[{"id": "d135110f-df60-4c39-b659-165fbfd2acb0", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-07 01:48:57.657353+00	2025-12-07 01:48:57.671317+00	f
1264df83-b717-421e-bd28-92c4d6d48646	3329f84c-1651-4583-93af-089fb8ec3a79	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "532841d7-52e6-4141-b5eb-283e5f62da1e"}	[{"id": "c0e63372-2e6e-4938-88e8-20c6288a9151", "name": "Remote Network", "subnet_id": "c818accd-6521-4393-891d-4237490c2ca3", "ip_address": "203.0.113.246", "mac_address": null}]	{63d68669-f0a7-47b1-a600-c8ce02f06acb}	[{"id": "15b452ef-75c9-4735-bf51-f1cf30c4ae19", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-07 01:48:57.657358+00	2025-12-07 01:48:57.675171+00	f
e9ae92cf-f00e-4379-adca-bd8bacb3402c	3329f84c-1651-4583-93af-089fb8ec3a79	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8e3a9dee-2ba3-4236-b61d-237d96f4f192", "name": null, "subnet_id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "ip_address": "172.25.0.3", "mac_address": "56:EF:73:F0:46:78"}]	{d8751f80-d14c-43b5-8fda-dce3748cf307}	[{"id": "637f6b28-7ee9-4180-91ff-7759b0360ee3", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:49:44.517704283Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-07 01:49:44.517706+00	2025-12-07 01:49:58.887295+00	f
616ab26e-bae0-4a2d-930f-9a417673dd11	3329f84c-1651-4583-93af-089fb8ec3a79	172.25.0.4	585629057eec	NetVisor daemon	{"type": "None"}	[{"id": "c144c1e7-ed03-4a97-9a3e-d875e7365ac5", "name": "eth0", "subnet_id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "ip_address": "172.25.0.4", "mac_address": "7A:91:56:01:A6:2E"}]	{af051df8-295b-4ff4-b69a-d75dd3ca2ff8}	[{"id": "85884b84-e903-460a-86bf-959807cb3cfa", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:48:57.880820063Z", "type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab"}]}	null	2025-12-07 01:48:57.766629+00	2025-12-07 01:48:57.890815+00	f
6fb73888-4356-440c-9edf-e72f98351a44	3329f84c-1651-4583-93af-089fb8ec3a79	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "27f714cf-7a96-41de-a488-6c507dc1acd8", "name": null, "subnet_id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "ip_address": "172.25.0.5", "mac_address": "16:98:98:4F:CA:7E"}]	{88b0bfeb-e551-4292-9350-a850c5f85e85,eb754105-74cf-462a-ae35-98171e93dd84}	[{"id": "6b5fa96e-02da-460a-bac6-75aa84f55fd1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6acd78f7-0c7f-4f8f-bb19-38deb9ee88e3", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:49:29.943786381Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-07 01:49:29.943788+00	2025-12-07 01:49:44.433976+00	f
c6b5239d-bbf1-4c22-85c0-04167ad25639	3329f84c-1651-4583-93af-089fb8ec3a79	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8294e965-48f1-48b8-ab5b-4a8594083717", "name": null, "subnet_id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "ip_address": "172.25.0.6", "mac_address": "B2:67:CA:03:81:C2"}]	{90b0ab4e-c842-4188-a978-b6d4702d99b6}	[{"id": "6ae489fb-526c-4a9f-bdfd-a808b9d7e66c", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:49:58.876492468Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-07 01:49:58.876495+00	2025-12-07 01:50:13.365463+00	f
605dd99f-a3ce-434f-bda4-79d419c95619	3329f84c-1651-4583-93af-089fb8ec3a79	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "2cab2c21-0424-48f2-b823-8a9047e43d47", "name": null, "subnet_id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "ip_address": "172.25.0.1", "mac_address": "62:DA:CE:EF:F9:B2"}]	{6750d956-1c21-4a5d-af67-2a2f2c0b53d7,356e8c8c-e034-4066-870c-218a1be8b3fd,34ab936b-878d-4239-8aeb-f37d081285cb,4243c995-f3b0-4d12-ae4e-24e8a30c2446}	[{"id": "2affdbee-f814-4745-ad76-ec30e46b23ca", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "ce7959bf-4af6-4eea-96c6-716c36ef2984", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ccd1f1cc-7dee-4fb7-b1af-673b7f91d91a", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "c8bb44b8-c6ce-46ff-a84b-3d257aabc5b5", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:50:19.412141759Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-07 01:50:19.412144+00	2025-12-07 01:50:33.809241+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
3329f84c-1651-4583-93af-089fb8ec3a79	My Network	2025-12-07 01:48:57.656002+00	2025-12-07 01:48:57.656002+00	f	7837b476-1d5e-4e9c-9a34-fca06fd72381
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
7837b476-1d5e-4e9c-9a34-fca06fd72381	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-07 01:48:55.939194+00	2025-12-07 01:48:57.856043+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
fe36636b-1315-4295-9524-ec30f178f9ba	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.657348+00	2025-12-07 01:48:57.657348+00	Cloudflare DNS	949e616a-0a44-40b8-bcfd-cf0a1af9d5f0	[{"id": "73bf4928-2ecd-4c5d-8352-f75501b5da20", "type": "Port", "port_id": "841a225f-d77a-4b2b-9b02-5e0967c5d04a", "interface_id": "0d03d028-4514-4754-be84-5488916aabf4"}]	"Dns Server"	null	{"type": "System"}
f643cc8e-9c5c-48f1-8d89-093d773a0f49	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.657354+00	2025-12-07 01:48:57.657354+00	Google.com	2353ae54-2b93-4a85-b4f6-448f4ccabc02	[{"id": "461ccb03-bd8e-4a95-b01c-49ff5866b6af", "type": "Port", "port_id": "d135110f-df60-4c39-b659-165fbfd2acb0", "interface_id": "19a56061-ec46-494e-ab97-980fa20521f9"}]	"Web Service"	null	{"type": "System"}
63d68669-f0a7-47b1-a600-c8ce02f06acb	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.657359+00	2025-12-07 01:48:57.657359+00	Mobile Device	1264df83-b717-421e-bd28-92c4d6d48646	[{"id": "532841d7-52e6-4141-b5eb-283e5f62da1e", "type": "Port", "port_id": "15b452ef-75c9-4735-bf51-f1cf30c4ae19", "interface_id": "c0e63372-2e6e-4938-88e8-20c6288a9151"}]	"Client"	null	{"type": "System"}
af051df8-295b-4ff4-b69a-d75dd3ca2ff8	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.88084+00	2025-12-07 01:48:57.88084+00	NetVisor Daemon API	616ab26e-bae0-4a2d-930f-9a417673dd11	[{"id": "24067ff0-93dd-4fb4-94a7-e1ee61f7b7b8", "type": "Port", "port_id": "85884b84-e903-460a-86bf-959807cb3cfa", "interface_id": "c144c1e7-ed03-4a97-9a3e-d875e7365ac5"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-07T01:48:57.880839629Z", "type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab"}]}
88b0bfeb-e551-4292-9350-a850c5f85e85	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:49:36.524573+00	2025-12-07 01:49:36.524573+00	Home Assistant	6fb73888-4356-440c-9edf-e72f98351a44	[{"id": "68638909-f41a-4974-897f-934835040389", "type": "Port", "port_id": "6b5fa96e-02da-460a-bac6-75aa84f55fd1", "interface_id": "27f714cf-7a96-41de-a488-6c507dc1acd8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-07T01:49:36.524558714Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
eb754105-74cf-462a-ae35-98171e93dd84	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:49:44.415955+00	2025-12-07 01:49:44.415955+00	Unclaimed Open Ports	6fb73888-4356-440c-9edf-e72f98351a44	[{"id": "4fb4dc92-21f9-4866-b2fe-a0136b8935a5", "type": "Port", "port_id": "6acd78f7-0c7f-4f8f-bb19-38deb9ee88e3", "interface_id": "27f714cf-7a96-41de-a488-6c507dc1acd8"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-07T01:49:44.415935767Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d8751f80-d14c-43b5-8fda-dce3748cf307	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:49:45.237574+00	2025-12-07 01:49:45.237574+00	NetVisor Server API	e9ae92cf-f00e-4379-adca-bd8bacb3402c	[{"id": "01ecb811-6c95-4544-b0c6-e932f3c97129", "type": "Port", "port_id": "637f6b28-7ee9-4180-91ff-7759b0360ee3", "interface_id": "8e3a9dee-2ba3-4236-b61d-237d96f4f192"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-07T01:49:45.237557593Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
90b0ab4e-c842-4188-a978-b6d4702d99b6	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:50:13.355426+00	2025-12-07 01:50:13.355426+00	PostgreSQL	c6b5239d-bbf1-4c22-85c0-04167ad25639	[{"id": "18fa4b76-818b-47e4-909b-1e4df8f24a54", "type": "Port", "port_id": "6ae489fb-526c-4a9f-bdfd-a808b9d7e66c", "interface_id": "8294e965-48f1-48b8-ab5b-4a8594083717"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-07T01:50:13.355411537Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
356e8c8c-e034-4066-870c-218a1be8b3fd	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:50:25.893172+00	2025-12-07 01:50:25.893172+00	Home Assistant	605dd99f-a3ce-434f-bda4-79d419c95619	[{"id": "ef0f7660-25f2-4206-bd88-4ccb375556d0", "type": "Port", "port_id": "ce7959bf-4af6-4eea-96c6-716c36ef2984", "interface_id": "2cab2c21-0424-48f2-b823-8a9047e43d47"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-07T01:50:25.893155258Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
6750d956-1c21-4a5d-af67-2a2f2c0b53d7	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:50:20.129857+00	2025-12-07 01:50:20.129857+00	NetVisor Server API	605dd99f-a3ce-434f-bda4-79d419c95619	[{"id": "b0387c37-3a07-424b-be64-a76f895a78dd", "type": "Port", "port_id": "2affdbee-f814-4745-ad76-ec30e46b23ca", "interface_id": "2cab2c21-0424-48f2-b823-8a9047e43d47"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-07T01:50:20.129840270Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
4243c995-f3b0-4d12-ae4e-24e8a30c2446	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:50:33.794556+00	2025-12-07 01:50:33.794556+00	Unclaimed Open Ports	605dd99f-a3ce-434f-bda4-79d419c95619	[{"id": "4b00528c-92c6-4941-a583-750dd4b417dd", "type": "Port", "port_id": "c8bb44b8-c6ce-46ff-a84b-3d257aabc5b5", "interface_id": "2cab2c21-0424-48f2-b823-8a9047e43d47"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-07T01:50:33.794546545Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
34ab936b-878d-4239-8aeb-f37d081285cb	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:50:33.794376+00	2025-12-07 01:50:33.794376+00	SSH	605dd99f-a3ce-434f-bda4-79d419c95619	[{"id": "1f0fdae5-2198-4630-80ad-fc31e19488f0", "type": "Port", "port_id": "ccd1f1cc-7dee-4fb7-b1af-673b7f91d91a", "interface_id": "2cab2c21-0424-48f2-b823-8a9047e43d47"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-07T01:50:33.794358496Z", "type": "Network", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
1d1f658c-24f7-4745-8fb1-16124462dba9	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.657291+00	2025-12-07 01:48:57.657291+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
c818accd-6521-4393-891d-4237490c2ca3	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.657296+00	2025-12-07 01:48:57.657296+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
1ce8d22b-ca79-441b-8bce-26f45e365ce0	3329f84c-1651-4583-93af-089fb8ec3a79	2025-12-07 01:48:57.863575+00	2025-12-07 01:48:57.863575+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-07T01:48:57.863574623Z", "type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
560bc3e4-9382-4b81-98de-d598b076e62c	3329f84c-1651-4583-93af-089fb8ec3a79	My Topology	[]	[{"id": "c818accd-6521-4393-891d-4237490c2ca3", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "0d03d028-4514-4754-be84-5488916aabf4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "949e616a-0a44-40b8-bcfd-cf0a1af9d5f0", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "interface_id": "0d03d028-4514-4754-be84-5488916aabf4"}, {"id": "19a56061-ec46-494e-ab97-980fa20521f9", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2353ae54-2b93-4a85-b4f6-448f4ccabc02", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "interface_id": "19a56061-ec46-494e-ab97-980fa20521f9"}, {"id": "c0e63372-2e6e-4938-88e8-20c6288a9151", "size": {"x": 250, "y": 100}, "header": null, "host_id": "1264df83-b717-421e-bd28-92c4d6d48646", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "c818accd-6521-4393-891d-4237490c2ca3", "interface_id": "c0e63372-2e6e-4938-88e8-20c6288a9151"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "949e616a-0a44-40b8-bcfd-cf0a1af9d5f0", "name": "Cloudflare DNS", "ports": [{"id": "841a225f-d77a-4b2b-9b02-5e0967c5d04a", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "73bf4928-2ecd-4c5d-8352-f75501b5da20"}, "hostname": null, "services": ["fe36636b-1315-4295-9524-ec30f178f9ba"], "created_at": "2025-12-07T01:48:57.657346Z", "interfaces": [{"id": "0d03d028-4514-4754-be84-5488916aabf4", "name": "Internet", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.666343Z", "description": null, "virtualization": null}, {"id": "2353ae54-2b93-4a85-b4f6-448f4ccabc02", "name": "Google.com", "ports": [{"id": "d135110f-df60-4c39-b659-165fbfd2acb0", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "461ccb03-bd8e-4a95-b01c-49ff5866b6af"}, "hostname": null, "services": ["f643cc8e-9c5c-48f1-8d89-093d773a0f49"], "created_at": "2025-12-07T01:48:57.657353Z", "interfaces": [{"id": "19a56061-ec46-494e-ab97-980fa20521f9", "name": "Internet", "subnet_id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "ip_address": "203.0.113.94", "mac_address": null}], "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.671317Z", "description": null, "virtualization": null}, {"id": "1264df83-b717-421e-bd28-92c4d6d48646", "name": "Mobile Device", "ports": [{"id": "15b452ef-75c9-4735-bf51-f1cf30c4ae19", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "532841d7-52e6-4141-b5eb-283e5f62da1e"}, "hostname": null, "services": ["63d68669-f0a7-47b1-a600-c8ce02f06acb"], "created_at": "2025-12-07T01:48:57.657358Z", "interfaces": [{"id": "c0e63372-2e6e-4938-88e8-20c6288a9151", "name": "Remote Network", "subnet_id": "c818accd-6521-4393-891d-4237490c2ca3", "ip_address": "203.0.113.246", "mac_address": null}], "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.675171Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "1d1f658c-24f7-4745-8fb1-16124462dba9", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-07T01:48:57.657291Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.657291Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "c818accd-6521-4393-891d-4237490c2ca3", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-07T01:48:57.657296Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.657296Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "1ce8d22b-ca79-441b-8bce-26f45e365ce0", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-07T01:48:57.863574623Z", "type": "SelfReport", "host_id": "616ab26e-bae0-4a2d-930f-9a417673dd11", "daemon_id": "80e2b4a2-d5d3-4e20-a5d6-b0d4bb161eab"}]}, "created_at": "2025-12-07T01:48:57.863575Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.863575Z", "description": null, "subnet_type": "Lan"}]	[{"id": "fe36636b-1315-4295-9524-ec30f178f9ba", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "949e616a-0a44-40b8-bcfd-cf0a1af9d5f0", "bindings": [{"id": "73bf4928-2ecd-4c5d-8352-f75501b5da20", "type": "Port", "port_id": "841a225f-d77a-4b2b-9b02-5e0967c5d04a", "interface_id": "0d03d028-4514-4754-be84-5488916aabf4"}], "created_at": "2025-12-07T01:48:57.657348Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.657348Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "f643cc8e-9c5c-48f1-8d89-093d773a0f49", "name": "Google.com", "source": {"type": "System"}, "host_id": "2353ae54-2b93-4a85-b4f6-448f4ccabc02", "bindings": [{"id": "461ccb03-bd8e-4a95-b01c-49ff5866b6af", "type": "Port", "port_id": "d135110f-df60-4c39-b659-165fbfd2acb0", "interface_id": "19a56061-ec46-494e-ab97-980fa20521f9"}], "created_at": "2025-12-07T01:48:57.657354Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.657354Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "63d68669-f0a7-47b1-a600-c8ce02f06acb", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "1264df83-b717-421e-bd28-92c4d6d48646", "bindings": [{"id": "532841d7-52e6-4141-b5eb-283e5f62da1e", "type": "Port", "port_id": "15b452ef-75c9-4735-bf51-f1cf30c4ae19", "interface_id": "c0e63372-2e6e-4938-88e8-20c6288a9151"}], "created_at": "2025-12-07T01:48:57.657359Z", "network_id": "3329f84c-1651-4583-93af-089fb8ec3a79", "updated_at": "2025-12-07T01:48:57.657359Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-07 01:48:57.679404+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-07 01:48:57.675888+00	2025-12-07 01:50:13.55113+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
09a225cb-5141-4b7e-9b1a-3cdee8b3bf78	2025-12-07 01:48:55.941065+00	2025-12-07 01:48:57.638651+00	$argon2id$v=19$m=19456,t=2,p=1$0UJYTaTQBurlPKo8dj31nA$6TdUBz1SopjldLKfC+3A2FMXH3Zpg9vDNNUBv8nOwa0	\N	\N	\N	user@gmail.com	7837b476-1d5e-4e9c-9a34-fca06fd72381	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
uOK5UlFV81h816rNTtCwsA	\\x93c410b0b0d04ecdaad77c58f3555152b9e2b881a7757365725f6964d92430396132323563622d353134312d346237652d396231612d33636465653862336266373899cd07ea06013039ce26394ced000000	2026-01-06 01:48:57.641289+00
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
-- Name: topologies topologies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topologies
    ADD CONSTRAINT topologies_pkey PRIMARY KEY (id);


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
-- Name: idx_topologies_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_topologies_network ON public.topologies USING btree (network_id);


--
-- Name: idx_users_email_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_email_lower ON public.users USING btree (lower(email));


--
-- Name: idx_users_network_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_network_ids ON public.users USING gin (network_ids);


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
-- Name: topologies topologies_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topologies
    ADD CONSTRAINT topologies_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict HDmUXJDUYqeJHDaUt13NFHPxl4NYqze8pdmdR8xilL3yHde2K3bUfparbZyeSmC

