--
-- PostgreSQL database dump
--

\restrict UB3J4hcMeCdeAkRTul8RaWsOOImQSDwK7xFbcFZAc2dbSZWiiHP54HtWCp1zC9U

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
20251006215000	users	2025-12-21 05:44:18.453446+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3541921
20251006215100	networks	2025-12-21 05:44:18.458034+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4571231
20251006215151	create hosts	2025-12-21 05:44:18.463881+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3777362
20251006215155	create subnets	2025-12-21 05:44:18.468007+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3650304
20251006215201	create groups	2025-12-21 05:44:18.472083+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3929498
20251006215204	create daemons	2025-12-21 05:44:18.476334+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4042609
20251006215212	create services	2025-12-21 05:44:18.480749+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5069395
20251029193448	user-auth	2025-12-21 05:44:18.486127+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6204493
20251030044828	daemon api	2025-12-21 05:44:18.492707+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1552360
20251030170438	host-hide	2025-12-21 05:44:18.494522+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1095564
20251102224919	create discovery	2025-12-21 05:44:18.495931+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11365058
20251106235621	normalize-daemon-cols	2025-12-21 05:44:18.507729+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1713212
20251107034459	api keys	2025-12-21 05:44:18.509765+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8174905
20251107222650	oidc-auth	2025-12-21 05:44:18.518255+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	30606424
20251110181948	orgs-billing	2025-12-21 05:44:18.549193+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10640412
20251113223656	group-enhancements	2025-12-21 05:44:18.560165+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1028558
20251117032720	daemon-mode	2025-12-21 05:44:18.561481+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1094181
20251118143058	set-default-plan	2025-12-21 05:44:18.562881+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1221429
20251118225043	save-topology	2025-12-21 05:44:18.564398+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8878587
20251123232748	network-permissions	2025-12-21 05:44:18.573605+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2673254
20251125001342	billing-updates	2025-12-21 05:44:18.576578+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	1003311
20251128035448	org-onboarding-status	2025-12-21 05:44:18.577904+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1414452
20251129180942	nfs-consolidate	2025-12-21 05:44:18.579621+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1347997
20251206052641	discovery-progress	2025-12-21 05:44:18.581265+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1734272
20251206202200	plan-fix	2025-12-21 05:44:18.583289+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	959678
20251207061341	daemon-url	2025-12-21 05:44:18.584537+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2259618
20251210045929	tags	2025-12-21 05:44:18.587097+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8839458
20251210175035	terms	2025-12-21 05:44:18.596292+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	910559
20251213025048	hash-keys	2025-12-21 05:44:18.597474+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9516813
20251214050638	scanopy	2025-12-21 05:44:18.607282+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1333069
20251215215724	topo-scanopy-fix	2025-12-21 05:44:18.609073+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	726632
20251217153736	category rename	2025-12-21 05:44:18.610073+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1608055
20251218053111	invite-persistence	2025-12-21 05:44:18.611981+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5193608
20251219211216	create shares	2025-12-21 05:44:18.617483+00	t	\\x1ea2a7fde07002f2b4f1742c761619edad3b5b439dbb1c746b8dabed29a0e9ba1b8c057c742b9f49614eba2ccfacd531	6772778
20251220170928	permissions-cleanup	2025-12-21 05:44:18.624778+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1386640
20251220180000	commercial-to-community	2025-12-21 05:44:18.626439+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	840826
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
f1a583a9-48c4-4cba-a739-0df23a1483ad	872eccd8af148290333278df4ce06c19c8d8192f5801b66b161758149ed3fc40	0f674a00-60f8-42cd-8337-188d2f6bfb77	Integrated Daemon API Key	2025-12-21 05:44:21.924507+00	2025-12-21 05:46:00.839225+00	2025-12-21 05:46:00.838201+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
115fb01e-d117-494f-bc38-88b97edadd33	0f674a00-60f8-42cd-8337-188d2f6bfb77	cac843dd-8ec3-422c-ad46-84f38450c650	2025-12-21 05:44:22.05579+00	2025-12-21 05:45:38.029462+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["0d4153bc-a09b-408e-a3da-12886df7b845"]}	2025-12-21 05:45:38.031025+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
3f513a50-400e-4359-b0cf-2af572d031d5	0f674a00-60f8-42cd-8337-188d2f6bfb77	115fb01e-d117-494f-bc38-88b97edadd33	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650"}	Self Report	2025-12-21 05:44:22.063293+00	2025-12-21 05:44:22.063293+00	{}
3dfd3208-de41-4a1f-b108-d03c6030b411	0f674a00-60f8-42cd-8337-188d2f6bfb77	115fb01e-d117-494f-bc38-88b97edadd33	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 05:44:22.069939+00	2025-12-21 05:44:22.069939+00	{}
169aff53-044e-46a2-9e85-58e4d34924bb	0f674a00-60f8-42cd-8337-188d2f6bfb77	115fb01e-d117-494f-bc38-88b97edadd33	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "session_id": "2128e681-69c7-4763-97ec-c43cde238ce6", "started_at": "2025-12-21T05:44:22.069535055Z", "finished_at": "2025-12-21T05:44:22.161904970Z", "discovery_type": {"type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650"}}}	{"type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650"}	Self Report	2025-12-21 05:44:22.069535+00	2025-12-21 05:44:22.165113+00	{}
0a99e8b4-a5cf-4270-b264-91170b376042	0f674a00-60f8-42cd-8337-188d2f6bfb77	115fb01e-d117-494f-bc38-88b97edadd33	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "session_id": "5bd5f39c-baee-4c6d-b801-220ece25b42a", "started_at": "2025-12-21T05:44:22.177740380Z", "finished_at": "2025-12-21T05:46:00.836039785Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 05:44:22.17774+00	2025-12-21 05:46:00.838624+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
6606fa65-e6ce-476d-8067-a8dbdf4d0611	0f674a00-60f8-42cd-8337-188d2f6bfb77		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 05:46:00.851078+00	2025-12-21 05:46:00.851078+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
eb8e0e38-6ec6-41b4-873b-dfc6d3d14924	0f674a00-60f8-42cd-8337-188d2f6bfb77	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "7a2c57ed-65d5-4ab6-91f7-49c7742498f0"}	[{"id": "d105965f-b014-4b42-808f-05a33e100d52", "name": "Internet", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "ip_address": "1.1.1.1", "mac_address": null}]	{705c10b3-c15a-4268-a1f4-d4ac2fd63ef9}	[{"id": "fd2cd232-9ac7-447a-8aa0-7886cb63fd54", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 05:44:21.898494+00	2025-12-21 05:44:21.908904+00	f	{}
4ff67a37-b650-4aea-a0cc-a8f0a3c7cc7a	0f674a00-60f8-42cd-8337-188d2f6bfb77	Google.com	\N	\N	{"type": "ServiceBinding", "config": "9fd40342-565b-49a9-b589-9863ffbb8736"}	[{"id": "39cd1644-774c-4a78-a897-67f4c6254d7d", "name": "Internet", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "ip_address": "203.0.113.85", "mac_address": null}]	{c8d67857-f136-448a-85c2-50a1674d71c8}	[{"id": "b453f301-a729-4a9e-94a2-90f8cbaf12a6", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 05:44:21.8985+00	2025-12-21 05:44:21.913419+00	f	{}
2f31c710-08cf-4b13-a1c8-0dbb092bd014	0f674a00-60f8-42cd-8337-188d2f6bfb77	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "c053db28-a5ef-4841-8be0-6fb59db1fb70"}	[{"id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a", "name": "Remote Network", "subnet_id": "10d230f9-c057-45ba-acb2-531d2d10fc56", "ip_address": "203.0.113.159", "mac_address": null}]	{d1cad809-0fab-4e54-8ba8-e1e8d6e7e36d}	[{"id": "8b54d04d-2596-40c7-ac89-c3c2a976ccea", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 05:44:21.898505+00	2025-12-21 05:44:21.917155+00	f	{}
020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe	0f674a00-60f8-42cd-8337-188d2f6bfb77	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.5", "mac_address": "6E:C0:00:C7:D1:87"}]	{c29a3bc1-60b5-4e01-8168-a1a55a13d9f6,37db4b4a-cd06-4dfe-86c8-06e6ebea2305}	[{"id": "bfa31831-7d7e-467b-bc3a-ff844bf9219d", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "e9c969b3-1ba8-4c86-96a8-ca5c0ab99dbd", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:09.105441708Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:45:09.105445+00	2025-12-21 05:45:24.47543+00	f	{}
cac843dd-8ec3-422c-ad46-84f38450c650	0f674a00-60f8-42cd-8337-188d2f6bfb77	scanopy-daemon	455b7a559fd0	Scanopy daemon	{"type": "None"}	[{"id": "8beeb8cc-f05a-4624-a329-135660d7ffcb", "name": "eth0", "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.4", "mac_address": "42:5B:2E:81:F5:C9"}]	{d0e2748e-6443-4062-bd22-7d13b4972737}	[{"id": "b93d66bb-20be-4ffa-b99a-c4fc3296c824", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:22.145527385Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}	null	2025-12-21 05:44:22.049297+00	2025-12-21 05:44:22.159344+00	f	{}
de0770a2-3b49-4901-959a-0127edbe7f92	0f674a00-60f8-42cd-8337-188d2f6bfb77	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "018cb285-bb32-4c77-bb39-38b4e20446dc", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.3", "mac_address": "4A:91:78:A5:66:38"}]	{a39a7829-bc72-43b1-a92a-46d23db7b3d3}	[{"id": "8910e820-f37b-48fd-93cd-377f50b950e7", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:54.019093572Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:44:54.019096+00	2025-12-21 05:45:09.073616+00	f	{}
844a4b32-8a26-4302-bb7d-74ee244240c0	0f674a00-60f8-42cd-8337-188d2f6bfb77	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "1e1f4215-5693-443f-a348-befa58c8a7f0", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.6", "mac_address": "36:71:1F:9B:0E:C9"}]	{156a4daf-fbc1-44a6-8830-3e15dc5a1012}	[{"id": "e15c5a5b-be89-46ce-a855-1848e6bcd898", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:24.463866052Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:45:24.463867+00	2025-12-21 05:45:39.660993+00	f	{}
ad7c8f97-4c0a-4779-bae4-d37ee4099fd8	0f674a00-60f8-42cd-8337-188d2f6bfb77	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "7130dc26-532f-494f-87c0-7daefd81395c", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.1", "mac_address": "E6:99:91:43:1C:13"}]	{1a5aebde-d49c-4ea6-8650-160c24ebe75a,704577f0-88b1-4f8f-9775-1fa6f8d415f2,72ff5577-51cc-46df-ba81-361264056603,b1e90d43-2876-47a7-b064-060229f0d657}	[{"id": "599dbba4-15cc-4298-bf80-6039e7bfa578", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "011d3412-6d2e-4e44-8a7e-778f2c0c4fb1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1ed98955-7030-4ea0-9cb0-24d5a14a7a34", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "b86f61da-3fa2-4b56-b63e-0688a5464bd8", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:45.707981232Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 05:45:45.707985+00	2025-12-21 05:46:00.829692+00	f	{}
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
0f674a00-60f8-42cd-8337-188d2f6bfb77	My Network	2025-12-21 05:44:21.89699+00	2025-12-21 05:44:21.89699+00	f	dd98ea40-6d9a-4aaf-a183-d55237265c3f	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
dd98ea40-6d9a-4aaf-a183-d55237265c3f	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 05:44:21.890129+00	2025-12-21 05:46:01.676644+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
705c10b3-c15a-4268-a1f4-d4ac2fd63ef9	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:21.898495+00	2025-12-21 05:44:21.898495+00	Cloudflare DNS	eb8e0e38-6ec6-41b4-873b-dfc6d3d14924	[{"id": "7a2c57ed-65d5-4ab6-91f7-49c7742498f0", "type": "Port", "port_id": "fd2cd232-9ac7-447a-8aa0-7886cb63fd54", "interface_id": "d105965f-b014-4b42-808f-05a33e100d52"}]	"Dns Server"	null	{"type": "System"}	{}
c8d67857-f136-448a-85c2-50a1674d71c8	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:21.898501+00	2025-12-21 05:44:21.898501+00	Google.com	4ff67a37-b650-4aea-a0cc-a8f0a3c7cc7a	[{"id": "9fd40342-565b-49a9-b589-9863ffbb8736", "type": "Port", "port_id": "b453f301-a729-4a9e-94a2-90f8cbaf12a6", "interface_id": "39cd1644-774c-4a78-a897-67f4c6254d7d"}]	"Web Service"	null	{"type": "System"}	{}
d1cad809-0fab-4e54-8ba8-e1e8d6e7e36d	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:21.898507+00	2025-12-21 05:44:21.898507+00	Mobile Device	2f31c710-08cf-4b13-a1c8-0dbb092bd014	[{"id": "c053db28-a5ef-4841-8be0-6fb59db1fb70", "type": "Port", "port_id": "8b54d04d-2596-40c7-ac89-c3c2a976ccea", "interface_id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a"}]	"Client"	null	{"type": "System"}	{}
d0e2748e-6443-4062-bd22-7d13b4972737	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:22.145551+00	2025-12-21 05:44:22.145551+00	Scanopy Daemon	cac843dd-8ec3-422c-ad46-84f38450c650	[{"id": "262f6744-352a-42c8-b76a-d33a42b858de", "type": "Port", "port_id": "b93d66bb-20be-4ffa-b99a-c4fc3296c824", "interface_id": "8beeb8cc-f05a-4624-a329-135660d7ffcb"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T05:44:22.145550999Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}	{}
a39a7829-bc72-43b1-a92a-46d23db7b3d3	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:05.204499+00	2025-12-21 05:45:05.204499+00	Scanopy Server	de0770a2-3b49-4901-959a-0127edbe7f92	[{"id": "871f8075-765e-4b87-8936-6559e3438668", "type": "Port", "port_id": "8910e820-f37b-48fd-93cd-377f50b950e7", "interface_id": "018cb285-bb32-4c77-bb39-38b4e20446dc"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:05.204484547Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c29a3bc1-60b5-4e01-8168-a1a55a13d9f6	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:22.148753+00	2025-12-21 05:45:22.148753+00	Home Assistant	020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe	[{"id": "abea2e15-7981-4c6a-91b6-f70606313f1c", "type": "Port", "port_id": "bfa31831-7d7e-467b-bc3a-ff844bf9219d", "interface_id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:22.148733244Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
37db4b4a-cd06-4dfe-86c8-06e6ebea2305	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:24.462559+00	2025-12-21 05:45:24.462559+00	Unclaimed Open Ports	020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe	[{"id": "bbabb21a-6186-4aae-be62-cca94158f60b", "type": "Port", "port_id": "e9c969b3-1ba8-4c86-96a8-ca5c0ab99dbd", "interface_id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:45:24.462543892Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
156a4daf-fbc1-44a6-8830-3e15dc5a1012	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:39.645231+00	2025-12-21 05:45:39.645231+00	PostgreSQL	844a4b32-8a26-4302-bb7d-74ee244240c0	[{"id": "f4f80b72-48da-4608-b762-b7779099e592", "type": "Port", "port_id": "e15c5a5b-be89-46ce-a855-1848e6bcd898", "interface_id": "1e1f4215-5693-443f-a348-befa58c8a7f0"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:45:39.645208758Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
72ff5577-51cc-46df-ba81-361264056603	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:46:00.816783+00	2025-12-21 05:46:00.816783+00	SSH	ad7c8f97-4c0a-4779-bae4-d37ee4099fd8	[{"id": "52f4c1b5-5c0b-4ed7-86f6-7663d8a62040", "type": "Port", "port_id": "1ed98955-7030-4ea0-9cb0-24d5a14a7a34", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:46:00.816764446Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
b1e90d43-2876-47a7-b064-060229f0d657	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:46:00.817302+00	2025-12-21 05:46:00.817302+00	Unclaimed Open Ports	ad7c8f97-4c0a-4779-bae4-d37ee4099fd8	[{"id": "28b975c1-518a-4256-912c-cbf0e5dbdc25", "type": "Port", "port_id": "b86f61da-3fa2-4b56-b63e-0688a5464bd8", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:46:00.817292266Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1a5aebde-d49c-4ea6-8650-160c24ebe75a	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:57.025807+00	2025-12-21 05:45:57.025807+00	Scanopy Server	ad7c8f97-4c0a-4779-bae4-d37ee4099fd8	[{"id": "64e23ab5-1003-4fb7-b460-1488400fe92f", "type": "Port", "port_id": "599dbba4-15cc-4298-bf80-6039e7bfa578", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:57.025787571Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
704577f0-88b1-4f8f-9775-1fa6f8d415f2	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:45:58.535023+00	2025-12-21 05:45:58.535023+00	Home Assistant	ad7c8f97-4c0a-4779-bae4-d37ee4099fd8	[{"id": "49b82fd5-b010-4b14-90c0-7008f2bf74d4", "type": "Port", "port_id": "011d3412-6d2e-4e44-8a7e-778f2c0c4fb1", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:58.535003996Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
1d22f8fb-2955-42a8-8bec-f659ad47c6e8	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:21.898446+00	2025-12-21 05:44:21.898446+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
10d230f9-c057-45ba-acb2-531d2d10fc56	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:21.89845+00	2025-12-21 05:44:21.89845+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
0d4153bc-a09b-408e-a3da-12886df7b845	0f674a00-60f8-42cd-8337-188d2f6bfb77	2025-12-21 05:44:22.069723+00	2025-12-21 05:44:22.069723+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:22.069721865Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
823bf28c-d63d-4064-a203-300610fdb874	dd98ea40-6d9a-4aaf-a183-d55237265c3f	New Tag	\N	2025-12-21 05:46:00.860541+00	2025-12-21 05:46:00.860541+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
1215bc14-da78-4562-885b-6ca8b954147b	0f674a00-60f8-42cd-8337-188d2f6bfb77	My Topology	[]	[{"id": "10d230f9-c057-45ba-acb2-531d2d10fc56", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "d105965f-b014-4b42-808f-05a33e100d52", "size": {"x": 250, "y": 100}, "header": null, "host_id": "eb8e0e38-6ec6-41b4-873b-dfc6d3d14924", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "interface_id": "d105965f-b014-4b42-808f-05a33e100d52"}, {"id": "39cd1644-774c-4a78-a897-67f4c6254d7d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "4ff67a37-b650-4aea-a0cc-a8f0a3c7cc7a", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "interface_id": "39cd1644-774c-4a78-a897-67f4c6254d7d"}, {"id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2f31c710-08cf-4b13-a1c8-0dbb092bd014", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "10d230f9-c057-45ba-acb2-531d2d10fc56", "interface_id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "eb8e0e38-6ec6-41b4-873b-dfc6d3d14924", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "fd2cd232-9ac7-447a-8aa0-7886cb63fd54", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "7a2c57ed-65d5-4ab6-91f7-49c7742498f0"}, "hostname": null, "services": ["705c10b3-c15a-4268-a1f4-d4ac2fd63ef9"], "created_at": "2025-12-21T05:44:21.898494Z", "interfaces": [{"id": "d105965f-b014-4b42-808f-05a33e100d52", "name": "Internet", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.908904Z", "description": null, "virtualization": null}, {"id": "4ff67a37-b650-4aea-a0cc-a8f0a3c7cc7a", "name": "Google.com", "tags": [], "ports": [{"id": "b453f301-a729-4a9e-94a2-90f8cbaf12a6", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "9fd40342-565b-49a9-b589-9863ffbb8736"}, "hostname": null, "services": ["c8d67857-f136-448a-85c2-50a1674d71c8"], "created_at": "2025-12-21T05:44:21.898500Z", "interfaces": [{"id": "39cd1644-774c-4a78-a897-67f4c6254d7d", "name": "Internet", "subnet_id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "ip_address": "203.0.113.85", "mac_address": null}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.913419Z", "description": null, "virtualization": null}, {"id": "2f31c710-08cf-4b13-a1c8-0dbb092bd014", "name": "Mobile Device", "tags": [], "ports": [{"id": "8b54d04d-2596-40c7-ac89-c3c2a976ccea", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c053db28-a5ef-4841-8be0-6fb59db1fb70"}, "hostname": null, "services": ["d1cad809-0fab-4e54-8ba8-e1e8d6e7e36d"], "created_at": "2025-12-21T05:44:21.898505Z", "interfaces": [{"id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a", "name": "Remote Network", "subnet_id": "10d230f9-c057-45ba-acb2-531d2d10fc56", "ip_address": "203.0.113.159", "mac_address": null}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.917155Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "cac843dd-8ec3-422c-ad46-84f38450c650", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "b93d66bb-20be-4ffa-b99a-c4fc3296c824", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:22.145527385Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}, "target": {"type": "None"}, "hostname": "455b7a559fd0", "services": ["d0e2748e-6443-4062-bd22-7d13b4972737"], "created_at": "2025-12-21T05:44:22.049297Z", "interfaces": [{"id": "8beeb8cc-f05a-4624-a329-135660d7ffcb", "name": "eth0", "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.4", "mac_address": "42:5B:2E:81:F5:C9"}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:22.159344Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "de0770a2-3b49-4901-959a-0127edbe7f92", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "8910e820-f37b-48fd-93cd-377f50b950e7", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:54.019093572Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["a39a7829-bc72-43b1-a92a-46d23db7b3d3"], "created_at": "2025-12-21T05:44:54.019096Z", "interfaces": [{"id": "018cb285-bb32-4c77-bb39-38b4e20446dc", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.3", "mac_address": "4A:91:78:A5:66:38"}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:09.073616Z", "description": null, "virtualization": null}, {"id": "020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "bfa31831-7d7e-467b-bc3a-ff844bf9219d", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "e9c969b3-1ba8-4c86-96a8-ca5c0ab99dbd", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:09.105441708Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["c29a3bc1-60b5-4e01-8168-a1a55a13d9f6", "37db4b4a-cd06-4dfe-86c8-06e6ebea2305"], "created_at": "2025-12-21T05:45:09.105445Z", "interfaces": [{"id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.5", "mac_address": "6E:C0:00:C7:D1:87"}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:24.475430Z", "description": null, "virtualization": null}, {"id": "844a4b32-8a26-4302-bb7d-74ee244240c0", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "e15c5a5b-be89-46ce-a855-1848e6bcd898", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:24.463866052Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["156a4daf-fbc1-44a6-8830-3e15dc5a1012"], "created_at": "2025-12-21T05:45:24.463867Z", "interfaces": [{"id": "1e1f4215-5693-443f-a348-befa58c8a7f0", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.6", "mac_address": "36:71:1F:9B:0E:C9"}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:39.660993Z", "description": null, "virtualization": null}, {"id": "ad7c8f97-4c0a-4779-bae4-d37ee4099fd8", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "599dbba4-15cc-4298-bf80-6039e7bfa578", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "011d3412-6d2e-4e44-8a7e-778f2c0c4fb1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "1ed98955-7030-4ea0-9cb0-24d5a14a7a34", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "b86f61da-3fa2-4b56-b63e-0688a5464bd8", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:45:45.707981232Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["1a5aebde-d49c-4ea6-8650-160c24ebe75a", "704577f0-88b1-4f8f-9775-1fa6f8d415f2", "72ff5577-51cc-46df-ba81-361264056603", "b1e90d43-2876-47a7-b064-060229f0d657"], "created_at": "2025-12-21T05:45:45.707985Z", "interfaces": [{"id": "7130dc26-532f-494f-87c0-7daefd81395c", "name": null, "subnet_id": "0d4153bc-a09b-408e-a3da-12886df7b845", "ip_address": "172.25.0.1", "mac_address": "E6:99:91:43:1C:13"}], "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:46:00.829692Z", "description": null, "virtualization": null}]	[{"id": "1d22f8fb-2955-42a8-8bec-f659ad47c6e8", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T05:44:21.898446Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.898446Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "10d230f9-c057-45ba-acb2-531d2d10fc56", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T05:44:21.898450Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.898450Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "0d4153bc-a09b-408e-a3da-12886df7b845", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T05:44:22.069721865Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}, "created_at": "2025-12-21T05:44:22.069723Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:22.069723Z", "description": null, "subnet_type": "Lan"}]	[{"id": "705c10b3-c15a-4268-a1f4-d4ac2fd63ef9", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "eb8e0e38-6ec6-41b4-873b-dfc6d3d14924", "bindings": [{"id": "7a2c57ed-65d5-4ab6-91f7-49c7742498f0", "type": "Port", "port_id": "fd2cd232-9ac7-447a-8aa0-7886cb63fd54", "interface_id": "d105965f-b014-4b42-808f-05a33e100d52"}], "created_at": "2025-12-21T05:44:21.898495Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.898495Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "c8d67857-f136-448a-85c2-50a1674d71c8", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "4ff67a37-b650-4aea-a0cc-a8f0a3c7cc7a", "bindings": [{"id": "9fd40342-565b-49a9-b589-9863ffbb8736", "type": "Port", "port_id": "b453f301-a729-4a9e-94a2-90f8cbaf12a6", "interface_id": "39cd1644-774c-4a78-a897-67f4c6254d7d"}], "created_at": "2025-12-21T05:44:21.898501Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.898501Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "d1cad809-0fab-4e54-8ba8-e1e8d6e7e36d", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "2f31c710-08cf-4b13-a1c8-0dbb092bd014", "bindings": [{"id": "c053db28-a5ef-4841-8be0-6fb59db1fb70", "type": "Port", "port_id": "8b54d04d-2596-40c7-ac89-c3c2a976ccea", "interface_id": "9eb40a6c-1c42-4dcf-8513-4c010eda1c5a"}], "created_at": "2025-12-21T05:44:21.898507Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:21.898507Z", "virtualization": null, "service_definition": "Client"}, {"id": "d0e2748e-6443-4062-bd22-7d13b4972737", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T05:44:22.145550999Z", "type": "SelfReport", "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33"}]}, "host_id": "cac843dd-8ec3-422c-ad46-84f38450c650", "bindings": [{"id": "262f6744-352a-42c8-b76a-d33a42b858de", "type": "Port", "port_id": "b93d66bb-20be-4ffa-b99a-c4fc3296c824", "interface_id": "8beeb8cc-f05a-4624-a329-135660d7ffcb"}], "created_at": "2025-12-21T05:44:22.145551Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:44:22.145551Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "a39a7829-bc72-43b1-a92a-46d23db7b3d3", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:05.204484547Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "de0770a2-3b49-4901-959a-0127edbe7f92", "bindings": [{"id": "871f8075-765e-4b87-8936-6559e3438668", "type": "Port", "port_id": "8910e820-f37b-48fd-93cd-377f50b950e7", "interface_id": "018cb285-bb32-4c77-bb39-38b4e20446dc"}], "created_at": "2025-12-21T05:45:05.204499Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:05.204499Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "c29a3bc1-60b5-4e01-8168-a1a55a13d9f6", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:22.148733244Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe", "bindings": [{"id": "abea2e15-7981-4c6a-91b6-f70606313f1c", "type": "Port", "port_id": "bfa31831-7d7e-467b-bc3a-ff844bf9219d", "interface_id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e"}], "created_at": "2025-12-21T05:45:22.148753Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:22.148753Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "37db4b4a-cd06-4dfe-86c8-06e6ebea2305", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:45:24.462543892Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "020e0d0b-9b4e-4aa8-bf08-bb51c282cbfe", "bindings": [{"id": "bbabb21a-6186-4aae-be62-cca94158f60b", "type": "Port", "port_id": "e9c969b3-1ba8-4c86-96a8-ca5c0ab99dbd", "interface_id": "b49858d2-aca7-4ebf-9015-fc1e8b29185e"}], "created_at": "2025-12-21T05:45:24.462559Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:24.462559Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "156a4daf-fbc1-44a6-8830-3e15dc5a1012", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:45:39.645208758Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "844a4b32-8a26-4302-bb7d-74ee244240c0", "bindings": [{"id": "f4f80b72-48da-4608-b762-b7779099e592", "type": "Port", "port_id": "e15c5a5b-be89-46ce-a855-1848e6bcd898", "interface_id": "1e1f4215-5693-443f-a348-befa58c8a7f0"}], "created_at": "2025-12-21T05:45:39.645231Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:39.645231Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "1a5aebde-d49c-4ea6-8650-160c24ebe75a", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:57.025787571Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ad7c8f97-4c0a-4779-bae4-d37ee4099fd8", "bindings": [{"id": "64e23ab5-1003-4fb7-b460-1488400fe92f", "type": "Port", "port_id": "599dbba4-15cc-4298-bf80-6039e7bfa578", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}], "created_at": "2025-12-21T05:45:57.025807Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:57.025807Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "704577f0-88b1-4f8f-9775-1fa6f8d415f2", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T05:45:58.535003996Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ad7c8f97-4c0a-4779-bae4-d37ee4099fd8", "bindings": [{"id": "49b82fd5-b010-4b14-90c0-7008f2bf74d4", "type": "Port", "port_id": "011d3412-6d2e-4e44-8a7e-778f2c0c4fb1", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}], "created_at": "2025-12-21T05:45:58.535023Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:45:58.535023Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "72ff5577-51cc-46df-ba81-361264056603", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:46:00.816764446Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ad7c8f97-4c0a-4779-bae4-d37ee4099fd8", "bindings": [{"id": "52f4c1b5-5c0b-4ed7-86f6-7663d8a62040", "type": "Port", "port_id": "1ed98955-7030-4ea0-9cb0-24d5a14a7a34", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}], "created_at": "2025-12-21T05:46:00.816783Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:46:00.816783Z", "virtualization": null, "service_definition": "SSH"}, {"id": "b1e90d43-2876-47a7-b064-060229f0d657", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T05:46:00.817292266Z", "type": "Network", "daemon_id": "115fb01e-d117-494f-bc38-88b97edadd33", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ad7c8f97-4c0a-4779-bae4-d37ee4099fd8", "bindings": [{"id": "28b975c1-518a-4256-912c-cbf0e5dbdc25", "type": "Port", "port_id": "b86f61da-3fa2-4b56-b63e-0688a5464bd8", "interface_id": "7130dc26-532f-494f-87c0-7daefd81395c"}], "created_at": "2025-12-21T05:46:00.817302Z", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:46:00.817302Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "6606fa65-e6ce-476d-8067-a8dbdf4d0611", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T05:46:00.851078Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "0f674a00-60f8-42cd-8337-188d2f6bfb77", "updated_at": "2025-12-21T05:46:00.851078Z", "description": null, "service_bindings": []}]	t	2025-12-21 05:44:21.921856+00	f	\N	\N	{89f3ef3d-442e-4770-a362-fded71c57d93,e2521f25-1798-4c65-a35a-ed9b9ba972e6,25b4ce6e-e555-46a8-a85c-aa02294badf4}	{50db1681-3eb1-4bc3-a992-8f4e8bacad23}	{ac741aa5-eb34-45e0-8b99-f5693ef0575b}	{38279ca2-6f44-4fb1-94bb-57fdc6369ce3}	\N	2025-12-21 05:44:21.91784+00	2025-12-21 05:46:02.509014+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
8d79b8ca-74ad-4784-8aa2-377231f47ff8	2025-12-21 05:44:21.893291+00	2025-12-21 05:44:21.893291+00	$argon2id$v=19$m=19456,t=2,p=1$yD/a/b/0pESZx5tAEcvKBw$ilbZ8tz2Phr1lGj60KHxvqijccMbxK3C8VIpA7hELL4	\N	\N	\N	user@gmail.com	dd98ea40-6d9a-4aaf-a183-d55237265c3f	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
-r2wU8m5hCnz61Zt0POqHA	\\x93c4101caaf3d06d56ebf32984b9c953b0bdfa81a7757365725f6964d92438643739623863612d373461642d343738342d386161322d33373732333166343766663899cd07ea14052c16ce04a56821000000	2026-01-20 05:44:22.077948+00
5H24COFDxUqD4aIEI_uryQ	\\x93c410c9abfb2304a2e1834ac543e108b87de482a7757365725f6964d92438643739623863612d373461642d343738342d386161322d333737323331663437666638ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92437323663656266302d663661362d346433352d393965382d396566613137393666356436a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea14052e01ce19681984000000	2026-01-20 05:46:01.426252+00
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

\unrestrict UB3J4hcMeCdeAkRTul8RaWsOOImQSDwK7xFbcFZAc2dbSZWiiHP54HtWCp1zC9U

