--
-- PostgreSQL database dump
--

\restrict 9dHXcYWo6khqjckk2uJZEeJOsu0IEltnOCH5nWXQULVasj3BeWybBOMuqT8J4io

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
20251006215000	users	2025-12-21 17:23:51.268421+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3613955
20251006215100	networks	2025-12-21 17:23:51.273007+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4479743
20251006215151	create hosts	2025-12-21 17:23:51.277839+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3837340
20251006215155	create subnets	2025-12-21 17:23:51.282016+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3811565
20251006215201	create groups	2025-12-21 17:23:51.286256+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4798084
20251006215204	create daemons	2025-12-21 17:23:51.291421+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4127007
20251006215212	create services	2025-12-21 17:23:51.2959+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4881700
20251029193448	user-auth	2025-12-21 17:23:51.301126+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5584810
20251030044828	daemon api	2025-12-21 17:23:51.306982+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1468489
20251030170438	host-hide	2025-12-21 17:23:51.308719+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1048258
20251102224919	create discovery	2025-12-21 17:23:51.310034+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10299235
20251106235621	normalize-daemon-cols	2025-12-21 17:23:51.32064+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1877187
20251107034459	api keys	2025-12-21 17:23:51.322803+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7867196
20251107222650	oidc-auth	2025-12-21 17:23:51.330965+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	25868842
20251110181948	orgs-billing	2025-12-21 17:23:51.357158+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10880565
20251113223656	group-enhancements	2025-12-21 17:23:51.368358+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1006109
20251117032720	daemon-mode	2025-12-21 17:23:51.369631+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1191082
20251118143058	set-default-plan	2025-12-21 17:23:51.37109+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1123898
20251118225043	save-topology	2025-12-21 17:23:51.372485+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8769283
20251123232748	network-permissions	2025-12-21 17:23:51.38162+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2772400
20251125001342	billing-updates	2025-12-21 17:23:51.384681+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	916563
20251128035448	org-onboarding-status	2025-12-21 17:23:51.385872+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1379503
20251129180942	nfs-consolidate	2025-12-21 17:23:51.387524+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1198096
20251206052641	discovery-progress	2025-12-21 17:23:51.388992+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1577881
20251206202200	plan-fix	2025-12-21 17:23:51.390836+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1035834
20251207061341	daemon-url	2025-12-21 17:23:51.392197+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2274626
20251210045929	tags	2025-12-21 17:23:51.39477+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8883766
20251210175035	terms	2025-12-21 17:23:51.403999+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	867432
20251213025048	hash-keys	2025-12-21 17:23:51.40514+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9087234
20251214050638	scanopy	2025-12-21 17:23:51.41457+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1367691
20251215215724	topo-scanopy-fix	2025-12-21 17:23:51.416237+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	714027
20251217153736	category rename	2025-12-21 17:23:51.417239+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1763066
20251218053111	invite-persistence	2025-12-21 17:23:51.419286+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5052217
20251219211216	create shares	2025-12-21 17:23:51.42464+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6671335
20251220170928	permissions-cleanup	2025-12-21 17:23:51.431664+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1447600
20251220180000	commercial-to-community	2025-12-21 17:23:51.433399+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	812820
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
084396d3-8e3c-4903-96c2-3c4019f26709	0f6174ea454ff54b7beac63cd8be3e065dc81dcdfb5c9cb4d77af19d0794f57f	7332b341-929a-4e1e-8d09-17626ae1b2ed	Integrated Daemon API Key	2025-12-21 17:23:54.753973+00	2025-12-21 17:25:31.997402+00	2025-12-21 17:25:31.996617+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
9b2002e6-4e44-4c8f-83f7-cd14be059b91	7332b341-929a-4e1e-8d09-17626ae1b2ed	31265c74-de1d-4884-9d39-9ca351070d79	2025-12-21 17:23:54.815219+00	2025-12-21 17:25:11.184096+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["6393da85-40a1-400b-96f4-3e9f78c79143"]}	2025-12-21 17:25:11.18498+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
67e5e95e-04ce-432d-8b36-3e73fda3f7a6	7332b341-929a-4e1e-8d09-17626ae1b2ed	9b2002e6-4e44-4c8f-83f7-cd14be059b91	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79"}	Self Report	2025-12-21 17:23:54.820663+00	2025-12-21 17:23:54.820663+00	{}
67c9edb3-5403-40d7-a288-4703482856f7	7332b341-929a-4e1e-8d09-17626ae1b2ed	9b2002e6-4e44-4c8f-83f7-cd14be059b91	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 17:23:54.827074+00	2025-12-21 17:23:54.827074+00	{}
1b73d532-24b9-4934-bed8-65a3fbf3b837	7332b341-929a-4e1e-8d09-17626ae1b2ed	9b2002e6-4e44-4c8f-83f7-cd14be059b91	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "session_id": "be915db1-838f-441a-b960-5e158c15a419", "started_at": "2025-12-21T17:23:54.826733857Z", "finished_at": "2025-12-21T17:23:54.986193556Z", "discovery_type": {"type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79"}}}	{"type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79"}	Self Report	2025-12-21 17:23:54.826733+00	2025-12-21 17:23:54.990759+00	{}
92ce5b67-17c5-4156-b545-c5c3432e820f	7332b341-929a-4e1e-8d09-17626ae1b2ed	9b2002e6-4e44-4c8f-83f7-cd14be059b91	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "session_id": "03f4cc7d-2d7a-4bb8-a160-a434311c35f7", "started_at": "2025-12-21T17:23:55.004573051Z", "finished_at": "2025-12-21T17:25:31.994776936Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 17:23:55.004573+00	2025-12-21 17:25:31.996847+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
7bd16458-b11e-47e6-b3a0-4d8b6899130d	7332b341-929a-4e1e-8d09-17626ae1b2ed		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 17:25:32.009032+00	2025-12-21 17:25:32.009032+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
776b2fe1-1c7e-487a-8926-be5f9e981e4c	7332b341-929a-4e1e-8d09-17626ae1b2ed	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "1a2df58e-97a7-4f90-a275-a63cd33aa8d0"}	[{"id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3", "name": "Internet", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "ip_address": "1.1.1.1", "mac_address": null}]	{0a8fb84c-d686-4cbe-90eb-41e7facfe689}	[{"id": "3ffd8e7f-73c8-4e3b-be63-bd7e8641b11d", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 17:23:54.727479+00	2025-12-21 17:23:54.737959+00	f	{}
244d901d-ef1d-460f-9902-f820aeb9da1a	7332b341-929a-4e1e-8d09-17626ae1b2ed	Google.com	\N	\N	{"type": "ServiceBinding", "config": "37725b36-925d-432b-a902-c58991040f92"}	[{"id": "e649655d-a127-42e7-835d-dab35e464a73", "name": "Internet", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "ip_address": "203.0.113.217", "mac_address": null}]	{9c0a5917-f93d-475b-8dc4-819dce042db0}	[{"id": "8c945210-60d9-4d53-b354-10f60f5593c9", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 17:23:54.727486+00	2025-12-21 17:23:54.742321+00	f	{}
06d74fc2-8328-435a-a3d4-30c925990e2a	7332b341-929a-4e1e-8d09-17626ae1b2ed	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "779d2c5e-c033-478b-baeb-58131a9bb9bf"}	[{"id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e", "name": "Remote Network", "subnet_id": "08563fad-47aa-4442-83a0-80f40fb8ff47", "ip_address": "203.0.113.85", "mac_address": null}]	{ffb76345-9fd9-4ded-9e2a-b6a0cb34b12e}	[{"id": "b5dfdfaa-361d-4e63-9878-1c81d6a87a5a", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 17:23:54.727491+00	2025-12-21 17:23:54.746461+00	f	{}
29049fc2-6ad5-45e7-9aa3-46f58f94351f	7332b341-929a-4e1e-8d09-17626ae1b2ed	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "4ec62b03-8f14-4e8b-a566-8be6935c053f", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.6", "mac_address": "EE:B3:E4:FA:A5:AE"}]	{2865bdcc-5194-4192-8509-5a1821d22d77}	[{"id": "9817e147-241b-4bdc-a95c-4e3e932a3dbe", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:42.217998101Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 17:24:42.218+00	2025-12-21 17:24:56.780441+00	f	{}
31265c74-de1d-4884-9d39-9ca351070d79	7332b341-929a-4e1e-8d09-17626ae1b2ed	scanopy-daemon	b50eb60cb48a	Scanopy daemon	{"type": "None"}	[{"id": "80b4f0fb-37aa-4aa7-aeec-8048c5ea49d0", "name": "eth0", "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.4", "mac_address": "7E:3D:1E:AC:22:E9"}]	{9891876a-1500-487a-ad5b-f575c1c4fd8c}	[{"id": "41ab2b8f-f92b-4703-a991-9ac6cbeb0945", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:23:54.914962854Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}	null	2025-12-21 17:23:54.81002+00	2025-12-21 17:23:54.983663+00	f	{}
fd1e36e6-9b45-414d-881d-72d2763629f7	7332b341-929a-4e1e-8d09-17626ae1b2ed	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "567e350c-aba3-45a6-a195-3d907af1eb7a", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.5", "mac_address": "9A:A1:09:00:F3:B9"}]	{3604968b-60c3-4b1f-995a-4ce0683f597d,fb5cfa67-ad70-45b5-b839-f02b2153de5e}	[{"id": "f513e3b2-6ae9-4c77-b0d3-24de27e38098", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "dfc36830-c87f-48cb-9c01-732ff1d4f862", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:27.582295871Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 17:24:27.582298+00	2025-12-21 17:24:42.141276+00	f	{}
869fb100-e6a8-453d-81cf-adaec09b40fb	7332b341-929a-4e1e-8d09-17626ae1b2ed	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "31ebb18d-5c54-469a-9f0c-7f51d30ed547", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.3", "mac_address": "06:D9:71:9A:FC:E8"}]	{7bd73cd1-1cbf-4d93-a37c-b6d2f16eff09}	[{"id": "b11c4f16-5889-47a7-b8a4-c9a195cd7f58", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:56.778978993Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 17:24:56.778981+00	2025-12-21 17:25:11.347915+00	f	{}
40b09c8e-68b2-4f85-8fd6-d900b297b019	7332b341-929a-4e1e-8d09-17626ae1b2ed	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "55bc55b7-2c99-46a5-af29-63cefdf51847", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.1", "mac_address": "16:4B:39:9A:F1:57"}]	{f5359f06-b667-4b98-bf73-51e1145575ad,869e1a88-5330-41b4-9169-0af92ec04dbd,6346572f-9115-41d0-a1d4-cfac7a42a2c2,1ae0e410-2ee6-4d3b-a664-a14c92d47426}	[{"id": "65c91ddb-13a8-42ba-b8ee-1ccdf5540ab1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "f0750f05-95a7-4f3e-b200-7b81257bb640", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "7c1f36ad-2467-4d28-bd3d-04132d5de5c2", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "6dd63d3b-b71d-4318-b3f1-9ce779f28140", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:25:17.399826863Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 17:25:17.39983+00	2025-12-21 17:25:31.989542+00	f	{}
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
7332b341-929a-4e1e-8d09-17626ae1b2ed	My Network	2025-12-21 17:23:54.725984+00	2025-12-21 17:23:54.725984+00	f	e0cf7c2f-4544-49b7-a3cd-943dc4eccfeb	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
e0cf7c2f-4544-49b7-a3cd-943dc4eccfeb	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 17:23:54.718933+00	2025-12-21 17:25:32.809011+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
0a8fb84c-d686-4cbe-90eb-41e7facfe689	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.727481+00	2025-12-21 17:23:54.727481+00	Cloudflare DNS	776b2fe1-1c7e-487a-8926-be5f9e981e4c	[{"id": "1a2df58e-97a7-4f90-a275-a63cd33aa8d0", "type": "Port", "port_id": "3ffd8e7f-73c8-4e3b-be63-bd7e8641b11d", "interface_id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3"}]	"Dns Server"	null	{"type": "System"}	{}
9c0a5917-f93d-475b-8dc4-819dce042db0	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.727487+00	2025-12-21 17:23:54.727487+00	Google.com	244d901d-ef1d-460f-9902-f820aeb9da1a	[{"id": "37725b36-925d-432b-a902-c58991040f92", "type": "Port", "port_id": "8c945210-60d9-4d53-b354-10f60f5593c9", "interface_id": "e649655d-a127-42e7-835d-dab35e464a73"}]	"Web Service"	null	{"type": "System"}	{}
ffb76345-9fd9-4ded-9e2a-b6a0cb34b12e	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.727492+00	2025-12-21 17:23:54.727492+00	Mobile Device	06d74fc2-8328-435a-a3d4-30c925990e2a	[{"id": "779d2c5e-c033-478b-baeb-58131a9bb9bf", "type": "Port", "port_id": "b5dfdfaa-361d-4e63-9878-1c81d6a87a5a", "interface_id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e"}]	"Client"	null	{"type": "System"}	{}
9891876a-1500-487a-ad5b-f575c1c4fd8c	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.91498+00	2025-12-21 17:23:54.91498+00	Scanopy Daemon	31265c74-de1d-4884-9d39-9ca351070d79	[{"id": "e04f4cf4-12d4-447c-a930-34857ff8c92f", "type": "Port", "port_id": "41ab2b8f-f92b-4703-a991-9ac6cbeb0945", "interface_id": "80b4f0fb-37aa-4aa7-aeec-8048c5ea49d0"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T17:23:54.914979125Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}	{}
3604968b-60c3-4b1f-995a-4ce0683f597d	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:24:33.435911+00	2025-12-21 17:24:33.435911+00	Home Assistant	fd1e36e6-9b45-414d-881d-72d2763629f7	[{"id": "08563a3f-990f-4ed5-b163-d007bded7763", "type": "Port", "port_id": "f513e3b2-6ae9-4c77-b0d3-24de27e38098", "interface_id": "567e350c-aba3-45a6-a195-3d907af1eb7a"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:24:33.435895228Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
fb5cfa67-ad70-45b5-b839-f02b2153de5e	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:24:42.123598+00	2025-12-21 17:24:42.123598+00	Unclaimed Open Ports	fd1e36e6-9b45-414d-881d-72d2763629f7	[{"id": "26fc4269-08d1-43a8-ba61-e62b6c38b534", "type": "Port", "port_id": "dfc36830-c87f-48cb-9c01-732ff1d4f862", "interface_id": "567e350c-aba3-45a6-a195-3d907af1eb7a"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:24:42.123578755Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
2865bdcc-5194-4192-8509-5a1821d22d77	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:24:56.768204+00	2025-12-21 17:24:56.768204+00	PostgreSQL	29049fc2-6ad5-45e7-9aa3-46f58f94351f	[{"id": "9cc00c8e-103f-4c3e-b092-bb37fcbb098a", "type": "Port", "port_id": "9817e147-241b-4bdc-a95c-4e3e932a3dbe", "interface_id": "4ec62b03-8f14-4e8b-a566-8be6935c053f"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:24:56.768185056Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7bd73cd1-1cbf-4d93-a37c-b6d2f16eff09	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:25:07.656319+00	2025-12-21 17:25:07.656319+00	Scanopy Server	869fb100-e6a8-453d-81cf-adaec09b40fb	[{"id": "4a683104-12c8-4b68-9d29-970835cdbc54", "type": "Port", "port_id": "b11c4f16-5889-47a7-b8a4-c9a195cd7f58", "interface_id": "31ebb18d-5c54-469a-9f0c-7f51d30ed547"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:07.656300106Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
f5359f06-b667-4b98-bf73-51e1145575ad	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:25:23.292816+00	2025-12-21 17:25:23.292816+00	Home Assistant	40b09c8e-68b2-4f85-8fd6-d900b297b019	[{"id": "beb0bf7b-7895-48df-a64f-4b4fb525cee6", "type": "Port", "port_id": "65c91ddb-13a8-42ba-b8ee-1ccdf5540ab1", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:23.292796146Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
869e1a88-5330-41b4-9169-0af92ec04dbd	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:25:28.330926+00	2025-12-21 17:25:28.330926+00	Scanopy Server	40b09c8e-68b2-4f85-8fd6-d900b297b019	[{"id": "8e2a36d7-1155-43d2-9d58-b1433f201a06", "type": "Port", "port_id": "f0750f05-95a7-4f3e-b200-7b81257bb640", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:28.330909251Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
6346572f-9115-41d0-a1d4-cfac7a42a2c2	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:25:31.976805+00	2025-12-21 17:25:31.976805+00	SSH	40b09c8e-68b2-4f85-8fd6-d900b297b019	[{"id": "f65e0a1b-95a0-4b97-9976-bf6ce1487ab3", "type": "Port", "port_id": "7c1f36ad-2467-4d28-bd3d-04132d5de5c2", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:25:31.976787120Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
1ae0e410-2ee6-4d3b-a664-a14c92d47426	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:25:31.977415+00	2025-12-21 17:25:31.977415+00	Unclaimed Open Ports	40b09c8e-68b2-4f85-8fd6-d900b297b019	[{"id": "aac19687-e344-4f3b-bf57-ffabd524d59d", "type": "Port", "port_id": "6dd63d3b-b71d-4318-b3f1-9ce779f28140", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:25:31.977406571Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
163438ee-81fe-4dff-b14f-bf2ce4a185cb	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.727428+00	2025-12-21 17:23:54.727428+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
08563fad-47aa-4442-83a0-80f40fb8ff47	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.727432+00	2025-12-21 17:23:54.727432+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
6393da85-40a1-400b-96f4-3e9f78c79143	7332b341-929a-4e1e-8d09-17626ae1b2ed	2025-12-21 17:23:54.826884+00	2025-12-21 17:23:54.826884+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T17:23:54.826883205Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
61d2f4d7-4ac4-4b31-9b9a-513b7c808995	e0cf7c2f-4544-49b7-a3cd-943dc4eccfeb	New Tag	\N	2025-12-21 17:25:32.015916+00	2025-12-21 17:25:32.015916+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
1d5e2aea-73f0-4b4b-b0f1-f760d378c3f3	7332b341-929a-4e1e-8d09-17626ae1b2ed	My Topology	[]	[{"id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "08563fad-47aa-4442-83a0-80f40fb8ff47", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3", "size": {"x": 250, "y": 100}, "header": null, "host_id": "776b2fe1-1c7e-487a-8926-be5f9e981e4c", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "interface_id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3"}, {"id": "e649655d-a127-42e7-835d-dab35e464a73", "size": {"x": 250, "y": 100}, "header": null, "host_id": "244d901d-ef1d-460f-9902-f820aeb9da1a", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "interface_id": "e649655d-a127-42e7-835d-dab35e464a73"}, {"id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e", "size": {"x": 250, "y": 100}, "header": null, "host_id": "06d74fc2-8328-435a-a3d4-30c925990e2a", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "08563fad-47aa-4442-83a0-80f40fb8ff47", "interface_id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "776b2fe1-1c7e-487a-8926-be5f9e981e4c", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "3ffd8e7f-73c8-4e3b-be63-bd7e8641b11d", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "1a2df58e-97a7-4f90-a275-a63cd33aa8d0"}, "hostname": null, "services": ["0a8fb84c-d686-4cbe-90eb-41e7facfe689"], "created_at": "2025-12-21T17:23:54.727479Z", "interfaces": [{"id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3", "name": "Internet", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.737959Z", "description": null, "virtualization": null}, {"id": "244d901d-ef1d-460f-9902-f820aeb9da1a", "name": "Google.com", "tags": [], "ports": [{"id": "8c945210-60d9-4d53-b354-10f60f5593c9", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "37725b36-925d-432b-a902-c58991040f92"}, "hostname": null, "services": ["9c0a5917-f93d-475b-8dc4-819dce042db0"], "created_at": "2025-12-21T17:23:54.727486Z", "interfaces": [{"id": "e649655d-a127-42e7-835d-dab35e464a73", "name": "Internet", "subnet_id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "ip_address": "203.0.113.217", "mac_address": null}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.742321Z", "description": null, "virtualization": null}, {"id": "06d74fc2-8328-435a-a3d4-30c925990e2a", "name": "Mobile Device", "tags": [], "ports": [{"id": "b5dfdfaa-361d-4e63-9878-1c81d6a87a5a", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "779d2c5e-c033-478b-baeb-58131a9bb9bf"}, "hostname": null, "services": ["ffb76345-9fd9-4ded-9e2a-b6a0cb34b12e"], "created_at": "2025-12-21T17:23:54.727491Z", "interfaces": [{"id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e", "name": "Remote Network", "subnet_id": "08563fad-47aa-4442-83a0-80f40fb8ff47", "ip_address": "203.0.113.85", "mac_address": null}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.746461Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "31265c74-de1d-4884-9d39-9ca351070d79", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "41ab2b8f-f92b-4703-a991-9ac6cbeb0945", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:23:54.914962854Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}, "target": {"type": "None"}, "hostname": "b50eb60cb48a", "services": ["9891876a-1500-487a-ad5b-f575c1c4fd8c"], "created_at": "2025-12-21T17:23:54.810020Z", "interfaces": [{"id": "80b4f0fb-37aa-4aa7-aeec-8048c5ea49d0", "name": "eth0", "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.4", "mac_address": "7E:3D:1E:AC:22:E9"}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.983663Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "fd1e36e6-9b45-414d-881d-72d2763629f7", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "f513e3b2-6ae9-4c77-b0d3-24de27e38098", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "dfc36830-c87f-48cb-9c01-732ff1d4f862", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:27.582295871Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["3604968b-60c3-4b1f-995a-4ce0683f597d", "fb5cfa67-ad70-45b5-b839-f02b2153de5e"], "created_at": "2025-12-21T17:24:27.582298Z", "interfaces": [{"id": "567e350c-aba3-45a6-a195-3d907af1eb7a", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.5", "mac_address": "9A:A1:09:00:F3:B9"}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:24:42.141276Z", "description": null, "virtualization": null}, {"id": "29049fc2-6ad5-45e7-9aa3-46f58f94351f", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "9817e147-241b-4bdc-a95c-4e3e932a3dbe", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:42.217998101Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["2865bdcc-5194-4192-8509-5a1821d22d77"], "created_at": "2025-12-21T17:24:42.218Z", "interfaces": [{"id": "4ec62b03-8f14-4e8b-a566-8be6935c053f", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.6", "mac_address": "EE:B3:E4:FA:A5:AE"}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:24:56.780441Z", "description": null, "virtualization": null}, {"id": "869fb100-e6a8-453d-81cf-adaec09b40fb", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "b11c4f16-5889-47a7-b8a4-c9a195cd7f58", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:24:56.778978993Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["7bd73cd1-1cbf-4d93-a37c-b6d2f16eff09"], "created_at": "2025-12-21T17:24:56.778981Z", "interfaces": [{"id": "31ebb18d-5c54-469a-9f0c-7f51d30ed547", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.3", "mac_address": "06:D9:71:9A:FC:E8"}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:11.347915Z", "description": null, "virtualization": null}, {"id": "40b09c8e-68b2-4f85-8fd6-d900b297b019", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "65c91ddb-13a8-42ba-b8ee-1ccdf5540ab1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "f0750f05-95a7-4f3e-b200-7b81257bb640", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "7c1f36ad-2467-4d28-bd3d-04132d5de5c2", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "6dd63d3b-b71d-4318-b3f1-9ce779f28140", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:25:17.399826863Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["f5359f06-b667-4b98-bf73-51e1145575ad", "869e1a88-5330-41b4-9169-0af92ec04dbd", "6346572f-9115-41d0-a1d4-cfac7a42a2c2", "1ae0e410-2ee6-4d3b-a664-a14c92d47426"], "created_at": "2025-12-21T17:25:17.399830Z", "interfaces": [{"id": "55bc55b7-2c99-46a5-af29-63cefdf51847", "name": null, "subnet_id": "6393da85-40a1-400b-96f4-3e9f78c79143", "ip_address": "172.25.0.1", "mac_address": "16:4B:39:9A:F1:57"}], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:31.989542Z", "description": null, "virtualization": null}, {"id": "24064773-b873-4e24-a943-6d62366f0bc0", "name": "Service Test Host", "tags": [], "ports": [], "hidden": false, "source": {"type": "System"}, "target": {"type": "Hostname"}, "hostname": "service-test.local", "services": [], "created_at": "2025-12-21T17:25:32.666704Z", "interfaces": [], "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:32.676011Z", "description": null, "virtualization": null}]	[{"id": "163438ee-81fe-4dff-b14f-bf2ce4a185cb", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T17:23:54.727428Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.727428Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "08563fad-47aa-4442-83a0-80f40fb8ff47", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T17:23:54.727432Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.727432Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "6393da85-40a1-400b-96f4-3e9f78c79143", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T17:23:54.826883205Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}, "created_at": "2025-12-21T17:23:54.826884Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.826884Z", "description": null, "subnet_type": "Lan"}]	[{"id": "0a8fb84c-d686-4cbe-90eb-41e7facfe689", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "776b2fe1-1c7e-487a-8926-be5f9e981e4c", "bindings": [{"id": "1a2df58e-97a7-4f90-a275-a63cd33aa8d0", "type": "Port", "port_id": "3ffd8e7f-73c8-4e3b-be63-bd7e8641b11d", "interface_id": "ceb359bf-e184-4570-a58f-bd532c7ac1b3"}], "created_at": "2025-12-21T17:23:54.727481Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.727481Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "9c0a5917-f93d-475b-8dc4-819dce042db0", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "244d901d-ef1d-460f-9902-f820aeb9da1a", "bindings": [{"id": "37725b36-925d-432b-a902-c58991040f92", "type": "Port", "port_id": "8c945210-60d9-4d53-b354-10f60f5593c9", "interface_id": "e649655d-a127-42e7-835d-dab35e464a73"}], "created_at": "2025-12-21T17:23:54.727487Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.727487Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "ffb76345-9fd9-4ded-9e2a-b6a0cb34b12e", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "06d74fc2-8328-435a-a3d4-30c925990e2a", "bindings": [{"id": "779d2c5e-c033-478b-baeb-58131a9bb9bf", "type": "Port", "port_id": "b5dfdfaa-361d-4e63-9878-1c81d6a87a5a", "interface_id": "d68d64b3-8dc8-4a74-8fe3-d617ba80978e"}], "created_at": "2025-12-21T17:23:54.727492Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.727492Z", "virtualization": null, "service_definition": "Client"}, {"id": "9891876a-1500-487a-ad5b-f575c1c4fd8c", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T17:23:54.914979125Z", "type": "SelfReport", "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91"}]}, "host_id": "31265c74-de1d-4884-9d39-9ca351070d79", "bindings": [{"id": "e04f4cf4-12d4-447c-a930-34857ff8c92f", "type": "Port", "port_id": "41ab2b8f-f92b-4703-a991-9ac6cbeb0945", "interface_id": "80b4f0fb-37aa-4aa7-aeec-8048c5ea49d0"}], "created_at": "2025-12-21T17:23:54.914980Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:23:54.914980Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "3604968b-60c3-4b1f-995a-4ce0683f597d", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:24:33.435895228Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "fd1e36e6-9b45-414d-881d-72d2763629f7", "bindings": [{"id": "08563a3f-990f-4ed5-b163-d007bded7763", "type": "Port", "port_id": "f513e3b2-6ae9-4c77-b0d3-24de27e38098", "interface_id": "567e350c-aba3-45a6-a195-3d907af1eb7a"}], "created_at": "2025-12-21T17:24:33.435911Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:24:33.435911Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "fb5cfa67-ad70-45b5-b839-f02b2153de5e", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:24:42.123578755Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "fd1e36e6-9b45-414d-881d-72d2763629f7", "bindings": [{"id": "26fc4269-08d1-43a8-ba61-e62b6c38b534", "type": "Port", "port_id": "dfc36830-c87f-48cb-9c01-732ff1d4f862", "interface_id": "567e350c-aba3-45a6-a195-3d907af1eb7a"}], "created_at": "2025-12-21T17:24:42.123598Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:24:42.123598Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "2865bdcc-5194-4192-8509-5a1821d22d77", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:24:56.768185056Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "29049fc2-6ad5-45e7-9aa3-46f58f94351f", "bindings": [{"id": "9cc00c8e-103f-4c3e-b092-bb37fcbb098a", "type": "Port", "port_id": "9817e147-241b-4bdc-a95c-4e3e932a3dbe", "interface_id": "4ec62b03-8f14-4e8b-a566-8be6935c053f"}], "created_at": "2025-12-21T17:24:56.768204Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:24:56.768204Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "7bd73cd1-1cbf-4d93-a37c-b6d2f16eff09", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:07.656300106Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "869fb100-e6a8-453d-81cf-adaec09b40fb", "bindings": [{"id": "4a683104-12c8-4b68-9d29-970835cdbc54", "type": "Port", "port_id": "b11c4f16-5889-47a7-b8a4-c9a195cd7f58", "interface_id": "31ebb18d-5c54-469a-9f0c-7f51d30ed547"}], "created_at": "2025-12-21T17:25:07.656319Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:07.656319Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "f5359f06-b667-4b98-bf73-51e1145575ad", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:23.292796146Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "40b09c8e-68b2-4f85-8fd6-d900b297b019", "bindings": [{"id": "beb0bf7b-7895-48df-a64f-4b4fb525cee6", "type": "Port", "port_id": "65c91ddb-13a8-42ba-b8ee-1ccdf5540ab1", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}], "created_at": "2025-12-21T17:25:23.292816Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:23.292816Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "869e1a88-5330-41b4-9169-0af92ec04dbd", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T17:25:28.330909251Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "40b09c8e-68b2-4f85-8fd6-d900b297b019", "bindings": [{"id": "8e2a36d7-1155-43d2-9d58-b1433f201a06", "type": "Port", "port_id": "f0750f05-95a7-4f3e-b200-7b81257bb640", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}], "created_at": "2025-12-21T17:25:28.330926Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:28.330926Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "6346572f-9115-41d0-a1d4-cfac7a42a2c2", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:25:31.976787120Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "40b09c8e-68b2-4f85-8fd6-d900b297b019", "bindings": [{"id": "f65e0a1b-95a0-4b97-9976-bf6ce1487ab3", "type": "Port", "port_id": "7c1f36ad-2467-4d28-bd3d-04132d5de5c2", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}], "created_at": "2025-12-21T17:25:31.976805Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:31.976805Z", "virtualization": null, "service_definition": "SSH"}, {"id": "1ae0e410-2ee6-4d3b-a664-a14c92d47426", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T17:25:31.977406571Z", "type": "Network", "daemon_id": "9b2002e6-4e44-4c8f-83f7-cd14be059b91", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "40b09c8e-68b2-4f85-8fd6-d900b297b019", "bindings": [{"id": "aac19687-e344-4f3b-bf57-ffabd524d59d", "type": "Port", "port_id": "6dd63d3b-b71d-4318-b3f1-9ce779f28140", "interface_id": "55bc55b7-2c99-46a5-af29-63cefdf51847"}], "created_at": "2025-12-21T17:25:31.977415Z", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:31.977415Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "7bd16458-b11e-47e6-b3a0-4d8b6899130d", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T17:25:32.009032Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "7332b341-929a-4e1e-8d09-17626ae1b2ed", "updated_at": "2025-12-21T17:25:32.009032Z", "description": null, "service_bindings": []}]	t	2025-12-21 17:23:54.751444+00	f	\N	\N	{ed1f9f35-a197-4b4b-b6b1-49c3e1b28934,24064773-b873-4e24-a943-6d62366f0bc0}	{58c6d228-dad8-405a-9108-096d111ed76e}	{66fde53e-9f55-4790-ad5e-32546e95f895}	{bcac38e1-2c7d-4d9e-a307-5e05b7a604eb}	\N	2025-12-21 17:23:54.747202+00	2025-12-21 17:25:32.917492+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
bb4adea0-e2f3-4761-a165-7e37e9122cc8	2025-12-21 17:23:54.722071+00	2025-12-21 17:23:54.722071+00	$argon2id$v=19$m=19456,t=2,p=1$upChkV2LZqa8xBlUfdKoGA$3egKI0P3IfdwPDxJs3zWeaI8WbVYrjv+sCRADeFkODU	\N	\N	\N	user@gmail.com	e0cf7c2f-4544-49b7-a3cd-943dc4eccfeb	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
pAzrTt8TZanTa3vr6_ECCQ	\\x93c4100902f1ebeb7b6bd3a96513df4eeb0ca481a7757365725f6964d92462623461646561302d653266332d343736312d613136352d37653337653931323263633899cd07ea14111736ce382e9142000000	2026-01-20 17:23:54.942575+00
BVfbH_wYXgHeJcdRRlarbA	\\x93c4106cab564651c725de015e18fc1fdb570582a7757365725f6964d92462623461646561302d653266332d343736312d613136352d376533376539313232636338ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92464393861346431652d623261622d343835612d626338332d633264643634666333613633a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea14111920ce211263c5000000	2026-01-20 17:25:32.554853+00
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

\unrestrict 9dHXcYWo6khqjckk2uJZEeJOsu0IEltnOCH5nWXQULVasj3BeWybBOMuqT8J4io

