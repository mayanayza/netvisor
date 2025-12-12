--
-- PostgreSQL database dump
--

\restrict gQEjs6H0t1cl0G9cX1ybhZm4gcUewJAu5BJEeLdS2OIBSdlQe3oB0BXkloZqEAf

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
20251006215000	users	2025-12-12 09:32:53.285521+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3696379
20251006215100	networks	2025-12-12 09:32:53.290279+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4972999
20251006215151	create hosts	2025-12-12 09:32:53.295614+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3979849
20251006215155	create subnets	2025-12-12 09:32:53.299982+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3810715
20251006215201	create groups	2025-12-12 09:32:53.304163+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3978086
20251006215204	create daemons	2025-12-12 09:32:53.308496+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4339398
20251006215212	create services	2025-12-12 09:32:53.313219+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4945915
20251029193448	user-auth	2025-12-12 09:32:53.31853+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6406804
20251030044828	daemon api	2025-12-12 09:32:53.325266+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1513463
20251030170438	host-hide	2025-12-12 09:32:53.327091+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1208377
20251102224919	create discovery	2025-12-12 09:32:53.328661+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10738985
20251106235621	normalize-daemon-cols	2025-12-12 09:32:53.339691+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1931521
20251107034459	api keys	2025-12-12 09:32:53.341929+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8186109
20251107222650	oidc-auth	2025-12-12 09:32:53.350444+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	27274398
20251110181948	orgs-billing	2025-12-12 09:32:53.378064+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10999470
20251113223656	group-enhancements	2025-12-12 09:32:53.389423+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1046396
20251117032720	daemon-mode	2025-12-12 09:32:53.390772+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1097631
20251118143058	set-default-plan	2025-12-12 09:32:53.392189+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1203718
20251118225043	save-topology	2025-12-12 09:32:53.393679+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8961851
20251123232748	network-permissions	2025-12-12 09:32:53.402985+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2788294
20251125001342	billing-updates	2025-12-12 09:32:53.406315+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	896727
20251128035448	org-onboarding-status	2025-12-12 09:32:53.407483+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1387520
20251129180942	nfs-consolidate	2025-12-12 09:32:53.409172+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1286231
20251206052641	discovery-progress	2025-12-12 09:32:53.410771+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1912197
20251206202200	plan-fix	2025-12-12 09:32:53.413+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	936555
20251207061341	daemon-url	2025-12-12 09:32:53.414299+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2317165
20251210045929	tags	2025-12-12 09:32:53.416961+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8702750
20251210175035	terms	2025-12-12 09:32:53.426013+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	850110
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
ed1c62d5-7809-414d-9f19-40a04c0f7c57	1bd3b62258de4a74898b884fbb7e6746	56dbf465-c418-4a74-9fa8-81c575b4fa54	Integrated Daemon API Key	2025-12-12 09:32:56.527401+00	2025-12-12 09:34:27.752375+00	2025-12-12 09:34:27.751253+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
24c79c6f-c5de-488d-b260-214699e900ff	56dbf465-c418-4a74-9fa8-81c575b4fa54	d68c7293-5001-40a4-96bc-06dc2a579e54	2025-12-12 09:32:56.575634+00	2025-12-12 09:34:13.04899+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["88c9da27-3283-4507-8370-14352f29c915"]}	2025-12-12 09:34:13.050444+00	"Push"	http://172.25.0.4:60073	netvisor-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
9f5d2e77-f655-4623-9884-37504162f6a3	56dbf465-c418-4a74-9fa8-81c575b4fa54	24c79c6f-c5de-488d-b260-214699e900ff	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54"}	Self Report	2025-12-12 09:32:56.582123+00	2025-12-12 09:32:56.582123+00	{}
1ea4033c-358e-4b9d-a2b7-7179d82e7a70	56dbf465-c418-4a74-9fa8-81c575b4fa54	24c79c6f-c5de-488d-b260-214699e900ff	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-12 09:32:56.588327+00	2025-12-12 09:32:56.588327+00	{}
e2d8f790-c958-4c2b-88c5-3607d5e7045c	56dbf465-c418-4a74-9fa8-81c575b4fa54	24c79c6f-c5de-488d-b260-214699e900ff	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "session_id": "9a6a5543-60cb-4142-95c9-63f933d1b7ff", "started_at": "2025-12-12T09:32:56.587962549Z", "finished_at": "2025-12-12T09:32:56.656961443Z", "discovery_type": {"type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54"}}}	{"type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54"}	Self Report	2025-12-12 09:32:56.587962+00	2025-12-12 09:32:56.661106+00	{}
acd5b71a-e6ea-4273-af7d-6b0219d39a93	56dbf465-c418-4a74-9fa8-81c575b4fa54	24c79c6f-c5de-488d-b260-214699e900ff	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "session_id": "72e28239-e2fb-45fd-83e2-2aad81685c46", "started_at": "2025-12-12T09:32:56.673120659Z", "finished_at": "2025-12-12T09:34:27.748349466Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-12 09:32:56.67312+00	2025-12-12 09:34:27.751491+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
80ba023d-23b6-4908-8e2b-1484c248e1f1	56dbf465-c418-4a74-9fa8-81c575b4fa54		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-12 09:34:27.762888+00	2025-12-12 09:34:27.762888+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
d7d850a6-930d-49b2-8600-b31739eac289	56dbf465-c418-4a74-9fa8-81c575b4fa54	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "41052320-21b0-498a-9bf4-f66e1a551560"}	[{"id": "6dd514cb-3c94-4054-a567-8ab7707d6eec", "name": "Internet", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "ip_address": "1.1.1.1", "mac_address": null}]	{7faa1c12-b843-4877-87cb-acf56675fab1}	[{"id": "2de3f03a-b773-4963-ad48-005ba8cfd0b7", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-12 09:32:56.457375+00	2025-12-12 09:32:56.466693+00	f	{}
6347c273-3aba-4e02-a83f-29e45401596b	56dbf465-c418-4a74-9fa8-81c575b4fa54	Google.com	\N	\N	{"type": "ServiceBinding", "config": "7c9e9eed-4d61-4d0d-b249-ae1a1a0620af"}	[{"id": "7a0aa171-ec73-44cd-82a3-857327e222a3", "name": "Internet", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "ip_address": "203.0.113.83", "mac_address": null}]	{d2aa6020-9611-48b8-8839-af978cbfb10d}	[{"id": "bdcd5d55-fd70-4b98-8073-191d70e817e2", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-12 09:32:56.457381+00	2025-12-12 09:32:56.471673+00	f	{}
27e8ea21-ab4d-4567-bd3b-902040c80e4e	56dbf465-c418-4a74-9fa8-81c575b4fa54	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "5e5f454b-45d0-4e82-800b-b66b8fdb62c0"}	[{"id": "d3c1d768-9b14-4828-a551-63af41cdb356", "name": "Remote Network", "subnet_id": "1bf345e1-87dd-4e43-a32c-bb0957c6393c", "ip_address": "203.0.113.111", "mac_address": null}]	{9766d804-e24d-4340-95f0-806edf456453}	[{"id": "b6e56189-8ce6-4138-bdf7-ed9777716812", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-12 09:32:56.457388+00	2025-12-12 09:32:56.518582+00	f	{}
0ee09350-b524-4db3-aab8-7d171df23554	56dbf465-c418-4a74-9fa8-81c575b4fa54	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "73646a22-af8d-4f8a-a0c4-498e06c061a5", "name": null, "subnet_id": "88c9da27-3283-4507-8370-14352f29c915", "ip_address": "172.25.0.3", "mac_address": "62:0D:BF:DC:72:77"}]	{926b4222-a969-49fb-aec6-254bfa6d4208}	[{"id": "bc3afa09-0353-4956-b66f-df2593bd4574", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:33:38.577968485Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-12 09:33:38.577971+00	2025-12-12 09:33:53.045863+00	f	{}
d68c7293-5001-40a4-96bc-06dc2a579e54	56dbf465-c418-4a74-9fa8-81c575b4fa54	netvisor-daemon	1f55184f05fe	NetVisor daemon	{"type": "None"}	[{"id": "86c021af-7985-41d2-8e87-bfc24e30a23d", "name": "eth0", "subnet_id": "88c9da27-3283-4507-8370-14352f29c915", "ip_address": "172.25.0.4", "mac_address": "C2:13:64:FF:46:DB"}]	{d9675c54-1f10-48c6-8718-40f0bf05561e}	[{"id": "3552a2d4-8a9a-401b-b4c0-d6bd1558157a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:32:56.642769709Z", "type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff"}]}	null	2025-12-12 09:32:56.537266+00	2025-12-12 09:32:56.654988+00	f	{}
b27cd7f4-7199-4358-9a08-28a7a52ed3a8	56dbf465-c418-4a74-9fa8-81c575b4fa54	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "d72d5b9e-837f-483e-b047-ea2f0f2a3f95", "name": null, "subnet_id": "88c9da27-3283-4507-8370-14352f29c915", "ip_address": "172.25.0.6", "mac_address": "02:89:83:CA:BB:DB"}]	{d3b65d18-bd1f-4385-a8b7-b84cfc9d95c5}	[{"id": "9bca69b4-63e6-405b-83be-bff9b2683772", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:33:23.624130628Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-12 09:33:23.624134+00	2025-12-12 09:33:38.479315+00	f	{}
7adf134c-e89f-4f49-84d6-96e5885eb52a	56dbf465-c418-4a74-9fa8-81c575b4fa54	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "4c17cf18-04e0-4213-99da-f81bcf8cb492", "name": null, "subnet_id": "88c9da27-3283-4507-8370-14352f29c915", "ip_address": "172.25.0.5", "mac_address": "3E:2F:F1:07:82:1B"}]	{ed62dabd-6e11-46f4-b607-b78c0e6c36a6,972aa438-5b6f-4348-9876-a4aaaa8390d4}	[{"id": "2d051c4f-5c03-4f8c-a293-010179da250c", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "722d8303-ce4c-407f-9d00-e51c14a72984", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:33:53.035643373Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-12 09:33:53.035645+00	2025-12-12 09:34:07.404531+00	f	{}
1dbe1d95-4e34-435d-b686-a774ab0f1492	56dbf465-c418-4a74-9fa8-81c575b4fa54	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "4fc11c80-5895-40e5-aecf-42a7e197034b", "name": null, "subnet_id": "88c9da27-3283-4507-8370-14352f29c915", "ip_address": "172.25.0.1", "mac_address": "52:AE:69:B7:18:74"}]	{92e91fb3-72dc-4421-82e1-26960533dca8,0b9571ff-1d31-4587-ac37-510854486c82,0910d836-955b-46e0-8079-409b685b4c75,582dbdfd-6032-442b-a5bd-693a7126ac75}	[{"id": "a19c64dc-b8b1-4046-b997-9c6b5a5a0903", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "7d58bef5-cd38-42bb-b55e-94ec312f3326", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "cd7a588c-6d65-4b4a-833b-b66834474ada", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "538155e8-e99f-4a82-aa63-335f7f722988", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:34:13.453740626Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-12 09:34:13.453743+00	2025-12-12 09:34:27.74249+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
56dbf465-c418-4a74-9fa8-81c575b4fa54	My Network	2025-12-12 09:32:56.456043+00	2025-12-12 09:32:56.456043+00	f	8b43c17a-63d4-4c6c-b100-7fd5a958523d	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
8b43c17a-63d4-4c6c-b100-7fd5a958523d	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-12 09:32:56.435273+00	2025-12-12 09:32:56.58045+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
7faa1c12-b843-4877-87cb-acf56675fab1	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.457377+00	2025-12-12 09:32:56.457377+00	Cloudflare DNS	d7d850a6-930d-49b2-8600-b31739eac289	[{"id": "41052320-21b0-498a-9bf4-f66e1a551560", "type": "Port", "port_id": "2de3f03a-b773-4963-ad48-005ba8cfd0b7", "interface_id": "6dd514cb-3c94-4054-a567-8ab7707d6eec"}]	"Dns Server"	null	{"type": "System"}	{}
d2aa6020-9611-48b8-8839-af978cbfb10d	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.457382+00	2025-12-12 09:32:56.457382+00	Google.com	6347c273-3aba-4e02-a83f-29e45401596b	[{"id": "7c9e9eed-4d61-4d0d-b249-ae1a1a0620af", "type": "Port", "port_id": "bdcd5d55-fd70-4b98-8073-191d70e817e2", "interface_id": "7a0aa171-ec73-44cd-82a3-857327e222a3"}]	"Web Service"	null	{"type": "System"}	{}
9766d804-e24d-4340-95f0-806edf456453	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.45739+00	2025-12-12 09:32:56.45739+00	Mobile Device	27e8ea21-ab4d-4567-bd3b-902040c80e4e	[{"id": "5e5f454b-45d0-4e82-800b-b66b8fdb62c0", "type": "Port", "port_id": "b6e56189-8ce6-4138-bdf7-ed9777716812", "interface_id": "d3c1d768-9b14-4828-a551-63af41cdb356"}]	"Client"	null	{"type": "System"}	{}
d9675c54-1f10-48c6-8718-40f0bf05561e	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.642787+00	2025-12-12 09:32:56.642787+00	NetVisor Daemon API	d68c7293-5001-40a4-96bc-06dc2a579e54	[{"id": "e7ff88e3-e5f2-4c15-a120-518facee1792", "type": "Port", "port_id": "3552a2d4-8a9a-401b-b4c0-d6bd1558157a", "interface_id": "86c021af-7985-41d2-8e87-bfc24e30a23d"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-12T09:32:56.642787241Z", "type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff"}]}	{}
d3b65d18-bd1f-4385-a8b7-b84cfc9d95c5	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:33:38.464752+00	2025-12-12 09:33:38.464752+00	PostgreSQL	b27cd7f4-7199-4358-9a08-28a7a52ed3a8	[{"id": "6c734203-40e3-4140-b673-536d47be8b2c", "type": "Port", "port_id": "9bca69b4-63e6-405b-83be-bff9b2683772", "interface_id": "d72d5b9e-837f-483e-b047-ea2f0f2a3f95"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-12T09:33:38.464736187Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
926b4222-a969-49fb-aec6-254bfa6d4208	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:33:46.572675+00	2025-12-12 09:33:46.572675+00	NetVisor Server API	0ee09350-b524-4db3-aab8-7d171df23554	[{"id": "e532ca63-87e5-42ac-ba3f-c604d631bff6", "type": "Port", "port_id": "bc3afa09-0353-4956-b66f-df2593bd4574", "interface_id": "73646a22-af8d-4f8a-a0c4-498e06c061a5"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-12T09:33:46.572659020Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
972aa438-5b6f-4348-9876-a4aaaa8390d4	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:34:07.393438+00	2025-12-12 09:34:07.393438+00	Unclaimed Open Ports	7adf134c-e89f-4f49-84d6-96e5885eb52a	[{"id": "5400da65-561d-45de-b982-9f2b3c5b17fd", "type": "Port", "port_id": "722d8303-ce4c-407f-9d00-e51c14a72984", "interface_id": "4c17cf18-04e0-4213-99da-f81bcf8cb492"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-12T09:34:07.393418016Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ed62dabd-6e11-46f4-b607-b78c0e6c36a6	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:33:54.525082+00	2025-12-12 09:33:54.525082+00	Home Assistant	7adf134c-e89f-4f49-84d6-96e5885eb52a	[{"id": "cbf21ef0-60cb-4223-b21d-64b4e97167ea", "type": "Port", "port_id": "2d051c4f-5c03-4f8c-a293-010179da250c", "interface_id": "4c17cf18-04e0-4213-99da-f81bcf8cb492"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-12T09:33:54.525063478Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0910d836-955b-46e0-8079-409b685b4c75	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:34:27.727458+00	2025-12-12 09:34:27.727458+00	SSH	1dbe1d95-4e34-435d-b686-a774ab0f1492	[{"id": "b237e1d3-c69e-4990-8567-c816ed58181e", "type": "Port", "port_id": "cd7a588c-6d65-4b4a-833b-b66834474ada", "interface_id": "4fc11c80-5895-40e5-aecf-42a7e197034b"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-12T09:34:27.727441168Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
582dbdfd-6032-442b-a5bd-693a7126ac75	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:34:27.727923+00	2025-12-12 09:34:27.727923+00	Unclaimed Open Ports	1dbe1d95-4e34-435d-b686-a774ab0f1492	[{"id": "d99e3f8d-f777-47ef-a8e4-331702fc62fe", "type": "Port", "port_id": "538155e8-e99f-4a82-aa63-335f7f722988", "interface_id": "4fc11c80-5895-40e5-aecf-42a7e197034b"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-12T09:34:27.727914929Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
92e91fb3-72dc-4421-82e1-26960533dca8	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:34:14.875047+00	2025-12-12 09:34:14.875047+00	Home Assistant	1dbe1d95-4e34-435d-b686-a774ab0f1492	[{"id": "85b5ce7e-c1d8-43cd-af3c-e95704cc1cb1", "type": "Port", "port_id": "a19c64dc-b8b1-4046-b997-9c6b5a5a0903", "interface_id": "4fc11c80-5895-40e5-aecf-42a7e197034b"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-12T09:34:14.875029770Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0b9571ff-1d31-4587-ac37-510854486c82	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:34:21.294208+00	2025-12-12 09:34:21.294208+00	NetVisor Server API	1dbe1d95-4e34-435d-b686-a774ab0f1492	[{"id": "f18f94b7-6aaa-410a-8915-f144bb03d784", "type": "Port", "port_id": "7d58bef5-cd38-42bb-b55e-94ec312f3326", "interface_id": "4fc11c80-5895-40e5-aecf-42a7e197034b"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-12T09:34:21.294191467Z", "type": "Network", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
9b44e25d-1786-42b3-826a-9e00a4679c23	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.457327+00	2025-12-12 09:32:56.457327+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
1bf345e1-87dd-4e43-a32c-bb0957c6393c	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.457331+00	2025-12-12 09:32:56.457331+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
88c9da27-3283-4507-8370-14352f29c915	56dbf465-c418-4a74-9fa8-81c575b4fa54	2025-12-12 09:32:56.588114+00	2025-12-12 09:32:56.588114+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-12T09:32:56.588113260Z", "type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
25b11c92-358f-404e-9ff1-e5de580ff55f	8b43c17a-63d4-4c6c-b100-7fd5a958523d	New Tag	\N	2025-12-12 09:34:27.76889+00	2025-12-12 09:34:27.76889+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
d3318751-2b5c-44dd-a8ff-8a23775be098	56dbf465-c418-4a74-9fa8-81c575b4fa54	My Topology	[]	[{"id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "1bf345e1-87dd-4e43-a32c-bb0957c6393c", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "d3c1d768-9b14-4828-a551-63af41cdb356", "size": {"x": 250, "y": 100}, "header": null, "host_id": "27e8ea21-ab4d-4567-bd3b-902040c80e4e", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "1bf345e1-87dd-4e43-a32c-bb0957c6393c", "interface_id": "d3c1d768-9b14-4828-a551-63af41cdb356"}, {"id": "6dd514cb-3c94-4054-a567-8ab7707d6eec", "size": {"x": 250, "y": 100}, "header": null, "host_id": "d7d850a6-930d-49b2-8600-b31739eac289", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "interface_id": "6dd514cb-3c94-4054-a567-8ab7707d6eec"}, {"id": "7a0aa171-ec73-44cd-82a3-857327e222a3", "size": {"x": 250, "y": 100}, "header": null, "host_id": "6347c273-3aba-4e02-a83f-29e45401596b", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "interface_id": "7a0aa171-ec73-44cd-82a3-857327e222a3"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "d7d850a6-930d-49b2-8600-b31739eac289", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "2de3f03a-b773-4963-ad48-005ba8cfd0b7", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "41052320-21b0-498a-9bf4-f66e1a551560"}, "hostname": null, "services": ["7faa1c12-b843-4877-87cb-acf56675fab1"], "created_at": "2025-12-12T09:32:56.457375Z", "interfaces": [{"id": "6dd514cb-3c94-4054-a567-8ab7707d6eec", "name": "Internet", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.466693Z", "description": null, "virtualization": null}, {"id": "6347c273-3aba-4e02-a83f-29e45401596b", "name": "Google.com", "tags": [], "ports": [{"id": "bdcd5d55-fd70-4b98-8073-191d70e817e2", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "7c9e9eed-4d61-4d0d-b249-ae1a1a0620af"}, "hostname": null, "services": ["d2aa6020-9611-48b8-8839-af978cbfb10d"], "created_at": "2025-12-12T09:32:56.457381Z", "interfaces": [{"id": "7a0aa171-ec73-44cd-82a3-857327e222a3", "name": "Internet", "subnet_id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "ip_address": "203.0.113.83", "mac_address": null}], "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.471673Z", "description": null, "virtualization": null}, {"id": "27e8ea21-ab4d-4567-bd3b-902040c80e4e", "name": "Mobile Device", "tags": [], "ports": [{"id": "b6e56189-8ce6-4138-bdf7-ed9777716812", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "5e5f454b-45d0-4e82-800b-b66b8fdb62c0"}, "hostname": null, "services": ["9766d804-e24d-4340-95f0-806edf456453"], "created_at": "2025-12-12T09:32:56.457388Z", "interfaces": [{"id": "d3c1d768-9b14-4828-a551-63af41cdb356", "name": "Remote Network", "subnet_id": "1bf345e1-87dd-4e43-a32c-bb0957c6393c", "ip_address": "203.0.113.111", "mac_address": null}], "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.518582Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "9b44e25d-1786-42b3-826a-9e00a4679c23", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-12T09:32:56.457327Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.457327Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "1bf345e1-87dd-4e43-a32c-bb0957c6393c", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-12T09:32:56.457331Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.457331Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "88c9da27-3283-4507-8370-14352f29c915", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-12T09:32:56.588113260Z", "type": "SelfReport", "host_id": "d68c7293-5001-40a4-96bc-06dc2a579e54", "daemon_id": "24c79c6f-c5de-488d-b260-214699e900ff"}]}, "created_at": "2025-12-12T09:32:56.588114Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.588114Z", "description": null, "subnet_type": "Lan"}]	[{"id": "7faa1c12-b843-4877-87cb-acf56675fab1", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "d7d850a6-930d-49b2-8600-b31739eac289", "bindings": [{"id": "41052320-21b0-498a-9bf4-f66e1a551560", "type": "Port", "port_id": "2de3f03a-b773-4963-ad48-005ba8cfd0b7", "interface_id": "6dd514cb-3c94-4054-a567-8ab7707d6eec"}], "created_at": "2025-12-12T09:32:56.457377Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.457377Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "d2aa6020-9611-48b8-8839-af978cbfb10d", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "6347c273-3aba-4e02-a83f-29e45401596b", "bindings": [{"id": "7c9e9eed-4d61-4d0d-b249-ae1a1a0620af", "type": "Port", "port_id": "bdcd5d55-fd70-4b98-8073-191d70e817e2", "interface_id": "7a0aa171-ec73-44cd-82a3-857327e222a3"}], "created_at": "2025-12-12T09:32:56.457382Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.457382Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "9766d804-e24d-4340-95f0-806edf456453", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "27e8ea21-ab4d-4567-bd3b-902040c80e4e", "bindings": [{"id": "5e5f454b-45d0-4e82-800b-b66b8fdb62c0", "type": "Port", "port_id": "b6e56189-8ce6-4138-bdf7-ed9777716812", "interface_id": "d3c1d768-9b14-4828-a551-63af41cdb356"}], "created_at": "2025-12-12T09:32:56.457390Z", "network_id": "56dbf465-c418-4a74-9fa8-81c575b4fa54", "updated_at": "2025-12-12T09:32:56.457390Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-12 09:32:56.524525+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-12 09:32:56.519399+00	2025-12-12 09:34:07.492565+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
5c1d881c-990e-40c1-b4e7-579eacc37ede	2025-12-12 09:32:56.438216+00	2025-12-12 09:32:56.438216+00	$argon2id$v=19$m=19456,t=2,p=1$FBwGVt/iruCNIPruFcG1Ew$Wrxuh+aSvSh/sb0e0Uagc3LmX7j+NVX2EUVC9pLC02k	\N	\N	\N	user@gmail.com	8b43c17a-63d4-4c6c-b100-7fd5a958523d	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
oIEVkBwA9mDeOCLIrGzlVg	\\x93c41056e56cacc82238de60f6001c901581a081a7757365725f6964d92435633164383831632d393930652d343063312d623465372d35373965616363333765646599cd07ea0b092038ce1a508a9b000000	2026-01-11 09:32:56.441485+00
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

\unrestrict gQEjs6H0t1cl0G9cX1ybhZm4gcUewJAu5BJEeLdS2OIBSdlQe3oB0BXkloZqEAf

