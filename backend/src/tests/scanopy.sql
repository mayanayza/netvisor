--
-- PostgreSQL database dump
--

\restrict WWKvf1tTggefce0IgjcJCE9gAufSotbUyPxSiWFJfVhctKGeVbeA5dx1g6WZTMs

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
20251006215000	users	2025-12-14 15:59:12.286274+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3373660
20251006215100	networks	2025-12-14 15:59:12.290761+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5229850
20251006215151	create hosts	2025-12-14 15:59:12.296355+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3876301
20251006215155	create subnets	2025-12-14 15:59:12.300597+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3757221
20251006215201	create groups	2025-12-14 15:59:12.304729+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4071053
20251006215204	create daemons	2025-12-14 15:59:12.309123+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4028895
20251006215212	create services	2025-12-14 15:59:12.313502+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4733069
20251029193448	user-auth	2025-12-14 15:59:12.318524+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5648745
20251030044828	daemon api	2025-12-14 15:59:12.324784+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1499037
20251030170438	host-hide	2025-12-14 15:59:12.326716+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1058251
20251102224919	create discovery	2025-12-14 15:59:12.328067+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10879156
20251106235621	normalize-daemon-cols	2025-12-14 15:59:12.339301+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1832495
20251107034459	api keys	2025-12-14 15:59:12.341434+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8229467
20251107222650	oidc-auth	2025-12-14 15:59:12.349969+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26605102
20251110181948	orgs-billing	2025-12-14 15:59:12.377045+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11382619
20251113223656	group-enhancements	2025-12-14 15:59:12.388733+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1064482
20251117032720	daemon-mode	2025-12-14 15:59:12.390117+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1174746
20251118143058	set-default-plan	2025-12-14 15:59:12.391577+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1195385
20251118225043	save-topology	2025-12-14 15:59:12.393059+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9558519
20251123232748	network-permissions	2025-12-14 15:59:12.402966+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2904531
20251125001342	billing-updates	2025-12-14 15:59:12.406192+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1042151
20251128035448	org-onboarding-status	2025-12-14 15:59:12.407524+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1775379
20251129180942	nfs-consolidate	2025-12-14 15:59:12.409593+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1303536
20251206052641	discovery-progress	2025-12-14 15:59:12.411252+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1699830
20251206202200	plan-fix	2025-12-14 15:59:12.413285+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	865594
20251207061341	daemon-url	2025-12-14 15:59:12.414483+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2274725
20251210045929	tags	2025-12-14 15:59:12.417173+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8606581
20251210175035	terms	2025-12-14 15:59:12.426183+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	841479
20251213025048	hash-keys	2025-12-14 15:59:12.427304+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9680225
20251214050638	scanopy	2025-12-14 15:59:12.437665+00	t	\\x90f63e0075b0459ace60f9220c1116109b4ec1e768f77c5ebdc2931caea8192d1aa0b4a785edf9186f2ae9bc367c1783	1338250
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
53daa8aa-b268-4cc1-91b0-77d48e2b3ab4	bb56558d97a79943d5904bce52ac66abceeea4fbe362a230ab18f5dfaf710b43	474bb9b3-8c54-4f4c-b465-4de91beb03be	Integrated Daemon API Key	2025-12-14 15:59:14.138237+00	2025-12-14 16:00:44.3212+00	2025-12-14 16:00:44.320154+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
a78e883a-1901-47d2-9ca3-a583e417440e	474bb9b3-8c54-4f4c-b465-4de91beb03be	dee824a6-2f72-4124-8cdf-bc667d5208de	2025-12-14 15:59:14.22694+00	2025-12-14 16:00:29.10461+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["f39269c7-c3ac-470a-a81f-8a1b9ccd32ab"]}	2025-12-14 16:00:29.105123+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
540308b9-ef34-4f03-95f3-0a48a31ca4b5	474bb9b3-8c54-4f4c-b465-4de91beb03be	a78e883a-1901-47d2-9ca3-a583e417440e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de"}	Self Report	2025-12-14 15:59:14.234094+00	2025-12-14 15:59:14.234094+00	{}
6994223b-1ef5-4e00-b906-28d6481595fa	474bb9b3-8c54-4f4c-b465-4de91beb03be	a78e883a-1901-47d2-9ca3-a583e417440e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-14 15:59:14.240705+00	2025-12-14 15:59:14.240705+00	{}
2daec8d5-95c5-41cf-91c3-a93f6f8deccb	474bb9b3-8c54-4f4c-b465-4de91beb03be	a78e883a-1901-47d2-9ca3-a583e417440e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "session_id": "c841d973-74d4-4437-8bb4-901274b48fe0", "started_at": "2025-12-14T15:59:14.240356047Z", "finished_at": "2025-12-14T15:59:14.358953914Z", "discovery_type": {"type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de"}}}	{"type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de"}	Self Report	2025-12-14 15:59:14.240356+00	2025-12-14 15:59:14.365174+00	{}
dd03272f-aa3d-4876-9475-afa2f52d81e7	474bb9b3-8c54-4f4c-b465-4de91beb03be	a78e883a-1901-47d2-9ca3-a583e417440e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "session_id": "9fb7c810-4c9e-43c7-bae0-cce71e8a49c2", "started_at": "2025-12-14T15:59:14.380600098Z", "finished_at": "2025-12-14T16:00:44.318051465Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-14 15:59:14.3806+00	2025-12-14 16:00:44.320379+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
4d3365a0-047d-444e-9f12-25090a8ac8ee	474bb9b3-8c54-4f4c-b465-4de91beb03be		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-14 16:00:44.334731+00	2025-12-14 16:00:44.334731+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
b6a8286d-e736-41ea-b7df-ddfa0d42f07f	474bb9b3-8c54-4f4c-b465-4de91beb03be	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "377f6901-eb7e-423d-af00-97adbf9c8645"}	[{"id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e", "name": "Internet", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "ip_address": "1.1.1.1", "mac_address": null}]	{5e256b70-89bb-44e1-b294-fc105806084a}	[{"id": "0bc355a2-12d5-4825-bd79-6ea4b88fe428", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-14 15:59:14.111061+00	2025-12-14 15:59:14.121787+00	f	{}
3a88148f-4dc5-45b5-a4ec-eaf345682e16	474bb9b3-8c54-4f4c-b465-4de91beb03be	Google.com	\N	\N	{"type": "ServiceBinding", "config": "ead4fc9d-7270-4a3e-83d1-6a38b20c5aa4"}	[{"id": "bd842f22-f635-45dc-9da0-bca89a20f7cd", "name": "Internet", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "ip_address": "203.0.113.219", "mac_address": null}]	{8c388811-b60e-435b-b088-9c2f203a897b}	[{"id": "7f7acd0c-0aaa-4960-8af1-030a0e6ec445", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-14 15:59:14.111069+00	2025-12-14 15:59:14.127299+00	f	{}
ebb251bf-1513-4bda-bf78-5eb10a267bf2	474bb9b3-8c54-4f4c-b465-4de91beb03be	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "3c577142-e451-4a99-a9b7-83f89ac5eca0"}	[{"id": "b78444f0-03ce-4012-a631-b46179ef5bdb", "name": "Remote Network", "subnet_id": "4a5fa3bf-92a6-4433-a1e7-232c505965ac", "ip_address": "203.0.113.115", "mac_address": null}]	{328b6e2f-9f6c-4c9a-bacf-674e06e7c703}	[{"id": "ab9724ed-364d-41e1-b31b-b68dcfdedbb9", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-14 15:59:14.111074+00	2025-12-14 15:59:14.131471+00	f	{}
efdb7f17-f795-4f65-a569-2ecc508b124a	474bb9b3-8c54-4f4c-b465-4de91beb03be	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "e0cc60dd-0132-4601-a686-3aac6cb4fc1f", "name": null, "subnet_id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "ip_address": "172.25.0.6", "mac_address": "AA:68:1F:2B:FD:9F"}]	{134b1b79-bfa1-4b5f-b45b-b341804c0fc4}	[{"id": "5e48d964-2045-4252-bfdd-5a12f99bc1e4", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-14T15:59:56.362513855Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-14 15:59:56.362517+00	2025-12-14 16:00:11.117176+00	f	{}
dee824a6-2f72-4124-8cdf-bc667d5208de	474bb9b3-8c54-4f4c-b465-4de91beb03be	scanopy-daemon	6ea9bfe42145	Scanopy daemon	{"type": "None"}	[{"id": "8062b25a-b44d-4ab6-a7d5-90d47f8460d9", "name": "eth0", "subnet_id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "ip_address": "172.25.0.4", "mac_address": "86:82:D1:5D:F0:A0"}]	{946f5706-f532-464a-89c0-5b0235a66121}	[{"id": "69ee7f0e-1001-447a-aaa7-9bc750614dae", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-14T15:59:14.286412686Z", "type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e"}]}	null	2025-12-14 15:59:14.222694+00	2025-12-14 15:59:14.353158+00	f	{}
a6c018d0-4802-4ae6-bf23-1c1990e821d1	474bb9b3-8c54-4f4c-b465-4de91beb03be	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "071a76c8-678d-435b-a8b7-f81e437679ee", "name": null, "subnet_id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "ip_address": "172.25.0.3", "mac_address": "92:C1:18:6C:AF:74"}]	{2649908c-aa81-47ee-a288-1677068464f9}	[{"id": "c30f381c-d749-463b-87b1-986538bc998c", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-14T15:59:41.673102936Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-14 15:59:41.673105+00	2025-12-14 15:59:56.27458+00	f	{}
68bc81d3-8691-4ac1-b49b-6c0fcbe236af	474bb9b3-8c54-4f4c-b465-4de91beb03be	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "d7780799-5133-407d-9da1-741244318edb", "name": null, "subnet_id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "ip_address": "172.25.0.5", "mac_address": "A6:06:5E:03:E2:3C"}]	{11390d90-3ce0-4589-bacd-949661271e95,7e0834bd-f572-4ea5-90b8-ee38d4758432}	[{"id": "92797c11-eae4-451c-bed2-d6758cbeef2a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1d3b7bf0-f84b-46f2-8c30-2a5a08b29f74", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-14T16:00:11.108587783Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-14 16:00:11.108589+00	2025-12-14 16:00:25.634824+00	f	{}
69932819-7e06-43b4-8759-185c776664d7	474bb9b3-8c54-4f4c-b465-4de91beb03be	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "aa5fb6c7-aa61-4c9f-8cd1-27641fe43ddf", "name": null, "subnet_id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "ip_address": "172.25.0.1", "mac_address": "06:C3:40:83:04:D6"}]	{51eaacdd-6148-44ad-9476-047ff41b5bb7,e4cca9c1-51e2-4e92-b2e6-9bb2a11b86c3,b889ee50-3dfc-47c6-a004-fbd9b07131ee,ac045751-58db-4465-842b-7018a64a9545}	[{"id": "27a6aab6-980e-49d0-a6a4-87feaf50ac6f", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "3d43935a-db37-4b17-b0d3-fbc219b80d04", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "672f531f-bdcd-4508-88a3-ca52bdf65fbb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "f46a23ea-c69f-44f7-83b5-9ac6dc4d0c2b", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-14T16:00:29.684338671Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-14 16:00:29.684341+00	2025-12-14 16:00:44.311846+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
474bb9b3-8c54-4f4c-b465-4de91beb03be	My Network	2025-12-14 15:59:14.109765+00	2025-12-14 15:59:14.109765+00	f	bebb9fa8-3daf-426b-bc9a-8cf4e58d341b	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
bebb9fa8-3daf-426b-bc9a-8cf4e58d341b	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-14 15:59:14.103824+00	2025-12-14 15:59:14.232569+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
5e256b70-89bb-44e1-b294-fc105806084a	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.111063+00	2025-12-14 15:59:14.111063+00	Cloudflare DNS	b6a8286d-e736-41ea-b7df-ddfa0d42f07f	[{"id": "377f6901-eb7e-423d-af00-97adbf9c8645", "type": "Port", "port_id": "0bc355a2-12d5-4825-bd79-6ea4b88fe428", "interface_id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e"}]	"Dns Server"	null	{"type": "System"}	{}
8c388811-b60e-435b-b088-9c2f203a897b	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.11107+00	2025-12-14 15:59:14.11107+00	Google.com	3a88148f-4dc5-45b5-a4ec-eaf345682e16	[{"id": "ead4fc9d-7270-4a3e-83d1-6a38b20c5aa4", "type": "Port", "port_id": "7f7acd0c-0aaa-4960-8af1-030a0e6ec445", "interface_id": "bd842f22-f635-45dc-9da0-bca89a20f7cd"}]	"Web Service"	null	{"type": "System"}	{}
328b6e2f-9f6c-4c9a-bacf-674e06e7c703	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.111075+00	2025-12-14 15:59:14.111075+00	Mobile Device	ebb251bf-1513-4bda-bf78-5eb10a267bf2	[{"id": "3c577142-e451-4a99-a9b7-83f89ac5eca0", "type": "Port", "port_id": "ab9724ed-364d-41e1-b31b-b68dcfdedbb9", "interface_id": "b78444f0-03ce-4012-a631-b46179ef5bdb"}]	"Client"	null	{"type": "System"}	{}
946f5706-f532-464a-89c0-5b0235a66121	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.286442+00	2025-12-14 15:59:14.286442+00	Scanopy Daemon	dee824a6-2f72-4124-8cdf-bc667d5208de	[{"id": "f87bee04-9490-418a-9ff1-2896ea351c34", "type": "Port", "port_id": "69ee7f0e-1001-447a-aaa7-9bc750614dae", "interface_id": "8062b25a-b44d-4ab6-a7d5-90d47f8460d9"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-14T15:59:14.286440918Z", "type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e"}]}	{}
2649908c-aa81-47ee-a288-1677068464f9	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:41.673505+00	2025-12-14 15:59:41.673505+00	Scanopy Server	a6c018d0-4802-4ae6-bf23-1c1990e821d1	[{"id": "cb1426c2-dda6-4ea2-821a-0113010f23ce", "type": "Port", "port_id": "c30f381c-d749-463b-87b1-986538bc998c", "interface_id": "071a76c8-678d-435b-a8b7-f81e437679ee"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-14T15:59:41.673491557Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
134b1b79-bfa1-4b5f-b45b-b341804c0fc4	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:11.107336+00	2025-12-14 16:00:11.107336+00	PostgreSQL	efdb7f17-f795-4f65-a569-2ecc508b124a	[{"id": "417e6c82-5e79-4d43-a880-b01402d78083", "type": "Port", "port_id": "5e48d964-2045-4252-bfdd-5a12f99bc1e4", "interface_id": "e0cc60dd-0132-4601-a686-3aac6cb4fc1f"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-14T16:00:11.107318070Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
11390d90-3ce0-4589-bacd-949661271e95	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:14.04755+00	2025-12-14 16:00:14.04755+00	Home Assistant	68bc81d3-8691-4ac1-b49b-6c0fcbe236af	[{"id": "9b34f745-7c56-4cd7-8eca-2aca1354aa7e", "type": "Port", "port_id": "92797c11-eae4-451c-bed2-d6758cbeef2a", "interface_id": "d7780799-5133-407d-9da1-741244318edb"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-14T16:00:14.047533095Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7e0834bd-f572-4ea5-90b8-ee38d4758432	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:25.62369+00	2025-12-14 16:00:25.62369+00	Unclaimed Open Ports	68bc81d3-8691-4ac1-b49b-6c0fcbe236af	[{"id": "9a14e481-bde8-489e-b88a-e9341615989f", "type": "Port", "port_id": "1d3b7bf0-f84b-46f2-8c30-2a5a08b29f74", "interface_id": "d7780799-5133-407d-9da1-741244318edb"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-14T16:00:25.623670210Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e4cca9c1-51e2-4e92-b2e6-9bb2a11b86c3	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:32.64565+00	2025-12-14 16:00:32.64565+00	Home Assistant	69932819-7e06-43b4-8759-185c776664d7	[{"id": "27490e78-795e-486d-90a8-a3e99f8ca726", "type": "Port", "port_id": "3d43935a-db37-4b17-b0d3-fbc219b80d04", "interface_id": "aa5fb6c7-aa61-4c9f-8cd1-27641fe43ddf"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-14T16:00:32.645631832Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b889ee50-3dfc-47c6-a004-fbd9b07131ee	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:44.296165+00	2025-12-14 16:00:44.296165+00	SSH	69932819-7e06-43b4-8759-185c776664d7	[{"id": "c3b83d81-84d8-4c81-bdff-f2adc3f7625f", "type": "Port", "port_id": "672f531f-bdcd-4508-88a3-ca52bdf65fbb", "interface_id": "aa5fb6c7-aa61-4c9f-8cd1-27641fe43ddf"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-14T16:00:44.296147980Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
51eaacdd-6148-44ad-9476-047ff41b5bb7	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:29.685039+00	2025-12-14 16:00:29.685039+00	Scanopy Server	69932819-7e06-43b4-8759-185c776664d7	[{"id": "992633db-ce63-4928-9f79-7ffe85be1530", "type": "Port", "port_id": "27a6aab6-980e-49d0-a6a4-87feaf50ac6f", "interface_id": "aa5fb6c7-aa61-4c9f-8cd1-27641fe43ddf"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-14T16:00:29.685025090Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ac045751-58db-4465-842b-7018a64a9545	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 16:00:44.296347+00	2025-12-14 16:00:44.296347+00	Unclaimed Open Ports	69932819-7e06-43b4-8759-185c776664d7	[{"id": "fca0c514-bab0-4590-b4b4-ac01a1f335f1", "type": "Port", "port_id": "f46a23ea-c69f-44f7-83b5-9ac6dc4d0c2b", "interface_id": "aa5fb6c7-aa61-4c9f-8cd1-27641fe43ddf"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-14T16:00:44.296338833Z", "type": "Network", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
8b4bb1ad-9c83-4458-98ba-f17bf0df15d3	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.111001+00	2025-12-14 15:59:14.111001+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
4a5fa3bf-92a6-4433-a1e7-232c505965ac	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.111005+00	2025-12-14 15:59:14.111005+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
f39269c7-c3ac-470a-a81f-8a1b9ccd32ab	474bb9b3-8c54-4f4c-b465-4de91beb03be	2025-12-14 15:59:14.240516+00	2025-12-14 15:59:14.240516+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-14T15:59:14.240514690Z", "type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
7072aa4e-9299-4d77-adf6-640e85a68b4f	bebb9fa8-3daf-426b-bc9a-8cf4e58d341b	New Tag	\N	2025-12-14 16:00:44.34077+00	2025-12-14 16:00:44.34077+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
e262493d-dc60-46ff-a099-05cab326a83e	474bb9b3-8c54-4f4c-b465-4de91beb03be	My Topology	[]	[{"id": "4a5fa3bf-92a6-4433-a1e7-232c505965ac", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e", "size": {"x": 250, "y": 100}, "header": null, "host_id": "b6a8286d-e736-41ea-b7df-ddfa0d42f07f", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "interface_id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e"}, {"id": "bd842f22-f635-45dc-9da0-bca89a20f7cd", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3a88148f-4dc5-45b5-a4ec-eaf345682e16", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "interface_id": "bd842f22-f635-45dc-9da0-bca89a20f7cd"}, {"id": "b78444f0-03ce-4012-a631-b46179ef5bdb", "size": {"x": 250, "y": 100}, "header": null, "host_id": "ebb251bf-1513-4bda-bf78-5eb10a267bf2", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "4a5fa3bf-92a6-4433-a1e7-232c505965ac", "interface_id": "b78444f0-03ce-4012-a631-b46179ef5bdb"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "b6a8286d-e736-41ea-b7df-ddfa0d42f07f", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "0bc355a2-12d5-4825-bd79-6ea4b88fe428", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "377f6901-eb7e-423d-af00-97adbf9c8645"}, "hostname": null, "services": ["5e256b70-89bb-44e1-b294-fc105806084a"], "created_at": "2025-12-14T15:59:14.111061Z", "interfaces": [{"id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e", "name": "Internet", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.121787Z", "description": null, "virtualization": null}, {"id": "3a88148f-4dc5-45b5-a4ec-eaf345682e16", "name": "Google.com", "tags": [], "ports": [{"id": "7f7acd0c-0aaa-4960-8af1-030a0e6ec445", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "ead4fc9d-7270-4a3e-83d1-6a38b20c5aa4"}, "hostname": null, "services": ["8c388811-b60e-435b-b088-9c2f203a897b"], "created_at": "2025-12-14T15:59:14.111069Z", "interfaces": [{"id": "bd842f22-f635-45dc-9da0-bca89a20f7cd", "name": "Internet", "subnet_id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "ip_address": "203.0.113.219", "mac_address": null}], "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.127299Z", "description": null, "virtualization": null}, {"id": "ebb251bf-1513-4bda-bf78-5eb10a267bf2", "name": "Mobile Device", "tags": [], "ports": [{"id": "ab9724ed-364d-41e1-b31b-b68dcfdedbb9", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3c577142-e451-4a99-a9b7-83f89ac5eca0"}, "hostname": null, "services": ["328b6e2f-9f6c-4c9a-bacf-674e06e7c703"], "created_at": "2025-12-14T15:59:14.111074Z", "interfaces": [{"id": "b78444f0-03ce-4012-a631-b46179ef5bdb", "name": "Remote Network", "subnet_id": "4a5fa3bf-92a6-4433-a1e7-232c505965ac", "ip_address": "203.0.113.115", "mac_address": null}], "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.131471Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "8b4bb1ad-9c83-4458-98ba-f17bf0df15d3", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-14T15:59:14.111001Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.111001Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "4a5fa3bf-92a6-4433-a1e7-232c505965ac", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-14T15:59:14.111005Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.111005Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "f39269c7-c3ac-470a-a81f-8a1b9ccd32ab", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-14T15:59:14.240514690Z", "type": "SelfReport", "host_id": "dee824a6-2f72-4124-8cdf-bc667d5208de", "daemon_id": "a78e883a-1901-47d2-9ca3-a583e417440e"}]}, "created_at": "2025-12-14T15:59:14.240516Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.240516Z", "description": null, "subnet_type": "Lan"}]	[{"id": "5e256b70-89bb-44e1-b294-fc105806084a", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "b6a8286d-e736-41ea-b7df-ddfa0d42f07f", "bindings": [{"id": "377f6901-eb7e-423d-af00-97adbf9c8645", "type": "Port", "port_id": "0bc355a2-12d5-4825-bd79-6ea4b88fe428", "interface_id": "be8f689f-8df2-451f-9f8a-a3a4aa6a3c5e"}], "created_at": "2025-12-14T15:59:14.111063Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.111063Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "8c388811-b60e-435b-b088-9c2f203a897b", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "3a88148f-4dc5-45b5-a4ec-eaf345682e16", "bindings": [{"id": "ead4fc9d-7270-4a3e-83d1-6a38b20c5aa4", "type": "Port", "port_id": "7f7acd0c-0aaa-4960-8af1-030a0e6ec445", "interface_id": "bd842f22-f635-45dc-9da0-bca89a20f7cd"}], "created_at": "2025-12-14T15:59:14.111070Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.111070Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "328b6e2f-9f6c-4c9a-bacf-674e06e7c703", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "ebb251bf-1513-4bda-bf78-5eb10a267bf2", "bindings": [{"id": "3c577142-e451-4a99-a9b7-83f89ac5eca0", "type": "Port", "port_id": "ab9724ed-364d-41e1-b31b-b68dcfdedbb9", "interface_id": "b78444f0-03ce-4012-a631-b46179ef5bdb"}], "created_at": "2025-12-14T15:59:14.111075Z", "network_id": "474bb9b3-8c54-4f4c-b465-4de91beb03be", "updated_at": "2025-12-14T15:59:14.111075Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-14 15:59:14.135522+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-14 15:59:14.132234+00	2025-12-14 16:00:25.704134+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
38f2cb03-5a86-489d-b11a-83a2603f7f2b	2025-12-14 15:59:14.106777+00	2025-12-14 15:59:14.106777+00	$argon2id$v=19$m=19456,t=2,p=1$hhve4kx6BxrV5AOOpjK/eA$jCkD1MM5sqBCzARFDfbpzHdIQDB38FZ18fjSylCPeEM	\N	\N	\N	user@gmail.com	bebb9fa8-3daf-426b-bc9a-8cf4e58d341b	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
UNbbkkpl7xnK8v81Ox_3dg	\\x93c41076f71f3b35fff2ca19ef654a92dbd65081a7757365725f6964d92433386632636230332d356138362d343839642d623131612d38336132363033663766326299cd07ea0d0f3b0ece0ed26685000000	2026-01-13 15:59:14.248669+00
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

\unrestrict WWKvf1tTggefce0IgjcJCE9gAufSotbUyPxSiWFJfVhctKGeVbeA5dx1g6WZTMs

