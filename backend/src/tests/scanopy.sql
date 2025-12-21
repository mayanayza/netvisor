--
-- PostgreSQL database dump
--

\restrict CNp8aeSlUgQgnLSfkEbrwB1laDhRntkcjmZHhvWcwQDaJuq9w5bMeCk2tkVkpD5

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
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    expires_at timestamp with time zone,
    password_hash text,
    allowed_domains text[],
    options jsonb NOT NULL,
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
20251006215000	users	2025-12-21 19:32:30.167457+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3503510
20251006215100	networks	2025-12-21 19:32:30.171978+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4958322
20251006215151	create hosts	2025-12-21 19:32:30.177274+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3893705
20251006215155	create subnets	2025-12-21 19:32:30.181534+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3634824
20251006215201	create groups	2025-12-21 19:32:30.185517+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4172513
20251006215204	create daemons	2025-12-21 19:32:30.190033+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4120516
20251006215212	create services	2025-12-21 19:32:30.194583+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4869919
20251029193448	user-auth	2025-12-21 19:32:30.19977+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6844918
20251030044828	daemon api	2025-12-21 19:32:30.206915+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1502011
20251030170438	host-hide	2025-12-21 19:32:30.208778+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1071241
20251102224919	create discovery	2025-12-21 19:32:30.210134+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11088483
20251106235621	normalize-daemon-cols	2025-12-21 19:32:30.221547+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1720246
20251107034459	api keys	2025-12-21 19:32:30.223608+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9069361
20251107222650	oidc-auth	2025-12-21 19:32:30.233001+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28534198
20251110181948	orgs-billing	2025-12-21 19:32:30.261858+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11089053
20251113223656	group-enhancements	2025-12-21 19:32:30.27325+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1012821
20251117032720	daemon-mode	2025-12-21 19:32:30.27454+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1055221
20251118143058	set-default-plan	2025-12-21 19:32:30.275873+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1166748
20251118225043	save-topology	2025-12-21 19:32:30.277321+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8859672
20251123232748	network-permissions	2025-12-21 19:32:30.286517+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2659271
20251125001342	billing-updates	2025-12-21 19:32:30.28948+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	869065
20251128035448	org-onboarding-status	2025-12-21 19:32:30.290648+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1395082
20251129180942	nfs-consolidate	2025-12-21 19:32:30.292328+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1179211
20251206052641	discovery-progress	2025-12-21 19:32:30.293789+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1664021
20251206202200	plan-fix	2025-12-21 19:32:30.295753+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	896866
20251207061341	daemon-url	2025-12-21 19:32:30.29692+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	3063262
20251210045929	tags	2025-12-21 19:32:30.300304+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8773672
20251210175035	terms	2025-12-21 19:32:30.309409+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	886347
20251213025048	hash-keys	2025-12-21 19:32:30.310576+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	10717723
20251214050638	scanopy	2025-12-21 19:32:30.321736+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1355208
20251215215724	topo-scanopy-fix	2025-12-21 19:32:30.323427+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	740065
20251217153736	category rename	2025-12-21 19:32:30.324461+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1662890
20251218053111	invite-persistence	2025-12-21 19:32:30.326432+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5179594
20251219211216	create shares	2025-12-21 19:32:30.331926+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6724344
20251220170928	permissions-cleanup	2025-12-21 19:32:30.338979+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1459621
20251220180000	commercial-to-community	2025-12-21 19:32:30.34076+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	787803
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
afe55eb5-616f-4d05-a1ef-df41158151c3	bf17c975f57720d76b2b4dea669c43723e2dda350645a04ac8d96f72b0941e7d	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	Integrated Daemon API Key	2025-12-21 19:32:33.651851+00	2025-12-21 19:34:09.267863+00	2025-12-21 19:34:09.266109+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	a18188ff-d0b3-4192-8b2f-d6e2e334c1e7	2025-12-21 19:32:33.705881+00	2025-12-21 19:33:50.273978+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["e1503e18-0f6d-4111-9308-93a4e66518c4"]}	2025-12-21 19:33:50.274869+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
bd195d18-ceff-453c-b11a-841151894a48	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7"}	Self Report	2025-12-21 19:32:33.712154+00	2025-12-21 19:32:33.712154+00	{}
d34535dd-30d3-450b-a7e3-87f555bfdf03	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 19:32:33.719467+00	2025-12-21 19:32:33.719467+00	{}
105cac0f-8771-4347-baf9-6b2e83fb941d	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "session_id": "d968bc13-a1ba-4607-bff7-32b7145a368b", "started_at": "2025-12-21T19:32:33.718859692Z", "finished_at": "2025-12-21T19:32:33.833040703Z", "discovery_type": {"type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7"}}}	{"type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7"}	Self Report	2025-12-21 19:32:33.718859+00	2025-12-21 19:32:33.838278+00	{}
9263434a-f95e-4daf-9d10-f76a3737aebd	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "session_id": "368217a1-3f67-450a-8b80-fb607f12d54f", "started_at": "2025-12-21T19:32:33.860075559Z", "finished_at": "2025-12-21T19:34:09.263503845Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 19:32:33.860075+00	2025-12-21 19:34:09.26653+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
8b5d76f6-b824-444c-875a-1e8ba8d9c760	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 19:34:09.280468+00	2025-12-21 19:34:09.280468+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
f719acfe-e6c2-458b-9578-e1d756d5a11c	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "5788e0be-391b-4251-baa2-f9b9c88fbe68"}	[{"id": "345141c6-97c5-479c-9a9a-2fd48d660dee", "name": "Internet", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "ip_address": "1.1.1.1", "mac_address": null}]	{e5fd38d4-3524-4f59-bf3a-998fea8f5b41}	[{"id": "b860c1a0-7696-400c-a84f-cc5e0b40b9e5", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 19:32:33.625035+00	2025-12-21 19:32:33.636124+00	f	{}
c6f5639d-d82d-4f9f-8f50-4d78119691f5	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "0e0f26c7-66b3-4086-94d3-9840c883bc9c"}	[{"id": "dadde791-28ec-49aa-ae17-dbf8db94cd87", "name": "Internet", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "ip_address": "203.0.113.31", "mac_address": null}]	{e1ceeb94-91f1-4596-846c-3fb5c08d7ce2}	[{"id": "93fabf55-e69c-4d4c-ab25-b6e6843a2294", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 19:32:33.625041+00	2025-12-21 19:32:33.640617+00	f	{}
3b940e3c-6642-4c60-a246-ae2563205c47	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "fb098bf3-5fe6-470f-b095-1acb778782a1"}	[{"id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370", "name": "Remote Network", "subnet_id": "437a199d-1ca7-47a2-aae0-6dd8cd7489d0", "ip_address": "203.0.113.213", "mac_address": null}]	{7575206c-5bad-4a31-9d90-81f442b88c47}	[{"id": "a4d50bcd-e4bc-4f11-8af1-40d871ed1f70", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 19:32:33.625046+00	2025-12-21 19:32:33.644574+00	f	{}
3821c08b-e152-4a46-97ea-24bdc60d0b21	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "5cfae996-c96d-4a95-beeb-46f01547ceb2", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.6", "mac_address": "FE:8C:23:DD:BB:3F"}]	{322387ef-9e04-4366-892d-4058bd7083d2}	[{"id": "d564f690-7d5a-47c3-9879-430501b9e6e6", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:20.616733273Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:33:20.616735+00	2025-12-21 19:33:34.824133+00	f	{}
a18188ff-d0b3-4192-8b2f-d6e2e334c1e7	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	scanopy-daemon	de38996a8038	Scanopy daemon	{"type": "None"}	[{"id": "19ed5cbe-89b8-475c-8a32-cf425b4359fc", "name": "eth0", "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.4", "mac_address": "82:CC:C6:3E:6C:BA"}]	{96988ba5-a81a-47c5-9c54-87af7ae35732}	[{"id": "618b1f0b-c2b7-4dbf-8de8-1ebb2e3243ce", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:32:33.784606740Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}	null	2025-12-21 19:32:33.701603+00	2025-12-21 19:32:33.825875+00	f	{}
26fb6ba9-c2d8-49c9-8013-97ee73d1fa58	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "e6df99b7-6776-424b-af6e-2017f6826995", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.5", "mac_address": "BA:F0:07:D3:32:21"}]	{d10af725-da37-4e5c-8752-afdfdd435f7b,93492b63-85c0-4f87-94e9-3cfa49777b6b}	[{"id": "e8335b78-30c6-4884-ad4b-3aab9c4d6c99", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "682a63a9-53a4-4e6c-a92b-301dc706aff4", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:06.146486047Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:33:06.146489+00	2025-12-21 19:33:20.543941+00	f	{}
a125fad3-ee74-417f-af8e-ca9aad2a7777	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "2435dfd1-6470-4844-b7bb-850f0aeaec1c", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.3", "mac_address": "32:7B:A7:BC:B8:B4"}]	{1021df77-55f4-4cbb-9fcd-131d82ff88f7}	[{"id": "7236427b-5fe4-4d53-a8ce-9cf2f17606ae", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:34.816750894Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:33:34.816752+00	2025-12-21 19:33:48.992878+00	f	{}
1d99528b-966f-4ccc-ac0b-ce3befe0b6cb	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "a5df539c-08da-48a5-b7b1-125e515520f6", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.1", "mac_address": "0E:44:E2:28:5F:75"}]	{43db47d2-839d-4eb7-b73d-d4528ced5850,5373c43a-9fce-4a57-93d6-fc0014e35441,d2948d43-544c-40e1-a5dc-ba018dcbf550,c715d31e-231b-4860-aee4-f81ea6bc9072}	[{"id": "d86baa1b-fea4-4821-9b16-a93c313a31b9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a67c71cf-9a13-467e-a3f6-4d8f076f588d", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "30c2bb55-8d8c-46c4-83d8-5aa1655838eb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "5dea8ffa-ed89-4088-9855-b99810f54f13", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:55.043476474Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:33:55.043479+00	2025-12-21 19:34:09.257935+00	f	{}
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
bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	My Network	2025-12-21 19:32:33.623423+00	2025-12-21 19:32:33.623423+00	f	f04c8ef0-eb25-4660-a050-e1ec6ea2ed74	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
f04c8ef0-eb25-4660-a050-e1ec6ea2ed74	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 19:32:33.616082+00	2025-12-21 19:34:10.074233+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
e5fd38d4-3524-4f59-bf3a-998fea8f5b41	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.625036+00	2025-12-21 19:32:33.625036+00	Cloudflare DNS	f719acfe-e6c2-458b-9578-e1d756d5a11c	[{"id": "5788e0be-391b-4251-baa2-f9b9c88fbe68", "type": "Port", "port_id": "b860c1a0-7696-400c-a84f-cc5e0b40b9e5", "interface_id": "345141c6-97c5-479c-9a9a-2fd48d660dee"}]	"Dns Server"	null	{"type": "System"}	{}
e1ceeb94-91f1-4596-846c-3fb5c08d7ce2	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.625042+00	2025-12-21 19:32:33.625042+00	Google.com	c6f5639d-d82d-4f9f-8f50-4d78119691f5	[{"id": "0e0f26c7-66b3-4086-94d3-9840c883bc9c", "type": "Port", "port_id": "93fabf55-e69c-4d4c-ab25-b6e6843a2294", "interface_id": "dadde791-28ec-49aa-ae17-dbf8db94cd87"}]	"Web Service"	null	{"type": "System"}	{}
7575206c-5bad-4a31-9d90-81f442b88c47	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.625047+00	2025-12-21 19:32:33.625047+00	Mobile Device	3b940e3c-6642-4c60-a246-ae2563205c47	[{"id": "fb098bf3-5fe6-470f-b095-1acb778782a1", "type": "Port", "port_id": "a4d50bcd-e4bc-4f11-8af1-40d871ed1f70", "interface_id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370"}]	"Client"	null	{"type": "System"}	{}
96988ba5-a81a-47c5-9c54-87af7ae35732	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.784625+00	2025-12-21 19:32:33.784625+00	Scanopy Daemon	a18188ff-d0b3-4192-8b2f-d6e2e334c1e7	[{"id": "b5e105b7-8a43-4319-9d75-80384c493d5c", "type": "Port", "port_id": "618b1f0b-c2b7-4dbf-8de8-1ebb2e3243ce", "interface_id": "19ed5cbe-89b8-475c-8a32-cf425b4359fc"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T19:32:33.784624242Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}	{}
93492b63-85c0-4f87-94e9-3cfa49777b6b	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:33:20.527224+00	2025-12-21 19:33:20.527224+00	Unclaimed Open Ports	26fb6ba9-c2d8-49c9-8013-97ee73d1fa58	[{"id": "7e37c383-9be6-411b-8712-490de7355cd2", "type": "Port", "port_id": "682a63a9-53a4-4e6c-a92b-301dc706aff4", "interface_id": "e6df99b7-6776-424b-af6e-2017f6826995"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:20.527206320Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d10af725-da37-4e5c-8752-afdfdd435f7b	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:33:11.946476+00	2025-12-21 19:33:11.946476+00	Home Assistant	26fb6ba9-c2d8-49c9-8013-97ee73d1fa58	[{"id": "6e8e5c6e-d5ad-4bf8-bc37-f0cb6513e039", "type": "Port", "port_id": "e8335b78-30c6-4884-ad4b-3aab9c4d6c99", "interface_id": "e6df99b7-6776-424b-af6e-2017f6826995"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:33:11.946459019Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
322387ef-9e04-4366-892d-4058bd7083d2	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:33:34.801777+00	2025-12-21 19:33:34.801777+00	PostgreSQL	3821c08b-e152-4a46-97ea-24bdc60d0b21	[{"id": "1f504966-2d12-4e6f-bdeb-e36fc6251d71", "type": "Port", "port_id": "d564f690-7d5a-47c3-9879-430501b9e6e6", "interface_id": "5cfae996-c96d-4a95-beeb-46f01547ceb2"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:34.801759518Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1021df77-55f4-4cbb-9fcd-131d82ff88f7	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:33:48.981674+00	2025-12-21 19:33:48.981674+00	Unclaimed Open Ports	a125fad3-ee74-417f-af8e-ca9aad2a7777	[{"id": "75449ba4-fe65-47cf-bbbf-6a7e99c7d3e8", "type": "Port", "port_id": "7236427b-5fe4-4d53-a8ce-9cf2f17606ae", "interface_id": "2435dfd1-6470-4844-b7bb-850f0aeaec1c"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:48.981653648Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5373c43a-9fce-4a57-93d6-fc0014e35441	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:34:05.687723+00	2025-12-21 19:34:05.687723+00	Scanopy Server	1d99528b-966f-4ccc-ac0b-ce3befe0b6cb	[{"id": "2d090b55-e0d6-4d40-8390-f66bc8614be3", "type": "Port", "port_id": "a67c71cf-9a13-467e-a3f6-4d8f076f588d", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:34:05.687704362Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
d2948d43-544c-40e1-a5dc-ba018dcbf550	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:34:09.24283+00	2025-12-21 19:34:09.24283+00	SSH	1d99528b-966f-4ccc-ac0b-ce3befe0b6cb	[{"id": "3cea8e70-5688-4be5-a726-525e80dddb88", "type": "Port", "port_id": "30c2bb55-8d8c-46c4-83d8-5aa1655838eb", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:34:09.242812449Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
c715d31e-231b-4860-aee4-f81ea6bc9072	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:34:09.243427+00	2025-12-21 19:34:09.243427+00	Unclaimed Open Ports	1d99528b-966f-4ccc-ac0b-ce3befe0b6cb	[{"id": "aa902d54-50fa-481d-b4f7-c7247a30d20c", "type": "Port", "port_id": "5dea8ffa-ed89-4088-9855-b99810f54f13", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:34:09.243418687Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
43db47d2-839d-4eb7-b73d-d4528ced5850	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:34:00.711757+00	2025-12-21 19:34:00.711757+00	Home Assistant	1d99528b-966f-4ccc-ac0b-ce3befe0b6cb	[{"id": "eae204f5-f7b4-480b-ba40-ea0506b00619", "type": "Port", "port_id": "d86baa1b-fea4-4821-9b16-a93c313a31b9", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:34:00.711739339Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: shares; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shares (id, topology_id, network_id, created_by, name, is_enabled, expires_at, password_hash, allowed_domains, options, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
092c0a6a-b8fc-474a-953d-991dafb727f6	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.624986+00	2025-12-21 19:32:33.624986+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
437a199d-1ca7-47a2-aae0-6dd8cd7489d0	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.62499+00	2025-12-21 19:32:33.62499+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
e1503e18-0f6d-4111-9308-93a4e66518c4	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	2025-12-21 19:32:33.719035+00	2025-12-21 19:32:33.719035+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:32:33.719033225Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
c902863d-4fae-443a-adeb-cc575ac628a4	f04c8ef0-eb25-4660-a050-e1ec6ea2ed74	New Tag	\N	2025-12-21 19:34:09.288756+00	2025-12-21 19:34:09.288756+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
345879df-2623-4782-adcd-3b414e9357e0	bfc13ca7-e4e7-49a7-8388-897bc40f4d5d	My Topology	[]	[{"id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "437a199d-1ca7-47a2-aae0-6dd8cd7489d0", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3b940e3c-6642-4c60-a246-ae2563205c47", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "437a199d-1ca7-47a2-aae0-6dd8cd7489d0", "interface_id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370"}, {"id": "345141c6-97c5-479c-9a9a-2fd48d660dee", "size": {"x": 250, "y": 100}, "header": null, "host_id": "f719acfe-e6c2-458b-9578-e1d756d5a11c", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "interface_id": "345141c6-97c5-479c-9a9a-2fd48d660dee"}, {"id": "dadde791-28ec-49aa-ae17-dbf8db94cd87", "size": {"x": 250, "y": 100}, "header": null, "host_id": "c6f5639d-d82d-4f9f-8f50-4d78119691f5", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "interface_id": "dadde791-28ec-49aa-ae17-dbf8db94cd87"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "f719acfe-e6c2-458b-9578-e1d756d5a11c", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "b860c1a0-7696-400c-a84f-cc5e0b40b9e5", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "5788e0be-391b-4251-baa2-f9b9c88fbe68"}, "hostname": null, "services": ["e5fd38d4-3524-4f59-bf3a-998fea8f5b41"], "created_at": "2025-12-21T19:32:33.625035Z", "interfaces": [{"id": "345141c6-97c5-479c-9a9a-2fd48d660dee", "name": "Internet", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.636124Z", "description": null, "virtualization": null}, {"id": "c6f5639d-d82d-4f9f-8f50-4d78119691f5", "name": "Google.com", "tags": [], "ports": [{"id": "93fabf55-e69c-4d4c-ab25-b6e6843a2294", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "0e0f26c7-66b3-4086-94d3-9840c883bc9c"}, "hostname": null, "services": ["e1ceeb94-91f1-4596-846c-3fb5c08d7ce2"], "created_at": "2025-12-21T19:32:33.625041Z", "interfaces": [{"id": "dadde791-28ec-49aa-ae17-dbf8db94cd87", "name": "Internet", "subnet_id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "ip_address": "203.0.113.31", "mac_address": null}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.640617Z", "description": null, "virtualization": null}, {"id": "3b940e3c-6642-4c60-a246-ae2563205c47", "name": "Mobile Device", "tags": [], "ports": [{"id": "a4d50bcd-e4bc-4f11-8af1-40d871ed1f70", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "fb098bf3-5fe6-470f-b095-1acb778782a1"}, "hostname": null, "services": ["7575206c-5bad-4a31-9d90-81f442b88c47"], "created_at": "2025-12-21T19:32:33.625046Z", "interfaces": [{"id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370", "name": "Remote Network", "subnet_id": "437a199d-1ca7-47a2-aae0-6dd8cd7489d0", "ip_address": "203.0.113.213", "mac_address": null}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.644574Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "618b1f0b-c2b7-4dbf-8de8-1ebb2e3243ce", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:32:33.784606740Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}, "target": {"type": "None"}, "hostname": "de38996a8038", "services": ["96988ba5-a81a-47c5-9c54-87af7ae35732"], "created_at": "2025-12-21T19:32:33.701603Z", "interfaces": [{"id": "19ed5cbe-89b8-475c-8a32-cf425b4359fc", "name": "eth0", "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.4", "mac_address": "82:CC:C6:3E:6C:BA"}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.825875Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "26fb6ba9-c2d8-49c9-8013-97ee73d1fa58", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "e8335b78-30c6-4884-ad4b-3aab9c4d6c99", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "682a63a9-53a4-4e6c-a92b-301dc706aff4", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:06.146486047Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["d10af725-da37-4e5c-8752-afdfdd435f7b", "93492b63-85c0-4f87-94e9-3cfa49777b6b"], "created_at": "2025-12-21T19:33:06.146489Z", "interfaces": [{"id": "e6df99b7-6776-424b-af6e-2017f6826995", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.5", "mac_address": "BA:F0:07:D3:32:21"}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:20.543941Z", "description": null, "virtualization": null}, {"id": "3821c08b-e152-4a46-97ea-24bdc60d0b21", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "d564f690-7d5a-47c3-9879-430501b9e6e6", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:20.616733273Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["322387ef-9e04-4366-892d-4058bd7083d2"], "created_at": "2025-12-21T19:33:20.616735Z", "interfaces": [{"id": "5cfae996-c96d-4a95-beeb-46f01547ceb2", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.6", "mac_address": "FE:8C:23:DD:BB:3F"}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:34.824133Z", "description": null, "virtualization": null}, {"id": "a125fad3-ee74-417f-af8e-ca9aad2a7777", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "7236427b-5fe4-4d53-a8ce-9cf2f17606ae", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:34.816750894Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["1021df77-55f4-4cbb-9fcd-131d82ff88f7"], "created_at": "2025-12-21T19:33:34.816752Z", "interfaces": [{"id": "2435dfd1-6470-4844-b7bb-850f0aeaec1c", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.3", "mac_address": "32:7B:A7:BC:B8:B4"}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:48.992878Z", "description": null, "virtualization": null}, {"id": "1d99528b-966f-4ccc-ac0b-ce3befe0b6cb", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "d86baa1b-fea4-4821-9b16-a93c313a31b9", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a67c71cf-9a13-467e-a3f6-4d8f076f588d", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "30c2bb55-8d8c-46c4-83d8-5aa1655838eb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "5dea8ffa-ed89-4088-9855-b99810f54f13", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:33:55.043476474Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["43db47d2-839d-4eb7-b73d-d4528ced5850", "5373c43a-9fce-4a57-93d6-fc0014e35441", "d2948d43-544c-40e1-a5dc-ba018dcbf550", "c715d31e-231b-4860-aee4-f81ea6bc9072"], "created_at": "2025-12-21T19:33:55.043479Z", "interfaces": [{"id": "a5df539c-08da-48a5-b7b1-125e515520f6", "name": null, "subnet_id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "ip_address": "172.25.0.1", "mac_address": "0E:44:E2:28:5F:75"}], "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:09.257935Z", "description": null, "virtualization": null}]	[{"id": "092c0a6a-b8fc-474a-953d-991dafb727f6", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T19:32:33.624986Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.624986Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "437a199d-1ca7-47a2-aae0-6dd8cd7489d0", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T19:32:33.624990Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.624990Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "e1503e18-0f6d-4111-9308-93a4e66518c4", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:32:33.719033225Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}, "created_at": "2025-12-21T19:32:33.719035Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.719035Z", "description": null, "subnet_type": "Lan"}]	[{"id": "e5fd38d4-3524-4f59-bf3a-998fea8f5b41", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "f719acfe-e6c2-458b-9578-e1d756d5a11c", "bindings": [{"id": "5788e0be-391b-4251-baa2-f9b9c88fbe68", "type": "Port", "port_id": "b860c1a0-7696-400c-a84f-cc5e0b40b9e5", "interface_id": "345141c6-97c5-479c-9a9a-2fd48d660dee"}], "created_at": "2025-12-21T19:32:33.625036Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.625036Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "e1ceeb94-91f1-4596-846c-3fb5c08d7ce2", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "c6f5639d-d82d-4f9f-8f50-4d78119691f5", "bindings": [{"id": "0e0f26c7-66b3-4086-94d3-9840c883bc9c", "type": "Port", "port_id": "93fabf55-e69c-4d4c-ab25-b6e6843a2294", "interface_id": "dadde791-28ec-49aa-ae17-dbf8db94cd87"}], "created_at": "2025-12-21T19:32:33.625042Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.625042Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "7575206c-5bad-4a31-9d90-81f442b88c47", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "3b940e3c-6642-4c60-a246-ae2563205c47", "bindings": [{"id": "fb098bf3-5fe6-470f-b095-1acb778782a1", "type": "Port", "port_id": "a4d50bcd-e4bc-4f11-8af1-40d871ed1f70", "interface_id": "30d0296e-585c-4b9c-b22c-ed7edbe9e370"}], "created_at": "2025-12-21T19:32:33.625047Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.625047Z", "virtualization": null, "service_definition": "Client"}, {"id": "96988ba5-a81a-47c5-9c54-87af7ae35732", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T19:32:33.784624242Z", "type": "SelfReport", "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a"}]}, "host_id": "a18188ff-d0b3-4192-8b2f-d6e2e334c1e7", "bindings": [{"id": "b5e105b7-8a43-4319-9d75-80384c493d5c", "type": "Port", "port_id": "618b1f0b-c2b7-4dbf-8de8-1ebb2e3243ce", "interface_id": "19ed5cbe-89b8-475c-8a32-cf425b4359fc"}], "created_at": "2025-12-21T19:32:33.784625Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:32:33.784625Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "d10af725-da37-4e5c-8752-afdfdd435f7b", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:33:11.946459019Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "26fb6ba9-c2d8-49c9-8013-97ee73d1fa58", "bindings": [{"id": "6e8e5c6e-d5ad-4bf8-bc37-f0cb6513e039", "type": "Port", "port_id": "e8335b78-30c6-4884-ad4b-3aab9c4d6c99", "interface_id": "e6df99b7-6776-424b-af6e-2017f6826995"}], "created_at": "2025-12-21T19:33:11.946476Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:11.946476Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "93492b63-85c0-4f87-94e9-3cfa49777b6b", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:20.527206320Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "26fb6ba9-c2d8-49c9-8013-97ee73d1fa58", "bindings": [{"id": "7e37c383-9be6-411b-8712-490de7355cd2", "type": "Port", "port_id": "682a63a9-53a4-4e6c-a92b-301dc706aff4", "interface_id": "e6df99b7-6776-424b-af6e-2017f6826995"}], "created_at": "2025-12-21T19:33:20.527224Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:20.527224Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "322387ef-9e04-4366-892d-4058bd7083d2", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:34.801759518Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "3821c08b-e152-4a46-97ea-24bdc60d0b21", "bindings": [{"id": "1f504966-2d12-4e6f-bdeb-e36fc6251d71", "type": "Port", "port_id": "d564f690-7d5a-47c3-9879-430501b9e6e6", "interface_id": "5cfae996-c96d-4a95-beeb-46f01547ceb2"}], "created_at": "2025-12-21T19:33:34.801777Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:34.801777Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "1021df77-55f4-4cbb-9fcd-131d82ff88f7", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:33:48.981653648Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "a125fad3-ee74-417f-af8e-ca9aad2a7777", "bindings": [{"id": "75449ba4-fe65-47cf-bbbf-6a7e99c7d3e8", "type": "Port", "port_id": "7236427b-5fe4-4d53-a8ce-9cf2f17606ae", "interface_id": "2435dfd1-6470-4844-b7bb-850f0aeaec1c"}], "created_at": "2025-12-21T19:33:48.981674Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:33:48.981674Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "43db47d2-839d-4eb7-b73d-d4528ced5850", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:34:00.711739339Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1d99528b-966f-4ccc-ac0b-ce3befe0b6cb", "bindings": [{"id": "eae204f5-f7b4-480b-ba40-ea0506b00619", "type": "Port", "port_id": "d86baa1b-fea4-4821-9b16-a93c313a31b9", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}], "created_at": "2025-12-21T19:34:00.711757Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:00.711757Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "5373c43a-9fce-4a57-93d6-fc0014e35441", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:34:05.687704362Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1d99528b-966f-4ccc-ac0b-ce3befe0b6cb", "bindings": [{"id": "2d090b55-e0d6-4d40-8390-f66bc8614be3", "type": "Port", "port_id": "a67c71cf-9a13-467e-a3f6-4d8f076f588d", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}], "created_at": "2025-12-21T19:34:05.687723Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:05.687723Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "d2948d43-544c-40e1-a5dc-ba018dcbf550", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:34:09.242812449Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1d99528b-966f-4ccc-ac0b-ce3befe0b6cb", "bindings": [{"id": "3cea8e70-5688-4be5-a726-525e80dddb88", "type": "Port", "port_id": "30c2bb55-8d8c-46c4-83d8-5aa1655838eb", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}], "created_at": "2025-12-21T19:34:09.242830Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:09.242830Z", "virtualization": null, "service_definition": "SSH"}, {"id": "c715d31e-231b-4860-aee4-f81ea6bc9072", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:34:09.243418687Z", "type": "Network", "daemon_id": "dffae1f2-cc64-4bdf-8a0d-5872bbd60d8a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "1d99528b-966f-4ccc-ac0b-ce3befe0b6cb", "bindings": [{"id": "aa902d54-50fa-481d-b4f7-c7247a30d20c", "type": "Port", "port_id": "5dea8ffa-ed89-4088-9855-b99810f54f13", "interface_id": "a5df539c-08da-48a5-b7b1-125e515520f6"}], "created_at": "2025-12-21T19:34:09.243427Z", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:09.243427Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "8b5d76f6-b824-444c-875a-1e8ba8d9c760", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T19:34:09.280468Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "bfc13ca7-e4e7-49a7-8388-897bc40f4d5d", "updated_at": "2025-12-21T19:34:09.280468Z", "description": null, "service_bindings": []}]	t	2025-12-21 19:32:33.649291+00	f	\N	\N	{64c788b6-d46d-4342-8f32-a9e0f7238a4a,0ae13a53-6ac4-4e82-b49f-ae745ed95b72}	{cff0c146-c6df-4367-92e2-9f6a4c67c5e5}	{61a81b81-7341-4dd6-82b8-c31b9600b54a}	{7ce19eed-68a2-44b0-b68c-d558b3a4378b}	\N	2025-12-21 19:32:33.64525+00	2025-12-21 19:34:10.228316+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
6d600c04-34e3-4183-903f-37d959bba5eb	2025-12-21 19:32:33.619458+00	2025-12-21 19:32:33.619458+00	$argon2id$v=19$m=19456,t=2,p=1$qGeBi7+j1P/gwxfdRYSkqw$0m9CNwR/pbiR4sGWV0SeFuelAJ0NiY8vHqegKQ9ME20	\N	\N	\N	user@gmail.com	f04c8ef0-eb25-4660-a050-e1ec6ea2ed74	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
BwtedRyx4IQpUDGwpaZ3FQ	\\x93c4101577a6a5b031502984e0b11c755e0b0781a7757365725f6964d92436643630306330342d333465332d343138332d393033662d33376439353962626135656299cd07ea14132021ce2b4562cb000000	2026-01-20 19:32:33.725967+00
KBw_fQ4QPEhzgidEp0EoHQ	\\x93c4101d2841a744278273483c100e7d3f1c2882a7757365725f6964d92436643630306330342d333465332d343138332d393033662d333764393539626261356562ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92466373231346638342d666137302d343263632d383938392d653032653133653865373934a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea14132209ce30c53f20000000	2026-01-20 19:34:09.818233+00
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

\unrestrict CNp8aeSlUgQgnLSfkEbrwB1laDhRntkcjmZHhvWcwQDaJuq9w5bMeCk2tkVkpD5

