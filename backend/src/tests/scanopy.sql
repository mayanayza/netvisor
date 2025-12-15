--
-- PostgreSQL database dump
--

\restrict dkXhrOAiaa27al0GRUGTAqnWGjnfUnjpypEnM8PJfMmjpNHA3RR2YzcUohyW7aI

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
20251006215000	users	2025-12-15 03:50:05.419406+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3455316
20251006215100	networks	2025-12-15 03:50:05.423544+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3855460
20251006215151	create hosts	2025-12-15 03:50:05.427745+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3945319
20251006215155	create subnets	2025-12-15 03:50:05.432039+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3670114
20251006215201	create groups	2025-12-15 03:50:05.436069+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3887661
20251006215204	create daemons	2025-12-15 03:50:05.440361+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4227851
20251006215212	create services	2025-12-15 03:50:05.44495+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4981660
20251029193448	user-auth	2025-12-15 03:50:05.450283+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3518800
20251030044828	daemon api	2025-12-15 03:50:05.454183+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1642225
20251030170438	host-hide	2025-12-15 03:50:05.45611+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1116261
20251102224919	create discovery	2025-12-15 03:50:05.45753+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9576185
20251106235621	normalize-daemon-cols	2025-12-15 03:50:05.467463+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1797717
20251107034459	api keys	2025-12-15 03:50:05.469563+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7207858
20251107222650	oidc-auth	2025-12-15 03:50:05.477083+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21475108
20251110181948	orgs-billing	2025-12-15 03:50:05.498896+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11239408
20251113223656	group-enhancements	2025-12-15 03:50:05.510532+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1116541
20251117032720	daemon-mode	2025-12-15 03:50:05.511948+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1097326
20251118143058	set-default-plan	2025-12-15 03:50:05.513364+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1157678
20251118225043	save-topology	2025-12-15 03:50:05.51481+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8581551
20251123232748	network-permissions	2025-12-15 03:50:05.523708+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2640195
20251125001342	billing-updates	2025-12-15 03:50:05.526649+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	997478
20251128035448	org-onboarding-status	2025-12-15 03:50:05.527956+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1406895
20251129180942	nfs-consolidate	2025-12-15 03:50:05.529652+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1196962
20251206052641	discovery-progress	2025-12-15 03:50:05.531259+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1514407
20251206202200	plan-fix	2025-12-15 03:50:05.532945+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	896849
20251207061341	daemon-url	2025-12-15 03:50:05.534168+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2250514
20251210045929	tags	2025-12-15 03:50:05.536687+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8687780
20251210175035	terms	2025-12-15 03:50:05.545747+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	940441
20251213025048	hash-keys	2025-12-15 03:50:05.54698+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	6751264
20251214050638	scanopy	2025-12-15 03:50:05.554049+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1471696
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
5770dee9-c1ac-48a8-9f97-615c10bc632c	86cef752a7edb9b53c5f953e6868107c1be4cc9ea0378017a5ce95134039de89	ad8cdc6e-f118-4980-833c-4fdfc0702816	Integrated Daemon API Key	2025-12-15 03:50:08.754411+00	2025-12-15 03:51:44.702565+00	2025-12-15 03:51:44.701382+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
b75be14a-9432-4e15-aa32-90ccfcb3cee3	ad8cdc6e-f118-4980-833c-4fdfc0702816	2897e2f2-612f-4264-83b1-a734ceb3ab09	2025-12-15 03:50:08.855371+00	2025-12-15 03:51:24.482022+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["d46f9abe-91e5-48ec-a57a-e17503e39217"]}	2025-12-15 03:51:24.482657+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
2d537caf-1e4c-4b5d-b719-e8903007798a	ad8cdc6e-f118-4980-833c-4fdfc0702816	b75be14a-9432-4e15-aa32-90ccfcb3cee3	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09"}	Self Report	2025-12-15 03:50:08.864536+00	2025-12-15 03:50:08.864536+00	{}
a7ef999c-ca48-4196-8407-b1e71fdfba60	ad8cdc6e-f118-4980-833c-4fdfc0702816	b75be14a-9432-4e15-aa32-90ccfcb3cee3	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 03:50:08.87328+00	2025-12-15 03:50:08.87328+00	{}
59f78901-a26e-4f8a-9f8d-99fcfa4fcb7b	ad8cdc6e-f118-4980-833c-4fdfc0702816	b75be14a-9432-4e15-aa32-90ccfcb3cee3	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "session_id": "ccf6abdf-7ebc-4544-9540-0745119d26bb", "started_at": "2025-12-15T03:50:08.872854419Z", "finished_at": "2025-12-15T03:50:08.909470244Z", "discovery_type": {"type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09"}}}	{"type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09"}	Self Report	2025-12-15 03:50:08.872854+00	2025-12-15 03:50:08.91345+00	{}
e077fcca-7127-4f1d-8516-92a25617379c	ad8cdc6e-f118-4980-833c-4fdfc0702816	b75be14a-9432-4e15-aa32-90ccfcb3cee3	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "session_id": "4674af4c-7a86-4a12-9a33-10369009d471", "started_at": "2025-12-15T03:50:08.925600798Z", "finished_at": "2025-12-15T03:51:44.699357869Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 03:50:08.9256+00	2025-12-15 03:51:44.701643+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
eacf80ea-cdaf-4a3e-a292-725b7405afe1	ad8cdc6e-f118-4980-833c-4fdfc0702816		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 03:51:44.71529+00	2025-12-15 03:51:44.71529+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
9544b8dd-b71c-4261-87a2-1d8f315da72e	ad8cdc6e-f118-4980-833c-4fdfc0702816	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "aa587a88-b1bb-49a8-8f8b-5c98a03f9327"}	[{"id": "cea03fda-8708-4357-80bb-a9dbd24dc03a", "name": "Internet", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "ip_address": "1.1.1.1", "mac_address": null}]	{d5288e88-803d-450f-aa67-7cbbb8399623}	[{"id": "0ced7715-ede3-4d91-8902-b6e47c0bdd3f", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 03:50:08.728996+00	2025-12-15 03:50:08.738626+00	f	{}
8bbabc9f-7648-499d-bfe8-b4c48b716c18	ad8cdc6e-f118-4980-833c-4fdfc0702816	Google.com	\N	\N	{"type": "ServiceBinding", "config": "a863c59e-7f89-48c4-a6d5-b714d20d62ba"}	[{"id": "456a27df-7864-4ac1-a109-59bf4724c922", "name": "Internet", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "ip_address": "203.0.113.240", "mac_address": null}]	{4e94ad65-326b-4eb9-b216-f3a8ecc1bcf8}	[{"id": "3a42bdce-c879-41e4-ace3-978de55fe6c1", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 03:50:08.729005+00	2025-12-15 03:50:08.744099+00	f	{}
da7ef2f8-d564-4432-a1d4-37ca70c22f4c	ad8cdc6e-f118-4980-833c-4fdfc0702816	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "a6917afa-71ef-47f2-a478-c2abd2e83035"}	[{"id": "374e882a-c83d-4f37-b12d-7601070ef7ce", "name": "Remote Network", "subnet_id": "8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87", "ip_address": "203.0.113.126", "mac_address": null}]	{1a93d54b-5c63-4d4a-a5f3-5e8d4f735202}	[{"id": "3d9c0621-7964-497e-a52f-a7354c20e18e", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 03:50:08.729013+00	2025-12-15 03:50:08.747858+00	f	{}
88e180a4-f634-4076-8b48-1e7346b68196	ad8cdc6e-f118-4980-833c-4fdfc0702816	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "a9dec73b-6164-4b8e-ac07-1e2e5ada77f3", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.6", "mac_address": "F6:FE:0B:84:95:95"}]	{4886fda0-40c6-4e4e-955a-dd01c85e18b7}	[{"id": "28a9fafb-681b-451e-93ec-ef0b131bf82a", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:56.906428560Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 03:50:56.90643+00	2025-12-15 03:51:11.80715+00	f	{}
2897e2f2-612f-4264-83b1-a734ceb3ab09	ad8cdc6e-f118-4980-833c-4fdfc0702816	scanopy-daemon	ba350fc616e4	Scanopy daemon	{"type": "None"}	[{"id": "a10360f5-9df4-4314-b2e7-f0cc9d1efee3", "name": "eth0", "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.4", "mac_address": "16:72:64:E1:37:BE"}]	{0245446c-69c5-4ca6-8fc3-c11fd7efcf87}	[{"id": "c6d9a789-9511-4e70-a2b3-9116e75a3878", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:08.893749222Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}	null	2025-12-15 03:50:08.763111+00	2025-12-15 03:50:08.906252+00	f	{}
e4748db5-5c37-42b2-80d7-f5e6f1fad07f	ad8cdc6e-f118-4980-833c-4fdfc0702816	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "49aa8f63-ea73-41d9-9999-66baee3b705c", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.5", "mac_address": "22:29:76:A3:82:56"}]	{8fb0869e-a0d4-4dfe-8222-e18b28da61c3,dddc803f-c4ff-4b9f-8695-2993323dc263}	[{"id": "e53237df-558f-4b54-8a2d-fabff158371c", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9c42892d-a034-43ee-b38a-3077eb27f7e1", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:42.186345709Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 03:50:42.186348+00	2025-12-15 03:50:56.918349+00	f	{}
1b9ae55d-2b17-4717-995e-582f9bf1573f	ad8cdc6e-f118-4980-833c-4fdfc0702816	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "33cd5aba-a5bc-4bff-b221-851c145ae369", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.3", "mac_address": "2E:FF:43:23:AA:C6"}]	{ee8caf6b-6574-4e0a-a41d-f3a8618cd2e4}	[{"id": "a617299c-7f60-499f-938f-5647d21d1711", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:51:11.844250990Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 03:51:11.844252+00	2025-12-15 03:51:26.077278+00	f	{}
8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4	ad8cdc6e-f118-4980-833c-4fdfc0702816	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.1", "mac_address": "76:AD:E3:18:DA:CB"}]	{fa6f1fd5-d0d9-4bc0-aad7-5beb7d3c1916,df3a45d3-7c10-4c13-bf7f-e1d10efb061e,7e6ce411-7dd2-40d4-9dc4-403d5ca4173c,557a3c52-e654-467b-8825-97688851ea7d}	[{"id": "54c70055-8814-4664-9937-d591e3bcbf3f", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "53fcd64c-a25c-4520-bff4-50d1222182cb", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "2e66901d-ae59-4c7e-9d1b-a6525df5ad6f", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "c02d9f4e-896a-400d-9462-3bc2c6fed517", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:51:30.131989693Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 03:51:30.131992+00	2025-12-15 03:51:44.693604+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
ad8cdc6e-f118-4980-833c-4fdfc0702816	My Network	2025-12-15 03:50:08.727561+00	2025-12-15 03:50:08.727561+00	f	046c321e-d5e4-4bd0-b620-94894f100644	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
046c321e-d5e4-4bd0-b620-94894f100644	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 03:50:08.721527+00	2025-12-15 03:51:45.529872+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
d5288e88-803d-450f-aa67-7cbbb8399623	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.728998+00	2025-12-15 03:50:08.728998+00	Cloudflare DNS	9544b8dd-b71c-4261-87a2-1d8f315da72e	[{"id": "aa587a88-b1bb-49a8-8f8b-5c98a03f9327", "type": "Port", "port_id": "0ced7715-ede3-4d91-8902-b6e47c0bdd3f", "interface_id": "cea03fda-8708-4357-80bb-a9dbd24dc03a"}]	"Dns Server"	null	{"type": "System"}	{}
4e94ad65-326b-4eb9-b216-f3a8ecc1bcf8	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.729007+00	2025-12-15 03:50:08.729007+00	Google.com	8bbabc9f-7648-499d-bfe8-b4c48b716c18	[{"id": "a863c59e-7f89-48c4-a6d5-b714d20d62ba", "type": "Port", "port_id": "3a42bdce-c879-41e4-ace3-978de55fe6c1", "interface_id": "456a27df-7864-4ac1-a109-59bf4724c922"}]	"Web Service"	null	{"type": "System"}	{}
1a93d54b-5c63-4d4a-a5f3-5e8d4f735202	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.729015+00	2025-12-15 03:50:08.729015+00	Mobile Device	da7ef2f8-d564-4432-a1d4-37ca70c22f4c	[{"id": "a6917afa-71ef-47f2-a478-c2abd2e83035", "type": "Port", "port_id": "3d9c0621-7964-497e-a52f-a7354c20e18e", "interface_id": "374e882a-c83d-4f37-b12d-7601070ef7ce"}]	"Client"	null	{"type": "System"}	{}
0245446c-69c5-4ca6-8fc3-c11fd7efcf87	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.893764+00	2025-12-15 03:50:08.893764+00	Scanopy Daemon	2897e2f2-612f-4264-83b1-a734ceb3ab09	[{"id": "ec005ccf-7eaa-490c-9ba6-ac7d5e2bca03", "type": "Port", "port_id": "c6d9a789-9511-4e70-a2b3-9116e75a3878", "interface_id": "a10360f5-9df4-4314-b2e7-f0cc9d1efee3"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T03:50:08.893764050Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}	{}
8fb0869e-a0d4-4dfe-8222-e18b28da61c3	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:50.979498+00	2025-12-15 03:50:50.979498+00	Home Assistant	e4748db5-5c37-42b2-80d7-f5e6f1fad07f	[{"id": "807a4b8d-6f60-4d8f-9db4-924c75c3e6fa", "type": "Port", "port_id": "e53237df-558f-4b54-8a2d-fabff158371c", "interface_id": "49aa8f63-ea73-41d9-9999-66baee3b705c"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:50:50.979479428Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
dddc803f-c4ff-4b9f-8695-2993323dc263	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:56.904748+00	2025-12-15 03:50:56.904748+00	Unclaimed Open Ports	e4748db5-5c37-42b2-80d7-f5e6f1fad07f	[{"id": "3886eff1-bb6f-4e6b-b187-3f2353baf7d9", "type": "Port", "port_id": "9c42892d-a034-43ee-b38a-3077eb27f7e1", "interface_id": "49aa8f63-ea73-41d9-9999-66baee3b705c"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:50:56.904728920Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
4886fda0-40c6-4e4e-955a-dd01c85e18b7	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:11.793401+00	2025-12-15 03:51:11.793401+00	PostgreSQL	88e180a4-f634-4076-8b48-1e7346b68196	[{"id": "a7341365-0de7-4cf0-b6a8-5e88c68e8904", "type": "Port", "port_id": "28a9fafb-681b-451e-93ec-ef0b131bf82a", "interface_id": "a9dec73b-6164-4b8e-ac07-1e2e5ada77f3"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:11.793383971Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ee8caf6b-6574-4e0a-a41d-f3a8618cd2e4	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:20.450673+00	2025-12-15 03:51:20.450673+00	Scanopy Server	1b9ae55d-2b17-4717-995e-582f9bf1573f	[{"id": "4a4f111b-e8e5-4f41-ba63-90cbe9f7da78", "type": "Port", "port_id": "a617299c-7f60-499f-938f-5647d21d1711", "interface_id": "33cd5aba-a5bc-4bff-b221-851c145ae369"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:20.450657986Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7e6ce411-7dd2-40d4-9dc4-403d5ca4173c	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:44.677756+00	2025-12-15 03:51:44.677756+00	SSH	8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4	[{"id": "503b410e-cd89-4174-bfbf-9b31ab342e51", "type": "Port", "port_id": "2e66901d-ae59-4c7e-9d1b-a6525df5ad6f", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:44.677738376Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
557a3c52-e654-467b-8825-97688851ea7d	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:44.67794+00	2025-12-15 03:51:44.67794+00	Unclaimed Open Ports	8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4	[{"id": "0a639f34-c5a9-4758-9fe8-0a71c072b7e9", "type": "Port", "port_id": "c02d9f4e-896a-400d-9462-3bc2c6fed517", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:44.677931157Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
fa6f1fd5-d0d9-4bc0-aad7-5beb7d3c1916	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:38.744437+00	2025-12-15 03:51:38.744437+00	Home Assistant	8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4	[{"id": "d4487df2-2bf4-460f-9726-255d8aaf46a6", "type": "Port", "port_id": "54c70055-8814-4664-9937-d591e3bcbf3f", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:38.744420145Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
df3a45d3-7c10-4c13-bf7f-e1d10efb061e	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:51:38.745659+00	2025-12-15 03:51:38.745659+00	Scanopy Server	8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4	[{"id": "e6713694-bacb-4dfc-9cc3-8181f6e3db8e", "type": "Port", "port_id": "53fcd64c-a25c-4520-bff4-50d1222182cb", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:38.745649828Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
14ddf04a-1847-48e4-85c0-b9f5e9299608	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.728939+00	2025-12-15 03:50:08.728939+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.728943+00	2025-12-15 03:50:08.728943+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
d46f9abe-91e5-48ec-a57a-e17503e39217	ad8cdc6e-f118-4980-833c-4fdfc0702816	2025-12-15 03:50:08.873013+00	2025-12-15 03:50:08.873013+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:08.873011713Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
c3446406-549c-405e-85d0-c6bdf548ed68	046c321e-d5e4-4bd0-b620-94894f100644	New Tag	\N	2025-12-15 03:51:44.72502+00	2025-12-15 03:51:44.72502+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
3a9e0127-74ad-4652-acee-67f79ae4e5d7	ad8cdc6e-f118-4980-833c-4fdfc0702816	My Topology	[]	[{"id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "cea03fda-8708-4357-80bb-a9dbd24dc03a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "9544b8dd-b71c-4261-87a2-1d8f315da72e", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "interface_id": "cea03fda-8708-4357-80bb-a9dbd24dc03a"}, {"id": "456a27df-7864-4ac1-a109-59bf4724c922", "size": {"x": 250, "y": 100}, "header": null, "host_id": "8bbabc9f-7648-499d-bfe8-b4c48b716c18", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "interface_id": "456a27df-7864-4ac1-a109-59bf4724c922"}, {"id": "374e882a-c83d-4f37-b12d-7601070ef7ce", "size": {"x": 250, "y": 100}, "header": null, "host_id": "da7ef2f8-d564-4432-a1d4-37ca70c22f4c", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87", "interface_id": "374e882a-c83d-4f37-b12d-7601070ef7ce"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "9544b8dd-b71c-4261-87a2-1d8f315da72e", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "0ced7715-ede3-4d91-8902-b6e47c0bdd3f", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "aa587a88-b1bb-49a8-8f8b-5c98a03f9327"}, "hostname": null, "services": ["d5288e88-803d-450f-aa67-7cbbb8399623"], "created_at": "2025-12-15T03:50:08.728996Z", "interfaces": [{"id": "cea03fda-8708-4357-80bb-a9dbd24dc03a", "name": "Internet", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.738626Z", "description": null, "virtualization": null}, {"id": "8bbabc9f-7648-499d-bfe8-b4c48b716c18", "name": "Google.com", "tags": [], "ports": [{"id": "3a42bdce-c879-41e4-ace3-978de55fe6c1", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "a863c59e-7f89-48c4-a6d5-b714d20d62ba"}, "hostname": null, "services": ["4e94ad65-326b-4eb9-b216-f3a8ecc1bcf8"], "created_at": "2025-12-15T03:50:08.729005Z", "interfaces": [{"id": "456a27df-7864-4ac1-a109-59bf4724c922", "name": "Internet", "subnet_id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "ip_address": "203.0.113.240", "mac_address": null}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.744099Z", "description": null, "virtualization": null}, {"id": "da7ef2f8-d564-4432-a1d4-37ca70c22f4c", "name": "Mobile Device", "tags": [], "ports": [{"id": "3d9c0621-7964-497e-a52f-a7354c20e18e", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "a6917afa-71ef-47f2-a478-c2abd2e83035"}, "hostname": null, "services": ["1a93d54b-5c63-4d4a-a5f3-5e8d4f735202"], "created_at": "2025-12-15T03:50:08.729013Z", "interfaces": [{"id": "374e882a-c83d-4f37-b12d-7601070ef7ce", "name": "Remote Network", "subnet_id": "8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87", "ip_address": "203.0.113.126", "mac_address": null}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.747858Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "c6d9a789-9511-4e70-a2b3-9116e75a3878", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:08.893749222Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}, "target": {"type": "None"}, "hostname": "ba350fc616e4", "services": ["0245446c-69c5-4ca6-8fc3-c11fd7efcf87"], "created_at": "2025-12-15T03:50:08.763111Z", "interfaces": [{"id": "a10360f5-9df4-4314-b2e7-f0cc9d1efee3", "name": "eth0", "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.4", "mac_address": "16:72:64:E1:37:BE"}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.906252Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "e4748db5-5c37-42b2-80d7-f5e6f1fad07f", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "e53237df-558f-4b54-8a2d-fabff158371c", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9c42892d-a034-43ee-b38a-3077eb27f7e1", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:42.186345709Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["8fb0869e-a0d4-4dfe-8222-e18b28da61c3", "dddc803f-c4ff-4b9f-8695-2993323dc263"], "created_at": "2025-12-15T03:50:42.186348Z", "interfaces": [{"id": "49aa8f63-ea73-41d9-9999-66baee3b705c", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.5", "mac_address": "22:29:76:A3:82:56"}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:56.918349Z", "description": null, "virtualization": null}, {"id": "88e180a4-f634-4076-8b48-1e7346b68196", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "28a9fafb-681b-451e-93ec-ef0b131bf82a", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:56.906428560Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["4886fda0-40c6-4e4e-955a-dd01c85e18b7"], "created_at": "2025-12-15T03:50:56.906430Z", "interfaces": [{"id": "a9dec73b-6164-4b8e-ac07-1e2e5ada77f3", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.6", "mac_address": "F6:FE:0B:84:95:95"}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:11.807150Z", "description": null, "virtualization": null}, {"id": "1b9ae55d-2b17-4717-995e-582f9bf1573f", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "a617299c-7f60-499f-938f-5647d21d1711", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:51:11.844250990Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["ee8caf6b-6574-4e0a-a41d-f3a8618cd2e4"], "created_at": "2025-12-15T03:51:11.844252Z", "interfaces": [{"id": "33cd5aba-a5bc-4bff-b221-851c145ae369", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.3", "mac_address": "2E:FF:43:23:AA:C6"}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:26.077278Z", "description": null, "virtualization": null}, {"id": "8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "54c70055-8814-4664-9937-d591e3bcbf3f", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "53fcd64c-a25c-4520-bff4-50d1222182cb", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "2e66901d-ae59-4c7e-9d1b-a6525df5ad6f", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "c02d9f4e-896a-400d-9462-3bc2c6fed517", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:51:30.131989693Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["fa6f1fd5-d0d9-4bc0-aad7-5beb7d3c1916", "df3a45d3-7c10-4c13-bf7f-e1d10efb061e", "7e6ce411-7dd2-40d4-9dc4-403d5ca4173c", "557a3c52-e654-467b-8825-97688851ea7d"], "created_at": "2025-12-15T03:51:30.131992Z", "interfaces": [{"id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc", "name": null, "subnet_id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "ip_address": "172.25.0.1", "mac_address": "76:AD:E3:18:DA:CB"}], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:44.693604Z", "description": null, "virtualization": null}, {"id": "519daf7c-c5eb-41fe-927a-d613692ac3b4", "name": "Service Test Host", "tags": [], "ports": [], "hidden": false, "source": {"type": "System"}, "target": {"type": "Hostname"}, "hostname": "service-test.local", "services": [], "created_at": "2025-12-15T03:51:45.389449Z", "interfaces": [], "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:45.397208Z", "description": null, "virtualization": null}]	[{"id": "14ddf04a-1847-48e4-85c0-b9f5e9299608", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T03:50:08.728939Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.728939Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "8d994dc3-6ced-4d1e-b415-2d9e2f7f1f87", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T03:50:08.728943Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.728943Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "d46f9abe-91e5-48ec-a57a-e17503e39217", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T03:50:08.873011713Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}, "created_at": "2025-12-15T03:50:08.873013Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.873013Z", "description": null, "subnet_type": "Lan"}]	[{"id": "d5288e88-803d-450f-aa67-7cbbb8399623", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "9544b8dd-b71c-4261-87a2-1d8f315da72e", "bindings": [{"id": "aa587a88-b1bb-49a8-8f8b-5c98a03f9327", "type": "Port", "port_id": "0ced7715-ede3-4d91-8902-b6e47c0bdd3f", "interface_id": "cea03fda-8708-4357-80bb-a9dbd24dc03a"}], "created_at": "2025-12-15T03:50:08.728998Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.728998Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "4e94ad65-326b-4eb9-b216-f3a8ecc1bcf8", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "8bbabc9f-7648-499d-bfe8-b4c48b716c18", "bindings": [{"id": "a863c59e-7f89-48c4-a6d5-b714d20d62ba", "type": "Port", "port_id": "3a42bdce-c879-41e4-ace3-978de55fe6c1", "interface_id": "456a27df-7864-4ac1-a109-59bf4724c922"}], "created_at": "2025-12-15T03:50:08.729007Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.729007Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "1a93d54b-5c63-4d4a-a5f3-5e8d4f735202", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "da7ef2f8-d564-4432-a1d4-37ca70c22f4c", "bindings": [{"id": "a6917afa-71ef-47f2-a478-c2abd2e83035", "type": "Port", "port_id": "3d9c0621-7964-497e-a52f-a7354c20e18e", "interface_id": "374e882a-c83d-4f37-b12d-7601070ef7ce"}], "created_at": "2025-12-15T03:50:08.729015Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.729015Z", "virtualization": null, "service_definition": "Client"}, {"id": "0245446c-69c5-4ca6-8fc3-c11fd7efcf87", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T03:50:08.893764050Z", "type": "SelfReport", "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3"}]}, "host_id": "2897e2f2-612f-4264-83b1-a734ceb3ab09", "bindings": [{"id": "ec005ccf-7eaa-490c-9ba6-ac7d5e2bca03", "type": "Port", "port_id": "c6d9a789-9511-4e70-a2b3-9116e75a3878", "interface_id": "a10360f5-9df4-4314-b2e7-f0cc9d1efee3"}], "created_at": "2025-12-15T03:50:08.893764Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:08.893764Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "8fb0869e-a0d4-4dfe-8222-e18b28da61c3", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:50:50.979479428Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e4748db5-5c37-42b2-80d7-f5e6f1fad07f", "bindings": [{"id": "807a4b8d-6f60-4d8f-9db4-924c75c3e6fa", "type": "Port", "port_id": "e53237df-558f-4b54-8a2d-fabff158371c", "interface_id": "49aa8f63-ea73-41d9-9999-66baee3b705c"}], "created_at": "2025-12-15T03:50:50.979498Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:50.979498Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "dddc803f-c4ff-4b9f-8695-2993323dc263", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:50:56.904728920Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e4748db5-5c37-42b2-80d7-f5e6f1fad07f", "bindings": [{"id": "3886eff1-bb6f-4e6b-b187-3f2353baf7d9", "type": "Port", "port_id": "9c42892d-a034-43ee-b38a-3077eb27f7e1", "interface_id": "49aa8f63-ea73-41d9-9999-66baee3b705c"}], "created_at": "2025-12-15T03:50:56.904748Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:50:56.904748Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "4886fda0-40c6-4e4e-955a-dd01c85e18b7", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:11.793383971Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "88e180a4-f634-4076-8b48-1e7346b68196", "bindings": [{"id": "a7341365-0de7-4cf0-b6a8-5e88c68e8904", "type": "Port", "port_id": "28a9fafb-681b-451e-93ec-ef0b131bf82a", "interface_id": "a9dec73b-6164-4b8e-ac07-1e2e5ada77f3"}], "created_at": "2025-12-15T03:51:11.793401Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:11.793401Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "ee8caf6b-6574-4e0a-a41d-f3a8618cd2e4", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:20.450657986Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1b9ae55d-2b17-4717-995e-582f9bf1573f", "bindings": [{"id": "4a4f111b-e8e5-4f41-ba63-90cbe9f7da78", "type": "Port", "port_id": "a617299c-7f60-499f-938f-5647d21d1711", "interface_id": "33cd5aba-a5bc-4bff-b221-851c145ae369"}], "created_at": "2025-12-15T03:51:20.450673Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:20.450673Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "fa6f1fd5-d0d9-4bc0-aad7-5beb7d3c1916", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:38.744420145Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4", "bindings": [{"id": "d4487df2-2bf4-460f-9726-255d8aaf46a6", "type": "Port", "port_id": "54c70055-8814-4664-9937-d591e3bcbf3f", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}], "created_at": "2025-12-15T03:51:38.744437Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:38.744437Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "df3a45d3-7c10-4c13-bf7f-e1d10efb061e", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T03:51:38.745649828Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4", "bindings": [{"id": "e6713694-bacb-4dfc-9cc3-8181f6e3db8e", "type": "Port", "port_id": "53fcd64c-a25c-4520-bff4-50d1222182cb", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}], "created_at": "2025-12-15T03:51:38.745659Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:38.745659Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "7e6ce411-7dd2-40d4-9dc4-403d5ca4173c", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:44.677738376Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4", "bindings": [{"id": "503b410e-cd89-4174-bfbf-9b31ab342e51", "type": "Port", "port_id": "2e66901d-ae59-4c7e-9d1b-a6525df5ad6f", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}], "created_at": "2025-12-15T03:51:44.677756Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:44.677756Z", "virtualization": null, "service_definition": "SSH"}, {"id": "557a3c52-e654-467b-8825-97688851ea7d", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T03:51:44.677931157Z", "type": "Network", "daemon_id": "b75be14a-9432-4e15-aa32-90ccfcb3cee3", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8dc4640c-8bc5-4f6a-9475-0bd84a46d6c4", "bindings": [{"id": "0a639f34-c5a9-4758-9fe8-0a71c072b7e9", "type": "Port", "port_id": "c02d9f4e-896a-400d-9462-3bc2c6fed517", "interface_id": "4a1e1adc-66ab-4f3c-b667-bd7b266b19fc"}], "created_at": "2025-12-15T03:51:44.677940Z", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:44.677940Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "eacf80ea-cdaf-4a3e-a292-725b7405afe1", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T03:51:44.715290Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "ad8cdc6e-f118-4980-833c-4fdfc0702816", "updated_at": "2025-12-15T03:51:44.715290Z", "description": null, "service_bindings": []}]	t	2025-12-15 03:50:08.751977+00	f	\N	\N	{9f15c310-5f8c-448a-a066-be8a8c1c536b,519daf7c-c5eb-41fe-927a-d613692ac3b4,a6606539-4e95-47a3-872b-8e4531195f3d}	{0e3b51d4-9346-439a-8d31-6e9862e1d79b}	{844c0345-b56d-4aa8-a692-58612be14fc7}	{b9134297-17b1-4513-9b40-79ced61d2222}	\N	2025-12-15 03:50:08.748649+00	2025-12-15 03:51:46.418975+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
58bc53b3-783f-47d8-a7ea-09e2a40cf088	2025-12-15 03:50:08.724422+00	2025-12-15 03:50:08.724422+00	$argon2id$v=19$m=19456,t=2,p=1$bH6tU9vZTDPr+ZFdcy1q7A$IalmsJmBfznl9MpP8OUHwA/M/zYWCJ4aYjBwubVzIMA	\N	\N	\N	user@gmail.com	046c321e-d5e4-4bd0-b620-94894f100644	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
jlyQIVdF0eVHWQ9J1hf-Sg	\\x93c4104afe17d6490f5947e5d1455721905c8e81a7757365725f6964d92435386263353362332d373833662d343764382d613765612d30396532613430636630383899cd07ea0e033208ce348c27d6000000	2026-01-14 03:50:08.8816+00
2tT5EaIctzoWBId2q3-zFg	\\x93c41016b37fab768704163ab71ca211f9d4da82ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92463353738306365632d383561642d343765392d386566622d346566336565653866633864ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92435386263353362332d373833662d343764382d613765612d30396532613430636630383899cd07ea0e03332dce10608b69000000	2026-01-14 03:51:45.274762+00
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

\unrestrict dkXhrOAiaa27al0GRUGTAqnWGjnfUnjpypEnM8PJfMmjpNHA3RR2YzcUohyW7aI

