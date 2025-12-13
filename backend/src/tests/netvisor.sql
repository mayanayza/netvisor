--
-- PostgreSQL database dump
--

\restrict GrsUZQQCdFrGxqVGJuuNActkbjiToC6bUoGeY6mWdXsEgm53hFrRTevFV4NP3So

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
20251006215000	users	2025-12-13 08:46:19.610364+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3537155
20251006215100	networks	2025-12-13 08:46:19.614937+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5321291
20251006215151	create hosts	2025-12-13 08:46:19.620582+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3864707
20251006215155	create subnets	2025-12-13 08:46:19.624775+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3725136
20251006215201	create groups	2025-12-13 08:46:19.628834+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4115646
20251006215204	create daemons	2025-12-13 08:46:19.63327+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4062257
20251006215212	create services	2025-12-13 08:46:19.637684+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4960015
20251029193448	user-auth	2025-12-13 08:46:19.6431+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5904301
20251030044828	daemon api	2025-12-13 08:46:19.649284+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1475249
20251030170438	host-hide	2025-12-13 08:46:19.651048+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1087483
20251102224919	create discovery	2025-12-13 08:46:19.652406+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10726729
20251106235621	normalize-daemon-cols	2025-12-13 08:46:19.670141+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2269842
20251107034459	api keys	2025-12-13 08:46:19.67289+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9521305
20251107222650	oidc-auth	2025-12-13 08:46:19.682733+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	30117486
20251110181948	orgs-billing	2025-12-13 08:46:19.713348+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10978971
20251113223656	group-enhancements	2025-12-13 08:46:19.724668+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	990132
20251117032720	daemon-mode	2025-12-13 08:46:19.725953+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1084929
20251118143058	set-default-plan	2025-12-13 08:46:19.727311+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1164648
20251118225043	save-topology	2025-12-13 08:46:19.728779+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9606238
20251123232748	network-permissions	2025-12-13 08:46:19.738716+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2681064
20251125001342	billing-updates	2025-12-13 08:46:19.741662+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	919129
20251128035448	org-onboarding-status	2025-12-13 08:46:19.742867+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1439242
20251129180942	nfs-consolidate	2025-12-13 08:46:19.744634+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1226373
20251206052641	discovery-progress	2025-12-13 08:46:19.74617+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1670283
20251206202200	plan-fix	2025-12-13 08:46:19.748143+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	920000
20251207061341	daemon-url	2025-12-13 08:46:19.749333+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2279362
20251210045929	tags	2025-12-13 08:46:19.751949+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8801649
20251210175035	terms	2025-12-13 08:46:19.761083+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	863224
20251213025048	hash-keys	2025-12-13 08:46:19.76221+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9926733
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
56350c73-3bf3-4361-a464-642af5420844	04a3074371dcbf9c01f99fd077df1df537b72340aadef2e7d7786b41670e6a73	69f12907-f167-49de-92e8-c4a595de9577	Integrated Daemon API Key	2025-12-13 08:46:20.936902+00	2025-12-13 08:47:47.894435+00	2025-12-13 08:47:47.893532+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
161ea17e-2e8c-4e83-88cd-3981623b30f2	69f12907-f167-49de-92e8-c4a595de9577	ea19645b-985c-4c4d-94eb-a45a58455b5c	2025-12-13 08:46:21.067334+00	2025-12-13 08:47:35.849612+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["123a05cd-972b-4e73-ac3f-7606db850eb4"]}	2025-12-13 08:47:35.850241+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
ec3606ee-1d35-4038-89b5-0929173700ef	69f12907-f167-49de-92e8-c4a595de9577	161ea17e-2e8c-4e83-88cd-3981623b30f2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c"}	Self Report	2025-12-13 08:46:21.07585+00	2025-12-13 08:46:21.07585+00	{}
17ac06c0-19b9-4f97-a78a-9f8e91b57ee2	69f12907-f167-49de-92e8-c4a595de9577	161ea17e-2e8c-4e83-88cd-3981623b30f2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 08:46:21.083607+00	2025-12-13 08:46:21.083607+00	{}
c9f34cf0-b7e0-4b41-8c7d-0f21af8efd7c	69f12907-f167-49de-92e8-c4a595de9577	161ea17e-2e8c-4e83-88cd-3981623b30f2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "session_id": "d8f72955-dd75-402d-aec0-6f89438d83fe", "started_at": "2025-12-13T08:46:21.083114586Z", "finished_at": "2025-12-13T08:46:21.143896888Z", "discovery_type": {"type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c"}}}	{"type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c"}	Self Report	2025-12-13 08:46:21.083114+00	2025-12-13 08:46:21.14645+00	{}
73e5ac1a-bdb1-4d9f-9076-ae0018cc0a0c	69f12907-f167-49de-92e8-c4a595de9577	161ea17e-2e8c-4e83-88cd-3981623b30f2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "session_id": "f32724a4-a15a-4f38-9aad-735f0cabf304", "started_at": "2025-12-13T08:46:21.160637789Z", "finished_at": "2025-12-13T08:47:47.891423330Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 08:46:21.160637+00	2025-12-13 08:47:47.893809+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
35167c73-2a39-4148-8529-6f3178d6d7f7	69f12907-f167-49de-92e8-c4a595de9577		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 08:47:47.904982+00	2025-12-13 08:47:47.904982+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
c7b000a0-52c2-41e2-b814-e2c401a61c56	69f12907-f167-49de-92e8-c4a595de9577	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "ea204e67-bb6a-41f4-823a-074efe063b63"}	[{"id": "ac0a824c-351f-48e2-b37b-4e019493312d", "name": "Internet", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "ip_address": "1.1.1.1", "mac_address": null}]	{ea6cd4d9-5c09-4d22-ac9e-7620ed73f164}	[{"id": "78794a07-03ac-43db-84cd-514344c8e93c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 08:46:20.911033+00	2025-12-13 08:46:20.920619+00	f	{}
cf144eb8-9d12-4f95-b47d-c33318e4bd14	69f12907-f167-49de-92e8-c4a595de9577	Google.com	\N	\N	{"type": "ServiceBinding", "config": "a3c9fb88-3d8e-42a9-981b-ff50f0b1cc39"}	[{"id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3", "name": "Internet", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "ip_address": "203.0.113.76", "mac_address": null}]	{850f7c5d-11aa-4f5f-ae99-a453b5ea7e48}	[{"id": "34081101-cd27-4c28-a585-ec049b0cfe8c", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 08:46:20.91104+00	2025-12-13 08:46:20.925894+00	f	{}
b9dfb1d6-45e8-4a8f-b094-bc7fc6f5d2d9	69f12907-f167-49de-92e8-c4a595de9577	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "d7e233b9-ba33-4a13-9ad9-011d84eb761b"}	[{"id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3", "name": "Remote Network", "subnet_id": "003aa3d5-4467-43f3-a6cb-ad13cf508975", "ip_address": "203.0.113.205", "mac_address": null}]	{60cb252a-4950-448a-82bb-2bc3d8cfc71b}	[{"id": "cd02abf3-ef6f-4531-a208-5c81ab3cad6f", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 08:46:20.911045+00	2025-12-13 08:46:20.929589+00	f	{}
65dd4e12-b552-4e10-9268-27b5613f8367	69f12907-f167-49de-92e8-c4a595de9577	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "6d1e4e10-0443-48b1-af70-2a968809bc99", "name": null, "subnet_id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "ip_address": "172.25.0.5", "mac_address": "96:43:4D:58:0D:6C"}]	{de1dc316-130d-4286-9c38-bd6ba6e94738,5c945d06-6e36-498a-88d7-bd7642d08ec4}	[{"id": "7306193d-f909-4405-b5bc-d926824d9e5e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "cf11d6c3-72a6-45d3-ba61-d8ceb248d5ae", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:46:57.661870998Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 08:46:57.661874+00	2025-12-13 08:47:12.935583+00	f	{}
ea19645b-985c-4c4d-94eb-a45a58455b5c	69f12907-f167-49de-92e8-c4a595de9577	netvisor-daemon	5ed3d4adb711	NetVisor daemon	{"type": "None"}	[{"id": "7cbec8a3-9a7b-4cdd-bcc6-e4136f345eb0", "name": "eth0", "subnet_id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "ip_address": "172.25.0.4", "mac_address": "EA:EC:88:3F:06:DF"}]	{bfe0697e-c578-43ac-ace6-5cc1b7542a8a}	[{"id": "879237b8-0b19-42e7-86a5-00acca55ed6d", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:46:21.102612415Z", "type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2"}]}	null	2025-12-13 08:46:21.021381+00	2025-12-13 08:46:21.14031+00	f	{}
47353499-aecb-463f-b254-675bd55f5fc4	69f12907-f167-49de-92e8-c4a595de9577	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "d6e72584-b365-412a-a45e-3b01127c899e", "name": null, "subnet_id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "ip_address": "172.25.0.6", "mac_address": "6E:55:2C:F5:80:24"}]	{80d67d17-d97c-4f94-bbd0-521f680ba32b}	[{"id": "7f0bcae2-a6c5-42a1-9f5d-e8d1fa201d07", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:46:42.203857453Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 08:46:42.203861+00	2025-12-13 08:46:57.627621+00	f	{}
15c20965-fc57-457b-9e79-74bcb8d6c60a	69f12907-f167-49de-92e8-c4a595de9577	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "cb63e294-920c-4969-a4ea-9ec6794177c6", "name": null, "subnet_id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "ip_address": "172.25.0.3", "mac_address": "3A:C7:78:09:58:5F"}]	{0c93b921-c778-4688-ab51-7be99da1113f}	[{"id": "fd43f86c-15ab-4dc0-9413-d190d80b84af", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:47:12.924651919Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 08:47:12.924653+00	2025-12-13 08:47:28.395471+00	f	{}
fdcb3381-720c-43eb-a2e8-ac2b30504e96	69f12907-f167-49de-92e8-c4a595de9577	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "800da4d3-8cb7-4a02-9800-fc86e2a856d6", "name": null, "subnet_id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "ip_address": "172.25.0.1", "mac_address": "86:4B:FB:27:37:8C"}]	{2b454569-e114-487d-a8d3-64de8aca706b,48da8cbe-19d0-4bcc-9909-3345c931e24d,5bfb3a03-082a-458e-a323-e27e0be5f2a7,5b1cbaf4-51d9-4961-a666-f4b5d1a37dfa}	[{"id": "73f5dec5-14a0-44d0-bb0d-ae3207669ac3", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "b417a4d0-1a16-4d3c-a810-9f72ac4ef053", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "c8d53b8d-2130-4e42-98cd-948221513695", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "a9b5f64b-7e93-423e-b955-e00b1f11b6da", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:47:32.443490988Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 08:47:32.443494+00	2025-12-13 08:47:47.885903+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
69f12907-f167-49de-92e8-c4a595de9577	My Network	2025-12-13 08:46:20.90973+00	2025-12-13 08:46:20.90973+00	f	8a6ca76c-625b-4629-9a8d-037011bc1631	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
8a6ca76c-625b-4629-9a8d-037011bc1631	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 08:46:20.888114+00	2025-12-13 08:46:21.073997+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
ea6cd4d9-5c09-4d22-ac9e-7620ed73f164	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:20.911035+00	2025-12-13 08:46:20.911035+00	Cloudflare DNS	c7b000a0-52c2-41e2-b814-e2c401a61c56	[{"id": "ea204e67-bb6a-41f4-823a-074efe063b63", "type": "Port", "port_id": "78794a07-03ac-43db-84cd-514344c8e93c", "interface_id": "ac0a824c-351f-48e2-b37b-4e019493312d"}]	"Dns Server"	null	{"type": "System"}	{}
850f7c5d-11aa-4f5f-ae99-a453b5ea7e48	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:20.911041+00	2025-12-13 08:46:20.911041+00	Google.com	cf144eb8-9d12-4f95-b47d-c33318e4bd14	[{"id": "a3c9fb88-3d8e-42a9-981b-ff50f0b1cc39", "type": "Port", "port_id": "34081101-cd27-4c28-a585-ec049b0cfe8c", "interface_id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3"}]	"Web Service"	null	{"type": "System"}	{}
60cb252a-4950-448a-82bb-2bc3d8cfc71b	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:20.911046+00	2025-12-13 08:46:20.911046+00	Mobile Device	b9dfb1d6-45e8-4a8f-b094-bc7fc6f5d2d9	[{"id": "d7e233b9-ba33-4a13-9ad9-011d84eb761b", "type": "Port", "port_id": "cd02abf3-ef6f-4531-a208-5c81ab3cad6f", "interface_id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3"}]	"Client"	null	{"type": "System"}	{}
bfe0697e-c578-43ac-ace6-5cc1b7542a8a	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:21.102639+00	2025-12-13 08:46:21.102639+00	NetVisor Daemon API	ea19645b-985c-4c4d-94eb-a45a58455b5c	[{"id": "b29b5147-e14f-4094-a0d7-cd1422da2cd5", "type": "Port", "port_id": "879237b8-0b19-42e7-86a5-00acca55ed6d", "interface_id": "7cbec8a3-9a7b-4cdd-bcc6-e4136f345eb0"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T08:46:21.102638614Z", "type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2"}]}	{}
80d67d17-d97c-4f94-bbd0-521f680ba32b	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:57.539776+00	2025-12-13 08:46:57.539776+00	PostgreSQL	47353499-aecb-463f-b254-675bd55f5fc4	[{"id": "bc531e66-373e-4725-9aef-ed525d7ed0df", "type": "Port", "port_id": "7f0bcae2-a6c5-42a1-9f5d-e8d1fa201d07", "interface_id": "d6e72584-b365-412a-a45e-3b01127c899e"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T08:46:57.539760824Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5c945d06-6e36-498a-88d7-bd7642d08ec4	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:12.923093+00	2025-12-13 08:47:12.923093+00	Unclaimed Open Ports	65dd4e12-b552-4e10-9268-27b5613f8367	[{"id": "3eed5586-455f-42db-a61e-abc2731709a5", "type": "Port", "port_id": "cf11d6c3-72a6-45d3-ba61-d8ceb248d5ae", "interface_id": "6d1e4e10-0443-48b1-af70-2a968809bc99"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T08:47:12.923070417Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
de1dc316-130d-4286-9c38-bd6ba6e94738	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:06.875854+00	2025-12-13 08:47:06.875854+00	Home Assistant	65dd4e12-b552-4e10-9268-27b5613f8367	[{"id": "66708f50-dd55-4816-bc75-974270078ffb", "type": "Port", "port_id": "7306193d-f909-4405-b5bc-d926824d9e5e", "interface_id": "6d1e4e10-0443-48b1-af70-2a968809bc99"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T08:47:06.875833971Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0c93b921-c778-4688-ab51-7be99da1113f	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:22.146243+00	2025-12-13 08:47:22.146243+00	NetVisor Server API	15c20965-fc57-457b-9e79-74bcb8d6c60a	[{"id": "a23371c8-88c4-4f02-9dc1-448fba061051", "type": "Port", "port_id": "fd43f86c-15ab-4dc0-9413-d190d80b84af", "interface_id": "cb63e294-920c-4969-a4ea-9ec6794177c6"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T08:47:22.146225225Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2b454569-e114-487d-a8d3-64de8aca706b	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:41.720136+00	2025-12-13 08:47:41.720136+00	Home Assistant	fdcb3381-720c-43eb-a2e8-ac2b30504e96	[{"id": "295efdb6-7d23-47e1-8ddc-5b50873b6d9e", "type": "Port", "port_id": "73f5dec5-14a0-44d0-bb0d-ae3207669ac3", "interface_id": "800da4d3-8cb7-4a02-9800-fc86e2a856d6"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T08:47:41.720118909Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
48da8cbe-19d0-4bcc-9909-3345c931e24d	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:41.721345+00	2025-12-13 08:47:41.721345+00	NetVisor Server API	fdcb3381-720c-43eb-a2e8-ac2b30504e96	[{"id": "6b79cbe5-0564-4efd-8c7b-21a36b340632", "type": "Port", "port_id": "b417a4d0-1a16-4d3c-a810-9f72ac4ef053", "interface_id": "800da4d3-8cb7-4a02-9800-fc86e2a856d6"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T08:47:41.721335925Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5b1cbaf4-51d9-4961-a666-f4b5d1a37dfa	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:47.873343+00	2025-12-13 08:47:47.873343+00	Unclaimed Open Ports	fdcb3381-720c-43eb-a2e8-ac2b30504e96	[{"id": "1685ffb0-ff4d-4be6-9074-b16cecb46a79", "type": "Port", "port_id": "a9b5f64b-7e93-423e-b955-e00b1f11b6da", "interface_id": "800da4d3-8cb7-4a02-9800-fc86e2a856d6"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T08:47:47.873334428Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5bfb3a03-082a-458e-a323-e27e0be5f2a7	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:47:47.872736+00	2025-12-13 08:47:47.872736+00	SSH	fdcb3381-720c-43eb-a2e8-ac2b30504e96	[{"id": "0cf67a3a-e5c9-446a-b34f-2ad14cd75a61", "type": "Port", "port_id": "c8d53b8d-2130-4e42-98cd-948221513695", "interface_id": "800da4d3-8cb7-4a02-9800-fc86e2a856d6"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T08:47:47.872715682Z", "type": "Network", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
bbaa247d-d83c-464e-8bc1-47eb7ba1ae76	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:20.910975+00	2025-12-13 08:46:20.910975+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
003aa3d5-4467-43f3-a6cb-ad13cf508975	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:20.910978+00	2025-12-13 08:46:20.910978+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
123a05cd-972b-4e73-ac3f-7606db850eb4	69f12907-f167-49de-92e8-c4a595de9577	2025-12-13 08:46:21.083285+00	2025-12-13 08:46:21.083285+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T08:46:21.083283802Z", "type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
f5e8f908-7a91-4e40-a84d-a35ff8e8a32a	8a6ca76c-625b-4629-9a8d-037011bc1631	New Tag	\N	2025-12-13 08:47:47.913039+00	2025-12-13 08:47:47.913039+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
a04e0c49-5f93-4f00-9502-70e11b312099	69f12907-f167-49de-92e8-c4a595de9577	My Topology	[]	[{"id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "003aa3d5-4467-43f3-a6cb-ad13cf508975", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "ac0a824c-351f-48e2-b37b-4e019493312d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "c7b000a0-52c2-41e2-b814-e2c401a61c56", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "interface_id": "ac0a824c-351f-48e2-b37b-4e019493312d"}, {"id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3", "size": {"x": 250, "y": 100}, "header": null, "host_id": "cf144eb8-9d12-4f95-b47d-c33318e4bd14", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "interface_id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3"}, {"id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3", "size": {"x": 250, "y": 100}, "header": null, "host_id": "b9dfb1d6-45e8-4a8f-b094-bc7fc6f5d2d9", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "003aa3d5-4467-43f3-a6cb-ad13cf508975", "interface_id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "c7b000a0-52c2-41e2-b814-e2c401a61c56", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "78794a07-03ac-43db-84cd-514344c8e93c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "ea204e67-bb6a-41f4-823a-074efe063b63"}, "hostname": null, "services": ["ea6cd4d9-5c09-4d22-ac9e-7620ed73f164"], "created_at": "2025-12-13T08:46:20.911033Z", "interfaces": [{"id": "ac0a824c-351f-48e2-b37b-4e019493312d", "name": "Internet", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.920619Z", "description": null, "virtualization": null}, {"id": "cf144eb8-9d12-4f95-b47d-c33318e4bd14", "name": "Google.com", "tags": [], "ports": [{"id": "34081101-cd27-4c28-a585-ec049b0cfe8c", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "a3c9fb88-3d8e-42a9-981b-ff50f0b1cc39"}, "hostname": null, "services": ["850f7c5d-11aa-4f5f-ae99-a453b5ea7e48"], "created_at": "2025-12-13T08:46:20.911040Z", "interfaces": [{"id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3", "name": "Internet", "subnet_id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "ip_address": "203.0.113.76", "mac_address": null}], "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.925894Z", "description": null, "virtualization": null}, {"id": "b9dfb1d6-45e8-4a8f-b094-bc7fc6f5d2d9", "name": "Mobile Device", "tags": [], "ports": [{"id": "cd02abf3-ef6f-4531-a208-5c81ab3cad6f", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "d7e233b9-ba33-4a13-9ad9-011d84eb761b"}, "hostname": null, "services": ["60cb252a-4950-448a-82bb-2bc3d8cfc71b"], "created_at": "2025-12-13T08:46:20.911045Z", "interfaces": [{"id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3", "name": "Remote Network", "subnet_id": "003aa3d5-4467-43f3-a6cb-ad13cf508975", "ip_address": "203.0.113.205", "mac_address": null}], "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.929589Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "bbaa247d-d83c-464e-8bc1-47eb7ba1ae76", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T08:46:20.910975Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.910975Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "003aa3d5-4467-43f3-a6cb-ad13cf508975", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T08:46:20.910978Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.910978Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "123a05cd-972b-4e73-ac3f-7606db850eb4", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T08:46:21.083283802Z", "type": "SelfReport", "host_id": "ea19645b-985c-4c4d-94eb-a45a58455b5c", "daemon_id": "161ea17e-2e8c-4e83-88cd-3981623b30f2"}]}, "created_at": "2025-12-13T08:46:21.083285Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:21.083285Z", "description": null, "subnet_type": "Lan"}]	[{"id": "ea6cd4d9-5c09-4d22-ac9e-7620ed73f164", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "c7b000a0-52c2-41e2-b814-e2c401a61c56", "bindings": [{"id": "ea204e67-bb6a-41f4-823a-074efe063b63", "type": "Port", "port_id": "78794a07-03ac-43db-84cd-514344c8e93c", "interface_id": "ac0a824c-351f-48e2-b37b-4e019493312d"}], "created_at": "2025-12-13T08:46:20.911035Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.911035Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "850f7c5d-11aa-4f5f-ae99-a453b5ea7e48", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "cf144eb8-9d12-4f95-b47d-c33318e4bd14", "bindings": [{"id": "a3c9fb88-3d8e-42a9-981b-ff50f0b1cc39", "type": "Port", "port_id": "34081101-cd27-4c28-a585-ec049b0cfe8c", "interface_id": "eded86c8-98b4-4ff0-a269-49bbd1c001b3"}], "created_at": "2025-12-13T08:46:20.911041Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.911041Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "60cb252a-4950-448a-82bb-2bc3d8cfc71b", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "b9dfb1d6-45e8-4a8f-b094-bc7fc6f5d2d9", "bindings": [{"id": "d7e233b9-ba33-4a13-9ad9-011d84eb761b", "type": "Port", "port_id": "cd02abf3-ef6f-4531-a208-5c81ab3cad6f", "interface_id": "11a1431a-9f6f-4a87-9bfc-14577dd6cfe3"}], "created_at": "2025-12-13T08:46:20.911046Z", "network_id": "69f12907-f167-49de-92e8-c4a595de9577", "updated_at": "2025-12-13T08:46:20.911046Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 08:46:20.934147+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 08:46:20.930373+00	2025-12-13 08:47:28.439062+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
c9e1262c-f255-4fe3-8318-d5ac5f714c90	2025-12-13 08:46:20.891432+00	2025-12-13 08:46:20.891432+00	$argon2id$v=19$m=19456,t=2,p=1$LhtvunqRa+DDJm8wamY38g$qKLv+bZWV4w2YNK61hEFQQF2cXVtoaUJBZlaN0+00jQ	\N	\N	\N	user@gmail.com	8a6ca76c-625b-4629-9a8d-037011bc1631	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
3uVa8PHobn48kaQT7axCAQ	\\x93c4100142aced13a4913c7e6ee8f1f05ae5de81a7757365725f6964d92463396531323632632d663235352d346665332d383331382d64356163356637313463393099cd07ea0c082e14ce35542c10000000	2026-01-12 08:46:20.894708+00
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

\unrestrict GrsUZQQCdFrGxqVGJuuNActkbjiToC6bUoGeY6mWdXsEgm53hFrRTevFV4NP3So

