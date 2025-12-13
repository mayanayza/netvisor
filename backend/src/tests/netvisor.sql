--
-- PostgreSQL database dump
--

\restrict epf1WdOYiJla5JbEVsZERMy884PhVF7i9hhMvYGUkrTWq2NF0JIPXY6EhyeZoIR

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
20251006215000	users	2025-12-13 17:04:18.325889+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3751331
20251006215100	networks	2025-12-13 17:04:18.330677+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4849280
20251006215151	create hosts	2025-12-13 17:04:18.335936+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3827403
20251006215155	create subnets	2025-12-13 17:04:18.340148+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3657486
20251006215201	create groups	2025-12-13 17:04:18.344251+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3863640
20251006215204	create daemons	2025-12-13 17:04:18.348451+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4304392
20251006215212	create services	2025-12-13 17:04:18.353181+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4787315
20251029193448	user-auth	2025-12-13 17:04:18.358437+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6454615
20251030044828	daemon api	2025-12-13 17:04:18.365176+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1469703
20251030170438	host-hide	2025-12-13 17:04:18.366936+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1136891
20251102224919	create discovery	2025-12-13 17:04:18.368528+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11200082
20251106235621	normalize-daemon-cols	2025-12-13 17:04:18.380197+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1789469
20251107034459	api keys	2025-12-13 17:04:18.382605+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8453776
20251107222650	oidc-auth	2025-12-13 17:04:18.391417+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28710944
20251110181948	orgs-billing	2025-12-13 17:04:18.420546+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11324103
20251113223656	group-enhancements	2025-12-13 17:04:18.432281+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	10302407
20251117032720	daemon-mode	2025-12-13 17:04:18.443057+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1126455
20251118143058	set-default-plan	2025-12-13 17:04:18.444537+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1148670
20251118225043	save-topology	2025-12-13 17:04:18.44601+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8992232
20251123232748	network-permissions	2025-12-13 17:04:18.455338+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2720118
20251125001342	billing-updates	2025-12-13 17:04:18.458389+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	962890
20251128035448	org-onboarding-status	2025-12-13 17:04:18.459659+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1446805
20251129180942	nfs-consolidate	2025-12-13 17:04:18.461397+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1207149
20251206052641	discovery-progress	2025-12-13 17:04:18.462901+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1608891
20251206202200	plan-fix	2025-12-13 17:04:18.464809+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	940862
20251207061341	daemon-url	2025-12-13 17:04:18.466065+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2367532
20251210045929	tags	2025-12-13 17:04:18.468797+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8879718
20251210175035	terms	2025-12-13 17:04:18.478081+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	1186448
20251213025048	hash-keys	2025-12-13 17:04:18.479637+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	11429080
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
12034f98-6b91-4bac-bfab-e3ded5fd0656	6be04354560d66c09f08752d17902f952ba0eefbee5834b363c909277b329613	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	Integrated Daemon API Key	2025-12-13 17:04:21.400894+00	2025-12-13 17:05:51.044903+00	2025-12-13 17:05:51.044035+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
98462fcd-365e-4258-a390-ead468af9ce2	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	009bee10-1d53-454e-a585-162b111c092e	2025-12-13 17:04:21.448245+00	2025-12-13 17:05:39.022416+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["e6471f95-e84c-4499-b643-65f39e27da00"]}	2025-12-13 17:05:39.024175+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
e139e080-2662-4dcd-8ef5-4dbeb65e8a2c	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	98462fcd-365e-4258-a390-ead468af9ce2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e"}	Self Report	2025-12-13 17:04:21.45525+00	2025-12-13 17:04:21.45525+00	{}
0f65c103-edd7-40a8-a27c-49c0dc702805	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	98462fcd-365e-4258-a390-ead468af9ce2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 17:04:21.461552+00	2025-12-13 17:04:21.461552+00	{}
d030415b-6764-4f93-a9bd-71c4f7a755b4	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	98462fcd-365e-4258-a390-ead468af9ce2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "session_id": "854a804e-59ea-48e6-a18c-b995f34b2e11", "started_at": "2025-12-13T17:04:21.461169032Z", "finished_at": "2025-12-13T17:04:21.600970435Z", "discovery_type": {"type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e"}}}	{"type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e"}	Self Report	2025-12-13 17:04:21.461169+00	2025-12-13 17:04:21.606984+00	{}
542a9e38-0525-42a4-9f40-28d82bd2284f	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	98462fcd-365e-4258-a390-ead468af9ce2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "session_id": "23a49b7b-555a-4ef8-b2ac-14f6546b685d", "started_at": "2025-12-13T17:04:21.625371755Z", "finished_at": "2025-12-13T17:05:51.040768935Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 17:04:21.625371+00	2025-12-13 17:05:51.044289+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
1dcfdc84-68a7-424f-9005-59c04a3de1d0	98894ef8-ae71-4222-b5ec-ea9f0359ea0d		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 17:05:51.056331+00	2025-12-13 17:05:51.056331+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
0b789234-1385-4b07-a7ec-a1ace8c2dae1	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "fba1f609-584b-4c0e-b1fe-499b8426ef6a"}	[{"id": "3187d329-530a-4f06-acbf-0be58173f4d6", "name": "Internet", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "ip_address": "1.1.1.1", "mac_address": null}]	{0facc54f-b0fe-47e6-ba94-a4a31c14bfa2}	[{"id": "5baa8daa-1573-4361-a124-b64eec499161", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 17:04:21.328865+00	2025-12-13 17:04:21.338971+00	f	{}
a3ec1efb-3bcb-413a-b486-5ebc40da5d1c	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "8f695bcd-72d7-4d5f-baa7-28b2ef9d8ea7"}	[{"id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa", "name": "Internet", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "ip_address": "203.0.113.85", "mac_address": null}]	{550dd927-6e95-432e-8acf-f7a2e853ec9a}	[{"id": "e94826e3-7999-4703-8890-e3f5031f7b0f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 17:04:21.328871+00	2025-12-13 17:04:21.387262+00	f	{}
527fb5eb-bacd-4200-8739-0cac16e99f8f	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "c2c587dc-64f3-4aad-8f2d-b2e512ff73a1"}	[{"id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316", "name": "Remote Network", "subnet_id": "3e4f2d96-886a-4176-8bf7-f4ca5c62bf05", "ip_address": "203.0.113.198", "mac_address": null}]	{197fb617-d13b-4ca4-94da-9c59346c9bca}	[{"id": "b626cbcc-9735-4a70-b181-9fe103c85de1", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 17:04:21.328876+00	2025-12-13 17:04:21.393063+00	f	{}
c1b31d3a-cf34-4108-8305-173c71b532f3	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "4acd5b92-27ab-4af5-a119-d9947248613c", "name": null, "subnet_id": "e6471f95-e84c-4499-b643-65f39e27da00", "ip_address": "172.25.0.3", "mac_address": "1E:6A:46:AC:27:CB"}]	{69ec9cd6-892f-428a-ad18-1ed9c9e832c1}	[{"id": "53c520cf-0d9e-442d-8246-a8dbabf23c23", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:05:01.641602920Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 17:05:01.641605+00	2025-12-13 17:05:16.134417+00	f	{}
009bee10-1d53-454e-a585-162b111c092e	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	netvisor-daemon	cfbc5cea586c	NetVisor daemon	{"type": "None"}	[{"id": "6e7f303e-ea3b-4a44-8cb2-d392f1b53515", "name": "eth0", "subnet_id": "e6471f95-e84c-4499-b643-65f39e27da00", "ip_address": "172.25.0.4", "mac_address": "EA:1D:EA:23:DA:61"}]	{eccbc4b4-8bc8-43d4-9280-f6a962adbeb0}	[{"id": "90061d79-0f26-404c-9ced-e1775fb2df87", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:04:21.571185284Z", "type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2"}]}	null	2025-12-13 17:04:21.410301+00	2025-12-13 17:04:21.598186+00	f	{}
b4d225c9-c128-4f53-a765-f02b27b2a63b	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "9fad56f4-74f4-4084-b5f1-d1480988ef81", "name": null, "subnet_id": "e6471f95-e84c-4499-b643-65f39e27da00", "ip_address": "172.25.0.5", "mac_address": "DA:79:2E:4A:48:26"}]	{f7071c01-5fd8-40ed-b195-86c9721f74c9,932ff511-9db7-4a15-82c3-3f5513b0dd51}	[{"id": "366f5d93-8ce4-48bf-8452-4021bc7445a8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "436fafd5-4d93-49a2-96ce-6c64b6bc89cc", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:04:46.980239121Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 17:04:46.980241+00	2025-12-13 17:05:01.559451+00	f	{}
e482ca0a-6b50-486b-9593-97193eb3d860	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "7368e075-1997-459e-80bf-032f68cae8d8", "name": null, "subnet_id": "e6471f95-e84c-4499-b643-65f39e27da00", "ip_address": "172.25.0.6", "mac_address": "A6:17:47:00:A3:2E"}]	{ad6d3e2c-4520-43f2-93e0-f6ca350bd166}	[{"id": "5f5b1d05-0e10-45cd-b222-3aca129e0852", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:05:16.126094782Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 17:05:16.126097+00	2025-12-13 17:05:30.513099+00	f	{}
6770c791-6147-4034-b578-e26946eb308d	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "30854fa4-c364-45b8-bab7-533cbee43641", "name": null, "subnet_id": "e6471f95-e84c-4499-b643-65f39e27da00", "ip_address": "172.25.0.1", "mac_address": "AE:06:D9:BA:7E:DD"}]	{e302ffbc-2baa-48f5-a0aa-2df6674dff34,a8fd6b8d-3d48-476d-8ee4-183c7cb1e73c,3576452b-0c35-4970-afe8-e262b684338d,4c0850da-82bf-4802-9276-8147340cd6fd}	[{"id": "a8d8dbbd-fa02-4873-8c57-c8c32d7bcc90", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "d95b2a28-c5df-4cdf-ad4f-4404be0c23be", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "76e93724-95b4-4de9-83ea-7a45e2945c2a", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "62820b1f-59f8-4572-9603-d2130ac050a3", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:05:36.560030669Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 17:05:36.560033+00	2025-12-13 17:05:51.035024+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
98894ef8-ae71-4222-b5ec-ea9f0359ea0d	My Network	2025-12-13 17:04:21.327241+00	2025-12-13 17:04:21.327241+00	f	6069dff8-bf8f-4333-838c-edee1c539522	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
6069dff8-bf8f-4333-838c-edee1c539522	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 17:04:21.305718+00	2025-12-13 17:04:21.453496+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
0facc54f-b0fe-47e6-ba94-a4a31c14bfa2	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.328867+00	2025-12-13 17:04:21.328867+00	Cloudflare DNS	0b789234-1385-4b07-a7ec-a1ace8c2dae1	[{"id": "fba1f609-584b-4c0e-b1fe-499b8426ef6a", "type": "Port", "port_id": "5baa8daa-1573-4361-a124-b64eec499161", "interface_id": "3187d329-530a-4f06-acbf-0be58173f4d6"}]	"Dns Server"	null	{"type": "System"}	{}
550dd927-6e95-432e-8acf-f7a2e853ec9a	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.328873+00	2025-12-13 17:04:21.328873+00	Google.com	a3ec1efb-3bcb-413a-b486-5ebc40da5d1c	[{"id": "8f695bcd-72d7-4d5f-baa7-28b2ef9d8ea7", "type": "Port", "port_id": "e94826e3-7999-4703-8890-e3f5031f7b0f", "interface_id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa"}]	"Web Service"	null	{"type": "System"}	{}
197fb617-d13b-4ca4-94da-9c59346c9bca	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.328878+00	2025-12-13 17:04:21.328878+00	Mobile Device	527fb5eb-bacd-4200-8739-0cac16e99f8f	[{"id": "c2c587dc-64f3-4aad-8f2d-b2e512ff73a1", "type": "Port", "port_id": "b626cbcc-9735-4a70-b181-9fe103c85de1", "interface_id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316"}]	"Client"	null	{"type": "System"}	{}
eccbc4b4-8bc8-43d4-9280-f6a962adbeb0	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.571206+00	2025-12-13 17:04:21.571206+00	NetVisor Daemon API	009bee10-1d53-454e-a585-162b111c092e	[{"id": "c4db8c36-dd8d-41fd-b8d5-584ab68dba8a", "type": "Port", "port_id": "90061d79-0f26-404c-9ced-e1775fb2df87", "interface_id": "6e7f303e-ea3b-4a44-8cb2-d392f1b53515"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T17:04:21.571204750Z", "type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2"}]}	{}
932ff511-9db7-4a15-82c3-3f5513b0dd51	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:01.543153+00	2025-12-13 17:05:01.543153+00	Unclaimed Open Ports	b4d225c9-c128-4f53-a765-f02b27b2a63b	[{"id": "f9279849-3f0d-4a74-ba31-96f42abc7513", "type": "Port", "port_id": "436fafd5-4d93-49a2-96ce-6c64b6bc89cc", "interface_id": "9fad56f4-74f4-4084-b5f1-d1480988ef81"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T17:05:01.543135674Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f7071c01-5fd8-40ed-b195-86c9721f74c9	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:58.616295+00	2025-12-13 17:04:58.616295+00	Home Assistant	b4d225c9-c128-4f53-a765-f02b27b2a63b	[{"id": "06d5cfd5-267c-493e-b5cf-8238907cbcb4", "type": "Port", "port_id": "366f5d93-8ce4-48bf-8452-4021bc7445a8", "interface_id": "9fad56f4-74f4-4084-b5f1-d1480988ef81"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T17:04:58.616275747Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
69ec9cd6-892f-428a-ad18-1ed9c9e832c1	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:05.293458+00	2025-12-13 17:05:05.293458+00	NetVisor Server API	c1b31d3a-cf34-4108-8305-173c71b532f3	[{"id": "6860c79a-baca-40d4-9d1e-e05c536d064e", "type": "Port", "port_id": "53c520cf-0d9e-442d-8246-a8dbabf23c23", "interface_id": "4acd5b92-27ab-4af5-a119-d9947248613c"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T17:05:05.293442348Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ad6d3e2c-4520-43f2-93e0-f6ca350bd166	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:30.502604+00	2025-12-13 17:05:30.502604+00	PostgreSQL	e482ca0a-6b50-486b-9593-97193eb3d860	[{"id": "1cd55c15-34f1-432a-ba60-c4092b3d1e1a", "type": "Port", "port_id": "5f5b1d05-0e10-45cd-b222-3aca129e0852", "interface_id": "7368e075-1997-459e-80bf-032f68cae8d8"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T17:05:30.502589128Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e302ffbc-2baa-48f5-a0aa-2df6674dff34	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:40.227222+00	2025-12-13 17:05:40.227222+00	NetVisor Server API	6770c791-6147-4034-b578-e26946eb308d	[{"id": "85237b7c-1263-44f9-9546-9fceb63d29ce", "type": "Port", "port_id": "a8d8dbbd-fa02-4873-8c57-c8c32d7bcc90", "interface_id": "30854fa4-c364-45b8-bab7-533cbee43641"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T17:05:40.227201175Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a8fd6b8d-3d48-476d-8ee4-183c7cb1e73c	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:48.148184+00	2025-12-13 17:05:48.148184+00	Home Assistant	6770c791-6147-4034-b578-e26946eb308d	[{"id": "941c946c-9ef0-4915-bde1-ca3d80a901fa", "type": "Port", "port_id": "d95b2a28-c5df-4cdf-ad4f-4404be0c23be", "interface_id": "30854fa4-c364-45b8-bab7-533cbee43641"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T17:05:48.148164575Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
4c0850da-82bf-4802-9276-8147340cd6fd	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:51.020827+00	2025-12-13 17:05:51.020827+00	Unclaimed Open Ports	6770c791-6147-4034-b578-e26946eb308d	[{"id": "31a4c2b5-c48e-47d7-8b3e-7d765e9d4d68", "type": "Port", "port_id": "62820b1f-59f8-4572-9603-d2130ac050a3", "interface_id": "30854fa4-c364-45b8-bab7-533cbee43641"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T17:05:51.020818375Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3576452b-0c35-4970-afe8-e262b684338d	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:05:51.020519+00	2025-12-13 17:05:51.020519+00	SSH	6770c791-6147-4034-b578-e26946eb308d	[{"id": "b2e6517f-4a34-49a3-a8f9-cd5d9195c740", "type": "Port", "port_id": "76e93724-95b4-4de9-83ea-7a45e2945c2a", "interface_id": "30854fa4-c364-45b8-bab7-533cbee43641"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T17:05:51.020501594Z", "type": "Network", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
21f87032-ff6b-413c-bee8-d942f4fb12e6	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.328809+00	2025-12-13 17:04:21.328809+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
3e4f2d96-886a-4176-8bf7-f4ca5c62bf05	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.328814+00	2025-12-13 17:04:21.328814+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
e6471f95-e84c-4499-b643-65f39e27da00	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	2025-12-13 17:04:21.46133+00	2025-12-13 17:04:21.46133+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T17:04:21.461324412Z", "type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
8a9426eb-424a-4824-a849-8f4558388551	6069dff8-bf8f-4333-838c-edee1c539522	New Tag	\N	2025-12-13 17:05:51.062522+00	2025-12-13 17:05:51.062522+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
8b51608c-ee5e-4845-a726-e25b26bd964c	98894ef8-ae71-4222-b5ec-ea9f0359ea0d	My Topology	[]	[{"id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "3e4f2d96-886a-4176-8bf7-f4ca5c62bf05", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "3187d329-530a-4f06-acbf-0be58173f4d6", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0b789234-1385-4b07-a7ec-a1ace8c2dae1", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "interface_id": "3187d329-530a-4f06-acbf-0be58173f4d6"}, {"id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a3ec1efb-3bcb-413a-b486-5ebc40da5d1c", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "interface_id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa"}, {"id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316", "size": {"x": 250, "y": 100}, "header": null, "host_id": "527fb5eb-bacd-4200-8739-0cac16e99f8f", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "3e4f2d96-886a-4176-8bf7-f4ca5c62bf05", "interface_id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "0b789234-1385-4b07-a7ec-a1ace8c2dae1", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "5baa8daa-1573-4361-a124-b64eec499161", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "fba1f609-584b-4c0e-b1fe-499b8426ef6a"}, "hostname": null, "services": ["0facc54f-b0fe-47e6-ba94-a4a31c14bfa2"], "created_at": "2025-12-13T17:04:21.328865Z", "interfaces": [{"id": "3187d329-530a-4f06-acbf-0be58173f4d6", "name": "Internet", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.338971Z", "description": null, "virtualization": null}, {"id": "a3ec1efb-3bcb-413a-b486-5ebc40da5d1c", "name": "Google.com", "tags": [], "ports": [{"id": "e94826e3-7999-4703-8890-e3f5031f7b0f", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8f695bcd-72d7-4d5f-baa7-28b2ef9d8ea7"}, "hostname": null, "services": ["550dd927-6e95-432e-8acf-f7a2e853ec9a"], "created_at": "2025-12-13T17:04:21.328871Z", "interfaces": [{"id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa", "name": "Internet", "subnet_id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "ip_address": "203.0.113.85", "mac_address": null}], "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.387262Z", "description": null, "virtualization": null}, {"id": "527fb5eb-bacd-4200-8739-0cac16e99f8f", "name": "Mobile Device", "tags": [], "ports": [{"id": "b626cbcc-9735-4a70-b181-9fe103c85de1", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c2c587dc-64f3-4aad-8f2d-b2e512ff73a1"}, "hostname": null, "services": ["197fb617-d13b-4ca4-94da-9c59346c9bca"], "created_at": "2025-12-13T17:04:21.328876Z", "interfaces": [{"id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316", "name": "Remote Network", "subnet_id": "3e4f2d96-886a-4176-8bf7-f4ca5c62bf05", "ip_address": "203.0.113.198", "mac_address": null}], "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.393063Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "21f87032-ff6b-413c-bee8-d942f4fb12e6", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T17:04:21.328809Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.328809Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "3e4f2d96-886a-4176-8bf7-f4ca5c62bf05", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T17:04:21.328814Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.328814Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "e6471f95-e84c-4499-b643-65f39e27da00", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T17:04:21.461324412Z", "type": "SelfReport", "host_id": "009bee10-1d53-454e-a585-162b111c092e", "daemon_id": "98462fcd-365e-4258-a390-ead468af9ce2"}]}, "created_at": "2025-12-13T17:04:21.461330Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.461330Z", "description": null, "subnet_type": "Lan"}]	[{"id": "0facc54f-b0fe-47e6-ba94-a4a31c14bfa2", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "0b789234-1385-4b07-a7ec-a1ace8c2dae1", "bindings": [{"id": "fba1f609-584b-4c0e-b1fe-499b8426ef6a", "type": "Port", "port_id": "5baa8daa-1573-4361-a124-b64eec499161", "interface_id": "3187d329-530a-4f06-acbf-0be58173f4d6"}], "created_at": "2025-12-13T17:04:21.328867Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.328867Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "550dd927-6e95-432e-8acf-f7a2e853ec9a", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "a3ec1efb-3bcb-413a-b486-5ebc40da5d1c", "bindings": [{"id": "8f695bcd-72d7-4d5f-baa7-28b2ef9d8ea7", "type": "Port", "port_id": "e94826e3-7999-4703-8890-e3f5031f7b0f", "interface_id": "1c273dc1-1895-4af3-92e0-3080ab3a73aa"}], "created_at": "2025-12-13T17:04:21.328873Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.328873Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "197fb617-d13b-4ca4-94da-9c59346c9bca", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "527fb5eb-bacd-4200-8739-0cac16e99f8f", "bindings": [{"id": "c2c587dc-64f3-4aad-8f2d-b2e512ff73a1", "type": "Port", "port_id": "b626cbcc-9735-4a70-b181-9fe103c85de1", "interface_id": "d98e036d-fc38-41ee-a9e6-7f5cc59bc316"}], "created_at": "2025-12-13T17:04:21.328878Z", "network_id": "98894ef8-ae71-4222-b5ec-ea9f0359ea0d", "updated_at": "2025-12-13T17:04:21.328878Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 17:04:21.398033+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 17:04:21.393958+00	2025-12-13 17:05:30.556149+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
4417b48b-969e-474b-b4e9-69acbc9957d0	2025-12-13 17:04:21.308892+00	2025-12-13 17:04:21.308892+00	$argon2id$v=19$m=19456,t=2,p=1$S5/o/BtCOzLor9MFp8IiVA$7huqbqWMtyku2nnuOWBWnGDnpAdRMo4zsWjx6inIR6A	\N	\N	\N	user@gmail.com	6069dff8-bf8f-4333-838c-edee1c539522	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
yfr_eaqcqfkhHypaWzVQpA	\\x93c410a450355b5a2a1f21f9a99caa79fffac981a7757365725f6964d92434343137623438622d393639652d343734622d623465392d36396163626339393537643099cd07ea0c110415ce129a3978000000	2026-01-12 17:04:21.312097+00
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

\unrestrict epf1WdOYiJla5JbEVsZERMy884PhVF7i9hhMvYGUkrTWq2NF0JIPXY6EhyeZoIR

