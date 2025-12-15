--
-- PostgreSQL database dump
--

\restrict FVKcFsZRzIMScosQop5dEarUMa7o0Ny8dlSa3v8g4AIpkrdxVDIGs21ntENdrak

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
20251006215000	users	2025-12-15 04:20:07.438967+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3731985
20251006215100	networks	2025-12-15 04:20:07.443617+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5146362
20251006215151	create hosts	2025-12-15 04:20:07.449095+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4154305
20251006215155	create subnets	2025-12-15 04:20:07.453598+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4051493
20251006215201	create groups	2025-12-15 04:20:07.458041+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4300870
20251006215204	create daemons	2025-12-15 04:20:07.462674+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4574441
20251006215212	create services	2025-12-15 04:20:07.467599+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5175968
20251029193448	user-auth	2025-12-15 04:20:07.473083+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5871789
20251030044828	daemon api	2025-12-15 04:20:07.479267+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1626163
20251030170438	host-hide	2025-12-15 04:20:07.481188+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1123483
20251102224919	create discovery	2025-12-15 04:20:07.482591+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11746155
20251106235621	normalize-daemon-cols	2025-12-15 04:20:07.494654+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1848009
20251107034459	api keys	2025-12-15 04:20:07.496946+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8981149
20251107222650	oidc-auth	2025-12-15 04:20:07.506271+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26593684
20251110181948	orgs-billing	2025-12-15 04:20:07.533171+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10655594
20251113223656	group-enhancements	2025-12-15 04:20:07.544174+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1096653
20251117032720	daemon-mode	2025-12-15 04:20:07.545547+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1059694
20251118143058	set-default-plan	2025-12-15 04:20:07.5469+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1141736
20251118225043	save-topology	2025-12-15 04:20:07.548388+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9173349
20251123232748	network-permissions	2025-12-15 04:20:07.557877+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2647245
20251125001342	billing-updates	2025-12-15 04:20:07.560833+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	835684
20251128035448	org-onboarding-status	2025-12-15 04:20:07.561968+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1361388
20251129180942	nfs-consolidate	2025-12-15 04:20:07.563608+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1179698
20251206052641	discovery-progress	2025-12-15 04:20:07.565069+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1572510
20251206202200	plan-fix	2025-12-15 04:20:07.566936+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	861843
20251207061341	daemon-url	2025-12-15 04:20:07.568072+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2244952
20251210045929	tags	2025-12-15 04:20:07.570601+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8528763
20251210175035	terms	2025-12-15 04:20:07.579448+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	860200
20251213025048	hash-keys	2025-12-15 04:20:07.580587+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	8852509
20251214050638	scanopy	2025-12-15 04:20:07.589744+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1351911
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
4fa96456-f635-4c67-ab42-56173b1e65a8	1bf0e8dc6c8bc86d73109755e0f2df48e11c11d4b661fac5902b1ade246c5ac6	05de138e-f5c8-4a46-aeb9-9c21bfcac826	Integrated Daemon API Key	2025-12-15 04:20:10.688505+00	2025-12-15 04:21:45.362066+00	2025-12-15 04:21:45.36092+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
c73cb7a4-2075-43e8-a3d4-66004b3cf225	05de138e-f5c8-4a46-aeb9-9c21bfcac826	5ecabdf1-a750-4e12-95d0-9ca578263a65	2025-12-15 04:20:10.734654+00	2025-12-15 04:21:26.124529+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["76b7c18f-c093-464a-8259-ff48f4dd5d73"]}	2025-12-15 04:21:26.12545+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
0dca9252-134b-4763-bc76-a1eca1f278a4	05de138e-f5c8-4a46-aeb9-9c21bfcac826	c73cb7a4-2075-43e8-a3d4-66004b3cf225	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65"}	Self Report	2025-12-15 04:20:10.742895+00	2025-12-15 04:20:10.742895+00	{}
4233bcff-25a7-4c8f-a0a8-64cfe4a60731	05de138e-f5c8-4a46-aeb9-9c21bfcac826	c73cb7a4-2075-43e8-a3d4-66004b3cf225	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 04:20:10.749974+00	2025-12-15 04:20:10.749974+00	{}
b71bf56d-ae19-4638-bcf9-1b50f4c0e9e1	05de138e-f5c8-4a46-aeb9-9c21bfcac826	c73cb7a4-2075-43e8-a3d4-66004b3cf225	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "session_id": "86b294dc-9c31-4b62-9884-5c3ffc8471c3", "started_at": "2025-12-15T04:20:10.749451526Z", "finished_at": "2025-12-15T04:20:10.856636557Z", "discovery_type": {"type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65"}}}	{"type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65"}	Self Report	2025-12-15 04:20:10.749451+00	2025-12-15 04:20:10.86268+00	{}
d336d3e6-f593-4f0d-b569-d8105b1e8f9f	05de138e-f5c8-4a46-aeb9-9c21bfcac826	c73cb7a4-2075-43e8-a3d4-66004b3cf225	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "session_id": "055fa16f-f381-47e7-bfb3-0f8a221b560c", "started_at": "2025-12-15T04:20:10.876749520Z", "finished_at": "2025-12-15T04:21:45.358222856Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 04:20:10.876749+00	2025-12-15 04:21:45.361162+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
589236d7-2c80-4d78-9dd3-2a7229cc69aa	05de138e-f5c8-4a46-aeb9-9c21bfcac826		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 04:21:45.375363+00	2025-12-15 04:21:45.375363+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
40e490f0-18d9-480c-9dc0-b8a6403c0d63	05de138e-f5c8-4a46-aeb9-9c21bfcac826	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "63606c5a-94f8-41d5-a134-58e018107e3b"}	[{"id": "a3fac25c-42ea-4729-a248-acb343d6ad85", "name": "Internet", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "ip_address": "1.1.1.1", "mac_address": null}]	{89d36b30-2210-4539-a775-b5b3213a1c24}	[{"id": "993a367f-13bc-4bf2-b542-53f85aabfe8a", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 04:20:10.663645+00	2025-12-15 04:20:10.673239+00	f	{}
8cc1e7b9-ddc9-4571-8b4e-03ec17e3935f	05de138e-f5c8-4a46-aeb9-9c21bfcac826	Google.com	\N	\N	{"type": "ServiceBinding", "config": "15f9f826-32a0-4bba-bdf4-5f1f1a439ee5"}	[{"id": "40e01334-cae8-488d-9b7c-490020de26c8", "name": "Internet", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "ip_address": "203.0.113.38", "mac_address": null}]	{e4a765a3-37fd-4b7e-8a9e-9791f6e18360}	[{"id": "b1193b10-1f85-4568-81a1-0e2b887173eb", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 04:20:10.663651+00	2025-12-15 04:20:10.678507+00	f	{}
246df746-1468-4a4f-a058-b0471e753538	05de138e-f5c8-4a46-aeb9-9c21bfcac826	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "b227bfcb-badf-486e-b19b-877f813ff23c"}	[{"id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e", "name": "Remote Network", "subnet_id": "99589182-4b7d-4394-a293-793deb833583", "ip_address": "203.0.113.199", "mac_address": null}]	{97f9af8e-d353-41a7-aed6-0bfc763299ba}	[{"id": "b24f2002-7d3b-4364-9a83-018a63ad5f92", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 04:20:10.663657+00	2025-12-15 04:20:10.682106+00	f	{}
633e1e4f-2a44-459f-8858-f6531d9492ce	05de138e-f5c8-4a46-aeb9-9c21bfcac826	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "ba7caf74-0655-482d-8e9e-cafb9e095f17", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.3", "mac_address": "26:D1:6B:BF:8E:2D"}]	{2a1339e7-6c69-4240-992e-84bf1f7c45d1}	[{"id": "811ec7d2-c5e9-4024-9a89-dee30a794d9b", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:57.043555644Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:20:57.043557+00	2025-12-15 04:21:11.127384+00	f	{}
5ecabdf1-a750-4e12-95d0-9ca578263a65	05de138e-f5c8-4a46-aeb9-9c21bfcac826	scanopy-daemon	47f513537de8	Scanopy daemon	{"type": "None"}	[{"id": "1360bb87-d139-4631-b118-5d532a491442", "name": "eth0", "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.4", "mac_address": "2A:E9:C6:07:AF:CE"}]	{1ca380d6-d2d1-4d4d-819f-543c6fc88fa9}	[{"id": "7db852b9-535f-4195-8320-0ee52b73e71a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:10.837162124Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}	null	2025-12-15 04:20:10.696908+00	2025-12-15 04:20:10.854235+00	f	{}
9b57c122-e833-4ae4-9897-ab1f14059a84	05de138e-f5c8-4a46-aeb9-9c21bfcac826	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "96c013c1-805f-4f20-8b8d-40a57206b1e7", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.6", "mac_address": "3E:F2:90:0B:BD:23"}]	{ee83853e-363e-47a3-9c10-8bae860c339b}	[{"id": "c817123c-9eeb-496e-838b-d5438df6755d", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:42.840091188Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:20:42.840093+00	2025-12-15 04:20:56.96638+00	f	{}
e10aee37-cf84-4900-8c00-65858723cbf3	05de138e-f5c8-4a46-aeb9-9c21bfcac826	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.5", "mac_address": "8E:B4:19:96:1F:D3"}]	{6ca577cc-41d3-4803-ba39-6900c535a2fe}	[{"id": "cb5b699d-3dfd-45d5-b926-8aeb4d3251d5", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1dc8d2de-c4c1-4692-be6e-de79cf6d3fa4", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:21:11.124439488Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:21:11.124442+00	2025-12-15 04:21:25.227028+00	f	{}
800926ab-4b54-4975-94fd-fc93dfb2658f	05de138e-f5c8-4a46-aeb9-9c21bfcac826	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "3e55b1e9-9d3f-4c58-b702-185944420a4e", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.1", "mac_address": "86:AF:72:58:05:FC"}]	{2e702879-9c33-484b-be71-21f6d87802ed,07b6cbce-5791-4fd3-9e4d-bd9c8e7058b6,b28b8b42-d6d8-40ce-b0d7-81bbca9adc71,531bcc42-ac68-4362-a562-a3886edf0976}	[{"id": "b75955c4-2ce5-4376-8511-20d22436ce9e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "291b4c1d-2c4e-4b26-927e-bc0ae70ee328", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "8a5d02ae-d8c2-4580-8400-71e89b8be5d2", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "079c7a49-88f2-4843-9388-caa0a6941e45", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:21:31.277466215Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:21:31.277469+00	2025-12-15 04:21:45.352894+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
05de138e-f5c8-4a46-aeb9-9c21bfcac826	My Network	2025-12-15 04:20:10.662382+00	2025-12-15 04:20:10.662382+00	f	3ffbcb00-28f8-4b21-ac38-762ff99b5dfd	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
3ffbcb00-28f8-4b21-ac38-762ff99b5dfd	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 04:20:10.656628+00	2025-12-15 04:21:46.186015+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
89d36b30-2210-4539-a775-b5b3213a1c24	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.663647+00	2025-12-15 04:20:10.663647+00	Cloudflare DNS	40e490f0-18d9-480c-9dc0-b8a6403c0d63	[{"id": "63606c5a-94f8-41d5-a134-58e018107e3b", "type": "Port", "port_id": "993a367f-13bc-4bf2-b542-53f85aabfe8a", "interface_id": "a3fac25c-42ea-4729-a248-acb343d6ad85"}]	"Dns Server"	null	{"type": "System"}	{}
e4a765a3-37fd-4b7e-8a9e-9791f6e18360	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.663653+00	2025-12-15 04:20:10.663653+00	Google.com	8cc1e7b9-ddc9-4571-8b4e-03ec17e3935f	[{"id": "15f9f826-32a0-4bba-bdf4-5f1f1a439ee5", "type": "Port", "port_id": "b1193b10-1f85-4568-81a1-0e2b887173eb", "interface_id": "40e01334-cae8-488d-9b7c-490020de26c8"}]	"Web Service"	null	{"type": "System"}	{}
97f9af8e-d353-41a7-aed6-0bfc763299ba	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.663658+00	2025-12-15 04:20:10.663658+00	Mobile Device	246df746-1468-4a4f-a058-b0471e753538	[{"id": "b227bfcb-badf-486e-b19b-877f813ff23c", "type": "Port", "port_id": "b24f2002-7d3b-4364-9a83-018a63ad5f92", "interface_id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e"}]	"Client"	null	{"type": "System"}	{}
1ca380d6-d2d1-4d4d-819f-543c6fc88fa9	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.83718+00	2025-12-15 04:20:10.83718+00	Scanopy Daemon	5ecabdf1-a750-4e12-95d0-9ca578263a65	[{"id": "9cc0e165-5036-401d-8e60-1a821632d7cb", "type": "Port", "port_id": "7db852b9-535f-4195-8320-0ee52b73e71a", "interface_id": "1360bb87-d139-4631-b118-5d532a491442"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T04:20:10.837179877Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}	{}
ee83853e-363e-47a3-9c10-8bae860c339b	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:56.951065+00	2025-12-15 04:20:56.951065+00	PostgreSQL	9b57c122-e833-4ae4-9897-ab1f14059a84	[{"id": "fbf15398-3068-4f7d-bfdd-6b984ec8f6e3", "type": "Port", "port_id": "c817123c-9eeb-496e-838b-d5438df6755d", "interface_id": "96c013c1-805f-4f20-8b8d-40a57206b1e7"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:20:56.951046546Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2a1339e7-6c69-4240-992e-84bf1f7c45d1	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:05.5013+00	2025-12-15 04:21:05.5013+00	Scanopy Server	633e1e4f-2a44-459f-8858-f6531d9492ce	[{"id": "ab093bb5-49e9-4fdb-9905-0174b8f54502", "type": "Port", "port_id": "811ec7d2-c5e9-4024-9a89-dee30a794d9b", "interface_id": "ba7caf74-0655-482d-8e9e-cafb9e095f17"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:05.501284692Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6ca577cc-41d3-4803-ba39-6900c535a2fe	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:25.217815+00	2025-12-15 04:21:25.217815+00	Unclaimed Open Ports	e10aee37-cf84-4900-8c00-65858723cbf3	[{"id": "dd3a0510-b212-4a9d-91b6-e34ef8a5c6ed", "type": "Port", "port_id": "cb5b699d-3dfd-45d5-b926-8aeb4d3251d5", "interface_id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13"}, {"id": "db4299ce-6def-4ad5-bb0f-e9c2ffe44555", "type": "Port", "port_id": "1dc8d2de-c4c1-4692-be6e-de79cf6d3fa4", "interface_id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:25.217797966Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2e702879-9c33-484b-be71-21f6d87802ed	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:39.718113+00	2025-12-15 04:21:39.718113+00	Home Assistant	800926ab-4b54-4975-94fd-fc93dfb2658f	[{"id": "93c1c427-56ee-4bd5-b654-093d0f038739", "type": "Port", "port_id": "b75955c4-2ce5-4376-8511-20d22436ce9e", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:39.718095148Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
07b6cbce-5791-4fd3-9e4d-bd9c8e7058b6	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:39.719318+00	2025-12-15 04:21:39.719318+00	Scanopy Server	800926ab-4b54-4975-94fd-fc93dfb2658f	[{"id": "d9b7dbce-1797-4c39-97d6-fdae85f27be5", "type": "Port", "port_id": "291b4c1d-2c4e-4b26-927e-bc0ae70ee328", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:39.719310851Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b28b8b42-d6d8-40ce-b0d7-81bbca9adc71	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:45.337364+00	2025-12-15 04:21:45.337364+00	SSH	800926ab-4b54-4975-94fd-fc93dfb2658f	[{"id": "4811d8b3-526a-441e-bb28-365dd9f61688", "type": "Port", "port_id": "8a5d02ae-d8c2-4580-8400-71e89b8be5d2", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:45.337344894Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
531bcc42-ac68-4362-a562-a3886edf0976	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:21:45.337538+00	2025-12-15 04:21:45.337538+00	Unclaimed Open Ports	800926ab-4b54-4975-94fd-fc93dfb2658f	[{"id": "3a6be963-e613-4bae-b042-cc14d99cd086", "type": "Port", "port_id": "079c7a49-88f2-4843-9388-caa0a6941e45", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:45.337529960Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
05665c64-89eb-41ec-8884-4bc127d946a1	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.663594+00	2025-12-15 04:20:10.663594+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
99589182-4b7d-4394-a293-793deb833583	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.663597+00	2025-12-15 04:20:10.663597+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
76b7c18f-c093-464a-8259-ff48f4dd5d73	05de138e-f5c8-4a46-aeb9-9c21bfcac826	2025-12-15 04:20:10.749608+00	2025-12-15 04:20:10.749608+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:10.749606427Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
bc095925-0104-4316-a3d0-04e63771cd4f	3ffbcb00-28f8-4b21-ac38-762ff99b5dfd	New Tag	\N	2025-12-15 04:21:45.382955+00	2025-12-15 04:21:45.382955+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
36e5c1a9-6fd0-4189-93bd-0c53c93c7e64	05de138e-f5c8-4a46-aeb9-9c21bfcac826	My Topology	[]	[{"id": "05665c64-89eb-41ec-8884-4bc127d946a1", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "99589182-4b7d-4394-a293-793deb833583", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e", "size": {"x": 250, "y": 100}, "header": null, "host_id": "246df746-1468-4a4f-a058-b0471e753538", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "99589182-4b7d-4394-a293-793deb833583", "interface_id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e"}, {"id": "a3fac25c-42ea-4729-a248-acb343d6ad85", "size": {"x": 250, "y": 100}, "header": null, "host_id": "40e490f0-18d9-480c-9dc0-b8a6403c0d63", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "interface_id": "a3fac25c-42ea-4729-a248-acb343d6ad85"}, {"id": "40e01334-cae8-488d-9b7c-490020de26c8", "size": {"x": 250, "y": 100}, "header": null, "host_id": "8cc1e7b9-ddc9-4571-8b4e-03ec17e3935f", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "interface_id": "40e01334-cae8-488d-9b7c-490020de26c8"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "40e490f0-18d9-480c-9dc0-b8a6403c0d63", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "993a367f-13bc-4bf2-b542-53f85aabfe8a", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "63606c5a-94f8-41d5-a134-58e018107e3b"}, "hostname": null, "services": ["89d36b30-2210-4539-a775-b5b3213a1c24"], "created_at": "2025-12-15T04:20:10.663645Z", "interfaces": [{"id": "a3fac25c-42ea-4729-a248-acb343d6ad85", "name": "Internet", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.673239Z", "description": null, "virtualization": null}, {"id": "8cc1e7b9-ddc9-4571-8b4e-03ec17e3935f", "name": "Google.com", "tags": [], "ports": [{"id": "b1193b10-1f85-4568-81a1-0e2b887173eb", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "15f9f826-32a0-4bba-bdf4-5f1f1a439ee5"}, "hostname": null, "services": ["e4a765a3-37fd-4b7e-8a9e-9791f6e18360"], "created_at": "2025-12-15T04:20:10.663651Z", "interfaces": [{"id": "40e01334-cae8-488d-9b7c-490020de26c8", "name": "Internet", "subnet_id": "05665c64-89eb-41ec-8884-4bc127d946a1", "ip_address": "203.0.113.38", "mac_address": null}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.678507Z", "description": null, "virtualization": null}, {"id": "246df746-1468-4a4f-a058-b0471e753538", "name": "Mobile Device", "tags": [], "ports": [{"id": "b24f2002-7d3b-4364-9a83-018a63ad5f92", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "b227bfcb-badf-486e-b19b-877f813ff23c"}, "hostname": null, "services": ["97f9af8e-d353-41a7-aed6-0bfc763299ba"], "created_at": "2025-12-15T04:20:10.663657Z", "interfaces": [{"id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e", "name": "Remote Network", "subnet_id": "99589182-4b7d-4394-a293-793deb833583", "ip_address": "203.0.113.199", "mac_address": null}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.682106Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "7db852b9-535f-4195-8320-0ee52b73e71a", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:10.837162124Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}, "target": {"type": "None"}, "hostname": "47f513537de8", "services": ["1ca380d6-d2d1-4d4d-819f-543c6fc88fa9"], "created_at": "2025-12-15T04:20:10.696908Z", "interfaces": [{"id": "1360bb87-d139-4631-b118-5d532a491442", "name": "eth0", "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.4", "mac_address": "2A:E9:C6:07:AF:CE"}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.854235Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "9b57c122-e833-4ae4-9897-ab1f14059a84", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "c817123c-9eeb-496e-838b-d5438df6755d", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:42.840091188Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["ee83853e-363e-47a3-9c10-8bae860c339b"], "created_at": "2025-12-15T04:20:42.840093Z", "interfaces": [{"id": "96c013c1-805f-4f20-8b8d-40a57206b1e7", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.6", "mac_address": "3E:F2:90:0B:BD:23"}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:56.966380Z", "description": null, "virtualization": null}, {"id": "633e1e4f-2a44-459f-8858-f6531d9492ce", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "811ec7d2-c5e9-4024-9a89-dee30a794d9b", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:57.043555644Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["2a1339e7-6c69-4240-992e-84bf1f7c45d1"], "created_at": "2025-12-15T04:20:57.043557Z", "interfaces": [{"id": "ba7caf74-0655-482d-8e9e-cafb9e095f17", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.3", "mac_address": "26:D1:6B:BF:8E:2D"}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:11.127384Z", "description": null, "virtualization": null}, {"id": "e10aee37-cf84-4900-8c00-65858723cbf3", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "cb5b699d-3dfd-45d5-b926-8aeb4d3251d5", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1dc8d2de-c4c1-4692-be6e-de79cf6d3fa4", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:21:11.124439488Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["6ca577cc-41d3-4803-ba39-6900c535a2fe"], "created_at": "2025-12-15T04:21:11.124442Z", "interfaces": [{"id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.5", "mac_address": "8E:B4:19:96:1F:D3"}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:25.227028Z", "description": null, "virtualization": null}, {"id": "800926ab-4b54-4975-94fd-fc93dfb2658f", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "b75955c4-2ce5-4376-8511-20d22436ce9e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "291b4c1d-2c4e-4b26-927e-bc0ae70ee328", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "8a5d02ae-d8c2-4580-8400-71e89b8be5d2", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "079c7a49-88f2-4843-9388-caa0a6941e45", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:21:31.277466215Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["2e702879-9c33-484b-be71-21f6d87802ed", "07b6cbce-5791-4fd3-9e4d-bd9c8e7058b6", "b28b8b42-d6d8-40ce-b0d7-81bbca9adc71", "531bcc42-ac68-4362-a562-a3886edf0976"], "created_at": "2025-12-15T04:21:31.277469Z", "interfaces": [{"id": "3e55b1e9-9d3f-4c58-b702-185944420a4e", "name": null, "subnet_id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "ip_address": "172.25.0.1", "mac_address": "86:AF:72:58:05:FC"}], "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:45.352894Z", "description": null, "virtualization": null}]	[{"id": "05665c64-89eb-41ec-8884-4bc127d946a1", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T04:20:10.663594Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.663594Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "99589182-4b7d-4394-a293-793deb833583", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T04:20:10.663597Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.663597Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "76b7c18f-c093-464a-8259-ff48f4dd5d73", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:20:10.749606427Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}, "created_at": "2025-12-15T04:20:10.749608Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.749608Z", "description": null, "subnet_type": "Lan"}]	[{"id": "89d36b30-2210-4539-a775-b5b3213a1c24", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "40e490f0-18d9-480c-9dc0-b8a6403c0d63", "bindings": [{"id": "63606c5a-94f8-41d5-a134-58e018107e3b", "type": "Port", "port_id": "993a367f-13bc-4bf2-b542-53f85aabfe8a", "interface_id": "a3fac25c-42ea-4729-a248-acb343d6ad85"}], "created_at": "2025-12-15T04:20:10.663647Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.663647Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "e4a765a3-37fd-4b7e-8a9e-9791f6e18360", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "8cc1e7b9-ddc9-4571-8b4e-03ec17e3935f", "bindings": [{"id": "15f9f826-32a0-4bba-bdf4-5f1f1a439ee5", "type": "Port", "port_id": "b1193b10-1f85-4568-81a1-0e2b887173eb", "interface_id": "40e01334-cae8-488d-9b7c-490020de26c8"}], "created_at": "2025-12-15T04:20:10.663653Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.663653Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "97f9af8e-d353-41a7-aed6-0bfc763299ba", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "246df746-1468-4a4f-a058-b0471e753538", "bindings": [{"id": "b227bfcb-badf-486e-b19b-877f813ff23c", "type": "Port", "port_id": "b24f2002-7d3b-4364-9a83-018a63ad5f92", "interface_id": "39f95f7a-4d18-463b-a6dd-26abd92cc86e"}], "created_at": "2025-12-15T04:20:10.663658Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.663658Z", "virtualization": null, "service_definition": "Client"}, {"id": "1ca380d6-d2d1-4d4d-819f-543c6fc88fa9", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T04:20:10.837179877Z", "type": "SelfReport", "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225"}]}, "host_id": "5ecabdf1-a750-4e12-95d0-9ca578263a65", "bindings": [{"id": "9cc0e165-5036-401d-8e60-1a821632d7cb", "type": "Port", "port_id": "7db852b9-535f-4195-8320-0ee52b73e71a", "interface_id": "1360bb87-d139-4631-b118-5d532a491442"}], "created_at": "2025-12-15T04:20:10.837180Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:10.837180Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "ee83853e-363e-47a3-9c10-8bae860c339b", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:20:56.951046546Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "9b57c122-e833-4ae4-9897-ab1f14059a84", "bindings": [{"id": "fbf15398-3068-4f7d-bfdd-6b984ec8f6e3", "type": "Port", "port_id": "c817123c-9eeb-496e-838b-d5438df6755d", "interface_id": "96c013c1-805f-4f20-8b8d-40a57206b1e7"}], "created_at": "2025-12-15T04:20:56.951065Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:20:56.951065Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "2a1339e7-6c69-4240-992e-84bf1f7c45d1", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:05.501284692Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "633e1e4f-2a44-459f-8858-f6531d9492ce", "bindings": [{"id": "ab093bb5-49e9-4fdb-9905-0174b8f54502", "type": "Port", "port_id": "811ec7d2-c5e9-4024-9a89-dee30a794d9b", "interface_id": "ba7caf74-0655-482d-8e9e-cafb9e095f17"}], "created_at": "2025-12-15T04:21:05.501300Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:05.501300Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "6ca577cc-41d3-4803-ba39-6900c535a2fe", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:25.217797966Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e10aee37-cf84-4900-8c00-65858723cbf3", "bindings": [{"id": "dd3a0510-b212-4a9d-91b6-e34ef8a5c6ed", "type": "Port", "port_id": "cb5b699d-3dfd-45d5-b926-8aeb4d3251d5", "interface_id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13"}, {"id": "db4299ce-6def-4ad5-bb0f-e9c2ffe44555", "type": "Port", "port_id": "1dc8d2de-c4c1-4692-be6e-de79cf6d3fa4", "interface_id": "2926a9bd-2fe9-47f4-925a-20d450d3ff13"}], "created_at": "2025-12-15T04:21:25.217815Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:25.217815Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "2e702879-9c33-484b-be71-21f6d87802ed", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:39.718095148Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "800926ab-4b54-4975-94fd-fc93dfb2658f", "bindings": [{"id": "93c1c427-56ee-4bd5-b654-093d0f038739", "type": "Port", "port_id": "b75955c4-2ce5-4376-8511-20d22436ce9e", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}], "created_at": "2025-12-15T04:21:39.718113Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:39.718113Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "07b6cbce-5791-4fd3-9e4d-bd9c8e7058b6", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:21:39.719310851Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "800926ab-4b54-4975-94fd-fc93dfb2658f", "bindings": [{"id": "d9b7dbce-1797-4c39-97d6-fdae85f27be5", "type": "Port", "port_id": "291b4c1d-2c4e-4b26-927e-bc0ae70ee328", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}], "created_at": "2025-12-15T04:21:39.719318Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:39.719318Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "b28b8b42-d6d8-40ce-b0d7-81bbca9adc71", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:45.337344894Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "800926ab-4b54-4975-94fd-fc93dfb2658f", "bindings": [{"id": "4811d8b3-526a-441e-bb28-365dd9f61688", "type": "Port", "port_id": "8a5d02ae-d8c2-4580-8400-71e89b8be5d2", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}], "created_at": "2025-12-15T04:21:45.337364Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:45.337364Z", "virtualization": null, "service_definition": "SSH"}, {"id": "531bcc42-ac68-4362-a562-a3886edf0976", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:21:45.337529960Z", "type": "Network", "daemon_id": "c73cb7a4-2075-43e8-a3d4-66004b3cf225", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "800926ab-4b54-4975-94fd-fc93dfb2658f", "bindings": [{"id": "3a6be963-e613-4bae-b042-cc14d99cd086", "type": "Port", "port_id": "079c7a49-88f2-4843-9388-caa0a6941e45", "interface_id": "3e55b1e9-9d3f-4c58-b702-185944420a4e"}], "created_at": "2025-12-15T04:21:45.337538Z", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:45.337538Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "589236d7-2c80-4d78-9dd3-2a7229cc69aa", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T04:21:45.375363Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "05de138e-f5c8-4a46-aeb9-9c21bfcac826", "updated_at": "2025-12-15T04:21:45.375363Z", "description": null, "service_bindings": []}]	t	2025-12-15 04:20:10.686073+00	f	\N	\N	{7865d469-e09e-4151-b1b3-d6d077f1510e,ab6ca6f9-e703-41cf-aac6-d239055f85d2}	{0e1e974c-71e9-47a3-9f6b-a68373695279}	{6c7b70e3-79ed-4e11-9f19-849f1c7d8a8c}	{0aba0167-db8a-4458-a519-53e9e63db678}	\N	2025-12-15 04:20:10.682802+00	2025-12-15 04:21:46.26789+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
69d01a28-aac2-402b-a2e5-36376a3bed06	2025-12-15 04:20:10.659413+00	2025-12-15 04:20:10.659413+00	$argon2id$v=19$m=19456,t=2,p=1$TCgbYQyKadNCa6/OXGg40g$zgSv2EOe4c9o/glkFvo4P6eOnnYmoqqiG11h3IX1ws8	\N	\N	\N	user@gmail.com	3ffbcb00-28f8-4b21-ac38-762ff99b5dfd	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
mdPo6_FI9HyDK_tLcXEbmQ	\\x93c410991b71714bfb2b837cf448f1ebe8d39981a7757365725f6964d92436396430316132382d616163322d343032622d613265352d33363337366133626564303699cd07ea0e04140ace2d46f981000000	2026-01-14 04:20:10.759626+00
l9gUQ3MyFla3_LYaYLiAOA	\\x93c4103880b8601ab6fcb7561632734314d89782a7757365725f6964d92436396430316132382d616163322d343032622d613265352d333633373661336265643036ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92439646233303138662d316635312d343262652d613939632d633339316366316238393039ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea0e04152dce381559fb000000	2026-01-14 04:21:45.940923+00
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

\unrestrict FVKcFsZRzIMScosQop5dEarUMa7o0Ny8dlSa3v8g4AIpkrdxVDIGs21ntENdrak

