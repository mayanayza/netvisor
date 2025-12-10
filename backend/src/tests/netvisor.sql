--
-- PostgreSQL database dump
--

\restrict 14chabhhlkDQezGfasqrtsljTJvc1d2w9VLc7tWzUcQ8M56TCQe15Tblvq9WlG6

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
    tags uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-10 16:48:47.951661+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3391695
20251006215100	networks	2025-12-10 16:48:47.956338+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5111057
20251006215151	create hosts	2025-12-10 16:48:47.961769+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3829944
20251006215155	create subnets	2025-12-10 16:48:47.965929+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3743672
20251006215201	create groups	2025-12-10 16:48:47.969996+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4029957
20251006215204	create daemons	2025-12-10 16:48:47.974417+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4078508
20251006215212	create services	2025-12-10 16:48:47.978838+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4737929
20251029193448	user-auth	2025-12-10 16:48:47.983886+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	7064525
20251030044828	daemon api	2025-12-10 16:48:47.991257+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1522954
20251030170438	host-hide	2025-12-10 16:48:47.993087+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1117527
20251102224919	create discovery	2025-12-10 16:48:47.994489+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11533735
20251106235621	normalize-daemon-cols	2025-12-10 16:48:48.006363+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1724231
20251107034459	api keys	2025-12-10 16:48:48.008438+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8787093
20251107222650	oidc-auth	2025-12-10 16:48:48.017533+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	33363977
20251110181948	orgs-billing	2025-12-10 16:48:48.051219+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11784292
20251113223656	group-enhancements	2025-12-10 16:48:48.063407+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1271501
20251117032720	daemon-mode	2025-12-10 16:48:48.06498+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1304246
20251118143058	set-default-plan	2025-12-10 16:48:48.066661+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1389205
20251118225043	save-topology	2025-12-10 16:48:48.068405+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	11499138
20251123232748	network-permissions	2025-12-10 16:48:48.080309+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3536466
20251125001342	billing-updates	2025-12-10 16:48:48.08416+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1025064
20251128035448	org-onboarding-status	2025-12-10 16:48:48.085492+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1827643
20251129180942	nfs-consolidate	2025-12-10 16:48:48.087739+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	2635022
20251206052641	discovery-progress	2025-12-10 16:48:48.090893+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	2262458
20251206202200	plan-fix	2025-12-10 16:48:48.093489+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1050530
20251207061341	daemon-url	2025-12-10 16:48:48.094873+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	3581687
20251210045929	tags	2025-12-10 16:48:48.098879+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9540537
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
5cad1b6f-45e5-41fb-b4ae-85052cc16955	75137920ab334f699ccada13cff5d746	a880a270-8657-4f2a-a285-092dd410cd53	Integrated Daemon API Key	2025-12-10 16:48:50.499868+00	2025-12-10 16:50:27.053863+00	2025-12-10 16:50:27.053118+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8	a880a270-8657-4f2a-a285-092dd410cd53	e79389f5-18e8-4f9c-89fd-7bd1efc6240f	2025-12-10 16:48:50.625333+00	2025-12-10 16:50:07.019645+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["f75f8541-af91-4569-b9cc-3e04261d81bb"]}	2025-12-10 16:50:07.020176+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
20aae18c-bf81-439c-a178-5981c33cf183	a880a270-8657-4f2a-a285-092dd410cd53	01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f"}	Self Report	2025-12-10 16:48:50.632749+00	2025-12-10 16:48:50.632749+00	{}
079504f2-ba54-4972-b82f-89bfe2dfd3de	a880a270-8657-4f2a-a285-092dd410cd53	01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 16:48:50.642759+00	2025-12-10 16:48:50.642759+00	{}
0b408148-a7d6-4767-87f6-4e6bf7a972da	a880a270-8657-4f2a-a285-092dd410cd53	01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "session_id": "2db8c6f3-ea2d-45c4-9aa5-04fe3b105afd", "started_at": "2025-12-10T16:48:50.642126736Z", "finished_at": "2025-12-10T16:48:50.728044964Z", "discovery_type": {"type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f"}}}	{"type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f"}	Self Report	2025-12-10 16:48:50.642126+00	2025-12-10 16:48:50.733641+00	{}
e2a8ffe9-d914-49df-aa6f-0b2f04ecdf1d	a880a270-8657-4f2a-a285-092dd410cd53	01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "session_id": "9db3159c-868e-447f-b1da-bed8a32ff489", "started_at": "2025-12-10T16:48:50.751535810Z", "finished_at": "2025-12-10T16:50:27.050270446Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-10 16:48:50.751535+00	2025-12-10 16:50:27.053365+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
830514c0-9047-49ee-aaf4-ada66af92b27	a880a270-8657-4f2a-a285-092dd410cd53		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-10 16:50:27.064926+00	2025-12-10 16:50:27.064926+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
649ec0bd-68f3-460c-bc9f-893a4d50d98a	a880a270-8657-4f2a-a285-092dd410cd53	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "d9898991-4c3e-4c92-a771-5b156c7b11a4"}	[{"id": "1cd14608-a234-4e2c-8e29-c04e6c597a99", "name": "Internet", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "ip_address": "1.1.1.1", "mac_address": null}]	{a48e660d-cc53-4d98-97a0-92fa35e80942}	[{"id": "02b30ea8-8ca5-435b-8f6c-5455c20ac40c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-10 16:48:50.472345+00	2025-12-10 16:48:50.482599+00	f	{}
a66aa300-7b10-4143-beed-e3074277c2fc	a880a270-8657-4f2a-a285-092dd410cd53	Google.com	\N	\N	{"type": "ServiceBinding", "config": "e5e625fc-dfb6-49bb-b81b-306ccb2bc5a5"}	[{"id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf", "name": "Internet", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "ip_address": "203.0.113.176", "mac_address": null}]	{5a81ef97-5bd2-4430-888b-bcfe8b865b53}	[{"id": "afcec77a-2468-40a6-88f1-37ddd701633f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 16:48:50.472356+00	2025-12-10 16:48:50.488007+00	f	{}
755d6960-a172-4313-be11-1c806675961a	a880a270-8657-4f2a-a285-092dd410cd53	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "8f91ffb0-1401-415f-8959-4728dccc2581"}	[{"id": "644089ac-babc-412f-8341-65fa6102b165", "name": "Remote Network", "subnet_id": "b309bea7-4447-43a4-90e6-8421ae9c936c", "ip_address": "203.0.113.41", "mac_address": null}]	{35fa6612-9418-4fb2-a4a1-65d83cf5d860}	[{"id": "fad2424f-8f22-4c45-9d43-f910d3fdd3b1", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-10 16:48:50.472361+00	2025-12-10 16:48:50.491951+00	f	{}
29d88152-8889-4378-99b7-5789b8c482b5	a880a270-8657-4f2a-a285-092dd410cd53	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e8e67543-1281-42f2-8ee9-ce594f59c549", "name": null, "subnet_id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "ip_address": "172.25.0.5", "mac_address": "32:10:A9:7E:93:1A"}]	{a1ec164b-4755-4ea3-aea6-c10acc8848f5,b9d8eac4-20d6-40a1-9614-34856ed325f2}	[{"id": "8fb96f0f-83f5-41df-87aa-54149699792a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "bf09736c-2aaf-406d-8e2a-9a844b91773d", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:49:38.234845396Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 16:49:38.234848+00	2025-12-10 16:49:52.572004+00	f	{}
e79389f5-18e8-4f9c-89fd-7bd1efc6240f	a880a270-8657-4f2a-a285-092dd410cd53	netvisor-daemon	f15897daa029	NetVisor daemon	{"type": "None"}	[{"id": "a8583d67-5a83-450d-a95e-fb6e83d51eda", "name": "eth0", "subnet_id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "ip_address": "172.25.0.4", "mac_address": "D6:9E:DC:3B:D3:1A"}]	{41a5b8b1-c723-4297-969d-c43ade56a70d}	[{"id": "b6dd8cb6-223b-4b65-ab27-c122b1a9f543", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:48:50.705312594Z", "type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8"}]}	null	2025-12-10 16:48:50.586044+00	2025-12-10 16:48:50.725571+00	f	{}
9b30c660-f696-4ef7-84de-5b9e4adb5156	a880a270-8657-4f2a-a285-092dd410cd53	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "3be3b6f5-0573-467c-ab23-c04f6452f1da", "name": null, "subnet_id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "ip_address": "172.25.0.6", "mac_address": "26:2D:4E:61:46:29"}]	{e915b0e8-e0f3-489c-b86d-814784029199}	[{"id": "79895149-6391-4149-a1fc-05909d6b05e2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:49:23.427827206Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 16:49:23.42783+00	2025-12-10 16:49:38.147741+00	f	{}
2098548a-f16e-488a-945b-c2579f646de4	a880a270-8657-4f2a-a285-092dd410cd53	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e1e65986-e677-4d79-848f-a6db1005be08", "name": null, "subnet_id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "ip_address": "172.25.0.3", "mac_address": "C6:61:28:B7:62:7D"}]	{6357bfc1-602c-4e4b-9263-7373ed913a18}	[{"id": "aeb09a0c-36e7-4a55-a693-c0e3aa4998b9", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:49:52.560669910Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 16:49:52.560671+00	2025-12-10 16:50:06.832501+00	f	{}
05cb8051-d550-424f-8418-6d002b7814b1	a880a270-8657-4f2a-a285-092dd410cd53	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "873a771b-c4be-4624-8731-ea2b9b2c4dd4", "name": null, "subnet_id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "ip_address": "172.25.0.1", "mac_address": "8A:16:F2:0F:C7:60"}]	{fb803de5-bd3c-4b6d-a1f5-c5eab1a50f03,f1659eba-40d1-40a8-a593-6cbfeff489dd,9e6e526c-bbfc-458e-8806-ca36a12a4cd1,b6dba59f-a36c-48a4-a0e1-f85be3bf2ce0}	[{"id": "022eb7af-9621-429d-952f-0a4186117ae9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "cda5c60d-ce9a-43b7-98be-11b22f24eaa0", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "571971b1-1576-4963-b848-6c66c13ed020", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "113f8625-5e4b-4425-846e-a4eb0c2dc578", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:50:12.879694399Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-10 16:50:12.879697+00	2025-12-10 16:50:27.044486+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
a880a270-8657-4f2a-a285-092dd410cd53	My Network	2025-12-10 16:48:50.47077+00	2025-12-10 16:48:50.47077+00	f	9ca46e04-3f95-4480-ac1d-1ddc5d244f11	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
9ca46e04-3f95-4480-ac1d-1ddc5d244f11	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-10 16:48:48.164025+00	2025-12-10 16:48:50.631682+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
a48e660d-cc53-4d98-97a0-92fa35e80942	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.472349+00	2025-12-10 16:48:50.472349+00	Cloudflare DNS	649ec0bd-68f3-460c-bc9f-893a4d50d98a	[{"id": "d9898991-4c3e-4c92-a771-5b156c7b11a4", "type": "Port", "port_id": "02b30ea8-8ca5-435b-8f6c-5455c20ac40c", "interface_id": "1cd14608-a234-4e2c-8e29-c04e6c597a99"}]	"Dns Server"	null	{"type": "System"}	{}
5a81ef97-5bd2-4430-888b-bcfe8b865b53	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.472357+00	2025-12-10 16:48:50.472357+00	Google.com	a66aa300-7b10-4143-beed-e3074277c2fc	[{"id": "e5e625fc-dfb6-49bb-b81b-306ccb2bc5a5", "type": "Port", "port_id": "afcec77a-2468-40a6-88f1-37ddd701633f", "interface_id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf"}]	"Web Service"	null	{"type": "System"}	{}
35fa6612-9418-4fb2-a4a1-65d83cf5d860	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.472362+00	2025-12-10 16:48:50.472362+00	Mobile Device	755d6960-a172-4313-be11-1c806675961a	[{"id": "8f91ffb0-1401-415f-8959-4728dccc2581", "type": "Port", "port_id": "fad2424f-8f22-4c45-9d43-f910d3fdd3b1", "interface_id": "644089ac-babc-412f-8341-65fa6102b165"}]	"Client"	null	{"type": "System"}	{}
41a5b8b1-c723-4297-969d-c43ade56a70d	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.705339+00	2025-12-10 16:48:50.705339+00	NetVisor Daemon API	e79389f5-18e8-4f9c-89fd-7bd1efc6240f	[{"id": "02bfce41-19c7-49fd-8c60-353ea9e09a92", "type": "Port", "port_id": "b6dd8cb6-223b-4b65-ab27-c122b1a9f543", "interface_id": "a8583d67-5a83-450d-a95e-fb6e83d51eda"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-10T16:48:50.705338693Z", "type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8"}]}	{}
e915b0e8-e0f3-489c-b86d-814784029199	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:49:38.133733+00	2025-12-10 16:49:38.133733+00	PostgreSQL	9b30c660-f696-4ef7-84de-5b9e4adb5156	[{"id": "60a86e13-654b-4794-997e-9d0d806eeea2", "type": "Port", "port_id": "79895149-6391-4149-a1fc-05909d6b05e2", "interface_id": "3be3b6f5-0573-467c-ab23-c04f6452f1da"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T16:49:38.133711263Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b9d8eac4-20d6-40a1-9614-34856ed325f2	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:49:52.559298+00	2025-12-10 16:49:52.559298+00	Unclaimed Open Ports	29d88152-8889-4378-99b7-5789b8c482b5	[{"id": "992a0615-702d-417e-b873-b8fbd805c6e6", "type": "Port", "port_id": "bf09736c-2aaf-406d-8e2a-9a844b91773d", "interface_id": "e8e67543-1281-42f2-8ee9-ce594f59c549"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T16:49:52.559275520Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a1ec164b-4755-4ea3-aea6-c10acc8848f5	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:49:38.235265+00	2025-12-10 16:49:38.235265+00	Home Assistant	29d88152-8889-4378-99b7-5789b8c482b5	[{"id": "1a6e120b-9d55-4ea4-8512-fb07ac5d6aa6", "type": "Port", "port_id": "8fb96f0f-83f5-41df-87aa-54149699792a", "interface_id": "e8e67543-1281-42f2-8ee9-ce594f59c549"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T16:49:38.235250452Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6357bfc1-602c-4e4b-9263-7373ed913a18	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:50:06.821863+00	2025-12-10 16:50:06.821863+00	NetVisor Server API	2098548a-f16e-488a-945b-c2579f646de4	[{"id": "eb8faf8d-19d2-4800-aaa8-a842263cad58", "type": "Port", "port_id": "aeb09a0c-36e7-4a55-a693-c0e3aa4998b9", "interface_id": "e1e65986-e677-4d79-848f-a6db1005be08"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T16:50:06.821847907Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f1659eba-40d1-40a8-a593-6cbfeff489dd	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:50:27.029198+00	2025-12-10 16:50:27.029198+00	NetVisor Server API	05cb8051-d550-424f-8418-6d002b7814b1	[{"id": "653fb660-e95d-4cf9-a9d2-f5b89d3a6bc2", "type": "Port", "port_id": "cda5c60d-ce9a-43b7-98be-11b22f24eaa0", "interface_id": "873a771b-c4be-4624-8731-ea2b9b2c4dd4"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T16:50:27.029180606Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
fb803de5-bd3c-4b6d-a1f5-c5eab1a50f03	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:50:12.879993+00	2025-12-10 16:50:12.879993+00	Home Assistant	05cb8051-d550-424f-8418-6d002b7814b1	[{"id": "4069f5af-d41f-42cf-b1d5-d46646b5ade8", "type": "Port", "port_id": "022eb7af-9621-429d-952f-0a4186117ae9", "interface_id": "873a771b-c4be-4624-8731-ea2b9b2c4dd4"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-10T16:50:12.879978089Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9e6e526c-bbfc-458e-8806-ca36a12a4cd1	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:50:27.030274+00	2025-12-10 16:50:27.030274+00	SSH	05cb8051-d550-424f-8418-6d002b7814b1	[{"id": "048da2ac-a923-445a-a4a1-d54741f65f46", "type": "Port", "port_id": "571971b1-1576-4963-b848-6c66c13ed020", "interface_id": "873a771b-c4be-4624-8731-ea2b9b2c4dd4"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T16:50:27.030265151Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b6dba59f-a36c-48a4-a0e1-f85be3bf2ce0	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:50:27.030651+00	2025-12-10 16:50:27.030651+00	Unclaimed Open Ports	05cb8051-d550-424f-8418-6d002b7814b1	[{"id": "eba38402-14ca-41ec-af4e-2c0a6f8f3d52", "type": "Port", "port_id": "113f8625-5e4b-4425-846e-a4eb0c2dc578", "interface_id": "873a771b-c4be-4624-8731-ea2b9b2c4dd4"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-10T16:50:27.030643768Z", "type": "Network", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.472282+00	2025-12-10 16:48:50.472282+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
b309bea7-4447-43a4-90e6-8421ae9c936c	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.472286+00	2025-12-10 16:48:50.472286+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
f75f8541-af91-4569-b9cc-3e04261d81bb	a880a270-8657-4f2a-a285-092dd410cd53	2025-12-10 16:48:50.642304+00	2025-12-10 16:48:50.642304+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-10T16:48:50.642303045Z", "type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
ba520aa8-ef23-4bde-bf36-8e529f4734c6	9ca46e04-3f95-4480-ac1d-1ddc5d244f11	New Tag	\N	2025-12-10 16:50:27.071355+00	2025-12-10 16:50:27.071355+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
1175f3f3-1242-4678-9806-8df99d812a65	a880a270-8657-4f2a-a285-092dd410cd53	My Topology	[]	[{"id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "b309bea7-4447-43a4-90e6-8421ae9c936c", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "1cd14608-a234-4e2c-8e29-c04e6c597a99", "size": {"x": 250, "y": 100}, "header": null, "host_id": "649ec0bd-68f3-460c-bc9f-893a4d50d98a", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "interface_id": "1cd14608-a234-4e2c-8e29-c04e6c597a99"}, {"id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a66aa300-7b10-4143-beed-e3074277c2fc", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "interface_id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf"}, {"id": "644089ac-babc-412f-8341-65fa6102b165", "size": {"x": 250, "y": 100}, "header": null, "host_id": "755d6960-a172-4313-be11-1c806675961a", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "b309bea7-4447-43a4-90e6-8421ae9c936c", "interface_id": "644089ac-babc-412f-8341-65fa6102b165"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "649ec0bd-68f3-460c-bc9f-893a4d50d98a", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "02b30ea8-8ca5-435b-8f6c-5455c20ac40c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "d9898991-4c3e-4c92-a771-5b156c7b11a4"}, "hostname": null, "services": ["a48e660d-cc53-4d98-97a0-92fa35e80942"], "created_at": "2025-12-10T16:48:50.472345Z", "interfaces": [{"id": "1cd14608-a234-4e2c-8e29-c04e6c597a99", "name": "Internet", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.482599Z", "description": null, "virtualization": null}, {"id": "a66aa300-7b10-4143-beed-e3074277c2fc", "name": "Google.com", "tags": [], "ports": [{"id": "afcec77a-2468-40a6-88f1-37ddd701633f", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "e5e625fc-dfb6-49bb-b81b-306ccb2bc5a5"}, "hostname": null, "services": ["5a81ef97-5bd2-4430-888b-bcfe8b865b53"], "created_at": "2025-12-10T16:48:50.472356Z", "interfaces": [{"id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf", "name": "Internet", "subnet_id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "ip_address": "203.0.113.176", "mac_address": null}], "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.488007Z", "description": null, "virtualization": null}, {"id": "755d6960-a172-4313-be11-1c806675961a", "name": "Mobile Device", "tags": [], "ports": [{"id": "fad2424f-8f22-4c45-9d43-f910d3fdd3b1", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8f91ffb0-1401-415f-8959-4728dccc2581"}, "hostname": null, "services": ["35fa6612-9418-4fb2-a4a1-65d83cf5d860"], "created_at": "2025-12-10T16:48:50.472361Z", "interfaces": [{"id": "644089ac-babc-412f-8341-65fa6102b165", "name": "Remote Network", "subnet_id": "b309bea7-4447-43a4-90e6-8421ae9c936c", "ip_address": "203.0.113.41", "mac_address": null}], "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.491951Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "acb5fb28-bc8e-46b5-8abc-f8cf6b692b2a", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-10T16:48:50.472282Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.472282Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "b309bea7-4447-43a4-90e6-8421ae9c936c", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-10T16:48:50.472286Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.472286Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "f75f8541-af91-4569-b9cc-3e04261d81bb", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-10T16:48:50.642303045Z", "type": "SelfReport", "host_id": "e79389f5-18e8-4f9c-89fd-7bd1efc6240f", "daemon_id": "01e9fb0a-7e27-4457-ad82-2c39e6e2f0a8"}]}, "created_at": "2025-12-10T16:48:50.642304Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.642304Z", "description": null, "subnet_type": "Lan"}]	[{"id": "a48e660d-cc53-4d98-97a0-92fa35e80942", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "649ec0bd-68f3-460c-bc9f-893a4d50d98a", "bindings": [{"id": "d9898991-4c3e-4c92-a771-5b156c7b11a4", "type": "Port", "port_id": "02b30ea8-8ca5-435b-8f6c-5455c20ac40c", "interface_id": "1cd14608-a234-4e2c-8e29-c04e6c597a99"}], "created_at": "2025-12-10T16:48:50.472349Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.472349Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5a81ef97-5bd2-4430-888b-bcfe8b865b53", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "a66aa300-7b10-4143-beed-e3074277c2fc", "bindings": [{"id": "e5e625fc-dfb6-49bb-b81b-306ccb2bc5a5", "type": "Port", "port_id": "afcec77a-2468-40a6-88f1-37ddd701633f", "interface_id": "ff0ec7e1-5d14-4c59-972b-0a9b0294c8bf"}], "created_at": "2025-12-10T16:48:50.472357Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.472357Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "35fa6612-9418-4fb2-a4a1-65d83cf5d860", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "755d6960-a172-4313-be11-1c806675961a", "bindings": [{"id": "8f91ffb0-1401-415f-8959-4728dccc2581", "type": "Port", "port_id": "fad2424f-8f22-4c45-9d43-f910d3fdd3b1", "interface_id": "644089ac-babc-412f-8341-65fa6102b165"}], "created_at": "2025-12-10T16:48:50.472362Z", "network_id": "a880a270-8657-4f2a-a285-092dd410cd53", "updated_at": "2025-12-10T16:48:50.472362Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-10 16:48:50.49689+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-10 16:48:50.492747+00	2025-12-10 16:50:06.971784+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags) FROM stdin;
4703e511-30bb-4d5f-a6e1-39ce198679f1	2025-12-10 16:48:48.165966+00	2025-12-10 16:48:50.45211+00	$argon2id$v=19$m=19456,t=2,p=1$JUes9FmHuymP92iNKYbdWg$FD+QIp25Grd6OcYu1WS7wc/xEV7OuTECJsyEO5VWm7U	\N	\N	\N	user@gmail.com	9ca46e04-3f95-4480-ac1d-1ddc5d244f11	Owner	{}	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
4ExSlppCS48eETttxlbadw	\\x93c41077da56c66d3b111e8f4b429a96524ce081a7757365725f6964d92434373033653531312d333062622d346435662d613665312d33396365313938363739663199cd07ea09103032ce1b1ec36e000000	2026-01-09 16:48:50.455+00
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

\unrestrict 14chabhhlkDQezGfasqrtsljTJvc1d2w9VLc7tWzUcQ8M56TCQe15Tblvq9WlG6

