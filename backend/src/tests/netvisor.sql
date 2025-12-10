--
-- PostgreSQL database dump
--

\restrict To8uLaMtcCa4oIqv1GcTN6UUfAmjxFPBndZkddlJPTypnxNzOq1Xht45gezkDY1

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
    created_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text,
    url text NOT NULL,
    name text
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
20251006215000	users	2025-12-10 01:03:06.072427+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3890269
20251006215100	networks	2025-12-10 01:03:06.077131+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4097356
20251006215151	create hosts	2025-12-10 01:03:06.081735+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3976380
20251006215155	create subnets	2025-12-10 01:03:06.08611+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	6530405
20251006215201	create groups	2025-12-10 01:03:06.093103+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3971961
20251006215204	create daemons	2025-12-10 01:03:06.097557+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4264909
20251006215212	create services	2025-12-10 01:03:06.102222+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5031509
20251029193448	user-auth	2025-12-10 01:03:06.107611+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3804339
20251030044828	daemon api	2025-12-10 01:03:06.111778+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1556264
20251030170438	host-hide	2025-12-10 01:03:06.113739+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1288044
20251102224919	create discovery	2025-12-10 01:03:06.115265+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9928707
20251106235621	normalize-daemon-cols	2025-12-10 01:03:06.125587+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1949258
20251107034459	api keys	2025-12-10 01:03:06.127862+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7455051
20251107222650	oidc-auth	2025-12-10 01:03:06.135658+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20933411
20251110181948	orgs-billing	2025-12-10 01:03:06.157033+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10626139
20251113223656	group-enhancements	2025-12-10 01:03:06.168022+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1039039
20251117032720	daemon-mode	2025-12-10 01:03:06.169349+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1168340
20251118143058	set-default-plan	2025-12-10 01:03:06.170908+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1190311
20251118225043	save-topology	2025-12-10 01:03:06.172562+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8999583
20251123232748	network-permissions	2025-12-10 01:03:06.181908+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2776752
20251125001342	billing-updates	2025-12-10 01:03:06.184984+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1027487
20251128035448	org-onboarding-status	2025-12-10 01:03:06.186323+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1724859
20251129180942	nfs-consolidate	2025-12-10 01:03:06.188361+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1339650
20251206052641	discovery-progress	2025-12-10 01:03:06.190057+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1450827
20251206202200	plan-fix	2025-12-10 01:03:06.191841+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	943390
20251207061341	daemon-url	2025-12-10 01:03:06.193094+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2149140
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
5b342516-d04c-41c8-aa73-ca40c561311a	5c0a66db23934457bd21e96f31769fa4	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	Integrated Daemon API Key	2025-12-10 01:03:07.497214+00	2025-12-10 01:04:45.923642+00	2025-12-10 01:04:45.922883+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name) FROM stdin;
c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	bb7abcf3-5540-42e5-a7ae-ce2821300ed0	2025-12-10 01:03:07.587538+00	2025-12-10 01:04:22.637018+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["03f8d2db-5fd7-408f-a897-defadec9cb2a"]}	2025-12-10 01:04:22.63762+00	"Push"	http://172.25.0.4:60073	netvisor-daemon
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
4e4af240-b7b5-4f5f-a92b-1a7ff40e5e23	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0"}	Self Report	2025-12-10 01:03:07.594557+00	2025-12-10 01:03:07.594557+00
3093bb5f-e428-4d31-b374-a35efa344777	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 01:03:07.60161+00	2025-12-10 01:03:07.60161+00
83edeebb-deaf-4389-9dbd-73ad7423a490	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "session_id": "eca1956e-9af9-4d0d-bc90-53dc24ab34ac", "started_at": "2025-12-10T01:03:07.601207820Z", "finished_at": "2025-12-10T01:03:07.749224200Z", "discovery_type": {"type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0"}}}	{"type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0"}	Self Report	2025-12-10 01:03:07.601207+00	2025-12-10 01:03:07.752993+00
d802b1ad-0ea0-4abf-805f-caf0d9b1284a	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "session_id": "8721b03c-8f3f-4bb1-95c6-e7e06da62adc", "started_at": "2025-12-10T01:03:07.766564228Z", "finished_at": "2025-12-10T01:04:45.920493770Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 01:03:07.766564+00	2025-12-10 01:04:45.923204+00
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
3a33db1c-2e3b-4b6b-bc8f-8e39638e6d5c	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "5d9cbf64-5163-4def-83df-425ff3192e36"}	[{"id": "03daa8f0-9ad6-4948-92e7-5d44614314d2", "name": "Internet", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "ip_address": "1.1.1.1", "mac_address": null}]	{ed4da82f-f328-4b88-8d46-047d233c98ed}	[{"id": "b4bc6837-bb99-4ad4-b530-f4987706abd1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-10 01:03:07.471506+00	2025-12-10 01:03:07.480768+00	f
3b0e6ac7-12af-4502-b7d6-f6eaf2a12904	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	Google.com	\N	\N	{"type": "ServiceBinding", "config": "5021e758-c326-4668-9efd-255d57802976"}	[{"id": "7a5617da-3a5f-4503-b021-0906c3f61437", "name": "Internet", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "ip_address": "203.0.113.81", "mac_address": null}]	{b276a233-1b35-4835-8991-a65a7307a47a}	[{"id": "c1eaa434-136e-42be-9e3b-b432515a60d1", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 01:03:07.471531+00	2025-12-10 01:03:07.485841+00	f
7748aa0f-167f-46fc-94c6-5ee24a956c5d	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "28eecd70-6451-46c6-905a-8b18be165baf"}	[{"id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa", "name": "Remote Network", "subnet_id": "95d592b7-1595-4369-ba3e-451dbff8244b", "ip_address": "203.0.113.128", "mac_address": null}]	{4bdfd90e-41ed-40e8-a117-3f8271e14d09}	[{"id": "2313bd26-7920-461c-83db-53f2014224a3", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 01:03:07.471542+00	2025-12-10 01:03:07.489763+00	f
211d3053-c9ca-4bc6-bc71-c613f6b9c074	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "38e0ff71-228f-4f90-b890-6ec72110a2ed", "name": null, "subnet_id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "ip_address": "172.25.0.3", "mac_address": "E6:25:24:C2:B3:A9"}]	{be2e813e-5521-48b2-988c-7ea3ecfe2d54}	[{"id": "0b0ee6f0-072f-4f9f-bba5-804b839a7bc7", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:03:56.090023316Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 01:03:56.090026+00	2025-12-10 01:04:11.339057+00	f
bb7abcf3-5540-42e5-a7ae-ce2821300ed0	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	netvisor-daemon	f86c053fafc1	NetVisor daemon	{"type": "None"}	[{"id": "74fef0d8-2c38-41a6-8926-4085b1bafa15", "name": "eth0", "subnet_id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "ip_address": "172.25.0.4", "mac_address": "0A:DE:C4:39:5D:5E"}]	{5a7b1602-4760-4d8d-b6b0-fd7feaeb4f78}	[{"id": "5c46fdd2-c5a3-4913-8c51-8168e6d66c1b", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:03:07.622325457Z", "type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f"}]}	null	2025-12-10 01:03:07.584373+00	2025-12-10 01:03:07.746157+00	f
376019ad-5b42-48bd-991e-b573a5d36a9f	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "9671ff31-ad21-4207-9817-773a12f276fc", "name": null, "subnet_id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "ip_address": "172.25.0.6", "mac_address": "12:FB:48:7C:49:56"}]	{47e9a07d-4da9-4e69-afeb-296509011ac4}	[{"id": "fc7f355c-02da-4035-8715-2bdcc0f6d361", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:03:40.668729700Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 01:03:40.668733+00	2025-12-10 01:03:56.012808+00	f
654d854b-9273-462c-9c9f-e06811887134	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "b3caffda-dd45-4b66-904d-2be026447885", "name": null, "subnet_id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "ip_address": "172.25.0.5", "mac_address": "BA:D5:6D:70:24:71"}]	{691ac06e-147b-4aec-bf24-a45a89af6362}	[{"id": "ce6f7cbf-0ed2-4586-84d2-cf513d29c1d4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "fb03d1b5-9131-46e7-8057-acbe720ea775", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:04:11.342996067Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 01:04:11.342998+00	2025-12-10 01:04:26.610775+00	f
73afa08c-12f2-4e10-92f3-54f05566bfc6	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "7bde7730-9d13-422e-a414-8abf54745405", "name": null, "subnet_id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "ip_address": "172.25.0.1", "mac_address": "7A:CD:93:14:67:CA"}]	{6732017d-2f0b-4742-a3fa-04ec8f0fca18,1000a958-d772-4125-a45d-8fd2ad28fd14,defa03f3-c78a-4a8d-a422-05c1a8c9d24b,58f63d68-9492-4123-aa4d-62c848a3269a}	[{"id": "729bf3ec-c409-499d-b1f0-7c0c2c300de0", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "ff4436d1-6fe5-4381-90ee-2dbd872aae5b", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "4f051c04-aa13-4390-9633-c672973aff2b", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "1dfff040-6fa4-4280-8de9-7b32833c8268", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:04:30.665398433Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 01:04:30.665402+00	2025-12-10 01:04:45.914218+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
abff052f-ddc1-4046-8f2b-d1b8640ef6ab	My Network	2025-12-10 01:03:07.470036+00	2025-12-10 01:03:07.470036+00	f	9d4e52ed-5e9e-466b-b99f-23a114619823
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
9d4e52ed-5e9e-466b-b99f-23a114619823	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-10 01:03:06.256654+00	2025-12-10 01:03:07.593458+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
ed4da82f-f328-4b88-8d46-047d233c98ed	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.471508+00	2025-12-10 01:03:07.471508+00	Cloudflare DNS	3a33db1c-2e3b-4b6b-bc8f-8e39638e6d5c	[{"id": "5d9cbf64-5163-4def-83df-425ff3192e36", "type": "Port", "port_id": "b4bc6837-bb99-4ad4-b530-f4987706abd1", "interface_id": "03daa8f0-9ad6-4948-92e7-5d44614314d2"}]	"Dns Server"	null	{"type": "System"}
b276a233-1b35-4835-8991-a65a7307a47a	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.471533+00	2025-12-10 01:03:07.471533+00	Google.com	3b0e6ac7-12af-4502-b7d6-f6eaf2a12904	[{"id": "5021e758-c326-4668-9efd-255d57802976", "type": "Port", "port_id": "c1eaa434-136e-42be-9e3b-b432515a60d1", "interface_id": "7a5617da-3a5f-4503-b021-0906c3f61437"}]	"Web Service"	null	{"type": "System"}
4bdfd90e-41ed-40e8-a117-3f8271e14d09	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.471544+00	2025-12-10 01:03:07.471544+00	Mobile Device	7748aa0f-167f-46fc-94c6-5ee24a956c5d	[{"id": "28eecd70-6451-46c6-905a-8b18be165baf", "type": "Port", "port_id": "2313bd26-7920-461c-83db-53f2014224a3", "interface_id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa"}]	"Client"	null	{"type": "System"}
5a7b1602-4760-4d8d-b6b0-fd7feaeb4f78	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.622343+00	2025-12-10 01:03:07.622343+00	NetVisor Daemon API	bb7abcf3-5540-42e5-a7ae-ce2821300ed0	[{"id": "cb5f7b0e-67b5-46ea-8d89-e55e79c35b46", "type": "Port", "port_id": "5c46fdd2-c5a3-4913-8c51-8168e6d66c1b", "interface_id": "74fef0d8-2c38-41a6-8926-4085b1bafa15"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-10T01:03:07.622342860Z", "type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f"}]}
47e9a07d-4da9-4e69-afeb-296509011ac4	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:55.998071+00	2025-12-10 01:03:55.998071+00	PostgreSQL	376019ad-5b42-48bd-991e-b573a5d36a9f	[{"id": "628dfda6-7572-4518-804c-a93b0a5c5603", "type": "Port", "port_id": "fc7f355c-02da-4035-8715-2bdcc0f6d361", "interface_id": "9671ff31-ad21-4207-9817-773a12f276fc"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T01:03:55.998053798Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
be2e813e-5521-48b2-988c-7ea3ecfe2d54	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:59.946968+00	2025-12-10 01:03:59.946968+00	NetVisor Server API	211d3053-c9ca-4bc6-bc71-c613f6b9c074	[{"id": "1949118d-c70e-4e76-8724-0a39cd0ed604", "type": "Port", "port_id": "0b0ee6f0-072f-4f9f-bba5-804b839a7bc7", "interface_id": "38e0ff71-228f-4f90-b890-6ec72110a2ed"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T01:03:59.946949123Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
691ac06e-147b-4aec-bf24-a45a89af6362	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:04:26.601139+00	2025-12-10 01:04:26.601139+00	Unclaimed Open Ports	654d854b-9273-462c-9c9f-e06811887134	[{"id": "9738b319-31ca-44fa-8557-17c040994a58", "type": "Port", "port_id": "ce6f7cbf-0ed2-4586-84d2-cf513d29c1d4", "interface_id": "b3caffda-dd45-4b66-904d-2be026447885"}, {"id": "787973e4-4a4b-4915-9fc2-613b95db46e4", "type": "Port", "port_id": "fb03d1b5-9131-46e7-8057-acbe720ea775", "interface_id": "b3caffda-dd45-4b66-904d-2be026447885"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T01:04:26.601117204Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
6732017d-2f0b-4742-a3fa-04ec8f0fca18	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:04:34.477918+00	2025-12-10 01:04:34.477918+00	NetVisor Server API	73afa08c-12f2-4e10-92f3-54f05566bfc6	[{"id": "07cfa9b5-9c71-424e-ba6c-75c53afdc385", "type": "Port", "port_id": "729bf3ec-c409-499d-b1f0-7c0c2c300de0", "interface_id": "7bde7730-9d13-422e-a414-8abf54745405"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T01:04:34.477900872Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
1000a958-d772-4125-a45d-8fd2ad28fd14	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:04:39.815941+00	2025-12-10 01:04:39.815941+00	Home Assistant	73afa08c-12f2-4e10-92f3-54f05566bfc6	[{"id": "82d5f9a8-7243-46ab-905f-a3ceaca407f0", "type": "Port", "port_id": "ff4436d1-6fe5-4381-90ee-2dbd872aae5b", "interface_id": "7bde7730-9d13-422e-a414-8abf54745405"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T01:04:39.815917028Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
defa03f3-c78a-4a8d-a422-05c1a8c9d24b	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:04:45.900715+00	2025-12-10 01:04:45.900715+00	SSH	73afa08c-12f2-4e10-92f3-54f05566bfc6	[{"id": "40a852cf-949e-4601-ad43-9a6b5a150ed0", "type": "Port", "port_id": "4f051c04-aa13-4390-9633-c672973aff2b", "interface_id": "7bde7730-9d13-422e-a414-8abf54745405"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T01:04:45.900697630Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
58f63d68-9492-4123-aa4d-62c848a3269a	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:04:45.901042+00	2025-12-10 01:04:45.901042+00	Unclaimed Open Ports	73afa08c-12f2-4e10-92f3-54f05566bfc6	[{"id": "f303b5f8-5ed9-4069-9bd8-b6963986bec1", "type": "Port", "port_id": "1dfff040-6fa4-4280-8de9-7b32833c8268", "interface_id": "7bde7730-9d13-422e-a414-8abf54745405"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T01:04:45.901032775Z", "type": "Network", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
2855b565-53ad-490b-9f64-f093984c9bde	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.471446+00	2025-12-10 01:03:07.471446+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
95d592b7-1595-4369-ba3e-451dbff8244b	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.471449+00	2025-12-10 01:03:07.471449+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
03f8d2db-5fd7-408f-a897-defadec9cb2a	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	2025-12-10 01:03:07.601362+00	2025-12-10 01:03:07.601362+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-10T01:03:07.601360816Z", "type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
5ed1e006-15f4-4fe9-919a-573e10edd816	abff052f-ddc1-4046-8f2b-d1b8640ef6ab	My Topology	[]	[{"id": "95d592b7-1595-4369-ba3e-451dbff8244b", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "2855b565-53ad-490b-9f64-f093984c9bde", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa", "size": {"x": 250, "y": 100}, "header": null, "host_id": "7748aa0f-167f-46fc-94c6-5ee24a956c5d", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "95d592b7-1595-4369-ba3e-451dbff8244b", "interface_id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa"}, {"id": "03daa8f0-9ad6-4948-92e7-5d44614314d2", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3a33db1c-2e3b-4b6b-bc8f-8e39638e6d5c", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "interface_id": "03daa8f0-9ad6-4948-92e7-5d44614314d2"}, {"id": "7a5617da-3a5f-4503-b021-0906c3f61437", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3b0e6ac7-12af-4502-b7d6-f6eaf2a12904", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "interface_id": "7a5617da-3a5f-4503-b021-0906c3f61437"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "3a33db1c-2e3b-4b6b-bc8f-8e39638e6d5c", "name": "Cloudflare DNS", "ports": [{"id": "b4bc6837-bb99-4ad4-b530-f4987706abd1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "5d9cbf64-5163-4def-83df-425ff3192e36"}, "hostname": null, "services": ["ed4da82f-f328-4b88-8d46-047d233c98ed"], "created_at": "2025-12-10T01:03:07.471506Z", "interfaces": [{"id": "03daa8f0-9ad6-4948-92e7-5d44614314d2", "name": "Internet", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.480768Z", "description": null, "virtualization": null}, {"id": "3b0e6ac7-12af-4502-b7d6-f6eaf2a12904", "name": "Google.com", "ports": [{"id": "c1eaa434-136e-42be-9e3b-b432515a60d1", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "5021e758-c326-4668-9efd-255d57802976"}, "hostname": null, "services": ["b276a233-1b35-4835-8991-a65a7307a47a"], "created_at": "2025-12-10T01:03:07.471531Z", "interfaces": [{"id": "7a5617da-3a5f-4503-b021-0906c3f61437", "name": "Internet", "subnet_id": "2855b565-53ad-490b-9f64-f093984c9bde", "ip_address": "203.0.113.81", "mac_address": null}], "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.485841Z", "description": null, "virtualization": null}, {"id": "7748aa0f-167f-46fc-94c6-5ee24a956c5d", "name": "Mobile Device", "ports": [{"id": "2313bd26-7920-461c-83db-53f2014224a3", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "28eecd70-6451-46c6-905a-8b18be165baf"}, "hostname": null, "services": ["4bdfd90e-41ed-40e8-a117-3f8271e14d09"], "created_at": "2025-12-10T01:03:07.471542Z", "interfaces": [{"id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa", "name": "Remote Network", "subnet_id": "95d592b7-1595-4369-ba3e-451dbff8244b", "ip_address": "203.0.113.128", "mac_address": null}], "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.489763Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "2855b565-53ad-490b-9f64-f093984c9bde", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-10T01:03:07.471446Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.471446Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "95d592b7-1595-4369-ba3e-451dbff8244b", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-10T01:03:07.471449Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.471449Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "03f8d2db-5fd7-408f-a897-defadec9cb2a", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-10T01:03:07.601360816Z", "type": "SelfReport", "host_id": "bb7abcf3-5540-42e5-a7ae-ce2821300ed0", "daemon_id": "c5a3ccaf-d54a-4c00-8623-18f0e6d54c6f"}]}, "created_at": "2025-12-10T01:03:07.601362Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.601362Z", "description": null, "subnet_type": "Lan"}]	[{"id": "ed4da82f-f328-4b88-8d46-047d233c98ed", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "3a33db1c-2e3b-4b6b-bc8f-8e39638e6d5c", "bindings": [{"id": "5d9cbf64-5163-4def-83df-425ff3192e36", "type": "Port", "port_id": "b4bc6837-bb99-4ad4-b530-f4987706abd1", "interface_id": "03daa8f0-9ad6-4948-92e7-5d44614314d2"}], "created_at": "2025-12-10T01:03:07.471508Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.471508Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "b276a233-1b35-4835-8991-a65a7307a47a", "name": "Google.com", "source": {"type": "System"}, "host_id": "3b0e6ac7-12af-4502-b7d6-f6eaf2a12904", "bindings": [{"id": "5021e758-c326-4668-9efd-255d57802976", "type": "Port", "port_id": "c1eaa434-136e-42be-9e3b-b432515a60d1", "interface_id": "7a5617da-3a5f-4503-b021-0906c3f61437"}], "created_at": "2025-12-10T01:03:07.471533Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.471533Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "4bdfd90e-41ed-40e8-a117-3f8271e14d09", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "7748aa0f-167f-46fc-94c6-5ee24a956c5d", "bindings": [{"id": "28eecd70-6451-46c6-905a-8b18be165baf", "type": "Port", "port_id": "2313bd26-7920-461c-83db-53f2014224a3", "interface_id": "0a6bb021-deb6-4fcc-a69d-f1557b5119fa"}], "created_at": "2025-12-10T01:03:07.471544Z", "network_id": "abff052f-ddc1-4046-8f2b-d1b8640ef6ab", "updated_at": "2025-12-10T01:03:07.471544Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-10 01:03:07.494313+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-10 01:03:07.490546+00	2025-12-10 01:04:26.663941+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
56644239-f060-4075-8038-8bd3525b9b39	2025-12-10 01:03:06.258713+00	2025-12-10 01:03:07.451746+00	$argon2id$v=19$m=19456,t=2,p=1$k9iEGdOlm+++qm5VgzcKYQ$v12DS+vmV+Nl9CeyPP0++GdMu9WrNH82QfbYpNHOTWQ	\N	\N	\N	user@gmail.com	9d4e52ed-5e9e-466b-b99f-23a114619823	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
SyP4NuuTGj-5Ju4R6Y16ug	\\x93c410ba7a8de911ee26b93f1a93eb36f8234b81a7757365725f6964d92435363634343233392d663036302d343037352d383033382d38626433353235623962333999cd07ea09010307ce1b15d739000000	2026-01-09 01:03:07.454416+00
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

\unrestrict To8uLaMtcCa4oIqv1GcTN6UUfAmjxFPBndZkddlJPTypnxNzOq1Xht45gezkDY1

