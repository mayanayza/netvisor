--
-- PostgreSQL database dump
--

\restrict YDd2eIweHlZNFxKL2gb7AV4gymp1z4MLZcxZZu89Z9qxdfZCdXLZ1WigR7ZJG1Z

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
20251006215000	users	2025-12-13 19:40:05.859702+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3504084
20251006215100	networks	2025-12-13 19:40:05.86417+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4787092
20251006215151	create hosts	2025-12-13 19:40:05.869295+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3955729
20251006215155	create subnets	2025-12-13 19:40:05.873607+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3785221
20251006215201	create groups	2025-12-13 19:40:05.877719+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3867214
20251006215204	create daemons	2025-12-13 19:40:05.881948+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4173350
20251006215212	create services	2025-12-13 19:40:05.886482+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4718980
20251029193448	user-auth	2025-12-13 19:40:05.891522+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6199108
20251030044828	daemon api	2025-12-13 19:40:05.898034+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1660854
20251030170438	host-hide	2025-12-13 19:40:05.899978+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1165561
20251102224919	create discovery	2025-12-13 19:40:05.901445+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11765607
20251106235621	normalize-daemon-cols	2025-12-13 19:40:05.913523+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1945223
20251107034459	api keys	2025-12-13 19:40:05.915762+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8808910
20251107222650	oidc-auth	2025-12-13 19:40:05.92491+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26777978
20251110181948	orgs-billing	2025-12-13 19:40:05.951994+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10635291
20251113223656	group-enhancements	2025-12-13 19:40:05.962951+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1014490
20251117032720	daemon-mode	2025-12-13 19:40:05.964283+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1092355
20251118143058	set-default-plan	2025-12-13 19:40:05.965662+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1154590
20251118225043	save-topology	2025-12-13 19:40:05.967175+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8905182
20251123232748	network-permissions	2025-12-13 19:40:05.976443+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2679191
20251125001342	billing-updates	2025-12-13 19:40:05.979427+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	982099
20251128035448	org-onboarding-status	2025-12-13 19:40:05.980818+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1456356
20251129180942	nfs-consolidate	2025-12-13 19:40:05.982571+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1295573
20251206052641	discovery-progress	2025-12-13 19:40:05.984171+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1743725
20251206202200	plan-fix	2025-12-13 19:40:05.9862+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	979037
20251207061341	daemon-url	2025-12-13 19:40:05.987477+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2435927
20251210045929	tags	2025-12-13 19:40:05.990199+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9313740
20251210175035	terms	2025-12-13 19:40:05.999861+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	865182
20251213025048	hash-keys	2025-12-13 19:40:06.001006+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	12144383
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
23f91533-1694-41b5-bd01-cd82ac029b21	1555137827baaa54d72ac7908e209db3a7c5f476949802e139145f5509a4b41e	3224e078-b192-49cd-aa7d-9b48433c9e09	Integrated Daemon API Key	2025-12-13 19:40:08.704776+00	2025-12-13 19:41:47.084475+00	2025-12-13 19:41:47.083646+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
dbd37e81-00b4-4070-95ea-28a46a457e5a	3224e078-b192-49cd-aa7d-9b48433c9e09	61213540-f050-4a1c-bb09-2cfc3b1fc17a	2025-12-13 19:40:08.749674+00	2025-12-13 19:41:24.549938+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["df7c0764-ca41-4265-b824-121231131509"]}	2025-12-13 19:41:24.553362+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
fc7b9b39-f421-4ca5-8bea-96c8841ee47a	3224e078-b192-49cd-aa7d-9b48433c9e09	dbd37e81-00b4-4070-95ea-28a46a457e5a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a"}	Self Report	2025-12-13 19:40:08.797883+00	2025-12-13 19:40:08.797883+00	{}
347cd166-ed41-4566-b262-155fb7e8c739	3224e078-b192-49cd-aa7d-9b48433c9e09	dbd37e81-00b4-4070-95ea-28a46a457e5a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 19:40:08.804673+00	2025-12-13 19:40:08.804673+00	{}
82ada869-ef18-45f9-9aa9-a0398be5ec09	3224e078-b192-49cd-aa7d-9b48433c9e09	dbd37e81-00b4-4070-95ea-28a46a457e5a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "session_id": "55d2065d-f9be-40c1-9310-3d4fff9d730e", "started_at": "2025-12-13T19:40:08.804287130Z", "finished_at": "2025-12-13T19:40:08.836349399Z", "discovery_type": {"type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a"}}}	{"type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a"}	Self Report	2025-12-13 19:40:08.804287+00	2025-12-13 19:40:08.839163+00	{}
6d07c472-742f-426b-bd41-4814ab76fec8	3224e078-b192-49cd-aa7d-9b48433c9e09	dbd37e81-00b4-4070-95ea-28a46a457e5a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "session_id": "86882148-5d69-4787-8c70-9e8d9e2c6116", "started_at": "2025-12-13T19:40:08.850770468Z", "finished_at": "2025-12-13T19:41:47.081697852Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 19:40:08.85077+00	2025-12-13 19:41:47.08392+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
46ef02bc-9c9f-4b62-8259-aad07e356d99	3224e078-b192-49cd-aa7d-9b48433c9e09		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 19:41:47.09674+00	2025-12-13 19:41:47.09674+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
bbd5d68f-69c4-4916-a517-4d8def817c69	3224e078-b192-49cd-aa7d-9b48433c9e09	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "6cb85d03-0ec4-4171-9231-896403fbfe28"}	[{"id": "fc55015c-5678-4c3d-9d75-d456db1e6097", "name": "Internet", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "ip_address": "1.1.1.1", "mac_address": null}]	{3bc91db9-7643-4f36-90c9-f17352aaa510}	[{"id": "7fcce4b5-7a00-4548-bf79-e52b90ba6b29", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 19:40:08.679288+00	2025-12-13 19:40:08.688611+00	f	{}
adbf1257-fe68-44b9-9a44-d0a36c3bca83	3224e078-b192-49cd-aa7d-9b48433c9e09	Google.com	\N	\N	{"type": "ServiceBinding", "config": "8b92f2f8-f4bd-40c5-97b7-3b59edad4ae5"}	[{"id": "69b06a80-bde1-463c-9d7e-de219887f5e9", "name": "Internet", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "ip_address": "203.0.113.143", "mac_address": null}]	{82803c3d-362e-47b9-895b-933caf380595}	[{"id": "197dfc6e-4446-4049-a99b-125a7857a2ed", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 19:40:08.679298+00	2025-12-13 19:40:08.693689+00	f	{}
23a7e7fd-afa0-45f1-87f2-f39ac5558cda	3224e078-b192-49cd-aa7d-9b48433c9e09	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "2042fe99-3b4c-41e0-8b50-24f90e5e4ad3"}	[{"id": "cad6d653-211f-4f81-9b49-32a23abdf9c5", "name": "Remote Network", "subnet_id": "29bc0a4a-a75d-4b4e-acf6-b597b5c65e67", "ip_address": "203.0.113.242", "mac_address": null}]	{498b92b8-7ad8-4f5a-8dad-900943021c00}	[{"id": "814ef32a-1a37-42cd-9b5b-b011a8862cfd", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 19:40:08.679307+00	2025-12-13 19:40:08.697534+00	f	{}
0f25d045-b8e8-4937-a4cc-d545c384fd39	3224e078-b192-49cd-aa7d-9b48433c9e09	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "4e7f96a5-d2c7-4aea-9aa8-277f5ee472ab", "name": null, "subnet_id": "df7c0764-ca41-4265-b824-121231131509", "ip_address": "172.25.0.5", "mac_address": "16:65:B8:8B:EE:DF"}]	{3b5d5477-20b5-45d1-8aea-c4416373fae9,325b5e9c-6422-42f5-a8a3-9c82befcf462}	[{"id": "3608688c-3d10-4961-ad08-b8b68d9916b6", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9c34a573-351d-4310-83c7-86ccc1e17878", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:40:55.639258714Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 19:40:55.639261+00	2025-12-13 19:41:24.560745+00	f	{}
61213540-f050-4a1c-bb09-2cfc3b1fc17a	3224e078-b192-49cd-aa7d-9b48433c9e09	netvisor-daemon	b8684f899787	NetVisor daemon	{"type": "None"}	[{"id": "9147a6b7-ebcc-45c1-afd1-fdd4d168d888", "name": "eth0", "subnet_id": "df7c0764-ca41-4265-b824-121231131509", "ip_address": "172.25.0.4", "mac_address": "F2:FE:48:DF:B7:AB"}]	{47d1476b-8ffd-4f80-b5a2-26950e864dd7}	[{"id": "39e5061d-86c8-4e1c-b0e5-95eaac95e334", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:40:08.824114317Z", "type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a"}]}	null	2025-12-13 19:40:08.712802+00	2025-12-13 19:40:08.834411+00	f	{}
ffe85168-975c-49e3-be68-79dda4a0ce2d	3224e078-b192-49cd-aa7d-9b48433c9e09	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c9b8b7b2-beb0-4dd5-9279-140a847f9102", "name": null, "subnet_id": "df7c0764-ca41-4265-b824-121231131509", "ip_address": "172.25.0.6", "mac_address": "7A:5D:51:5A:7D:43"}]	{32e20f71-1de5-4291-a631-4533fa7bb33e}	[{"id": "ecb9a857-b151-4c19-b935-f0fc88c0877e", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:40:40.993949832Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 19:40:40.993953+00	2025-12-13 19:40:55.559234+00	f	{}
a66c4f22-b820-4c17-b085-40c4b0a03d09	3224e078-b192-49cd-aa7d-9b48433c9e09	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e3d10ae0-734e-4b82-ac1f-7416f36834c6", "name": null, "subnet_id": "df7c0764-ca41-4265-b824-121231131509", "ip_address": "172.25.0.3", "mac_address": "2E:61:83:D8:9D:69"}]	{532bca44-4050-4a99-89bf-c86c0fd3da34}	[{"id": "657f02a2-635b-4d6e-8c0a-704271ae9c4e", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:41:10.128143198Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 19:41:10.128144+00	2025-12-13 19:41:24.562245+00	f	{}
055fba99-c523-4940-8c4d-e2ce657d8f46	3224e078-b192-49cd-aa7d-9b48433c9e09	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "be2f34f5-a353-4325-a355-9982b7aa1ad3", "name": null, "subnet_id": "df7c0764-ca41-4265-b824-121231131509", "ip_address": "172.25.0.1", "mac_address": "C2:5D:3A:29:F4:5D"}]	{716511c2-4bd7-4dd5-8bf1-fff39b74cccd,57f7049a-92e2-4ac4-84d0-17f7db03b4f8,6af2b66e-a66d-4c17-b1db-1c44ffb4947b,f6d9888e-9b81-4c2d-8a47-dd834a9996c4}	[{"id": "dce13960-e747-4b68-9f56-28f4b8c8e770", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "10b4f43d-9f13-4ed9-8999-f148c6bcd0d1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "be4ec6a0-8d37-4918-bf58-cc43dfcb52bb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "fa8f347d-af8d-49ce-a944-6264a8c5316e", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:41:32.604477390Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 19:41:32.60448+00	2025-12-13 19:41:47.075396+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
3224e078-b192-49cd-aa7d-9b48433c9e09	My Network	2025-12-13 19:40:08.67805+00	2025-12-13 19:40:08.67805+00	f	00dffb99-4816-4e90-809a-69fd32de17bb	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
00dffb99-4816-4e90-809a-69fd32de17bb	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 19:40:08.656406+00	2025-12-13 19:40:08.796295+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
3bc91db9-7643-4f36-90c9-f17352aaa510	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.679291+00	2025-12-13 19:40:08.679291+00	Cloudflare DNS	bbd5d68f-69c4-4916-a517-4d8def817c69	[{"id": "6cb85d03-0ec4-4171-9231-896403fbfe28", "type": "Port", "port_id": "7fcce4b5-7a00-4548-bf79-e52b90ba6b29", "interface_id": "fc55015c-5678-4c3d-9d75-d456db1e6097"}]	"Dns Server"	null	{"type": "System"}	{}
82803c3d-362e-47b9-895b-933caf380595	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.679301+00	2025-12-13 19:40:08.679301+00	Google.com	adbf1257-fe68-44b9-9a44-d0a36c3bca83	[{"id": "8b92f2f8-f4bd-40c5-97b7-3b59edad4ae5", "type": "Port", "port_id": "197dfc6e-4446-4049-a99b-125a7857a2ed", "interface_id": "69b06a80-bde1-463c-9d7e-de219887f5e9"}]	"Web Service"	null	{"type": "System"}	{}
498b92b8-7ad8-4f5a-8dad-900943021c00	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.679308+00	2025-12-13 19:40:08.679308+00	Mobile Device	23a7e7fd-afa0-45f1-87f2-f39ac5558cda	[{"id": "2042fe99-3b4c-41e0-8b50-24f90e5e4ad3", "type": "Port", "port_id": "814ef32a-1a37-42cd-9b5b-b011a8862cfd", "interface_id": "cad6d653-211f-4f81-9b49-32a23abdf9c5"}]	"Client"	null	{"type": "System"}	{}
47d1476b-8ffd-4f80-b5a2-26950e864dd7	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.824132+00	2025-12-13 19:40:08.824132+00	NetVisor Daemon API	61213540-f050-4a1c-bb09-2cfc3b1fc17a	[{"id": "0d3a07d4-40ba-438c-8f3c-0c71b3a48e4b", "type": "Port", "port_id": "39e5061d-86c8-4e1c-b0e5-95eaac95e334", "interface_id": "9147a6b7-ebcc-45c1-afd1-fdd4d168d888"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T19:40:08.824131398Z", "type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a"}]}	{}
32e20f71-1de5-4291-a631-4533fa7bb33e	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:55.541153+00	2025-12-13 19:40:55.541153+00	PostgreSQL	ffe85168-975c-49e3-be68-79dda4a0ce2d	[{"id": "aabfbb5f-9ddb-4d70-82df-ddd46bed95b9", "type": "Port", "port_id": "ecb9a857-b151-4c19-b935-f0fc88c0877e", "interface_id": "c9b8b7b2-beb0-4dd5-9279-140a847f9102"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T19:40:55.541134995Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3b5d5477-20b5-45d1-8aea-c4416373fae9	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:07.24387+00	2025-12-13 19:41:07.24387+00	Home Assistant	0f25d045-b8e8-4937-a4cc-d545c384fd39	[{"id": "8b5d4b58-d880-4c7c-ac0f-d374e264aef8", "type": "Port", "port_id": "3608688c-3d10-4961-ad08-b8b68d9916b6", "interface_id": "4e7f96a5-d2c7-4aea-9aa8-277f5ee472ab"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T19:41:07.243854542Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
325b5e9c-6422-42f5-a8a3-9c82befcf462	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:10.127521+00	2025-12-13 19:41:10.127521+00	Unclaimed Open Ports	0f25d045-b8e8-4937-a4cc-d545c384fd39	[{"id": "09390758-339b-44f0-88ba-6dccc91664af", "type": "Port", "port_id": "9c34a573-351d-4310-83c7-86ccc1e17878", "interface_id": "4e7f96a5-d2c7-4aea-9aa8-277f5ee472ab"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T19:41:10.127505109Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
532bca44-4050-4a99-89bf-c86c0fd3da34	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:10.128463+00	2025-12-13 19:41:10.128463+00	NetVisor Server API	a66c4f22-b820-4c17-b085-40c4b0a03d09	[{"id": "8b722d06-f5df-4231-98fd-d17d50a86479", "type": "Port", "port_id": "657f02a2-635b-4d6e-8c0a-704271ae9c4e", "interface_id": "e3d10ae0-734e-4b82-ac1f-7416f36834c6"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T19:41:10.128456942Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
716511c2-4bd7-4dd5-8bf1-fff39b74cccd	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:32.606154+00	2025-12-13 19:41:32.606154+00	NetVisor Server API	055fba99-c523-4940-8c4d-e2ce657d8f46	[{"id": "699d2f84-fbf0-4e66-90e6-f80a95fede70", "type": "Port", "port_id": "dce13960-e747-4b68-9f56-28f4b8c8e770", "interface_id": "be2f34f5-a353-4325-a355-9982b7aa1ad3"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T19:41:32.606139717Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f6d9888e-9b81-4c2d-8a47-dd834a9996c4	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:47.061939+00	2025-12-13 19:41:47.061939+00	Unclaimed Open Ports	055fba99-c523-4940-8c4d-e2ce657d8f46	[{"id": "1bb6402c-aa94-450f-9181-1cea1d08ab49", "type": "Port", "port_id": "fa8f347d-af8d-49ce-a944-6264a8c5316e", "interface_id": "be2f34f5-a353-4325-a355-9982b7aa1ad3"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T19:41:47.061930613Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6af2b66e-a66d-4c17-b1db-1c44ffb4947b	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:47.061447+00	2025-12-13 19:41:47.061447+00	SSH	055fba99-c523-4940-8c4d-e2ce657d8f46	[{"id": "b702230b-d741-485b-ad0a-0cb4d4ebcae2", "type": "Port", "port_id": "be4ec6a0-8d37-4918-bf58-cc43dfcb52bb", "interface_id": "be2f34f5-a353-4325-a355-9982b7aa1ad3"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T19:41:47.061429038Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
57f7049a-92e2-4ac4-84d0-17f7db03b4f8	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:41:44.183649+00	2025-12-13 19:41:44.183649+00	Home Assistant	055fba99-c523-4940-8c4d-e2ce657d8f46	[{"id": "ed7e8902-521a-4c88-9563-b0949d220e69", "type": "Port", "port_id": "10b4f43d-9f13-4ed9-8999-f148c6bcd0d1", "interface_id": "be2f34f5-a353-4325-a355-9982b7aa1ad3"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T19:41:44.183631926Z", "type": "Network", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
e966307c-9e9a-4124-9736-d57f2b80e496	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.679233+00	2025-12-13 19:40:08.679233+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
29bc0a4a-a75d-4b4e-acf6-b597b5c65e67	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.679236+00	2025-12-13 19:40:08.679236+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
df7c0764-ca41-4265-b824-121231131509	3224e078-b192-49cd-aa7d-9b48433c9e09	2025-12-13 19:40:08.804424+00	2025-12-13 19:40:08.804424+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T19:40:08.804423124Z", "type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
454e26fe-b3b2-4bda-b6d4-086703b1f91b	00dffb99-4816-4e90-809a-69fd32de17bb	New Tag	\N	2025-12-13 19:41:47.103184+00	2025-12-13 19:41:47.103184+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
cb446500-64dc-481f-92c5-78c5bbb2e7c0	3224e078-b192-49cd-aa7d-9b48433c9e09	My Topology	[]	[{"id": "e966307c-9e9a-4124-9736-d57f2b80e496", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "29bc0a4a-a75d-4b4e-acf6-b597b5c65e67", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "fc55015c-5678-4c3d-9d75-d456db1e6097", "size": {"x": 250, "y": 100}, "header": null, "host_id": "bbd5d68f-69c4-4916-a517-4d8def817c69", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "interface_id": "fc55015c-5678-4c3d-9d75-d456db1e6097"}, {"id": "69b06a80-bde1-463c-9d7e-de219887f5e9", "size": {"x": 250, "y": 100}, "header": null, "host_id": "adbf1257-fe68-44b9-9a44-d0a36c3bca83", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "interface_id": "69b06a80-bde1-463c-9d7e-de219887f5e9"}, {"id": "cad6d653-211f-4f81-9b49-32a23abdf9c5", "size": {"x": 250, "y": 100}, "header": null, "host_id": "23a7e7fd-afa0-45f1-87f2-f39ac5558cda", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "29bc0a4a-a75d-4b4e-acf6-b597b5c65e67", "interface_id": "cad6d653-211f-4f81-9b49-32a23abdf9c5"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "bbd5d68f-69c4-4916-a517-4d8def817c69", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "7fcce4b5-7a00-4548-bf79-e52b90ba6b29", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "6cb85d03-0ec4-4171-9231-896403fbfe28"}, "hostname": null, "services": ["3bc91db9-7643-4f36-90c9-f17352aaa510"], "created_at": "2025-12-13T19:40:08.679288Z", "interfaces": [{"id": "fc55015c-5678-4c3d-9d75-d456db1e6097", "name": "Internet", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.688611Z", "description": null, "virtualization": null}, {"id": "adbf1257-fe68-44b9-9a44-d0a36c3bca83", "name": "Google.com", "tags": [], "ports": [{"id": "197dfc6e-4446-4049-a99b-125a7857a2ed", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8b92f2f8-f4bd-40c5-97b7-3b59edad4ae5"}, "hostname": null, "services": ["82803c3d-362e-47b9-895b-933caf380595"], "created_at": "2025-12-13T19:40:08.679298Z", "interfaces": [{"id": "69b06a80-bde1-463c-9d7e-de219887f5e9", "name": "Internet", "subnet_id": "e966307c-9e9a-4124-9736-d57f2b80e496", "ip_address": "203.0.113.143", "mac_address": null}], "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.693689Z", "description": null, "virtualization": null}, {"id": "23a7e7fd-afa0-45f1-87f2-f39ac5558cda", "name": "Mobile Device", "tags": [], "ports": [{"id": "814ef32a-1a37-42cd-9b5b-b011a8862cfd", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "2042fe99-3b4c-41e0-8b50-24f90e5e4ad3"}, "hostname": null, "services": ["498b92b8-7ad8-4f5a-8dad-900943021c00"], "created_at": "2025-12-13T19:40:08.679307Z", "interfaces": [{"id": "cad6d653-211f-4f81-9b49-32a23abdf9c5", "name": "Remote Network", "subnet_id": "29bc0a4a-a75d-4b4e-acf6-b597b5c65e67", "ip_address": "203.0.113.242", "mac_address": null}], "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.697534Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "e966307c-9e9a-4124-9736-d57f2b80e496", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T19:40:08.679233Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.679233Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "29bc0a4a-a75d-4b4e-acf6-b597b5c65e67", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T19:40:08.679236Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.679236Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "df7c0764-ca41-4265-b824-121231131509", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T19:40:08.804423124Z", "type": "SelfReport", "host_id": "61213540-f050-4a1c-bb09-2cfc3b1fc17a", "daemon_id": "dbd37e81-00b4-4070-95ea-28a46a457e5a"}]}, "created_at": "2025-12-13T19:40:08.804424Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.804424Z", "description": null, "subnet_type": "Lan"}]	[{"id": "3bc91db9-7643-4f36-90c9-f17352aaa510", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "bbd5d68f-69c4-4916-a517-4d8def817c69", "bindings": [{"id": "6cb85d03-0ec4-4171-9231-896403fbfe28", "type": "Port", "port_id": "7fcce4b5-7a00-4548-bf79-e52b90ba6b29", "interface_id": "fc55015c-5678-4c3d-9d75-d456db1e6097"}], "created_at": "2025-12-13T19:40:08.679291Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.679291Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "82803c3d-362e-47b9-895b-933caf380595", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "adbf1257-fe68-44b9-9a44-d0a36c3bca83", "bindings": [{"id": "8b92f2f8-f4bd-40c5-97b7-3b59edad4ae5", "type": "Port", "port_id": "197dfc6e-4446-4049-a99b-125a7857a2ed", "interface_id": "69b06a80-bde1-463c-9d7e-de219887f5e9"}], "created_at": "2025-12-13T19:40:08.679301Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.679301Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "498b92b8-7ad8-4f5a-8dad-900943021c00", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "23a7e7fd-afa0-45f1-87f2-f39ac5558cda", "bindings": [{"id": "2042fe99-3b4c-41e0-8b50-24f90e5e4ad3", "type": "Port", "port_id": "814ef32a-1a37-42cd-9b5b-b011a8862cfd", "interface_id": "cad6d653-211f-4f81-9b49-32a23abdf9c5"}], "created_at": "2025-12-13T19:40:08.679308Z", "network_id": "3224e078-b192-49cd-aa7d-9b48433c9e09", "updated_at": "2025-12-13T19:40:08.679308Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 19:40:08.701953+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 19:40:08.698233+00	2025-12-13 19:41:24.681184+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
d34cd00a-8495-4bbe-b85e-657ade9d1ba3	2025-12-13 19:40:08.659506+00	2025-12-13 19:40:08.659506+00	$argon2id$v=19$m=19456,t=2,p=1$6YOpGrMaCXXdVubJ1kX1fw$btvmFtkg4FERZSrFwnhAijaUqfFiHVKZrNXhTGvaVvA	\N	\N	\N	user@gmail.com	00dffb99-4816-4e90-809a-69fd32de17bb	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
vKkK3SGW68yf96OtRMhYjg	\\x93c4108e58c844ada3f79fcceb9621dd0aa9bc81a7757365725f6964d92464333463643030612d383439352d346262652d623835652d36353761646539643162613399cd07ea0c132808ce27824045000000	2026-01-12 19:40:08.662847+00
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

\unrestrict YDd2eIweHlZNFxKL2gb7AV4gymp1z4MLZcxZZu89Z9qxdfZCdXLZ1WigR7ZJG1Z

