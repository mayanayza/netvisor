--
-- PostgreSQL database dump
--

\restrict yhbCzAxLj19SN3PDE2Ge5CReBe30hGq1StW5v4b6UyHPqPit5ebABL7oY7A0ONo

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
20251006215000	users	2025-12-21 05:05:51.58887+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3506490
20251006215100	networks	2025-12-21 05:05:51.593355+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4299558
20251006215151	create hosts	2025-12-21 05:05:51.597983+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3782028
20251006215155	create subnets	2025-12-21 05:05:51.602094+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3677562
20251006215201	create groups	2025-12-21 05:05:51.60611+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4158078
20251006215204	create daemons	2025-12-21 05:05:51.61061+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4084659
20251006215212	create services	2025-12-21 05:05:51.615072+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4842756
20251029193448	user-auth	2025-12-21 05:05:51.620228+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5735800
20251030044828	daemon api	2025-12-21 05:05:51.626271+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1561657
20251030170438	host-hide	2025-12-21 05:05:51.628124+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1116636
20251102224919	create discovery	2025-12-21 05:05:51.629542+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10777268
20251106235621	normalize-daemon-cols	2025-12-21 05:05:51.640658+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1810633
20251107034459	api keys	2025-12-21 05:05:51.642806+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8197778
20251107222650	oidc-auth	2025-12-21 05:05:51.651342+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	25906935
20251110181948	orgs-billing	2025-12-21 05:05:51.677588+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	13027817
20251113223656	group-enhancements	2025-12-21 05:05:51.690976+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1094808
20251117032720	daemon-mode	2025-12-21 05:05:51.692377+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1154093
20251118143058	set-default-plan	2025-12-21 05:05:51.693866+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1201214
20251118225043	save-topology	2025-12-21 05:05:51.695367+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8824429
20251123232748	network-permissions	2025-12-21 05:05:51.704535+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2675183
20251125001342	billing-updates	2025-12-21 05:05:51.707518+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	988703
20251128035448	org-onboarding-status	2025-12-21 05:05:51.708803+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1448102
20251129180942	nfs-consolidate	2025-12-21 05:05:51.710539+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1185432
20251206052641	discovery-progress	2025-12-21 05:05:51.712041+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1571105
20251206202200	plan-fix	2025-12-21 05:05:51.713928+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	925525
20251207061341	daemon-url	2025-12-21 05:05:51.715154+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2422801
20251210045929	tags	2025-12-21 05:05:51.717877+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8567952
20251210175035	terms	2025-12-21 05:05:51.7268+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	877564
20251213025048	hash-keys	2025-12-21 05:05:51.728009+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9333664
20251214050638	scanopy	2025-12-21 05:05:51.737652+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1372262
20251215215724	topo-scanopy-fix	2025-12-21 05:05:51.739349+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	828668
20251217153736	category rename	2025-12-21 05:05:51.740516+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1717178
20251218053111	invite-persistence	2025-12-21 05:05:51.742528+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5174019
20251219211216	create shares	2025-12-21 05:05:51.748095+00	t	\\x1ea2a7fde07002f2b4f1742c761619edad3b5b439dbb1c746b8dabed29a0e9ba1b8c057c742b9f49614eba2ccfacd531	6692122
20251220170928	permissions-cleanup	2025-12-21 05:05:51.755142+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1549953
20251220180000	commercial-to-community	2025-12-21 05:05:51.757001+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	837632
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
e4a00450-b131-4dc4-8ad6-4b514a59212a	d879b98e0adbde4833ca476b7d88b838d6fa0043311ffd70b5db58c69edaad92	d4a29d21-3c54-4539-a518-b57578ec16aa	Integrated Daemon API Key	2025-12-21 05:05:54.760219+00	2025-12-21 05:07:33.488771+00	2025-12-21 05:07:33.48794+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
3bbfbd10-4f13-4b45-8e79-bed5863f7c3a	d4a29d21-3c54-4539-a518-b57578ec16aa	ead1807d-af0f-4bda-87c5-572b80e3ffe3	2025-12-21 05:05:54.879538+00	2025-12-21 05:07:11.760538+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["570090bc-2d00-4896-a23a-60a874e0774e"]}	2025-12-21 05:07:11.761118+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
9751f8ea-e3c2-4894-8aeb-10a54ee1f79f	d4a29d21-3c54-4539-a518-b57578ec16aa	3bbfbd10-4f13-4b45-8e79-bed5863f7c3a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3"}	Self Report	2025-12-21 05:05:54.889254+00	2025-12-21 05:05:54.889254+00	{}
24911c6d-606d-4df3-8ffd-561e02e49e8e	d4a29d21-3c54-4539-a518-b57578ec16aa	3bbfbd10-4f13-4b45-8e79-bed5863f7c3a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 05:05:54.897937+00	2025-12-21 05:05:54.897937+00	{}
075f797a-712b-4b2a-8839-9ab291df1f4e	d4a29d21-3c54-4539-a518-b57578ec16aa	3bbfbd10-4f13-4b45-8e79-bed5863f7c3a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "session_id": "ca0c57bd-8736-4269-b02f-ed70ad85c2ad", "started_at": "2025-12-21T05:05:54.897441184Z", "finished_at": "2025-12-21T05:05:54.934836613Z", "discovery_type": {"type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3"}}}	{"type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3"}	Self Report	2025-12-21 05:05:54.897441+00	2025-12-21 05:05:54.938083+00	{}
782f16bc-1891-4963-963f-1454ba719647	d4a29d21-3c54-4539-a518-b57578ec16aa	3bbfbd10-4f13-4b45-8e79-bed5863f7c3a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "session_id": "46515fad-2779-4ab5-ae26-7e41a60503e0", "started_at": "2025-12-21T05:05:54.949056572Z", "finished_at": "2025-12-21T05:07:33.486027601Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 05:05:54.949056+00	2025-12-21 05:07:33.488182+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
f75b79e2-4fa1-49ef-8354-91f776ef60ff	d4a29d21-3c54-4539-a518-b57578ec16aa		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 05:07:33.50126+00	2025-12-21 05:07:33.50126+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
0e492d00-bc86-458d-8981-35b0aa4074be	d4a29d21-3c54-4539-a518-b57578ec16aa	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "aa005191-5af2-453e-bd6a-fd63e5fb69a9"}	[{"id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb", "name": "Internet", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "ip_address": "1.1.1.1", "mac_address": null}]	{81fc5fa4-cfcd-4db2-a987-5ccd8df8edc6}	[{"id": "9c0e913d-2199-4274-9f9a-8b5c62d2e7f8", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 05:05:54.734141+00	2025-12-21 05:05:54.744417+00	f	{}
c73f4077-2925-4863-ba89-d0cf0ee48998	d4a29d21-3c54-4539-a518-b57578ec16aa	Google.com	\N	\N	{"type": "ServiceBinding", "config": "0a76a413-2d17-49fd-8522-dcaf7bf679a5"}	[{"id": "db102b9a-9759-4287-b9b9-30904ec36dc7", "name": "Internet", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "ip_address": "203.0.113.116", "mac_address": null}]	{fb614ce2-0f0c-415a-a04a-b98c3171f75f}	[{"id": "b57b7bf2-529f-41d0-b6fe-a92e8675fa2f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 05:05:54.734151+00	2025-12-21 05:05:54.748778+00	f	{}
4d4de606-20f1-4938-86ba-3bdb30cbde14	d4a29d21-3c54-4539-a518-b57578ec16aa	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "47203003-139e-4ff6-9de2-3e588e8955f7"}	[{"id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458", "name": "Remote Network", "subnet_id": "f5be8913-24a9-42f1-9213-a7d557db2154", "ip_address": "203.0.113.150", "mac_address": null}]	{88ab3615-3b4f-4b99-bb71-4832b7a3ce52}	[{"id": "180610c4-d08d-4a2c-8bb3-779083930901", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 05:05:54.734159+00	2025-12-21 05:05:54.752961+00	f	{}
864dcd64-c584-4bb9-b463-78db7578ee54	d4a29d21-3c54-4539-a518-b57578ec16aa	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "88561895-5357-463c-8574-6ec97d1c40a2", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.5", "mac_address": "2A:3D:98:0F:A6:36"}]	{9c132aea-7f79-4337-916a-29e74e358284,0272d8df-979b-4423-83d8-905509c95720}	[{"id": "7b866f21-ac81-4408-bedd-486b56480012", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "0511dfa3-50ee-4056-9619-0a475076ec2f", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:42.584115239Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:06:42.584119+00	2025-12-21 05:06:57.734339+00	f	{}
ead1807d-af0f-4bda-87c5-572b80e3ffe3	d4a29d21-3c54-4539-a518-b57578ec16aa	scanopy-daemon	c02daaa1645b	Scanopy daemon	{"type": "None"}	[{"id": "fa28f655-45f7-49ea-b680-db0c278bc147", "name": "eth0", "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.4", "mac_address": "16:06:04:12:CB:C8"}]	{5eb0a056-d474-49fd-a466-ef9fc828a0dd}	[{"id": "cf91c376-65d6-4b7d-856b-3f4e0b7e0e58", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:05:54.918753011Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}	null	2025-12-21 05:05:54.806137+00	2025-12-21 05:05:54.931968+00	f	{}
2017b95a-77da-4d99-a859-c28f67205dcc	d4a29d21-3c54-4539-a518-b57578ec16aa	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "544501ce-f1f7-4bed-ae03-c8e6e146e3f6", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.6", "mac_address": "2E:85:A7:20:8D:37"}]	{431a12c0-8093-4050-9d0b-762bc178eefe}	[{"id": "a59ca28d-a975-45df-9ddf-59c7b4b98ae9", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:27.353118075Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:06:27.353121+00	2025-12-21 05:06:42.498698+00	f	{}
370871ab-d7ed-4243-85a1-9004179bb5fb	d4a29d21-3c54-4539-a518-b57578ec16aa	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "69b438b1-3ebc-457c-8519-14fc0fa40c40", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.3", "mac_address": "C6:1D:05:9D:DE:FE"}]	{5061d906-abae-4d45-b83e-afa2c5d2a451}	[{"id": "f3b518f9-0a6e-466e-a593-26c7ceb1be0b", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:57.734477169Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:06:57.734479+00	2025-12-21 05:07:12.267589+00	f	{}
38153003-65fa-4537-a608-05125e6e2763	d4a29d21-3c54-4539-a518-b57578ec16aa	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "c0def101-50f6-4528-a6f8-c5afb6bb4701", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.1", "mac_address": "E6:54:E9:B4:44:68"}]	{e6d48df5-1f49-4bf9-a5f0-6a4e95085e2e,af602150-ef2e-45dc-a399-4243db5dfa4b,c0f6f3a7-e06c-4d6b-82ea-a50ffc4d37c7,325db5bc-dd13-4ca6-915f-04784e1f997b}	[{"id": "0abd3f5f-c56f-4627-a29d-e8394035f21a", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "88240eb6-4d48-40b5-a206-3e6e26161795", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5de01924-b407-4d6f-aaf2-2449e1856270", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "3199aac7-9c0c-4d93-8111-fe67e6870d39", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:07:18.359232158Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:07:18.359235+00	2025-12-21 05:07:33.48009+00	f	{}
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
d4a29d21-3c54-4539-a518-b57578ec16aa	My Network	2025-12-21 05:05:54.732697+00	2025-12-21 05:05:54.732697+00	f	5db01261-adc1-4b56-8beb-e0885bbc358a	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
5db01261-adc1-4b56-8beb-e0885bbc358a	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 05:05:54.725824+00	2025-12-21 05:07:34.345013+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
81fc5fa4-cfcd-4db2-a987-5ccd8df8edc6	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.734144+00	2025-12-21 05:05:54.734144+00	Cloudflare DNS	0e492d00-bc86-458d-8981-35b0aa4074be	[{"id": "aa005191-5af2-453e-bd6a-fd63e5fb69a9", "type": "Port", "port_id": "9c0e913d-2199-4274-9f9a-8b5c62d2e7f8", "interface_id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb"}]	"Dns Server"	null	{"type": "System"}	{}
fb614ce2-0f0c-415a-a04a-b98c3171f75f	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.734153+00	2025-12-21 05:05:54.734153+00	Google.com	c73f4077-2925-4863-ba89-d0cf0ee48998	[{"id": "0a76a413-2d17-49fd-8522-dcaf7bf679a5", "type": "Port", "port_id": "b57b7bf2-529f-41d0-b6fe-a92e8675fa2f", "interface_id": "db102b9a-9759-4287-b9b9-30904ec36dc7"}]	"Web Service"	null	{"type": "System"}	{}
88ab3615-3b4f-4b99-bb71-4832b7a3ce52	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.73416+00	2025-12-21 05:05:54.73416+00	Mobile Device	4d4de606-20f1-4938-86ba-3bdb30cbde14	[{"id": "47203003-139e-4ff6-9de2-3e588e8955f7", "type": "Port", "port_id": "180610c4-d08d-4a2c-8bb3-779083930901", "interface_id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458"}]	"Client"	null	{"type": "System"}	{}
5eb0a056-d474-49fd-a466-ef9fc828a0dd	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.91877+00	2025-12-21 05:05:54.91877+00	Scanopy Daemon	ead1807d-af0f-4bda-87c5-572b80e3ffe3	[{"id": "4cf46b7c-3b3c-41a6-b068-cf3ad917c45a", "type": "Port", "port_id": "cf91c376-65d6-4b7d-856b-3f4e0b7e0e58", "interface_id": "fa28f655-45f7-49ea-b680-db0c278bc147"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T05:05:54.918769181Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}	{}
431a12c0-8093-4050-9d0b-762bc178eefe	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:06:42.472762+00	2025-12-21 05:06:42.472762+00	PostgreSQL	2017b95a-77da-4d99-a859-c28f67205dcc	[{"id": "d302c23e-d632-471c-a1b2-97b01d916a15", "type": "Port", "port_id": "a59ca28d-a975-45df-9ddf-59c7b4b98ae9", "interface_id": "544501ce-f1f7-4bed-ae03-c8e6e146e3f6"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:06:42.472746396Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0272d8df-979b-4423-83d8-905509c95720	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:06:57.712048+00	2025-12-21 05:06:57.712048+00	Unclaimed Open Ports	864dcd64-c584-4bb9-b463-78db7578ee54	[{"id": "afb18266-0c70-4841-b8c0-c82fa8549ce7", "type": "Port", "port_id": "0511dfa3-50ee-4056-9619-0a475076ec2f", "interface_id": "88561895-5357-463c-8574-6ec97d1c40a2"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:06:57.712030163Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9c132aea-7f79-4337-916a-29e74e358284	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:06:55.449189+00	2025-12-21 05:06:55.449189+00	Home Assistant	864dcd64-c584-4bb9-b463-78db7578ee54	[{"id": "be8ec6d9-4f7c-451c-b4dd-350e55803b33", "type": "Port", "port_id": "7b866f21-ac81-4408-bedd-486b56480012", "interface_id": "88561895-5357-463c-8574-6ec97d1c40a2"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:06:55.449169840Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5061d906-abae-4d45-b83e-afa2c5d2a451	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:07:12.255898+00	2025-12-21 05:07:12.255898+00	Unclaimed Open Ports	370871ab-d7ed-4243-85a1-9004179bb5fb	[{"id": "a82fe9a8-fbf4-41a5-a18d-b46ccac39b6d", "type": "Port", "port_id": "f3b518f9-0a6e-466e-a593-26c7ceb1be0b", "interface_id": "69b438b1-3ebc-457c-8519-14fc0fa40c40"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:12.255878635Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
af602150-ef2e-45dc-a399-4243db5dfa4b	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:07:31.211549+00	2025-12-21 05:07:31.211549+00	Home Assistant	38153003-65fa-4537-a608-05125e6e2763	[{"id": "981fd437-76ac-42bb-b6c5-077bd67e248a", "type": "Port", "port_id": "88240eb6-4d48-40b5-a206-3e6e26161795", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:07:31.211530747Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e6d48df5-1f49-4bf9-a5f0-6a4e95085e2e	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:07:29.704892+00	2025-12-21 05:07:29.704892+00	Scanopy Server	38153003-65fa-4537-a608-05125e6e2763	[{"id": "c04e6dd4-8a0c-4264-ab02-074c8c8b88d1", "type": "Port", "port_id": "0abd3f5f-c56f-4627-a29d-e8394035f21a", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:07:29.704873697Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
325db5bc-dd13-4ca6-915f-04784e1f997b	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:07:33.467104+00	2025-12-21 05:07:33.467104+00	Unclaimed Open Ports	38153003-65fa-4537-a608-05125e6e2763	[{"id": "5af1e3e4-a2d5-4396-9cbc-c5bb1a33a77e", "type": "Port", "port_id": "3199aac7-9c0c-4d93-8111-fe67e6870d39", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:33.467095382Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c0f6f3a7-e06c-4d6b-82ea-a50ffc4d37c7	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:07:33.466574+00	2025-12-21 05:07:33.466574+00	SSH	38153003-65fa-4537-a608-05125e6e2763	[{"id": "c9eeee5e-3c9e-4324-be34-09e3fd8c2fc9", "type": "Port", "port_id": "5de01924-b407-4d6f-aaf2-2449e1856270", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:33.466555700Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
de33ff6c-d8a8-4aea-a246-4dfdb09d6094	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.734083+00	2025-12-21 05:05:54.734083+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
f5be8913-24a9-42f1-9213-a7d557db2154	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.734087+00	2025-12-21 05:05:54.734087+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
570090bc-2d00-4896-a23a-60a874e0774e	d4a29d21-3c54-4539-a518-b57578ec16aa	2025-12-21 05:05:54.897619+00	2025-12-21 05:05:54.897619+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:05:54.897617164Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
1d7b46a0-e642-487b-aabc-32983664a826	5db01261-adc1-4b56-8beb-e0885bbc358a	New Tag	\N	2025-12-21 05:07:33.509625+00	2025-12-21 05:07:33.509625+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
f77b9405-9d03-41f4-85f5-323c6b1bf6ab	d4a29d21-3c54-4539-a518-b57578ec16aa	My Topology	[]	[{"id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "f5be8913-24a9-42f1-9213-a7d557db2154", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0e492d00-bc86-458d-8981-35b0aa4074be", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "interface_id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb"}, {"id": "db102b9a-9759-4287-b9b9-30904ec36dc7", "size": {"x": 250, "y": 100}, "header": null, "host_id": "c73f4077-2925-4863-ba89-d0cf0ee48998", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "interface_id": "db102b9a-9759-4287-b9b9-30904ec36dc7"}, {"id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458", "size": {"x": 250, "y": 100}, "header": null, "host_id": "4d4de606-20f1-4938-86ba-3bdb30cbde14", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f5be8913-24a9-42f1-9213-a7d557db2154", "interface_id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "0e492d00-bc86-458d-8981-35b0aa4074be", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "9c0e913d-2199-4274-9f9a-8b5c62d2e7f8", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "aa005191-5af2-453e-bd6a-fd63e5fb69a9"}, "hostname": null, "services": ["81fc5fa4-cfcd-4db2-a987-5ccd8df8edc6"], "created_at": "2025-12-21T05:05:54.734141Z", "interfaces": [{"id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb", "name": "Internet", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.744417Z", "description": null, "virtualization": null}, {"id": "c73f4077-2925-4863-ba89-d0cf0ee48998", "name": "Google.com", "tags": [], "ports": [{"id": "b57b7bf2-529f-41d0-b6fe-a92e8675fa2f", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "0a76a413-2d17-49fd-8522-dcaf7bf679a5"}, "hostname": null, "services": ["fb614ce2-0f0c-415a-a04a-b98c3171f75f"], "created_at": "2025-12-21T05:05:54.734151Z", "interfaces": [{"id": "db102b9a-9759-4287-b9b9-30904ec36dc7", "name": "Internet", "subnet_id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "ip_address": "203.0.113.116", "mac_address": null}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.748778Z", "description": null, "virtualization": null}, {"id": "4d4de606-20f1-4938-86ba-3bdb30cbde14", "name": "Mobile Device", "tags": [], "ports": [{"id": "180610c4-d08d-4a2c-8bb3-779083930901", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "47203003-139e-4ff6-9de2-3e588e8955f7"}, "hostname": null, "services": ["88ab3615-3b4f-4b99-bb71-4832b7a3ce52"], "created_at": "2025-12-21T05:05:54.734159Z", "interfaces": [{"id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458", "name": "Remote Network", "subnet_id": "f5be8913-24a9-42f1-9213-a7d557db2154", "ip_address": "203.0.113.150", "mac_address": null}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.752961Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "cf91c376-65d6-4b7d-856b-3f4e0b7e0e58", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:05:54.918753011Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}, "target": {"type": "None"}, "hostname": "c02daaa1645b", "services": ["5eb0a056-d474-49fd-a466-ef9fc828a0dd"], "created_at": "2025-12-21T05:05:54.806137Z", "interfaces": [{"id": "fa28f655-45f7-49ea-b680-db0c278bc147", "name": "eth0", "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.4", "mac_address": "16:06:04:12:CB:C8"}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.931968Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "2017b95a-77da-4d99-a859-c28f67205dcc", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "a59ca28d-a975-45df-9ddf-59c7b4b98ae9", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:27.353118075Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["431a12c0-8093-4050-9d0b-762bc178eefe"], "created_at": "2025-12-21T05:06:27.353121Z", "interfaces": [{"id": "544501ce-f1f7-4bed-ae03-c8e6e146e3f6", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.6", "mac_address": "2E:85:A7:20:8D:37"}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:06:42.498698Z", "description": null, "virtualization": null}, {"id": "864dcd64-c584-4bb9-b463-78db7578ee54", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "7b866f21-ac81-4408-bedd-486b56480012", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "0511dfa3-50ee-4056-9619-0a475076ec2f", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:42.584115239Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["9c132aea-7f79-4337-916a-29e74e358284", "0272d8df-979b-4423-83d8-905509c95720"], "created_at": "2025-12-21T05:06:42.584119Z", "interfaces": [{"id": "88561895-5357-463c-8574-6ec97d1c40a2", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.5", "mac_address": "2A:3D:98:0F:A6:36"}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:06:57.734339Z", "description": null, "virtualization": null}, {"id": "370871ab-d7ed-4243-85a1-9004179bb5fb", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "f3b518f9-0a6e-466e-a593-26c7ceb1be0b", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:06:57.734477169Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["5061d906-abae-4d45-b83e-afa2c5d2a451"], "created_at": "2025-12-21T05:06:57.734479Z", "interfaces": [{"id": "69b438b1-3ebc-457c-8519-14fc0fa40c40", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.3", "mac_address": "C6:1D:05:9D:DE:FE"}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:12.267589Z", "description": null, "virtualization": null}, {"id": "38153003-65fa-4537-a608-05125e6e2763", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "0abd3f5f-c56f-4627-a29d-e8394035f21a", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "88240eb6-4d48-40b5-a206-3e6e26161795", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5de01924-b407-4d6f-aaf2-2449e1856270", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "3199aac7-9c0c-4d93-8111-fe67e6870d39", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:07:18.359232158Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["e6d48df5-1f49-4bf9-a5f0-6a4e95085e2e", "af602150-ef2e-45dc-a399-4243db5dfa4b", "c0f6f3a7-e06c-4d6b-82ea-a50ffc4d37c7", "325db5bc-dd13-4ca6-915f-04784e1f997b"], "created_at": "2025-12-21T05:07:18.359235Z", "interfaces": [{"id": "c0def101-50f6-4528-a6f8-c5afb6bb4701", "name": null, "subnet_id": "570090bc-2d00-4896-a23a-60a874e0774e", "ip_address": "172.25.0.1", "mac_address": "E6:54:E9:B4:44:68"}], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:33.480090Z", "description": null, "virtualization": null}, {"id": "f9f94918-4c75-465e-beb0-4f9073b69f2b", "name": "Service Test Host", "tags": [], "ports": [], "hidden": false, "source": {"type": "System"}, "target": {"type": "Hostname"}, "hostname": "service-test.local", "services": [], "created_at": "2025-12-21T05:07:34.194913Z", "interfaces": [], "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:34.204676Z", "description": null, "virtualization": null}]	[{"id": "de33ff6c-d8a8-4aea-a246-4dfdb09d6094", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T05:05:54.734083Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.734083Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "f5be8913-24a9-42f1-9213-a7d557db2154", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T05:05:54.734087Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.734087Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "570090bc-2d00-4896-a23a-60a874e0774e", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:05:54.897617164Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}, "created_at": "2025-12-21T05:05:54.897619Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.897619Z", "description": null, "subnet_type": "Lan"}]	[{"id": "81fc5fa4-cfcd-4db2-a987-5ccd8df8edc6", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "0e492d00-bc86-458d-8981-35b0aa4074be", "bindings": [{"id": "aa005191-5af2-453e-bd6a-fd63e5fb69a9", "type": "Port", "port_id": "9c0e913d-2199-4274-9f9a-8b5c62d2e7f8", "interface_id": "9e4b92ef-e16d-4fa6-a0ee-e1c49486bbcb"}], "created_at": "2025-12-21T05:05:54.734144Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.734144Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "fb614ce2-0f0c-415a-a04a-b98c3171f75f", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "c73f4077-2925-4863-ba89-d0cf0ee48998", "bindings": [{"id": "0a76a413-2d17-49fd-8522-dcaf7bf679a5", "type": "Port", "port_id": "b57b7bf2-529f-41d0-b6fe-a92e8675fa2f", "interface_id": "db102b9a-9759-4287-b9b9-30904ec36dc7"}], "created_at": "2025-12-21T05:05:54.734153Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.734153Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "88ab3615-3b4f-4b99-bb71-4832b7a3ce52", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "4d4de606-20f1-4938-86ba-3bdb30cbde14", "bindings": [{"id": "47203003-139e-4ff6-9de2-3e588e8955f7", "type": "Port", "port_id": "180610c4-d08d-4a2c-8bb3-779083930901", "interface_id": "b179dc7d-a6f6-42ce-aa5c-f1cf21a4a458"}], "created_at": "2025-12-21T05:05:54.734160Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.734160Z", "virtualization": null, "service_definition": "Client"}, {"id": "5eb0a056-d474-49fd-a466-ef9fc828a0dd", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T05:05:54.918769181Z", "type": "SelfReport", "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a"}]}, "host_id": "ead1807d-af0f-4bda-87c5-572b80e3ffe3", "bindings": [{"id": "4cf46b7c-3b3c-41a6-b068-cf3ad917c45a", "type": "Port", "port_id": "cf91c376-65d6-4b7d-856b-3f4e0b7e0e58", "interface_id": "fa28f655-45f7-49ea-b680-db0c278bc147"}], "created_at": "2025-12-21T05:05:54.918770Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:05:54.918770Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "431a12c0-8093-4050-9d0b-762bc178eefe", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:06:42.472746396Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2017b95a-77da-4d99-a859-c28f67205dcc", "bindings": [{"id": "d302c23e-d632-471c-a1b2-97b01d916a15", "type": "Port", "port_id": "a59ca28d-a975-45df-9ddf-59c7b4b98ae9", "interface_id": "544501ce-f1f7-4bed-ae03-c8e6e146e3f6"}], "created_at": "2025-12-21T05:06:42.472762Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:06:42.472762Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "9c132aea-7f79-4337-916a-29e74e358284", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:06:55.449169840Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "864dcd64-c584-4bb9-b463-78db7578ee54", "bindings": [{"id": "be8ec6d9-4f7c-451c-b4dd-350e55803b33", "type": "Port", "port_id": "7b866f21-ac81-4408-bedd-486b56480012", "interface_id": "88561895-5357-463c-8574-6ec97d1c40a2"}], "created_at": "2025-12-21T05:06:55.449189Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:06:55.449189Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "0272d8df-979b-4423-83d8-905509c95720", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:06:57.712030163Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "864dcd64-c584-4bb9-b463-78db7578ee54", "bindings": [{"id": "afb18266-0c70-4841-b8c0-c82fa8549ce7", "type": "Port", "port_id": "0511dfa3-50ee-4056-9619-0a475076ec2f", "interface_id": "88561895-5357-463c-8574-6ec97d1c40a2"}], "created_at": "2025-12-21T05:06:57.712048Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:06:57.712048Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "5061d906-abae-4d45-b83e-afa2c5d2a451", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:12.255878635Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "370871ab-d7ed-4243-85a1-9004179bb5fb", "bindings": [{"id": "a82fe9a8-fbf4-41a5-a18d-b46ccac39b6d", "type": "Port", "port_id": "f3b518f9-0a6e-466e-a593-26c7ceb1be0b", "interface_id": "69b438b1-3ebc-457c-8519-14fc0fa40c40"}], "created_at": "2025-12-21T05:07:12.255898Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:12.255898Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "e6d48df5-1f49-4bf9-a5f0-6a4e95085e2e", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:07:29.704873697Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "38153003-65fa-4537-a608-05125e6e2763", "bindings": [{"id": "c04e6dd4-8a0c-4264-ab02-074c8c8b88d1", "type": "Port", "port_id": "0abd3f5f-c56f-4627-a29d-e8394035f21a", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}], "created_at": "2025-12-21T05:07:29.704892Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:29.704892Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "af602150-ef2e-45dc-a399-4243db5dfa4b", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:07:31.211530747Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "38153003-65fa-4537-a608-05125e6e2763", "bindings": [{"id": "981fd437-76ac-42bb-b6c5-077bd67e248a", "type": "Port", "port_id": "88240eb6-4d48-40b5-a206-3e6e26161795", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}], "created_at": "2025-12-21T05:07:31.211549Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:31.211549Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "c0f6f3a7-e06c-4d6b-82ea-a50ffc4d37c7", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:33.466555700Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "38153003-65fa-4537-a608-05125e6e2763", "bindings": [{"id": "c9eeee5e-3c9e-4324-be34-09e3fd8c2fc9", "type": "Port", "port_id": "5de01924-b407-4d6f-aaf2-2449e1856270", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}], "created_at": "2025-12-21T05:07:33.466574Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:33.466574Z", "virtualization": null, "service_definition": "SSH"}, {"id": "325db5bc-dd13-4ca6-915f-04784e1f997b", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:07:33.467095382Z", "type": "Network", "daemon_id": "3bbfbd10-4f13-4b45-8e79-bed5863f7c3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "38153003-65fa-4537-a608-05125e6e2763", "bindings": [{"id": "5af1e3e4-a2d5-4396-9cbc-c5bb1a33a77e", "type": "Port", "port_id": "3199aac7-9c0c-4d93-8111-fe67e6870d39", "interface_id": "c0def101-50f6-4528-a6f8-c5afb6bb4701"}], "created_at": "2025-12-21T05:07:33.467104Z", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:33.467104Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "f75b79e2-4fa1-49ef-8354-91f776ef60ff", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T05:07:33.501260Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "d4a29d21-3c54-4539-a518-b57578ec16aa", "updated_at": "2025-12-21T05:07:33.501260Z", "description": null, "service_bindings": []}]	t	2025-12-21 05:05:54.757665+00	f	\N	\N	{832b66d0-1204-4f02-82f3-bdaaaaac7efe,f9f94918-4c75-465e-beb0-4f9073b69f2b,dbad3467-b96f-4405-9826-a6da5cda7950}	{e922676c-c2ec-48c2-be5a-204e16a10d79}	{fb8f8ab2-5b85-4c50-980a-0cff6247dcc0}	{fed5a26a-6498-48b0-9dd7-e9df74e4e1ad}	\N	2025-12-21 05:05:54.753691+00	2025-12-21 05:07:35.23699+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
31f57712-4b25-412c-8f88-ed4d606f9bbb	2025-12-21 05:05:54.728964+00	2025-12-21 05:05:54.728964+00	$argon2id$v=19$m=19456,t=2,p=1$eq37/fWkU20B9KPprCDThw$QX09yOvowQLz38yjwvIE1MT2VN3GzTsIdUaWdclrS50	\N	\N	\N	user@gmail.com	5db01261-adc1-4b56-8beb-e0885bbc358a	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
5aNqBwAWMLJ0sNBd7Ccr3A	\\x93c410dc2b27ec5dd0b074b2301600076aa3e581a7757365725f6964d92433316635373731322d346232352d343132632d386638382d65643464363036663962626299cd07ea14050536ce35db1600000000	2026-01-20 05:05:54.90355+00
waVVir-nl-93G8wHzYehrg	\\x93c410aea187cd07cc1b77ef97a7bf8a55a5c182a7757365725f6964d92433316635373731322d346232352d343132632d386638382d656434643630366639626262ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92464653264373964612d616430342d343164392d393633312d633762656634666462313465a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea14050722ce042aed1d000000	2026-01-20 05:07:34.069922+00
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

\unrestrict yhbCzAxLj19SN3PDE2Ge5CReBe30hGq1StW5v4b6UyHPqPit5ebABL7oY7A0ONo

