--
-- PostgreSQL database dump
--

\restrict SVpBMco9NtEXrLCa5RmdIInonlARKHAfhaYytmxN26sMUjTxvbXCNdKmZK1qXgC

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
DROP EXTENSION IF EXISTS pgcrypto;
DROP SCHEMA IF EXISTS tower_sessions;
--
-- Name: tower_sessions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tower_sessions;


ALTER SCHEMA tower_sessions OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL,
    terms_accepted_at timestamp with time zone
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
20251006215000	users	2025-12-13 14:47:08.791349+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3493131
20251006215100	networks	2025-12-13 14:47:08.795718+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3943062
20251006215151	create hosts	2025-12-13 14:47:08.800035+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4048478
20251006215155	create subnets	2025-12-13 14:47:08.804403+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3646167
20251006215201	create groups	2025-12-13 14:47:08.808367+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3708613
20251006215204	create daemons	2025-12-13 14:47:08.812394+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4415763
20251006215212	create services	2025-12-13 14:47:08.817232+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4774283
20251029193448	user-auth	2025-12-13 14:47:08.822442+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3487861
20251030044828	daemon api	2025-12-13 14:47:08.826236+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1474032
20251030170438	host-hide	2025-12-13 14:47:08.827993+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1044297
20251102224919	create discovery	2025-12-13 14:47:08.829653+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10720744
20251106235621	normalize-daemon-cols	2025-12-13 14:47:08.840716+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1717586
20251107034459	api keys	2025-12-13 14:47:08.842702+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7506333
20251107222650	oidc-auth	2025-12-13 14:47:08.850512+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20213847
20251110181948	orgs-billing	2025-12-13 14:47:08.871048+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10025096
20251113223656	group-enhancements	2025-12-13 14:47:08.881529+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	977304
20251117032720	daemon-mode	2025-12-13 14:47:08.882774+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1038919
20251118143058	set-default-plan	2025-12-13 14:47:08.884138+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1161318
20251118225043	save-topology	2025-12-13 14:47:08.886174+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8571111
20251123232748	network-permissions	2025-12-13 14:47:08.895074+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2598661
20251125001342	billing-updates	2025-12-13 14:47:08.897984+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1025524
20251128035448	org-onboarding-status	2025-12-13 14:47:08.899267+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1392973
20251129180942	nfs-consolidate	2025-12-13 14:47:08.900968+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1325955
20251206052641	discovery-progress	2025-12-13 14:47:08.902612+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1425732
20251206202200	plan-fix	2025-12-13 14:47:08.904546+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	926299
20251207061341	daemon-url	2025-12-13 14:47:08.905736+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2044357
20251210045929	tags	2025-12-13 14:47:08.908064+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9371997
20251210175035	terms	2025-12-13 14:47:08.917795+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	1159415
20251213025048	hash-keys	2025-12-13 14:47:08.919429+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	7293382
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
d13b8b24-afaa-4802-a270-e0da0c1884ad	f14dfcd3632761174592e18e5f88318c474fa59e2110444443383353a02439b4	74a17d30-f3d1-42d1-8e79-c94f081109b8	Integrated Daemon API Key	2025-12-13 14:47:12.377125+00	2025-12-13 14:48:46.802984+00	2025-12-13 14:48:46.801932+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
ac487ead-951c-4413-b6e9-4926298b24e9	74a17d30-f3d1-42d1-8e79-c94f081109b8	52a1af3f-d7a0-4aa5-bb1f-382e0366a861	2025-12-13 14:47:12.425906+00	2025-12-13 14:48:27.282514+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["c34128fe-2920-41e7-a1cf-abb941a04675"]}	2025-12-13 14:48:27.282966+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
d7f26213-071d-41e6-ab10-edc1cc046f09	74a17d30-f3d1-42d1-8e79-c94f081109b8	ac487ead-951c-4413-b6e9-4926298b24e9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861"}	Self Report	2025-12-13 14:47:12.432156+00	2025-12-13 14:47:12.432156+00	{}
f1a61b97-e118-4ae4-a1a9-d56ff63ebdd5	74a17d30-f3d1-42d1-8e79-c94f081109b8	ac487ead-951c-4413-b6e9-4926298b24e9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 14:47:12.438382+00	2025-12-13 14:47:12.438382+00	{}
7ee5dd23-6fc6-40ac-850d-7970d78d5724	74a17d30-f3d1-42d1-8e79-c94f081109b8	ac487ead-951c-4413-b6e9-4926298b24e9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "session_id": "d433b1ce-6743-4d38-a014-65a1c41944cc", "started_at": "2025-12-13T14:47:12.437890831Z", "finished_at": "2025-12-13T14:47:12.543707808Z", "discovery_type": {"type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861"}}}	{"type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861"}	Self Report	2025-12-13 14:47:12.43789+00	2025-12-13 14:47:12.546479+00	{}
8d7a7d41-a285-4242-8bd8-edd910a584c1	74a17d30-f3d1-42d1-8e79-c94f081109b8	ac487ead-951c-4413-b6e9-4926298b24e9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "session_id": "f598afb0-0cc0-4c94-bddc-87e97234d166", "started_at": "2025-12-13T14:47:12.561013986Z", "finished_at": "2025-12-13T14:48:46.799606740Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 14:47:12.561013+00	2025-12-13 14:48:46.802202+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
75bab5f2-7060-4207-bbc1-4f6f1fb3c6ee	74a17d30-f3d1-42d1-8e79-c94f081109b8		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 14:48:46.813647+00	2025-12-13 14:48:46.813647+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
cf43e176-a9f4-4a57-93cf-ef9d5f64353c	74a17d30-f3d1-42d1-8e79-c94f081109b8	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "0db94ed9-a560-484b-b9af-600f6e15a5ce"}	[{"id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634", "name": "Internet", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "ip_address": "1.1.1.1", "mac_address": null}]	{aadc272d-1e8a-45ab-8dcc-7a9d6df14cae}	[{"id": "ca233eb2-4699-491e-ba68-704dc5140db1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 14:47:12.349681+00	2025-12-13 14:47:12.359599+00	f	{}
477da266-0dee-4cb0-bdbd-ddef618f7e8f	74a17d30-f3d1-42d1-8e79-c94f081109b8	Google.com	\N	\N	{"type": "ServiceBinding", "config": "c0b84706-3f24-43d3-86a9-a3188fb09988"}	[{"id": "d43625a4-5510-4ad6-bf1a-31c231ac781b", "name": "Internet", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "ip_address": "203.0.113.35", "mac_address": null}]	{e16f8f2a-a37e-4906-bdc2-1b354b4fa6aa}	[{"id": "83684ee9-70fb-49ee-88fa-3043f2c83557", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 14:47:12.349691+00	2025-12-13 14:47:12.364834+00	f	{}
8c947d32-8ad2-4aaf-af2c-5d4498d98b22	74a17d30-f3d1-42d1-8e79-c94f081109b8	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "4de258fa-c82a-4adf-8ef5-290b9ffc87e1"}	[{"id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6", "name": "Remote Network", "subnet_id": "8477c252-9c12-4d62-a96e-13f9cc428b4e", "ip_address": "203.0.113.41", "mac_address": null}]	{a93539f2-7b4d-479c-8126-da0954ed0044}	[{"id": "2488ce43-68d1-4e30-98d7-6c7e2235e2ed", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 14:47:12.349696+00	2025-12-13 14:47:12.369023+00	f	{}
7bd56578-c8b8-40e8-a05d-195ff38ce2fa	74a17d30-f3d1-42d1-8e79-c94f081109b8	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "3557f2fc-4dde-4121-bd75-53db6bde59de", "name": null, "subnet_id": "c34128fe-2920-41e7-a1cf-abb941a04675", "ip_address": "172.25.0.6", "mac_address": "DA:D1:6F:66:BA:45"}]	{182ab02a-18e9-44c4-b1df-a9c6cd9efbc5}	[{"id": "8c81d67b-dc01-4905-82d3-d888676b18da", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:47:57.441977026Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 14:47:57.44198+00	2025-12-13 14:48:11.818646+00	f	{}
52a1af3f-d7a0-4aa5-bb1f-382e0366a861	74a17d30-f3d1-42d1-8e79-c94f081109b8	netvisor-daemon	e1df8a047867	NetVisor daemon	{"type": "None"}	[{"id": "ea98ef29-669f-4f40-b50b-5dd1e726d2e2", "name": "eth0", "subnet_id": "c34128fe-2920-41e7-a1cf-abb941a04675", "ip_address": "172.25.0.4", "mac_address": "7A:E6:7A:AA:AC:F0"}]	{55de4c3c-0fd3-41e7-ae08-06125d24ec31}	[{"id": "d49bc43c-f3da-47f7-92a6-6a70b2e6b6df", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:47:12.528602075Z", "type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9"}]}	null	2025-12-13 14:47:12.422029+00	2025-12-13 14:47:12.540519+00	f	{}
06942d2c-80ba-4051-ad00-2b88073ac793	74a17d30-f3d1-42d1-8e79-c94f081109b8	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ad602bc9-894d-4185-ba0f-95434ca52317", "name": null, "subnet_id": "c34128fe-2920-41e7-a1cf-abb941a04675", "ip_address": "172.25.0.3", "mac_address": "3A:F1:D1:E1:91:8F"}]	{b27b2aaf-33be-4c55-97be-ca24be017a90}	[{"id": "822f6f2b-3641-4cfa-99fb-daaca2cd8cad", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:47:42.616586906Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 14:47:42.616589+00	2025-12-13 14:47:57.355719+00	f	{}
ff621472-47b1-40dc-be2b-a77d3bfd87d8	74a17d30-f3d1-42d1-8e79-c94f081109b8	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "d153590a-1f74-4a11-8a5f-e56cdcc7318e", "name": null, "subnet_id": "c34128fe-2920-41e7-a1cf-abb941a04675", "ip_address": "172.25.0.5", "mac_address": "AE:33:E1:A3:DF:B9"}]	{a3580719-37d9-4a55-ae0e-fd0eae518aca}	[{"id": "7532df50-c438-487e-b0f0-85140d962f46", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "99f99e97-7bc7-4c24-91f9-929845e906b7", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:48:11.812383768Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 14:48:11.812385+00	2025-12-13 14:48:25.924974+00	f	{}
e9a6bb52-3ce1-4851-b5bc-b3ac210b4222	74a17d30-f3d1-42d1-8e79-c94f081109b8	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "a3ecb441-5c9d-4e26-bf23-3ab52d355d10", "name": null, "subnet_id": "c34128fe-2920-41e7-a1cf-abb941a04675", "ip_address": "172.25.0.1", "mac_address": "66:9F:A5:A5:D5:38"}]	{55c2c3c6-8220-40f9-b032-a4fc90b5772b,d95a775d-92ac-45c0-b966-8c82e613a2b8,ba6f6b4c-914d-4630-a1d9-9dbb0a62a95c,999c4180-a901-47f0-81db-35af8cdda657}	[{"id": "8dd3304e-13dc-4bd4-bdc5-bdd61952f04d", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "abdb3f21-4a45-4346-ad7c-c63e18e7746d", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "862e593e-328c-478b-b5d5-e5e6ba623e5f", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "204b2283-9202-4f4d-bc48-6a19404d9017", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:48:31.988546985Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 14:48:31.988549+00	2025-12-13 14:48:46.794169+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
74a17d30-f3d1-42d1-8e79-c94f081109b8	My Network	2025-12-13 14:47:12.348413+00	2025-12-13 14:47:12.348413+00	f	ae0d6265-563a-4a08-9480-7a0cf4240656	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
ae0d6265-563a-4a08-9480-7a0cf4240656	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 14:47:12.326532+00	2025-12-13 14:47:12.430568+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
aadc272d-1e8a-45ab-8dcc-7a9d6df14cae	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.349684+00	2025-12-13 14:47:12.349684+00	Cloudflare DNS	cf43e176-a9f4-4a57-93cf-ef9d5f64353c	[{"id": "0db94ed9-a560-484b-b9af-600f6e15a5ce", "type": "Port", "port_id": "ca233eb2-4699-491e-ba68-704dc5140db1", "interface_id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634"}]	"Dns Server"	null	{"type": "System"}	{}
e16f8f2a-a37e-4906-bdc2-1b354b4fa6aa	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.349692+00	2025-12-13 14:47:12.349692+00	Google.com	477da266-0dee-4cb0-bdbd-ddef618f7e8f	[{"id": "c0b84706-3f24-43d3-86a9-a3188fb09988", "type": "Port", "port_id": "83684ee9-70fb-49ee-88fa-3043f2c83557", "interface_id": "d43625a4-5510-4ad6-bf1a-31c231ac781b"}]	"Web Service"	null	{"type": "System"}	{}
a93539f2-7b4d-479c-8126-da0954ed0044	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.349697+00	2025-12-13 14:47:12.349697+00	Mobile Device	8c947d32-8ad2-4aaf-af2c-5d4498d98b22	[{"id": "4de258fa-c82a-4adf-8ef5-290b9ffc87e1", "type": "Port", "port_id": "2488ce43-68d1-4e30-98d7-6c7e2235e2ed", "interface_id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6"}]	"Client"	null	{"type": "System"}	{}
55de4c3c-0fd3-41e7-ae08-06125d24ec31	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.52862+00	2025-12-13 14:47:12.52862+00	NetVisor Daemon API	52a1af3f-d7a0-4aa5-bb1f-382e0366a861	[{"id": "6a5d7e88-ebdc-4011-b179-b579587ac362", "type": "Port", "port_id": "d49bc43c-f3da-47f7-92a6-6a70b2e6b6df", "interface_id": "ea98ef29-669f-4f40-b50b-5dd1e726d2e2"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T14:47:12.528619177Z", "type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9"}]}	{}
b27b2aaf-33be-4c55-97be-ca24be017a90	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:55.11459+00	2025-12-13 14:47:55.11459+00	NetVisor Server API	06942d2c-80ba-4051-ad00-2b88073ac793	[{"id": "40636fc3-d8a5-4ce1-8753-c97506fbd562", "type": "Port", "port_id": "822f6f2b-3641-4cfa-99fb-daaca2cd8cad", "interface_id": "ad602bc9-894d-4185-ba0f-95434ca52317"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T14:47:55.114571104Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
182ab02a-18e9-44c4-b1df-a9c6cd9efbc5	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:11.805317+00	2025-12-13 14:48:11.805317+00	PostgreSQL	7bd56578-c8b8-40e8-a05d-195ff38ce2fa	[{"id": "e4f63762-0764-4f54-ac72-63ebd5db8785", "type": "Port", "port_id": "8c81d67b-dc01-4905-82d3-d888676b18da", "interface_id": "3557f2fc-4dde-4121-bd75-53db6bde59de"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T14:48:11.805298046Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a3580719-37d9-4a55-ae0e-fd0eae518aca	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:25.915814+00	2025-12-13 14:48:25.915814+00	Unclaimed Open Ports	ff621472-47b1-40dc-be2b-a77d3bfd87d8	[{"id": "f2451cec-eb55-4623-870e-3b6697c1a25b", "type": "Port", "port_id": "7532df50-c438-487e-b0f0-85140d962f46", "interface_id": "d153590a-1f74-4a11-8a5f-e56cdcc7318e"}, {"id": "e55b61b9-2893-454b-be14-e7cd8535f6c7", "type": "Port", "port_id": "99f99e97-7bc7-4c24-91f9-929845e906b7", "interface_id": "d153590a-1f74-4a11-8a5f-e56cdcc7318e"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T14:48:25.915794621Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
55c2c3c6-8220-40f9-b032-a4fc90b5772b	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:41.654359+00	2025-12-13 14:48:41.654359+00	Home Assistant	e9a6bb52-3ce1-4851-b5bc-b3ac210b4222	[{"id": "2dd193a7-f76c-4c2a-90bf-330fb2951e76", "type": "Port", "port_id": "8dd3304e-13dc-4bd4-bdc5-bdd61952f04d", "interface_id": "a3ecb441-5c9d-4e26-bf23-3ab52d355d10"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T14:48:41.654340344Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d95a775d-92ac-45c0-b966-8c82e613a2b8	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:44.579122+00	2025-12-13 14:48:44.579122+00	NetVisor Server API	e9a6bb52-3ce1-4851-b5bc-b3ac210b4222	[{"id": "d298bdd5-7049-4bb6-bd4f-d5aca226e20c", "type": "Port", "port_id": "abdb3f21-4a45-4346-ad7c-c63e18e7746d", "interface_id": "a3ecb441-5c9d-4e26-bf23-3ab52d355d10"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T14:48:44.579102581Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ba6f6b4c-914d-4630-a1d9-9dbb0a62a95c	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:46.777525+00	2025-12-13 14:48:46.777525+00	SSH	e9a6bb52-3ce1-4851-b5bc-b3ac210b4222	[{"id": "09385c4c-f8a5-4e69-b042-cac1d642638d", "type": "Port", "port_id": "862e593e-328c-478b-b5d5-e5e6ba623e5f", "interface_id": "a3ecb441-5c9d-4e26-bf23-3ab52d355d10"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T14:48:46.777507763Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
999c4180-a901-47f0-81db-35af8cdda657	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:48:46.777686+00	2025-12-13 14:48:46.777686+00	Unclaimed Open Ports	e9a6bb52-3ce1-4851-b5bc-b3ac210b4222	[{"id": "93c4278f-d249-4acf-8a7b-461a5e3e8da0", "type": "Port", "port_id": "204b2283-9202-4f4d-bc48-6a19404d9017", "interface_id": "a3ecb441-5c9d-4e26-bf23-3ab52d355d10"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T14:48:46.777678010Z", "type": "Network", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
9b9abe30-c67e-45bc-a303-fb9a19e4b656	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.349628+00	2025-12-13 14:47:12.349628+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
8477c252-9c12-4d62-a96e-13f9cc428b4e	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.349631+00	2025-12-13 14:47:12.349631+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
c34128fe-2920-41e7-a1cf-abb941a04675	74a17d30-f3d1-42d1-8e79-c94f081109b8	2025-12-13 14:47:12.438066+00	2025-12-13 14:47:12.438066+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T14:47:12.438064886Z", "type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
ab412a91-5a6b-4115-8ce2-3fa358bba0fd	ae0d6265-563a-4a08-9480-7a0cf4240656	New Tag	\N	2025-12-13 14:48:46.821625+00	2025-12-13 14:48:46.821625+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
9979a231-f652-480f-9ddd-c59546ac6e1a	74a17d30-f3d1-42d1-8e79-c94f081109b8	My Topology	[]	[{"id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "8477c252-9c12-4d62-a96e-13f9cc428b4e", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634", "size": {"x": 250, "y": 100}, "header": null, "host_id": "cf43e176-a9f4-4a57-93cf-ef9d5f64353c", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "interface_id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634"}, {"id": "d43625a4-5510-4ad6-bf1a-31c231ac781b", "size": {"x": 250, "y": 100}, "header": null, "host_id": "477da266-0dee-4cb0-bdbd-ddef618f7e8f", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "interface_id": "d43625a4-5510-4ad6-bf1a-31c231ac781b"}, {"id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6", "size": {"x": 250, "y": 100}, "header": null, "host_id": "8c947d32-8ad2-4aaf-af2c-5d4498d98b22", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8477c252-9c12-4d62-a96e-13f9cc428b4e", "interface_id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "cf43e176-a9f4-4a57-93cf-ef9d5f64353c", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "ca233eb2-4699-491e-ba68-704dc5140db1", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "0db94ed9-a560-484b-b9af-600f6e15a5ce"}, "hostname": null, "services": ["aadc272d-1e8a-45ab-8dcc-7a9d6df14cae"], "created_at": "2025-12-13T14:47:12.349681Z", "interfaces": [{"id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634", "name": "Internet", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.359599Z", "description": null, "virtualization": null}, {"id": "477da266-0dee-4cb0-bdbd-ddef618f7e8f", "name": "Google.com", "tags": [], "ports": [{"id": "83684ee9-70fb-49ee-88fa-3043f2c83557", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c0b84706-3f24-43d3-86a9-a3188fb09988"}, "hostname": null, "services": ["e16f8f2a-a37e-4906-bdc2-1b354b4fa6aa"], "created_at": "2025-12-13T14:47:12.349691Z", "interfaces": [{"id": "d43625a4-5510-4ad6-bf1a-31c231ac781b", "name": "Internet", "subnet_id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "ip_address": "203.0.113.35", "mac_address": null}], "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.364834Z", "description": null, "virtualization": null}, {"id": "8c947d32-8ad2-4aaf-af2c-5d4498d98b22", "name": "Mobile Device", "tags": [], "ports": [{"id": "2488ce43-68d1-4e30-98d7-6c7e2235e2ed", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "4de258fa-c82a-4adf-8ef5-290b9ffc87e1"}, "hostname": null, "services": ["a93539f2-7b4d-479c-8126-da0954ed0044"], "created_at": "2025-12-13T14:47:12.349696Z", "interfaces": [{"id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6", "name": "Remote Network", "subnet_id": "8477c252-9c12-4d62-a96e-13f9cc428b4e", "ip_address": "203.0.113.41", "mac_address": null}], "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.369023Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "9b9abe30-c67e-45bc-a303-fb9a19e4b656", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T14:47:12.349628Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.349628Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "8477c252-9c12-4d62-a96e-13f9cc428b4e", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T14:47:12.349631Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.349631Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "c34128fe-2920-41e7-a1cf-abb941a04675", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T14:47:12.438064886Z", "type": "SelfReport", "host_id": "52a1af3f-d7a0-4aa5-bb1f-382e0366a861", "daemon_id": "ac487ead-951c-4413-b6e9-4926298b24e9"}]}, "created_at": "2025-12-13T14:47:12.438066Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.438066Z", "description": null, "subnet_type": "Lan"}]	[{"id": "aadc272d-1e8a-45ab-8dcc-7a9d6df14cae", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "cf43e176-a9f4-4a57-93cf-ef9d5f64353c", "bindings": [{"id": "0db94ed9-a560-484b-b9af-600f6e15a5ce", "type": "Port", "port_id": "ca233eb2-4699-491e-ba68-704dc5140db1", "interface_id": "1ee5b1f8-7e9d-48dc-ad6b-21e555022634"}], "created_at": "2025-12-13T14:47:12.349684Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.349684Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "e16f8f2a-a37e-4906-bdc2-1b354b4fa6aa", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "477da266-0dee-4cb0-bdbd-ddef618f7e8f", "bindings": [{"id": "c0b84706-3f24-43d3-86a9-a3188fb09988", "type": "Port", "port_id": "83684ee9-70fb-49ee-88fa-3043f2c83557", "interface_id": "d43625a4-5510-4ad6-bf1a-31c231ac781b"}], "created_at": "2025-12-13T14:47:12.349692Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.349692Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "a93539f2-7b4d-479c-8126-da0954ed0044", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "8c947d32-8ad2-4aaf-af2c-5d4498d98b22", "bindings": [{"id": "4de258fa-c82a-4adf-8ef5-290b9ffc87e1", "type": "Port", "port_id": "2488ce43-68d1-4e30-98d7-6c7e2235e2ed", "interface_id": "26ffbcae-7d72-4211-b8c5-edd9b24572d6"}], "created_at": "2025-12-13T14:47:12.349697Z", "network_id": "74a17d30-f3d1-42d1-8e79-c94f081109b8", "updated_at": "2025-12-13T14:47:12.349697Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 14:47:12.373691+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 14:47:12.370015+00	2025-12-13 14:48:25.991501+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
b7432597-3684-43b0-a138-c123ff8ac1e2	2025-12-13 14:47:12.32975+00	2025-12-13 14:47:12.32975+00	$argon2id$v=19$m=19456,t=2,p=1$U8b6z+cXNC74mS6fPUOgOQ$u1yAulssC68XhWTwHPoQ3PZgzDfzoKPa4l5rYDQkCtE	\N	\N	\N	user@gmail.com	ae0d6265-563a-4a08-9480-7a0cf4240656	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
xldQG85zjPyWb85lZ4NLwA	\\x93c410c04b836765ce6f96fc8c73ce1b5057c681a7757365725f6964d92462373433323539372d333638342d343362302d613133382d63313233666638616331653299cd07ea0c0e2f0cce13da684e000000	2026-01-12 14:47:12.33308+00
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

\unrestrict SVpBMco9NtEXrLCa5RmdIInonlARKHAfhaYytmxN26sMUjTxvbXCNdKmZK1qXgC

