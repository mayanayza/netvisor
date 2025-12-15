--
-- PostgreSQL database dump
--

\restrict HVnZYDxOb4aCnSkpoF7eTwnHTjtnMAIfTgu9m6x6opcyp9u61XqQgcqwbcxQ2Wh

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
20251006215000	users	2025-12-15 00:45:36.790404+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3566275
20251006215100	networks	2025-12-15 00:45:36.794975+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4699092
20251006215151	create hosts	2025-12-15 00:45:36.799986+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3958104
20251006215155	create subnets	2025-12-15 00:45:36.804375+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4007726
20251006215201	create groups	2025-12-15 00:45:36.808749+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4042962
20251006215204	create daemons	2025-12-15 00:45:36.813327+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4301854
20251006215212	create services	2025-12-15 00:45:36.818199+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5112772
20251029193448	user-auth	2025-12-15 00:45:36.823649+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6509962
20251030044828	daemon api	2025-12-15 00:45:36.830477+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1802133
20251030170438	host-hide	2025-12-15 00:45:36.832616+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1082123
20251102224919	create discovery	2025-12-15 00:45:36.83397+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10303649
20251106235621	normalize-daemon-cols	2025-12-15 00:45:36.844599+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1759904
20251107034459	api keys	2025-12-15 00:45:36.846659+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8031121
20251107222650	oidc-auth	2025-12-15 00:45:36.855009+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	24595538
20251110181948	orgs-billing	2025-12-15 00:45:36.879933+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11038557
20251113223656	group-enhancements	2025-12-15 00:45:36.891315+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1051115
20251117032720	daemon-mode	2025-12-15 00:45:36.892665+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1159457
20251118143058	set-default-plan	2025-12-15 00:45:36.894124+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1217244
20251118225043	save-topology	2025-12-15 00:45:36.895705+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9392404
20251123232748	network-permissions	2025-12-15 00:45:36.905419+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2717847
20251125001342	billing-updates	2025-12-15 00:45:36.908447+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	920663
20251128035448	org-onboarding-status	2025-12-15 00:45:36.909648+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1474674
20251129180942	nfs-consolidate	2025-12-15 00:45:36.911544+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1269121
20251206052641	discovery-progress	2025-12-15 00:45:36.91309+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1874537
20251206202200	plan-fix	2025-12-15 00:45:36.915369+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	952131
20251207061341	daemon-url	2025-12-15 00:45:36.916625+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2369518
20251210045929	tags	2025-12-15 00:45:36.919518+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9600780
20251210175035	terms	2025-12-15 00:45:36.929302+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	927095
20251213025048	hash-keys	2025-12-15 00:45:36.932899+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	8726335
20251214050638	scanopy	2025-12-15 00:45:36.941959+00	t	\\x224a2b7ccf787fd7dca8c650ee11f0fe34d16fc1509ee85e043102336498c601022819476b914002229d2a2dac6eb2c9	1488459
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
1b3dd83e-aa23-4640-ac37-393a89d2eef0	445fe5f0c51a408add19023ba3c3a309b3d48a771d9cc7c03956cf5bb8f96e59	d444fc95-154e-484d-90e7-ed8db1ccc897	Integrated Daemon API Key	2025-12-15 00:45:39.077631+00	2025-12-15 00:47:19.491966+00	2025-12-15 00:47:19.491053+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
ecdfb873-ded0-416b-bd55-2386f72cae1e	d444fc95-154e-484d-90e7-ed8db1ccc897	9c429c16-08ec-4cba-9afc-127183eff463	2025-12-15 00:45:39.169078+00	2025-12-15 00:46:55.952925+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["a50c6678-0ab2-4c73-9008-5b825faaaa89"]}	2025-12-15 00:46:55.953937+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
e8a99014-4077-4589-865d-0b90f9aefb3b	d444fc95-154e-484d-90e7-ed8db1ccc897	ecdfb873-ded0-416b-bd55-2386f72cae1e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463"}	Self Report	2025-12-15 00:45:39.176934+00	2025-12-15 00:45:39.176934+00	{}
c9fe2a7d-ab8b-46c9-b8a0-e507695a5f77	d444fc95-154e-484d-90e7-ed8db1ccc897	ecdfb873-ded0-416b-bd55-2386f72cae1e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 00:45:39.184304+00	2025-12-15 00:45:39.184304+00	{}
66d5a255-f6d4-4808-a236-73ca83053797	d444fc95-154e-484d-90e7-ed8db1ccc897	ecdfb873-ded0-416b-bd55-2386f72cae1e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "session_id": "988966dd-084f-4b6e-bbab-4feae5cfe1b0", "started_at": "2025-12-15T00:45:39.183854684Z", "finished_at": "2025-12-15T00:45:39.220036212Z", "discovery_type": {"type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463"}}}	{"type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463"}	Self Report	2025-12-15 00:45:39.183854+00	2025-12-15 00:45:39.223531+00	{}
f4637d40-6db4-4083-897b-fefe1a3f10c8	d444fc95-154e-484d-90e7-ed8db1ccc897	ecdfb873-ded0-416b-bd55-2386f72cae1e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "session_id": "3645bef8-c599-493d-b8e0-058ef81c000f", "started_at": "2025-12-15T00:45:39.234717205Z", "finished_at": "2025-12-15T00:47:19.488617468Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 00:45:39.234717+00	2025-12-15 00:47:19.491383+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
468de1a3-5fc7-4661-b6e9-2de7a237eda1	d444fc95-154e-484d-90e7-ed8db1ccc897		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 00:47:19.506851+00	2025-12-15 00:47:19.506851+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
bfefdde0-546c-493d-836b-c2117dfbaee3	d444fc95-154e-484d-90e7-ed8db1ccc897	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "382e4874-c0c5-4995-b7f2-ea08a9f19d5f"}	[{"id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a", "name": "Internet", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "ip_address": "1.1.1.1", "mac_address": null}]	{02884e9a-dcd1-494b-9149-ffeb0f1ec899}	[{"id": "ea9fce1e-7487-4b27-a403-0a1a36f70f8e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 00:45:39.050409+00	2025-12-15 00:45:39.060369+00	f	{}
b8252a1e-3a9f-4074-a68d-09c58da83919	d444fc95-154e-484d-90e7-ed8db1ccc897	Google.com	\N	\N	{"type": "ServiceBinding", "config": "7a085c0b-2ba3-4e02-9b04-24a6a3f70a0a"}	[{"id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73", "name": "Internet", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "ip_address": "203.0.113.83", "mac_address": null}]	{95c3eb90-8f79-41a4-9e40-d2a1697068c1}	[{"id": "2c45f820-27c7-42e0-81d9-acce18e2c258", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 00:45:39.050417+00	2025-12-15 00:45:39.066566+00	f	{}
72b41d46-8330-4d98-a15c-22bab353a159	d444fc95-154e-484d-90e7-ed8db1ccc897	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "15ce3064-1819-4a68-9546-ace102b855ea"}	[{"id": "dcde8407-cb1d-4806-b458-b8be4788a2fd", "name": "Remote Network", "subnet_id": "231259d4-cc8d-4ea2-9780-7e712a86485a", "ip_address": "203.0.113.22", "mac_address": null}]	{81609369-372b-4642-9b51-c1d365790e64}	[{"id": "fe00f445-5d96-4f8f-a9d7-89685d3dd25e", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 00:45:39.050422+00	2025-12-15 00:45:39.070698+00	f	{}
2e981439-b3a5-4993-9d99-fdb3b3245c5c	d444fc95-154e-484d-90e7-ed8db1ccc897	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "afcd92cc-22f6-4508-b73f-c76f242f8c87", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.5", "mac_address": "F2:11:62:C2:6D:2B"}]	{6c4b7847-eceb-4883-8e06-a52f3ef6162d,c85adf07-ff74-4409-874a-a0e33ce282a2}	[{"id": "053aff53-6a20-4452-a333-ca89d769d52d", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "07fafe30-3438-401c-94b1-c08c4bc5a5e2", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:25.831939720Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 00:46:25.831943+00	2025-12-15 00:46:55.962989+00	f	{}
9c429c16-08ec-4cba-9afc-127183eff463	d444fc95-154e-484d-90e7-ed8db1ccc897	scanopy-daemon	e9b61c39413b	Scanopy daemon	{"type": "None"}	[{"id": "d1f6c138-a1f2-47db-bcb3-b0fd358de259", "name": "eth0", "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.4", "mac_address": "02:1E:6E:E7:83:DE"}]	{e316cd4f-d14c-4af7-8e5d-670933673aa4}	[{"id": "b7400d43-3ff1-4ee1-ac26-41aa332218dd", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:45:39.205561871Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}	null	2025-12-15 00:45:39.087025+00	2025-12-15 00:45:39.216945+00	f	{}
7c466557-f676-4b3c-89ee-f1a4f9e8a3d0	d444fc95-154e-484d-90e7-ed8db1ccc897	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "fc121b0f-481c-4655-ae72-78b804f9074b", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.3", "mac_address": "F6:14:3E:05:6F:54"}]	{c2f52c2d-802a-4036-baed-23e6ffd59a22}	[{"id": "cc918211-8d62-4167-910f-c689778da991", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:10.557121065Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 00:46:10.557124+00	2025-12-15 00:46:25.733448+00	f	{}
2b85ed12-948a-465d-a497-e3fd4bf5c123	d444fc95-154e-484d-90e7-ed8db1ccc897	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "f8ff098e-8d1e-43ae-bbd9-16d7ed7f2759", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.6", "mac_address": "66:B7:DD:43:6C:00"}]	{e16ed5a6-9252-488f-b580-6e2f4ac39afa}	[{"id": "aa377adb-39ff-42fc-a09a-1b0bea17a5ae", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:40.897149333Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 00:46:40.89715+00	2025-12-15 00:46:55.963632+00	f	{}
8ed9d655-55d5-43cc-9529-6699ba721be0	d444fc95-154e-484d-90e7-ed8db1ccc897	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "9e7ea623-1c6f-4da6-a049-79ce314e9209", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.1", "mac_address": "2E:71:70:D0:F1:60"}]	{899215d2-e1fd-4a03-a2f7-ab303ccc91d2,df053cf8-b196-4733-866f-908aca5f9a38,cc26581e-12dc-42c0-83db-2795f4023637,cbdc891e-4039-4605-af3b-6352966b6834}	[{"id": "aea3a06a-6264-4692-ba20-d2ca362a3821", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6bc06d75-3154-4091-af3a-9f396658db5e", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "d179e4ef-6adb-4a79-86fe-ebe741c6a407", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "94d44b62-d823-4370-b323-dc7dc012b2d2", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:47:04.007286337Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 00:47:04.00729+00	2025-12-15 00:47:19.48178+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
d444fc95-154e-484d-90e7-ed8db1ccc897	My Network	2025-12-15 00:45:39.048872+00	2025-12-15 00:45:39.048872+00	f	a605a7bb-8790-483a-8503-2cb3746d23f5	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
a605a7bb-8790-483a-8503-2cb3746d23f5	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 00:45:39.042407+00	2025-12-15 00:47:20.351298+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
02884e9a-dcd1-494b-9149-ffeb0f1ec899	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.050412+00	2025-12-15 00:45:39.050412+00	Cloudflare DNS	bfefdde0-546c-493d-836b-c2117dfbaee3	[{"id": "382e4874-c0c5-4995-b7f2-ea08a9f19d5f", "type": "Port", "port_id": "ea9fce1e-7487-4b27-a403-0a1a36f70f8e", "interface_id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a"}]	"Dns Server"	null	{"type": "System"}	{}
95c3eb90-8f79-41a4-9e40-d2a1697068c1	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.050418+00	2025-12-15 00:45:39.050418+00	Google.com	b8252a1e-3a9f-4074-a68d-09c58da83919	[{"id": "7a085c0b-2ba3-4e02-9b04-24a6a3f70a0a", "type": "Port", "port_id": "2c45f820-27c7-42e0-81d9-acce18e2c258", "interface_id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73"}]	"Web Service"	null	{"type": "System"}	{}
81609369-372b-4642-9b51-c1d365790e64	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.050423+00	2025-12-15 00:45:39.050423+00	Mobile Device	72b41d46-8330-4d98-a15c-22bab353a159	[{"id": "15ce3064-1819-4a68-9546-ace102b855ea", "type": "Port", "port_id": "fe00f445-5d96-4f8f-a9d7-89685d3dd25e", "interface_id": "dcde8407-cb1d-4806-b458-b8be4788a2fd"}]	"Client"	null	{"type": "System"}	{}
e316cd4f-d14c-4af7-8e5d-670933673aa4	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.205584+00	2025-12-15 00:45:39.205584+00	Scanopy Daemon	9c429c16-08ec-4cba-9afc-127183eff463	[{"id": "a1a44a8b-1d2a-4ef3-a138-e2e7a41cd3f2", "type": "Port", "port_id": "b7400d43-3ff1-4ee1-ac26-41aa332218dd", "interface_id": "d1f6c138-a1f2-47db-bcb3-b0fd358de259"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T00:45:39.205583952Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}	{}
c2f52c2d-802a-4036-baed-23e6ffd59a22	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:46:19.735365+00	2025-12-15 00:46:19.735365+00	Scanopy Server	7c466557-f676-4b3c-89ee-f1a4f9e8a3d0	[{"id": "0132a0f2-11d0-4e71-8809-e0c57ec6019b", "type": "Port", "port_id": "cc918211-8d62-4167-910f-c689778da991", "interface_id": "fc121b0f-481c-4655-ae72-78b804f9074b"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:46:19.735346790Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c85adf07-ff74-4409-874a-a0e33ce282a2	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:46:40.896555+00	2025-12-15 00:46:40.896555+00	Unclaimed Open Ports	2e981439-b3a5-4993-9d99-fdb3b3245c5c	[{"id": "8126152b-3f4a-4d04-985f-b5abb1f0adc5", "type": "Port", "port_id": "07fafe30-3438-401c-94b1-c08c4bc5a5e2", "interface_id": "afcd92cc-22f6-4508-b73f-c76f242f8c87"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:46:40.896535540Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6c4b7847-eceb-4883-8e06-a52f3ef6162d	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:46:34.845217+00	2025-12-15 00:46:34.845217+00	Home Assistant	2e981439-b3a5-4993-9d99-fdb3b3245c5c	[{"id": "d7254637-5d2c-46d4-bec1-8a057e9b2a41", "type": "Port", "port_id": "053aff53-6a20-4452-a333-ca89d769d52d", "interface_id": "afcd92cc-22f6-4508-b73f-c76f242f8c87"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:46:34.845198474Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e16ed5a6-9252-488f-b580-6e2f4ac39afa	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:46:55.945591+00	2025-12-15 00:46:55.945591+00	PostgreSQL	2b85ed12-948a-465d-a497-e3fd4bf5c123	[{"id": "e21e868c-1124-4ee3-9c29-4833ea1981ed", "type": "Port", "port_id": "aa377adb-39ff-42fc-a09a-1b0bea17a5ae", "interface_id": "f8ff098e-8d1e-43ae-bbd9-16d7ed7f2759"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:46:55.945573392Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
df053cf8-b196-4733-866f-908aca5f9a38	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:47:13.303896+00	2025-12-15 00:47:13.303896+00	Scanopy Server	8ed9d655-55d5-43cc-9529-6699ba721be0	[{"id": "1bf805ea-018b-4ab3-ad39-1c526584b8ce", "type": "Port", "port_id": "6bc06d75-3154-4091-af3a-9f396658db5e", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:47:13.303887024Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
cc26581e-12dc-42c0-83db-2795f4023637	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:47:19.464849+00	2025-12-15 00:47:19.464849+00	SSH	8ed9d655-55d5-43cc-9529-6699ba721be0	[{"id": "89a74f74-e950-4a6c-b499-130492382fbc", "type": "Port", "port_id": "d179e4ef-6adb-4a79-86fe-ebe741c6a407", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:47:19.464832163Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
cbdc891e-4039-4605-af3b-6352966b6834	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:47:19.465014+00	2025-12-15 00:47:19.465014+00	Unclaimed Open Ports	8ed9d655-55d5-43cc-9529-6699ba721be0	[{"id": "90c43aa1-ce32-4ed6-b83d-d35dd177ee37", "type": "Port", "port_id": "94d44b62-d823-4370-b323-dc7dc012b2d2", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:47:19.465006748Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
899215d2-e1fd-4a03-a2f7-ab303ccc91d2	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:47:13.302689+00	2025-12-15 00:47:13.302689+00	Home Assistant	8ed9d655-55d5-43cc-9529-6699ba721be0	[{"id": "0cc5efbf-dbf3-4662-b51e-ee1fb2d5b023", "type": "Port", "port_id": "aea3a06a-6264-4692-ba20-d2ca362a3821", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:47:13.302669860Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
8ed74f78-2312-49cf-bd36-97586496a846	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.050345+00	2025-12-15 00:45:39.050345+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
231259d4-cc8d-4ea2-9780-7e712a86485a	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.050349+00	2025-12-15 00:45:39.050349+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
a50c6678-0ab2-4c73-9008-5b825faaaa89	d444fc95-154e-484d-90e7-ed8db1ccc897	2025-12-15 00:45:39.184009+00	2025-12-15 00:45:39.184009+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T00:45:39.184008600Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
2c288026-a129-4e4e-8a6f-1001bc2ddda9	a605a7bb-8790-483a-8503-2cb3746d23f5	New Tag	\N	2025-12-15 00:47:19.515737+00	2025-12-15 00:47:19.515737+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
6dc01591-e3c5-45f6-95d1-0d24495ff178	d444fc95-154e-484d-90e7-ed8db1ccc897	My Topology	[]	[{"id": "231259d4-cc8d-4ea2-9780-7e712a86485a", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "8ed74f78-2312-49cf-bd36-97586496a846", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "bfefdde0-546c-493d-836b-c2117dfbaee3", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "interface_id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a"}, {"id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73", "size": {"x": 250, "y": 100}, "header": null, "host_id": "b8252a1e-3a9f-4074-a68d-09c58da83919", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "interface_id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73"}, {"id": "dcde8407-cb1d-4806-b458-b8be4788a2fd", "size": {"x": 250, "y": 100}, "header": null, "host_id": "72b41d46-8330-4d98-a15c-22bab353a159", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "231259d4-cc8d-4ea2-9780-7e712a86485a", "interface_id": "dcde8407-cb1d-4806-b458-b8be4788a2fd"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "bfefdde0-546c-493d-836b-c2117dfbaee3", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "ea9fce1e-7487-4b27-a403-0a1a36f70f8e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "382e4874-c0c5-4995-b7f2-ea08a9f19d5f"}, "hostname": null, "services": ["02884e9a-dcd1-494b-9149-ffeb0f1ec899"], "created_at": "2025-12-15T00:45:39.050409Z", "interfaces": [{"id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a", "name": "Internet", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.060369Z", "description": null, "virtualization": null}, {"id": "b8252a1e-3a9f-4074-a68d-09c58da83919", "name": "Google.com", "tags": [], "ports": [{"id": "2c45f820-27c7-42e0-81d9-acce18e2c258", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "7a085c0b-2ba3-4e02-9b04-24a6a3f70a0a"}, "hostname": null, "services": ["95c3eb90-8f79-41a4-9e40-d2a1697068c1"], "created_at": "2025-12-15T00:45:39.050417Z", "interfaces": [{"id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73", "name": "Internet", "subnet_id": "8ed74f78-2312-49cf-bd36-97586496a846", "ip_address": "203.0.113.83", "mac_address": null}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.066566Z", "description": null, "virtualization": null}, {"id": "72b41d46-8330-4d98-a15c-22bab353a159", "name": "Mobile Device", "tags": [], "ports": [{"id": "fe00f445-5d96-4f8f-a9d7-89685d3dd25e", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "15ce3064-1819-4a68-9546-ace102b855ea"}, "hostname": null, "services": ["81609369-372b-4642-9b51-c1d365790e64"], "created_at": "2025-12-15T00:45:39.050422Z", "interfaces": [{"id": "dcde8407-cb1d-4806-b458-b8be4788a2fd", "name": "Remote Network", "subnet_id": "231259d4-cc8d-4ea2-9780-7e712a86485a", "ip_address": "203.0.113.22", "mac_address": null}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.070698Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "9c429c16-08ec-4cba-9afc-127183eff463", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "b7400d43-3ff1-4ee1-ac26-41aa332218dd", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:45:39.205561871Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}, "target": {"type": "None"}, "hostname": "e9b61c39413b", "services": ["e316cd4f-d14c-4af7-8e5d-670933673aa4"], "created_at": "2025-12-15T00:45:39.087025Z", "interfaces": [{"id": "d1f6c138-a1f2-47db-bcb3-b0fd358de259", "name": "eth0", "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.4", "mac_address": "02:1E:6E:E7:83:DE"}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.216945Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "7c466557-f676-4b3c-89ee-f1a4f9e8a3d0", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "cc918211-8d62-4167-910f-c689778da991", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:10.557121065Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["c2f52c2d-802a-4036-baed-23e6ffd59a22"], "created_at": "2025-12-15T00:46:10.557124Z", "interfaces": [{"id": "fc121b0f-481c-4655-ae72-78b804f9074b", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.3", "mac_address": "F6:14:3E:05:6F:54"}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:25.733448Z", "description": null, "virtualization": null}, {"id": "2e981439-b3a5-4993-9d99-fdb3b3245c5c", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "053aff53-6a20-4452-a333-ca89d769d52d", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "07fafe30-3438-401c-94b1-c08c4bc5a5e2", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:25.831939720Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["6c4b7847-eceb-4883-8e06-a52f3ef6162d", "c85adf07-ff74-4409-874a-a0e33ce282a2"], "created_at": "2025-12-15T00:46:25.831943Z", "interfaces": [{"id": "afcd92cc-22f6-4508-b73f-c76f242f8c87", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.5", "mac_address": "F2:11:62:C2:6D:2B"}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:55.962989Z", "description": null, "virtualization": null}, {"id": "2b85ed12-948a-465d-a497-e3fd4bf5c123", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "aa377adb-39ff-42fc-a09a-1b0bea17a5ae", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:46:40.897149333Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["e16ed5a6-9252-488f-b580-6e2f4ac39afa"], "created_at": "2025-12-15T00:46:40.897150Z", "interfaces": [{"id": "f8ff098e-8d1e-43ae-bbd9-16d7ed7f2759", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.6", "mac_address": "66:B7:DD:43:6C:00"}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:55.963632Z", "description": null, "virtualization": null}, {"id": "8ed9d655-55d5-43cc-9529-6699ba721be0", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "aea3a06a-6264-4692-ba20-d2ca362a3821", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6bc06d75-3154-4091-af3a-9f396658db5e", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "d179e4ef-6adb-4a79-86fe-ebe741c6a407", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "94d44b62-d823-4370-b323-dc7dc012b2d2", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:47:04.007286337Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["899215d2-e1fd-4a03-a2f7-ab303ccc91d2", "df053cf8-b196-4733-866f-908aca5f9a38", "cc26581e-12dc-42c0-83db-2795f4023637", "cbdc891e-4039-4605-af3b-6352966b6834"], "created_at": "2025-12-15T00:47:04.007290Z", "interfaces": [{"id": "9e7ea623-1c6f-4da6-a049-79ce314e9209", "name": null, "subnet_id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "ip_address": "172.25.0.1", "mac_address": "2E:71:70:D0:F1:60"}], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:19.481780Z", "description": null, "virtualization": null}, {"id": "4d07eab3-674c-48eb-bf66-e03bc66e006c", "name": "Service Test Host", "tags": [], "ports": [], "hidden": false, "source": {"type": "System"}, "target": {"type": "Hostname"}, "hostname": "service-test.local", "services": [], "created_at": "2025-12-15T00:47:20.193278Z", "interfaces": [], "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:20.205297Z", "description": null, "virtualization": null}]	[{"id": "8ed74f78-2312-49cf-bd36-97586496a846", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T00:45:39.050345Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.050345Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "231259d4-cc8d-4ea2-9780-7e712a86485a", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T00:45:39.050349Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.050349Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "a50c6678-0ab2-4c73-9008-5b825faaaa89", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T00:45:39.184008600Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}, "created_at": "2025-12-15T00:45:39.184009Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.184009Z", "description": null, "subnet_type": "Lan"}]	[{"id": "02884e9a-dcd1-494b-9149-ffeb0f1ec899", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "bfefdde0-546c-493d-836b-c2117dfbaee3", "bindings": [{"id": "382e4874-c0c5-4995-b7f2-ea08a9f19d5f", "type": "Port", "port_id": "ea9fce1e-7487-4b27-a403-0a1a36f70f8e", "interface_id": "0bcc9c5e-bbc2-490c-a002-bb6190f91f9a"}], "created_at": "2025-12-15T00:45:39.050412Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.050412Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "95c3eb90-8f79-41a4-9e40-d2a1697068c1", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "b8252a1e-3a9f-4074-a68d-09c58da83919", "bindings": [{"id": "7a085c0b-2ba3-4e02-9b04-24a6a3f70a0a", "type": "Port", "port_id": "2c45f820-27c7-42e0-81d9-acce18e2c258", "interface_id": "d80fea9c-dcea-4bb6-9bcc-454f06c74a73"}], "created_at": "2025-12-15T00:45:39.050418Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.050418Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "81609369-372b-4642-9b51-c1d365790e64", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "72b41d46-8330-4d98-a15c-22bab353a159", "bindings": [{"id": "15ce3064-1819-4a68-9546-ace102b855ea", "type": "Port", "port_id": "fe00f445-5d96-4f8f-a9d7-89685d3dd25e", "interface_id": "dcde8407-cb1d-4806-b458-b8be4788a2fd"}], "created_at": "2025-12-15T00:45:39.050423Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.050423Z", "virtualization": null, "service_definition": "Client"}, {"id": "e316cd4f-d14c-4af7-8e5d-670933673aa4", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T00:45:39.205583952Z", "type": "SelfReport", "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e"}]}, "host_id": "9c429c16-08ec-4cba-9afc-127183eff463", "bindings": [{"id": "a1a44a8b-1d2a-4ef3-a138-e2e7a41cd3f2", "type": "Port", "port_id": "b7400d43-3ff1-4ee1-ac26-41aa332218dd", "interface_id": "d1f6c138-a1f2-47db-bcb3-b0fd358de259"}], "created_at": "2025-12-15T00:45:39.205584Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:45:39.205584Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "c2f52c2d-802a-4036-baed-23e6ffd59a22", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:46:19.735346790Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "7c466557-f676-4b3c-89ee-f1a4f9e8a3d0", "bindings": [{"id": "0132a0f2-11d0-4e71-8809-e0c57ec6019b", "type": "Port", "port_id": "cc918211-8d62-4167-910f-c689778da991", "interface_id": "fc121b0f-481c-4655-ae72-78b804f9074b"}], "created_at": "2025-12-15T00:46:19.735365Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:19.735365Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "6c4b7847-eceb-4883-8e06-a52f3ef6162d", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:46:34.845198474Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2e981439-b3a5-4993-9d99-fdb3b3245c5c", "bindings": [{"id": "d7254637-5d2c-46d4-bec1-8a057e9b2a41", "type": "Port", "port_id": "053aff53-6a20-4452-a333-ca89d769d52d", "interface_id": "afcd92cc-22f6-4508-b73f-c76f242f8c87"}], "created_at": "2025-12-15T00:46:34.845217Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:34.845217Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "c85adf07-ff74-4409-874a-a0e33ce282a2", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:46:40.896535540Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2e981439-b3a5-4993-9d99-fdb3b3245c5c", "bindings": [{"id": "8126152b-3f4a-4d04-985f-b5abb1f0adc5", "type": "Port", "port_id": "07fafe30-3438-401c-94b1-c08c4bc5a5e2", "interface_id": "afcd92cc-22f6-4508-b73f-c76f242f8c87"}], "created_at": "2025-12-15T00:46:40.896555Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:40.896555Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "e16ed5a6-9252-488f-b580-6e2f4ac39afa", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:46:55.945573392Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2b85ed12-948a-465d-a497-e3fd4bf5c123", "bindings": [{"id": "e21e868c-1124-4ee3-9c29-4833ea1981ed", "type": "Port", "port_id": "aa377adb-39ff-42fc-a09a-1b0bea17a5ae", "interface_id": "f8ff098e-8d1e-43ae-bbd9-16d7ed7f2759"}], "created_at": "2025-12-15T00:46:55.945591Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:46:55.945591Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "899215d2-e1fd-4a03-a2f7-ab303ccc91d2", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:47:13.302669860Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8ed9d655-55d5-43cc-9529-6699ba721be0", "bindings": [{"id": "0cc5efbf-dbf3-4662-b51e-ee1fb2d5b023", "type": "Port", "port_id": "aea3a06a-6264-4692-ba20-d2ca362a3821", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}], "created_at": "2025-12-15T00:47:13.302689Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:13.302689Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "df053cf8-b196-4733-866f-908aca5f9a38", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T00:47:13.303887024Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8ed9d655-55d5-43cc-9529-6699ba721be0", "bindings": [{"id": "1bf805ea-018b-4ab3-ad39-1c526584b8ce", "type": "Port", "port_id": "6bc06d75-3154-4091-af3a-9f396658db5e", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}], "created_at": "2025-12-15T00:47:13.303896Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:13.303896Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "cc26581e-12dc-42c0-83db-2795f4023637", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:47:19.464832163Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8ed9d655-55d5-43cc-9529-6699ba721be0", "bindings": [{"id": "89a74f74-e950-4a6c-b499-130492382fbc", "type": "Port", "port_id": "d179e4ef-6adb-4a79-86fe-ebe741c6a407", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}], "created_at": "2025-12-15T00:47:19.464849Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:19.464849Z", "virtualization": null, "service_definition": "SSH"}, {"id": "cbdc891e-4039-4605-af3b-6352966b6834", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T00:47:19.465006748Z", "type": "Network", "daemon_id": "ecdfb873-ded0-416b-bd55-2386f72cae1e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8ed9d655-55d5-43cc-9529-6699ba721be0", "bindings": [{"id": "90c43aa1-ce32-4ed6-b83d-d35dd177ee37", "type": "Port", "port_id": "94d44b62-d823-4370-b323-dc7dc012b2d2", "interface_id": "9e7ea623-1c6f-4da6-a049-79ce314e9209"}], "created_at": "2025-12-15T00:47:19.465014Z", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:19.465014Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "468de1a3-5fc7-4661-b6e9-2de7a237eda1", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T00:47:19.506851Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "d444fc95-154e-484d-90e7-ed8db1ccc897", "updated_at": "2025-12-15T00:47:19.506851Z", "description": null, "service_bindings": []}]	t	2025-12-15 00:45:39.074998+00	f	\N	\N	{d1f2f030-ed8a-4a9c-ad21-d19153fcffec,4d07eab3-674c-48eb-bf66-e03bc66e006c,31a0dd10-aba5-4760-b88c-29bc8671c53c}	{258e7491-c217-4e1f-b6d5-dbc486bad1c3}	{b45c5b7b-7938-4b64-a305-4d69824def9e}	{fde5046e-24b7-4d9c-a03d-a318e322a9f9}	\N	2025-12-15 00:45:39.071457+00	2025-12-15 00:47:21.225499+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
d2505d0f-8278-4a57-ba85-e1ee240febba	2025-12-15 00:45:39.045374+00	2025-12-15 00:45:39.045374+00	$argon2id$v=19$m=19456,t=2,p=1$puWhsB964BJ3kol6Yx0u3g$ztklgrkO18UmJmphtIky9P/wXN2PGWNITQwk99naRw4	\N	\N	\N	user@gmail.com	a605a7bb-8790-483a-8503-2cb3746d23f5	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
JbEexYQ0CjBscmpZMkcxLA	\\x93c4102c314732596a726c300a3484c51eb12581a7757365725f6964d92464323530356430662d383237382d346135372d626138352d65316565323430666562626199cd07ea0e002d27ce0b841308000000	2026-01-14 00:45:39.193205+00
1F_2vQIvUs2PvX1FQZNZXg	\\x93c4105e599341457dbd8fcd522f02bdf65fd482a7757365725f6964d92464323530356430662d383237382d346135372d626138352d653165653234306665626261ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92433393932613132312d636430372d346231652d623863322d666131646534346166636135ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea0e002f14ce04356073000000	2026-01-14 00:47:20.070606+00
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

\unrestrict HVnZYDxOb4aCnSkpoF7eTwnHTjtnMAIfTgu9m6x6opcyp9u61XqQgcqwbcxQ2Wh

