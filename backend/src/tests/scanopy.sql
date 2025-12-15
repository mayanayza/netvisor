--
-- PostgreSQL database dump
--

\restrict 2GwNw8zpZO6WrEqkR4b6mwiypZWgBsHSMy53g62Mn9PSnpVLHJnU0GPdLN7hSQ5

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
20251006215000	users	2025-12-15 04:06:13.098363+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3432258
20251006215100	networks	2025-12-15 04:06:13.102794+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4763791
20251006215151	create hosts	2025-12-15 04:06:13.107935+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3901713
20251006215155	create subnets	2025-12-15 04:06:13.112175+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3639204
20251006215201	create groups	2025-12-15 04:06:13.116238+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4147892
20251006215204	create daemons	2025-12-15 04:06:13.120705+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4311257
20251006215212	create services	2025-12-15 04:06:13.125391+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4811448
20251029193448	user-auth	2025-12-15 04:06:13.130561+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6210397
20251030044828	daemon api	2025-12-15 04:06:13.137088+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1530032
20251030170438	host-hide	2025-12-15 04:06:13.138913+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1062100
20251102224919	create discovery	2025-12-15 04:06:13.140283+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10770026
20251106235621	normalize-daemon-cols	2025-12-15 04:06:13.151358+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1767886
20251107034459	api keys	2025-12-15 04:06:13.153404+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	10180948
20251107222650	oidc-auth	2025-12-15 04:06:13.16392+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26691375
20251110181948	orgs-billing	2025-12-15 04:06:13.190929+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11262634
20251113223656	group-enhancements	2025-12-15 04:06:13.202512+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	995185
20251117032720	daemon-mode	2025-12-15 04:06:13.20383+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1082688
20251118143058	set-default-plan	2025-12-15 04:06:13.205213+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1153190
20251118225043	save-topology	2025-12-15 04:06:13.206644+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9031224
20251123232748	network-permissions	2025-12-15 04:06:13.216006+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2919042
20251125001342	billing-updates	2025-12-15 04:06:13.219264+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	891031
20251128035448	org-onboarding-status	2025-12-15 04:06:13.220442+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1401171
20251129180942	nfs-consolidate	2025-12-15 04:06:13.222135+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1201620
20251206052641	discovery-progress	2025-12-15 04:06:13.223656+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	2096809
20251206202200	plan-fix	2025-12-15 04:06:13.226183+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	973986
20251207061341	daemon-url	2025-12-15 04:06:13.227451+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2309505
20251210045929	tags	2025-12-15 04:06:13.230067+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9164684
20251210175035	terms	2025-12-15 04:06:13.239581+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	1022135
20251213025048	hash-keys	2025-12-15 04:06:13.240948+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9940386
20251214050638	scanopy	2025-12-15 04:06:13.251181+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1461284
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
73de8696-9c7d-4a5c-9152-75136cc01387	9bc99b91171dbabe4c299b356e233a16387f7842ba637b968b35ea60f0db22fb	c0eb3d78-0298-433f-ae91-5385a31a18d1	Integrated Daemon API Key	2025-12-15 04:06:15.088933+00	2025-12-15 04:07:52.256377+00	2025-12-15 04:07:52.255489+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2	c0eb3d78-0298-433f-ae91-5385a31a18d1	6435bb37-8492-4631-962c-c24b2262e470	2025-12-15 04:06:15.21994+00	2025-12-15 04:07:29.40427+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["a21aebac-72ae-49cf-a13c-77c670787baf"]}	2025-12-15 04:07:29.404766+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
380efb2e-42fc-4655-95bf-32cfec9784db	c0eb3d78-0298-433f-ae91-5385a31a18d1	572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470"}	Self Report	2025-12-15 04:06:15.226774+00	2025-12-15 04:06:15.226774+00	{}
0c9d6347-cc68-408b-9427-99e84bfb8039	c0eb3d78-0298-433f-ae91-5385a31a18d1	572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 04:06:15.234035+00	2025-12-15 04:06:15.234035+00	{}
af3c2df7-7005-48d6-ba69-b4647f5c7c4f	c0eb3d78-0298-433f-ae91-5385a31a18d1	572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "session_id": "8005f5b4-6604-4be3-9a66-156d6ed7d733", "started_at": "2025-12-15T04:06:15.233654986Z", "finished_at": "2025-12-15T04:06:15.320649118Z", "discovery_type": {"type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470"}}}	{"type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470"}	Self Report	2025-12-15 04:06:15.233654+00	2025-12-15 04:06:15.323867+00	{}
42bce4ef-681d-4b0c-912f-bd6b9c432f71	c0eb3d78-0298-433f-ae91-5385a31a18d1	572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "session_id": "23e0a163-2ade-4191-8ad1-e1221e896d9c", "started_at": "2025-12-15T04:06:15.336971187Z", "finished_at": "2025-12-15T04:07:52.253219489Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 04:06:15.336971+00	2025-12-15 04:07:52.255879+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
31f38436-724b-40bf-b03f-0ab6b46d3aa4	c0eb3d78-0298-433f-ae91-5385a31a18d1		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 04:07:52.271231+00	2025-12-15 04:07:52.271231+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
03600f7a-8895-4176-bf2e-021c342220fd	c0eb3d78-0298-433f-ae91-5385a31a18d1	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "2f1c8e0d-0c3d-4de0-857d-9eb85af7978f"}	[{"id": "9c9cb345-3df1-4592-ab02-0148db53a42b", "name": "Internet", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "ip_address": "1.1.1.1", "mac_address": null}]	{49d13b6f-42af-4915-88cc-cbcc1410188b}	[{"id": "43344820-51d8-494b-a564-8912365d43f0", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 04:06:15.062839+00	2025-12-15 04:06:15.072561+00	f	{}
bc5d0267-3f36-4109-b442-95d4260099fe	c0eb3d78-0298-433f-ae91-5385a31a18d1	Google.com	\N	\N	{"type": "ServiceBinding", "config": "b151d69e-3aab-4157-a0d0-df60606ed1fb"}	[{"id": "4e3d5e54-6325-4006-ac13-fe030471db6f", "name": "Internet", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "ip_address": "203.0.113.54", "mac_address": null}]	{c32589e6-f43f-4777-a117-7268249f0283}	[{"id": "d24d66f2-0377-4d1a-9504-9882c2d98a02", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 04:06:15.062864+00	2025-12-15 04:06:15.078193+00	f	{}
3d0130f7-f689-49ab-82c0-0f46355fbd80	c0eb3d78-0298-433f-ae91-5385a31a18d1	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "16cc31af-86ec-453a-b216-150a7c2d3984"}	[{"id": "e35f4750-e420-4130-9258-e478009c6ae9", "name": "Remote Network", "subnet_id": "a8dc3d88-41ee-4e30-810d-05803eb95f55", "ip_address": "203.0.113.43", "mac_address": null}]	{8b4d31ca-2a43-4512-9f45-b85b6f5062b4}	[{"id": "8dc5d53e-335d-462c-901b-b348e735f4fe", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 04:06:15.062872+00	2025-12-15 04:06:15.082068+00	f	{}
6d55b5b6-6d28-4d46-be1b-e4535e04ae52	c0eb3d78-0298-433f-ae91-5385a31a18d1	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "3e73d6b2-31a7-4f97-94f8-c6781b5e149f", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.6", "mac_address": "76:47:38:3C:4D:D7"}]	{12dd34bf-238d-4e02-b9da-d33d7efc344d}	[{"id": "13d72378-a368-4d44-95b0-9e896ec5e1be", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:01.822254093Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:07:01.822255+00	2025-12-15 04:07:16.670955+00	f	{}
6435bb37-8492-4631-962c-c24b2262e470	c0eb3d78-0298-433f-ae91-5385a31a18d1	scanopy-daemon	869d9f329ba3	Scanopy daemon	{"type": "None"}	[{"id": "6f44986c-0ec7-47bc-b73d-23a5fd9752f9", "name": "eth0", "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.4", "mac_address": "7E:53:5B:57:C7:CB"}]	{8354e041-97c6-47ad-a294-136fe5cd03e9}	[{"id": "ee00d112-a4d0-4465-a8a7-b0bf82145697", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:15.304946390Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}	null	2025-12-15 04:06:15.097833+00	2025-12-15 04:06:15.318383+00	f	{}
02bcb8f5-1672-4b6d-9bb2-2d8e3346d278	c0eb3d78-0298-433f-ae91-5385a31a18d1	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "b21006d8-1dc2-4d99-936a-b695f61806fe", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.5", "mac_address": "32:8F:C7:F5:03:50"}]	{5a03c946-1b4a-4450-97ea-48d1d69375b5,c558aa0f-aeff-4fc5-a3d6-ab06d015b119}	[{"id": "6181ef59-8b02-4283-a265-49dc4c4a6f99", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9feb4a7b-5a4b-47a5-bf70-5886dbbba677", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:46.883426665Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:06:46.88343+00	2025-12-15 04:07:01.81669+00	f	{}
d863ebcb-f943-4856-888c-3ba81984ddaa	c0eb3d78-0298-433f-ae91-5385a31a18d1	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "1aa34e4a-96c2-4a45-be3a-06cf77c2a17b", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.3", "mac_address": "6A:DB:55:6B:BA:03"}]	{7221927e-a39e-460c-bad9-906c39a14b78}	[{"id": "84c05b81-0cf7-4444-941a-e3ac64629ea8", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:16.670032029Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:07:16.670035+00	2025-12-15 04:07:31.446721+00	f	{}
2ec92751-4d89-4901-bdbf-2b6277c4d9e8	c0eb3d78-0298-433f-ae91-5385a31a18d1	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "382aa7c5-0c75-4fca-819b-63cebc283a53", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.1", "mac_address": "5E:47:1E:D7:83:FA"}]	{10034285-13ea-434e-97f6-8dd05cbe5e53,d9336f5d-39a8-4a8b-87c6-85614ab306c6,71190748-0962-4e03-8687-ce4ddc3782a3,3e50a69a-6274-4b51-bd60-9e8e01f6f3d3}	[{"id": "f7b973e4-bcff-4772-bda0-9c839d560722", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ddeb0e62-439a-469f-ab08-5b5bf5e31998", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "70ac68e1-5589-4244-8ffa-79d998f21cfb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "41ccd7b0-bd02-4e5b-b677-0735277ff95e", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:37.500376854Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 04:07:37.500379+00	2025-12-15 04:07:52.246924+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
c0eb3d78-0298-433f-ae91-5385a31a18d1	My Network	2025-12-15 04:06:15.061422+00	2025-12-15 04:06:15.061422+00	f	936335a4-9047-433c-b997-f07c11e751b4	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
936335a4-9047-433c-b997-f07c11e751b4	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 04:06:15.055435+00	2025-12-15 04:07:53.083138+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
49d13b6f-42af-4915-88cc-cbcc1410188b	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.062842+00	2025-12-15 04:06:15.062842+00	Cloudflare DNS	03600f7a-8895-4176-bf2e-021c342220fd	[{"id": "2f1c8e0d-0c3d-4de0-857d-9eb85af7978f", "type": "Port", "port_id": "43344820-51d8-494b-a564-8912365d43f0", "interface_id": "9c9cb345-3df1-4592-ab02-0148db53a42b"}]	"Dns Server"	null	{"type": "System"}	{}
c32589e6-f43f-4777-a117-7268249f0283	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.062866+00	2025-12-15 04:06:15.062866+00	Google.com	bc5d0267-3f36-4109-b442-95d4260099fe	[{"id": "b151d69e-3aab-4157-a0d0-df60606ed1fb", "type": "Port", "port_id": "d24d66f2-0377-4d1a-9504-9882c2d98a02", "interface_id": "4e3d5e54-6325-4006-ac13-fe030471db6f"}]	"Web Service"	null	{"type": "System"}	{}
8b4d31ca-2a43-4512-9f45-b85b6f5062b4	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.062874+00	2025-12-15 04:06:15.062874+00	Mobile Device	3d0130f7-f689-49ab-82c0-0f46355fbd80	[{"id": "16cc31af-86ec-453a-b216-150a7c2d3984", "type": "Port", "port_id": "8dc5d53e-335d-462c-901b-b348e735f4fe", "interface_id": "e35f4750-e420-4130-9258-e478009c6ae9"}]	"Client"	null	{"type": "System"}	{}
8354e041-97c6-47ad-a294-136fe5cd03e9	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.304968+00	2025-12-15 04:06:15.304968+00	Scanopy Daemon	6435bb37-8492-4631-962c-c24b2262e470	[{"id": "80436d60-3025-4685-9f64-88efa42a5bd6", "type": "Port", "port_id": "ee00d112-a4d0-4465-a8a7-b0bf82145697", "interface_id": "6f44986c-0ec7-47bc-b73d-23a5fd9752f9"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T04:06:15.304967479Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}	{}
5a03c946-1b4a-4450-97ea-48d1d69375b5	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:55.851144+00	2025-12-15 04:06:55.851144+00	Home Assistant	02bcb8f5-1672-4b6d-9bb2-2d8e3346d278	[{"id": "9084f382-172e-4523-be91-ba00e04e9069", "type": "Port", "port_id": "6181ef59-8b02-4283-a265-49dc4c4a6f99", "interface_id": "b21006d8-1dc2-4d99-936a-b695f61806fe"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:06:55.851125847Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c558aa0f-aeff-4fc5-a3d6-ab06d015b119	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:01.746797+00	2025-12-15 04:07:01.746797+00	Unclaimed Open Ports	02bcb8f5-1672-4b6d-9bb2-2d8e3346d278	[{"id": "d1168cd8-17ed-4a98-bc5f-b5366d6bec60", "type": "Port", "port_id": "9feb4a7b-5a4b-47a5-bf70-5886dbbba677", "interface_id": "b21006d8-1dc2-4d99-936a-b695f61806fe"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:01.746778189Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
12dd34bf-238d-4e02-b9da-d33d7efc344d	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:16.634635+00	2025-12-15 04:07:16.634635+00	PostgreSQL	6d55b5b6-6d28-4d46-be1b-e4535e04ae52	[{"id": "3fc97aa4-8c19-443e-b8a0-b0205470b3a1", "type": "Port", "port_id": "13d72378-a368-4d44-95b0-9e896ec5e1be", "interface_id": "3e73d6b2-31a7-4f97-94f8-c6781b5e149f"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:16.634617351Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7221927e-a39e-460c-bad9-906c39a14b78	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:25.531968+00	2025-12-15 04:07:25.531968+00	Scanopy Server	d863ebcb-f943-4856-888c-3ba81984ddaa	[{"id": "0ccac727-7907-4e32-86b9-19446b6b5f50", "type": "Port", "port_id": "84c05b81-0cf7-4444-941a-e3ac64629ea8", "interface_id": "1aa34e4a-96c2-4a45-be3a-06cf77c2a17b"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:25.531950619Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
10034285-13ea-434e-97f6-8dd05cbe5e53	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:46.315758+00	2025-12-15 04:07:46.315758+00	Home Assistant	2ec92751-4d89-4901-bdbf-2b6277c4d9e8	[{"id": "21ff327c-7894-4791-b529-51811d465eeb", "type": "Port", "port_id": "f7b973e4-bcff-4772-bda0-9c839d560722", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:46.315739511Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d9336f5d-39a8-4a8b-87c6-85614ab306c6	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:46.316999+00	2025-12-15 04:07:46.316999+00	Scanopy Server	2ec92751-4d89-4901-bdbf-2b6277c4d9e8	[{"id": "f06fcc98-37d9-4831-9ee0-2421829b5332", "type": "Port", "port_id": "ddeb0e62-439a-469f-ab08-5b5bf5e31998", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:46.316990742Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
71190748-0962-4e03-8687-ce4ddc3782a3	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:52.234273+00	2025-12-15 04:07:52.234273+00	SSH	2ec92751-4d89-4901-bdbf-2b6277c4d9e8	[{"id": "f0ad8792-757d-451a-b20d-67d814476809", "type": "Port", "port_id": "70ac68e1-5589-4244-8ffa-79d998f21cfb", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:52.234257111Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3e50a69a-6274-4b51-bd60-9e8e01f6f3d3	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:07:52.234455+00	2025-12-15 04:07:52.234455+00	Unclaimed Open Ports	2ec92751-4d89-4901-bdbf-2b6277c4d9e8	[{"id": "adb92665-8ce8-4cf2-98d2-442346bd9145", "type": "Port", "port_id": "41ccd7b0-bd02-4e5b-b677-0735277ff95e", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:52.234445582Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
2732e9af-0fce-4d38-83f0-ab377fe76362	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.062789+00	2025-12-15 04:06:15.062789+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
a8dc3d88-41ee-4e30-810d-05803eb95f55	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.062792+00	2025-12-15 04:06:15.062792+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
a21aebac-72ae-49cf-a13c-77c670787baf	c0eb3d78-0298-433f-ae91-5385a31a18d1	2025-12-15 04:06:15.233814+00	2025-12-15 04:06:15.233814+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:15.233812911Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
fc62fb86-c467-47cb-b0b2-3a7b56951dbd	936335a4-9047-433c-b997-f07c11e751b4	New Tag	\N	2025-12-15 04:07:52.279606+00	2025-12-15 04:07:52.279606+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
6c6ec101-41d9-484f-812a-230612556471	c0eb3d78-0298-433f-ae91-5385a31a18d1	My Topology	[]	[{"id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "a8dc3d88-41ee-4e30-810d-05803eb95f55", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "9c9cb345-3df1-4592-ab02-0148db53a42b", "size": {"x": 250, "y": 100}, "header": null, "host_id": "03600f7a-8895-4176-bf2e-021c342220fd", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "interface_id": "9c9cb345-3df1-4592-ab02-0148db53a42b"}, {"id": "4e3d5e54-6325-4006-ac13-fe030471db6f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "bc5d0267-3f36-4109-b442-95d4260099fe", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "interface_id": "4e3d5e54-6325-4006-ac13-fe030471db6f"}, {"id": "e35f4750-e420-4130-9258-e478009c6ae9", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3d0130f7-f689-49ab-82c0-0f46355fbd80", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "a8dc3d88-41ee-4e30-810d-05803eb95f55", "interface_id": "e35f4750-e420-4130-9258-e478009c6ae9"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "03600f7a-8895-4176-bf2e-021c342220fd", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "43344820-51d8-494b-a564-8912365d43f0", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "2f1c8e0d-0c3d-4de0-857d-9eb85af7978f"}, "hostname": null, "services": ["49d13b6f-42af-4915-88cc-cbcc1410188b"], "created_at": "2025-12-15T04:06:15.062839Z", "interfaces": [{"id": "9c9cb345-3df1-4592-ab02-0148db53a42b", "name": "Internet", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.072561Z", "description": null, "virtualization": null}, {"id": "bc5d0267-3f36-4109-b442-95d4260099fe", "name": "Google.com", "tags": [], "ports": [{"id": "d24d66f2-0377-4d1a-9504-9882c2d98a02", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "b151d69e-3aab-4157-a0d0-df60606ed1fb"}, "hostname": null, "services": ["c32589e6-f43f-4777-a117-7268249f0283"], "created_at": "2025-12-15T04:06:15.062864Z", "interfaces": [{"id": "4e3d5e54-6325-4006-ac13-fe030471db6f", "name": "Internet", "subnet_id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "ip_address": "203.0.113.54", "mac_address": null}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.078193Z", "description": null, "virtualization": null}, {"id": "3d0130f7-f689-49ab-82c0-0f46355fbd80", "name": "Mobile Device", "tags": [], "ports": [{"id": "8dc5d53e-335d-462c-901b-b348e735f4fe", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "16cc31af-86ec-453a-b216-150a7c2d3984"}, "hostname": null, "services": ["8b4d31ca-2a43-4512-9f45-b85b6f5062b4"], "created_at": "2025-12-15T04:06:15.062872Z", "interfaces": [{"id": "e35f4750-e420-4130-9258-e478009c6ae9", "name": "Remote Network", "subnet_id": "a8dc3d88-41ee-4e30-810d-05803eb95f55", "ip_address": "203.0.113.43", "mac_address": null}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.082068Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "6435bb37-8492-4631-962c-c24b2262e470", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "ee00d112-a4d0-4465-a8a7-b0bf82145697", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:15.304946390Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}, "target": {"type": "None"}, "hostname": "869d9f329ba3", "services": ["8354e041-97c6-47ad-a294-136fe5cd03e9"], "created_at": "2025-12-15T04:06:15.097833Z", "interfaces": [{"id": "6f44986c-0ec7-47bc-b73d-23a5fd9752f9", "name": "eth0", "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.4", "mac_address": "7E:53:5B:57:C7:CB"}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.318383Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "02bcb8f5-1672-4b6d-9bb2-2d8e3346d278", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "6181ef59-8b02-4283-a265-49dc4c4a6f99", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9feb4a7b-5a4b-47a5-bf70-5886dbbba677", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:46.883426665Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["5a03c946-1b4a-4450-97ea-48d1d69375b5", "c558aa0f-aeff-4fc5-a3d6-ab06d015b119"], "created_at": "2025-12-15T04:06:46.883430Z", "interfaces": [{"id": "b21006d8-1dc2-4d99-936a-b695f61806fe", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.5", "mac_address": "32:8F:C7:F5:03:50"}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:01.816690Z", "description": null, "virtualization": null}, {"id": "6d55b5b6-6d28-4d46-be1b-e4535e04ae52", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "13d72378-a368-4d44-95b0-9e896ec5e1be", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:01.822254093Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["12dd34bf-238d-4e02-b9da-d33d7efc344d"], "created_at": "2025-12-15T04:07:01.822255Z", "interfaces": [{"id": "3e73d6b2-31a7-4f97-94f8-c6781b5e149f", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.6", "mac_address": "76:47:38:3C:4D:D7"}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:16.670955Z", "description": null, "virtualization": null}, {"id": "d863ebcb-f943-4856-888c-3ba81984ddaa", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "84c05b81-0cf7-4444-941a-e3ac64629ea8", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:16.670032029Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["7221927e-a39e-460c-bad9-906c39a14b78"], "created_at": "2025-12-15T04:07:16.670035Z", "interfaces": [{"id": "1aa34e4a-96c2-4a45-be3a-06cf77c2a17b", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.3", "mac_address": "6A:DB:55:6B:BA:03"}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:31.446721Z", "description": null, "virtualization": null}, {"id": "2ec92751-4d89-4901-bdbf-2b6277c4d9e8", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "f7b973e4-bcff-4772-bda0-9c839d560722", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ddeb0e62-439a-469f-ab08-5b5bf5e31998", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "70ac68e1-5589-4244-8ffa-79d998f21cfb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "41ccd7b0-bd02-4e5b-b677-0735277ff95e", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:07:37.500376854Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["10034285-13ea-434e-97f6-8dd05cbe5e53", "d9336f5d-39a8-4a8b-87c6-85614ab306c6", "71190748-0962-4e03-8687-ce4ddc3782a3", "3e50a69a-6274-4b51-bd60-9e8e01f6f3d3"], "created_at": "2025-12-15T04:07:37.500379Z", "interfaces": [{"id": "382aa7c5-0c75-4fca-819b-63cebc283a53", "name": null, "subnet_id": "a21aebac-72ae-49cf-a13c-77c670787baf", "ip_address": "172.25.0.1", "mac_address": "5E:47:1E:D7:83:FA"}], "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:52.246924Z", "description": null, "virtualization": null}]	[{"id": "2732e9af-0fce-4d38-83f0-ab377fe76362", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T04:06:15.062789Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.062789Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "a8dc3d88-41ee-4e30-810d-05803eb95f55", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T04:06:15.062792Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.062792Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "a21aebac-72ae-49cf-a13c-77c670787baf", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T04:06:15.233812911Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}, "created_at": "2025-12-15T04:06:15.233814Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.233814Z", "description": null, "subnet_type": "Lan"}]	[{"id": "49d13b6f-42af-4915-88cc-cbcc1410188b", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "03600f7a-8895-4176-bf2e-021c342220fd", "bindings": [{"id": "2f1c8e0d-0c3d-4de0-857d-9eb85af7978f", "type": "Port", "port_id": "43344820-51d8-494b-a564-8912365d43f0", "interface_id": "9c9cb345-3df1-4592-ab02-0148db53a42b"}], "created_at": "2025-12-15T04:06:15.062842Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.062842Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "c32589e6-f43f-4777-a117-7268249f0283", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "bc5d0267-3f36-4109-b442-95d4260099fe", "bindings": [{"id": "b151d69e-3aab-4157-a0d0-df60606ed1fb", "type": "Port", "port_id": "d24d66f2-0377-4d1a-9504-9882c2d98a02", "interface_id": "4e3d5e54-6325-4006-ac13-fe030471db6f"}], "created_at": "2025-12-15T04:06:15.062866Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.062866Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "8b4d31ca-2a43-4512-9f45-b85b6f5062b4", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "3d0130f7-f689-49ab-82c0-0f46355fbd80", "bindings": [{"id": "16cc31af-86ec-453a-b216-150a7c2d3984", "type": "Port", "port_id": "8dc5d53e-335d-462c-901b-b348e735f4fe", "interface_id": "e35f4750-e420-4130-9258-e478009c6ae9"}], "created_at": "2025-12-15T04:06:15.062874Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.062874Z", "virtualization": null, "service_definition": "Client"}, {"id": "8354e041-97c6-47ad-a294-136fe5cd03e9", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T04:06:15.304967479Z", "type": "SelfReport", "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2"}]}, "host_id": "6435bb37-8492-4631-962c-c24b2262e470", "bindings": [{"id": "80436d60-3025-4685-9f64-88efa42a5bd6", "type": "Port", "port_id": "ee00d112-a4d0-4465-a8a7-b0bf82145697", "interface_id": "6f44986c-0ec7-47bc-b73d-23a5fd9752f9"}], "created_at": "2025-12-15T04:06:15.304968Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:15.304968Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "5a03c946-1b4a-4450-97ea-48d1d69375b5", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:06:55.851125847Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "02bcb8f5-1672-4b6d-9bb2-2d8e3346d278", "bindings": [{"id": "9084f382-172e-4523-be91-ba00e04e9069", "type": "Port", "port_id": "6181ef59-8b02-4283-a265-49dc4c4a6f99", "interface_id": "b21006d8-1dc2-4d99-936a-b695f61806fe"}], "created_at": "2025-12-15T04:06:55.851144Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:06:55.851144Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "c558aa0f-aeff-4fc5-a3d6-ab06d015b119", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:01.746778189Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "02bcb8f5-1672-4b6d-9bb2-2d8e3346d278", "bindings": [{"id": "d1168cd8-17ed-4a98-bc5f-b5366d6bec60", "type": "Port", "port_id": "9feb4a7b-5a4b-47a5-bf70-5886dbbba677", "interface_id": "b21006d8-1dc2-4d99-936a-b695f61806fe"}], "created_at": "2025-12-15T04:07:01.746797Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:01.746797Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "12dd34bf-238d-4e02-b9da-d33d7efc344d", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:16.634617351Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "6d55b5b6-6d28-4d46-be1b-e4535e04ae52", "bindings": [{"id": "3fc97aa4-8c19-443e-b8a0-b0205470b3a1", "type": "Port", "port_id": "13d72378-a368-4d44-95b0-9e896ec5e1be", "interface_id": "3e73d6b2-31a7-4f97-94f8-c6781b5e149f"}], "created_at": "2025-12-15T04:07:16.634635Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:16.634635Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "7221927e-a39e-460c-bad9-906c39a14b78", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:25.531950619Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d863ebcb-f943-4856-888c-3ba81984ddaa", "bindings": [{"id": "0ccac727-7907-4e32-86b9-19446b6b5f50", "type": "Port", "port_id": "84c05b81-0cf7-4444-941a-e3ac64629ea8", "interface_id": "1aa34e4a-96c2-4a45-be3a-06cf77c2a17b"}], "created_at": "2025-12-15T04:07:25.531968Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:25.531968Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "10034285-13ea-434e-97f6-8dd05cbe5e53", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:46.315739511Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2ec92751-4d89-4901-bdbf-2b6277c4d9e8", "bindings": [{"id": "21ff327c-7894-4791-b529-51811d465eeb", "type": "Port", "port_id": "f7b973e4-bcff-4772-bda0-9c839d560722", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}], "created_at": "2025-12-15T04:07:46.315758Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:46.315758Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "d9336f5d-39a8-4a8b-87c6-85614ab306c6", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T04:07:46.316990742Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2ec92751-4d89-4901-bdbf-2b6277c4d9e8", "bindings": [{"id": "f06fcc98-37d9-4831-9ee0-2421829b5332", "type": "Port", "port_id": "ddeb0e62-439a-469f-ab08-5b5bf5e31998", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}], "created_at": "2025-12-15T04:07:46.316999Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:46.316999Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "71190748-0962-4e03-8687-ce4ddc3782a3", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:52.234257111Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2ec92751-4d89-4901-bdbf-2b6277c4d9e8", "bindings": [{"id": "f0ad8792-757d-451a-b20d-67d814476809", "type": "Port", "port_id": "70ac68e1-5589-4244-8ffa-79d998f21cfb", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}], "created_at": "2025-12-15T04:07:52.234273Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:52.234273Z", "virtualization": null, "service_definition": "SSH"}, {"id": "3e50a69a-6274-4b51-bd60-9e8e01f6f3d3", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T04:07:52.234445582Z", "type": "Network", "daemon_id": "572a7ed9-25d1-4fdf-ae42-a0a62ff31ce2", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2ec92751-4d89-4901-bdbf-2b6277c4d9e8", "bindings": [{"id": "adb92665-8ce8-4cf2-98d2-442346bd9145", "type": "Port", "port_id": "41ccd7b0-bd02-4e5b-b677-0735277ff95e", "interface_id": "382aa7c5-0c75-4fca-819b-63cebc283a53"}], "created_at": "2025-12-15T04:07:52.234455Z", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:52.234455Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "31f38436-724b-40bf-b03f-0ab6b46d3aa4", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T04:07:52.271231Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "c0eb3d78-0298-433f-ae91-5385a31a18d1", "updated_at": "2025-12-15T04:07:52.271231Z", "description": null, "service_bindings": []}]	t	2025-12-15 04:06:15.08632+00	f	\N	\N	{755ef826-ee89-419f-8f43-caa723d4251b,97e53469-cff3-4e8e-9ccd-edb6bd7a98ba,cf7b193f-9c71-466a-92b7-b0efdc83ea47}	{e75bc1b0-fd34-4218-9f02-1f526dca5058}	{d8f48b6c-f3d2-4eaa-ba9f-93ea5c39e568}	{a1ecc8ff-98df-49d7-8d97-3f90424a5600}	\N	2025-12-15 04:06:15.082862+00	2025-12-15 04:07:53.933345+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
3d70a391-affc-483e-9c6b-1d462ecbaaba	2025-12-15 04:06:15.058225+00	2025-12-15 04:06:15.058225+00	$argon2id$v=19$m=19456,t=2,p=1$6AaUsnkKgMWNim97YpegWQ$9oGfLKr5eJhjLIxQxABF4r+ljUctQ9ZJxitfB7LddRg	\N	\N	\N	user@gmail.com	936335a4-9047-433c-b997-f07c11e751b4	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
lz3jB-uJhFDf9sBwR3CmhA	\\x93c41084a6704770c0f6df508489eb07e33d9781a7757365725f6964d92433643730613339312d616666632d343833652d396336622d31643436326563626161626199cd07ea0e04060fce0e77093f000000	2026-01-14 04:06:15.242682+00
NPhPM73CZZczuSQqQy7BWg	\\x93c4105ac12e432a24b9339765c2bd334ff83482ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92431353633313039352d333366362d343363312d623133622d613132656331316434363830ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92433643730613339312d616666632d343833652d396336622d31643436326563626161626199cd07ea0e040734ce31616e96000000	2026-01-14 04:07:52.828468+00
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

\unrestrict 2GwNw8zpZO6WrEqkR4b6mwiypZWgBsHSMy53g62Mn9PSnpVLHJnU0GPdLN7hSQ5

