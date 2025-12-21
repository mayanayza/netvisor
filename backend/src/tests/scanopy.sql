--
-- PostgreSQL database dump
--

\restrict xy7c7rqGbk80TlESSyKCP8dUk26Co21OHHtXfcOiVf5kxHsTeySd3v3hydjq2RH

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
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_topology_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_organization_id_fkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_created_by_fkey;
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
DROP INDEX IF EXISTS public.idx_shares_topology;
DROP INDEX IF EXISTS public.idx_shares_network;
DROP INDEX IF EXISTS public.idx_shares_enabled;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_organizations_stripe_customer;
DROP INDEX IF EXISTS public.idx_networks_owner_organization;
DROP INDEX IF EXISTS public.idx_invites_organization;
DROP INDEX IF EXISTS public.idx_invites_expires_at;
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
ALTER TABLE IF EXISTS ONLY public.shares DROP CONSTRAINT IF EXISTS shares_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.organizations DROP CONSTRAINT IF EXISTS organizations_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.invites DROP CONSTRAINT IF EXISTS invites_pkey;
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
DROP TABLE IF EXISTS public.shares;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.organizations;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.invites;
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
-- Name: invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invites (
    id uuid NOT NULL,
    organization_id uuid NOT NULL,
    permissions text NOT NULL,
    network_ids uuid[] NOT NULL,
    url text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    send_to text
);


ALTER TABLE public.invites OWNER TO postgres;

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
-- Name: shares; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shares (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    topology_id uuid NOT NULL,
    network_id uuid NOT NULL,
    created_by uuid NOT NULL,
    share_type text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    password_hash text,
    has_password boolean,
    allowed_domains text[],
    embed_options jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shares OWNER TO postgres;

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
20251006215000	users	2025-12-21 03:37:05.475864+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3512707
20251006215100	networks	2025-12-21 03:37:05.48047+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4781004
20251006215151	create hosts	2025-12-21 03:37:05.485587+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3918574
20251006215155	create subnets	2025-12-21 03:37:05.489933+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3878750
20251006215201	create groups	2025-12-21 03:37:05.494169+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4108825
20251006215204	create daemons	2025-12-21 03:37:05.498655+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4149045
20251006215212	create services	2025-12-21 03:37:05.503159+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4775284
20251029193448	user-auth	2025-12-21 03:37:05.508259+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5932131
20251030044828	daemon api	2025-12-21 03:37:05.514503+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1531549
20251030170438	host-hide	2025-12-21 03:37:05.516309+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1163772
20251102224919	create discovery	2025-12-21 03:37:05.517773+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10741841
20251106235621	normalize-daemon-cols	2025-12-21 03:37:05.531289+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1757541
20251107034459	api keys	2025-12-21 03:37:05.533348+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8257363
20251107222650	oidc-auth	2025-12-21 03:37:05.541935+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26053292
20251110181948	orgs-billing	2025-12-21 03:37:05.568298+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11549729
20251113223656	group-enhancements	2025-12-21 03:37:05.580199+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1029070
20251117032720	daemon-mode	2025-12-21 03:37:05.581553+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1204699
20251118143058	set-default-plan	2025-12-21 03:37:05.583079+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1196012
20251118225043	save-topology	2025-12-21 03:37:05.584579+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8791721
20251123232748	network-permissions	2025-12-21 03:37:05.593711+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2651068
20251125001342	billing-updates	2025-12-21 03:37:05.596697+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	932351
20251128035448	org-onboarding-status	2025-12-21 03:37:05.597907+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1449786
20251129180942	nfs-consolidate	2025-12-21 03:37:05.599665+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1192156
20251206052641	discovery-progress	2025-12-21 03:37:05.601135+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1588606
20251206202200	plan-fix	2025-12-21 03:37:05.603008+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	912754
20251207061341	daemon-url	2025-12-21 03:37:05.604236+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2420658
20251210045929	tags	2025-12-21 03:37:05.606947+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8641922
20251210175035	terms	2025-12-21 03:37:05.615948+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	900802
20251213025048	hash-keys	2025-12-21 03:37:05.617148+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9856548
20251214050638	scanopy	2025-12-21 03:37:05.62731+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1399783
20251215215724	topo-scanopy-fix	2025-12-21 03:37:05.629005+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	763996
20251217153736	category rename	2025-12-21 03:37:05.630068+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1679184
20251218053111	invite-persistence	2025-12-21 03:37:05.632044+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5119716
20251219211216	create shares	2025-12-21 03:37:05.637502+00	t	\\x1ea2a7fde07002f2b4f1742c761619edad3b5b439dbb1c746b8dabed29a0e9ba1b8c057c742b9f49614eba2ccfacd531	6753556
20251220170928	permissions-cleanup	2025-12-21 03:37:05.644605+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1468772
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
418255eb-4ce3-47bb-93fd-4981519318f0	9db8f2cfe9ff17d4ab21e29b1d91e2bbb3240c20d3a7ebfa431af07b85138994	4abf774f-b262-4167-be6d-6a791d8933f6	Integrated Daemon API Key	2025-12-21 03:37:07.757989+00	2025-12-21 03:38:45.729144+00	2025-12-21 03:38:45.728191+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
afc4f325-67cc-4cb0-8b5e-e8d860b3deae	4abf774f-b262-4167-be6d-6a791d8933f6	8705c1f7-3929-4093-aaa5-17231893d815	2025-12-21 03:37:07.773085+00	2025-12-21 03:38:22.579642+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["e112d999-dbd8-4650-97dd-aca4898fc104"]}	2025-12-21 03:38:22.580234+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
97d65c31-221b-4e4a-ba49-0598222e52e6	4abf774f-b262-4167-be6d-6a791d8933f6	afc4f325-67cc-4cb0-8b5e-e8d860b3deae	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815"}	Self Report	2025-12-21 03:37:07.779387+00	2025-12-21 03:37:07.779387+00	{}
6d8d1db2-9641-4795-bed0-9f39dd0d7c21	4abf774f-b262-4167-be6d-6a791d8933f6	afc4f325-67cc-4cb0-8b5e-e8d860b3deae	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 03:37:07.786149+00	2025-12-21 03:37:07.786149+00	{}
627d0159-9579-45d3-b009-0cb7c516bca0	4abf774f-b262-4167-be6d-6a791d8933f6	afc4f325-67cc-4cb0-8b5e-e8d860b3deae	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "session_id": "6bd5d351-a23a-4370-91e3-93ca44c3a3e9", "started_at": "2025-12-21T03:37:07.785577950Z", "finished_at": "2025-12-21T03:37:07.934673986Z", "discovery_type": {"type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815"}}}	{"type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815"}	Self Report	2025-12-21 03:37:07.785577+00	2025-12-21 03:37:07.937815+00	{}
1da7acea-c7bd-4fe2-99f4-03349b8b9e62	4abf774f-b262-4167-be6d-6a791d8933f6	afc4f325-67cc-4cb0-8b5e-e8d860b3deae	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "session_id": "70208604-cd7d-40f8-8981-5eb33b69deaf", "started_at": "2025-12-21T03:37:07.950994301Z", "finished_at": "2025-12-21T03:38:45.726043659Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 03:37:07.950994+00	2025-12-21 03:38:45.728473+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
b04183a1-5ace-4385-a7b9-4a4da7bf7742	4abf774f-b262-4167-be6d-6a791d8933f6		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 03:38:45.742217+00	2025-12-21 03:38:45.742217+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
440cdeae-a1a2-43ef-9f7c-368f25a71a13	4abf774f-b262-4167-be6d-6a791d8933f6	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "08aa7cab-6863-414f-9284-3add9265fbf8"}	[{"id": "0f67d5fd-fbe1-4556-a401-814ae675ea10", "name": "Internet", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "ip_address": "1.1.1.1", "mac_address": null}]	{d14eb9cd-ecea-4392-ae43-a06f8cf03c30}	[{"id": "969c8001-281b-454d-a8ee-76baab7e8478", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 03:37:07.683235+00	2025-12-21 03:37:07.694815+00	f	{}
68c1834c-21c6-4691-8ff7-8690730eb8d5	4abf774f-b262-4167-be6d-6a791d8933f6	Google.com	\N	\N	{"type": "ServiceBinding", "config": "6584cb30-bd58-497f-a878-b27907cbe0f0"}	[{"id": "449af1b0-ea49-4e36-a52f-f9a2c544a077", "name": "Internet", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "ip_address": "203.0.113.109", "mac_address": null}]	{8cb835dc-9493-4636-8392-e2536f12696c}	[{"id": "d9189340-1d72-4d80-b8e6-448b7b3a08fa", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 03:37:07.683241+00	2025-12-21 03:37:07.745539+00	f	{}
233006f8-fadf-45b4-8f2c-21c52ab2a405	4abf774f-b262-4167-be6d-6a791d8933f6	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "2e7f21fa-e95c-4524-a033-76b19e5df6b0"}	[{"id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d", "name": "Remote Network", "subnet_id": "a4a3acf4-1a47-4a29-b874-378c1e7b44d5", "ip_address": "203.0.113.7", "mac_address": null}]	{88cbbc98-90e9-4e7f-9cdf-e73d2a4e8f0f}	[{"id": "b513471c-976a-4b18-9430-b895ea09159a", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 03:37:07.683252+00	2025-12-21 03:37:07.749858+00	f	{}
9c6eaa43-b3ca-41a4-9ed0-af2a7d892689	4abf774f-b262-4167-be6d-6a791d8933f6	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "35007d92-0112-4511-bca6-67e4f82f86ee", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.5", "mac_address": "62:56:F9:B7:2A:51"}]	{f31a1517-2bf7-4829-bdc1-2c997152abb2,d71e72d0-2b75-462c-ae12-9a9db821fc55}	[{"id": "98442ba9-358d-460e-9017-8b4b5101a602", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "302ca4d6-27e8-4f40-bb03-80eb9d9d640d", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:56.340463182Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 03:37:56.340467+00	2025-12-21 03:38:11.823902+00	f	{}
8705c1f7-3929-4093-aaa5-17231893d815	4abf774f-b262-4167-be6d-6a791d8933f6	scanopy-daemon	54d353e18c13	Scanopy daemon	{"type": "None"}	[{"id": "9a330846-54df-4d9d-a86c-a1d4b04b7e46", "name": "eth0", "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.4", "mac_address": "BA:8E:87:D1:C8:0C"}]	{580c8fe0-fb0b-40a1-b830-2ad564a41e11}	[{"id": "e971252d-fef5-441e-8bdb-6bb687030db7", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:07.915475400Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}	null	2025-12-21 03:37:07.769349+00	2025-12-21 03:37:07.930667+00	f	{}
b3ade007-8bd1-49f8-8335-41200f31157e	4abf774f-b262-4167-be6d-6a791d8933f6	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "f14becfa-4384-45f6-8c60-68e27df968a6", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.6", "mac_address": "B2:FC:F3:EF:E0:18"}]	{f035d973-6b1d-48ba-83ea-304f11585844}	[{"id": "5a100584-39b9-4eef-9690-cad49a52fed9", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:40.758807927Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 03:37:40.758811+00	2025-12-21 03:37:56.252686+00	f	{}
f080df34-a860-4f84-8e47-1c5d2f3caed5	4abf774f-b262-4167-be6d-6a791d8933f6	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "9a269abb-fecf-4799-bcd6-fedf247599e4", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.3", "mac_address": "0E:14:18:92:E5:2D"}]	{10c3c3e1-2ab7-4a20-9332-34063a72955d}	[{"id": "61181136-ec2d-467d-86a5-7f7762a9fa54", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:38:11.815052202Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 03:38:11.815055+00	2025-12-21 03:38:27.013307+00	f	{}
da91f9cd-1745-42c9-aa72-e7e1c8c8a761	4abf774f-b262-4167-be6d-6a791d8933f6	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "641b3a05-0378-455e-aabf-65a77f1ac03a", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.1", "mac_address": "4A:1D:9C:7D:AC:80"}]	{89224db6-fe3b-406a-9567-49e1944dd831,ee53cb31-5fbe-493e-95c9-833958e2227d,de31e827-f25e-4a65-a6c0-9f3b179ff444,6516c716-af9e-4f8a-a42b-ced8689242b1}	[{"id": "20e5d012-b9a0-402d-97a5-5dcfd6eb2f26", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "9efe8bc4-48a8-4d24-ae38-4edbfc38e52a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6a32eade-8eea-4cc1-9e54-8c27713eacc1", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "4ce3e8de-be97-4c59-a804-051523284a3c", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:38:31.063691518Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 03:38:31.063694+00	2025-12-21 03:38:45.720753+00	f	{}
\.


--
-- Data for Name: invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invites (id, organization_id, permissions, network_ids, url, created_by, created_at, updated_at, expires_at, send_to) FROM stdin;
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id, tags) FROM stdin;
4abf774f-b262-4167-be6d-6a791d8933f6	My Network	2025-12-21 03:37:07.681731+00	2025-12-21 03:37:07.681731+00	f	a4d97203-c824-476b-a8d3-ab9074dce6f2	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
a4d97203-c824-476b-a8d3-ab9074dce6f2	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 03:37:07.673976+00	2025-12-21 03:38:46.57266+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
d14eb9cd-ecea-4392-ae43-a06f8cf03c30	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.683236+00	2025-12-21 03:37:07.683236+00	Cloudflare DNS	440cdeae-a1a2-43ef-9f7c-368f25a71a13	[{"id": "08aa7cab-6863-414f-9284-3add9265fbf8", "type": "Port", "port_id": "969c8001-281b-454d-a8ee-76baab7e8478", "interface_id": "0f67d5fd-fbe1-4556-a401-814ae675ea10"}]	"Dns Server"	null	{"type": "System"}	{}
8cb835dc-9493-4636-8392-e2536f12696c	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.683243+00	2025-12-21 03:37:07.683243+00	Google.com	68c1834c-21c6-4691-8ff7-8690730eb8d5	[{"id": "6584cb30-bd58-497f-a878-b27907cbe0f0", "type": "Port", "port_id": "d9189340-1d72-4d80-b8e6-448b7b3a08fa", "interface_id": "449af1b0-ea49-4e36-a52f-f9a2c544a077"}]	"Web Service"	null	{"type": "System"}	{}
88cbbc98-90e9-4e7f-9cdf-e73d2a4e8f0f	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.683254+00	2025-12-21 03:37:07.683254+00	Mobile Device	233006f8-fadf-45b4-8f2c-21c52ab2a405	[{"id": "2e7f21fa-e95c-4524-a033-76b19e5df6b0", "type": "Port", "port_id": "b513471c-976a-4b18-9430-b895ea09159a", "interface_id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d"}]	"Client"	null	{"type": "System"}	{}
580c8fe0-fb0b-40a1-b830-2ad564a41e11	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.915494+00	2025-12-21 03:37:07.915494+00	Scanopy Daemon	8705c1f7-3929-4093-aaa5-17231893d815	[{"id": "fbb61ced-a0ec-4197-aed2-de1a9e09efa5", "type": "Port", "port_id": "e971252d-fef5-441e-8bdb-6bb687030db7", "interface_id": "9a330846-54df-4d9d-a86c-a1d4b04b7e46"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T03:37:07.915493544Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}	{}
f035d973-6b1d-48ba-83ea-304f11585844	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:56.231763+00	2025-12-21 03:37:56.231763+00	PostgreSQL	b3ade007-8bd1-49f8-8335-41200f31157e	[{"id": "8ea08802-09a2-4245-946f-7563a5263c58", "type": "Port", "port_id": "5a100584-39b9-4eef-9690-cad49a52fed9", "interface_id": "f14becfa-4384-45f6-8c60-68e27df968a6"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:37:56.231745490Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f31a1517-2bf7-4829-bdc1-2c997152abb2	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:09.482651+00	2025-12-21 03:38:09.482651+00	Home Assistant	9c6eaa43-b3ca-41a4-9ed0-af2a7d892689	[{"id": "358b732d-dc96-488c-bec9-beb8f2939320", "type": "Port", "port_id": "98442ba9-358d-460e-9017-8b4b5101a602", "interface_id": "35007d92-0112-4511-bca6-67e4f82f86ee"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:09.482632440Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d71e72d0-2b75-462c-ae12-9a9db821fc55	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:11.807932+00	2025-12-21 03:38:11.807932+00	Unclaimed Open Ports	9c6eaa43-b3ca-41a4-9ed0-af2a7d892689	[{"id": "b9aadfde-8457-4965-93cc-ced206533b7d", "type": "Port", "port_id": "302ca4d6-27e8-4f40-bb03-80eb9d9d640d", "interface_id": "35007d92-0112-4511-bca6-67e4f82f86ee"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:11.807913060Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
10c3c3e1-2ab7-4a20-9332-34063a72955d	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:27.003283+00	2025-12-21 03:38:27.003283+00	Unclaimed Open Ports	f080df34-a860-4f84-8e47-1c5d2f3caed5	[{"id": "5204bb69-ec94-423e-94a4-31f6deecc51a", "type": "Port", "port_id": "61181136-ec2d-467d-86a5-7f7762a9fa54", "interface_id": "9a269abb-fecf-4799-bcd6-fedf247599e4"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:27.003268565Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6516c716-af9e-4f8a-a42b-ced8689242b1	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:45.708764+00	2025-12-21 03:38:45.708764+00	Unclaimed Open Ports	da91f9cd-1745-42c9-aa72-e7e1c8c8a761	[{"id": "49897143-5c0a-4dd1-951e-39486e278f16", "type": "Port", "port_id": "4ce3e8de-be97-4c59-a804-051523284a3c", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:45.708750177Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
89224db6-fe3b-406a-9567-49e1944dd831	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:42.061208+00	2025-12-21 03:38:42.061208+00	Scanopy Server	da91f9cd-1745-42c9-aa72-e7e1c8c8a761	[{"id": "2aea3fec-2d5f-425a-9ce1-3c7a6bb6c3f1", "type": "Port", "port_id": "20e5d012-b9a0-402d-97a5-5dcfd6eb2f26", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:42.061184661Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
ee53cb31-5fbe-493e-95c9-833958e2227d	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:43.555804+00	2025-12-21 03:38:43.555804+00	Home Assistant	da91f9cd-1745-42c9-aa72-e7e1c8c8a761	[{"id": "79467d84-5b0e-45b5-becb-520f2a14cf1c", "type": "Port", "port_id": "9efe8bc4-48a8-4d24-ae38-4edbfc38e52a", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:43.555783103Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
de31e827-f25e-4a65-a6c0-9f3b179ff444	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:38:45.708248+00	2025-12-21 03:38:45.708248+00	SSH	da91f9cd-1745-42c9-aa72-e7e1c8c8a761	[{"id": "4a6b61f1-1444-470c-ba12-725a794bec8f", "type": "Port", "port_id": "6a32eade-8eea-4cc1-9e54-8c27713eacc1", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:45.708231109Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, share_type, name, is_enabled, expires_at, password_hash, has_password, allowed_domains, embed_options, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
373bd710-9fb4-47c9-8f51-dd6fd110a076	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.683175+00	2025-12-21 03:37:07.683175+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
a4a3acf4-1a47-4a29-b874-378c1e7b44d5	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.683179+00	2025-12-21 03:37:07.683179+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
e112d999-dbd8-4650-97dd-aca4898fc104	4abf774f-b262-4167-be6d-6a791d8933f6	2025-12-21 03:37:07.78577+00	2025-12-21 03:37:07.78577+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:07.785768715Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
b45877b7-5399-47a5-97b5-e9e2a8b0b322	a4d97203-c824-476b-a8d3-ab9074dce6f2	New Tag	\N	2025-12-21 03:38:45.749084+00	2025-12-21 03:38:45.749084+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
2973ec81-070f-4af3-9e54-9c3b25405201	4abf774f-b262-4167-be6d-6a791d8933f6	My Topology	[]	[{"id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "a4a3acf4-1a47-4a29-b874-378c1e7b44d5", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "233006f8-fadf-45b4-8f2c-21c52ab2a405", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "a4a3acf4-1a47-4a29-b874-378c1e7b44d5", "interface_id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d"}, {"id": "0f67d5fd-fbe1-4556-a401-814ae675ea10", "size": {"x": 250, "y": 100}, "header": null, "host_id": "440cdeae-a1a2-43ef-9f7c-368f25a71a13", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "interface_id": "0f67d5fd-fbe1-4556-a401-814ae675ea10"}, {"id": "449af1b0-ea49-4e36-a52f-f9a2c544a077", "size": {"x": 250, "y": 100}, "header": null, "host_id": "68c1834c-21c6-4691-8ff7-8690730eb8d5", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "interface_id": "449af1b0-ea49-4e36-a52f-f9a2c544a077"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "440cdeae-a1a2-43ef-9f7c-368f25a71a13", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "969c8001-281b-454d-a8ee-76baab7e8478", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "08aa7cab-6863-414f-9284-3add9265fbf8"}, "hostname": null, "services": ["d14eb9cd-ecea-4392-ae43-a06f8cf03c30"], "created_at": "2025-12-21T03:37:07.683235Z", "interfaces": [{"id": "0f67d5fd-fbe1-4556-a401-814ae675ea10", "name": "Internet", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.694815Z", "description": null, "virtualization": null}, {"id": "68c1834c-21c6-4691-8ff7-8690730eb8d5", "name": "Google.com", "tags": [], "ports": [{"id": "d9189340-1d72-4d80-b8e6-448b7b3a08fa", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "6584cb30-bd58-497f-a878-b27907cbe0f0"}, "hostname": null, "services": ["8cb835dc-9493-4636-8392-e2536f12696c"], "created_at": "2025-12-21T03:37:07.683241Z", "interfaces": [{"id": "449af1b0-ea49-4e36-a52f-f9a2c544a077", "name": "Internet", "subnet_id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "ip_address": "203.0.113.109", "mac_address": null}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.745539Z", "description": null, "virtualization": null}, {"id": "233006f8-fadf-45b4-8f2c-21c52ab2a405", "name": "Mobile Device", "tags": [], "ports": [{"id": "b513471c-976a-4b18-9430-b895ea09159a", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "2e7f21fa-e95c-4524-a033-76b19e5df6b0"}, "hostname": null, "services": ["88cbbc98-90e9-4e7f-9cdf-e73d2a4e8f0f"], "created_at": "2025-12-21T03:37:07.683252Z", "interfaces": [{"id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d", "name": "Remote Network", "subnet_id": "a4a3acf4-1a47-4a29-b874-378c1e7b44d5", "ip_address": "203.0.113.7", "mac_address": null}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.749858Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "8705c1f7-3929-4093-aaa5-17231893d815", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "e971252d-fef5-441e-8bdb-6bb687030db7", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:07.915475400Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}, "target": {"type": "None"}, "hostname": "54d353e18c13", "services": ["580c8fe0-fb0b-40a1-b830-2ad564a41e11"], "created_at": "2025-12-21T03:37:07.769349Z", "interfaces": [{"id": "9a330846-54df-4d9d-a86c-a1d4b04b7e46", "name": "eth0", "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.4", "mac_address": "BA:8E:87:D1:C8:0C"}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.930667Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "b3ade007-8bd1-49f8-8335-41200f31157e", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "5a100584-39b9-4eef-9690-cad49a52fed9", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:40.758807927Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["f035d973-6b1d-48ba-83ea-304f11585844"], "created_at": "2025-12-21T03:37:40.758811Z", "interfaces": [{"id": "f14becfa-4384-45f6-8c60-68e27df968a6", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.6", "mac_address": "B2:FC:F3:EF:E0:18"}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:56.252686Z", "description": null, "virtualization": null}, {"id": "9c6eaa43-b3ca-41a4-9ed0-af2a7d892689", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "98442ba9-358d-460e-9017-8b4b5101a602", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "302ca4d6-27e8-4f40-bb03-80eb9d9d640d", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:56.340463182Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["f31a1517-2bf7-4829-bdc1-2c997152abb2", "d71e72d0-2b75-462c-ae12-9a9db821fc55"], "created_at": "2025-12-21T03:37:56.340467Z", "interfaces": [{"id": "35007d92-0112-4511-bca6-67e4f82f86ee", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.5", "mac_address": "62:56:F9:B7:2A:51"}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:11.823902Z", "description": null, "virtualization": null}, {"id": "f080df34-a860-4f84-8e47-1c5d2f3caed5", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "61181136-ec2d-467d-86a5-7f7762a9fa54", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:38:11.815052202Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["10c3c3e1-2ab7-4a20-9332-34063a72955d"], "created_at": "2025-12-21T03:38:11.815055Z", "interfaces": [{"id": "9a269abb-fecf-4799-bcd6-fedf247599e4", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.3", "mac_address": "0E:14:18:92:E5:2D"}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:27.013307Z", "description": null, "virtualization": null}, {"id": "da91f9cd-1745-42c9-aa72-e7e1c8c8a761", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "20e5d012-b9a0-402d-97a5-5dcfd6eb2f26", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "9efe8bc4-48a8-4d24-ae38-4edbfc38e52a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "6a32eade-8eea-4cc1-9e54-8c27713eacc1", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "4ce3e8de-be97-4c59-a804-051523284a3c", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:38:31.063691518Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["89224db6-fe3b-406a-9567-49e1944dd831", "ee53cb31-5fbe-493e-95c9-833958e2227d", "de31e827-f25e-4a65-a6c0-9f3b179ff444", "6516c716-af9e-4f8a-a42b-ced8689242b1"], "created_at": "2025-12-21T03:38:31.063694Z", "interfaces": [{"id": "641b3a05-0378-455e-aabf-65a77f1ac03a", "name": null, "subnet_id": "e112d999-dbd8-4650-97dd-aca4898fc104", "ip_address": "172.25.0.1", "mac_address": "4A:1D:9C:7D:AC:80"}], "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:45.720753Z", "description": null, "virtualization": null}]	[{"id": "373bd710-9fb4-47c9-8f51-dd6fd110a076", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T03:37:07.683175Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.683175Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "a4a3acf4-1a47-4a29-b874-378c1e7b44d5", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T03:37:07.683179Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.683179Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "e112d999-dbd8-4650-97dd-aca4898fc104", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T03:37:07.785768715Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}, "created_at": "2025-12-21T03:37:07.785770Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.785770Z", "description": null, "subnet_type": "Lan"}]	[{"id": "d14eb9cd-ecea-4392-ae43-a06f8cf03c30", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "440cdeae-a1a2-43ef-9f7c-368f25a71a13", "bindings": [{"id": "08aa7cab-6863-414f-9284-3add9265fbf8", "type": "Port", "port_id": "969c8001-281b-454d-a8ee-76baab7e8478", "interface_id": "0f67d5fd-fbe1-4556-a401-814ae675ea10"}], "created_at": "2025-12-21T03:37:07.683236Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.683236Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "8cb835dc-9493-4636-8392-e2536f12696c", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "68c1834c-21c6-4691-8ff7-8690730eb8d5", "bindings": [{"id": "6584cb30-bd58-497f-a878-b27907cbe0f0", "type": "Port", "port_id": "d9189340-1d72-4d80-b8e6-448b7b3a08fa", "interface_id": "449af1b0-ea49-4e36-a52f-f9a2c544a077"}], "created_at": "2025-12-21T03:37:07.683243Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.683243Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "88cbbc98-90e9-4e7f-9cdf-e73d2a4e8f0f", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "233006f8-fadf-45b4-8f2c-21c52ab2a405", "bindings": [{"id": "2e7f21fa-e95c-4524-a033-76b19e5df6b0", "type": "Port", "port_id": "b513471c-976a-4b18-9430-b895ea09159a", "interface_id": "a7f77d5c-2958-4cea-a19d-ddfdd98f768d"}], "created_at": "2025-12-21T03:37:07.683254Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.683254Z", "virtualization": null, "service_definition": "Client"}, {"id": "580c8fe0-fb0b-40a1-b830-2ad564a41e11", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T03:37:07.915493544Z", "type": "SelfReport", "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae"}]}, "host_id": "8705c1f7-3929-4093-aaa5-17231893d815", "bindings": [{"id": "fbb61ced-a0ec-4197-aed2-de1a9e09efa5", "type": "Port", "port_id": "e971252d-fef5-441e-8bdb-6bb687030db7", "interface_id": "9a330846-54df-4d9d-a86c-a1d4b04b7e46"}], "created_at": "2025-12-21T03:37:07.915494Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:07.915494Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "f035d973-6b1d-48ba-83ea-304f11585844", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:37:56.231745490Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "b3ade007-8bd1-49f8-8335-41200f31157e", "bindings": [{"id": "8ea08802-09a2-4245-946f-7563a5263c58", "type": "Port", "port_id": "5a100584-39b9-4eef-9690-cad49a52fed9", "interface_id": "f14becfa-4384-45f6-8c60-68e27df968a6"}], "created_at": "2025-12-21T03:37:56.231763Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:37:56.231763Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "f31a1517-2bf7-4829-bdc1-2c997152abb2", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:09.482632440Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "9c6eaa43-b3ca-41a4-9ed0-af2a7d892689", "bindings": [{"id": "358b732d-dc96-488c-bec9-beb8f2939320", "type": "Port", "port_id": "98442ba9-358d-460e-9017-8b4b5101a602", "interface_id": "35007d92-0112-4511-bca6-67e4f82f86ee"}], "created_at": "2025-12-21T03:38:09.482651Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:09.482651Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "d71e72d0-2b75-462c-ae12-9a9db821fc55", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:11.807913060Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "9c6eaa43-b3ca-41a4-9ed0-af2a7d892689", "bindings": [{"id": "b9aadfde-8457-4965-93cc-ced206533b7d", "type": "Port", "port_id": "302ca4d6-27e8-4f40-bb03-80eb9d9d640d", "interface_id": "35007d92-0112-4511-bca6-67e4f82f86ee"}], "created_at": "2025-12-21T03:38:11.807932Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:11.807932Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "10c3c3e1-2ab7-4a20-9332-34063a72955d", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:27.003268565Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "f080df34-a860-4f84-8e47-1c5d2f3caed5", "bindings": [{"id": "5204bb69-ec94-423e-94a4-31f6deecc51a", "type": "Port", "port_id": "61181136-ec2d-467d-86a5-7f7762a9fa54", "interface_id": "9a269abb-fecf-4799-bcd6-fedf247599e4"}], "created_at": "2025-12-21T03:38:27.003283Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:27.003283Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "89224db6-fe3b-406a-9567-49e1944dd831", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:42.061184661Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "da91f9cd-1745-42c9-aa72-e7e1c8c8a761", "bindings": [{"id": "2aea3fec-2d5f-425a-9ce1-3c7a6bb6c3f1", "type": "Port", "port_id": "20e5d012-b9a0-402d-97a5-5dcfd6eb2f26", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}], "created_at": "2025-12-21T03:38:42.061208Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:42.061208Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "ee53cb31-5fbe-493e-95c9-833958e2227d", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T03:38:43.555783103Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "da91f9cd-1745-42c9-aa72-e7e1c8c8a761", "bindings": [{"id": "79467d84-5b0e-45b5-becb-520f2a14cf1c", "type": "Port", "port_id": "9efe8bc4-48a8-4d24-ae38-4edbfc38e52a", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}], "created_at": "2025-12-21T03:38:43.555804Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:43.555804Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "de31e827-f25e-4a65-a6c0-9f3b179ff444", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:45.708231109Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "da91f9cd-1745-42c9-aa72-e7e1c8c8a761", "bindings": [{"id": "4a6b61f1-1444-470c-ba12-725a794bec8f", "type": "Port", "port_id": "6a32eade-8eea-4cc1-9e54-8c27713eacc1", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}], "created_at": "2025-12-21T03:38:45.708248Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:45.708248Z", "virtualization": null, "service_definition": "SSH"}, {"id": "6516c716-af9e-4f8a-a42b-ced8689242b1", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T03:38:45.708750177Z", "type": "Network", "daemon_id": "afc4f325-67cc-4cb0-8b5e-e8d860b3deae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "da91f9cd-1745-42c9-aa72-e7e1c8c8a761", "bindings": [{"id": "49897143-5c0a-4dd1-951e-39486e278f16", "type": "Port", "port_id": "4ce3e8de-be97-4c59-a804-051523284a3c", "interface_id": "641b3a05-0378-455e-aabf-65a77f1ac03a"}], "created_at": "2025-12-21T03:38:45.708764Z", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:45.708764Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "b04183a1-5ace-4385-a7b9-4a4da7bf7742", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T03:38:45.742217Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "4abf774f-b262-4167-be6d-6a791d8933f6", "updated_at": "2025-12-21T03:38:45.742217Z", "description": null, "service_bindings": []}]	t	2025-12-21 03:37:07.755382+00	f	\N	\N	{8d886e20-c11d-4345-8cee-8222c4424eb1,64cbd185-a17c-4005-91ff-29e73855a28b}	{a38b91d5-6fad-4e0e-95b4-0aea98ebf618}	{1df0e3ee-8b79-4a79-9efb-fea5bc155394}	{670312c0-7810-4ab1-9de8-2d6a1af9742b}	\N	2025-12-21 03:37:07.750598+00	2025-12-21 03:38:46.730038+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
32d2080f-97ee-4789-9287-da39bc4d94b7	2025-12-21 03:37:07.677173+00	2025-12-21 03:37:07.677173+00	$argon2id$v=19$m=19456,t=2,p=1$nkJF5AGQAyW1JGEhEp6Rug$fuRSxefYqa0mOtVTE42zK/M0gQg0Az5lc1i9JMKBN+U	\N	\N	\N	user@gmail.com	a4d97203-c824-476b-a8d3-ab9074dce6f2	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
hlogAbx26G_p__5V6GPsRA	\\x93c41044ec63e855feffe96fe876bc01205a8681a7757365725f6964d92433326432303830662d393765652d343738392d393238372d64613339626334643934623799cd07ea14032507ce2f4d32c3000000	2026-01-20 03:37:07.793588+00
zeeb7pHvpF5uFiVGGWfobw	\\x93c4106fe867194625166e5ea4ef91ee9be7cd82ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92463393430396666362d383638622d343337362d623134652d336331343333616163313839a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c3a7757365725f6964d92433326432303830662d393765652d343738392d393238372d64613339626334643934623799cd07ea1403262ece12b21b6b000000	2026-01-20 03:38:46.313662+00
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
-- Name: invites invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_pkey PRIMARY KEY (id);


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
-- Name: shares shares_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_pkey PRIMARY KEY (id);


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
-- Name: idx_invites_expires_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_expires_at ON public.invites USING btree (expires_at);


--
-- Name: idx_invites_organization; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_invites_organization ON public.invites USING btree (organization_id);


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
-- Name: idx_shares_enabled; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_enabled ON public.shares USING btree (is_enabled) WHERE (is_enabled = true);


--
-- Name: idx_shares_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_network ON public.shares USING btree (network_id);


--
-- Name: idx_shares_topology; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_shares_topology ON public.shares USING btree (topology_id);


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
-- Name: invites invites_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: invites invites_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invites
    ADD CONSTRAINT invites_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


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
-- Name: shares shares_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: shares shares_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


--
-- Name: shares shares_topology_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shares
    ADD CONSTRAINT shares_topology_id_fkey FOREIGN KEY (topology_id) REFERENCES public.topologies(id) ON DELETE CASCADE;


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

\unrestrict xy7c7rqGbk80TlESSyKCP8dUk26Co21OHHtXfcOiVf5kxHsTeySd3v3hydjq2RH

