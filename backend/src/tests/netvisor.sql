--
-- PostgreSQL database dump
--

\restrict EGAsXQYdIwtws80WOwN1HSoOcmWLgkfkvgs4a2DIedvxTKblPAfbFmMRoL7hB5G

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
20251006215000	users	2025-12-13 21:56:16.844283+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4723908
20251006215100	networks	2025-12-13 21:56:16.850432+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4646264
20251006215151	create hosts	2025-12-13 21:56:16.855436+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3923988
20251006215155	create subnets	2025-12-13 21:56:16.859705+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3805948
20251006215201	create groups	2025-12-13 21:56:16.86386+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4111197
20251006215204	create daemons	2025-12-13 21:56:16.868333+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4181428
20251006215212	create services	2025-12-13 21:56:16.872858+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4814087
20251029193448	user-auth	2025-12-13 21:56:16.877984+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5629725
20251030044828	daemon api	2025-12-13 21:56:16.883923+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1558092
20251030170438	host-hide	2025-12-13 21:56:16.885774+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1134613
20251102224919	create discovery	2025-12-13 21:56:16.887326+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10925989
20251106235621	normalize-daemon-cols	2025-12-13 21:56:16.898586+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1793440
20251107034459	api keys	2025-12-13 21:56:16.90068+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8246288
20251107222650	oidc-auth	2025-12-13 21:56:16.909256+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26075135
20251110181948	orgs-billing	2025-12-13 21:56:16.935666+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10816836
20251113223656	group-enhancements	2025-12-13 21:56:16.946804+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1062709
20251117032720	daemon-mode	2025-12-13 21:56:16.948174+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1117181
20251118143058	set-default-plan	2025-12-13 21:56:16.949584+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1178896
20251118225043	save-topology	2025-12-13 21:56:16.951123+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8953857
20251123232748	network-permissions	2025-12-13 21:56:16.960458+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2726428
20251125001342	billing-updates	2025-12-13 21:56:16.963527+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1005593
20251128035448	org-onboarding-status	2025-12-13 21:56:16.964822+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1418632
20251129180942	nfs-consolidate	2025-12-13 21:56:16.966533+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1249858
20251206052641	discovery-progress	2025-12-13 21:56:16.968068+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1821071
20251206202200	plan-fix	2025-12-13 21:56:16.970203+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	905627
20251207061341	daemon-url	2025-12-13 21:56:16.971413+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2295887
20251210045929	tags	2025-12-13 21:56:16.973998+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8768441
20251210175035	terms	2025-12-13 21:56:16.983098+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	898012
20251213025048	hash-keys	2025-12-13 21:56:16.98429+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	11404491
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
c6c7b75f-edd9-4ec7-84c4-a25e5704af03	3e381bc1242fdeda42d471f259cf13053ee6651063653cc977214ec051e9b503	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	Integrated Daemon API Key	2025-12-13 21:56:19.828469+00	2025-12-13 21:57:56.55471+00	2025-12-13 21:57:56.553783+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
0b94b8d9-4ef8-413b-b62b-78e0c2c70b05	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b	2025-12-13 21:56:19.88649+00	2025-12-13 21:57:36.563577+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["6e4f6f2a-6447-46f4-8caf-71fef62e60e4"]}	2025-12-13 21:57:36.564408+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
c11856be-4998-4466-9e6e-109c552e1edf	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	0b94b8d9-4ef8-413b-b62b-78e0c2c70b05	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b"}	Self Report	2025-12-13 21:56:19.957973+00	2025-12-13 21:56:19.957973+00	{}
87b479ba-d9c4-4cf5-81ac-e4e8e417c57c	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	0b94b8d9-4ef8-413b-b62b-78e0c2c70b05	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 21:56:19.964238+00	2025-12-13 21:56:19.964238+00	{}
7bdcc917-d2a7-4ffa-bac8-bd9eba226283	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	0b94b8d9-4ef8-413b-b62b-78e0c2c70b05	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "session_id": "154e7d7b-f3bc-44e6-81eb-d74d386a49e0", "started_at": "2025-12-13T21:56:19.963844731Z", "finished_at": "2025-12-13T21:56:20.036032686Z", "discovery_type": {"type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b"}}}	{"type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b"}	Self Report	2025-12-13 21:56:19.963844+00	2025-12-13 21:56:20.039863+00	{}
9ae734da-822e-45f4-8b0d-0aa65bf2188c	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	0b94b8d9-4ef8-413b-b62b-78e0c2c70b05	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "session_id": "947107f5-89fa-4a59-93da-0fbfb754d1e3", "started_at": "2025-12-13T21:56:20.055616984Z", "finished_at": "2025-12-13T21:57:56.551028874Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-13 21:56:20.055616+00	2025-12-13 21:57:56.554042+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
e0572c52-efc4-497c-a15c-d056dd27254b	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-13 21:57:56.565954+00	2025-12-13 21:57:56.565954+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
e50de2dc-a389-4245-9400-6d67807d41fb	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "f9603247-ac9f-4f67-b24f-777e1c83adff"}	[{"id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4", "name": "Internet", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "ip_address": "1.1.1.1", "mac_address": null}]	{b8a1e04e-9bde-4006-a1e8-6317929a5eaf}	[{"id": "e1c7124a-17d1-4822-8627-7521e3124e0c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-13 21:56:19.801677+00	2025-12-13 21:56:19.811752+00	f	{}
fe622eab-053b-4dab-8265-7b506a1229d3	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	Google.com	\N	\N	{"type": "ServiceBinding", "config": "2a761111-cf0e-4cfd-b37c-bda542428c2d"}	[{"id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02", "name": "Internet", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "ip_address": "203.0.113.138", "mac_address": null}]	{e58d7315-2d8b-406f-81ad-838dfa2f3bcd}	[{"id": "b9da3c36-48e8-4161-913b-05c9c744c07c", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 21:56:19.801685+00	2025-12-13 21:56:19.81704+00	f	{}
6b121836-710a-4c2b-9ec4-cb81d5aa7e21	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "f3106df6-645b-4c8c-9509-65f5480047ec"}	[{"id": "b8406692-46dc-4de3-b095-a6007243bfb4", "name": "Remote Network", "subnet_id": "2dabfa8f-b217-490e-acf7-c9488d88f99d", "ip_address": "203.0.113.189", "mac_address": null}]	{3ee8475f-499b-4948-9079-10b5cc7b6271}	[{"id": "654032d7-bc92-46c0-9885-1aa956c120ff", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-13 21:56:19.801691+00	2025-12-13 21:56:19.821186+00	f	{}
d9c0a2a8-0fe0-4599-a17b-a2bccb606a37	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "af0c5f31-34d6-4e07-9876-6889e03f5ea5", "name": null, "subnet_id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "ip_address": "172.25.0.6", "mac_address": "1A:75:0F:45:E7:36"}]	{1f3b5650-ce23-457d-8b42-e95530ff1b48}	[{"id": "29889a4f-2050-4bd4-aa31-4e22980113a2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:57:07.518798499Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 21:57:07.5188+00	2025-12-13 21:57:21.868772+00	f	{}
7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	netvisor-daemon	a716643e90f6	NetVisor daemon	{"type": "None"}	[{"id": "16cd4f35-e498-4296-818d-9ae75b8194e6", "name": "eth0", "subnet_id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "ip_address": "172.25.0.4", "mac_address": "56:56:10:E0:52:A3"}]	{4dbd48d4-9b79-451b-bc2d-2f3a5bd8bfb6}	[{"id": "ca16858f-93c0-4929-becc-3b8b947912f4", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:56:20.017808246Z", "type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05"}]}	null	2025-12-13 21:56:19.880763+00	2025-12-13 21:56:20.033152+00	f	{}
6a1e0710-5c68-4bcd-9c27-ae93d85a8613	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ae3b9971-d448-43b3-ab31-2d949ba55906", "name": null, "subnet_id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "ip_address": "172.25.0.3", "mac_address": "82:EB:E1:30:60:E7"}]	{e25fd861-3936-4f97-b92c-6a8ce11d05d5}	[{"id": "8440fc5c-147c-4745-b507-783f7acfc683", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:56:52.938012465Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 21:56:52.938014+00	2025-12-13 21:57:07.434366+00	f	{}
cd51f942-523c-4ad1-8e9b-63beaae2157d	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "a21a8d2c-ed06-4b77-804a-31b0ec667071", "name": null, "subnet_id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "ip_address": "172.25.0.5", "mac_address": "E2:C1:D1:56:04:66"}]	{76c21f3b-5747-4190-bbf2-833fdf1628db}	[{"id": "e0bb7ce8-35fc-4ed2-9541-1e03ce0164d3", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c220d3ac-b946-4477-8592-032730456639", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:57:21.866162546Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 21:57:21.866165+00	2025-12-13 21:57:36.224206+00	f	{}
77470e4c-83f2-4612-8c4d-c3881e17effd	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "796564eb-dafc-4aed-9ed6-e8884dd9e8c8", "name": null, "subnet_id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "ip_address": "172.25.0.1", "mac_address": "16:E5:F4:B1:C9:6E"}]	{8767f4e9-bd65-4fd9-95b1-b661242e358c,2f296f07-6fe7-4dcc-a553-a10253db669c,c35e74f1-4362-4ad0-9951-84f4b524b2e3,0c262061-352b-4732-877a-40cb0fee7dbd}	[{"id": "5d572643-d1f5-4b6c-9ef1-6284d8c968b2", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "4d09098f-09cd-41f8-8131-0b8750cbc270", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ab348230-10d1-42e5-acce-816c96996d43", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "4bf7c4ee-a018-45b4-8fa9-7b8e57372954", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:57:42.272774674Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-13 21:57:42.272777+00	2025-12-13 21:57:56.545569+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	My Network	2025-12-13 21:56:19.800416+00	2025-12-13 21:56:19.800416+00	f	99d3e25e-732e-4bd7-90e6-f1ba294f9dca	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
99d3e25e-732e-4bd7-90e6-f1ba294f9dca	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-13 21:56:19.779691+00	2025-12-13 21:56:19.956918+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
b8a1e04e-9bde-4006-a1e8-6317929a5eaf	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.80168+00	2025-12-13 21:56:19.80168+00	Cloudflare DNS	e50de2dc-a389-4245-9400-6d67807d41fb	[{"id": "f9603247-ac9f-4f67-b24f-777e1c83adff", "type": "Port", "port_id": "e1c7124a-17d1-4822-8627-7521e3124e0c", "interface_id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4"}]	"Dns Server"	null	{"type": "System"}	{}
e58d7315-2d8b-406f-81ad-838dfa2f3bcd	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.801687+00	2025-12-13 21:56:19.801687+00	Google.com	fe622eab-053b-4dab-8265-7b506a1229d3	[{"id": "2a761111-cf0e-4cfd-b37c-bda542428c2d", "type": "Port", "port_id": "b9da3c36-48e8-4161-913b-05c9c744c07c", "interface_id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02"}]	"Web Service"	null	{"type": "System"}	{}
3ee8475f-499b-4948-9079-10b5cc7b6271	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.801692+00	2025-12-13 21:56:19.801692+00	Mobile Device	6b121836-710a-4c2b-9ec4-cb81d5aa7e21	[{"id": "f3106df6-645b-4c8c-9509-65f5480047ec", "type": "Port", "port_id": "654032d7-bc92-46c0-9885-1aa956c120ff", "interface_id": "b8406692-46dc-4de3-b095-a6007243bfb4"}]	"Client"	null	{"type": "System"}	{}
4dbd48d4-9b79-451b-bc2d-2f3a5bd8bfb6	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:20.017826+00	2025-12-13 21:56:20.017826+00	NetVisor Daemon API	7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b	[{"id": "0ebfaeb2-2263-4feb-99f5-e13409253814", "type": "Port", "port_id": "ca16858f-93c0-4929-becc-3b8b947912f4", "interface_id": "16cd4f35-e498-4296-818d-9ae75b8194e6"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-13T21:56:20.017825168Z", "type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05"}]}	{}
e25fd861-3936-4f97-b92c-6a8ce11d05d5	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:52.938443+00	2025-12-13 21:56:52.938443+00	NetVisor Server API	6a1e0710-5c68-4bcd-9c27-ae93d85a8613	[{"id": "3d5e5c6c-3291-4560-93ff-145966d97578", "type": "Port", "port_id": "8440fc5c-147c-4745-b507-783f7acfc683", "interface_id": "ae3b9971-d448-43b3-ab31-2d949ba55906"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T21:56:52.938429422Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1f3b5650-ce23-457d-8b42-e95530ff1b48	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:21.857779+00	2025-12-13 21:57:21.857779+00	PostgreSQL	d9c0a2a8-0fe0-4599-a17b-a2bccb606a37	[{"id": "2a2af4ef-c6d4-4b16-98b3-de572083c8fd", "type": "Port", "port_id": "29889a4f-2050-4bd4-aa31-4e22980113a2", "interface_id": "af0c5f31-34d6-4e07-9876-6889e03f5ea5"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T21:57:21.857764805Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
76c21f3b-5747-4190-bbf2-833fdf1628db	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:36.213895+00	2025-12-13 21:57:36.213895+00	Unclaimed Open Ports	cd51f942-523c-4ad1-8e9b-63beaae2157d	[{"id": "f7b14d0e-28a8-44ca-973f-c892f3bc6231", "type": "Port", "port_id": "e0bb7ce8-35fc-4ed2-9541-1e03ce0164d3", "interface_id": "a21a8d2c-ed06-4b77-804a-31b0ec667071"}, {"id": "86c4f1fe-bd71-4578-b564-38f1a61ee5c7", "type": "Port", "port_id": "c220d3ac-b946-4477-8592-032730456639", "interface_id": "a21a8d2c-ed06-4b77-804a-31b0ec667071"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T21:57:36.213875075Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0c262061-352b-4732-877a-40cb0fee7dbd	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:56.530659+00	2025-12-13 21:57:56.530659+00	Unclaimed Open Ports	77470e4c-83f2-4612-8c4d-c3881e17effd	[{"id": "83cb5c4b-f5aa-45a5-ae58-2c7203dbb3ab", "type": "Port", "port_id": "4bf7c4ee-a018-45b4-8fa9-7b8e57372954", "interface_id": "796564eb-dafc-4aed-9ed6-e8884dd9e8c8"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T21:57:56.530648083Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
8767f4e9-bd65-4fd9-95b1-b661242e358c	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:42.274388+00	2025-12-13 21:57:42.274388+00	NetVisor Server API	77470e4c-83f2-4612-8c4d-c3881e17effd	[{"id": "5a756ad2-194b-4f0d-9e23-4a389a1af782", "type": "Port", "port_id": "5d572643-d1f5-4b6c-9ef1-6284d8c968b2", "interface_id": "796564eb-dafc-4aed-9ed6-e8884dd9e8c8"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T21:57:42.274377449Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2f296f07-6fe7-4dcc-a553-a10253db669c	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:53.680107+00	2025-12-13 21:57:53.680107+00	Home Assistant	77470e4c-83f2-4612-8c4d-c3881e17effd	[{"id": "1c4c4812-96f0-40fa-9a3f-fd6a7761660e", "type": "Port", "port_id": "4d09098f-09cd-41f8-8131-0b8750cbc270", "interface_id": "796564eb-dafc-4aed-9ed6-e8884dd9e8c8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-13T21:57:53.680068299Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c35e74f1-4362-4ad0-9951-84f4b524b2e3	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:57:56.530185+00	2025-12-13 21:57:56.530185+00	SSH	77470e4c-83f2-4612-8c4d-c3881e17effd	[{"id": "4451abd9-161c-4775-b7f4-c9126e312ec7", "type": "Port", "port_id": "ab348230-10d1-42e5-acce-816c96996d43", "interface_id": "796564eb-dafc-4aed-9ed6-e8884dd9e8c8"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-13T21:57:56.530167588Z", "type": "Network", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
8a651142-1438-4420-9573-5aed663d21a5	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.801618+00	2025-12-13 21:56:19.801618+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
2dabfa8f-b217-490e-acf7-c9488d88f99d	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.801622+00	2025-12-13 21:56:19.801622+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
6e4f6f2a-6447-46f4-8caf-71fef62e60e4	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	2025-12-13 21:56:19.963998+00	2025-12-13 21:56:19.963998+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-13T21:56:19.963997195Z", "type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
88bd3178-d996-4948-ac51-69d5eae239d2	99d3e25e-732e-4bd7-90e6-f1ba294f9dca	New Tag	\N	2025-12-13 21:57:56.57288+00	2025-12-13 21:57:56.57288+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
e31075df-86a6-4e1b-b846-24368c4e220d	ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9	My Topology	[]	[{"id": "2dabfa8f-b217-490e-acf7-c9488d88f99d", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "8a651142-1438-4420-9573-5aed663d21a5", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "e50de2dc-a389-4245-9400-6d67807d41fb", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "interface_id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4"}, {"id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02", "size": {"x": 250, "y": 100}, "header": null, "host_id": "fe622eab-053b-4dab-8265-7b506a1229d3", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "interface_id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02"}, {"id": "b8406692-46dc-4de3-b095-a6007243bfb4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "6b121836-710a-4c2b-9ec4-cb81d5aa7e21", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2dabfa8f-b217-490e-acf7-c9488d88f99d", "interface_id": "b8406692-46dc-4de3-b095-a6007243bfb4"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "e50de2dc-a389-4245-9400-6d67807d41fb", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "e1c7124a-17d1-4822-8627-7521e3124e0c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "f9603247-ac9f-4f67-b24f-777e1c83adff"}, "hostname": null, "services": ["b8a1e04e-9bde-4006-a1e8-6317929a5eaf"], "created_at": "2025-12-13T21:56:19.801677Z", "interfaces": [{"id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4", "name": "Internet", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.811752Z", "description": null, "virtualization": null}, {"id": "fe622eab-053b-4dab-8265-7b506a1229d3", "name": "Google.com", "tags": [], "ports": [{"id": "b9da3c36-48e8-4161-913b-05c9c744c07c", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "2a761111-cf0e-4cfd-b37c-bda542428c2d"}, "hostname": null, "services": ["e58d7315-2d8b-406f-81ad-838dfa2f3bcd"], "created_at": "2025-12-13T21:56:19.801685Z", "interfaces": [{"id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02", "name": "Internet", "subnet_id": "8a651142-1438-4420-9573-5aed663d21a5", "ip_address": "203.0.113.138", "mac_address": null}], "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.817040Z", "description": null, "virtualization": null}, {"id": "6b121836-710a-4c2b-9ec4-cb81d5aa7e21", "name": "Mobile Device", "tags": [], "ports": [{"id": "654032d7-bc92-46c0-9885-1aa956c120ff", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "f3106df6-645b-4c8c-9509-65f5480047ec"}, "hostname": null, "services": ["3ee8475f-499b-4948-9079-10b5cc7b6271"], "created_at": "2025-12-13T21:56:19.801691Z", "interfaces": [{"id": "b8406692-46dc-4de3-b095-a6007243bfb4", "name": "Remote Network", "subnet_id": "2dabfa8f-b217-490e-acf7-c9488d88f99d", "ip_address": "203.0.113.189", "mac_address": null}], "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.821186Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "8a651142-1438-4420-9573-5aed663d21a5", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T21:56:19.801618Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.801618Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "2dabfa8f-b217-490e-acf7-c9488d88f99d", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-13T21:56:19.801622Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.801622Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "6e4f6f2a-6447-46f4-8caf-71fef62e60e4", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-13T21:56:19.963997195Z", "type": "SelfReport", "host_id": "7c6f69e3-8e98-4dda-8f7b-3aeae324ef7b", "daemon_id": "0b94b8d9-4ef8-413b-b62b-78e0c2c70b05"}]}, "created_at": "2025-12-13T21:56:19.963998Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.963998Z", "description": null, "subnet_type": "Lan"}]	[{"id": "b8a1e04e-9bde-4006-a1e8-6317929a5eaf", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "e50de2dc-a389-4245-9400-6d67807d41fb", "bindings": [{"id": "f9603247-ac9f-4f67-b24f-777e1c83adff", "type": "Port", "port_id": "e1c7124a-17d1-4822-8627-7521e3124e0c", "interface_id": "f3639ebe-6dbd-4f88-8255-a15d69abbbd4"}], "created_at": "2025-12-13T21:56:19.801680Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.801680Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "e58d7315-2d8b-406f-81ad-838dfa2f3bcd", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "fe622eab-053b-4dab-8265-7b506a1229d3", "bindings": [{"id": "2a761111-cf0e-4cfd-b37c-bda542428c2d", "type": "Port", "port_id": "b9da3c36-48e8-4161-913b-05c9c744c07c", "interface_id": "64a0c9b7-a9fe-4efa-bae2-ecdf5a2f0c02"}], "created_at": "2025-12-13T21:56:19.801687Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.801687Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "3ee8475f-499b-4948-9079-10b5cc7b6271", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "6b121836-710a-4c2b-9ec4-cb81d5aa7e21", "bindings": [{"id": "f3106df6-645b-4c8c-9509-65f5480047ec", "type": "Port", "port_id": "654032d7-bc92-46c0-9885-1aa956c120ff", "interface_id": "b8406692-46dc-4de3-b095-a6007243bfb4"}], "created_at": "2025-12-13T21:56:19.801692Z", "network_id": "ed61e6fe-34e8-4ed9-a91b-d52f952fe2d9", "updated_at": "2025-12-13T21:56:19.801692Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-13 21:56:19.825624+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-13 21:56:19.821928+00	2025-12-13 21:57:36.261577+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
10c75625-3d73-425a-8dd7-f3e86e61a3b1	2025-12-13 21:56:19.782669+00	2025-12-13 21:56:19.782669+00	$argon2id$v=19$m=19456,t=2,p=1$riFqGNzJWB+bxuWs2KAuUA$8YdIxF3wSbtVSCN6jMHcc/O7ttDacLtuCr9bIZzG/uE	\N	\N	\N	user@gmail.com	99d3e25e-732e-4bd7-90e6-f1ba294f9dca	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
AfHkxgojemICVZ47TTa2mA	\\x93c41098b6364d3b9e5502627a230ac6e4f10181a7757365725f6964d92431306337353632352d336437332d343235612d386464372d66336538366536316133623199cd07ea0c153813ce2ed652e9000000	2026-01-12 21:56:19.785797+00
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

\unrestrict EGAsXQYdIwtws80WOwN1HSoOcmWLgkfkvgs4a2DIedvxTKblPAfbFmMRoL7hB5G

