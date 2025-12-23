--
-- PostgreSQL database dump
--

\restrict 61zkfAli2f7sBBM30LkDfmd8Sa4wuvEdXeBUrQGbEa6tJzbQDNl70OjkY5WYR7x

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
20251006215000	users	2025-12-23 19:34:36.910699+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3533711
20251006215100	networks	2025-12-23 19:34:36.915505+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5007814
20251006215151	create hosts	2025-12-23 19:34:36.920833+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3839444
20251006215155	create subnets	2025-12-23 19:34:36.924992+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3966123
20251006215201	create groups	2025-12-23 19:34:36.929298+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4005155
20251006215204	create daemons	2025-12-23 19:34:36.933653+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4287134
20251006215212	create services	2025-12-23 19:34:36.938298+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4884934
20251029193448	user-auth	2025-12-23 19:34:36.943532+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6886131
20251030044828	daemon api	2025-12-23 19:34:36.950826+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1647027
20251030170438	host-hide	2025-12-23 19:34:36.952794+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1159884
20251102224919	create discovery	2025-12-23 19:34:36.954267+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	12938386
20251106235621	normalize-daemon-cols	2025-12-23 19:34:36.967644+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2070239
20251107034459	api keys	2025-12-23 19:34:36.969895+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	9834849
20251107222650	oidc-auth	2025-12-23 19:34:36.980062+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	30724144
20251110181948	orgs-billing	2025-12-23 19:34:37.011123+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	13043793
20251113223656	group-enhancements	2025-12-23 19:34:37.024505+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1102907
20251117032720	daemon-mode	2025-12-23 19:34:37.025909+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1182636
20251118143058	set-default-plan	2025-12-23 19:34:37.027383+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1468822
20251118225043	save-topology	2025-12-23 19:34:37.029163+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	10025167
20251123232748	network-permissions	2025-12-23 19:34:37.039543+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2894324
20251125001342	billing-updates	2025-12-23 19:34:37.042743+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	992450
20251128035448	org-onboarding-status	2025-12-23 19:34:37.044042+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1454298
20251129180942	nfs-consolidate	2025-12-23 19:34:37.04581+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1266951
20251206052641	discovery-progress	2025-12-23 19:34:37.047377+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1738127
20251206202200	plan-fix	2025-12-23 19:34:37.049408+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	962263
20251207061341	daemon-url	2025-12-23 19:34:37.050681+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2403453
20251210045929	tags	2025-12-23 19:34:37.053428+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8869664
20251210175035	terms	2025-12-23 19:34:37.06267+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	949627
20251213025048	hash-keys	2025-12-23 19:34:37.063948+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	14592626
20251214050638	scanopy	2025-12-23 19:34:37.078917+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1520322
20251215215724	topo-scanopy-fix	2025-12-23 19:34:37.08077+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	832760
20251217153736	category rename	2025-12-23 19:34:37.081911+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1744941
20251218053111	invite-persistence	2025-12-23 19:34:37.08396+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5332730
20251219211216	create shares	2025-12-23 19:34:37.089666+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6773062
20251220170928	permissions-cleanup	2025-12-23 19:34:37.096884+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1515447
20251220180000	commercial-to-community	2025-12-23 19:34:37.098711+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	928219
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
b06cccd0-452d-4cbe-8c66-0987a48b60ea	2f027a0d0adce2982954655e52c33baf48d929b535895c9b1f48a18d7371ed82	02c25a66-107c-4a70-8328-84d676aa8cd9	Integrated Daemon API Key	2025-12-23 19:34:39.516218+00	2025-12-23 19:36:18.556306+00	2025-12-23 19:36:18.555147+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
af15a603-a2dc-445b-8dc4-a726f6cfb85a	02c25a66-107c-4a70-8328-84d676aa8cd9	7635f416-af76-4081-aec7-5760976d21db	2025-12-23 19:34:39.531898+00	2025-12-23 19:35:55.309888+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["16b4c044-4fd5-4238-b82a-bba21ce1fc30"]}	2025-12-23 19:35:55.311935+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
ff0a259f-6caf-4bbd-8812-b107760c6405	02c25a66-107c-4a70-8328-84d676aa8cd9	af15a603-a2dc-445b-8dc4-a726f6cfb85a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db"}	Self Report	2025-12-23 19:34:39.603202+00	2025-12-23 19:34:39.603202+00	{}
5c5094b8-8d36-4418-8a64-d9eb1d8c34d4	02c25a66-107c-4a70-8328-84d676aa8cd9	af15a603-a2dc-445b-8dc4-a726f6cfb85a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-23 19:34:39.611264+00	2025-12-23 19:34:39.611264+00	{}
25649238-c309-4784-bfe2-99478e179c0d	02c25a66-107c-4a70-8328-84d676aa8cd9	af15a603-a2dc-445b-8dc4-a726f6cfb85a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "session_id": "d5e649d0-f4cd-4456-9105-6b6fdf830a08", "started_at": "2025-12-23T19:34:39.610865281Z", "finished_at": "2025-12-23T19:34:39.651227113Z", "discovery_type": {"type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db"}}}	{"type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db"}	Self Report	2025-12-23 19:34:39.610865+00	2025-12-23 19:34:39.655103+00	{}
95e15e96-f851-4193-ae40-4c8becee04df	02c25a66-107c-4a70-8328-84d676aa8cd9	af15a603-a2dc-445b-8dc4-a726f6cfb85a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "session_id": "b79505b5-589f-4749-b35c-c51fea3cf4c9", "started_at": "2025-12-23T19:34:39.668250784Z", "finished_at": "2025-12-23T19:36:18.552427222Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-23 19:34:39.66825+00	2025-12-23 19:36:18.555426+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
70403855-ee69-4138-ba98-5439b9282198	02c25a66-107c-4a70-8328-84d676aa8cd9		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-23 19:36:18.569668+00	2025-12-23 19:36:18.569668+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
1794ce06-3874-4dfd-a6d0-b5e8c1b1384a	02c25a66-107c-4a70-8328-84d676aa8cd9	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "07b67963-a6f3-4d6c-a4d9-9387acc9a37c"}	[{"id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4", "name": "Internet", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "ip_address": "1.1.1.1", "mac_address": null}]	{b031d8d7-b783-4888-a831-3b083dda5501}	[{"id": "9d8d362e-05c5-46c5-96f2-6e0a72725d50", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-23 19:34:39.488147+00	2025-12-23 19:34:39.499211+00	f	{}
ee90b431-a153-45f7-89a6-22218934af81	02c25a66-107c-4a70-8328-84d676aa8cd9	Google.com	\N	\N	{"type": "ServiceBinding", "config": "53fbbed4-9110-4b3a-8ee8-b68066f99a4f"}	[{"id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9", "name": "Internet", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "ip_address": "203.0.113.77", "mac_address": null}]	{4faeba64-aca5-46db-8e5a-4a15488ad2b3}	[{"id": "60fd3f47-de32-422b-adb3-df67e3c9f0a3", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-23 19:34:39.488154+00	2025-12-23 19:34:39.503885+00	f	{}
2f10835c-bc2c-40d0-a060-0d8bd91ef3e4	02c25a66-107c-4a70-8328-84d676aa8cd9	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "8e4a06f8-212b-4abc-8e2a-a9d5187339ac"}	[{"id": "590736db-5972-4c49-9a4d-677ffa177c45", "name": "Remote Network", "subnet_id": "77cc230b-68e7-4f76-9687-b566f6dc01ca", "ip_address": "203.0.113.186", "mac_address": null}]	{053e3fe5-bdd0-4978-905c-f9c2dba33764}	[{"id": "923738d4-7220-4565-8077-7e7e6c5f9d41", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-23 19:34:39.488161+00	2025-12-23 19:34:39.508724+00	f	{}
dedc8bc4-e212-4cb3-8df6-bc716b1ea53f	02c25a66-107c-4a70-8328-84d676aa8cd9	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "935db454-ce9b-4bd1-aa0c-35a2ed7191c8", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.6", "mac_address": "5E:C8:67:41:2F:7B"}]	{39578003-2d01-461d-8e8e-a55ed32fe03b}	[{"id": "6d83854b-648c-4803-bea5-0336531f3bd0", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:27.414306086Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-23 19:35:27.414309+00	2025-12-23 19:35:42.439941+00	f	{}
7635f416-af76-4081-aec7-5760976d21db	02c25a66-107c-4a70-8328-84d676aa8cd9	scanopy-daemon	5bb40c53826a	Scanopy daemon	{"type": "None"}	[{"id": "19186ae9-7d2d-44bf-87e6-2a0aa2384861", "name": "eth0", "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.4", "mac_address": "AE:66:DC:21:0B:6E"}]	{3f7156df-4050-4d5a-b4c5-0eddd7f18b47}	[{"id": "dc99e10a-02a3-43eb-bc80-864133646beb", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:34:39.630730858Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}	null	2025-12-23 19:34:39.527608+00	2025-12-23 19:34:39.647321+00	f	{}
40a3d5f4-7aa0-4922-92c5-3b0a6b0b8683	02c25a66-107c-4a70-8328-84d676aa8cd9	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "ce38d1ad-0652-4de2-83d5-2077952436c8", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.3", "mac_address": "52:F2:4E:F8:6A:D4"}]	{070625c3-a1bb-4bc5-87d3-f907250165d6}	[{"id": "1f8b7953-6cb9-4045-a988-f2120ec31345", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:12.215966611Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-23 19:35:12.21597+00	2025-12-23 19:35:27.366434+00	f	{}
8aaae33b-d39c-4564-8ae5-6772411d466c	02c25a66-107c-4a70-8328-84d676aa8cd9	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "5b5c0588-de4b-488e-ad9f-e94f857794fd", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.5", "mac_address": "32:17:9A:39:8C:A0"}]	{6099bb51-6925-4875-854d-badf386581ad,939d0a6a-b998-484b-a324-5d4fb4854146}	[{"id": "8a0363a1-099a-44f2-a4a9-3acb396275d7", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "0bf453b4-a677-4901-a068-d687715ef1e4", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:42.477325510Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-23 19:35:42.477328+00	2025-12-23 19:35:57.457953+00	f	{}
28ede4d9-7606-4527-a78f-2a61791e7da0	02c25a66-107c-4a70-8328-84d676aa8cd9	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "185387a0-49e4-460c-b24e-c13073c190bf", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.1", "mac_address": "1E:38:82:D0:5B:39"}]	{58f0dd93-95a6-46d5-8953-1f1e1bedbbd9,3e171552-6bb8-48f1-886a-7b5ed32d9ce7,171c903c-5040-466c-b962-9df3578536ef,4e4d28b6-84f4-4d5e-a86e-61020c19bcec}	[{"id": "bc265e95-a61e-4abc-aeaa-86cbb04b6f27", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "b9aea8f9-c894-4c07-a70b-a4a388e85032", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "139d37ba-65c5-430a-a6dc-0b05ef44a931", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "dc5d1f18-4e9f-4b0a-b98c-e29032399a58", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:36:03.505931899Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-23 19:36:03.505934+00	2025-12-23 19:36:18.54588+00	f	{}
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
02c25a66-107c-4a70-8328-84d676aa8cd9	My Network	2025-12-23 19:34:39.486618+00	2025-12-23 19:34:39.486618+00	f	6daf298e-54c4-4d3c-8745-0f4c898b2681	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
6daf298e-54c4-4d3c-8745-0f4c898b2681	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-23 19:34:39.479735+00	2025-12-23 19:36:19.41556+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
b031d8d7-b783-4888-a831-3b083dda5501	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.48815+00	2025-12-23 19:34:39.48815+00	Cloudflare DNS	1794ce06-3874-4dfd-a6d0-b5e8c1b1384a	[{"id": "07b67963-a6f3-4d6c-a4d9-9387acc9a37c", "type": "Port", "port_id": "9d8d362e-05c5-46c5-96f2-6e0a72725d50", "interface_id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4"}]	"Dns Server"	null	{"type": "System"}	{}
4faeba64-aca5-46db-8e5a-4a15488ad2b3	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.488155+00	2025-12-23 19:34:39.488155+00	Google.com	ee90b431-a153-45f7-89a6-22218934af81	[{"id": "53fbbed4-9110-4b3a-8ee8-b68066f99a4f", "type": "Port", "port_id": "60fd3f47-de32-422b-adb3-df67e3c9f0a3", "interface_id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9"}]	"Web Service"	null	{"type": "System"}	{}
053e3fe5-bdd0-4978-905c-f9c2dba33764	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.488163+00	2025-12-23 19:34:39.488163+00	Mobile Device	2f10835c-bc2c-40d0-a060-0d8bd91ef3e4	[{"id": "8e4a06f8-212b-4abc-8e2a-a9d5187339ac", "type": "Port", "port_id": "923738d4-7220-4565-8077-7e7e6c5f9d41", "interface_id": "590736db-5972-4c49-9a4d-677ffa177c45"}]	"Client"	null	{"type": "System"}	{}
3f7156df-4050-4d5a-b4c5-0eddd7f18b47	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.630754+00	2025-12-23 19:34:39.630754+00	Scanopy Daemon	7635f416-af76-4081-aec7-5760976d21db	[{"id": "f8d73a44-9984-4d71-9c7b-1dbd5f0ce834", "type": "Port", "port_id": "dc99e10a-02a3-43eb-bc80-864133646beb", "interface_id": "19186ae9-7d2d-44bf-87e6-2a0aa2384861"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-23T19:34:39.630753290Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}	{}
070625c3-a1bb-4bc5-87d3-f907250165d6	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:35:20.583556+00	2025-12-23 19:35:20.583556+00	Scanopy Server	40a3d5f4-7aa0-4922-92c5-3b0a6b0b8683	[{"id": "6104ecf8-e155-486a-aa4c-339acd4b71b5", "type": "Port", "port_id": "1f8b7953-6cb9-4045-a988-f2120ec31345", "interface_id": "ce38d1ad-0652-4de2-83d5-2077952436c8"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:35:20.583537746Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
39578003-2d01-461d-8e8e-a55ed32fe03b	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:35:42.422875+00	2025-12-23 19:35:42.422875+00	PostgreSQL	dedc8bc4-e212-4cb3-8df6-bc716b1ea53f	[{"id": "214466a6-01ea-40d1-887b-5665d15d6935", "type": "Port", "port_id": "6d83854b-648c-4803-bea5-0336531f3bd0", "interface_id": "935db454-ce9b-4bd1-aa0c-35a2ed7191c8"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:35:42.422859276Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6099bb51-6925-4875-854d-badf386581ad	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:35:54.468721+00	2025-12-23 19:35:54.468721+00	Home Assistant	8aaae33b-d39c-4564-8ae5-6772411d466c	[{"id": "71de66e6-f508-4931-9985-92de19f3ec1d", "type": "Port", "port_id": "8a0363a1-099a-44f2-a4a9-3acb396275d7", "interface_id": "5b5c0588-de4b-488e-ad9f-e94f857794fd"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:35:54.468704828Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
939d0a6a-b998-484b-a324-5d4fb4854146	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:35:57.442737+00	2025-12-23 19:35:57.442737+00	Unclaimed Open Ports	8aaae33b-d39c-4564-8ae5-6772411d466c	[{"id": "802387cd-093c-4abe-bdda-50f26628e543", "type": "Port", "port_id": "0bf453b4-a677-4901-a068-d687715ef1e4", "interface_id": "5b5c0588-de4b-488e-ad9f-e94f857794fd"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:35:57.442718108Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
171c903c-5040-466c-b962-9df3578536ef	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:36:18.5323+00	2025-12-23 19:36:18.5323+00	SSH	28ede4d9-7606-4527-a78f-2a61791e7da0	[{"id": "2683c40d-e893-434c-b094-38302eafeedc", "type": "Port", "port_id": "139d37ba-65c5-430a-a6dc-0b05ef44a931", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:36:18.532284226Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
4e4d28b6-84f4-4d5e-a86e-61020c19bcec	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:36:18.53264+00	2025-12-23 19:36:18.53264+00	Unclaimed Open Ports	28ede4d9-7606-4527-a78f-2a61791e7da0	[{"id": "90dfe009-287b-4d2f-86a4-99046e12712b", "type": "Port", "port_id": "dc5d1f18-4e9f-4b0a-b98c-e29032399a58", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:36:18.532632198Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
58f0dd93-95a6-46d5-8953-1f1e1bedbbd9	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:36:11.748039+00	2025-12-23 19:36:11.748039+00	Scanopy Server	28ede4d9-7606-4527-a78f-2a61791e7da0	[{"id": "b63218ec-3754-4e9f-a460-48d1bae93722", "type": "Port", "port_id": "bc265e95-a61e-4abc-aeaa-86cbb04b6f27", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:36:11.748018816Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
3e171552-6bb8-48f1-886a-7b5ed32d9ce7	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:36:15.526832+00	2025-12-23 19:36:15.526832+00	Home Assistant	28ede4d9-7606-4527-a78f-2a61791e7da0	[{"id": "d3ef9f4f-b827-42c0-a308-53c0c187ddf4", "type": "Port", "port_id": "b9aea8f9-c894-4c07-a70b-a4a388e85032", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:36:15.526814146Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
406e9720-2139-4793-b623-c490ce3eb7d3	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.488088+00	2025-12-23 19:34:39.488088+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
77cc230b-68e7-4f76-9687-b566f6dc01ca	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.488092+00	2025-12-23 19:34:39.488092+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
16b4c044-4fd5-4238-b82a-bba21ce1fc30	02c25a66-107c-4a70-8328-84d676aa8cd9	2025-12-23 19:34:39.611041+00	2025-12-23 19:34:39.611041+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-23T19:34:39.611040730Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
db7b81cf-f95f-450f-9eff-cd504b7ce7a3	6daf298e-54c4-4d3c-8745-0f4c898b2681	New Tag	\N	2025-12-23 19:36:18.582025+00	2025-12-23 19:36:18.582025+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
f80ff393-583c-45ed-8e13-5d16c894caed	02c25a66-107c-4a70-8328-84d676aa8cd9	My Topology	[]	[{"id": "406e9720-2139-4793-b623-c490ce3eb7d3", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "77cc230b-68e7-4f76-9687-b566f6dc01ca", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4", "size": {"x": 250, "y": 100}, "header": null, "host_id": "1794ce06-3874-4dfd-a6d0-b5e8c1b1384a", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "interface_id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4"}, {"id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9", "size": {"x": 250, "y": 100}, "header": null, "host_id": "ee90b431-a153-45f7-89a6-22218934af81", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "interface_id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9"}, {"id": "590736db-5972-4c49-9a4d-677ffa177c45", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2f10835c-bc2c-40d0-a060-0d8bd91ef3e4", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "77cc230b-68e7-4f76-9687-b566f6dc01ca", "interface_id": "590736db-5972-4c49-9a4d-677ffa177c45"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "1794ce06-3874-4dfd-a6d0-b5e8c1b1384a", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "9d8d362e-05c5-46c5-96f2-6e0a72725d50", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "07b67963-a6f3-4d6c-a4d9-9387acc9a37c"}, "hostname": null, "services": ["b031d8d7-b783-4888-a831-3b083dda5501"], "created_at": "2025-12-23T19:34:39.488147Z", "interfaces": [{"id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4", "name": "Internet", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.499211Z", "description": null, "virtualization": null}, {"id": "ee90b431-a153-45f7-89a6-22218934af81", "name": "Google.com", "tags": [], "ports": [{"id": "60fd3f47-de32-422b-adb3-df67e3c9f0a3", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "53fbbed4-9110-4b3a-8ee8-b68066f99a4f"}, "hostname": null, "services": ["4faeba64-aca5-46db-8e5a-4a15488ad2b3"], "created_at": "2025-12-23T19:34:39.488154Z", "interfaces": [{"id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9", "name": "Internet", "subnet_id": "406e9720-2139-4793-b623-c490ce3eb7d3", "ip_address": "203.0.113.77", "mac_address": null}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.503885Z", "description": null, "virtualization": null}, {"id": "2f10835c-bc2c-40d0-a060-0d8bd91ef3e4", "name": "Mobile Device", "tags": [], "ports": [{"id": "923738d4-7220-4565-8077-7e7e6c5f9d41", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8e4a06f8-212b-4abc-8e2a-a9d5187339ac"}, "hostname": null, "services": ["053e3fe5-bdd0-4978-905c-f9c2dba33764"], "created_at": "2025-12-23T19:34:39.488161Z", "interfaces": [{"id": "590736db-5972-4c49-9a4d-677ffa177c45", "name": "Remote Network", "subnet_id": "77cc230b-68e7-4f76-9687-b566f6dc01ca", "ip_address": "203.0.113.186", "mac_address": null}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.508724Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "7635f416-af76-4081-aec7-5760976d21db", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "dc99e10a-02a3-43eb-bc80-864133646beb", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:34:39.630730858Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}, "target": {"type": "None"}, "hostname": "5bb40c53826a", "services": ["3f7156df-4050-4d5a-b4c5-0eddd7f18b47"], "created_at": "2025-12-23T19:34:39.527608Z", "interfaces": [{"id": "19186ae9-7d2d-44bf-87e6-2a0aa2384861", "name": "eth0", "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.4", "mac_address": "AE:66:DC:21:0B:6E"}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.647321Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "40a3d5f4-7aa0-4922-92c5-3b0a6b0b8683", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "1f8b7953-6cb9-4045-a988-f2120ec31345", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:12.215966611Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["070625c3-a1bb-4bc5-87d3-f907250165d6"], "created_at": "2025-12-23T19:35:12.215970Z", "interfaces": [{"id": "ce38d1ad-0652-4de2-83d5-2077952436c8", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.3", "mac_address": "52:F2:4E:F8:6A:D4"}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:27.366434Z", "description": null, "virtualization": null}, {"id": "dedc8bc4-e212-4cb3-8df6-bc716b1ea53f", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "6d83854b-648c-4803-bea5-0336531f3bd0", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:27.414306086Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["39578003-2d01-461d-8e8e-a55ed32fe03b"], "created_at": "2025-12-23T19:35:27.414309Z", "interfaces": [{"id": "935db454-ce9b-4bd1-aa0c-35a2ed7191c8", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.6", "mac_address": "5E:C8:67:41:2F:7B"}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:42.439941Z", "description": null, "virtualization": null}, {"id": "8aaae33b-d39c-4564-8ae5-6772411d466c", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "8a0363a1-099a-44f2-a4a9-3acb396275d7", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "0bf453b4-a677-4901-a068-d687715ef1e4", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:35:42.477325510Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["6099bb51-6925-4875-854d-badf386581ad", "939d0a6a-b998-484b-a324-5d4fb4854146"], "created_at": "2025-12-23T19:35:42.477328Z", "interfaces": [{"id": "5b5c0588-de4b-488e-ad9f-e94f857794fd", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.5", "mac_address": "32:17:9A:39:8C:A0"}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:57.457953Z", "description": null, "virtualization": null}, {"id": "28ede4d9-7606-4527-a78f-2a61791e7da0", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "bc265e95-a61e-4abc-aeaa-86cbb04b6f27", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "b9aea8f9-c894-4c07-a70b-a4a388e85032", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "139d37ba-65c5-430a-a6dc-0b05ef44a931", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "dc5d1f18-4e9f-4b0a-b98c-e29032399a58", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:36:03.505931899Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["58f0dd93-95a6-46d5-8953-1f1e1bedbbd9", "3e171552-6bb8-48f1-886a-7b5ed32d9ce7", "171c903c-5040-466c-b962-9df3578536ef", "4e4d28b6-84f4-4d5e-a86e-61020c19bcec"], "created_at": "2025-12-23T19:36:03.505934Z", "interfaces": [{"id": "185387a0-49e4-460c-b24e-c13073c190bf", "name": null, "subnet_id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "ip_address": "172.25.0.1", "mac_address": "1E:38:82:D0:5B:39"}], "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:18.545880Z", "description": null, "virtualization": null}]	[{"id": "406e9720-2139-4793-b623-c490ce3eb7d3", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-23T19:34:39.488088Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.488088Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "77cc230b-68e7-4f76-9687-b566f6dc01ca", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-23T19:34:39.488092Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.488092Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "16b4c044-4fd5-4238-b82a-bba21ce1fc30", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-23T19:34:39.611040730Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}, "created_at": "2025-12-23T19:34:39.611041Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.611041Z", "description": null, "subnet_type": "Lan"}]	[{"id": "b031d8d7-b783-4888-a831-3b083dda5501", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "1794ce06-3874-4dfd-a6d0-b5e8c1b1384a", "bindings": [{"id": "07b67963-a6f3-4d6c-a4d9-9387acc9a37c", "type": "Port", "port_id": "9d8d362e-05c5-46c5-96f2-6e0a72725d50", "interface_id": "a4e9aeb0-7704-4b8b-ba84-b43c24203fa4"}], "created_at": "2025-12-23T19:34:39.488150Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.488150Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "4faeba64-aca5-46db-8e5a-4a15488ad2b3", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "ee90b431-a153-45f7-89a6-22218934af81", "bindings": [{"id": "53fbbed4-9110-4b3a-8ee8-b68066f99a4f", "type": "Port", "port_id": "60fd3f47-de32-422b-adb3-df67e3c9f0a3", "interface_id": "ca120437-76f0-4ffb-8b9c-5710c6e1a9a9"}], "created_at": "2025-12-23T19:34:39.488155Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.488155Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "053e3fe5-bdd0-4978-905c-f9c2dba33764", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "2f10835c-bc2c-40d0-a060-0d8bd91ef3e4", "bindings": [{"id": "8e4a06f8-212b-4abc-8e2a-a9d5187339ac", "type": "Port", "port_id": "923738d4-7220-4565-8077-7e7e6c5f9d41", "interface_id": "590736db-5972-4c49-9a4d-677ffa177c45"}], "created_at": "2025-12-23T19:34:39.488163Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.488163Z", "virtualization": null, "service_definition": "Client"}, {"id": "3f7156df-4050-4d5a-b4c5-0eddd7f18b47", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-23T19:34:39.630753290Z", "type": "SelfReport", "host_id": "7635f416-af76-4081-aec7-5760976d21db", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a"}]}, "host_id": "7635f416-af76-4081-aec7-5760976d21db", "bindings": [{"id": "f8d73a44-9984-4d71-9c7b-1dbd5f0ce834", "type": "Port", "port_id": "dc99e10a-02a3-43eb-bc80-864133646beb", "interface_id": "19186ae9-7d2d-44bf-87e6-2a0aa2384861"}], "created_at": "2025-12-23T19:34:39.630754Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:34:39.630754Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "070625c3-a1bb-4bc5-87d3-f907250165d6", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:35:20.583537746Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "40a3d5f4-7aa0-4922-92c5-3b0a6b0b8683", "bindings": [{"id": "6104ecf8-e155-486a-aa4c-339acd4b71b5", "type": "Port", "port_id": "1f8b7953-6cb9-4045-a988-f2120ec31345", "interface_id": "ce38d1ad-0652-4de2-83d5-2077952436c8"}], "created_at": "2025-12-23T19:35:20.583556Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:20.583556Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "39578003-2d01-461d-8e8e-a55ed32fe03b", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:35:42.422859276Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "dedc8bc4-e212-4cb3-8df6-bc716b1ea53f", "bindings": [{"id": "214466a6-01ea-40d1-887b-5665d15d6935", "type": "Port", "port_id": "6d83854b-648c-4803-bea5-0336531f3bd0", "interface_id": "935db454-ce9b-4bd1-aa0c-35a2ed7191c8"}], "created_at": "2025-12-23T19:35:42.422875Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:42.422875Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "6099bb51-6925-4875-854d-badf386581ad", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:35:54.468704828Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8aaae33b-d39c-4564-8ae5-6772411d466c", "bindings": [{"id": "71de66e6-f508-4931-9985-92de19f3ec1d", "type": "Port", "port_id": "8a0363a1-099a-44f2-a4a9-3acb396275d7", "interface_id": "5b5c0588-de4b-488e-ad9f-e94f857794fd"}], "created_at": "2025-12-23T19:35:54.468721Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:54.468721Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "939d0a6a-b998-484b-a324-5d4fb4854146", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:35:57.442718108Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "8aaae33b-d39c-4564-8ae5-6772411d466c", "bindings": [{"id": "802387cd-093c-4abe-bdda-50f26628e543", "type": "Port", "port_id": "0bf453b4-a677-4901-a068-d687715ef1e4", "interface_id": "5b5c0588-de4b-488e-ad9f-e94f857794fd"}], "created_at": "2025-12-23T19:35:57.442737Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:35:57.442737Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "58f0dd93-95a6-46d5-8953-1f1e1bedbbd9", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:36:11.748018816Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "28ede4d9-7606-4527-a78f-2a61791e7da0", "bindings": [{"id": "b63218ec-3754-4e9f-a460-48d1bae93722", "type": "Port", "port_id": "bc265e95-a61e-4abc-aeaa-86cbb04b6f27", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}], "created_at": "2025-12-23T19:36:11.748039Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:11.748039Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "3e171552-6bb8-48f1-886a-7b5ed32d9ce7", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-23T19:36:15.526814146Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "28ede4d9-7606-4527-a78f-2a61791e7da0", "bindings": [{"id": "d3ef9f4f-b827-42c0-a308-53c0c187ddf4", "type": "Port", "port_id": "b9aea8f9-c894-4c07-a70b-a4a388e85032", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}], "created_at": "2025-12-23T19:36:15.526832Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:15.526832Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "171c903c-5040-466c-b962-9df3578536ef", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:36:18.532284226Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "28ede4d9-7606-4527-a78f-2a61791e7da0", "bindings": [{"id": "2683c40d-e893-434c-b094-38302eafeedc", "type": "Port", "port_id": "139d37ba-65c5-430a-a6dc-0b05ef44a931", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}], "created_at": "2025-12-23T19:36:18.532300Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:18.532300Z", "virtualization": null, "service_definition": "SSH"}, {"id": "4e4d28b6-84f4-4d5e-a86e-61020c19bcec", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-23T19:36:18.532632198Z", "type": "Network", "daemon_id": "af15a603-a2dc-445b-8dc4-a726f6cfb85a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "28ede4d9-7606-4527-a78f-2a61791e7da0", "bindings": [{"id": "90dfe009-287b-4d2f-86a4-99046e12712b", "type": "Port", "port_id": "dc5d1f18-4e9f-4b0a-b98c-e29032399a58", "interface_id": "185387a0-49e4-460c-b24e-c13073c190bf"}], "created_at": "2025-12-23T19:36:18.532640Z", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:18.532640Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "70403855-ee69-4138-ba98-5439b9282198", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-23T19:36:18.569668Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "02c25a66-107c-4a70-8328-84d676aa8cd9", "updated_at": "2025-12-23T19:36:18.569668Z", "description": null, "service_bindings": []}]	t	2025-12-23 19:34:39.513666+00	f	\N	\N	{0d8bc271-ab9d-4172-b092-63f68b655545,4bd5b4a9-b77e-4016-bd18-6f20636d24ca}	{4e0ca57b-d538-44ea-9112-aa7acebc295a}	{fcc894a6-b39f-4823-866b-e0bdcc218a16}	{b45fff4b-f853-4def-b839-e6e7ede22c09}	\N	2025-12-23 19:34:39.509486+00	2025-12-23 19:36:19.585829+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
6e6d569a-0899-4e73-adf0-6fa17927f8ce	2025-12-23 19:34:39.482794+00	2025-12-23 19:34:39.482794+00	$argon2id$v=19$m=19456,t=2,p=1$EaODI4CL+H182EjF7OIzCg$EcC4pEyVtdBGUCJWP53ZYj7Qp4dbla5OjiMcpv0sRFE	\N	\N	\N	user@gmail.com	6daf298e-54c4-4d3c-8745-0f4c898b2681	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
e4gklpFxcUItkYpC5N_f6w	\\x93c410ebdfdfe4428a912d427171919624887b81a7757365725f6964d92436653664353639612d303839392d346537332d616466302d36666131373932376638636599cd07ea16132227ce25268164000000	2026-01-22 19:34:39.62328+00
0xfBrqfAa2lcfU8HBBzx4A	\\x93c410e0f11c04074f7d5c696bc0a7aec117d382a7757365725f6964d92436653664353639612d303839392d346537332d616466302d366661313739323766386365ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92461613231393033382d333432322d343738302d393339632d333964613762356663306332a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea16132413ce08bde81c000000	2026-01-22 19:36:19.146663+00
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

\unrestrict 61zkfAli2f7sBBM30LkDfmd8Sa4wuvEdXeBUrQGbEa6tJzbQDNl70OjkY5WYR7x

