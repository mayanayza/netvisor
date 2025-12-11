--
-- PostgreSQL database dump
--

\restrict tttC9WIEsU6bI2fyVclHjkxHAuAG6JYQj23vGdzwIjASgYBTeHa1dZWG7DA9Ci1

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
DROP SCHEMA IF EXISTS tower_sessions;
--
-- Name: tower_sessions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tower_sessions;


ALTER SCHEMA tower_sessions OWNER TO postgres;

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
20251006215000	users	2025-12-11 00:50:31.835952+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3423018
20251006215100	networks	2025-12-11 00:50:31.84034+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4692665
20251006215151	create hosts	2025-12-11 00:50:31.845387+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3884001
20251006215155	create subnets	2025-12-11 00:50:31.849597+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3703773
20251006215201	create groups	2025-12-11 00:50:31.85365+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4059670
20251006215204	create daemons	2025-12-11 00:50:31.858083+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4079967
20251006215212	create services	2025-12-11 00:50:31.862498+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4814733
20251029193448	user-auth	2025-12-11 00:50:31.867611+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5653002
20251030044828	daemon api	2025-12-11 00:50:31.87359+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1497794
20251030170438	host-hide	2025-12-11 00:50:31.87537+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1060686
20251102224919	create discovery	2025-12-11 00:50:31.876731+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10729666
20251106235621	normalize-daemon-cols	2025-12-11 00:50:31.887752+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1709269
20251107034459	api keys	2025-12-11 00:50:31.889761+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8056422
20251107222650	oidc-auth	2025-12-11 00:50:31.89811+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26323067
20251110181948	orgs-billing	2025-12-11 00:50:31.924754+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11077087
20251113223656	group-enhancements	2025-12-11 00:50:31.936173+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1052791
20251117032720	daemon-mode	2025-12-11 00:50:31.937551+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1068771
20251118143058	set-default-plan	2025-12-11 00:50:31.939006+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1171603
20251118225043	save-topology	2025-12-11 00:50:31.940473+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8828037
20251123232748	network-permissions	2025-12-11 00:50:31.949608+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2642857
20251125001342	billing-updates	2025-12-11 00:50:31.952642+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	927115
20251128035448	org-onboarding-status	2025-12-11 00:50:31.95384+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1420870
20251129180942	nfs-consolidate	2025-12-11 00:50:31.95553+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1268104
20251206052641	discovery-progress	2025-12-11 00:50:31.95707+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1615684
20251206202200	plan-fix	2025-12-11 00:50:31.959148+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1106150
20251207061341	daemon-url	2025-12-11 00:50:31.960614+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2263578
20251210045929	tags	2025-12-11 00:50:31.96322+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8742529
20251210175035	terms	2025-12-11 00:50:31.972343+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	905245
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
8e50c804-ee2e-442e-a512-ed3901e4630d	c16e65e8bf944d72bd4ad2788dfa7741	a6533ccf-a587-4d65-a55f-064b8e1bf14c	Integrated Daemon API Key	2025-12-11 00:50:34.069289+00	2025-12-11 00:52:08.478257+00	2025-12-11 00:52:08.477519+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
e62f5d0a-0157-47c8-ade1-d51c5ea98dd5	a6533ccf-a587-4d65-a55f-064b8e1bf14c	e1328dac-60b5-489d-ba13-066bcb5c382b	2025-12-11 00:50:34.124728+00	2025-12-11 00:51:47.91509+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["baf287bf-606d-4f6f-be49-d7ee3ad68734"]}	2025-12-11 00:51:47.916623+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
fbcc48d5-7998-4f60-85bb-a5d351a55d19	a6533ccf-a587-4d65-a55f-064b8e1bf14c	e62f5d0a-0157-47c8-ade1-d51c5ea98dd5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b"}	Self Report	2025-12-11 00:50:34.130992+00	2025-12-11 00:50:34.130992+00	{}
9143a365-0d86-4bfd-984e-5300956e7908	a6533ccf-a587-4d65-a55f-064b8e1bf14c	e62f5d0a-0157-47c8-ade1-d51c5ea98dd5	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-11 00:50:34.138103+00	2025-12-11 00:50:34.138103+00	{}
a85cfee7-4d43-46a5-8769-de7fbf47eb38	a6533ccf-a587-4d65-a55f-064b8e1bf14c	e62f5d0a-0157-47c8-ade1-d51c5ea98dd5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "session_id": "0e1ac21f-204b-4351-a1a5-bfac679cc716", "started_at": "2025-12-11T00:50:34.137731988Z", "finished_at": "2025-12-11T00:50:34.264880Z", "discovery_type": {"type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b"}}}	{"type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b"}	Self Report	2025-12-11 00:50:34.137731+00	2025-12-11 00:50:34.267876+00	{}
037e1407-9f90-42ac-9553-0d2dd013d031	a6533ccf-a587-4d65-a55f-064b8e1bf14c	e62f5d0a-0157-47c8-ade1-d51c5ea98dd5	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "session_id": "e1f00d1e-4210-4d35-9583-9a565e8d8856", "started_at": "2025-12-11T00:50:34.278076261Z", "finished_at": "2025-12-11T00:52:08.474294360Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-11 00:50:34.278076+00	2025-12-11 00:52:08.477844+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
1f877627-e501-4154-a3b6-abf8de692660	a6533ccf-a587-4d65-a55f-064b8e1bf14c		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-11 00:52:08.489152+00	2025-12-11 00:52:08.489152+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
d9e00107-4753-46e8-a978-252592892b22	a6533ccf-a587-4d65-a55f-064b8e1bf14c	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "abf0ead4-6b5c-4edf-94b3-83aaabac0d51"}	[{"id": "1f55b314-905f-4387-8b1e-03d3981d86e1", "name": "Internet", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "ip_address": "1.1.1.1", "mac_address": null}]	{3819e9fe-4d8c-425f-920c-908ed503ba64}	[{"id": "a2b92916-1103-402f-b2ea-e9e698c877e8", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-11 00:50:34.043611+00	2025-12-11 00:50:34.052768+00	f	{}
2a7c3651-e5fa-437b-9188-0ef2929d1663	a6533ccf-a587-4d65-a55f-064b8e1bf14c	Google.com	\N	\N	{"type": "ServiceBinding", "config": "3d375a25-3083-43e9-8b11-d92f0ed0dc3e"}	[{"id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f", "name": "Internet", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "ip_address": "203.0.113.211", "mac_address": null}]	{5bdae727-b0aa-4c78-a7a2-82f51bd248f5}	[{"id": "65adcbb5-891d-46e7-907f-6a7d8ceab5cc", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-11 00:50:34.043621+00	2025-12-11 00:50:34.057927+00	f	{}
9b491e02-7f85-4af7-9d6e-4ad3d2384b34	a6533ccf-a587-4d65-a55f-064b8e1bf14c	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "fa8e3874-6e98-4b0c-966e-c95512e8c630"}	[{"id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a", "name": "Remote Network", "subnet_id": "ca67967c-f6c7-4a12-bb9e-410d962d0141", "ip_address": "203.0.113.198", "mac_address": null}]	{72021986-1e75-41f4-b977-b4b6037cb690}	[{"id": "885c1ebb-d980-4809-a1dc-10907e2095f4", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-11 00:50:34.043627+00	2025-12-11 00:50:34.061975+00	f	{}
831d1bd4-7ccf-4e5d-8af1-50a2a6c0b780	a6533ccf-a587-4d65-a55f-064b8e1bf14c	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ebbe2ded-02aa-4ad7-b171-b80985c5d42b", "name": null, "subnet_id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "ip_address": "172.25.0.6", "mac_address": "96:7A:23:67:E7:08"}]	{0fad615a-0b73-40fb-9a83-d35c3b0f4083}	[{"id": "dd420533-2bac-4530-9caf-94ec0c517e4a", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:51:19.835219977Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-11 00:51:19.835223+00	2025-12-11 00:51:34.452955+00	f	{}
e1328dac-60b5-489d-ba13-066bcb5c382b	a6533ccf-a587-4d65-a55f-064b8e1bf14c	netvisor-daemon	abc9a51c0996	NetVisor daemon	{"type": "None"}	[{"id": "048ff7f5-84e1-4e67-ae47-5ef6e22c106c", "name": "eth0", "subnet_id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "ip_address": "172.25.0.4", "mac_address": "6A:46:4E:79:1D:0E"}]	{47ba028f-2275-4702-97f7-fd07c13516c4}	[{"id": "8cd65e6d-255a-4c38-8aea-820d13926c9f", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:50:34.251222613Z", "type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5"}]}	null	2025-12-11 00:50:34.119133+00	2025-12-11 00:50:34.263129+00	f	{}
a2f7407b-cce1-4612-b1cb-8861a857fbbc	a6533ccf-a587-4d65-a55f-064b8e1bf14c	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8be0faa8-43b4-426f-907b-6e1cd5c60de7", "name": null, "subnet_id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "ip_address": "172.25.0.3", "mac_address": "C6:7C:B6:8F:DA:C3"}]	{9fbcded2-9748-4ddd-b83a-ddcc6d29e738}	[{"id": "59667d2c-a900-4030-a6c4-151402fd23a1", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:51:05.054057344Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-11 00:51:05.054068+00	2025-12-11 00:51:19.752984+00	f	{}
b0a492db-04b2-4d13-b72e-fa9140bc6c81	a6533ccf-a587-4d65-a55f-064b8e1bf14c	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c069ea34-12e1-440a-a451-1018398d182b", "name": null, "subnet_id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "ip_address": "172.25.0.5", "mac_address": "F6:8A:4D:95:E5:7A"}]	{2b84f9dd-23eb-4ec5-ac7b-a7f51c1cfab8}	[{"id": "d324caee-9461-4f0b-9a2c-753f9e8c9afe", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "917af64d-815e-4143-94ed-29e56d507799", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:51:34.447603730Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-11 00:51:34.447605+00	2025-12-11 00:51:49.135298+00	f	{}
79b9a101-862c-47e3-8c03-b0614d6645c7	a6533ccf-a587-4d65-a55f-064b8e1bf14c	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "42df08ea-eecb-42d3-9e53-4da360e00d10", "name": null, "subnet_id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "ip_address": "172.25.0.1", "mac_address": "5E:0A:64:0E:EB:C3"}]	{8e759a90-747d-4bc6-8987-531fad9c7fef,10886ea7-a407-4f24-827a-006ffdbf8c04,eeede92c-726f-4cc6-8b24-9c0e2b0d040b,873138ee-5d3b-41a4-a1d4-6d6ef3bf3095}	[{"id": "f9bbda96-33f7-4505-bb95-330c04645ffc", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "17e4f057-e97b-4c04-a9c1-188091bd30da", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ccc137dc-3363-407c-ab86-120af95abb12", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "aba5e9ea-4293-4dad-af46-524d15f4d34e", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:51:53.198020462Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-11 00:51:53.198024+00	2025-12-11 00:52:08.466761+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
a6533ccf-a587-4d65-a55f-064b8e1bf14c	My Network	2025-12-11 00:50:34.042301+00	2025-12-11 00:50:34.042301+00	f	4d094047-651f-4594-b9fe-2af03aa958f0	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
4d094047-651f-4594-b9fe-2af03aa958f0	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-11 00:50:34.020902+00	2025-12-11 00:50:34.130201+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
3819e9fe-4d8c-425f-920c-908ed503ba64	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.043614+00	2025-12-11 00:50:34.043614+00	Cloudflare DNS	d9e00107-4753-46e8-a978-252592892b22	[{"id": "abf0ead4-6b5c-4edf-94b3-83aaabac0d51", "type": "Port", "port_id": "a2b92916-1103-402f-b2ea-e9e698c877e8", "interface_id": "1f55b314-905f-4387-8b1e-03d3981d86e1"}]	"Dns Server"	null	{"type": "System"}	{}
5bdae727-b0aa-4c78-a7a2-82f51bd248f5	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.043623+00	2025-12-11 00:50:34.043623+00	Google.com	2a7c3651-e5fa-437b-9188-0ef2929d1663	[{"id": "3d375a25-3083-43e9-8b11-d92f0ed0dc3e", "type": "Port", "port_id": "65adcbb5-891d-46e7-907f-6a7d8ceab5cc", "interface_id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f"}]	"Web Service"	null	{"type": "System"}	{}
72021986-1e75-41f4-b977-b4b6037cb690	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.043628+00	2025-12-11 00:50:34.043628+00	Mobile Device	9b491e02-7f85-4af7-9d6e-4ad3d2384b34	[{"id": "fa8e3874-6e98-4b0c-966e-c95512e8c630", "type": "Port", "port_id": "885c1ebb-d980-4809-a1dc-10907e2095f4", "interface_id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a"}]	"Client"	null	{"type": "System"}	{}
47ba028f-2275-4702-97f7-fd07c13516c4	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.251239+00	2025-12-11 00:50:34.251239+00	NetVisor Daemon API	e1328dac-60b5-489d-ba13-066bcb5c382b	[{"id": "2572ef8a-b091-4648-85ba-8ce7f6ae1ddb", "type": "Port", "port_id": "8cd65e6d-255a-4c38-8aea-820d13926c9f", "interface_id": "048ff7f5-84e1-4e67-ae47-5ef6e22c106c"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-11T00:50:34.251238143Z", "type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5"}]}	{}
9fbcded2-9748-4ddd-b83a-ddcc6d29e738	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:51:08.840474+00	2025-12-11 00:51:08.840474+00	NetVisor Server API	a2f7407b-cce1-4612-b1cb-8861a857fbbc	[{"id": "cd77d6de-be98-4fd6-8736-4320a7157e1d", "type": "Port", "port_id": "59667d2c-a900-4030-a6c4-151402fd23a1", "interface_id": "8be0faa8-43b4-426f-907b-6e1cd5c60de7"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-11T00:51:08.840455020Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0fad615a-0b73-40fb-9a83-d35c3b0f4083	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:51:34.440116+00	2025-12-11 00:51:34.440116+00	PostgreSQL	831d1bd4-7ccf-4e5d-8af1-50a2a6c0b780	[{"id": "5045103e-c93d-485f-833f-28dcae948b92", "type": "Port", "port_id": "dd420533-2bac-4530-9caf-94ec0c517e4a", "interface_id": "ebbe2ded-02aa-4ad7-b171-b80985c5d42b"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-11T00:51:34.440095557Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2b84f9dd-23eb-4ec5-ac7b-a7f51c1cfab8	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:51:49.125634+00	2025-12-11 00:51:49.125634+00	Unclaimed Open Ports	b0a492db-04b2-4d13-b72e-fa9140bc6c81	[{"id": "dd88fbfb-93c7-44d6-bfbf-30849313c91d", "type": "Port", "port_id": "d324caee-9461-4f0b-9a2c-753f9e8c9afe", "interface_id": "c069ea34-12e1-440a-a451-1018398d182b"}, {"id": "11cd98d8-4c30-4028-941f-c2626eb7674c", "type": "Port", "port_id": "917af64d-815e-4143-94ed-29e56d507799", "interface_id": "c069ea34-12e1-440a-a451-1018398d182b"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-11T00:51:49.125617439Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
8e759a90-747d-4bc6-8987-531fad9c7fef	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:51:56.961429+00	2025-12-11 00:51:56.961429+00	NetVisor Server API	79b9a101-862c-47e3-8c03-b0614d6645c7	[{"id": "f1f3328b-ea56-455e-8f67-6147e61a64fe", "type": "Port", "port_id": "f9bbda96-33f7-4505-bb95-330c04645ffc", "interface_id": "42df08ea-eecb-42d3-9e53-4da360e00d10"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-11T00:51:56.961407389Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
eeede92c-726f-4cc6-8b24-9c0e2b0d040b	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:52:08.450813+00	2025-12-11 00:52:08.450813+00	SSH	79b9a101-862c-47e3-8c03-b0614d6645c7	[{"id": "3b0b1ded-f89e-45c2-8b52-99f1f93fa046", "type": "Port", "port_id": "ccc137dc-3363-407c-ab86-120af95abb12", "interface_id": "42df08ea-eecb-42d3-9e53-4da360e00d10"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-11T00:52:08.450795384Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
10886ea7-a407-4f24-827a-006ffdbf8c04	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:52:03.846708+00	2025-12-11 00:52:03.846708+00	Home Assistant	79b9a101-862c-47e3-8c03-b0614d6645c7	[{"id": "fc7bc1b7-cc06-43ee-b165-1627444fe720", "type": "Port", "port_id": "17e4f057-e97b-4c04-a9c1-188091bd30da", "interface_id": "42df08ea-eecb-42d3-9e53-4da360e00d10"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-11T00:52:03.846675228Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
873138ee-5d3b-41a4-a1d4-6d6ef3bf3095	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:52:08.451226+00	2025-12-11 00:52:08.451226+00	Unclaimed Open Ports	79b9a101-862c-47e3-8c03-b0614d6645c7	[{"id": "8b3905ca-8942-4d83-915b-25d014535959", "type": "Port", "port_id": "aba5e9ea-4293-4dad-af46-524d15f4d34e", "interface_id": "42df08ea-eecb-42d3-9e53-4da360e00d10"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-11T00:52:08.451217653Z", "type": "Network", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
c63c0f7c-a004-462d-b17a-3369fd020f86	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.043563+00	2025-12-11 00:50:34.043563+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
ca67967c-f6c7-4a12-bb9e-410d962d0141	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.043567+00	2025-12-11 00:50:34.043567+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
baf287bf-606d-4f6f-be49-d7ee3ad68734	a6533ccf-a587-4d65-a55f-064b8e1bf14c	2025-12-11 00:50:34.137916+00	2025-12-11 00:50:34.137916+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-11T00:50:34.137914750Z", "type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
c00bde18-7e63-49ed-827d-04e7640882d3	4d094047-651f-4594-b9fe-2af03aa958f0	New Tag	\N	2025-12-11 00:52:08.497572+00	2025-12-11 00:52:08.497572+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
1e9e4af3-d278-4b8d-a29f-40fb7cac7bf1	a6533ccf-a587-4d65-a55f-064b8e1bf14c	My Topology	[]	[{"id": "ca67967c-f6c7-4a12-bb9e-410d962d0141", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "9b491e02-7f85-4af7-9d6e-4ad3d2384b34", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "ca67967c-f6c7-4a12-bb9e-410d962d0141", "interface_id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a"}, {"id": "1f55b314-905f-4387-8b1e-03d3981d86e1", "size": {"x": 250, "y": 100}, "header": null, "host_id": "d9e00107-4753-46e8-a978-252592892b22", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "interface_id": "1f55b314-905f-4387-8b1e-03d3981d86e1"}, {"id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2a7c3651-e5fa-437b-9188-0ef2929d1663", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "interface_id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "d9e00107-4753-46e8-a978-252592892b22", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "a2b92916-1103-402f-b2ea-e9e698c877e8", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "abf0ead4-6b5c-4edf-94b3-83aaabac0d51"}, "hostname": null, "services": ["3819e9fe-4d8c-425f-920c-908ed503ba64"], "created_at": "2025-12-11T00:50:34.043611Z", "interfaces": [{"id": "1f55b314-905f-4387-8b1e-03d3981d86e1", "name": "Internet", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.052768Z", "description": null, "virtualization": null}, {"id": "2a7c3651-e5fa-437b-9188-0ef2929d1663", "name": "Google.com", "tags": [], "ports": [{"id": "65adcbb5-891d-46e7-907f-6a7d8ceab5cc", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3d375a25-3083-43e9-8b11-d92f0ed0dc3e"}, "hostname": null, "services": ["5bdae727-b0aa-4c78-a7a2-82f51bd248f5"], "created_at": "2025-12-11T00:50:34.043621Z", "interfaces": [{"id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f", "name": "Internet", "subnet_id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "ip_address": "203.0.113.211", "mac_address": null}], "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.057927Z", "description": null, "virtualization": null}, {"id": "9b491e02-7f85-4af7-9d6e-4ad3d2384b34", "name": "Mobile Device", "tags": [], "ports": [{"id": "885c1ebb-d980-4809-a1dc-10907e2095f4", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "fa8e3874-6e98-4b0c-966e-c95512e8c630"}, "hostname": null, "services": ["72021986-1e75-41f4-b977-b4b6037cb690"], "created_at": "2025-12-11T00:50:34.043627Z", "interfaces": [{"id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a", "name": "Remote Network", "subnet_id": "ca67967c-f6c7-4a12-bb9e-410d962d0141", "ip_address": "203.0.113.198", "mac_address": null}], "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.061975Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "c63c0f7c-a004-462d-b17a-3369fd020f86", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-11T00:50:34.043563Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.043563Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "ca67967c-f6c7-4a12-bb9e-410d962d0141", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-11T00:50:34.043567Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.043567Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "baf287bf-606d-4f6f-be49-d7ee3ad68734", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-11T00:50:34.137914750Z", "type": "SelfReport", "host_id": "e1328dac-60b5-489d-ba13-066bcb5c382b", "daemon_id": "e62f5d0a-0157-47c8-ade1-d51c5ea98dd5"}]}, "created_at": "2025-12-11T00:50:34.137916Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.137916Z", "description": null, "subnet_type": "Lan"}]	[{"id": "3819e9fe-4d8c-425f-920c-908ed503ba64", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "d9e00107-4753-46e8-a978-252592892b22", "bindings": [{"id": "abf0ead4-6b5c-4edf-94b3-83aaabac0d51", "type": "Port", "port_id": "a2b92916-1103-402f-b2ea-e9e698c877e8", "interface_id": "1f55b314-905f-4387-8b1e-03d3981d86e1"}], "created_at": "2025-12-11T00:50:34.043614Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.043614Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5bdae727-b0aa-4c78-a7a2-82f51bd248f5", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "2a7c3651-e5fa-437b-9188-0ef2929d1663", "bindings": [{"id": "3d375a25-3083-43e9-8b11-d92f0ed0dc3e", "type": "Port", "port_id": "65adcbb5-891d-46e7-907f-6a7d8ceab5cc", "interface_id": "fe206e1b-51cb-4f17-8a7f-240ce5293d8f"}], "created_at": "2025-12-11T00:50:34.043623Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.043623Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "72021986-1e75-41f4-b977-b4b6037cb690", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "9b491e02-7f85-4af7-9d6e-4ad3d2384b34", "bindings": [{"id": "fa8e3874-6e98-4b0c-966e-c95512e8c630", "type": "Port", "port_id": "885c1ebb-d980-4809-a1dc-10907e2095f4", "interface_id": "ae8cabbe-70e3-4e32-b1da-ee80532bea5a"}], "created_at": "2025-12-11T00:50:34.043628Z", "network_id": "a6533ccf-a587-4d65-a55f-064b8e1bf14c", "updated_at": "2025-12-11T00:50:34.043628Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-11 00:50:34.06649+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-11 00:50:34.062771+00	2025-12-11 00:51:49.239191+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
5dde8625-4899-41d7-97ad-3816dba8183f	2025-12-11 00:50:34.023764+00	2025-12-11 00:50:34.023764+00	$argon2id$v=19$m=19456,t=2,p=1$lsbWPgxy1dr5SORpSW8pBA$erxcueuLrW28UdWQD8b1up+zfhh9nT45LtYobIz/T2w	\N	\N	\N	user@gmail.com	4d094047-651f-4594-b9fe-2af03aa958f0	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
Bq4dCLPg9IIChv6J8V2M2A	\\x93c410d88c5df189fe860282f4e0b3081dae0681a7757365725f6964d92435646465383632352d343839392d343164372d393761642d33383136646261383138336699cd07ea0a003222ce01a59eea000000	2026-01-10 00:50:34.027631+00
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

\unrestrict tttC9WIEsU6bI2fyVclHjkxHAuAG6JYQj23vGdzwIjASgYBTeHa1dZWG7DA9Ci1

