--
-- PostgreSQL database dump
--

\restrict mW28zmkwLd4WZYNqC9bRhMw4WjamzDonNdlKI69L0hHFePJW2NJJCymUec4Qa8I

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
20251006215000	users	2025-12-17 16:12:04.549578+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3554613
20251006215100	networks	2025-12-17 16:12:04.553877+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3835790
20251006215151	create hosts	2025-12-17 16:12:04.558073+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3936559
20251006215155	create subnets	2025-12-17 16:12:04.562395+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4058402
20251006215201	create groups	2025-12-17 16:12:04.566793+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3753653
20251006215204	create daemons	2025-12-17 16:12:04.572216+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4204709
20251006215212	create services	2025-12-17 16:12:04.576777+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4882211
20251029193448	user-auth	2025-12-17 16:12:04.582016+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4173000
20251030044828	daemon api	2025-12-17 16:12:04.58652+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1529207
20251030170438	host-hide	2025-12-17 16:12:04.588366+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1214474
20251102224919	create discovery	2025-12-17 16:12:04.589894+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9555973
20251106235621	normalize-daemon-cols	2025-12-17 16:12:04.599761+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1815222
20251107034459	api keys	2025-12-17 16:12:04.601882+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8091226
20251107222650	oidc-auth	2025-12-17 16:12:04.610363+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	22298327
20251110181948	orgs-billing	2025-12-17 16:12:04.633016+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11475471
20251113223656	group-enhancements	2025-12-17 16:12:04.644825+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1133815
20251117032720	daemon-mode	2025-12-17 16:12:04.646255+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1147602
20251118143058	set-default-plan	2025-12-17 16:12:04.647683+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1214176
20251118225043	save-topology	2025-12-17 16:12:04.649204+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9760736
20251123232748	network-permissions	2025-12-17 16:12:04.659303+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2915164
20251125001342	billing-updates	2025-12-17 16:12:04.662515+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	912961
20251128035448	org-onboarding-status	2025-12-17 16:12:04.663703+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1521161
20251129180942	nfs-consolidate	2025-12-17 16:12:04.665561+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1278366
20251206052641	discovery-progress	2025-12-17 16:12:04.667127+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1550797
20251206202200	plan-fix	2025-12-17 16:12:04.669009+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	953598
20251207061341	daemon-url	2025-12-17 16:12:04.670267+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2432109
20251210045929	tags	2025-12-17 16:12:04.672982+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8978966
20251210175035	terms	2025-12-17 16:12:04.682346+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	886772
20251213025048	hash-keys	2025-12-17 16:12:04.686024+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	7031660
20251214050638	scanopy	2025-12-17 16:12:04.693351+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1354809
20251215215724	topo-scanopy-fix	2025-12-17 16:12:04.69499+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	755986
20251217153736	category rename	2025-12-17 16:12:04.696054+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1637550
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
6eaaf31a-d059-4d92-8f48-0471eb689842	7985ff2c0c4dc92cc539a8a13c83f1a6f1477db6d8796d33ccf0fbeb503bb7b4	61cd097d-8a08-4123-93c9-a70333f82c88	Integrated Daemon API Key	2025-12-17 16:12:07.880335+00	2025-12-17 16:13:45.424857+00	2025-12-17 16:13:45.423976+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
35f8042f-2b6c-400f-a1cd-5d7a70acff3b	61cd097d-8a08-4123-93c9-a70333f82c88	59bd3722-96e2-492b-b5a8-0b0cc884ffac	2025-12-17 16:12:07.926963+00	2025-12-17 16:13:25.723252+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["d240adbe-49d5-4dc4-b74a-29947aa17ad7"]}	2025-12-17 16:13:25.723782+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
1ef28ef1-e5c2-479a-9929-7031797cde0d	61cd097d-8a08-4123-93c9-a70333f82c88	35f8042f-2b6c-400f-a1cd-5d7a70acff3b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac"}	Self Report	2025-12-17 16:12:07.98115+00	2025-12-17 16:12:07.98115+00	{}
81c4df11-dc71-40df-b151-9e19c52a66ef	61cd097d-8a08-4123-93c9-a70333f82c88	35f8042f-2b6c-400f-a1cd-5d7a70acff3b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-17 16:12:07.988742+00	2025-12-17 16:12:07.988742+00	{}
4321c183-a7e0-4bea-b5a5-cdecc6d37224	61cd097d-8a08-4123-93c9-a70333f82c88	35f8042f-2b6c-400f-a1cd-5d7a70acff3b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "session_id": "eb55a15a-3560-465e-829b-f5f6190c01fb", "started_at": "2025-12-17T16:12:07.988320790Z", "finished_at": "2025-12-17T16:12:08.063878696Z", "discovery_type": {"type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac"}}}	{"type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac"}	Self Report	2025-12-17 16:12:07.98832+00	2025-12-17 16:12:08.067011+00	{}
7d180bcc-6e7e-4caa-9814-1f08fda908aa	61cd097d-8a08-4123-93c9-a70333f82c88	35f8042f-2b6c-400f-a1cd-5d7a70acff3b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "session_id": "7e2f6748-642a-4a0a-957f-715fb1ceb4bb", "started_at": "2025-12-17T16:12:08.079125749Z", "finished_at": "2025-12-17T16:13:45.421582055Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-17 16:12:08.079125+00	2025-12-17 16:13:45.424248+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
6a0c3575-172a-4f50-8dad-2fff98483633	61cd097d-8a08-4123-93c9-a70333f82c88		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-17 16:13:45.437649+00	2025-12-17 16:13:45.437649+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
0e019836-d7af-4d74-8e28-7e13642930f8	61cd097d-8a08-4123-93c9-a70333f82c88	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "c76bbc29-7270-4521-8890-7a91e9a33158"}	[{"id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56", "name": "Internet", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "ip_address": "1.1.1.1", "mac_address": null}]	{aca12cf2-1ac0-441a-a558-cc18f3d75162}	[{"id": "3b6a45d8-2e4c-48d4-9d8f-b145f0460a7e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-17 16:12:07.855547+00	2025-12-17 16:12:07.865057+00	f	{}
c6d0a55f-1d85-41c2-83db-96eeeaede8e1	61cd097d-8a08-4123-93c9-a70333f82c88	Google.com	\N	\N	{"type": "ServiceBinding", "config": "63017808-b3ed-4d6d-a7d2-b0d8172f03d0"}	[{"id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91", "name": "Internet", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "ip_address": "203.0.113.3", "mac_address": null}]	{73ca3a5b-0bd4-4ea4-9571-7e08d5da9a47}	[{"id": "5cd23a41-7d05-4f88-a289-aeab9581e44b", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-17 16:12:07.855557+00	2025-12-17 16:12:07.870352+00	f	{}
672e3e21-aa9f-4d78-be98-ee2dd2297e25	61cd097d-8a08-4123-93c9-a70333f82c88	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "7f986205-8704-456d-8252-965220ac30d4"}	[{"id": "dac5bae1-df36-4e64-9700-f5196792a3ab", "name": "Remote Network", "subnet_id": "dc528c99-c4df-46fc-a6eb-a247cbf04024", "ip_address": "203.0.113.228", "mac_address": null}]	{3967d3b7-4996-4389-9f0a-71bfc132538e}	[{"id": "78ff4a25-781e-4225-8464-5153cee771a0", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-17 16:12:07.855565+00	2025-12-17 16:12:07.87387+00	f	{}
89fee0f6-ab2d-4cb8-808c-baa9c00cc1be	61cd097d-8a08-4123-93c9-a70333f82c88	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "2e4bb2e0-241c-4543-9002-cac399c5a9a8", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.3", "mac_address": "76:02:8D:99:4C:1A"}]	{395f3c78-7ac0-4e3f-b95c-3957e043f495}	[{"id": "70d3c019-f984-416c-9b8f-38b776eb7ada", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:55.293906153Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-17 16:12:55.293908+00	2025-12-17 16:13:10.018503+00	f	{}
59bd3722-96e2-492b-b5a8-0b0cc884ffac	61cd097d-8a08-4123-93c9-a70333f82c88	scanopy-daemon	2041c0e37b4e	Scanopy daemon	{"type": "None"}	[{"id": "49b0c0fc-c008-46ec-b958-f5edd661143b", "name": "eth0", "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.4", "mac_address": "D6:79:E9:2C:38:58"}]	{de8cc6b3-0490-4a5f-9d26-a0d589ac462b}	[{"id": "05450eea-dd1d-4011-a9c6-f5d531f03987", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:08.045378250Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}	null	2025-12-17 16:12:07.888627+00	2025-12-17 16:12:08.061724+00	f	{}
e7eeeaf6-3b3c-4db3-a1a8-368eac9925b9	61cd097d-8a08-4123-93c9-a70333f82c88	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "f7ca2b30-db19-4e53-9046-56b4046d8724", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.6", "mac_address": "12:78:1C:65:99:AA"}]	{4102b303-292d-48f1-a02a-34a711312bb0}	[{"id": "ec77dee5-4119-47b8-b34b-3dba72ed40f2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:40.449904755Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-17 16:12:40.449907+00	2025-12-17 16:12:55.240988+00	f	{}
2d3f9ac2-95b4-4cf9-9e9e-50e1c0e159bc	61cd097d-8a08-4123-93c9-a70333f82c88	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "84f910a9-e1f1-4557-a67e-a195890ec00f", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.5", "mac_address": "22:98:74:FF:5F:D4"}]	{98495581-3d54-41b2-994b-3d5f9f417a10}	[{"id": "2cb8a60f-fc06-40f4-86b8-8b4c9850fa7e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9b006265-84df-4da5-88c8-dac0c1953303", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:13:10.015540581Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-17 16:13:10.015543+00	2025-12-17 16:13:24.684232+00	f	{}
c072fc8a-5849-4da0-b95c-dc0fe477cb69	61cd097d-8a08-4123-93c9-a70333f82c88	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "01c49c08-417d-45a6-9267-1c40bac670c6", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.1", "mac_address": "66:75:2E:6D:05:A2"}]	{2c130f94-23fe-43ea-a1e3-5fae7155f22e,fa50ecb6-7c0f-4686-ac44-0db92dc9da44,ee020a6d-bfac-4a90-9a81-18760ce5550b,269b7ee3-639c-4cd2-88d6-42c315ff019c}	[{"id": "1265ed85-4116-4ca4-8e4c-51e8bc690d81", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "0b324270-2f06-4585-91bb-b1b61dd8cae1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "55d2b2f9-d289-47b0-b9db-60f4ea46d99f", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "8d383064-c1b9-45cd-b959-2a5cc2f18897", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:13:30.743106820Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-17 16:13:30.74311+00	2025-12-17 16:13:45.416068+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
61cd097d-8a08-4123-93c9-a70333f82c88	My Network	2025-12-17 16:12:07.854208+00	2025-12-17 16:12:07.854208+00	f	94c8c05e-5761-407c-aa7a-3043de411cca	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
94c8c05e-5761-407c-aa7a-3043de411cca	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-17 16:12:07.848361+00	2025-12-17 16:13:46.237774+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
aca12cf2-1ac0-441a-a558-cc18f3d75162	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.855549+00	2025-12-17 16:12:07.855549+00	Cloudflare DNS	0e019836-d7af-4d74-8e28-7e13642930f8	[{"id": "c76bbc29-7270-4521-8890-7a91e9a33158", "type": "Port", "port_id": "3b6a45d8-2e4c-48d4-9d8f-b145f0460a7e", "interface_id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56"}]	"Dns Server"	null	{"type": "System"}	{}
73ca3a5b-0bd4-4ea4-9571-7e08d5da9a47	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.855559+00	2025-12-17 16:12:07.855559+00	Google.com	c6d0a55f-1d85-41c2-83db-96eeeaede8e1	[{"id": "63017808-b3ed-4d6d-a7d2-b0d8172f03d0", "type": "Port", "port_id": "5cd23a41-7d05-4f88-a289-aeab9581e44b", "interface_id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91"}]	"Web Service"	null	{"type": "System"}	{}
3967d3b7-4996-4389-9f0a-71bfc132538e	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.855567+00	2025-12-17 16:12:07.855567+00	Mobile Device	672e3e21-aa9f-4d78-be98-ee2dd2297e25	[{"id": "7f986205-8704-456d-8252-965220ac30d4", "type": "Port", "port_id": "78ff4a25-781e-4225-8464-5153cee771a0", "interface_id": "dac5bae1-df36-4e64-9700-f5196792a3ab"}]	"Client"	null	{"type": "System"}	{}
de8cc6b3-0490-4a5f-9d26-a0d589ac462b	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:08.045403+00	2025-12-17 16:12:08.045403+00	Scanopy Daemon	59bd3722-96e2-492b-b5a8-0b0cc884ffac	[{"id": "9d8ed597-64b1-4bcc-8290-f1010939267f", "type": "Port", "port_id": "05450eea-dd1d-4011-a9c6-f5d531f03987", "interface_id": "49b0c0fc-c008-46ec-b958-f5edd661143b"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-17T16:12:08.045402155Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}	{}
4102b303-292d-48f1-a02a-34a711312bb0	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:55.225178+00	2025-12-17 16:12:55.225178+00	PostgreSQL	e7eeeaf6-3b3c-4db3-a1a8-368eac9925b9	[{"id": "22aad0ae-3f44-48a0-86ea-3bee6c7384ad", "type": "Port", "port_id": "ec77dee5-4119-47b8-b34b-3dba72ed40f2", "interface_id": "f7ca2b30-db19-4e53-9046-56b4046d8724"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:12:55.225160805Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
395f3c78-7ac0-4e3f-b95c-3957e043f495	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:02.658595+00	2025-12-17 16:13:02.658595+00	Scanopy Server	89fee0f6-ab2d-4cb8-808c-baa9c00cc1be	[{"id": "5a21d973-a18b-4781-8706-367096ed6960", "type": "Port", "port_id": "70d3c019-f984-416c-9b8f-38b776eb7ada", "interface_id": "2e4bb2e0-241c-4543-9002-cac399c5a9a8"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:02.658580004Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
98495581-3d54-41b2-994b-3d5f9f417a10	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:24.675747+00	2025-12-17 16:13:24.675747+00	Unclaimed Open Ports	2d3f9ac2-95b4-4cf9-9e9e-50e1c0e159bc	[{"id": "44bad034-8e42-4d21-828c-a2b2a2b74e0f", "type": "Port", "port_id": "2cb8a60f-fc06-40f4-86b8-8b4c9850fa7e", "interface_id": "84f910a9-e1f1-4557-a67e-a195890ec00f"}, {"id": "6c2243ab-132e-44ad-a8f4-3fec827c84d9", "type": "Port", "port_id": "9b006265-84df-4da5-88c8-dac0c1953303", "interface_id": "84f910a9-e1f1-4557-a67e-a195890ec00f"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:24.675731107Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2c130f94-23fe-43ea-a1e3-5fae7155f22e	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:38.130817+00	2025-12-17 16:13:38.130817+00	Scanopy Server	c072fc8a-5849-4da0-b95c-dc0fe477cb69	[{"id": "222f12c1-b0fb-4ffe-b266-79ed3dd12ec8", "type": "Port", "port_id": "1265ed85-4116-4ca4-8e4c-51e8bc690d81", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:38.130798544Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
269b7ee3-639c-4cd2-88d6-42c315ff019c	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:45.403519+00	2025-12-17 16:13:45.403519+00	Unclaimed Open Ports	c072fc8a-5849-4da0-b95c-dc0fe477cb69	[{"id": "8d178eaf-0937-4a2a-9fcc-202e972c2d77", "type": "Port", "port_id": "8d383064-c1b9-45cd-b959-2a5cc2f18897", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:45.403510754Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
fa50ecb6-7c0f-4686-ac44-0db92dc9da44	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:43.225406+00	2025-12-17 16:13:43.225406+00	Home Assistant	c072fc8a-5849-4da0-b95c-dc0fe477cb69	[{"id": "c6482c69-82f8-4334-8a70-a4de9da2abb2", "type": "Port", "port_id": "0b324270-2f06-4585-91bb-b1b61dd8cae1", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:43.225393119Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ee020a6d-bfac-4a90-9a81-18760ce5550b	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:13:45.40297+00	2025-12-17 16:13:45.40297+00	SSH	c072fc8a-5849-4da0-b95c-dc0fe477cb69	[{"id": "03c1b5ff-02e8-4dfc-bf3c-95e3aac8eca9", "type": "Port", "port_id": "55d2b2f9-d289-47b0-b9db-60f4ea46d99f", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:45.402953751Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
e60ccf25-72d7-46b0-ae13-ef77df538fba	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.855494+00	2025-12-17 16:12:07.855494+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
dc528c99-c4df-46fc-a6eb-a247cbf04024	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.855498+00	2025-12-17 16:12:07.855498+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
d240adbe-49d5-4dc4-b74a-29947aa17ad7	61cd097d-8a08-4123-93c9-a70333f82c88	2025-12-17 16:12:07.988511+00	2025-12-17 16:12:07.988511+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:07.988510175Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
40c80662-a8ee-4178-810a-d09923933dd1	94c8c05e-5761-407c-aa7a-3043de411cca	New Tag	\N	2025-12-17 16:13:45.446133+00	2025-12-17 16:13:45.446133+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
08270ecb-bd0f-4808-8751-7d21a46f7264	61cd097d-8a08-4123-93c9-a70333f82c88	My Topology	[]	[{"id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "dc528c99-c4df-46fc-a6eb-a247cbf04024", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0e019836-d7af-4d74-8e28-7e13642930f8", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "interface_id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56"}, {"id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91", "size": {"x": 250, "y": 100}, "header": null, "host_id": "c6d0a55f-1d85-41c2-83db-96eeeaede8e1", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "interface_id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91"}, {"id": "dac5bae1-df36-4e64-9700-f5196792a3ab", "size": {"x": 250, "y": 100}, "header": null, "host_id": "672e3e21-aa9f-4d78-be98-ee2dd2297e25", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "dc528c99-c4df-46fc-a6eb-a247cbf04024", "interface_id": "dac5bae1-df36-4e64-9700-f5196792a3ab"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "0e019836-d7af-4d74-8e28-7e13642930f8", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "3b6a45d8-2e4c-48d4-9d8f-b145f0460a7e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c76bbc29-7270-4521-8890-7a91e9a33158"}, "hostname": null, "services": ["aca12cf2-1ac0-441a-a558-cc18f3d75162"], "created_at": "2025-12-17T16:12:07.855547Z", "interfaces": [{"id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56", "name": "Internet", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.865057Z", "description": null, "virtualization": null}, {"id": "c6d0a55f-1d85-41c2-83db-96eeeaede8e1", "name": "Google.com", "tags": [], "ports": [{"id": "5cd23a41-7d05-4f88-a289-aeab9581e44b", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "63017808-b3ed-4d6d-a7d2-b0d8172f03d0"}, "hostname": null, "services": ["73ca3a5b-0bd4-4ea4-9571-7e08d5da9a47"], "created_at": "2025-12-17T16:12:07.855557Z", "interfaces": [{"id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91", "name": "Internet", "subnet_id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "ip_address": "203.0.113.3", "mac_address": null}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.870352Z", "description": null, "virtualization": null}, {"id": "672e3e21-aa9f-4d78-be98-ee2dd2297e25", "name": "Mobile Device", "tags": [], "ports": [{"id": "78ff4a25-781e-4225-8464-5153cee771a0", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "7f986205-8704-456d-8252-965220ac30d4"}, "hostname": null, "services": ["3967d3b7-4996-4389-9f0a-71bfc132538e"], "created_at": "2025-12-17T16:12:07.855565Z", "interfaces": [{"id": "dac5bae1-df36-4e64-9700-f5196792a3ab", "name": "Remote Network", "subnet_id": "dc528c99-c4df-46fc-a6eb-a247cbf04024", "ip_address": "203.0.113.228", "mac_address": null}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.873870Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "05450eea-dd1d-4011-a9c6-f5d531f03987", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:08.045378250Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}, "target": {"type": "None"}, "hostname": "2041c0e37b4e", "services": ["de8cc6b3-0490-4a5f-9d26-a0d589ac462b"], "created_at": "2025-12-17T16:12:07.888627Z", "interfaces": [{"id": "49b0c0fc-c008-46ec-b958-f5edd661143b", "name": "eth0", "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.4", "mac_address": "D6:79:E9:2C:38:58"}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:08.061724Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "e7eeeaf6-3b3c-4db3-a1a8-368eac9925b9", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "ec77dee5-4119-47b8-b34b-3dba72ed40f2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:40.449904755Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["4102b303-292d-48f1-a02a-34a711312bb0"], "created_at": "2025-12-17T16:12:40.449907Z", "interfaces": [{"id": "f7ca2b30-db19-4e53-9046-56b4046d8724", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.6", "mac_address": "12:78:1C:65:99:AA"}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:55.240988Z", "description": null, "virtualization": null}, {"id": "89fee0f6-ab2d-4cb8-808c-baa9c00cc1be", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "70d3c019-f984-416c-9b8f-38b776eb7ada", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:55.293906153Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["395f3c78-7ac0-4e3f-b95c-3957e043f495"], "created_at": "2025-12-17T16:12:55.293908Z", "interfaces": [{"id": "2e4bb2e0-241c-4543-9002-cac399c5a9a8", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.3", "mac_address": "76:02:8D:99:4C:1A"}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:10.018503Z", "description": null, "virtualization": null}, {"id": "2d3f9ac2-95b4-4cf9-9e9e-50e1c0e159bc", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "2cb8a60f-fc06-40f4-86b8-8b4c9850fa7e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9b006265-84df-4da5-88c8-dac0c1953303", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:13:10.015540581Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["98495581-3d54-41b2-994b-3d5f9f417a10"], "created_at": "2025-12-17T16:13:10.015543Z", "interfaces": [{"id": "84f910a9-e1f1-4557-a67e-a195890ec00f", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.5", "mac_address": "22:98:74:FF:5F:D4"}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:24.684232Z", "description": null, "virtualization": null}, {"id": "c072fc8a-5849-4da0-b95c-dc0fe477cb69", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "1265ed85-4116-4ca4-8e4c-51e8bc690d81", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "0b324270-2f06-4585-91bb-b1b61dd8cae1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "55d2b2f9-d289-47b0-b9db-60f4ea46d99f", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "8d383064-c1b9-45cd-b959-2a5cc2f18897", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:13:30.743106820Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["2c130f94-23fe-43ea-a1e3-5fae7155f22e", "fa50ecb6-7c0f-4686-ac44-0db92dc9da44", "ee020a6d-bfac-4a90-9a81-18760ce5550b", "269b7ee3-639c-4cd2-88d6-42c315ff019c"], "created_at": "2025-12-17T16:13:30.743110Z", "interfaces": [{"id": "01c49c08-417d-45a6-9267-1c40bac670c6", "name": null, "subnet_id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "ip_address": "172.25.0.1", "mac_address": "66:75:2E:6D:05:A2"}], "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:45.416068Z", "description": null, "virtualization": null}]	[{"id": "e60ccf25-72d7-46b0-ae13-ef77df538fba", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-17T16:12:07.855494Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.855494Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "dc528c99-c4df-46fc-a6eb-a247cbf04024", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-17T16:12:07.855498Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.855498Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "d240adbe-49d5-4dc4-b74a-29947aa17ad7", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-17T16:12:07.988510175Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}, "created_at": "2025-12-17T16:12:07.988511Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.988511Z", "description": null, "subnet_type": "Lan"}]	[{"id": "aca12cf2-1ac0-441a-a558-cc18f3d75162", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "0e019836-d7af-4d74-8e28-7e13642930f8", "bindings": [{"id": "c76bbc29-7270-4521-8890-7a91e9a33158", "type": "Port", "port_id": "3b6a45d8-2e4c-48d4-9d8f-b145f0460a7e", "interface_id": "6c6179be-47c1-4825-b3a7-6808cc7aeb56"}], "created_at": "2025-12-17T16:12:07.855549Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.855549Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "73ca3a5b-0bd4-4ea4-9571-7e08d5da9a47", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "c6d0a55f-1d85-41c2-83db-96eeeaede8e1", "bindings": [{"id": "63017808-b3ed-4d6d-a7d2-b0d8172f03d0", "type": "Port", "port_id": "5cd23a41-7d05-4f88-a289-aeab9581e44b", "interface_id": "53a7796c-6dd7-42e4-95e9-b8ad0b01eb91"}], "created_at": "2025-12-17T16:12:07.855559Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.855559Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "3967d3b7-4996-4389-9f0a-71bfc132538e", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "672e3e21-aa9f-4d78-be98-ee2dd2297e25", "bindings": [{"id": "7f986205-8704-456d-8252-965220ac30d4", "type": "Port", "port_id": "78ff4a25-781e-4225-8464-5153cee771a0", "interface_id": "dac5bae1-df36-4e64-9700-f5196792a3ab"}], "created_at": "2025-12-17T16:12:07.855567Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:07.855567Z", "virtualization": null, "service_definition": "Client"}, {"id": "de8cc6b3-0490-4a5f-9d26-a0d589ac462b", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-17T16:12:08.045402155Z", "type": "SelfReport", "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b"}]}, "host_id": "59bd3722-96e2-492b-b5a8-0b0cc884ffac", "bindings": [{"id": "9d8ed597-64b1-4bcc-8290-f1010939267f", "type": "Port", "port_id": "05450eea-dd1d-4011-a9c6-f5d531f03987", "interface_id": "49b0c0fc-c008-46ec-b958-f5edd661143b"}], "created_at": "2025-12-17T16:12:08.045403Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:08.045403Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "4102b303-292d-48f1-a02a-34a711312bb0", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:12:55.225160805Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "e7eeeaf6-3b3c-4db3-a1a8-368eac9925b9", "bindings": [{"id": "22aad0ae-3f44-48a0-86ea-3bee6c7384ad", "type": "Port", "port_id": "ec77dee5-4119-47b8-b34b-3dba72ed40f2", "interface_id": "f7ca2b30-db19-4e53-9046-56b4046d8724"}], "created_at": "2025-12-17T16:12:55.225178Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:12:55.225178Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "395f3c78-7ac0-4e3f-b95c-3957e043f495", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:02.658580004Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "89fee0f6-ab2d-4cb8-808c-baa9c00cc1be", "bindings": [{"id": "5a21d973-a18b-4781-8706-367096ed6960", "type": "Port", "port_id": "70d3c019-f984-416c-9b8f-38b776eb7ada", "interface_id": "2e4bb2e0-241c-4543-9002-cac399c5a9a8"}], "created_at": "2025-12-17T16:13:02.658595Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:02.658595Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "98495581-3d54-41b2-994b-3d5f9f417a10", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:24.675731107Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2d3f9ac2-95b4-4cf9-9e9e-50e1c0e159bc", "bindings": [{"id": "44bad034-8e42-4d21-828c-a2b2a2b74e0f", "type": "Port", "port_id": "2cb8a60f-fc06-40f4-86b8-8b4c9850fa7e", "interface_id": "84f910a9-e1f1-4557-a67e-a195890ec00f"}, {"id": "6c2243ab-132e-44ad-a8f4-3fec827c84d9", "type": "Port", "port_id": "9b006265-84df-4da5-88c8-dac0c1953303", "interface_id": "84f910a9-e1f1-4557-a67e-a195890ec00f"}], "created_at": "2025-12-17T16:13:24.675747Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:24.675747Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "2c130f94-23fe-43ea-a1e3-5fae7155f22e", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:38.130798544Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c072fc8a-5849-4da0-b95c-dc0fe477cb69", "bindings": [{"id": "222f12c1-b0fb-4ffe-b266-79ed3dd12ec8", "type": "Port", "port_id": "1265ed85-4116-4ca4-8e4c-51e8bc690d81", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}], "created_at": "2025-12-17T16:13:38.130817Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:38.130817Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "fa50ecb6-7c0f-4686-ac44-0db92dc9da44", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-17T16:13:43.225393119Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c072fc8a-5849-4da0-b95c-dc0fe477cb69", "bindings": [{"id": "c6482c69-82f8-4334-8a70-a4de9da2abb2", "type": "Port", "port_id": "0b324270-2f06-4585-91bb-b1b61dd8cae1", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}], "created_at": "2025-12-17T16:13:43.225406Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:43.225406Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "ee020a6d-bfac-4a90-9a81-18760ce5550b", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:45.402953751Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c072fc8a-5849-4da0-b95c-dc0fe477cb69", "bindings": [{"id": "03c1b5ff-02e8-4dfc-bf3c-95e3aac8eca9", "type": "Port", "port_id": "55d2b2f9-d289-47b0-b9db-60f4ea46d99f", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}], "created_at": "2025-12-17T16:13:45.402970Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:45.402970Z", "virtualization": null, "service_definition": "SSH"}, {"id": "269b7ee3-639c-4cd2-88d6-42c315ff019c", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-17T16:13:45.403510754Z", "type": "Network", "daemon_id": "35f8042f-2b6c-400f-a1cd-5d7a70acff3b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c072fc8a-5849-4da0-b95c-dc0fe477cb69", "bindings": [{"id": "8d178eaf-0937-4a2a-9fcc-202e972c2d77", "type": "Port", "port_id": "8d383064-c1b9-45cd-b959-2a5cc2f18897", "interface_id": "01c49c08-417d-45a6-9267-1c40bac670c6"}], "created_at": "2025-12-17T16:13:45.403519Z", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:45.403519Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "6a0c3575-172a-4f50-8dad-2fff98483633", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-17T16:13:45.437649Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "61cd097d-8a08-4123-93c9-a70333f82c88", "updated_at": "2025-12-17T16:13:45.437649Z", "description": null, "service_bindings": []}]	t	2025-12-17 16:12:07.877975+00	f	\N	\N	{ac2da1a9-58be-4474-a19f-333444e9627b,9e0a796a-6d7a-424b-9617-5414f479082c}	{a23eb400-da7d-4fe0-a597-8b5a7d78d718}	{d9ec6c16-ee4e-4833-a539-dd8da6a6e856}	{fa1c8383-796e-4ddb-8cd2-c77e5f5bef36}	\N	2025-12-17 16:12:07.874653+00	2025-12-17 16:13:46.379117+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
9372bdbf-ea25-4c42-a6e9-22385c2688a0	2025-12-17 16:12:07.85113+00	2025-12-17 16:12:07.85113+00	$argon2id$v=19$m=19456,t=2,p=1$DCpvF1gdnT1LpzlFnWl/NA$wyMtDiwDtKIrj5xhop23Rg3HpVy2wh7scdwaHK3I/cI	\N	\N	\N	user@gmail.com	94c8c05e-5761-407c-aa7a-3043de411cca	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
jF7mCXfyoGoH9_y43vX-5w	\\x93c410e7fef5deb8fcf7076aa0f27709e65e8c81a7757365725f6964d92439333732626462662d656132352d346334322d613665392d32323338356332363838613099cd07ea10100c07ce3b7833c8000000	2026-01-16 16:12:07.997733+00
1qAFnrKah0UlTGPHRfWMBQ	\\x93c410058cf545c7634c2545879ab29e05a0d682ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92466323239383062352d626661612d346332652d623733382d663236386666376362643161a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92439333732626462662d656132352d346334322d613665392d32323338356332363838613099cd07ea10100d2dce3b2f6796000000	2026-01-16 16:13:45.992962+00
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

\unrestrict mW28zmkwLd4WZYNqC9bRhMw4WjamzDonNdlKI69L0hHFePJW2NJJCymUec4Qa8I

