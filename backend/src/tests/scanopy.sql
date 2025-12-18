--
-- PostgreSQL database dump
--

\restrict b5MC7XxhGS5PewF35PhfZNU2DbvOg256Bm0DY0DrXhXzQoY6RDPTavULNL03g8A

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
20251006215000	users	2025-12-18 02:58:48.997804+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3547194
20251006215100	networks	2025-12-18 02:58:49.002369+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4690218
20251006215151	create hosts	2025-12-18 02:58:49.007415+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3887389
20251006215155	create subnets	2025-12-18 02:58:49.011642+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3686905
20251006215201	create groups	2025-12-18 02:58:49.015826+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3943614
20251006215204	create daemons	2025-12-18 02:58:49.020093+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4206105
20251006215212	create services	2025-12-18 02:58:49.024657+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4708222
20251029193448	user-auth	2025-12-18 02:58:49.029694+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6085945
20251030044828	daemon api	2025-12-18 02:58:49.036051+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1484082
20251030170438	host-hide	2025-12-18 02:58:49.037815+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1322479
20251102224919	create discovery	2025-12-18 02:58:49.039515+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10900695
20251106235621	normalize-daemon-cols	2025-12-18 02:58:49.050731+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1823175
20251107034459	api keys	2025-12-18 02:58:49.052846+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8198480
20251107222650	oidc-auth	2025-12-18 02:58:49.061361+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26837785
20251110181948	orgs-billing	2025-12-18 02:58:49.088546+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10841635
20251113223656	group-enhancements	2025-12-18 02:58:49.099747+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1032408
20251117032720	daemon-mode	2025-12-18 02:58:49.101201+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1186976
20251118143058	set-default-plan	2025-12-18 02:58:49.102699+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1161148
20251118225043	save-topology	2025-12-18 02:58:49.104148+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8682804
20251123232748	network-permissions	2025-12-18 02:58:49.113162+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2814355
20251125001342	billing-updates	2025-12-18 02:58:49.116267+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	965092
20251128035448	org-onboarding-status	2025-12-18 02:58:49.117596+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1392060
20251129180942	nfs-consolidate	2025-12-18 02:58:49.119278+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1197476
20251206052641	discovery-progress	2025-12-18 02:58:49.120792+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1765226
20251206202200	plan-fix	2025-12-18 02:58:49.122847+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	951486
20251207061341	daemon-url	2025-12-18 02:58:49.124081+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2399059
20251210045929	tags	2025-12-18 02:58:49.126797+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8790334
20251210175035	terms	2025-12-18 02:58:49.135931+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	885463
20251213025048	hash-keys	2025-12-18 02:58:49.137103+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9221400
20251214050638	scanopy	2025-12-18 02:58:49.146621+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1530217
20251215215724	topo-scanopy-fix	2025-12-18 02:58:49.148502+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	781058
20251217153736	category rename	2025-12-18 02:58:49.149686+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1785546
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
576d2fff-57f9-47e7-9402-b2f10975afc4	673f021725b6cf2fc5a8825732f0ed49d163eb7571fe7fab4149cb6568b63114	5124b6f1-277f-4993-8c4a-a33e035f2732	Integrated Daemon API Key	2025-12-18 02:58:51.125245+00	2025-12-18 03:00:27.943803+00	2025-12-18 03:00:27.94297+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
16aae8bf-a5ca-446b-a777-ba4b6121a782	5124b6f1-277f-4993-8c4a-a33e035f2732	4e58a31b-d081-41e7-bbd0-446bcffbc57d	2025-12-18 02:58:51.257276+00	2025-12-18 03:00:06.155766+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["313057c7-d00b-483d-aefa-f34d8fc93c1d"]}	2025-12-18 03:00:06.156292+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
7f13885f-1b98-4f74-8b9e-5f25366d3e7f	5124b6f1-277f-4993-8c4a-a33e035f2732	16aae8bf-a5ca-446b-a777-ba4b6121a782	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d"}	Self Report	2025-12-18 02:58:51.263972+00	2025-12-18 02:58:51.263972+00	{}
bf54652f-dcf8-4530-9ae5-537f68928a84	5124b6f1-277f-4993-8c4a-a33e035f2732	16aae8bf-a5ca-446b-a777-ba4b6121a782	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-18 02:58:51.271183+00	2025-12-18 02:58:51.271183+00	{}
29f153c3-2003-411f-bdb5-b98b81b49d01	5124b6f1-277f-4993-8c4a-a33e035f2732	16aae8bf-a5ca-446b-a777-ba4b6121a782	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "session_id": "38c77fb1-8f7b-4285-b024-1f4cfa5d7667", "started_at": "2025-12-18T02:58:51.270809386Z", "finished_at": "2025-12-18T02:58:51.366137958Z", "discovery_type": {"type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d"}}}	{"type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d"}	Self Report	2025-12-18 02:58:51.270809+00	2025-12-18 02:58:51.369376+00	{}
75504ac6-0b27-461b-b0d8-056813bfa22c	5124b6f1-277f-4993-8c4a-a33e035f2732	16aae8bf-a5ca-446b-a777-ba4b6121a782	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "session_id": "09b73fdf-6c25-41a1-8fa8-592f018af119", "started_at": "2025-12-18T02:58:51.381210590Z", "finished_at": "2025-12-18T03:00:27.940994356Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-18 02:58:51.38121+00	2025-12-18 03:00:27.943326+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
7821521f-e923-4db8-8977-a7221443711c	5124b6f1-277f-4993-8c4a-a33e035f2732		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-18 03:00:27.957914+00	2025-12-18 03:00:27.957914+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
14977da3-6aae-4b19-9483-abbeefe30bbf	5124b6f1-277f-4993-8c4a-a33e035f2732	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "ada192c8-c8a7-4604-b3d0-f3140d17e7b7"}	[{"id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951", "name": "Internet", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "ip_address": "1.1.1.1", "mac_address": null}]	{ce65e4a6-0ba0-4124-a41f-d9903022458c}	[{"id": "6529a2d0-9f65-4619-b6a8-ffb89d14aa93", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-18 02:58:51.099761+00	2025-12-18 02:58:51.109012+00	f	{}
322d337e-479b-42b2-8d22-189fb3cc1677	5124b6f1-277f-4993-8c4a-a33e035f2732	Google.com	\N	\N	{"type": "ServiceBinding", "config": "1190cd5e-24c4-48ad-b304-e628cd83c960"}	[{"id": "3f937ede-cb0d-44e9-b3a3-c849586137b2", "name": "Internet", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "ip_address": "203.0.113.26", "mac_address": null}]	{ee2e4bfe-f709-438b-a003-fd69b4577d52}	[{"id": "db55e596-16c6-4bb5-a27e-60b19d91e19b", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-18 02:58:51.099771+00	2025-12-18 02:58:51.114553+00	f	{}
adbd6df4-ac03-42a9-9235-8a52a76c1d32	5124b6f1-277f-4993-8c4a-a33e035f2732	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "dc93c42e-5bc1-4ed6-81e3-9b4567d3e125"}	[{"id": "252dac88-35a0-44a5-9602-db703b7e0fe5", "name": "Remote Network", "subnet_id": "dd4801ad-e3ea-4c2f-be66-95d9f76c22fb", "ip_address": "203.0.113.185", "mac_address": null}]	{eb03cd36-38ce-4f89-82dd-2febb84b27f3}	[{"id": "5f7fc77d-c5e4-4898-89b9-ae9f0e8f4c04", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-18 02:58:51.09978+00	2025-12-18 02:58:51.118369+00	f	{}
5d4e59b9-4a1c-4343-a3d9-5611e141023b	5124b6f1-277f-4993-8c4a-a33e035f2732	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.5", "mac_address": "A2:58:F1:6E:62:1D"}]	{e5998b21-7166-47c8-a0f5-5b7ed6fe71ca}	[{"id": "96dd16af-fbf1-4530-a5f2-e369c4b6a8f3", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6bf40be4-9c49-4349-b8d0-9570242600b7", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:39.393517982Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 02:59:39.393521+00	2025-12-18 02:59:54.20093+00	f	{}
4e58a31b-d081-41e7-bbd0-446bcffbc57d	5124b6f1-277f-4993-8c4a-a33e035f2732	scanopy-daemon	37222176cada	Scanopy daemon	{"type": "None"}	[{"id": "b7803587-6291-4727-94fa-f28b47bedaff", "name": "eth0", "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.4", "mac_address": "DA:8C:A3:84:AB:A9"}]	{b84933c3-645c-44ea-941a-bf0a8fcf7889}	[{"id": "56ffe439-764d-4338-9d4a-e9b9799f620d", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T02:58:51.349199559Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}	null	2025-12-18 02:58:51.134156+00	2025-12-18 02:58:51.364205+00	f	{}
c07b36a6-fb21-45fa-b27d-711eac01f093	5124b6f1-277f-4993-8c4a-a33e035f2732	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "704459f4-e8de-47fa-87dd-e9e43760a651", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.6", "mac_address": "F2:88:DE:46:20:90"}]	{bea35652-f44a-4636-9268-51b375d42be6}	[{"id": "0095706a-379a-48e2-af44-cc9653033392", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:24.481520081Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 02:59:24.481522+00	2025-12-18 02:59:39.345209+00	f	{}
de72f1e1-4a3a-467d-949c-39ede880b253	5124b6f1-277f-4993-8c4a-a33e035f2732	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "a3461567-0c8d-4154-95c2-33ccbc5cd99d", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.3", "mac_address": "F2:23:BA:EA:7C:C1"}]	{92e1ca07-78a5-4369-9679-745620cbc7b8}	[{"id": "e05fdfbd-921f-4f9a-be8b-1e842921ca94", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:54.195174160Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 02:59:54.195176+00	2025-12-18 03:00:09.02202+00	f	{}
496e0dae-4c3a-4e94-82c2-557e625d3f68	5124b6f1-277f-4993-8c4a-a33e035f2732	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "8e1946ea-0add-485a-9570-2dea7aafa9a9", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.1", "mac_address": "FE:39:78:F7:40:CD"}]	{476904df-5369-4f3c-aa2e-db1015619629,e4671839-7bff-4705-b3b7-84ad0dc292de,cc13deeb-d268-4572-b5f8-24336ef47262,74506430-d45b-4500-b769-0926be0c3711}	[{"id": "53ba43b8-2ebf-46a4-8471-62b2b4b47e29", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "dfcd4122-2c76-4849-b5af-e7473927468e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c7520cf2-48c8-40a7-83c8-83d3ed6f9b2c", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "ca3fcd83-5fe9-4d45-9310-228ff2254ba7", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T03:00:13.075668961Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 03:00:13.075671+00	2025-12-18 03:00:27.934933+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
5124b6f1-277f-4993-8c4a-a33e035f2732	My Network	2025-12-18 02:58:51.098281+00	2025-12-18 02:58:51.098281+00	f	abd82464-0781-451a-a4e4-9b6362ed4cd9	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
abd82464-0781-451a-a4e4-9b6362ed4cd9	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-18 02:58:51.09214+00	2025-12-18 03:00:28.770396+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
ce65e4a6-0ba0-4124-a41f-d9903022458c	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.099764+00	2025-12-18 02:58:51.099764+00	Cloudflare DNS	14977da3-6aae-4b19-9483-abbeefe30bbf	[{"id": "ada192c8-c8a7-4604-b3d0-f3140d17e7b7", "type": "Port", "port_id": "6529a2d0-9f65-4619-b6a8-ffb89d14aa93", "interface_id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951"}]	"Dns Server"	null	{"type": "System"}	{}
ee2e4bfe-f709-438b-a003-fd69b4577d52	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.099773+00	2025-12-18 02:58:51.099773+00	Google.com	322d337e-479b-42b2-8d22-189fb3cc1677	[{"id": "1190cd5e-24c4-48ad-b304-e628cd83c960", "type": "Port", "port_id": "db55e596-16c6-4bb5-a27e-60b19d91e19b", "interface_id": "3f937ede-cb0d-44e9-b3a3-c849586137b2"}]	"Web Service"	null	{"type": "System"}	{}
eb03cd36-38ce-4f89-82dd-2febb84b27f3	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.099781+00	2025-12-18 02:58:51.099781+00	Mobile Device	adbd6df4-ac03-42a9-9235-8a52a76c1d32	[{"id": "dc93c42e-5bc1-4ed6-81e3-9b4567d3e125", "type": "Port", "port_id": "5f7fc77d-c5e4-4898-89b9-ae9f0e8f4c04", "interface_id": "252dac88-35a0-44a5-9602-db703b7e0fe5"}]	"Client"	null	{"type": "System"}	{}
b84933c3-645c-44ea-941a-bf0a8fcf7889	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.349218+00	2025-12-18 02:58:51.349218+00	Scanopy Daemon	4e58a31b-d081-41e7-bbd0-446bcffbc57d	[{"id": "ca3740c1-668c-4b30-acf3-3eae5b70d6da", "type": "Port", "port_id": "56ffe439-764d-4338-9d4a-e9b9799f620d", "interface_id": "b7803587-6291-4727-94fa-f28b47bedaff"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-18T02:58:51.349217522Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}	{}
bea35652-f44a-4636-9268-51b375d42be6	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:59:39.310505+00	2025-12-18 02:59:39.310505+00	PostgreSQL	c07b36a6-fb21-45fa-b27d-711eac01f093	[{"id": "6a142136-b5f0-41d6-991e-d11a6d33cd5d", "type": "Port", "port_id": "0095706a-379a-48e2-af44-cc9653033392", "interface_id": "704459f4-e8de-47fa-87dd-e9e43760a651"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T02:59:39.310489493Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e5998b21-7166-47c8-a0f5-5b7ed6fe71ca	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:59:54.188302+00	2025-12-18 02:59:54.188302+00	Unclaimed Open Ports	5d4e59b9-4a1c-4343-a3d9-5611e141023b	[{"id": "c378551c-d1c0-433e-8503-a2201c9e24bb", "type": "Port", "port_id": "96dd16af-fbf1-4530-a5f2-e369c4b6a8f3", "interface_id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1"}, {"id": "8fcb49d6-dae8-4077-a039-1ee28faa6686", "type": "Port", "port_id": "6bf40be4-9c49-4349-b8d0-9570242600b7", "interface_id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T02:59:54.188283991Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
92e1ca07-78a5-4369-9679-745620cbc7b8	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 03:00:09.011436+00	2025-12-18 03:00:09.011436+00	Unclaimed Open Ports	de72f1e1-4a3a-467d-949c-39ede880b253	[{"id": "2a5a60fc-c6a7-44bd-9cb7-40f57cbc5dc1", "type": "Port", "port_id": "e05fdfbd-921f-4f9a-be8b-1e842921ca94", "interface_id": "a3461567-0c8d-4154-95c2-33ccbc5cd99d"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:09.011417045Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
476904df-5369-4f3c-aa2e-db1015619629	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 03:00:21.241292+00	2025-12-18 03:00:21.241292+00	Scanopy Server	496e0dae-4c3a-4e94-82c2-557e625d3f68	[{"id": "aac87907-323c-4db4-8dbd-ed4499d1d13d", "type": "Port", "port_id": "53ba43b8-2ebf-46a4-8471-62b2b4b47e29", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T03:00:21.241269774Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e4671839-7bff-4705-b3b7-84ad0dc292de	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 03:00:24.187431+00	2025-12-18 03:00:24.187431+00	Home Assistant	496e0dae-4c3a-4e94-82c2-557e625d3f68	[{"id": "5bfd2a13-3852-4fde-8066-e9b0437bf849", "type": "Port", "port_id": "dfcd4122-2c76-4849-b5af-e7473927468e", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T03:00:24.187410554Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
74506430-d45b-4500-b769-0926be0c3711	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 03:00:27.921775+00	2025-12-18 03:00:27.921775+00	Unclaimed Open Ports	496e0dae-4c3a-4e94-82c2-557e625d3f68	[{"id": "a02f63d6-ca29-46b5-87ee-d8124778e61c", "type": "Port", "port_id": "ca3fcd83-5fe9-4d45-9310-228ff2254ba7", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:27.921766021Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
cc13deeb-d268-4572-b5f8-24336ef47262	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 03:00:27.921445+00	2025-12-18 03:00:27.921445+00	SSH	496e0dae-4c3a-4e94-82c2-557e625d3f68	[{"id": "d913f16a-2a1b-4f4b-bf26-5d6f0b6d0c13", "type": "Port", "port_id": "c7520cf2-48c8-40a7-83c8-83d3ed6f9b2c", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:27.921427820Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
327ac440-6408-423b-a1c2-c32376c74f55	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.099708+00	2025-12-18 02:58:51.099708+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
dd4801ad-e3ea-4c2f-be66-95d9f76c22fb	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.099712+00	2025-12-18 02:58:51.099712+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
313057c7-d00b-483d-aefa-f34d8fc93c1d	5124b6f1-277f-4993-8c4a-a33e035f2732	2025-12-18 02:58:51.270978+00	2025-12-18 02:58:51.270978+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-18T02:58:51.270977250Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
55b296d9-58a6-4d59-a52a-09a19bf00a4f	abd82464-0781-451a-a4e4-9b6362ed4cd9	New Tag	\N	2025-12-18 03:00:27.966195+00	2025-12-18 03:00:27.966195+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
e9660faa-6852-42b2-9b63-3dcb39ca8f79	5124b6f1-277f-4993-8c4a-a33e035f2732	My Topology	[]	[{"id": "327ac440-6408-423b-a1c2-c32376c74f55", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "dd4801ad-e3ea-4c2f-be66-95d9f76c22fb", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951", "size": {"x": 250, "y": 100}, "header": null, "host_id": "14977da3-6aae-4b19-9483-abbeefe30bbf", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "interface_id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951"}, {"id": "3f937ede-cb0d-44e9-b3a3-c849586137b2", "size": {"x": 250, "y": 100}, "header": null, "host_id": "322d337e-479b-42b2-8d22-189fb3cc1677", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "interface_id": "3f937ede-cb0d-44e9-b3a3-c849586137b2"}, {"id": "252dac88-35a0-44a5-9602-db703b7e0fe5", "size": {"x": 250, "y": 100}, "header": null, "host_id": "adbd6df4-ac03-42a9-9235-8a52a76c1d32", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "dd4801ad-e3ea-4c2f-be66-95d9f76c22fb", "interface_id": "252dac88-35a0-44a5-9602-db703b7e0fe5"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "14977da3-6aae-4b19-9483-abbeefe30bbf", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "6529a2d0-9f65-4619-b6a8-ffb89d14aa93", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "ada192c8-c8a7-4604-b3d0-f3140d17e7b7"}, "hostname": null, "services": ["ce65e4a6-0ba0-4124-a41f-d9903022458c"], "created_at": "2025-12-18T02:58:51.099761Z", "interfaces": [{"id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951", "name": "Internet", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.109012Z", "description": null, "virtualization": null}, {"id": "322d337e-479b-42b2-8d22-189fb3cc1677", "name": "Google.com", "tags": [], "ports": [{"id": "db55e596-16c6-4bb5-a27e-60b19d91e19b", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "1190cd5e-24c4-48ad-b304-e628cd83c960"}, "hostname": null, "services": ["ee2e4bfe-f709-438b-a003-fd69b4577d52"], "created_at": "2025-12-18T02:58:51.099771Z", "interfaces": [{"id": "3f937ede-cb0d-44e9-b3a3-c849586137b2", "name": "Internet", "subnet_id": "327ac440-6408-423b-a1c2-c32376c74f55", "ip_address": "203.0.113.26", "mac_address": null}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.114553Z", "description": null, "virtualization": null}, {"id": "adbd6df4-ac03-42a9-9235-8a52a76c1d32", "name": "Mobile Device", "tags": [], "ports": [{"id": "5f7fc77d-c5e4-4898-89b9-ae9f0e8f4c04", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "dc93c42e-5bc1-4ed6-81e3-9b4567d3e125"}, "hostname": null, "services": ["eb03cd36-38ce-4f89-82dd-2febb84b27f3"], "created_at": "2025-12-18T02:58:51.099780Z", "interfaces": [{"id": "252dac88-35a0-44a5-9602-db703b7e0fe5", "name": "Remote Network", "subnet_id": "dd4801ad-e3ea-4c2f-be66-95d9f76c22fb", "ip_address": "203.0.113.185", "mac_address": null}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.118369Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "56ffe439-764d-4338-9d4a-e9b9799f620d", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T02:58:51.349199559Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}, "target": {"type": "None"}, "hostname": "37222176cada", "services": ["b84933c3-645c-44ea-941a-bf0a8fcf7889"], "created_at": "2025-12-18T02:58:51.134156Z", "interfaces": [{"id": "b7803587-6291-4727-94fa-f28b47bedaff", "name": "eth0", "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.4", "mac_address": "DA:8C:A3:84:AB:A9"}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.364205Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "c07b36a6-fb21-45fa-b27d-711eac01f093", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "0095706a-379a-48e2-af44-cc9653033392", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:24.481520081Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["bea35652-f44a-4636-9268-51b375d42be6"], "created_at": "2025-12-18T02:59:24.481522Z", "interfaces": [{"id": "704459f4-e8de-47fa-87dd-e9e43760a651", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.6", "mac_address": "F2:88:DE:46:20:90"}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:59:39.345209Z", "description": null, "virtualization": null}, {"id": "5d4e59b9-4a1c-4343-a3d9-5611e141023b", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "96dd16af-fbf1-4530-a5f2-e369c4b6a8f3", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6bf40be4-9c49-4349-b8d0-9570242600b7", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:39.393517982Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["e5998b21-7166-47c8-a0f5-5b7ed6fe71ca"], "created_at": "2025-12-18T02:59:39.393521Z", "interfaces": [{"id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.5", "mac_address": "A2:58:F1:6E:62:1D"}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:59:54.200930Z", "description": null, "virtualization": null}, {"id": "de72f1e1-4a3a-467d-949c-39ede880b253", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "e05fdfbd-921f-4f9a-be8b-1e842921ca94", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T02:59:54.195174160Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["92e1ca07-78a5-4369-9679-745620cbc7b8"], "created_at": "2025-12-18T02:59:54.195176Z", "interfaces": [{"id": "a3461567-0c8d-4154-95c2-33ccbc5cd99d", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.3", "mac_address": "F2:23:BA:EA:7C:C1"}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:09.022020Z", "description": null, "virtualization": null}, {"id": "496e0dae-4c3a-4e94-82c2-557e625d3f68", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "53ba43b8-2ebf-46a4-8471-62b2b4b47e29", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "dfcd4122-2c76-4849-b5af-e7473927468e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c7520cf2-48c8-40a7-83c8-83d3ed6f9b2c", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "ca3fcd83-5fe9-4d45-9310-228ff2254ba7", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T03:00:13.075668961Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["476904df-5369-4f3c-aa2e-db1015619629", "e4671839-7bff-4705-b3b7-84ad0dc292de", "cc13deeb-d268-4572-b5f8-24336ef47262", "74506430-d45b-4500-b769-0926be0c3711"], "created_at": "2025-12-18T03:00:13.075671Z", "interfaces": [{"id": "8e1946ea-0add-485a-9570-2dea7aafa9a9", "name": null, "subnet_id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "ip_address": "172.25.0.1", "mac_address": "FE:39:78:F7:40:CD"}], "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:27.934933Z", "description": null, "virtualization": null}]	[{"id": "327ac440-6408-423b-a1c2-c32376c74f55", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-18T02:58:51.099708Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.099708Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "dd4801ad-e3ea-4c2f-be66-95d9f76c22fb", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-18T02:58:51.099712Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.099712Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "313057c7-d00b-483d-aefa-f34d8fc93c1d", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T02:58:51.270977250Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}, "created_at": "2025-12-18T02:58:51.270978Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.270978Z", "description": null, "subnet_type": "Lan"}]	[{"id": "ce65e4a6-0ba0-4124-a41f-d9903022458c", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "14977da3-6aae-4b19-9483-abbeefe30bbf", "bindings": [{"id": "ada192c8-c8a7-4604-b3d0-f3140d17e7b7", "type": "Port", "port_id": "6529a2d0-9f65-4619-b6a8-ffb89d14aa93", "interface_id": "6ccd4b08-8226-4da3-bb5e-d6e41e184951"}], "created_at": "2025-12-18T02:58:51.099764Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.099764Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "ee2e4bfe-f709-438b-a003-fd69b4577d52", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "322d337e-479b-42b2-8d22-189fb3cc1677", "bindings": [{"id": "1190cd5e-24c4-48ad-b304-e628cd83c960", "type": "Port", "port_id": "db55e596-16c6-4bb5-a27e-60b19d91e19b", "interface_id": "3f937ede-cb0d-44e9-b3a3-c849586137b2"}], "created_at": "2025-12-18T02:58:51.099773Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.099773Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "eb03cd36-38ce-4f89-82dd-2febb84b27f3", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "adbd6df4-ac03-42a9-9235-8a52a76c1d32", "bindings": [{"id": "dc93c42e-5bc1-4ed6-81e3-9b4567d3e125", "type": "Port", "port_id": "5f7fc77d-c5e4-4898-89b9-ae9f0e8f4c04", "interface_id": "252dac88-35a0-44a5-9602-db703b7e0fe5"}], "created_at": "2025-12-18T02:58:51.099781Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.099781Z", "virtualization": null, "service_definition": "Client"}, {"id": "b84933c3-645c-44ea-941a-bf0a8fcf7889", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-18T02:58:51.349217522Z", "type": "SelfReport", "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782"}]}, "host_id": "4e58a31b-d081-41e7-bbd0-446bcffbc57d", "bindings": [{"id": "ca3740c1-668c-4b30-acf3-3eae5b70d6da", "type": "Port", "port_id": "56ffe439-764d-4338-9d4a-e9b9799f620d", "interface_id": "b7803587-6291-4727-94fa-f28b47bedaff"}], "created_at": "2025-12-18T02:58:51.349218Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:58:51.349218Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "bea35652-f44a-4636-9268-51b375d42be6", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T02:59:39.310489493Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "c07b36a6-fb21-45fa-b27d-711eac01f093", "bindings": [{"id": "6a142136-b5f0-41d6-991e-d11a6d33cd5d", "type": "Port", "port_id": "0095706a-379a-48e2-af44-cc9653033392", "interface_id": "704459f4-e8de-47fa-87dd-e9e43760a651"}], "created_at": "2025-12-18T02:59:39.310505Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:59:39.310505Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "e5998b21-7166-47c8-a0f5-5b7ed6fe71ca", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T02:59:54.188283991Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "5d4e59b9-4a1c-4343-a3d9-5611e141023b", "bindings": [{"id": "c378551c-d1c0-433e-8503-a2201c9e24bb", "type": "Port", "port_id": "96dd16af-fbf1-4530-a5f2-e369c4b6a8f3", "interface_id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1"}, {"id": "8fcb49d6-dae8-4077-a039-1ee28faa6686", "type": "Port", "port_id": "6bf40be4-9c49-4349-b8d0-9570242600b7", "interface_id": "96e3e732-8a51-47c6-acc9-aa1b3a94b8b1"}], "created_at": "2025-12-18T02:59:54.188302Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T02:59:54.188302Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "92e1ca07-78a5-4369-9679-745620cbc7b8", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:09.011417045Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "de72f1e1-4a3a-467d-949c-39ede880b253", "bindings": [{"id": "2a5a60fc-c6a7-44bd-9cb7-40f57cbc5dc1", "type": "Port", "port_id": "e05fdfbd-921f-4f9a-be8b-1e842921ca94", "interface_id": "a3461567-0c8d-4154-95c2-33ccbc5cd99d"}], "created_at": "2025-12-18T03:00:09.011436Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:09.011436Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "476904df-5369-4f3c-aa2e-db1015619629", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T03:00:21.241269774Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "496e0dae-4c3a-4e94-82c2-557e625d3f68", "bindings": [{"id": "aac87907-323c-4db4-8dbd-ed4499d1d13d", "type": "Port", "port_id": "53ba43b8-2ebf-46a4-8471-62b2b4b47e29", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}], "created_at": "2025-12-18T03:00:21.241292Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:21.241292Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "e4671839-7bff-4705-b3b7-84ad0dc292de", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T03:00:24.187410554Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "496e0dae-4c3a-4e94-82c2-557e625d3f68", "bindings": [{"id": "5bfd2a13-3852-4fde-8066-e9b0437bf849", "type": "Port", "port_id": "dfcd4122-2c76-4849-b5af-e7473927468e", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}], "created_at": "2025-12-18T03:00:24.187431Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:24.187431Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "cc13deeb-d268-4572-b5f8-24336ef47262", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:27.921427820Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "496e0dae-4c3a-4e94-82c2-557e625d3f68", "bindings": [{"id": "d913f16a-2a1b-4f4b-bf26-5d6f0b6d0c13", "type": "Port", "port_id": "c7520cf2-48c8-40a7-83c8-83d3ed6f9b2c", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}], "created_at": "2025-12-18T03:00:27.921445Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:27.921445Z", "virtualization": null, "service_definition": "SSH"}, {"id": "74506430-d45b-4500-b769-0926be0c3711", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T03:00:27.921766021Z", "type": "Network", "daemon_id": "16aae8bf-a5ca-446b-a777-ba4b6121a782", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "496e0dae-4c3a-4e94-82c2-557e625d3f68", "bindings": [{"id": "a02f63d6-ca29-46b5-87ee-d8124778e61c", "type": "Port", "port_id": "ca3fcd83-5fe9-4d45-9310-228ff2254ba7", "interface_id": "8e1946ea-0add-485a-9570-2dea7aafa9a9"}], "created_at": "2025-12-18T03:00:27.921775Z", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:27.921775Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "7821521f-e923-4db8-8977-a7221443711c", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-18T03:00:27.957914Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "5124b6f1-277f-4993-8c4a-a33e035f2732", "updated_at": "2025-12-18T03:00:27.957914Z", "description": null, "service_bindings": []}]	t	2025-12-18 02:58:51.12271+00	f	\N	\N	{6e87d05a-2593-40a3-9660-ac22e9b37b13,40931e1d-49ed-4b8e-9c55-e96789c98456,5aa249f9-7309-4422-a527-da38ed80a6ec}	{f30421bd-2921-40df-8acf-cc4e584c780b}	{2254d570-7f4a-45fd-939e-306ea1bcf44b}	{62606055-120d-4dc3-aa57-80cb1369ffe1}	\N	2025-12-18 02:58:51.119204+00	2025-12-18 03:00:29.630243+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
e1f99943-babe-4e71-9d8f-362ebebdb97a	2025-12-18 02:58:51.095046+00	2025-12-18 02:58:51.095046+00	$argon2id$v=19$m=19456,t=2,p=1$U1s1JOd3+lR/tOgiuHSohg$XskjeKa4yylETe34WpzgpJpBey+zn0q0XO3BXUGemFo	\N	\N	\N	user@gmail.com	abd82464-0781-451a-a4e4-9b6362ed4cd9	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
GJtFxPYdnogYd2VRT-e9PA	\\x93c4103cbde74f51657718889e1df6c4459b1881a7757365725f6964d92465316639393934332d626162652d346537312d396438662d33363265626562646239376199cd07ea11023a33ce10906a00000000	2026-01-17 02:58:51.277899+00
aObIp5vsxzDXtSlmdlTNWQ	\\x93c41059cd54766629b5d730c7ec9ba7c8e66882ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92462373462613433342d393839622d346339612d383264382d313035366161373465373432a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92465316639393934332d626162652d346537312d396438662d33363265626562646239376199cd07ea1103001cce1ede9056000000	2026-01-17 03:00:28.517902+00
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

\unrestrict b5MC7XxhGS5PewF35PhfZNU2DbvOg256Bm0DY0DrXhXzQoY6RDPTavULNL03g8A

