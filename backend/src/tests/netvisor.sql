--
-- PostgreSQL database dump
--

\restrict ROX8N6tLkyd7dcmIlqSJp4ZzAgQEy5xe2ru9NgKw00I0IBwf8be876LMRNs4I4f

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
20251006215000	users	2025-12-09 16:13:11.13205+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3961711
20251006215100	networks	2025-12-09 16:13:11.136789+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3867405
20251006215151	create hosts	2025-12-09 16:13:11.141063+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3886540
20251006215155	create subnets	2025-12-09 16:13:11.145372+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3865865
20251006215201	create groups	2025-12-09 16:13:11.149607+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3945611
20251006215204	create daemons	2025-12-09 16:13:11.1539+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4317616
20251006215212	create services	2025-12-09 16:13:11.158637+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4799687
20251029193448	user-auth	2025-12-09 16:13:11.16379+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3793715
20251030044828	daemon api	2025-12-09 16:13:11.167906+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1588229
20251030170438	host-hide	2025-12-09 16:13:11.169825+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1121705
20251102224919	create discovery	2025-12-09 16:13:11.171289+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9356199
20251106235621	normalize-daemon-cols	2025-12-09 16:13:11.180955+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1790765
20251107034459	api keys	2025-12-09 16:13:11.183049+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7352786
20251107222650	oidc-auth	2025-12-09 16:13:11.190812+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20190108
20251110181948	orgs-billing	2025-12-09 16:13:11.211338+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10008968
20251113223656	group-enhancements	2025-12-09 16:13:11.221722+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1224277
20251117032720	daemon-mode	2025-12-09 16:13:11.223241+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1087151
20251118143058	set-default-plan	2025-12-09 16:13:11.225707+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1294799
20251118225043	save-topology	2025-12-09 16:13:11.227326+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8709300
20251123232748	network-permissions	2025-12-09 16:13:11.236407+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2655526
20251125001342	billing-updates	2025-12-09 16:13:11.239439+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1002122
20251128035448	org-onboarding-status	2025-12-09 16:13:11.240796+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1523557
20251129180942	nfs-consolidate	2025-12-09 16:13:11.242677+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1447942
20251206052641	discovery-progress	2025-12-09 16:13:11.244524+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1480446
20251206202200	plan-fix	2025-12-09 16:13:11.246323+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	991189
20251207061341	daemon-url	2025-12-09 16:13:11.247617+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2305768
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
741e0d1b-7f57-47f1-b9eb-b331a9942e9b	e50f58f8fa4446608847225653e11937	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	Integrated Daemon API Key	2025-12-09 16:13:14.197373+00	2025-12-09 16:14:50.181202+00	2025-12-09 16:14:50.180077+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name) FROM stdin;
fde75b20-fb64-4c06-9295-06ab289e483d	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	41470c19-dfb9-46e9-8a52-2b304d3f1b63	2025-12-09 16:13:14.286425+00	2025-12-09 16:14:31.407218+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["ce1bc44c-e794-496e-88f6-8e8b51afd196"]}	2025-12-09 16:14:31.407867+00	"Push"	http://172.25.0.4:60073	netvisor-daemon
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
8dc61b29-3af9-4f5c-beb4-06b0c27860ca	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	fde75b20-fb64-4c06-9295-06ab289e483d	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63"}	Self Report	2025-12-09 16:13:14.293196+00	2025-12-09 16:13:14.293196+00
e548e59d-d86a-488e-b6a1-da5cf7443f4d	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	fde75b20-fb64-4c06-9295-06ab289e483d	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-09 16:13:14.301513+00	2025-12-09 16:13:14.301513+00
292a1fb8-219e-41ad-8e92-efff58d8300d	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	fde75b20-fb64-4c06-9295-06ab289e483d	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "session_id": "53ad2b81-3b2a-4c8d-b1d8-d8a62d659566", "started_at": "2025-12-09T16:13:14.299804613Z", "finished_at": "2025-12-09T16:13:14.403784950Z", "discovery_type": {"type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63"}}}	{"type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63"}	Self Report	2025-12-09 16:13:14.299804+00	2025-12-09 16:13:14.40656+00
8bd25083-e4ce-4a45-b014-234ea300b29a	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	fde75b20-fb64-4c06-9295-06ab289e483d	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "session_id": "fd40e9f6-db4e-40a1-8c19-f264227d82fc", "started_at": "2025-12-09T16:13:14.418174648Z", "finished_at": "2025-12-09T16:14:50.177708474Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-09 16:13:14.418174+00	2025-12-09 16:14:50.180352+00
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
61dccd39-e7b6-4d32-8582-5961f508f95c	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "9051c7e2-4e2b-4232-89f2-6d1c08d6e423"}	[{"id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f", "name": "Internet", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "ip_address": "1.1.1.1", "mac_address": null}]	{06d21117-731a-4fae-8479-225eaad10ca7}	[{"id": "56c1fa48-9f76-4af4-9d6e-86a0bc4d241e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-09 16:13:14.173176+00	2025-12-09 16:13:14.182078+00	f
d51d8ac4-7d24-4c92-802e-aa2f8aa13ad4	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	Google.com	\N	\N	{"type": "ServiceBinding", "config": "0375a52b-9a57-4cf9-8da1-803620b51e86"}	[{"id": "788d84b9-adc7-45b1-875e-7c1cb364caaa", "name": "Internet", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "ip_address": "203.0.113.199", "mac_address": null}]	{37ef7c8a-ef09-4c73-b55a-855a3c068045}	[{"id": "3ee08930-5367-4c46-9f5e-4153c85719f8", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-09 16:13:14.173183+00	2025-12-09 16:13:14.186925+00	f
d36961d8-ad45-45b9-877a-dc31ff725657	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "830370aa-9b21-420e-8a8f-e6b0bc06b652"}	[{"id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd", "name": "Remote Network", "subnet_id": "9939201a-36d5-464a-9c49-1a4d24e4a883", "ip_address": "203.0.113.8", "mac_address": null}]	{8d6eea57-6849-427d-aaa8-9b6f5052413c}	[{"id": "9a051f60-4e90-4084-871a-c0a54d49c061", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-09 16:13:14.173188+00	2025-12-09 16:13:14.190755+00	f
1faa6141-9082-4ad5-a374-c4e632cec07d	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8f168298-f89a-4f56-9f2b-8f88cb093426", "name": null, "subnet_id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "ip_address": "172.25.0.3", "mac_address": "62:BA:82:F3:20:D6"}]	{c33efc45-3306-4467-a60d-f3932d3bc1bb}	[{"id": "d5c502c5-2216-4a40-9647-19f535a6a28f", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:14:01.123715785Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 16:14:01.123718+00	2025-12-09 16:14:15.536815+00	f
41470c19-dfb9-46e9-8a52-2b304d3f1b63	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	netvisor-daemon	604004c1baf5	NetVisor daemon	{"type": "None"}	[{"id": "b5695361-9a00-4d6f-9810-53bb1d63a75a", "name": "eth0", "subnet_id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "ip_address": "172.25.0.4", "mac_address": "C6:4D:93:A6:A4:1C"}]	{eabc40e6-6482-4571-a5a7-eec3f6814880}	[{"id": "fdd68ed8-2d10-4868-a045-7b2ca621f4bb", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:13:14.390464175Z", "type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d"}]}	null	2025-12-09 16:13:14.282002+00	2025-12-09 16:13:14.401584+00	f
17a8257a-2032-4e02-94e6-0b936bd2508c	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e5764920-1180-421e-a88e-093541f0efbc", "name": null, "subnet_id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "ip_address": "172.25.0.5", "mac_address": "A2:61:83:A6:56:DB"}]	{5746df5f-61ad-4aee-a8ba-63ecf55c6350,615582f4-030e-41db-b1d6-e9811911b051}	[{"id": "feca21c1-5089-4627-a7fc-758c44d05a87", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "e7bd255a-68a6-4649-98a3-8a488849aef3", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:13:46.684840950Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 16:13:46.684843+00	2025-12-09 16:14:01.158318+00	f
274a9bfe-87dd-4224-8b89-217a45f7c6a8	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "df344bfa-ef09-4518-a2b7-d21b777db679", "name": null, "subnet_id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "ip_address": "172.25.0.6", "mac_address": "9E:C2:C3:39:D1:AC"}]	{c1fa75dc-888a-486c-807c-6378c119d52a}	[{"id": "e4c9f952-cfb4-42df-82f5-dd70b0f68e04", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:14:15.539950559Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 16:14:15.539951+00	2025-12-09 16:14:29.943575+00	f
91ff8bb6-5f80-421f-8cfa-845db68d87d6	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "64ce9a9d-25a5-4c72-a64f-9fd835dbc700", "name": null, "subnet_id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "ip_address": "172.25.0.1", "mac_address": "52:95:59:72:D4:80"}]	{a36d9924-ed6c-4c48-8a13-9bdb9456e6a0,dc8cd53a-44c2-4680-905e-a38b25ddb17d,b161433b-a9c5-4126-8c76-be3248f1da5a,efb483a3-3129-45c9-8d57-0d26d1a5b7ed}	[{"id": "ce929d99-92c7-4a2b-99c9-ffa3c2f6abcf", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1e9ad153-e439-4b30-97cd-58da8a1bfdce", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "f6dea6f5-b403-44e6-954d-fc953ba09e78", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "2654682b-4c1e-4b25-997c-b0e3c196e0d9", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:14:35.991087164Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 16:14:35.991089+00	2025-12-09 16:14:50.17197+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
9810a8e1-cf51-4f0a-8869-0767bedcc7e7	My Network	2025-12-09 16:13:14.171777+00	2025-12-09 16:13:14.171777+00	f	4d9163ef-f216-472e-8754-34691eab780b
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
4d9163ef-f216-472e-8754-34691eab780b	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-09 16:13:11.30531+00	2025-12-09 16:13:14.292444+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
06d21117-731a-4fae-8479-225eaad10ca7	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.173178+00	2025-12-09 16:13:14.173178+00	Cloudflare DNS	61dccd39-e7b6-4d32-8582-5961f508f95c	[{"id": "9051c7e2-4e2b-4232-89f2-6d1c08d6e423", "type": "Port", "port_id": "56c1fa48-9f76-4af4-9d6e-86a0bc4d241e", "interface_id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f"}]	"Dns Server"	null	{"type": "System"}
37ef7c8a-ef09-4c73-b55a-855a3c068045	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.173184+00	2025-12-09 16:13:14.173184+00	Google.com	d51d8ac4-7d24-4c92-802e-aa2f8aa13ad4	[{"id": "0375a52b-9a57-4cf9-8da1-803620b51e86", "type": "Port", "port_id": "3ee08930-5367-4c46-9f5e-4153c85719f8", "interface_id": "788d84b9-adc7-45b1-875e-7c1cb364caaa"}]	"Web Service"	null	{"type": "System"}
8d6eea57-6849-427d-aaa8-9b6f5052413c	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.17319+00	2025-12-09 16:13:14.17319+00	Mobile Device	d36961d8-ad45-45b9-877a-dc31ff725657	[{"id": "830370aa-9b21-420e-8a8f-e6b0bc06b652", "type": "Port", "port_id": "9a051f60-4e90-4084-871a-c0a54d49c061", "interface_id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd"}]	"Client"	null	{"type": "System"}
eabc40e6-6482-4571-a5a7-eec3f6814880	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.390485+00	2025-12-09 16:13:14.390485+00	NetVisor Daemon API	41470c19-dfb9-46e9-8a52-2b304d3f1b63	[{"id": "b3de6cb3-362b-41c9-8251-03000146eae8", "type": "Port", "port_id": "fdd68ed8-2d10-4868-a045-7b2ca621f4bb", "interface_id": "b5695361-9a00-4d6f-9810-53bb1d63a75a"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-09T16:13:14.390484273Z", "type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d"}]}
615582f4-030e-41db-b1d6-e9811911b051	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:01.077319+00	2025-12-09 16:14:01.077319+00	Unclaimed Open Ports	17a8257a-2032-4e02-94e6-0b936bd2508c	[{"id": "00ac44ce-5cee-42fb-b20b-1d35c896432a", "type": "Port", "port_id": "e7bd255a-68a6-4649-98a3-8a488849aef3", "interface_id": "e5764920-1180-421e-a88e-093541f0efbc"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T16:14:01.077302568Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5746df5f-61ad-4aee-a8ba-63ecf55c6350	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:58.199568+00	2025-12-09 16:13:58.199568+00	Home Assistant	17a8257a-2032-4e02-94e6-0b936bd2508c	[{"id": "37455db5-3237-45e0-b52d-78d972f559fd", "type": "Port", "port_id": "feca21c1-5089-4627-a7fc-758c44d05a87", "interface_id": "e5764920-1180-421e-a88e-093541f0efbc"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T16:13:58.199549502Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c33efc45-3306-4467-a60d-f3932d3bc1bb	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:15.519504+00	2025-12-09 16:14:15.519504+00	Unclaimed Open Ports	1faa6141-9082-4ad5-a374-c4e632cec07d	[{"id": "4ea0c426-15af-4f93-9208-a1bf17768fb0", "type": "Port", "port_id": "d5c502c5-2216-4a40-9647-19f535a6a28f", "interface_id": "8f168298-f89a-4f56-9f2b-8f88cb093426"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T16:14:15.519488535Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c1fa75dc-888a-486c-807c-6378c119d52a	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:29.933783+00	2025-12-09 16:14:29.933783+00	PostgreSQL	274a9bfe-87dd-4224-8b89-217a45f7c6a8	[{"id": "03bd51ab-4e7b-4871-a53c-32c71707a8cc", "type": "Port", "port_id": "e4c9f952-cfb4-42df-82f5-dd70b0f68e04", "interface_id": "df344bfa-ef09-4518-a2b7-d21b777db679"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T16:14:29.933767575Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
dc8cd53a-44c2-4680-905e-a38b25ddb17d	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:50.157341+00	2025-12-09 16:14:50.157341+00	NetVisor Server API	91ff8bb6-5f80-421f-8cfa-845db68d87d6	[{"id": "9bbfecbe-6af1-45dc-86d6-e066ab981e0a", "type": "Port", "port_id": "1e9ad153-e439-4b30-97cd-58da8a1bfdce", "interface_id": "64ce9a9d-25a5-4c72-a64f-9fd835dbc700"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T16:14:50.157322108Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
b161433b-a9c5-4126-8c76-be3248f1da5a	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:50.158486+00	2025-12-09 16:14:50.158486+00	SSH	91ff8bb6-5f80-421f-8cfa-845db68d87d6	[{"id": "c4a1b2d3-aa6f-447f-9b8e-99084ce39def", "type": "Port", "port_id": "f6dea6f5-b403-44e6-954d-fc953ba09e78", "interface_id": "64ce9a9d-25a5-4c72-a64f-9fd835dbc700"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T16:14:50.158476606Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
a36d9924-ed6c-4c48-8a13-9bdb9456e6a0	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:47.337131+00	2025-12-09 16:14:47.337131+00	Home Assistant	91ff8bb6-5f80-421f-8cfa-845db68d87d6	[{"id": "bfa6bef1-0ed9-4207-bf07-4c62244ae2ff", "type": "Port", "port_id": "ce929d99-92c7-4a2b-99c9-ffa3c2f6abcf", "interface_id": "64ce9a9d-25a5-4c72-a64f-9fd835dbc700"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T16:14:47.337111776Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
efb483a3-3129-45c9-8d57-0d26d1a5b7ed	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:14:50.158954+00	2025-12-09 16:14:50.158954+00	Unclaimed Open Ports	91ff8bb6-5f80-421f-8cfa-845db68d87d6	[{"id": "9ea1e611-f204-4ec6-a44e-7cecdd6351eb", "type": "Port", "port_id": "2654682b-4c1e-4b25-997c-b0e3c196e0d9", "interface_id": "64ce9a9d-25a5-4c72-a64f-9fd835dbc700"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T16:14:50.158946805Z", "type": "Network", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
a3a8a281-6524-4afc-ac8f-1abdc11be95b	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.173126+00	2025-12-09 16:13:14.173126+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
9939201a-36d5-464a-9c49-1a4d24e4a883	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.17313+00	2025-12-09 16:13:14.17313+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
ce1bc44c-e794-496e-88f6-8e8b51afd196	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	2025-12-09 16:13:14.299989+00	2025-12-09 16:13:14.299989+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-09T16:13:14.299987114Z", "type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
26c89745-9620-45bc-ae0b-61e772e1488a	9810a8e1-cf51-4f0a-8869-0767bedcc7e7	My Topology	[]	[{"id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "9939201a-36d5-464a-9c49-1a4d24e4a883", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd", "size": {"x": 250, "y": 100}, "header": null, "host_id": "d36961d8-ad45-45b9-877a-dc31ff725657", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9939201a-36d5-464a-9c49-1a4d24e4a883", "interface_id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd"}, {"id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "61dccd39-e7b6-4d32-8582-5961f508f95c", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "interface_id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f"}, {"id": "788d84b9-adc7-45b1-875e-7c1cb364caaa", "size": {"x": 250, "y": 100}, "header": null, "host_id": "d51d8ac4-7d24-4c92-802e-aa2f8aa13ad4", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "interface_id": "788d84b9-adc7-45b1-875e-7c1cb364caaa"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "61dccd39-e7b6-4d32-8582-5961f508f95c", "name": "Cloudflare DNS", "ports": [{"id": "56c1fa48-9f76-4af4-9d6e-86a0bc4d241e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "9051c7e2-4e2b-4232-89f2-6d1c08d6e423"}, "hostname": null, "services": ["06d21117-731a-4fae-8479-225eaad10ca7"], "created_at": "2025-12-09T16:13:14.173176Z", "interfaces": [{"id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f", "name": "Internet", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.182078Z", "description": null, "virtualization": null}, {"id": "d51d8ac4-7d24-4c92-802e-aa2f8aa13ad4", "name": "Google.com", "ports": [{"id": "3ee08930-5367-4c46-9f5e-4153c85719f8", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "0375a52b-9a57-4cf9-8da1-803620b51e86"}, "hostname": null, "services": ["37ef7c8a-ef09-4c73-b55a-855a3c068045"], "created_at": "2025-12-09T16:13:14.173183Z", "interfaces": [{"id": "788d84b9-adc7-45b1-875e-7c1cb364caaa", "name": "Internet", "subnet_id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "ip_address": "203.0.113.199", "mac_address": null}], "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.186925Z", "description": null, "virtualization": null}, {"id": "d36961d8-ad45-45b9-877a-dc31ff725657", "name": "Mobile Device", "ports": [{"id": "9a051f60-4e90-4084-871a-c0a54d49c061", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "830370aa-9b21-420e-8a8f-e6b0bc06b652"}, "hostname": null, "services": ["8d6eea57-6849-427d-aaa8-9b6f5052413c"], "created_at": "2025-12-09T16:13:14.173188Z", "interfaces": [{"id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd", "name": "Remote Network", "subnet_id": "9939201a-36d5-464a-9c49-1a4d24e4a883", "ip_address": "203.0.113.8", "mac_address": null}], "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.190755Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "a3a8a281-6524-4afc-ac8f-1abdc11be95b", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-09T16:13:14.173126Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.173126Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "9939201a-36d5-464a-9c49-1a4d24e4a883", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-09T16:13:14.173130Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.173130Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "ce1bc44c-e794-496e-88f6-8e8b51afd196", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-09T16:13:14.299987114Z", "type": "SelfReport", "host_id": "41470c19-dfb9-46e9-8a52-2b304d3f1b63", "daemon_id": "fde75b20-fb64-4c06-9295-06ab289e483d"}]}, "created_at": "2025-12-09T16:13:14.299989Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.299989Z", "description": null, "subnet_type": "Lan"}]	[{"id": "06d21117-731a-4fae-8479-225eaad10ca7", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "61dccd39-e7b6-4d32-8582-5961f508f95c", "bindings": [{"id": "9051c7e2-4e2b-4232-89f2-6d1c08d6e423", "type": "Port", "port_id": "56c1fa48-9f76-4af4-9d6e-86a0bc4d241e", "interface_id": "6f252408-5e75-4ed6-ad64-5fc13b3dc20f"}], "created_at": "2025-12-09T16:13:14.173178Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.173178Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "37ef7c8a-ef09-4c73-b55a-855a3c068045", "name": "Google.com", "source": {"type": "System"}, "host_id": "d51d8ac4-7d24-4c92-802e-aa2f8aa13ad4", "bindings": [{"id": "0375a52b-9a57-4cf9-8da1-803620b51e86", "type": "Port", "port_id": "3ee08930-5367-4c46-9f5e-4153c85719f8", "interface_id": "788d84b9-adc7-45b1-875e-7c1cb364caaa"}], "created_at": "2025-12-09T16:13:14.173184Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.173184Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "8d6eea57-6849-427d-aaa8-9b6f5052413c", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "d36961d8-ad45-45b9-877a-dc31ff725657", "bindings": [{"id": "830370aa-9b21-420e-8a8f-e6b0bc06b652", "type": "Port", "port_id": "9a051f60-4e90-4084-871a-c0a54d49c061", "interface_id": "90c03199-e1a2-4e63-9f41-a3edfd3314cd"}], "created_at": "2025-12-09T16:13:14.173190Z", "network_id": "9810a8e1-cf51-4f0a-8869-0767bedcc7e7", "updated_at": "2025-12-09T16:13:14.173190Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-09 16:13:14.194759+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-09 16:13:14.191454+00	2025-12-09 16:14:30.117243+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
38194420-b895-4678-a9c4-3210c53b62a2	2025-12-09 16:13:11.307263+00	2025-12-09 16:13:14.152846+00	$argon2id$v=19$m=19456,t=2,p=1$DuhMjjjkq9Ze1ZNibChwfA$62cs74x8PSjbg0Vgzr7gZJcJ+DuY+sdZOgDxu0nNiWc	\N	\N	\N	user@gmail.com	4d9163ef-f216-472e-8754-34691eab780b	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
OrmZqcX8_GFwwZl-oi78Fg	\\x93c41016fc2ea27e99c17061fcfcc5a999b93a81a7757365725f6964d92433383139343432302d623839352d343637382d613963342d33323130633533623632613299cd07ea08100d0ece0946b0b3000000	2026-01-08 16:13:14.155627+00
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

\unrestrict ROX8N6tLkyd7dcmIlqSJp4ZzAgQEy5xe2ru9NgKw00I0IBwf8be876LMRNs4I4f

