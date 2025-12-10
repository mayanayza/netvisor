--
-- PostgreSQL database dump
--

\restrict y1GJXLS7vTkQfpscfUSdR6J3aQGEFxSjRbxLPKjla9ta2nsdVQjCMnmPzeKWNXm

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
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS tags_organization_id_fkey;
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
DROP INDEX IF EXISTS public.idx_tags_organization;
DROP INDEX IF EXISTS public.idx_tags_org_name;
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
ALTER TABLE IF EXISTS ONLY public.tags DROP CONSTRAINT IF EXISTS tags_pkey;
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
DROP TABLE IF EXISTS public.tags;
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
    is_enabled boolean DEFAULT true NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    name text,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    updated_at timestamp with time zone NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    edge_style text DEFAULT '"SmoothStep"'::text,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    hidden boolean DEFAULT false,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    organization_id uuid NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    source jsonb NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    source jsonb NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
);


ALTER TABLE public.subnets OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tags (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    color text NOT NULL
);


ALTER TABLE public.tags OWNER TO postgres;

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
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
    network_ids uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-10 07:27:15.754082+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3435210
20251006215100	networks	2025-12-10 07:27:15.75846+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4614130
20251006215151	create hosts	2025-12-10 07:27:15.763393+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3882173
20251006215155	create subnets	2025-12-10 07:27:15.767657+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3647787
20251006215201	create groups	2025-12-10 07:27:15.771637+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3679575
20251006215204	create daemons	2025-12-10 07:27:15.775655+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4059745
20251006215212	create services	2025-12-10 07:27:15.780032+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4660627
20251029193448	user-auth	2025-12-10 07:27:15.784997+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5882175
20251030044828	daemon api	2025-12-10 07:27:15.791196+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1586840
20251030170438	host-hide	2025-12-10 07:27:15.793098+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1071239
20251102224919	create discovery	2025-12-10 07:27:15.7945+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10290672
20251106235621	normalize-daemon-cols	2025-12-10 07:27:15.805112+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1706524
20251107034459	api keys	2025-12-10 07:27:15.807092+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7792270
20251107222650	oidc-auth	2025-12-10 07:27:15.815172+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	27728587
20251110181948	orgs-billing	2025-12-10 07:27:15.843304+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10675680
20251113223656	group-enhancements	2025-12-10 07:27:15.854303+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1008442
20251117032720	daemon-mode	2025-12-10 07:27:15.8556+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1063414
20251118143058	set-default-plan	2025-12-10 07:27:15.85695+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1138044
20251118225043	save-topology	2025-12-10 07:27:15.858367+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8685747
20251123232748	network-permissions	2025-12-10 07:27:15.867368+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2663791
20251125001342	billing-updates	2025-12-10 07:27:15.870324+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	868631
20251128035448	org-onboarding-status	2025-12-10 07:27:15.87149+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1372340
20251129180942	nfs-consolidate	2025-12-10 07:27:15.873141+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1185833
20251206052641	discovery-progress	2025-12-10 07:27:15.874628+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1791021
20251206202200	plan-fix	2025-12-10 07:27:15.87689+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	916220
20251207061341	daemon-url	2025-12-10 07:27:15.87807+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2278922
20251210045929	tags	2025-12-10 07:27:15.880677+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8627338
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
cc279cce-99fa-4c2e-8f1f-d0ac4efe72a9	fff0b861c63048d4938a6e01710020e9	40846f9a-fe66-4922-b89e-115493c8633e	Integrated Daemon API Key	2025-12-10 07:27:18.923271+00	2025-12-10 07:28:55.155472+00	2025-12-10 07:28:55.154706+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
06057b2e-9b19-4bbb-9c86-a1288af0509d	40846f9a-fe66-4922-b89e-115493c8633e	c42206f4-652f-4302-befa-55ac6db5fa96	2025-12-10 07:27:19.025474+00	2025-12-10 07:28:36.888536+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["ecf81549-0b7d-4ad5-ba39-c54a00a19b1a"]}	2025-12-10 07:28:36.889158+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
bfc2d1ed-5ea6-4dd9-ab32-6d1237848056	40846f9a-fe66-4922-b89e-115493c8633e	06057b2e-9b19-4bbb-9c86-a1288af0509d	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96"}	Self Report	2025-12-10 07:27:19.033886+00	2025-12-10 07:27:19.033886+00	{}
91b134b2-a4c3-4597-bf18-ba3a2b0fd1b1	40846f9a-fe66-4922-b89e-115493c8633e	06057b2e-9b19-4bbb-9c86-a1288af0509d	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 07:27:19.04083+00	2025-12-10 07:27:19.04083+00	{}
bfbdcccf-90fa-4db7-af61-a10fa09580bf	40846f9a-fe66-4922-b89e-115493c8633e	06057b2e-9b19-4bbb-9c86-a1288af0509d	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "session_id": "1f51e395-e613-4c64-b45b-17db527e3856", "started_at": "2025-12-10T07:27:19.040459947Z", "finished_at": "2025-12-10T07:27:19.152791736Z", "discovery_type": {"type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96"}}}	{"type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96"}	Self Report	2025-12-10 07:27:19.040459+00	2025-12-10 07:27:19.157053+00	{}
06cfd03f-edb7-4c48-a519-023526b54dd2	40846f9a-fe66-4922-b89e-115493c8633e	06057b2e-9b19-4bbb-9c86-a1288af0509d	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "session_id": "9b1a2c57-5689-47dc-9d3a-bd61d4effda2", "started_at": "2025-12-10T07:27:19.170763342Z", "finished_at": "2025-12-10T07:28:55.151968069Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 07:27:19.170763+00	2025-12-10 07:28:55.154995+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
0bffebcd-16b1-4fe0-8e95-0c81272c202a	40846f9a-fe66-4922-b89e-115493c8633e		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-10 07:28:55.166314+00	2025-12-10 07:28:55.166314+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
d6eba617-e1d2-4bc5-8c9f-398845abc9be	40846f9a-fe66-4922-b89e-115493c8633e	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "61054003-a7c1-4b8c-abcd-5fa8f023f11f"}	[{"id": "30a55814-0eed-4130-b044-20e0c570d80d", "name": "Internet", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "ip_address": "1.1.1.1", "mac_address": null}]	{1f582214-833b-4129-a548-1fc44f8e562a}	[{"id": "c75a3e3f-2abb-418e-bb45-214173a576a1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-10 07:27:18.897649+00	2025-12-10 07:27:18.906982+00	f	{}
9a8acd9b-6281-412a-95c8-c8eb0e45a3bf	40846f9a-fe66-4922-b89e-115493c8633e	Google.com	\N	\N	{"type": "ServiceBinding", "config": "c6382f4e-81c5-4d46-b54c-24cc91b2b409"}	[{"id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884", "name": "Internet", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "ip_address": "203.0.113.195", "mac_address": null}]	{4540d984-3e11-4a74-a3c4-cbf0ef8e34b7}	[{"id": "03502289-44a9-46db-881b-eafbf8a856e3", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 07:27:18.897655+00	2025-12-10 07:27:18.912143+00	f	{}
73d2c20c-73c9-42ca-b9bf-826a9ec846c6	40846f9a-fe66-4922-b89e-115493c8633e	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "3b00305a-832b-4295-952b-53848c51bc42"}	[{"id": "83b5b799-47e3-4854-8496-b8c00e2db591", "name": "Remote Network", "subnet_id": "f50e2b61-458c-45c6-8964-478a3914dba3", "ip_address": "203.0.113.208", "mac_address": null}]	{7b993025-a94f-4843-8153-4ec3422e2b3e}	[{"id": "72dc2a17-84eb-4292-ae1d-9f03d0b5fd11", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 07:27:18.89766+00	2025-12-10 07:27:18.916064+00	f	{}
9e455635-61f1-49db-8f22-0f9fd96b3416	40846f9a-fe66-4922-b89e-115493c8633e	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "38893f00-ef8c-4cf8-8296-b44ea3d053d0", "name": null, "subnet_id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "ip_address": "172.25.0.3", "mac_address": "DA:6C:BA:15:18:0B"}]	{828002cd-7811-4060-9ea1-b60563e63228}	[{"id": "e595a346-7cc8-4959-837d-5fd596e958fc", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:28:06.473419396Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 07:28:06.473422+00	2025-12-10 07:28:21.49054+00	f	{}
c42206f4-652f-4302-befa-55ac6db5fa96	40846f9a-fe66-4922-b89e-115493c8633e	netvisor-daemon	73961b4ae7a7	NetVisor daemon	{"type": "None"}	[{"id": "fa08ba62-bfb8-43ed-8ae1-fb15ab9dd9ba", "name": "eth0", "subnet_id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "ip_address": "172.25.0.4", "mac_address": "72:94:FF:DF:F1:64"}]	{53c1918c-d51b-45af-bacf-74f099f27140}	[{"id": "8e0a25be-4632-4cd5-bb59-5861353abb24", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:27:19.134672299Z", "type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d"}]}	null	2025-12-10 07:27:18.975098+00	2025-12-10 07:27:19.150473+00	f	{}
340ff763-21d7-45e2-949e-4213031b72eb	40846f9a-fe66-4922-b89e-115493c8633e	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "07b3c44a-385b-4aad-837a-30a482a9f641", "name": null, "subnet_id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "ip_address": "172.25.0.5", "mac_address": "96:F9:DD:8D:6A:0B"}]	{eebf0406-da71-438c-b29a-67c83aabd828,695810dc-2349-4adb-83f4-784053b87b1b}	[{"id": "16c2f381-79ab-4b86-b9aa-2203b43b8709", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "0b1ce39a-f3da-41af-8f50-8058aadf8f4c", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:27:51.552029543Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 07:27:51.552033+00	2025-12-10 07:28:06.394118+00	f	{}
6717bd41-5062-4053-b620-a3189ee96950	40846f9a-fe66-4922-b89e-115493c8633e	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "0d002bf5-0dc5-4dec-825b-80e2d69cdea7", "name": null, "subnet_id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "ip_address": "172.25.0.6", "mac_address": "F2:9D:42:55:81:2E"}]	{9619922a-c28f-4c0b-86a5-b294863a1419}	[{"id": "140a1c13-8817-4951-ac13-0e37dc6a6980", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:28:21.481597485Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 07:28:21.4816+00	2025-12-10 07:28:36.200324+00	f	{}
6712f02b-dc9b-49f3-bb6a-c1e00f26ceb5	40846f9a-fe66-4922-b89e-115493c8633e	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "d750692d-445f-4706-872e-0c710b48ac32", "name": null, "subnet_id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "ip_address": "172.25.0.1", "mac_address": "0A:FE:45:BA:2E:4A"}]	{09359e66-6ff8-4f02-be13-df302f4299b5,cb8ad773-5f65-46e4-b721-71e483b77e81,73144175-1298-496a-9f00-54d6565e4cb8,aba31e57-7cd7-4845-8571-2516b56ed9ab}	[{"id": "b8090a17-d5ea-4a06-9782-1d264790ccb1", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "21561661-474d-4492-909c-4d8a164ef1b9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "3e04a1dd-8cf0-4ac6-b78b-9a052681c996", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "4592efb8-977c-4c4d-a7cb-1e472d04690b", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:28:40.249293222Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 07:28:40.249296+00	2025-12-10 07:28:55.144782+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
40846f9a-fe66-4922-b89e-115493c8633e	My Network	2025-12-10 07:27:18.896322+00	2025-12-10 07:27:18.896322+00	f	1d894c08-e310-43ae-951c-3b775fe0bb7d	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
1d894c08-e310-43ae-951c-3b775fe0bb7d	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-10 07:27:15.944059+00	2025-12-10 07:27:19.032066+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
1f582214-833b-4129-a548-1fc44f8e562a	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:18.897651+00	2025-12-10 07:27:18.897651+00	Cloudflare DNS	d6eba617-e1d2-4bc5-8c9f-398845abc9be	[{"id": "61054003-a7c1-4b8c-abcd-5fa8f023f11f", "type": "Port", "port_id": "c75a3e3f-2abb-418e-bb45-214173a576a1", "interface_id": "30a55814-0eed-4130-b044-20e0c570d80d"}]	"Dns Server"	null	{"type": "System"}	{}
4540d984-3e11-4a74-a3c4-cbf0ef8e34b7	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:18.897656+00	2025-12-10 07:27:18.897656+00	Google.com	9a8acd9b-6281-412a-95c8-c8eb0e45a3bf	[{"id": "c6382f4e-81c5-4d46-b54c-24cc91b2b409", "type": "Port", "port_id": "03502289-44a9-46db-881b-eafbf8a856e3", "interface_id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884"}]	"Web Service"	null	{"type": "System"}	{}
7b993025-a94f-4843-8153-4ec3422e2b3e	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:18.897661+00	2025-12-10 07:27:18.897661+00	Mobile Device	73d2c20c-73c9-42ca-b9bf-826a9ec846c6	[{"id": "3b00305a-832b-4295-952b-53848c51bc42", "type": "Port", "port_id": "72dc2a17-84eb-4292-ae1d-9f03d0b5fd11", "interface_id": "83b5b799-47e3-4854-8496-b8c00e2db591"}]	"Client"	null	{"type": "System"}	{}
53c1918c-d51b-45af-bacf-74f099f27140	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:19.134691+00	2025-12-10 07:27:19.134691+00	NetVisor Daemon API	c42206f4-652f-4302-befa-55ac6db5fa96	[{"id": "a022b82e-cace-4a1f-a005-0835539d6c92", "type": "Port", "port_id": "8e0a25be-4632-4cd5-bb59-5861353abb24", "interface_id": "fa08ba62-bfb8-43ed-8ae1-fb15ab9dd9ba"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-10T07:27:19.134690633Z", "type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d"}]}	{}
695810dc-2349-4adb-83f4-784053b87b1b	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:06.376484+00	2025-12-10 07:28:06.376484+00	Unclaimed Open Ports	340ff763-21d7-45e2-949e-4213031b72eb	[{"id": "e140931b-48c3-4f12-a313-31a4730b8452", "type": "Port", "port_id": "0b1ce39a-f3da-41af-8f50-8058aadf8f4c", "interface_id": "07b3c44a-385b-4aad-837a-30a482a9f641"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T07:28:06.376467700Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
eebf0406-da71-438c-b29a-67c83aabd828	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:05.642994+00	2025-12-10 07:28:05.642994+00	Home Assistant	340ff763-21d7-45e2-949e-4213031b72eb	[{"id": "a695e56c-24ff-4be6-944a-35d82c5692ae", "type": "Port", "port_id": "16c2f381-79ab-4b86-b9aa-2203b43b8709", "interface_id": "07b3c44a-385b-4aad-837a-30a482a9f641"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T07:28:05.642976702Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
828002cd-7811-4060-9ea1-b60563e63228	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:09.502076+00	2025-12-10 07:28:09.502076+00	NetVisor Server API	9e455635-61f1-49db-8f22-0f9fd96b3416	[{"id": "6571c0a7-6aec-46dd-8a08-a041c815d213", "type": "Port", "port_id": "e595a346-7cc8-4959-837d-5fd596e958fc", "interface_id": "38893f00-ef8c-4cf8-8296-b44ea3d053d0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T07:28:09.502057490Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9619922a-c28f-4c0b-86a5-b294863a1419	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:36.190326+00	2025-12-10 07:28:36.190326+00	PostgreSQL	6717bd41-5062-4053-b620-a3189ee96950	[{"id": "84f3949f-78fd-4be8-9183-dcd0ba40ff79", "type": "Port", "port_id": "140a1c13-8817-4951-ac13-0e37dc6a6980", "interface_id": "0d002bf5-0dc5-4dec-825b-80e2d69cdea7"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T07:28:36.190307552Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
09359e66-6ff8-4f02-be13-df302f4299b5	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:43.25822+00	2025-12-10 07:28:43.25822+00	NetVisor Server API	6712f02b-dc9b-49f3-bb6a-c1e00f26ceb5	[{"id": "1419f897-80d9-4384-a58f-882c511fdb40", "type": "Port", "port_id": "b8090a17-d5ea-4a06-9782-1d264790ccb1", "interface_id": "d750692d-445f-4706-872e-0c710b48ac32"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T07:28:43.258202321Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
cb8ad773-5f65-46e4-b721-71e483b77e81	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:54.402671+00	2025-12-10 07:28:54.402671+00	Home Assistant	6712f02b-dc9b-49f3-bb6a-c1e00f26ceb5	[{"id": "c3f4817a-222b-4cca-a9ee-e23589fd8583", "type": "Port", "port_id": "21561661-474d-4492-909c-4d8a164ef1b9", "interface_id": "d750692d-445f-4706-872e-0c710b48ac32"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T07:28:54.402656723Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
73144175-1298-496a-9f00-54d6565e4cb8	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:55.129868+00	2025-12-10 07:28:55.129868+00	SSH	6712f02b-dc9b-49f3-bb6a-c1e00f26ceb5	[{"id": "220c9dcd-3afb-4cc8-b2f0-09f8435ce11e", "type": "Port", "port_id": "3e04a1dd-8cf0-4ac6-b78b-9a052681c996", "interface_id": "d750692d-445f-4706-872e-0c710b48ac32"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T07:28:55.129853685Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
aba31e57-7cd7-4845-8571-2516b56ed9ab	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:28:55.130111+00	2025-12-10 07:28:55.130111+00	Unclaimed Open Ports	6712f02b-dc9b-49f3-bb6a-c1e00f26ceb5	[{"id": "071b7903-b689-44c1-8dc1-3e685ceb1d48", "type": "Port", "port_id": "4592efb8-977c-4c4d-a7cb-1e472d04690b", "interface_id": "d750692d-445f-4706-872e-0c710b48ac32"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T07:28:55.130102509Z", "type": "Network", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
98a16647-31fa-4468-92c6-2e7439751720	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:18.897599+00	2025-12-10 07:27:18.897599+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
f50e2b61-458c-45c6-8964-478a3914dba3	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:18.897602+00	2025-12-10 07:27:18.897602+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
ecf81549-0b7d-4ad5-ba39-c54a00a19b1a	40846f9a-fe66-4922-b89e-115493c8633e	2025-12-10 07:27:19.040622+00	2025-12-10 07:27:19.040622+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-10T07:27:19.040620887Z", "type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
6fb369cb-f21c-43dc-a6ef-4f5e79bc8e9c	1d894c08-e310-43ae-951c-3b775fe0bb7d	New Tag	\N	2025-12-10 07:28:55.173258+00	2025-12-10 07:28:55.173258+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
e4d99fdc-dd83-44f7-933f-8bee80987e3d	40846f9a-fe66-4922-b89e-115493c8633e	My Topology	[]	[{"id": "98a16647-31fa-4468-92c6-2e7439751720", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "f50e2b61-458c-45c6-8964-478a3914dba3", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "30a55814-0eed-4130-b044-20e0c570d80d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "d6eba617-e1d2-4bc5-8c9f-398845abc9be", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "interface_id": "30a55814-0eed-4130-b044-20e0c570d80d"}, {"id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884", "size": {"x": 250, "y": 100}, "header": null, "host_id": "9a8acd9b-6281-412a-95c8-c8eb0e45a3bf", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "interface_id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884"}, {"id": "83b5b799-47e3-4854-8496-b8c00e2db591", "size": {"x": 250, "y": 100}, "header": null, "host_id": "73d2c20c-73c9-42ca-b9bf-826a9ec846c6", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f50e2b61-458c-45c6-8964-478a3914dba3", "interface_id": "83b5b799-47e3-4854-8496-b8c00e2db591"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "d6eba617-e1d2-4bc5-8c9f-398845abc9be", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "c75a3e3f-2abb-418e-bb45-214173a576a1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "61054003-a7c1-4b8c-abcd-5fa8f023f11f"}, "hostname": null, "services": ["1f582214-833b-4129-a548-1fc44f8e562a"], "created_at": "2025-12-10T07:27:18.897649Z", "interfaces": [{"id": "30a55814-0eed-4130-b044-20e0c570d80d", "name": "Internet", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.906982Z", "description": null, "virtualization": null}, {"id": "9a8acd9b-6281-412a-95c8-c8eb0e45a3bf", "name": "Google.com", "tags": [], "ports": [{"id": "03502289-44a9-46db-881b-eafbf8a856e3", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c6382f4e-81c5-4d46-b54c-24cc91b2b409"}, "hostname": null, "services": ["4540d984-3e11-4a74-a3c4-cbf0ef8e34b7"], "created_at": "2025-12-10T07:27:18.897655Z", "interfaces": [{"id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884", "name": "Internet", "subnet_id": "98a16647-31fa-4468-92c6-2e7439751720", "ip_address": "203.0.113.195", "mac_address": null}], "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.912143Z", "description": null, "virtualization": null}, {"id": "73d2c20c-73c9-42ca-b9bf-826a9ec846c6", "name": "Mobile Device", "tags": [], "ports": [{"id": "72dc2a17-84eb-4292-ae1d-9f03d0b5fd11", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3b00305a-832b-4295-952b-53848c51bc42"}, "hostname": null, "services": ["7b993025-a94f-4843-8153-4ec3422e2b3e"], "created_at": "2025-12-10T07:27:18.897660Z", "interfaces": [{"id": "83b5b799-47e3-4854-8496-b8c00e2db591", "name": "Remote Network", "subnet_id": "f50e2b61-458c-45c6-8964-478a3914dba3", "ip_address": "203.0.113.208", "mac_address": null}], "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.916064Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "98a16647-31fa-4468-92c6-2e7439751720", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-10T07:27:18.897599Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.897599Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "f50e2b61-458c-45c6-8964-478a3914dba3", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-10T07:27:18.897602Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.897602Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "ecf81549-0b7d-4ad5-ba39-c54a00a19b1a", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-10T07:27:19.040620887Z", "type": "SelfReport", "host_id": "c42206f4-652f-4302-befa-55ac6db5fa96", "daemon_id": "06057b2e-9b19-4bbb-9c86-a1288af0509d"}]}, "created_at": "2025-12-10T07:27:19.040622Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:19.040622Z", "description": null, "subnet_type": "Lan"}]	[{"id": "1f582214-833b-4129-a548-1fc44f8e562a", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "d6eba617-e1d2-4bc5-8c9f-398845abc9be", "bindings": [{"id": "61054003-a7c1-4b8c-abcd-5fa8f023f11f", "type": "Port", "port_id": "c75a3e3f-2abb-418e-bb45-214173a576a1", "interface_id": "30a55814-0eed-4130-b044-20e0c570d80d"}], "created_at": "2025-12-10T07:27:18.897651Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.897651Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "4540d984-3e11-4a74-a3c4-cbf0ef8e34b7", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "9a8acd9b-6281-412a-95c8-c8eb0e45a3bf", "bindings": [{"id": "c6382f4e-81c5-4d46-b54c-24cc91b2b409", "type": "Port", "port_id": "03502289-44a9-46db-881b-eafbf8a856e3", "interface_id": "4f5ee499-215f-47e2-8eb3-d3f88b80d884"}], "created_at": "2025-12-10T07:27:18.897656Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.897656Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "7b993025-a94f-4843-8153-4ec3422e2b3e", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "73d2c20c-73c9-42ca-b9bf-826a9ec846c6", "bindings": [{"id": "3b00305a-832b-4295-952b-53848c51bc42", "type": "Port", "port_id": "72dc2a17-84eb-4292-ae1d-9f03d0b5fd11", "interface_id": "83b5b799-47e3-4854-8496-b8c00e2db591"}], "created_at": "2025-12-10T07:27:18.897661Z", "network_id": "40846f9a-fe66-4922-b89e-115493c8633e", "updated_at": "2025-12-10T07:27:18.897661Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-10 07:27:18.920524+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-10 07:27:18.916808+00	2025-12-10 07:28:36.352235+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags) FROM stdin;
f2670baf-6072-4a4a-b41d-efb722942b00	2025-12-10 07:27:15.945931+00	2025-12-10 07:27:18.878046+00	$argon2id$v=19$m=19456,t=2,p=1$S85/gqE731tJMkpeSQrI0A$OESI2TKcShNddBvvetrzHWpv5E+V4Lof9LayLmQkN/c	\N	\N	\N	user@gmail.com	1d894c08-e310-43ae-951c-3b775fe0bb7d	Owner	{}	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
PB_QtxN8POQyPFkbIujylQ	\\x93c41095f2e8221b593c32e43c7c13b7d01f3c81a7757365725f6964d92466323637306261662d363037322d346134612d623431642d65666237323239343262303099cd07ea09071b12ce34819a73000000	2026-01-09 07:27:18.880908+00
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
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


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
-- Name: idx_tags_org_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tags_org_name ON public.tags USING btree (organization_id, name);


--
-- Name: idx_tags_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_tags_organization ON public.tags USING btree (organization_id);


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
-- Name: tags tags_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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

\unrestrict y1GJXLS7vTkQfpscfUSdR6J3aQGEFxSjRbxLPKjla9ta2nsdVQjCMnmPzeKWNXm

