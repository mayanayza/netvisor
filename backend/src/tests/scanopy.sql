--
-- PostgreSQL database dump
--

\restrict BWX7hQOktUBUu2qzmzNpXjdMCSfnA1JLWhTG3tAMxFKjv7m69HujGO0yyoHDfvw

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
20251006215000	users	2025-12-15 05:47:51.937761+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3427172
20251006215100	networks	2025-12-15 05:47:51.942216+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4590092
20251006215151	create hosts	2025-12-15 05:47:51.947162+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3813793
20251006215155	create subnets	2025-12-15 05:47:51.951392+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3738502
20251006215201	create groups	2025-12-15 05:47:51.955552+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3925783
20251006215204	create daemons	2025-12-15 05:47:51.959834+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4167123
20251006215212	create services	2025-12-15 05:47:51.964363+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4754067
20251029193448	user-auth	2025-12-15 05:47:51.9695+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	13164614
20251030044828	daemon api	2025-12-15 05:47:51.982954+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1551453
20251030170438	host-hide	2025-12-15 05:47:51.98481+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1094632
20251102224919	create discovery	2025-12-15 05:47:51.986246+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10659060
20251106235621	normalize-daemon-cols	2025-12-15 05:47:51.997206+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1808493
20251107034459	api keys	2025-12-15 05:47:51.99933+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8197409
20251107222650	oidc-auth	2025-12-15 05:47:52.007836+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28119035
20251110181948	orgs-billing	2025-12-15 05:47:52.036278+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10691722
20251113223656	group-enhancements	2025-12-15 05:47:52.047294+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1023580
20251117032720	daemon-mode	2025-12-15 05:47:52.048638+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1086837
20251118143058	set-default-plan	2025-12-15 05:47:52.050094+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1170273
20251118225043	save-topology	2025-12-15 05:47:52.051556+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8699696
20251123232748	network-permissions	2025-12-15 05:47:52.060604+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2827523
20251125001342	billing-updates	2025-12-15 05:47:52.063789+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1010495
20251128035448	org-onboarding-status	2025-12-15 05:47:52.065107+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1639107
20251129180942	nfs-consolidate	2025-12-15 05:47:52.067094+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1376437
20251206052641	discovery-progress	2025-12-15 05:47:52.068823+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1777005
20251206202200	plan-fix	2025-12-15 05:47:52.070928+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1082759
20251207061341	daemon-url	2025-12-15 05:47:52.072354+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2548863
20251210045929	tags	2025-12-15 05:47:52.07524+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9671879
20251210175035	terms	2025-12-15 05:47:52.085343+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	957827
20251213025048	hash-keys	2025-12-15 05:47:52.086616+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9823943
20251214050638	scanopy	2025-12-15 05:47:52.096833+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1381447
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
3a017e7b-05c4-45a5-b335-6ed6f905a40b	2e108e1d950a6ee67410576f7fe06ffc3d1451228d0005bededb5c900b68d203	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	Integrated Daemon API Key	2025-12-15 05:47:55.062621+00	2025-12-15 05:49:30.133515+00	2025-12-15 05:49:30.132706+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
6dd03575-78b8-413b-8f5e-6fc7cdae06ed	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	452c15ad-2e93-4fbe-957d-2baa75362308	2025-12-15 05:47:55.152302+00	2025-12-15 05:49:11.127841+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["df2e89e7-da87-4a26-9923-ef0bed90f2e1"]}	2025-12-15 05:49:11.128294+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
3ae754bf-b942-4670-b000-be781e88cdd0	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	6dd03575-78b8-413b-8f5e-6fc7cdae06ed	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308"}	Self Report	2025-12-15 05:47:55.160593+00	2025-12-15 05:47:55.160593+00	{}
cb6aa680-d649-4d6a-ba7f-874583784dd0	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	6dd03575-78b8-413b-8f5e-6fc7cdae06ed	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 05:47:55.168959+00	2025-12-15 05:47:55.168959+00	{}
237fbe67-3a39-498d-b446-7ce9c16c262a	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	6dd03575-78b8-413b-8f5e-6fc7cdae06ed	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "session_id": "b8dedb6a-a027-480f-ba26-1b34210e69bd", "started_at": "2025-12-15T05:47:55.168531617Z", "finished_at": "2025-12-15T05:47:55.277508565Z", "discovery_type": {"type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308"}}}	{"type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308"}	Self Report	2025-12-15 05:47:55.168531+00	2025-12-15 05:47:55.28025+00	{}
e08f2bc5-4dd2-4398-9697-1e58201fafc9	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	6dd03575-78b8-413b-8f5e-6fc7cdae06ed	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "session_id": "f10aee3d-2345-4882-aba3-654e67ea8735", "started_at": "2025-12-15T05:47:55.292820379Z", "finished_at": "2025-12-15T05:49:30.130489770Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 05:47:55.29282+00	2025-12-15 05:49:30.132964+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
085c10d9-c8ea-4289-a787-c02844b1b993	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 05:49:30.148794+00	2025-12-15 05:49:30.148794+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
e301f7a6-3ef1-4458-8585-d150f0e6e788	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "051f65ae-2b14-4681-a8b9-0e0c24d34683"}	[{"id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c", "name": "Internet", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "ip_address": "1.1.1.1", "mac_address": null}]	{9288b70f-74f4-4850-8d11-3e2c0fc9423d}	[{"id": "6458ca50-b9fd-43c4-b3c6-210c5d6ac8ae", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 05:47:55.036869+00	2025-12-15 05:47:55.046679+00	f	{}
5ea65580-fc12-4844-bb89-a0dd3d2dac00	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	Google.com	\N	\N	{"type": "ServiceBinding", "config": "010abb4d-4838-47b4-a74b-1d8b9b777e3f"}	[{"id": "53896db0-f945-4a8d-87cb-95d87a1cbd84", "name": "Internet", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "ip_address": "203.0.113.37", "mac_address": null}]	{5abe2c07-9258-4d29-8835-6802d27680d0}	[{"id": "798744e7-7786-4da9-8804-310fd77275fc", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 05:47:55.036878+00	2025-12-15 05:47:55.052011+00	f	{}
dbc19a67-efa7-4b49-b4bc-370a185ffe7b	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "8d0b3e0a-b2b2-4674-923e-56e9c890efa3"}	[{"id": "497476b6-c392-428e-92c3-a3bdcefa02b6", "name": "Remote Network", "subnet_id": "f7038195-cb74-4966-aa86-81e8befbcf0a", "ip_address": "203.0.113.144", "mac_address": null}]	{c55b1080-60f5-46bb-a2b3-2e65023c794d}	[{"id": "c6e68944-f35e-463f-b2ad-31eb237664fd", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 05:47:55.036883+00	2025-12-15 05:47:55.055898+00	f	{}
cfc6c289-dd69-4480-99ff-49f2e179e4b5	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "57224f0d-f9df-41da-ad29-168add308730", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.5", "mac_address": "F2:C5:1D:66:F4:05"}]	{eb5c5c22-0c31-494a-992c-dd3d0cb3f90d,d8c2ec28-1ee9-41a9-a2cc-052fdc05eb76}	[{"id": "46c28b3e-5834-4e97-9255-d97f658b7fc9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a6737701-a2fb-4ecb-8909-6969e07ced4b", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:41.919320272Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 05:48:41.919322+00	2025-12-15 05:48:55.942904+00	f	{}
452c15ad-2e93-4fbe-957d-2baa75362308	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	scanopy-daemon	23f3fe056f0e	Scanopy daemon	{"type": "None"}	[{"id": "aa5731d9-ace0-4fee-adc4-0343b15ca3e3", "name": "eth0", "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.4", "mac_address": "CA:15:70:18:BF:F9"}]	{64c754ee-bcf6-4916-b968-d01aa0d2ffc9}	[{"id": "4628bbb6-c3e4-4d63-9b68-1f111a127c4f", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:47:55.263152564Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}	null	2025-12-15 05:47:55.149441+00	2025-12-15 05:47:55.274317+00	f	{}
aaeae3e6-e33e-46f8-b451-33e3ea66912f	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "2258123d-7e04-4f10-8057-f94da731cf41", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.6", "mac_address": "F6:95:3F:D9:92:E5"}]	{201f6f48-bf93-47b5-88bd-edb246358bde}	[{"id": "bf040a02-2f14-4b3e-b511-8029494da3ea", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:27.632198061Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 05:48:27.6322+00	2025-12-15 05:48:41.867862+00	f	{}
1fc8a77d-f5b8-4a77-8561-eb3e3b1ee95d	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "80d142a9-10da-4a50-adaf-0634268ed3b1", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.3", "mac_address": "B6:FB:C9:A1:C0:80"}]	{9c0599bb-3c25-4b7e-9328-b5d5de17174e}	[{"id": "eb23f1d2-0097-4a69-889e-b370b8e97cdc", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:55.982574075Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 05:48:55.982575+00	2025-12-15 05:49:09.960395+00	f	{}
93a06922-ec46-400a-8c39-54d6c38fea08	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.1", "mac_address": "E2:7D:D3:9F:EB:B0"}]	{b6d04123-8996-46cf-9879-43ae4f21f54f,d0944a69-ffd1-48bd-ab74-b3c5894c18f2,3c5ae4fa-61f3-4d86-86ea-b7567d897b98,f839447d-a8fc-496b-8838-c48fef8ce3f2}	[{"id": "3bbfbffd-83a5-43c9-86ca-cc3d022565c8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "8ee51ddb-f5df-4607-8d62-bedb3c761cbb", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "9aa0dce4-d6ee-48bc-b48b-575a3519f18a", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "7b4e1f3d-5c38-41e7-8ef0-24d4a6e87057", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:49:16.009429797Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 05:49:16.009432+00	2025-12-15 05:49:30.123841+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	My Network	2025-12-15 05:47:55.030969+00	2025-12-15 05:47:55.030969+00	f	ab815927-0ab7-4031-b417-d4e689a6ec58	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
ab815927-0ab7-4031-b417-d4e689a6ec58	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 05:47:55.025187+00	2025-12-15 05:49:30.969215+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
9288b70f-74f4-4850-8d11-3e2c0fc9423d	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.036872+00	2025-12-15 05:47:55.036872+00	Cloudflare DNS	e301f7a6-3ef1-4458-8585-d150f0e6e788	[{"id": "051f65ae-2b14-4681-a8b9-0e0c24d34683", "type": "Port", "port_id": "6458ca50-b9fd-43c4-b3c6-210c5d6ac8ae", "interface_id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c"}]	"Dns Server"	null	{"type": "System"}	{}
5abe2c07-9258-4d29-8835-6802d27680d0	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.036879+00	2025-12-15 05:47:55.036879+00	Google.com	5ea65580-fc12-4844-bb89-a0dd3d2dac00	[{"id": "010abb4d-4838-47b4-a74b-1d8b9b777e3f", "type": "Port", "port_id": "798744e7-7786-4da9-8804-310fd77275fc", "interface_id": "53896db0-f945-4a8d-87cb-95d87a1cbd84"}]	"Web Service"	null	{"type": "System"}	{}
c55b1080-60f5-46bb-a2b3-2e65023c794d	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.036885+00	2025-12-15 05:47:55.036885+00	Mobile Device	dbc19a67-efa7-4b49-b4bc-370a185ffe7b	[{"id": "8d0b3e0a-b2b2-4674-923e-56e9c890efa3", "type": "Port", "port_id": "c6e68944-f35e-463f-b2ad-31eb237664fd", "interface_id": "497476b6-c392-428e-92c3-a3bdcefa02b6"}]	"Client"	null	{"type": "System"}	{}
64c754ee-bcf6-4916-b968-d01aa0d2ffc9	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.263169+00	2025-12-15 05:47:55.263169+00	Scanopy Daemon	452c15ad-2e93-4fbe-957d-2baa75362308	[{"id": "78797f80-4682-4f3e-8ab6-90e5a30e631e", "type": "Port", "port_id": "4628bbb6-c3e4-4d63-9b68-1f111a127c4f", "interface_id": "aa5731d9-ace0-4fee-adc4-0343b15ca3e3"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T05:47:55.263168825Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}	{}
201f6f48-bf93-47b5-88bd-edb246358bde	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:48:41.845987+00	2025-12-15 05:48:41.845987+00	PostgreSQL	aaeae3e6-e33e-46f8-b451-33e3ea66912f	[{"id": "172b4b4a-85b5-445e-9a7e-16523b7b586d", "type": "Port", "port_id": "bf040a02-2f14-4b3e-b511-8029494da3ea", "interface_id": "2258123d-7e04-4f10-8057-f94da731cf41"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:48:41.845969525Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
eb5c5c22-0c31-494a-992c-dd3d0cb3f90d	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:48:50.371163+00	2025-12-15 05:48:50.371163+00	Home Assistant	cfc6c289-dd69-4480-99ff-49f2e179e4b5	[{"id": "8817cb18-a3f1-404a-b825-b5f0e2384d02", "type": "Port", "port_id": "46c28b3e-5834-4e97-9255-d97f658b7fc9", "interface_id": "57224f0d-f9df-41da-ad29-168add308730"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:48:50.371145354Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d8c2ec28-1ee9-41a9-a2cc-052fdc05eb76	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:48:55.928189+00	2025-12-15 05:48:55.928189+00	Unclaimed Open Ports	cfc6c289-dd69-4480-99ff-49f2e179e4b5	[{"id": "cace1872-cbbb-4d94-9e61-29a1783dea4c", "type": "Port", "port_id": "a6737701-a2fb-4ecb-8909-6969e07ced4b", "interface_id": "57224f0d-f9df-41da-ad29-168add308730"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:48:55.928166694Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9c0599bb-3c25-4b7e-9328-b5d5de17174e	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:49:04.355859+00	2025-12-15 05:49:04.355859+00	Scanopy Server	1fc8a77d-f5b8-4a77-8561-eb3e3b1ee95d	[{"id": "64ff3b33-0c2b-486c-be82-cfcd6f512abe", "type": "Port", "port_id": "eb23f1d2-0097-4a69-889e-b370b8e97cdc", "interface_id": "80d142a9-10da-4a50-adaf-0634268ed3b1"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:04.355836702Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b6d04123-8996-46cf-9879-43ae4f21f54f	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:49:24.449343+00	2025-12-15 05:49:24.449343+00	Home Assistant	93a06922-ec46-400a-8c39-54d6c38fea08	[{"id": "1f381301-9b0f-449e-935f-c28fc7bbda9c", "type": "Port", "port_id": "3bbfbffd-83a5-43c9-86ca-cc3d022565c8", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:24.449325597Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d0944a69-ffd1-48bd-ab74-b3c5894c18f2	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:49:24.450567+00	2025-12-15 05:49:24.450567+00	Scanopy Server	93a06922-ec46-400a-8c39-54d6c38fea08	[{"id": "0b606d07-315f-4cef-8bd2-0e0913cf134c", "type": "Port", "port_id": "8ee51ddb-f5df-4607-8d62-bedb3c761cbb", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:24.450558196Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3c5ae4fa-61f3-4d86-86ea-b7567d897b98	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:49:30.108601+00	2025-12-15 05:49:30.108601+00	SSH	93a06922-ec46-400a-8c39-54d6c38fea08	[{"id": "e4bc2a2d-11c7-48cd-89c1-6f9c8ed205ec", "type": "Port", "port_id": "9aa0dce4-d6ee-48bc-b48b-575a3519f18a", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:49:30.108583840Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f839447d-a8fc-496b-8838-c48fef8ce3f2	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:49:30.1088+00	2025-12-15 05:49:30.1088+00	Unclaimed Open Ports	93a06922-ec46-400a-8c39-54d6c38fea08	[{"id": "3eb1371b-3cf0-4a93-b295-22fc7f66955d", "type": "Port", "port_id": "7b4e1f3d-5c38-41e7-8ef0-24d4a6e87057", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:49:30.108791Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
96c17b6d-1cef-4010-9ddf-b5fd7927618f	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.036811+00	2025-12-15 05:47:55.036811+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
f7038195-cb74-4966-aa86-81e8befbcf0a	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.036815+00	2025-12-15 05:47:55.036815+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
df2e89e7-da87-4a26-9923-ef0bed90f2e1	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	2025-12-15 05:47:55.168667+00	2025-12-15 05:47:55.168667+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T05:47:55.168665967Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
8063b565-f626-4653-808a-0a157b8a76de	ab815927-0ab7-4031-b417-d4e689a6ec58	New Tag	\N	2025-12-15 05:49:30.164603+00	2025-12-15 05:49:30.164603+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
e7e884a9-2b04-45cd-a9e6-9df00e2fb3e1	e0756d0d-19c8-4ce8-ad5f-39e680afc0ca	My Topology	[]	[{"id": "f7038195-cb74-4966-aa86-81e8befbcf0a", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "497476b6-c392-428e-92c3-a3bdcefa02b6", "size": {"x": 250, "y": 100}, "header": null, "host_id": "dbc19a67-efa7-4b49-b4bc-370a185ffe7b", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f7038195-cb74-4966-aa86-81e8befbcf0a", "interface_id": "497476b6-c392-428e-92c3-a3bdcefa02b6"}, {"id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c", "size": {"x": 250, "y": 100}, "header": null, "host_id": "e301f7a6-3ef1-4458-8585-d150f0e6e788", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "interface_id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c"}, {"id": "53896db0-f945-4a8d-87cb-95d87a1cbd84", "size": {"x": 250, "y": 100}, "header": null, "host_id": "5ea65580-fc12-4844-bb89-a0dd3d2dac00", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "interface_id": "53896db0-f945-4a8d-87cb-95d87a1cbd84"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "e301f7a6-3ef1-4458-8585-d150f0e6e788", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "6458ca50-b9fd-43c4-b3c6-210c5d6ac8ae", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "051f65ae-2b14-4681-a8b9-0e0c24d34683"}, "hostname": null, "services": ["9288b70f-74f4-4850-8d11-3e2c0fc9423d"], "created_at": "2025-12-15T05:47:55.036869Z", "interfaces": [{"id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c", "name": "Internet", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.046679Z", "description": null, "virtualization": null}, {"id": "5ea65580-fc12-4844-bb89-a0dd3d2dac00", "name": "Google.com", "tags": [], "ports": [{"id": "798744e7-7786-4da9-8804-310fd77275fc", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "010abb4d-4838-47b4-a74b-1d8b9b777e3f"}, "hostname": null, "services": ["5abe2c07-9258-4d29-8835-6802d27680d0"], "created_at": "2025-12-15T05:47:55.036878Z", "interfaces": [{"id": "53896db0-f945-4a8d-87cb-95d87a1cbd84", "name": "Internet", "subnet_id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "ip_address": "203.0.113.37", "mac_address": null}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.052011Z", "description": null, "virtualization": null}, {"id": "dbc19a67-efa7-4b49-b4bc-370a185ffe7b", "name": "Mobile Device", "tags": [], "ports": [{"id": "c6e68944-f35e-463f-b2ad-31eb237664fd", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8d0b3e0a-b2b2-4674-923e-56e9c890efa3"}, "hostname": null, "services": ["c55b1080-60f5-46bb-a2b3-2e65023c794d"], "created_at": "2025-12-15T05:47:55.036883Z", "interfaces": [{"id": "497476b6-c392-428e-92c3-a3bdcefa02b6", "name": "Remote Network", "subnet_id": "f7038195-cb74-4966-aa86-81e8befbcf0a", "ip_address": "203.0.113.144", "mac_address": null}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.055898Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "452c15ad-2e93-4fbe-957d-2baa75362308", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "4628bbb6-c3e4-4d63-9b68-1f111a127c4f", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:47:55.263152564Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}, "target": {"type": "None"}, "hostname": "23f3fe056f0e", "services": ["64c754ee-bcf6-4916-b968-d01aa0d2ffc9"], "created_at": "2025-12-15T05:47:55.149441Z", "interfaces": [{"id": "aa5731d9-ace0-4fee-adc4-0343b15ca3e3", "name": "eth0", "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.4", "mac_address": "CA:15:70:18:BF:F9"}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.274317Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "aaeae3e6-e33e-46f8-b451-33e3ea66912f", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "bf040a02-2f14-4b3e-b511-8029494da3ea", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:27.632198061Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["201f6f48-bf93-47b5-88bd-edb246358bde"], "created_at": "2025-12-15T05:48:27.632200Z", "interfaces": [{"id": "2258123d-7e04-4f10-8057-f94da731cf41", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.6", "mac_address": "F6:95:3F:D9:92:E5"}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:48:41.867862Z", "description": null, "virtualization": null}, {"id": "cfc6c289-dd69-4480-99ff-49f2e179e4b5", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "46c28b3e-5834-4e97-9255-d97f658b7fc9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a6737701-a2fb-4ecb-8909-6969e07ced4b", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:41.919320272Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["eb5c5c22-0c31-494a-992c-dd3d0cb3f90d", "d8c2ec28-1ee9-41a9-a2cc-052fdc05eb76"], "created_at": "2025-12-15T05:48:41.919322Z", "interfaces": [{"id": "57224f0d-f9df-41da-ad29-168add308730", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.5", "mac_address": "F2:C5:1D:66:F4:05"}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:48:55.942904Z", "description": null, "virtualization": null}, {"id": "1fc8a77d-f5b8-4a77-8561-eb3e3b1ee95d", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "eb23f1d2-0097-4a69-889e-b370b8e97cdc", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:48:55.982574075Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["9c0599bb-3c25-4b7e-9328-b5d5de17174e"], "created_at": "2025-12-15T05:48:55.982575Z", "interfaces": [{"id": "80d142a9-10da-4a50-adaf-0634268ed3b1", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.3", "mac_address": "B6:FB:C9:A1:C0:80"}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:09.960395Z", "description": null, "virtualization": null}, {"id": "93a06922-ec46-400a-8c39-54d6c38fea08", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "3bbfbffd-83a5-43c9-86ca-cc3d022565c8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "8ee51ddb-f5df-4607-8d62-bedb3c761cbb", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "9aa0dce4-d6ee-48bc-b48b-575a3519f18a", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "7b4e1f3d-5c38-41e7-8ef0-24d4a6e87057", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:49:16.009429797Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["b6d04123-8996-46cf-9879-43ae4f21f54f", "d0944a69-ffd1-48bd-ab74-b3c5894c18f2", "3c5ae4fa-61f3-4d86-86ea-b7567d897b98", "f839447d-a8fc-496b-8838-c48fef8ce3f2"], "created_at": "2025-12-15T05:49:16.009432Z", "interfaces": [{"id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff", "name": null, "subnet_id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "ip_address": "172.25.0.1", "mac_address": "E2:7D:D3:9F:EB:B0"}], "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:30.123841Z", "description": null, "virtualization": null}]	[{"id": "96c17b6d-1cef-4010-9ddf-b5fd7927618f", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T05:47:55.036811Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.036811Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "f7038195-cb74-4966-aa86-81e8befbcf0a", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T05:47:55.036815Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.036815Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "df2e89e7-da87-4a26-9923-ef0bed90f2e1", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T05:47:55.168665967Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}, "created_at": "2025-12-15T05:47:55.168667Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.168667Z", "description": null, "subnet_type": "Lan"}]	[{"id": "9288b70f-74f4-4850-8d11-3e2c0fc9423d", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "e301f7a6-3ef1-4458-8585-d150f0e6e788", "bindings": [{"id": "051f65ae-2b14-4681-a8b9-0e0c24d34683", "type": "Port", "port_id": "6458ca50-b9fd-43c4-b3c6-210c5d6ac8ae", "interface_id": "2f4e30b9-be11-49bd-9b88-27eb06ce3c5c"}], "created_at": "2025-12-15T05:47:55.036872Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.036872Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5abe2c07-9258-4d29-8835-6802d27680d0", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "5ea65580-fc12-4844-bb89-a0dd3d2dac00", "bindings": [{"id": "010abb4d-4838-47b4-a74b-1d8b9b777e3f", "type": "Port", "port_id": "798744e7-7786-4da9-8804-310fd77275fc", "interface_id": "53896db0-f945-4a8d-87cb-95d87a1cbd84"}], "created_at": "2025-12-15T05:47:55.036879Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.036879Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "c55b1080-60f5-46bb-a2b3-2e65023c794d", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "dbc19a67-efa7-4b49-b4bc-370a185ffe7b", "bindings": [{"id": "8d0b3e0a-b2b2-4674-923e-56e9c890efa3", "type": "Port", "port_id": "c6e68944-f35e-463f-b2ad-31eb237664fd", "interface_id": "497476b6-c392-428e-92c3-a3bdcefa02b6"}], "created_at": "2025-12-15T05:47:55.036885Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.036885Z", "virtualization": null, "service_definition": "Client"}, {"id": "64c754ee-bcf6-4916-b968-d01aa0d2ffc9", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T05:47:55.263168825Z", "type": "SelfReport", "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed"}]}, "host_id": "452c15ad-2e93-4fbe-957d-2baa75362308", "bindings": [{"id": "78797f80-4682-4f3e-8ab6-90e5a30e631e", "type": "Port", "port_id": "4628bbb6-c3e4-4d63-9b68-1f111a127c4f", "interface_id": "aa5731d9-ace0-4fee-adc4-0343b15ca3e3"}], "created_at": "2025-12-15T05:47:55.263169Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:47:55.263169Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "201f6f48-bf93-47b5-88bd-edb246358bde", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:48:41.845969525Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "aaeae3e6-e33e-46f8-b451-33e3ea66912f", "bindings": [{"id": "172b4b4a-85b5-445e-9a7e-16523b7b586d", "type": "Port", "port_id": "bf040a02-2f14-4b3e-b511-8029494da3ea", "interface_id": "2258123d-7e04-4f10-8057-f94da731cf41"}], "created_at": "2025-12-15T05:48:41.845987Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:48:41.845987Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "eb5c5c22-0c31-494a-992c-dd3d0cb3f90d", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:48:50.371145354Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "cfc6c289-dd69-4480-99ff-49f2e179e4b5", "bindings": [{"id": "8817cb18-a3f1-404a-b825-b5f0e2384d02", "type": "Port", "port_id": "46c28b3e-5834-4e97-9255-d97f658b7fc9", "interface_id": "57224f0d-f9df-41da-ad29-168add308730"}], "created_at": "2025-12-15T05:48:50.371163Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:48:50.371163Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "d8c2ec28-1ee9-41a9-a2cc-052fdc05eb76", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:48:55.928166694Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "cfc6c289-dd69-4480-99ff-49f2e179e4b5", "bindings": [{"id": "cace1872-cbbb-4d94-9e61-29a1783dea4c", "type": "Port", "port_id": "a6737701-a2fb-4ecb-8909-6969e07ced4b", "interface_id": "57224f0d-f9df-41da-ad29-168add308730"}], "created_at": "2025-12-15T05:48:55.928189Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:48:55.928189Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "9c0599bb-3c25-4b7e-9328-b5d5de17174e", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:04.355836702Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1fc8a77d-f5b8-4a77-8561-eb3e3b1ee95d", "bindings": [{"id": "64ff3b33-0c2b-486c-be82-cfcd6f512abe", "type": "Port", "port_id": "eb23f1d2-0097-4a69-889e-b370b8e97cdc", "interface_id": "80d142a9-10da-4a50-adaf-0634268ed3b1"}], "created_at": "2025-12-15T05:49:04.355859Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:04.355859Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "b6d04123-8996-46cf-9879-43ae4f21f54f", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:24.449325597Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "93a06922-ec46-400a-8c39-54d6c38fea08", "bindings": [{"id": "1f381301-9b0f-449e-935f-c28fc7bbda9c", "type": "Port", "port_id": "3bbfbffd-83a5-43c9-86ca-cc3d022565c8", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}], "created_at": "2025-12-15T05:49:24.449343Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:24.449343Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "d0944a69-ffd1-48bd-ab74-b3c5894c18f2", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T05:49:24.450558196Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "93a06922-ec46-400a-8c39-54d6c38fea08", "bindings": [{"id": "0b606d07-315f-4cef-8bd2-0e0913cf134c", "type": "Port", "port_id": "8ee51ddb-f5df-4607-8d62-bedb3c761cbb", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}], "created_at": "2025-12-15T05:49:24.450567Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:24.450567Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "3c5ae4fa-61f3-4d86-86ea-b7567d897b98", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:49:30.108583840Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "93a06922-ec46-400a-8c39-54d6c38fea08", "bindings": [{"id": "e4bc2a2d-11c7-48cd-89c1-6f9c8ed205ec", "type": "Port", "port_id": "9aa0dce4-d6ee-48bc-b48b-575a3519f18a", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}], "created_at": "2025-12-15T05:49:30.108601Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:30.108601Z", "virtualization": null, "service_definition": "SSH"}, {"id": "f839447d-a8fc-496b-8838-c48fef8ce3f2", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T05:49:30.108791Z", "type": "Network", "daemon_id": "6dd03575-78b8-413b-8f5e-6fc7cdae06ed", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "93a06922-ec46-400a-8c39-54d6c38fea08", "bindings": [{"id": "3eb1371b-3cf0-4a93-b295-22fc7f66955d", "type": "Port", "port_id": "7b4e1f3d-5c38-41e7-8ef0-24d4a6e87057", "interface_id": "8f8282d4-d0a0-44e7-a336-e6583627b5ff"}], "created_at": "2025-12-15T05:49:30.108800Z", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:30.108800Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "085c10d9-c8ea-4289-a787-c02844b1b993", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T05:49:30.148794Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "e0756d0d-19c8-4ce8-ad5f-39e680afc0ca", "updated_at": "2025-12-15T05:49:30.148794Z", "description": null, "service_bindings": []}]	t	2025-12-15 05:47:55.060143+00	f	\N	\N	{f0e672af-114b-4ad5-907e-bfbe845f4201,7874dc30-2a28-4187-a605-88e58b5fb71a}	{4dd94114-c0e7-4e43-ac49-578902dae1ac}	{8b111203-4d8b-4f5f-8cd7-29e38f7787ac}	{1034512d-214c-450e-84bf-c34017db2b50}	\N	2025-12-15 05:47:55.056713+00	2025-12-15 05:49:31.777681+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
ef556487-4c07-4e02-a68e-e70929cb2197	2025-12-15 05:47:55.027771+00	2025-12-15 05:47:55.027771+00	$argon2id$v=19$m=19456,t=2,p=1$aV76sCofEWCBp40DAEYIQA$I5t0U1/1oriM3zO04JuIiI/jJ+VUapYk63acpq8mGSU	\N	\N	\N	user@gmail.com	ab815927-0ab7-4031-b417-d4e689a6ec58	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
qiWqtbqfeAfinGl9eo5vsg	\\x93c410b26f8e7a7d699ce207789fbab5aa25aa81a7757365725f6964d92465663535363438372d346330372d346530322d613638652d65373039323963623231393799cd07ea0e052f37ce0f05e16e000000	2026-01-14 05:47:55.252043+00
bGiV_zCDsuY_SlGTbnw09Q	\\x93c410f5347c6e93514a3fe6b28330ff95686c82ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92431326238656466652d373737362d343164642d623266652d636631326437363637383036ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92465663535363438372d346330372d346530322d613638652d65373039323963623231393799cd07ea0e05311ece2ab79e0e000000	2026-01-14 05:49:30.716676+00
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

\unrestrict BWX7hQOktUBUu2qzmzNpXjdMCSfnA1JLWhTG3tAMxFKjv7m69HujGO0yyoHDfvw

