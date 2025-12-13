--
-- PostgreSQL database dump
--

\restrict fawQu9MbG76bNuvMT16KnvEXDvAlyrQmiwAEoMgtDeJreEkt9glCRqwt1ZbOtvt

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
20251006215000	users	2025-12-13 04:16:03.199034+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3437880
20251006215100	networks	2025-12-13 04:16:03.203455+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4480009
20251006215151	create hosts	2025-12-13 04:16:03.208256+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3705101
20251006215155	create subnets	2025-12-13 04:16:03.212283+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3614240
20251006215201	create groups	2025-12-13 04:16:03.216225+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3895707
20251006215204	create daemons	2025-12-13 04:16:03.220447+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4046258
20251006215212	create services	2025-12-13 04:16:03.224861+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4844252
20251029193448	user-auth	2025-12-13 04:16:03.230013+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5964046
20251030044828	daemon api	2025-12-13 04:16:03.236289+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1470842
20251030170438	host-hide	2025-12-13 04:16:03.238075+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1043612
20251102224919	create discovery	2025-12-13 04:16:03.239392+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10852251
20251106235621	normalize-daemon-cols	2025-12-13 04:16:03.250566+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1764388
20251107034459	api keys	2025-12-13 04:16:03.252627+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8118847
20251107222650	oidc-auth	2025-12-13 04:16:03.261125+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	25699633
20251110181948	orgs-billing	2025-12-13 04:16:03.287158+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10581596
20251113223656	group-enhancements	2025-12-13 04:16:03.298189+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1044834
20251117032720	daemon-mode	2025-12-13 04:16:03.299526+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1117748
20251118143058	set-default-plan	2025-12-13 04:16:03.300954+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1179809
20251118225043	save-topology	2025-12-13 04:16:03.302431+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8698431
20251123232748	network-permissions	2025-12-13 04:16:03.311452+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2702265
20251125001342	billing-updates	2025-12-13 04:16:03.314471+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	920202
20251128035448	org-onboarding-status	2025-12-13 04:16:03.315673+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1487222
20251129180942	nfs-consolidate	2025-12-13 04:16:03.317445+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1249096
20251206052641	discovery-progress	2025-12-13 04:16:03.318982+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1650227
20251206202200	plan-fix	2025-12-13 04:16:03.320923+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	894042
20251207061341	daemon-url	2025-12-13 04:16:03.32211+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2400871
20251210045929	tags	2025-12-13 04:16:03.32504+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9386448
20251210175035	terms	2025-12-13 04:16:03.334739+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	913830
20251213025048	hash-keys	2025-12-13 04:16:03.335948+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9614094
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
586ed116-8989-4bad-87eb-a1f8249078b8	b7f6f1a7ab2cc72297869486e0e1093a0e10617525b52f57dd33c6974b35f871	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	Integrated Daemon API Key	2025-12-13 04:16:05.03532+00	2025-12-13 04:17:38.222269+00	2025-12-13 04:17:38.221518+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
17199da8-86aa-4303-8ed9-81b355069bdb	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7	2025-12-13 04:16:05.157528+00	2025-12-13 04:17:19.255889+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["26d2c090-3a71-49c5-8208-b60534ec17c3"]}	2025-12-13 04:17:19.257078+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
c78fb9d6-9ac4-4163-a260-cc3bee11d808	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	17199da8-86aa-4303-8ed9-81b355069bdb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7"}	Self Report	2025-12-13 04:16:05.164655+00	2025-12-13 04:16:05.164655+00	{}
c1440b46-36f5-4eee-bba9-8e68e06746a8	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	17199da8-86aa-4303-8ed9-81b355069bdb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 04:16:05.17181+00	2025-12-13 04:16:05.17181+00	{}
4307fa15-fb9b-41b5-bfce-ea5021612cb8	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	17199da8-86aa-4303-8ed9-81b355069bdb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "session_id": "bfa62aa7-72f9-4e44-8c37-d544f0259782", "started_at": "2025-12-13T04:16:05.171429768Z", "finished_at": "2025-12-13T04:16:05.291646782Z", "discovery_type": {"type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7"}}}	{"type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7"}	Self Report	2025-12-13 04:16:05.171429+00	2025-12-13 04:16:05.295776+00	{}
d7cefe74-92e3-474e-86b1-d991c59b9d8d	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	17199da8-86aa-4303-8ed9-81b355069bdb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "session_id": "7882b4ba-efde-4dc7-b020-e6008b7bfb82", "started_at": "2025-12-13T04:16:05.310416772Z", "finished_at": "2025-12-13T04:17:38.219235870Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 04:16:05.310416+00	2025-12-13 04:17:38.221765+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
d654b596-5e48-454b-a2b1-8fb1c9bcbf40	f2e65ecb-1feb-468b-8482-ac5e97a5aec1		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 04:17:38.233298+00	2025-12-13 04:17:38.233298+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
21a2cf76-c754-4eb3-9bdb-56f7c56cb493	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "8db52a70-a308-49dd-b26b-19d715131995"}	[{"id": "effdc6d4-4f34-451c-b3bb-372b753d24a4", "name": "Internet", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "ip_address": "1.1.1.1", "mac_address": null}]	{4c21b2a0-ad3b-4c4c-adbb-395ae52f3e66}	[{"id": "8cbb6ee7-149b-40b5-a5f7-b375c0106af4", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 04:16:05.010003+00	2025-12-13 04:16:05.019142+00	f	{}
93761288-4963-42b0-9aaf-b5a7dba7df98	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	Google.com	\N	\N	{"type": "ServiceBinding", "config": "54942a61-f717-460a-bad6-332597475b2b"}	[{"id": "b5335489-5738-4b71-b856-45613cd95dd4", "name": "Internet", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "ip_address": "203.0.113.79", "mac_address": null}]	{1fcdef9a-3503-450d-9c5c-2874e4ea830e}	[{"id": "25d31b8c-0b9e-46e8-9b2c-90775fea0d0b", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 04:16:05.01001+00	2025-12-13 04:16:05.024053+00	f	{}
0293c8c4-11cc-40e0-ada1-4d2729941d48	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "b582ef89-81df-46d4-a347-c149f76adb42"}	[{"id": "7143cfcf-6022-4533-86e6-531f810d7332", "name": "Remote Network", "subnet_id": "60210c19-2d0d-4e45-be2f-a2d79fb08e76", "ip_address": "203.0.113.22", "mac_address": null}]	{3cbd004e-089d-455d-8ac0-779a128e419a}	[{"id": "4b18769e-0804-416a-af6c-1b4a0116b445", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 04:16:05.010015+00	2025-12-13 04:16:05.027937+00	f	{}
60b82b64-7b37-4f69-969d-acd2e6f86e85	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "14aab958-7daa-4059-ae2a-46605601d30e", "name": null, "subnet_id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "ip_address": "172.25.0.6", "mac_address": "E6:00:AB:4D:A1:9F"}]	{af1b0864-cb76-4db4-896c-2d9748653c5a}	[{"id": "1eefc20d-7f48-46bd-a6f8-99de4b243a0c", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:16:50.266251594Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 04:16:50.266253+00	2025-12-13 04:17:04.201208+00	f	{}
fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	netvisor-daemon	beef247dcd7a	NetVisor daemon	{"type": "None"}	[{"id": "e7593b9f-fcae-406d-bf24-271e627a9e07", "name": "eth0", "subnet_id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "ip_address": "172.25.0.4", "mac_address": "66:D4:32:65:D2:C4"}]	{84e4f2f2-ccfe-4b04-aa27-4df45895167a}	[{"id": "89033dec-4e7a-4070-a718-820940a554b0", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:16:05.186154903Z", "type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb"}]}	null	2025-12-13 04:16:05.117812+00	2025-12-13 04:16:05.28841+00	f	{}
ef838c73-ea26-4def-ac93-be621ff29dc4	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "90ca171b-47f1-4af3-b806-975e4e0dcfd0", "name": null, "subnet_id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "ip_address": "172.25.0.3", "mac_address": "4A:8B:33:4A:A0:F3"}]	{24110d5b-20a0-4ba6-a661-296f51770c14}	[{"id": "6f31c8a5-8398-4253-aa0b-74ad9eb4d8ad", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:16:36.203310187Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 04:16:36.203312+00	2025-12-13 04:16:50.184027+00	f	{}
57e4ff20-0060-4cdc-a144-f1fb09f69620	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "f0e9b6dd-4455-4609-99df-08520e8870f1", "name": null, "subnet_id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "ip_address": "172.25.0.5", "mac_address": "1E:44:01:75:48:90"}]	{3bcb2db0-ccae-4b52-b228-477d80537e67,1baea9b2-b3ce-4417-bee1-8a3319dbfdb8}	[{"id": "7e91f982-23bb-4c27-99af-60d277955159", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ca7edb96-f3f3-48de-a0ab-00e6d6abac2e", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:17:04.195964649Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 04:17:04.195966+00	2025-12-13 04:17:18.208314+00	f	{}
f94e9752-10da-4ee4-ae0d-bdc6f0149ce4	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "fc51dd1a-409f-4baa-a56f-423460518940", "name": null, "subnet_id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "ip_address": "172.25.0.1", "mac_address": "CE:41:69:D5:09:E4"}]	{67b903b2-bbfe-4b43-a5aa-be1d1b2c9f4b,7381f5e9-f631-4991-a8b8-a25f0644e184,518ea603-287f-4f6c-be79-e03527956342,1019eb55-95b6-4ecc-81f1-682559784a16}	[{"id": "8029f24c-f7ff-4b9a-8434-eebb6eca136a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "86f9eb28-7abe-4544-9e9a-f0d0cb819a47", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "7e30e316-cea7-4674-ba0a-c61462d732a2", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "01cb07a4-05bb-44d2-819c-fa616f189769", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:17:24.268106244Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 04:17:24.268108+00	2025-12-13 04:17:38.213746+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
f2e65ecb-1feb-468b-8482-ac5e97a5aec1	My Network	2025-12-13 04:16:05.008681+00	2025-12-13 04:16:05.008681+00	f	19ddad31-bfe8-4eec-9d03-e78006f36346	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
19ddad31-bfe8-4eec-9d03-e78006f36346	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 04:16:04.987457+00	2025-12-13 04:16:05.163623+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
4c21b2a0-ad3b-4c4c-adbb-395ae52f3e66	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.010005+00	2025-12-13 04:16:05.010005+00	Cloudflare DNS	21a2cf76-c754-4eb3-9bdb-56f7c56cb493	[{"id": "8db52a70-a308-49dd-b26b-19d715131995", "type": "Port", "port_id": "8cbb6ee7-149b-40b5-a5f7-b375c0106af4", "interface_id": "effdc6d4-4f34-451c-b3bb-372b753d24a4"}]	"Dns Server"	null	{"type": "System"}	{}
1fcdef9a-3503-450d-9c5c-2874e4ea830e	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.010011+00	2025-12-13 04:16:05.010011+00	Google.com	93761288-4963-42b0-9aaf-b5a7dba7df98	[{"id": "54942a61-f717-460a-bad6-332597475b2b", "type": "Port", "port_id": "25d31b8c-0b9e-46e8-9b2c-90775fea0d0b", "interface_id": "b5335489-5738-4b71-b856-45613cd95dd4"}]	"Web Service"	null	{"type": "System"}	{}
3cbd004e-089d-455d-8ac0-779a128e419a	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.010017+00	2025-12-13 04:16:05.010017+00	Mobile Device	0293c8c4-11cc-40e0-ada1-4d2729941d48	[{"id": "b582ef89-81df-46d4-a347-c149f76adb42", "type": "Port", "port_id": "4b18769e-0804-416a-af6c-1b4a0116b445", "interface_id": "7143cfcf-6022-4533-86e6-531f810d7332"}]	"Client"	null	{"type": "System"}	{}
84e4f2f2-ccfe-4b04-aa27-4df45895167a	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.186169+00	2025-12-13 04:16:05.186169+00	NetVisor Daemon API	fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7	[{"id": "2db5dbb8-6098-4132-913d-68c0cc3b5f6a", "type": "Port", "port_id": "89033dec-4e7a-4070-a718-820940a554b0", "interface_id": "e7593b9f-fcae-406d-bf24-271e627a9e07"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T04:16:05.186168729Z", "type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb"}]}	{}
24110d5b-20a0-4ba6-a661-296f51770c14	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:41.134609+00	2025-12-13 04:16:41.134609+00	NetVisor Server API	ef838c73-ea26-4def-ac93-be621ff29dc4	[{"id": "7ff091cf-bc2e-4318-90b7-ec1538f40b42", "type": "Port", "port_id": "6f31c8a5-8398-4253-aa0b-74ad9eb4d8ad", "interface_id": "90ca171b-47f1-4af3-b806-975e4e0dcfd0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T04:16:41.134593915Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
af1b0864-cb76-4db4-896c-2d9748653c5a	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:04.189688+00	2025-12-13 04:17:04.189688+00	PostgreSQL	60b82b64-7b37-4f69-969d-acd2e6f86e85	[{"id": "361c382a-6dd1-48bd-9caf-ab7e97b5e2fa", "type": "Port", "port_id": "1eefc20d-7f48-46bd-a6f8-99de4b243a0c", "interface_id": "14aab958-7daa-4059-ae2a-46605601d30e"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T04:17:04.189670703Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1baea9b2-b3ce-4417-bee1-8a3319dbfdb8	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:18.197479+00	2025-12-13 04:17:18.197479+00	Unclaimed Open Ports	57e4ff20-0060-4cdc-a144-f1fb09f69620	[{"id": "43591fcb-6567-4bdf-b4ee-6b942fbb9e09", "type": "Port", "port_id": "ca7edb96-f3f3-48de-a0ab-00e6d6abac2e", "interface_id": "f0e9b6dd-4455-4609-99df-08520e8870f1"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T04:17:18.197459725Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3bcb2db0-ccae-4b52-b228-477d80537e67	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:09.107117+00	2025-12-13 04:17:09.107117+00	Home Assistant	57e4ff20-0060-4cdc-a144-f1fb09f69620	[{"id": "dcf1b824-d4a1-452e-a8d7-93315d51365a", "type": "Port", "port_id": "7e91f982-23bb-4c27-99af-60d277955159", "interface_id": "f0e9b6dd-4455-4609-99df-08520e8870f1"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T04:17:09.107099270Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7381f5e9-f631-4991-a8b8-a25f0644e184	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:29.071343+00	2025-12-13 04:17:29.071343+00	NetVisor Server API	f94e9752-10da-4ee4-ae0d-bdc6f0149ce4	[{"id": "28482f0b-39f4-4e93-bcf6-94f5b3fec089", "type": "Port", "port_id": "86f9eb28-7abe-4544-9e9a-f0d0cb819a47", "interface_id": "fc51dd1a-409f-4baa-a56f-423460518940"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T04:17:29.071334178Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
518ea603-287f-4f6c-be79-e03527956342	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:38.199474+00	2025-12-13 04:17:38.199474+00	SSH	f94e9752-10da-4ee4-ae0d-bdc6f0149ce4	[{"id": "42fbe84c-7418-479c-bec6-945c37b29a9c", "type": "Port", "port_id": "7e30e316-cea7-4674-ba0a-c61462d732a2", "interface_id": "fc51dd1a-409f-4baa-a56f-423460518940"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T04:17:38.199456308Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1019eb55-95b6-4ecc-81f1-682559784a16	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:38.199856+00	2025-12-13 04:17:38.199856+00	Unclaimed Open Ports	f94e9752-10da-4ee4-ae0d-bdc6f0149ce4	[{"id": "b10dd702-66e3-434b-8947-c20ba22afc48", "type": "Port", "port_id": "01cb07a4-05bb-44d2-819c-fa616f189769", "interface_id": "fc51dd1a-409f-4baa-a56f-423460518940"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T04:17:38.199846427Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
67b903b2-bbfe-4b43-a5aa-be1d1b2c9f4b	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:17:29.07092+00	2025-12-13 04:17:29.07092+00	Home Assistant	f94e9752-10da-4ee4-ae0d-bdc6f0149ce4	[{"id": "fb42fcbb-8fa2-44a3-ac17-f8a9b443a0d0", "type": "Port", "port_id": "8029f24c-f7ff-4b9a-8434-eebb6eca136a", "interface_id": "fc51dd1a-409f-4baa-a56f-423460518940"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T04:17:29.070900687Z", "type": "Network", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
94db884f-690d-467d-a3c1-1f123293fcf9	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.009952+00	2025-12-13 04:16:05.009952+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
60210c19-2d0d-4e45-be2f-a2d79fb08e76	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.009956+00	2025-12-13 04:16:05.009956+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
26d2c090-3a71-49c5-8208-b60534ec17c3	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	2025-12-13 04:16:05.171605+00	2025-12-13 04:16:05.171605+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T04:16:05.171603933Z", "type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
a9f62ebf-73d1-4e11-828c-5a640bc74eab	19ddad31-bfe8-4eec-9d03-e78006f36346	New Tag	\N	2025-12-13 04:17:38.239624+00	2025-12-13 04:17:38.239624+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
7367e4fa-580c-420c-bd83-9616bd1d67cc	f2e65ecb-1feb-468b-8482-ac5e97a5aec1	My Topology	[]	[{"id": "94db884f-690d-467d-a3c1-1f123293fcf9", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "60210c19-2d0d-4e45-be2f-a2d79fb08e76", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "7143cfcf-6022-4533-86e6-531f810d7332", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0293c8c4-11cc-40e0-ada1-4d2729941d48", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "60210c19-2d0d-4e45-be2f-a2d79fb08e76", "interface_id": "7143cfcf-6022-4533-86e6-531f810d7332"}, {"id": "effdc6d4-4f34-451c-b3bb-372b753d24a4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "21a2cf76-c754-4eb3-9bdb-56f7c56cb493", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "interface_id": "effdc6d4-4f34-451c-b3bb-372b753d24a4"}, {"id": "b5335489-5738-4b71-b856-45613cd95dd4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "93761288-4963-42b0-9aaf-b5a7dba7df98", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "interface_id": "b5335489-5738-4b71-b856-45613cd95dd4"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "21a2cf76-c754-4eb3-9bdb-56f7c56cb493", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "8cbb6ee7-149b-40b5-a5f7-b375c0106af4", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8db52a70-a308-49dd-b26b-19d715131995"}, "hostname": null, "services": ["4c21b2a0-ad3b-4c4c-adbb-395ae52f3e66"], "created_at": "2025-12-13T04:16:05.010003Z", "interfaces": [{"id": "effdc6d4-4f34-451c-b3bb-372b753d24a4", "name": "Internet", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.019142Z", "description": null, "virtualization": null}, {"id": "93761288-4963-42b0-9aaf-b5a7dba7df98", "name": "Google.com", "tags": [], "ports": [{"id": "25d31b8c-0b9e-46e8-9b2c-90775fea0d0b", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "54942a61-f717-460a-bad6-332597475b2b"}, "hostname": null, "services": ["1fcdef9a-3503-450d-9c5c-2874e4ea830e"], "created_at": "2025-12-13T04:16:05.010010Z", "interfaces": [{"id": "b5335489-5738-4b71-b856-45613cd95dd4", "name": "Internet", "subnet_id": "94db884f-690d-467d-a3c1-1f123293fcf9", "ip_address": "203.0.113.79", "mac_address": null}], "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.024053Z", "description": null, "virtualization": null}, {"id": "0293c8c4-11cc-40e0-ada1-4d2729941d48", "name": "Mobile Device", "tags": [], "ports": [{"id": "4b18769e-0804-416a-af6c-1b4a0116b445", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "b582ef89-81df-46d4-a347-c149f76adb42"}, "hostname": null, "services": ["3cbd004e-089d-455d-8ac0-779a128e419a"], "created_at": "2025-12-13T04:16:05.010015Z", "interfaces": [{"id": "7143cfcf-6022-4533-86e6-531f810d7332", "name": "Remote Network", "subnet_id": "60210c19-2d0d-4e45-be2f-a2d79fb08e76", "ip_address": "203.0.113.22", "mac_address": null}], "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.027937Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "94db884f-690d-467d-a3c1-1f123293fcf9", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T04:16:05.009952Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.009952Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "60210c19-2d0d-4e45-be2f-a2d79fb08e76", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T04:16:05.009956Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.009956Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "26d2c090-3a71-49c5-8208-b60534ec17c3", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T04:16:05.171603933Z", "type": "SelfReport", "host_id": "fd3cfc5d-ac3c-4f5a-9ef8-19f71d41fdf7", "daemon_id": "17199da8-86aa-4303-8ed9-81b355069bdb"}]}, "created_at": "2025-12-13T04:16:05.171605Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.171605Z", "description": null, "subnet_type": "Lan"}]	[{"id": "4c21b2a0-ad3b-4c4c-adbb-395ae52f3e66", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "21a2cf76-c754-4eb3-9bdb-56f7c56cb493", "bindings": [{"id": "8db52a70-a308-49dd-b26b-19d715131995", "type": "Port", "port_id": "8cbb6ee7-149b-40b5-a5f7-b375c0106af4", "interface_id": "effdc6d4-4f34-451c-b3bb-372b753d24a4"}], "created_at": "2025-12-13T04:16:05.010005Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.010005Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "1fcdef9a-3503-450d-9c5c-2874e4ea830e", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "93761288-4963-42b0-9aaf-b5a7dba7df98", "bindings": [{"id": "54942a61-f717-460a-bad6-332597475b2b", "type": "Port", "port_id": "25d31b8c-0b9e-46e8-9b2c-90775fea0d0b", "interface_id": "b5335489-5738-4b71-b856-45613cd95dd4"}], "created_at": "2025-12-13T04:16:05.010011Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.010011Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "3cbd004e-089d-455d-8ac0-779a128e419a", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "0293c8c4-11cc-40e0-ada1-4d2729941d48", "bindings": [{"id": "b582ef89-81df-46d4-a347-c149f76adb42", "type": "Port", "port_id": "4b18769e-0804-416a-af6c-1b4a0116b445", "interface_id": "7143cfcf-6022-4533-86e6-531f810d7332"}], "created_at": "2025-12-13T04:16:05.010017Z", "network_id": "f2e65ecb-1feb-468b-8482-ac5e97a5aec1", "updated_at": "2025-12-13T04:16:05.010017Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 04:16:05.032518+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 04:16:05.028682+00	2025-12-13 04:17:18.410042+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
a801fda9-8cb2-4617-b917-5317a3be2590	2025-12-13 04:16:04.990322+00	2025-12-13 04:16:04.990322+00	$argon2id$v=19$m=19456,t=2,p=1$nQZOilRv4bWPpiHm4zFLzQ$2U7NloYjRfawcMxhl1RAV2pVni2xsrhx2XPFfKZH19g	\N	\N	\N	user@gmail.com	19ddad31-bfe8-4eec-9d03-e78006f36346	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
HreiSXdFwsO3mmDsUOAumA	\\x93c410982ee050ec609ab7c3c2457749a2b71e81a7757365725f6964d92461383031666461392d386362322d343631372d623931372d35333137613362653235393099cd07ea0c041004ce3b383311000000	2026-01-12 04:16:04.993538+00
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

\unrestrict fawQu9MbG76bNuvMT16KnvEXDvAlyrQmiwAEoMgtDeJreEkt9glCRqwt1ZbOtvt

