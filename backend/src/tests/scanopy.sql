--
-- PostgreSQL database dump
--

\restrict fk5cAh2E9O7lnm9fOEclE50O6UGa3N3nKjuQgzJWEgOIpjL6HkfkEeYWBTRjVau

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
20251006215000	users	2025-12-15 22:32:59.641393+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3605720
20251006215100	networks	2025-12-15 22:32:59.646027+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4582710
20251006215151	create hosts	2025-12-15 22:32:59.650962+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3893069
20251006215155	create subnets	2025-12-15 22:32:59.655195+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3926451
20251006215201	create groups	2025-12-15 22:32:59.659487+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4133800
20251006215204	create daemons	2025-12-15 22:32:59.664008+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4216084
20251006215212	create services	2025-12-15 22:32:59.670961+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4838900
20251029193448	user-auth	2025-12-15 22:32:59.676146+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5640390
20251030044828	daemon api	2025-12-15 22:32:59.682066+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1494188
20251030170438	host-hide	2025-12-15 22:32:59.683849+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1091724
20251102224919	create discovery	2025-12-15 22:32:59.685245+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10807134
20251106235621	normalize-daemon-cols	2025-12-15 22:32:59.696366+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1772889
20251107034459	api keys	2025-12-15 22:32:59.698419+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8267289
20251107222650	oidc-auth	2025-12-15 22:32:59.707016+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26436817
20251110181948	orgs-billing	2025-12-15 22:32:59.733983+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11063043
20251113223656	group-enhancements	2025-12-15 22:32:59.745369+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1044335
20251117032720	daemon-mode	2025-12-15 22:32:59.746714+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1105801
20251118143058	set-default-plan	2025-12-15 22:32:59.748102+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1204154
20251118225043	save-topology	2025-12-15 22:32:59.749585+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9141566
20251123232748	network-permissions	2025-12-15 22:32:59.759059+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2762923
20251125001342	billing-updates	2025-12-15 22:32:59.76214+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	964756
20251128035448	org-onboarding-status	2025-12-15 22:32:59.763492+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1477105
20251129180942	nfs-consolidate	2025-12-15 22:32:59.765259+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1354086
20251206052641	discovery-progress	2025-12-15 22:32:59.766947+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1634681
20251206202200	plan-fix	2025-12-15 22:32:59.768891+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1089549
20251207061341	daemon-url	2025-12-15 22:32:59.770291+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2307351
20251210045929	tags	2025-12-15 22:32:59.772939+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	9409670
20251210175035	terms	2025-12-15 22:32:59.78273+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	892531
20251213025048	hash-keys	2025-12-15 22:32:59.783929+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9053962
20251214050638	scanopy	2025-12-15 22:32:59.793277+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1489328
20251215215724	topo-scanopy-fix	2025-12-15 22:32:59.795131+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	838961
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
9dacb455-9678-4fcf-bd61-869d715285b8	9bb791c40515f5f3d97a7642fab1d35f6756ee64b95a508d654963c328bf1226	0becc2bc-8583-4587-af55-6565cc3a4f51	Integrated Daemon API Key	2025-12-15 22:33:02.559517+00	2025-12-15 22:34:37.383431+00	2025-12-15 22:34:37.382443+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
b02b861a-35ed-4b3e-8586-6df4b7a268ee	0becc2bc-8583-4587-af55-6565cc3a4f51	dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81	2025-12-15 22:33:02.638264+00	2025-12-15 22:34:15.33285+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["381cf8f7-bb2a-412b-bfa7-f026991b408e"]}	2025-12-15 22:34:15.333453+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
952a3c62-a48c-49ce-a447-e1b2d336b210	0becc2bc-8583-4587-af55-6565cc3a4f51	b02b861a-35ed-4b3e-8586-6df4b7a268ee	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81"}	Self Report	2025-12-15 22:33:02.646723+00	2025-12-15 22:33:02.646723+00	{}
e059334b-1d42-4d5c-ba5e-1e54508fc3a5	0becc2bc-8583-4587-af55-6565cc3a4f51	b02b861a-35ed-4b3e-8586-6df4b7a268ee	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 22:33:02.655731+00	2025-12-15 22:33:02.655731+00	{}
8e15e186-bc5c-492d-b942-6896a426b504	0becc2bc-8583-4587-af55-6565cc3a4f51	b02b861a-35ed-4b3e-8586-6df4b7a268ee	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "session_id": "4c309858-bc66-42ef-9d54-7ee80b379e75", "started_at": "2025-12-15T22:33:02.655047493Z", "finished_at": "2025-12-15T22:33:02.743867515Z", "discovery_type": {"type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81"}}}	{"type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81"}	Self Report	2025-12-15 22:33:02.655047+00	2025-12-15 22:33:02.746579+00	{}
5bdb8e5f-55a1-4a66-bd70-d210b3eb9edf	0becc2bc-8583-4587-af55-6565cc3a4f51	b02b861a-35ed-4b3e-8586-6df4b7a268ee	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "session_id": "910163ed-ecc8-4726-b2ab-ad3229052a68", "started_at": "2025-12-15T22:33:02.760129431Z", "finished_at": "2025-12-15T22:34:37.380344930Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-15 22:33:02.760129+00	2025-12-15 22:34:37.382781+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
67b5f468-0084-454b-8bcc-551a025d57ef	0becc2bc-8583-4587-af55-6565cc3a4f51		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-15 22:34:37.399143+00	2025-12-15 22:34:37.399143+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
b07a8cd0-ec4b-4229-ba58-c56c3e3511a7	0becc2bc-8583-4587-af55-6565cc3a4f51	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "849b9463-4528-4983-bba5-8b3014f35959"}	[{"id": "9d23488c-7455-4083-83d5-e8f5302a6441", "name": "Internet", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "ip_address": "1.1.1.1", "mac_address": null}]	{350593c3-fde3-4184-bb65-48778fd6cfb2}	[{"id": "8811320e-d656-4d82-b388-e953f8ce0b3f", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-15 22:33:02.531389+00	2025-12-15 22:33:02.541287+00	f	{}
736ca5ef-2a80-499d-a80c-5c3d5c84e172	0becc2bc-8583-4587-af55-6565cc3a4f51	Google.com	\N	\N	{"type": "ServiceBinding", "config": "bc6da80b-7336-465d-b227-846afaf06bf1"}	[{"id": "d3817524-dd33-4769-90ef-c9f070c9ac6f", "name": "Internet", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "ip_address": "203.0.113.177", "mac_address": null}]	{a832432c-1b2f-4da3-9887-c3ff05ef651e}	[{"id": "36f0a7a1-9135-4b52-af62-2f00d9205288", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 22:33:02.531397+00	2025-12-15 22:33:02.548874+00	f	{}
2ec84b65-eece-46cc-a889-fb46680160e9	0becc2bc-8583-4587-af55-6565cc3a4f51	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "6d1b36ee-b14a-4143-80d3-bd1b00d8ae16"}	[{"id": "99cb4868-3cef-4d4a-a49e-2a80eee10739", "name": "Remote Network", "subnet_id": "9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3", "ip_address": "203.0.113.173", "mac_address": null}]	{fd07d5ea-d897-46cd-9711-cf0c8f8f64a0}	[{"id": "abfc157a-360b-47c8-8285-3e519e63f4fc", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-15 22:33:02.531402+00	2025-12-15 22:33:02.55283+00	f	{}
cab802e6-598f-429d-bf9a-f2f59052a5ef	0becc2bc-8583-4587-af55-6565cc3a4f51	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "9862e028-a300-4dbd-8f4f-4f366557149b", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.3", "mac_address": "0A:36:DC:6A:62:4E"}]	{5b70cbe4-e59a-474e-83fb-961fd5c93c14}	[{"id": "5f597889-5fc7-4fcb-b692-09eba3c9193f", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:48.112906729Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 22:33:48.112909+00	2025-12-15 22:34:03.202175+00	f	{}
dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81	0becc2bc-8583-4587-af55-6565cc3a4f51	scanopy-daemon	622747fa3805	Scanopy daemon	{"type": "None"}	[{"id": "f31a0f82-ab45-432e-b0bc-7d25a0b5ad80", "name": "eth0", "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.4", "mac_address": "FE:CD:EB:4E:E0:7F"}]	{6d76404d-6ce8-4801-b19a-ab6ebf2658e9}	[{"id": "ca44d2f2-5238-42ef-8d99-f56e84d03f03", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:02.729760498Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}	null	2025-12-15 22:33:02.569569+00	2025-12-15 22:33:02.741807+00	f	{}
d3d4dab4-5b25-4168-ba67-c59ec9595549	0becc2bc-8583-4587-af55-6565cc3a4f51	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "68fbe1d1-5b2b-44a0-9065-8e4dcdd257aa", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.6", "mac_address": "C6:86:E1:9C:72:32"}]	{8658f2f0-dc16-4625-a4b4-43e7505fad87}	[{"id": "39f2e4ad-a8f6-4633-ae7b-81465cee6d4e", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:33.145797693Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 22:33:33.145801+00	2025-12-15 22:33:48.027475+00	f	{}
27370877-3832-4531-8f9b-5fd8c8045f2f	0becc2bc-8583-4587-af55-6565cc3a4f51	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "8a4cdda3-df7c-455a-b9e9-281616d85e67", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.5", "mac_address": "5A:91:DF:7D:40:FB"}]	{8182ca12-3d4e-4cad-b51c-d429ecb54fed}	[{"id": "fc5e06bb-5e29-4516-867d-bbaa5db85777", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "d5839ed8-2448-4796-bdd0-d74782755daf", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:34:03.197209785Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 22:34:03.197213+00	2025-12-15 22:34:18.163289+00	f	{}
4f3bd74e-4373-46bc-8fb4-6a53b757a94b	0becc2bc-8583-4587-af55-6565cc3a4f51	runnervm6qbrg	runnervm6qbrg	\N	{"type": "Hostname"}	[{"id": "c522a083-dfe8-4f42-8c33-55b27ca467e1", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.1", "mac_address": "76:B5:3E:B1:A5:7F"}]	{1e7d650e-28c4-4519-9f26-d004e29cd98b,04521006-01d4-41f8-9d35-e12f93e2124f,4bf27622-4cb1-4696-8bdf-cebcc397b2aa,a199f2dc-9c30-4967-92f6-83419297d6eb}	[{"id": "ff3d3e0b-01c2-41da-9275-aac905667f1e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1e57859c-1b3c-4d93-ad94-45ad6713fd97", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "4606c6da-82db-43d8-9f1e-060537048a19", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "91c6a118-0674-4f94-aed6-820c98a36f06", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:34:22.219715062Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-15 22:34:22.219718+00	2025-12-15 22:34:37.373859+00	f	{}
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
0becc2bc-8583-4587-af55-6565cc3a4f51	My Network	2025-12-15 22:33:02.529904+00	2025-12-15 22:33:02.529904+00	f	8625779b-63c7-46ae-8367-9b34d64a20f0	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
8625779b-63c7-46ae-8367-9b34d64a20f0	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-15 22:33:02.52352+00	2025-12-15 22:34:38.250363+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
350593c3-fde3-4184-bb65-48778fd6cfb2	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.531392+00	2025-12-15 22:33:02.531392+00	Cloudflare DNS	b07a8cd0-ec4b-4229-ba58-c56c3e3511a7	[{"id": "849b9463-4528-4983-bba5-8b3014f35959", "type": "Port", "port_id": "8811320e-d656-4d82-b388-e953f8ce0b3f", "interface_id": "9d23488c-7455-4083-83d5-e8f5302a6441"}]	"Dns Server"	null	{"type": "System"}	{}
a832432c-1b2f-4da3-9887-c3ff05ef651e	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.531398+00	2025-12-15 22:33:02.531398+00	Google.com	736ca5ef-2a80-499d-a80c-5c3d5c84e172	[{"id": "bc6da80b-7336-465d-b227-846afaf06bf1", "type": "Port", "port_id": "36f0a7a1-9135-4b52-af62-2f00d9205288", "interface_id": "d3817524-dd33-4769-90ef-c9f070c9ac6f"}]	"Web Service"	null	{"type": "System"}	{}
fd07d5ea-d897-46cd-9711-cf0c8f8f64a0	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.531403+00	2025-12-15 22:33:02.531403+00	Mobile Device	2ec84b65-eece-46cc-a889-fb46680160e9	[{"id": "6d1b36ee-b14a-4143-80d3-bd1b00d8ae16", "type": "Port", "port_id": "abfc157a-360b-47c8-8285-3e519e63f4fc", "interface_id": "99cb4868-3cef-4d4a-a49e-2a80eee10739"}]	"Client"	null	{"type": "System"}	{}
6d76404d-6ce8-4801-b19a-ab6ebf2658e9	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.729781+00	2025-12-15 22:33:02.729781+00	Scanopy Daemon	dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81	[{"id": "b8e1f7f4-eedf-4eb0-b0d0-479f7295903a", "type": "Port", "port_id": "ca44d2f2-5238-42ef-8d99-f56e84d03f03", "interface_id": "f31a0f82-ab45-432e-b0bc-7d25a0b5ad80"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T22:33:02.729781307Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}	{}
8658f2f0-dc16-4625-a4b4-43e7505fad87	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:48.011716+00	2025-12-15 22:33:48.011716+00	PostgreSQL	d3d4dab4-5b25-4168-ba67-c59ec9595549	[{"id": "4f1d60cb-ef44-42c5-99f0-3b5223e976f4", "type": "Port", "port_id": "39f2e4ad-a8f6-4633-ae7b-81465cee6d4e", "interface_id": "68fbe1d1-5b2b-44a0-9065-8e4dcdd257aa"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:33:48.011699594Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5b70cbe4-e59a-474e-83fb-961fd5c93c14	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:54.804767+00	2025-12-15 22:33:54.804767+00	Scanopy Server	cab802e6-598f-429d-bf9a-f2f59052a5ef	[{"id": "a2096e4b-fa2d-4d6a-8759-17589204ec77", "type": "Port", "port_id": "5f597889-5fc7-4fcb-b692-09eba3c9193f", "interface_id": "9862e028-a300-4dbd-8f4f-4f366557149b"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:33:54.804747022Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
8182ca12-3d4e-4cad-b51c-d429ecb54fed	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:34:18.15401+00	2025-12-15 22:34:18.15401+00	Unclaimed Open Ports	27370877-3832-4531-8f9b-5fd8c8045f2f	[{"id": "3f156ff6-5f71-422e-ba88-84563b90dd96", "type": "Port", "port_id": "fc5e06bb-5e29-4516-867d-bbaa5db85777", "interface_id": "8a4cdda3-df7c-455a-b9e9-281616d85e67"}, {"id": "7b3ef440-86c1-4a94-ad9d-16d3a3c78b8f", "type": "Port", "port_id": "d5839ed8-2448-4796-bdd0-d74782755daf", "interface_id": "8a4cdda3-df7c-455a-b9e9-281616d85e67"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:18.153989138Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
04521006-01d4-41f8-9d35-e12f93e2124f	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:34:29.057542+00	2025-12-15 22:34:29.057542+00	Scanopy Server	4f3bd74e-4373-46bc-8fb4-6a53b757a94b	[{"id": "2c64ae8d-c607-4aa6-8bd3-de2bc512b349", "type": "Port", "port_id": "1e57859c-1b3c-4d93-ad94-45ad6713fd97", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:34:29.057522491Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
4bf27622-4cb1-4696-8bdf-cebcc397b2aa	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:34:37.358436+00	2025-12-15 22:34:37.358436+00	SSH	4f3bd74e-4373-46bc-8fb4-6a53b757a94b	[{"id": "5f01579b-34ca-4a5e-8431-b4e1103ee093", "type": "Port", "port_id": "4606c6da-82db-43d8-9f1e-060537048a19", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:37.358419148Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1e7d650e-28c4-4519-9f26-d004e29cd98b	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:34:26.780847+00	2025-12-15 22:34:26.780847+00	Home Assistant	4f3bd74e-4373-46bc-8fb4-6a53b757a94b	[{"id": "3ec226b0-e6c2-4667-b05a-fd7e9f21c313", "type": "Port", "port_id": "ff3d3e0b-01c2-41da-9275-aac905667f1e", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:34:26.780830877Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a199f2dc-9c30-4967-92f6-83419297d6eb	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:34:37.358982+00	2025-12-15 22:34:37.358982+00	Unclaimed Open Ports	4f3bd74e-4373-46bc-8fb4-6a53b757a94b	[{"id": "bcc14725-f0e8-43cb-b984-828490959662", "type": "Port", "port_id": "91c6a118-0674-4f94-aed6-820c98a36f06", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:37.358974297Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
7c645809-19ff-46ca-b4c8-9fd0539fc478	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.531325+00	2025-12-15 22:33:02.531325+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.531329+00	2025-12-15 22:33:02.531329+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
381cf8f7-bb2a-412b-bfa7-f026991b408e	0becc2bc-8583-4587-af55-6565cc3a4f51	2025-12-15 22:33:02.655231+00	2025-12-15 22:33:02.655231+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:02.655229404Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
0e604982-16be-43de-a3a0-a617fc127341	8625779b-63c7-46ae-8367-9b34d64a20f0	New Tag	\N	2025-12-15 22:34:37.407984+00	2025-12-15 22:34:37.407984+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
f6f32fac-e14c-4ee2-b450-06bfd1047cc8	0becc2bc-8583-4587-af55-6565cc3a4f51	My Topology	[]	[{"id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "9d23488c-7455-4083-83d5-e8f5302a6441", "size": {"x": 250, "y": 100}, "header": null, "host_id": "b07a8cd0-ec4b-4229-ba58-c56c3e3511a7", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "interface_id": "9d23488c-7455-4083-83d5-e8f5302a6441"}, {"id": "d3817524-dd33-4769-90ef-c9f070c9ac6f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "736ca5ef-2a80-499d-a80c-5c3d5c84e172", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "interface_id": "d3817524-dd33-4769-90ef-c9f070c9ac6f"}, {"id": "99cb4868-3cef-4d4a-a49e-2a80eee10739", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2ec84b65-eece-46cc-a889-fb46680160e9", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3", "interface_id": "99cb4868-3cef-4d4a-a49e-2a80eee10739"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "b07a8cd0-ec4b-4229-ba58-c56c3e3511a7", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "8811320e-d656-4d82-b388-e953f8ce0b3f", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "849b9463-4528-4983-bba5-8b3014f35959"}, "hostname": null, "services": ["350593c3-fde3-4184-bb65-48778fd6cfb2"], "created_at": "2025-12-15T22:33:02.531389Z", "interfaces": [{"id": "9d23488c-7455-4083-83d5-e8f5302a6441", "name": "Internet", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.541287Z", "description": null, "virtualization": null}, {"id": "736ca5ef-2a80-499d-a80c-5c3d5c84e172", "name": "Google.com", "tags": [], "ports": [{"id": "36f0a7a1-9135-4b52-af62-2f00d9205288", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "bc6da80b-7336-465d-b227-846afaf06bf1"}, "hostname": null, "services": ["a832432c-1b2f-4da3-9887-c3ff05ef651e"], "created_at": "2025-12-15T22:33:02.531397Z", "interfaces": [{"id": "d3817524-dd33-4769-90ef-c9f070c9ac6f", "name": "Internet", "subnet_id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "ip_address": "203.0.113.177", "mac_address": null}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.548874Z", "description": null, "virtualization": null}, {"id": "2ec84b65-eece-46cc-a889-fb46680160e9", "name": "Mobile Device", "tags": [], "ports": [{"id": "abfc157a-360b-47c8-8285-3e519e63f4fc", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "6d1b36ee-b14a-4143-80d3-bd1b00d8ae16"}, "hostname": null, "services": ["fd07d5ea-d897-46cd-9711-cf0c8f8f64a0"], "created_at": "2025-12-15T22:33:02.531402Z", "interfaces": [{"id": "99cb4868-3cef-4d4a-a49e-2a80eee10739", "name": "Remote Network", "subnet_id": "9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3", "ip_address": "203.0.113.173", "mac_address": null}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.552830Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "ca44d2f2-5238-42ef-8d99-f56e84d03f03", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:02.729760498Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}, "target": {"type": "None"}, "hostname": "622747fa3805", "services": ["6d76404d-6ce8-4801-b19a-ab6ebf2658e9"], "created_at": "2025-12-15T22:33:02.569569Z", "interfaces": [{"id": "f31a0f82-ab45-432e-b0bc-7d25a0b5ad80", "name": "eth0", "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.4", "mac_address": "FE:CD:EB:4E:E0:7F"}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.741807Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "d3d4dab4-5b25-4168-ba67-c59ec9595549", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "39f2e4ad-a8f6-4633-ae7b-81465cee6d4e", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:33.145797693Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["8658f2f0-dc16-4625-a4b4-43e7505fad87"], "created_at": "2025-12-15T22:33:33.145801Z", "interfaces": [{"id": "68fbe1d1-5b2b-44a0-9065-8e4dcdd257aa", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.6", "mac_address": "C6:86:E1:9C:72:32"}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:48.027475Z", "description": null, "virtualization": null}, {"id": "cab802e6-598f-429d-bf9a-f2f59052a5ef", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "5f597889-5fc7-4fcb-b692-09eba3c9193f", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:48.112906729Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["5b70cbe4-e59a-474e-83fb-961fd5c93c14"], "created_at": "2025-12-15T22:33:48.112909Z", "interfaces": [{"id": "9862e028-a300-4dbd-8f4f-4f366557149b", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.3", "mac_address": "0A:36:DC:6A:62:4E"}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:03.202175Z", "description": null, "virtualization": null}, {"id": "27370877-3832-4531-8f9b-5fd8c8045f2f", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "fc5e06bb-5e29-4516-867d-bbaa5db85777", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "d5839ed8-2448-4796-bdd0-d74782755daf", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:34:03.197209785Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["8182ca12-3d4e-4cad-b51c-d429ecb54fed"], "created_at": "2025-12-15T22:34:03.197213Z", "interfaces": [{"id": "8a4cdda3-df7c-455a-b9e9-281616d85e67", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.5", "mac_address": "5A:91:DF:7D:40:FB"}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:18.163289Z", "description": null, "virtualization": null}, {"id": "4f3bd74e-4373-46bc-8fb4-6a53b757a94b", "name": "runnervm6qbrg", "tags": [], "ports": [{"id": "ff3d3e0b-01c2-41da-9275-aac905667f1e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1e57859c-1b3c-4d93-ad94-45ad6713fd97", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "4606c6da-82db-43d8-9f1e-060537048a19", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "91c6a118-0674-4f94-aed6-820c98a36f06", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:34:22.219715062Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervm6qbrg", "services": ["1e7d650e-28c4-4519-9f26-d004e29cd98b", "04521006-01d4-41f8-9d35-e12f93e2124f", "4bf27622-4cb1-4696-8bdf-cebcc397b2aa", "a199f2dc-9c30-4967-92f6-83419297d6eb"], "created_at": "2025-12-15T22:34:22.219718Z", "interfaces": [{"id": "c522a083-dfe8-4f42-8c33-55b27ca467e1", "name": null, "subnet_id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "ip_address": "172.25.0.1", "mac_address": "76:B5:3E:B1:A5:7F"}], "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:37.373859Z", "description": null, "virtualization": null}]	[{"id": "7c645809-19ff-46ca-b4c8-9fd0539fc478", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T22:33:02.531325Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.531325Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "9e6f0bd1-bf24-4286-b8ae-f2f71cd499f3", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-15T22:33:02.531329Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.531329Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "381cf8f7-bb2a-412b-bfa7-f026991b408e", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-15T22:33:02.655229404Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}, "created_at": "2025-12-15T22:33:02.655231Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.655231Z", "description": null, "subnet_type": "Lan"}]	[{"id": "350593c3-fde3-4184-bb65-48778fd6cfb2", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "b07a8cd0-ec4b-4229-ba58-c56c3e3511a7", "bindings": [{"id": "849b9463-4528-4983-bba5-8b3014f35959", "type": "Port", "port_id": "8811320e-d656-4d82-b388-e953f8ce0b3f", "interface_id": "9d23488c-7455-4083-83d5-e8f5302a6441"}], "created_at": "2025-12-15T22:33:02.531392Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.531392Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "a832432c-1b2f-4da3-9887-c3ff05ef651e", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "736ca5ef-2a80-499d-a80c-5c3d5c84e172", "bindings": [{"id": "bc6da80b-7336-465d-b227-846afaf06bf1", "type": "Port", "port_id": "36f0a7a1-9135-4b52-af62-2f00d9205288", "interface_id": "d3817524-dd33-4769-90ef-c9f070c9ac6f"}], "created_at": "2025-12-15T22:33:02.531398Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.531398Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "fd07d5ea-d897-46cd-9711-cf0c8f8f64a0", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "2ec84b65-eece-46cc-a889-fb46680160e9", "bindings": [{"id": "6d1b36ee-b14a-4143-80d3-bd1b00d8ae16", "type": "Port", "port_id": "abfc157a-360b-47c8-8285-3e519e63f4fc", "interface_id": "99cb4868-3cef-4d4a-a49e-2a80eee10739"}], "created_at": "2025-12-15T22:33:02.531403Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.531403Z", "virtualization": null, "service_definition": "Client"}, {"id": "6d76404d-6ce8-4801-b19a-ab6ebf2658e9", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-15T22:33:02.729781307Z", "type": "SelfReport", "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee"}]}, "host_id": "dc4fa852-bf64-4cbd-b1c6-bf7806fd1e81", "bindings": [{"id": "b8e1f7f4-eedf-4eb0-b0d0-479f7295903a", "type": "Port", "port_id": "ca44d2f2-5238-42ef-8d99-f56e84d03f03", "interface_id": "f31a0f82-ab45-432e-b0bc-7d25a0b5ad80"}], "created_at": "2025-12-15T22:33:02.729781Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:02.729781Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "8658f2f0-dc16-4625-a4b4-43e7505fad87", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:33:48.011699594Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "d3d4dab4-5b25-4168-ba67-c59ec9595549", "bindings": [{"id": "4f1d60cb-ef44-42c5-99f0-3b5223e976f4", "type": "Port", "port_id": "39f2e4ad-a8f6-4633-ae7b-81465cee6d4e", "interface_id": "68fbe1d1-5b2b-44a0-9065-8e4dcdd257aa"}], "created_at": "2025-12-15T22:33:48.011716Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:48.011716Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "5b70cbe4-e59a-474e-83fb-961fd5c93c14", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:33:54.804747022Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "cab802e6-598f-429d-bf9a-f2f59052a5ef", "bindings": [{"id": "a2096e4b-fa2d-4d6a-8759-17589204ec77", "type": "Port", "port_id": "5f597889-5fc7-4fcb-b692-09eba3c9193f", "interface_id": "9862e028-a300-4dbd-8f4f-4f366557149b"}], "created_at": "2025-12-15T22:33:54.804767Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:33:54.804767Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "8182ca12-3d4e-4cad-b51c-d429ecb54fed", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:18.153989138Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "27370877-3832-4531-8f9b-5fd8c8045f2f", "bindings": [{"id": "3f156ff6-5f71-422e-ba88-84563b90dd96", "type": "Port", "port_id": "fc5e06bb-5e29-4516-867d-bbaa5db85777", "interface_id": "8a4cdda3-df7c-455a-b9e9-281616d85e67"}, {"id": "7b3ef440-86c1-4a94-ad9d-16d3a3c78b8f", "type": "Port", "port_id": "d5839ed8-2448-4796-bdd0-d74782755daf", "interface_id": "8a4cdda3-df7c-455a-b9e9-281616d85e67"}], "created_at": "2025-12-15T22:34:18.154010Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:18.154010Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "1e7d650e-28c4-4519-9f26-d004e29cd98b", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:34:26.780830877Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "4f3bd74e-4373-46bc-8fb4-6a53b757a94b", "bindings": [{"id": "3ec226b0-e6c2-4667-b05a-fd7e9f21c313", "type": "Port", "port_id": "ff3d3e0b-01c2-41da-9275-aac905667f1e", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}], "created_at": "2025-12-15T22:34:26.780847Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:26.780847Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "04521006-01d4-41f8-9d35-e12f93e2124f", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-15T22:34:29.057522491Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "4f3bd74e-4373-46bc-8fb4-6a53b757a94b", "bindings": [{"id": "2c64ae8d-c607-4aa6-8bd3-de2bc512b349", "type": "Port", "port_id": "1e57859c-1b3c-4d93-ad94-45ad6713fd97", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}], "created_at": "2025-12-15T22:34:29.057542Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:29.057542Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "4bf27622-4cb1-4696-8bdf-cebcc397b2aa", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:37.358419148Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "4f3bd74e-4373-46bc-8fb4-6a53b757a94b", "bindings": [{"id": "5f01579b-34ca-4a5e-8431-b4e1103ee093", "type": "Port", "port_id": "4606c6da-82db-43d8-9f1e-060537048a19", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}], "created_at": "2025-12-15T22:34:37.358436Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:37.358436Z", "virtualization": null, "service_definition": "SSH"}, {"id": "a199f2dc-9c30-4967-92f6-83419297d6eb", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-15T22:34:37.358974297Z", "type": "Network", "daemon_id": "b02b861a-35ed-4b3e-8586-6df4b7a268ee", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "4f3bd74e-4373-46bc-8fb4-6a53b757a94b", "bindings": [{"id": "bcc14725-f0e8-43cb-b984-828490959662", "type": "Port", "port_id": "91c6a118-0674-4f94-aed6-820c98a36f06", "interface_id": "c522a083-dfe8-4f42-8c33-55b27ca467e1"}], "created_at": "2025-12-15T22:34:37.358982Z", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:37.358982Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "67b5f468-0084-454b-8bcc-551a025d57ef", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-15T22:34:37.399143Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "0becc2bc-8583-4587-af55-6565cc3a4f51", "updated_at": "2025-12-15T22:34:37.399143Z", "description": null, "service_bindings": []}]	t	2025-12-15 22:33:02.556992+00	f	\N	\N	{464db83c-143c-4ced-8619-70856d4fdf78,1adf1ae4-3123-4fba-b10b-2ad342733652}	{de500400-ef57-47fa-8ad3-747e2de0289a}	{ca1c42e8-7f6c-4af2-8df3-38a12ae13a18}	{a4c3a70c-68f2-41b5-b3d2-1e88cd7beab4}	\N	2025-12-15 22:33:02.553541+00	2025-12-15 22:34:38.279411+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
10121d01-29d0-4843-8caf-930699bb1606	2025-12-15 22:33:02.526618+00	2025-12-15 22:33:02.526618+00	$argon2id$v=19$m=19456,t=2,p=1$9sw32Vb5VwOinD37K4SKzA$Y8nDF1AGBmD38GEICELc7IP4jvlvWkNWyzK5Q97mJe0	\N	\N	\N	user@gmail.com	8625779b-63c7-46ae-8367-9b34d64a20f0	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
26h6XMj_gJSkbdm93L2GcQ	\\x93c4107186bddcbdd96da49480ffc85c7aa8db81a7757365725f6964d92431303132316430312d323964302d343834332d386361662d39333036393962623136303699cd07ea0e162102ce27abd337000000	2026-01-14 22:33:02.665572+00
11fOi5IymREPRSv_P7-fCg	\\x93c4100a9fbf3fff2b450f119932928bce57d782ad70656e64696e675f736574757084aa6e6574776f726b5f6964d92434643534636236302d383030372d343566312d383461632d366662656634623837663964ac6e6574776f726b5f6e616d65aa4d79204e6574776f726ba86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92431303132316430312d323964302d343834332d386361662d39333036393962623136303699cd07ea0e162225ce3acde57b000000	2026-01-14 22:34:37.986572+00
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

\unrestrict fk5cAh2E9O7lnm9fOEclE50O6UGa3N3nKjuQgzJWEgOIpjL6HkfkEeYWBTRjVau

