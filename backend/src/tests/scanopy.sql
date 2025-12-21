--
-- PostgreSQL database dump
--

\restrict p0aS8K4yEqQB3SMpqx3qWja674loTRLhiA6Snfb0LpuIiHeO0R8I464tcbmja6F

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
20251006215000	users	2025-12-21 19:08:12.084897+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3659873
20251006215100	networks	2025-12-21 19:08:12.089556+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4835173
20251006215151	create hosts	2025-12-21 19:08:12.094736+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4051347
20251006215155	create subnets	2025-12-21 19:08:12.099143+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3687996
20251006215201	create groups	2025-12-21 19:08:12.103156+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4007295
20251006215204	create daemons	2025-12-21 19:08:12.1076+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4267912
20251006215212	create services	2025-12-21 19:08:12.112269+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4995816
20251029193448	user-auth	2025-12-21 19:08:12.117854+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6269130
20251030044828	daemon api	2025-12-21 19:08:12.124423+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1489960
20251030170438	host-hide	2025-12-21 19:08:12.126196+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1134465
20251102224919	create discovery	2025-12-21 19:08:12.12762+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10755993
20251106235621	normalize-daemon-cols	2025-12-21 19:08:12.138689+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1710303
20251107034459	api keys	2025-12-21 19:08:12.14073+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8969306
20251107222650	oidc-auth	2025-12-21 19:08:12.149997+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28290147
20251110181948	orgs-billing	2025-12-21 19:08:12.178596+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11070431
20251113223656	group-enhancements	2025-12-21 19:08:12.189974+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1159822
20251117032720	daemon-mode	2025-12-21 19:08:12.191519+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1175802
20251118143058	set-default-plan	2025-12-21 19:08:12.19302+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1128053
20251118225043	save-topology	2025-12-21 19:08:12.194508+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8801480
20251123232748	network-permissions	2025-12-21 19:08:12.203641+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2687923
20251125001342	billing-updates	2025-12-21 19:08:12.206666+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	937486
20251128035448	org-onboarding-status	2025-12-21 19:08:12.207901+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1812975
20251129180942	nfs-consolidate	2025-12-21 19:08:12.210077+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1299050
20251206052641	discovery-progress	2025-12-21 19:08:12.211675+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1862248
20251206202200	plan-fix	2025-12-21 19:08:12.21438+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	1048195
20251207061341	daemon-url	2025-12-21 19:08:12.215721+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2289494
20251210045929	tags	2025-12-21 19:08:12.218329+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8680536
20251210175035	terms	2025-12-21 19:08:12.22745+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	942305
20251213025048	hash-keys	2025-12-21 19:08:12.228818+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	10111937
20251214050638	scanopy	2025-12-21 19:08:12.239228+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1492756
20251215215724	topo-scanopy-fix	2025-12-21 19:08:12.241063+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	798535
20251217153736	category rename	2025-12-21 19:08:12.242192+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1762961
20251218053111	invite-persistence	2025-12-21 19:08:12.244319+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5080775
20251219211216	create shares	2025-12-21 19:08:12.249728+00	t	\\x036485debd3536f9e58ead728f461b925585911acf565970bf3b2ab295b12a2865606d6a56d334c5641dcd42adeb3d68	6787353
20251220170928	permissions-cleanup	2025-12-21 19:08:12.257038+00	t	\\x632f7b6702b494301e0d36fd3b900686b1a7f9936aef8c084b5880f1152b8256a125566e2b5ac40216eaadd3c4c64a03	1989135
20251220180000	commercial-to-community	2025-12-21 19:08:12.259338+00	t	\\x26fc298486c225f2f01271d611418377c403183ae51daf32fef104ec07c027f2017d138910c4fbfb5f49819a5f4194d6	831617
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
05838023-a22a-42e2-93ca-900afee78725	1e4843050182e303534ae8cd3b9a418d106666bed09c10931042aef8743d30ac	9d8082d2-4a21-487b-b979-1960492f343d	Integrated Daemon API Key	2025-12-21 19:08:14.634253+00	2025-12-21 19:09:49.611882+00	2025-12-21 19:09:49.610478+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
c2a3b1da-3b12-40fc-898b-1596134f9321	9d8082d2-4a21-487b-b979-1960492f343d	c797de77-ddd8-44a6-a0f0-6b822f54964d	2025-12-21 19:08:14.690382+00	2025-12-21 19:09:28.551305+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["d5922ac1-e462-4125-9aa1-2a1445ab7cd5"]}	2025-12-21 19:09:28.551891+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
6fdaeb2a-2ca4-4062-b19f-74a3291e5b39	9d8082d2-4a21-487b-b979-1960492f343d	c2a3b1da-3b12-40fc-898b-1596134f9321	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d"}	Self Report	2025-12-21 19:08:14.698519+00	2025-12-21 19:08:14.698519+00	{}
48f511c7-cd15-4be4-8fa5-b9c252ba3c94	9d8082d2-4a21-487b-b979-1960492f343d	c2a3b1da-3b12-40fc-898b-1596134f9321	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 19:08:14.70619+00	2025-12-21 19:08:14.70619+00	{}
9ad881b7-d31a-4be3-a14e-b69f78fbce04	9d8082d2-4a21-487b-b979-1960492f343d	c2a3b1da-3b12-40fc-898b-1596134f9321	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "session_id": "26a41b00-158a-48aa-a259-ef82c2847e6e", "started_at": "2025-12-21T19:08:14.705800347Z", "finished_at": "2025-12-21T19:08:14.824465266Z", "discovery_type": {"type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d"}}}	{"type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d"}	Self Report	2025-12-21 19:08:14.7058+00	2025-12-21 19:08:14.829008+00	{}
d3a91d4c-482e-4273-b9b5-a7153282d018	9d8082d2-4a21-487b-b979-1960492f343d	c2a3b1da-3b12-40fc-898b-1596134f9321	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "session_id": "0f65461e-811a-4b37-84e0-a06f14350dd9", "started_at": "2025-12-21T19:08:14.850720708Z", "finished_at": "2025-12-21T19:09:49.607923334Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-21 19:08:14.85072+00	2025-12-21 19:09:49.610754+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
9a448273-1b58-4f2b-88ab-a42e2f58255a	9d8082d2-4a21-487b-b979-1960492f343d		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-21 19:09:49.623698+00	2025-12-21 19:09:49.623698+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
442052b8-77ba-4555-a644-978756d2f59f	9d8082d2-4a21-487b-b979-1960492f343d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "033c5bfc-e2a8-40f6-a29f-7ab63a2bba7e"}	[{"id": "4c842596-4857-4a4e-9d5b-7dee9af062cf", "name": "Internet", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "ip_address": "1.1.1.1", "mac_address": null}]	{5e73eeff-633b-4e27-b46c-2516fe3c56cc}	[{"id": "cbc258f8-6ab2-4182-ab88-a6e17f766f03", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-21 19:08:14.607543+00	2025-12-21 19:08:14.618308+00	f	{}
4d9409c1-27f3-4f2d-b05b-9bb301f1e734	9d8082d2-4a21-487b-b979-1960492f343d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "a41df70f-bc1a-444e-87b7-65dc88d6eda0"}	[{"id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3", "name": "Internet", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "ip_address": "203.0.113.22", "mac_address": null}]	{51f3653f-624e-45dd-b155-b8aa0d18a0ba}	[{"id": "d82bb391-483c-4082-b67d-0cd2ade51811", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 19:08:14.607551+00	2025-12-21 19:08:14.622674+00	f	{}
2fd1c191-44d9-46e5-b381-c0ab4b61fae9	9d8082d2-4a21-487b-b979-1960492f343d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "a39d9b85-1b73-464d-a32c-83c6d89de0ae"}	[{"id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d", "name": "Remote Network", "subnet_id": "2813d8b0-b5f7-4187-af19-98318ce179fe", "ip_address": "203.0.113.125", "mac_address": null}]	{e62dab93-def0-4b05-b15e-3540ac203b5e}	[{"id": "f1e08575-1d63-4172-974a-937a2e8a6c75", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-21 19:08:14.607557+00	2025-12-21 19:08:14.627048+00	f	{}
b3df6c99-1b71-47d6-8f5d-978a01a540f3	9d8082d2-4a21-487b-b979-1960492f343d	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "3471001d-e72d-45a6-a32b-73374f049b2c", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.3", "mac_address": "96:84:5E:79:5A:CD"}]	{7e81d59c-da9e-42b9-9fd8-b3931f91ded3}	[{"id": "9ed049a5-aef3-46ca-9209-cacda7b42b4c", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:00.162737395Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:09:00.162739+00	2025-12-21 19:09:14.680338+00	f	{}
c797de77-ddd8-44a6-a0f0-6b822f54964d	9d8082d2-4a21-487b-b979-1960492f343d	scanopy-daemon	4a5914fe8b6d	Scanopy daemon	{"type": "None"}	[{"id": "af26d84c-2c52-4359-8de8-120f1c49c94a", "name": "eth0", "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.4", "mac_address": "AA:1A:9A:C1:65:9E"}]	{6cb4d4bd-75ff-4000-91aa-813b847d23d5}	[{"id": "61f6ad52-d5c9-46cd-a596-fbb234159881", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:14.799193345Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}	null	2025-12-21 19:08:14.644084+00	2025-12-21 19:08:14.820931+00	f	{}
354aa8bc-18c7-4bad-ac60-031aa1b17c44	9d8082d2-4a21-487b-b979-1960492f343d	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "9f392aff-9905-4652-ac22-aa64940a149d", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.5", "mac_address": "B2:21:38:84:D6:BB"}]	{95ee8028-4155-4bc0-983f-a108ff82c648,e79300f9-b686-4350-aa8e-43f14c0ba814}	[{"id": "4bee84ea-104d-4b3b-9078-730b83a678a4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5c057fe3-ed55-4361-93c4-6c9331ad3689", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:45.573048019Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:08:45.57305+00	2025-12-21 19:09:00.103022+00	f	{}
2c86d5ca-20a1-44b3-8c46-75d8fa619fff	9d8082d2-4a21-487b-b979-1960492f343d	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "e3a28629-67f3-4493-9347-72882e5770fc", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.6", "mac_address": "CA:10:7C:EE:D6:1C"}]	{9a883c40-0fe9-4503-93d8-685275d7c43b}	[{"id": "174c4832-19ca-4130-aad5-29d0e1a67846", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:14.673169611Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:09:14.673172+00	2025-12-21 19:09:29.038038+00	f	{}
ce73f081-d503-42a6-a6bd-5d3e83b3168f	9d8082d2-4a21-487b-b979-1960492f343d	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.1", "mac_address": "1A:BB:86:5F:F5:5D"}]	{dd7df6ce-32a7-436e-950a-7ab3152a9ff8,a5359903-b094-4f60-a59f-b0996a0002cf,112968ec-2704-4a50-baef-5f47341a0ea0,9d64583d-ddbf-422d-aa08-3968a8ceceed}	[{"id": "a74aaec9-1d95-4a14-90ea-9c2776c03570", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5cb7bb3c-8449-4d25-bbc5-fad8e4f46de4", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "96221f44-ecb8-4f0b-899e-20878856d168", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "01b48048-77be-4c77-bccb-22364016e2c7", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:35.102735747Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-21 19:09:35.102738+00	2025-12-21 19:09:49.602326+00	f	{}
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
9d8082d2-4a21-487b-b979-1960492f343d	My Network	2025-12-21 19:08:14.605957+00	2025-12-21 19:08:14.605957+00	f	b864789e-059d-4d32-b2d9-cf10f0901b62	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
b864789e-059d-4d32-b2d9-cf10f0901b62	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-21 19:08:14.598904+00	2025-12-21 19:09:50.410872+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
5e73eeff-633b-4e27-b46c-2516fe3c56cc	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.607545+00	2025-12-21 19:08:14.607545+00	Cloudflare DNS	442052b8-77ba-4555-a644-978756d2f59f	[{"id": "033c5bfc-e2a8-40f6-a29f-7ab63a2bba7e", "type": "Port", "port_id": "cbc258f8-6ab2-4182-ab88-a6e17f766f03", "interface_id": "4c842596-4857-4a4e-9d5b-7dee9af062cf"}]	"Dns Server"	null	{"type": "System"}	{}
51f3653f-624e-45dd-b155-b8aa0d18a0ba	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.607552+00	2025-12-21 19:08:14.607552+00	Google.com	4d9409c1-27f3-4f2d-b05b-9bb301f1e734	[{"id": "a41df70f-bc1a-444e-87b7-65dc88d6eda0", "type": "Port", "port_id": "d82bb391-483c-4082-b67d-0cd2ade51811", "interface_id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3"}]	"Web Service"	null	{"type": "System"}	{}
e62dab93-def0-4b05-b15e-3540ac203b5e	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.607558+00	2025-12-21 19:08:14.607558+00	Mobile Device	2fd1c191-44d9-46e5-b381-c0ab4b61fae9	[{"id": "a39d9b85-1b73-464d-a32c-83c6d89de0ae", "type": "Port", "port_id": "f1e08575-1d63-4172-974a-937a2e8a6c75", "interface_id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d"}]	"Client"	null	{"type": "System"}	{}
6cb4d4bd-75ff-4000-91aa-813b847d23d5	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.799209+00	2025-12-21 19:08:14.799209+00	Scanopy Daemon	c797de77-ddd8-44a6-a0f0-6b822f54964d	[{"id": "fe661c83-f013-45bd-b1dc-82a5d8251b8b", "type": "Port", "port_id": "61f6ad52-d5c9-46cd-a596-fbb234159881", "interface_id": "af26d84c-2c52-4359-8de8-120f1c49c94a"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T19:08:14.799208743Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}	{}
95ee8028-4155-4bc0-983f-a108ff82c648	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:51.441448+00	2025-12-21 19:08:51.441448+00	Home Assistant	354aa8bc-18c7-4bad-ac60-031aa1b17c44	[{"id": "0ddc2390-377c-42d3-9175-a34affa99120", "type": "Port", "port_id": "4bee84ea-104d-4b3b-9078-730b83a678a4", "interface_id": "9f392aff-9905-4652-ac22-aa64940a149d"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:08:51.441429749Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
e79300f9-b686-4350-aa8e-43f14c0ba814	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:00.085359+00	2025-12-21 19:09:00.085359+00	Unclaimed Open Ports	354aa8bc-18c7-4bad-ac60-031aa1b17c44	[{"id": "897bb084-ae42-4a21-bfd8-ae2a37e3d9db", "type": "Port", "port_id": "5c057fe3-ed55-4361-93c4-6c9331ad3689", "interface_id": "9f392aff-9905-4652-ac22-aa64940a149d"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:00.085340408Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
7e81d59c-da9e-42b9-9fd8-b3931f91ded3	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:11.053734+00	2025-12-21 19:09:11.053734+00	Scanopy Server	b3df6c99-1b71-47d6-8f5d-978a01a540f3	[{"id": "bc27f0a8-9c65-4f8b-8963-ccc83276e2c7", "type": "Port", "port_id": "9ed049a5-aef3-46ca-9209-cacda7b42b4c", "interface_id": "3471001d-e72d-45a6-a32b-73374f049b2c"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:11.053718132Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9a883c40-0fe9-4503-93d8-685275d7c43b	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:29.027159+00	2025-12-21 19:09:29.027159+00	PostgreSQL	2c86d5ca-20a1-44b3-8c46-75d8fa619fff	[{"id": "d007f13c-6210-4d35-add5-63c58f0d5501", "type": "Port", "port_id": "174c4832-19ca-4130-aad5-29d0e1a67846", "interface_id": "e3a28629-67f3-4493-9347-72882e5770fc"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:29.027142931Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
a5359903-b094-4f60-a59f-b0996a0002cf	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:45.972937+00	2025-12-21 19:09:45.972937+00	Scanopy Server	ce73f081-d503-42a6-a6bd-5d3e83b3168f	[{"id": "18aa55e8-704b-410d-9848-b55e943668a2", "type": "Port", "port_id": "5cb7bb3c-8449-4d25-bbc5-fad8e4f46de4", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:45.972917321Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
dd7df6ce-32a7-436e-950a-7ab3152a9ff8	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:40.917343+00	2025-12-21 19:09:40.917343+00	Home Assistant	ce73f081-d503-42a6-a6bd-5d3e83b3168f	[{"id": "0e2822c2-d0c4-499d-a2e5-3d2aa872b029", "type": "Port", "port_id": "a74aaec9-1d95-4a14-90ea-9c2776c03570", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:40.917325470Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
112968ec-2704-4a50-baef-5f47341a0ea0	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:49.587928+00	2025-12-21 19:09:49.587928+00	SSH	ce73f081-d503-42a6-a6bd-5d3e83b3168f	[{"id": "d79994ba-514c-48e2-8ff9-50c2020e5ae9", "type": "Port", "port_id": "96221f44-ecb8-4f0b-899e-20878856d168", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:49.587911281Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9d64583d-ddbf-422d-aa08-3968a8ceceed	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:09:49.588558+00	2025-12-21 19:09:49.588558+00	Unclaimed Open Ports	ce73f081-d503-42a6-a6bd-5d3e83b3168f	[{"id": "f5c5a923-347b-42fd-b3e1-9c946c02dfdc", "type": "Port", "port_id": "01b48048-77be-4c77-bccb-22364016e2c7", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:49.588549346Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
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
2579055d-59d4-4bdd-b0f8-e25e8b978a50	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.607481+00	2025-12-21 19:08:14.607481+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
2813d8b0-b5f7-4187-af19-98318ce179fe	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.607485+00	2025-12-21 19:08:14.607485+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
d5922ac1-e462-4125-9aa1-2a1445ab7cd5	9d8082d2-4a21-487b-b979-1960492f343d	2025-12-21 19:08:14.705959+00	2025-12-21 19:08:14.705959+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:14.705957742Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
2d63e96c-ccca-4da4-a9e7-bbfc96b57ab9	b864789e-059d-4d32-b2d9-cf10f0901b62	New Tag	\N	2025-12-21 19:09:49.631067+00	2025-12-21 19:09:49.631067+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
5746e28b-2bc5-405c-b8bb-a62faf7422c3	9d8082d2-4a21-487b-b979-1960492f343d	My Topology	[]	[{"id": "2813d8b0-b5f7-4187-af19-98318ce179fe", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "4c842596-4857-4a4e-9d5b-7dee9af062cf", "size": {"x": 250, "y": 100}, "header": null, "host_id": "442052b8-77ba-4555-a644-978756d2f59f", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "interface_id": "4c842596-4857-4a4e-9d5b-7dee9af062cf"}, {"id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3", "size": {"x": 250, "y": 100}, "header": null, "host_id": "4d9409c1-27f3-4f2d-b05b-9bb301f1e734", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "interface_id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3"}, {"id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "2fd1c191-44d9-46e5-b381-c0ab4b61fae9", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "2813d8b0-b5f7-4187-af19-98318ce179fe", "interface_id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": true, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "442052b8-77ba-4555-a644-978756d2f59f", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "cbc258f8-6ab2-4182-ab88-a6e17f766f03", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "033c5bfc-e2a8-40f6-a29f-7ab63a2bba7e"}, "hostname": null, "services": ["5e73eeff-633b-4e27-b46c-2516fe3c56cc"], "created_at": "2025-12-21T19:08:14.607543Z", "interfaces": [{"id": "4c842596-4857-4a4e-9d5b-7dee9af062cf", "name": "Internet", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.618308Z", "description": null, "virtualization": null}, {"id": "4d9409c1-27f3-4f2d-b05b-9bb301f1e734", "name": "Google.com", "tags": [], "ports": [{"id": "d82bb391-483c-4082-b67d-0cd2ade51811", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "a41df70f-bc1a-444e-87b7-65dc88d6eda0"}, "hostname": null, "services": ["51f3653f-624e-45dd-b155-b8aa0d18a0ba"], "created_at": "2025-12-21T19:08:14.607551Z", "interfaces": [{"id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3", "name": "Internet", "subnet_id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "ip_address": "203.0.113.22", "mac_address": null}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.622674Z", "description": null, "virtualization": null}, {"id": "2fd1c191-44d9-46e5-b381-c0ab4b61fae9", "name": "Mobile Device", "tags": [], "ports": [{"id": "f1e08575-1d63-4172-974a-937a2e8a6c75", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "a39d9b85-1b73-464d-a32c-83c6d89de0ae"}, "hostname": null, "services": ["e62dab93-def0-4b05-b15e-3540ac203b5e"], "created_at": "2025-12-21T19:08:14.607557Z", "interfaces": [{"id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d", "name": "Remote Network", "subnet_id": "2813d8b0-b5f7-4187-af19-98318ce179fe", "ip_address": "203.0.113.125", "mac_address": null}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.627048Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "61f6ad52-d5c9-46cd-a596-fbb234159881", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:14.799193345Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}, "target": {"type": "None"}, "hostname": "4a5914fe8b6d", "services": ["6cb4d4bd-75ff-4000-91aa-813b847d23d5"], "created_at": "2025-12-21T19:08:14.644084Z", "interfaces": [{"id": "af26d84c-2c52-4359-8de8-120f1c49c94a", "name": "eth0", "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.4", "mac_address": "AA:1A:9A:C1:65:9E"}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.820931Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "354aa8bc-18c7-4bad-ac60-031aa1b17c44", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "4bee84ea-104d-4b3b-9078-730b83a678a4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5c057fe3-ed55-4361-93c4-6c9331ad3689", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:45.573048019Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["95ee8028-4155-4bc0-983f-a108ff82c648", "e79300f9-b686-4350-aa8e-43f14c0ba814"], "created_at": "2025-12-21T19:08:45.573050Z", "interfaces": [{"id": "9f392aff-9905-4652-ac22-aa64940a149d", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.5", "mac_address": "B2:21:38:84:D6:BB"}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:00.103022Z", "description": null, "virtualization": null}, {"id": "b3df6c99-1b71-47d6-8f5d-978a01a540f3", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "9ed049a5-aef3-46ca-9209-cacda7b42b4c", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:00.162737395Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["7e81d59c-da9e-42b9-9fd8-b3931f91ded3"], "created_at": "2025-12-21T19:09:00.162739Z", "interfaces": [{"id": "3471001d-e72d-45a6-a32b-73374f049b2c", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.3", "mac_address": "96:84:5E:79:5A:CD"}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:14.680338Z", "description": null, "virtualization": null}, {"id": "2c86d5ca-20a1-44b3-8c46-75d8fa619fff", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "174c4832-19ca-4130-aad5-29d0e1a67846", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:14.673169611Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["9a883c40-0fe9-4503-93d8-685275d7c43b"], "created_at": "2025-12-21T19:09:14.673172Z", "interfaces": [{"id": "e3a28629-67f3-4493-9347-72882e5770fc", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.6", "mac_address": "CA:10:7C:EE:D6:1C"}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:29.038038Z", "description": null, "virtualization": null}, {"id": "ce73f081-d503-42a6-a6bd-5d3e83b3168f", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "a74aaec9-1d95-4a14-90ea-9c2776c03570", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "5cb7bb3c-8449-4d25-bbc5-fad8e4f46de4", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "96221f44-ecb8-4f0b-899e-20878856d168", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "01b48048-77be-4c77-bccb-22364016e2c7", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:09:35.102735747Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["dd7df6ce-32a7-436e-950a-7ab3152a9ff8", "a5359903-b094-4f60-a59f-b0996a0002cf", "112968ec-2704-4a50-baef-5f47341a0ea0", "9d64583d-ddbf-422d-aa08-3968a8ceceed"], "created_at": "2025-12-21T19:09:35.102738Z", "interfaces": [{"id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88", "name": null, "subnet_id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "ip_address": "172.25.0.1", "mac_address": "1A:BB:86:5F:F5:5D"}], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:49.602326Z", "description": null, "virtualization": null}, {"id": "babfe252-966d-4ad1-bd60-5747c1c1ec42", "name": "Service Test Host", "tags": [], "ports": [], "hidden": false, "source": {"type": "System"}, "target": {"type": "Hostname"}, "hostname": "service-test.local", "services": [], "created_at": "2025-12-21T19:09:50.271004Z", "interfaces": [], "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:50.280183Z", "description": null, "virtualization": null}]	[{"id": "2579055d-59d4-4bdd-b0f8-e25e8b978a50", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T19:08:14.607481Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.607481Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "2813d8b0-b5f7-4187-af19-98318ce179fe", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-21T19:08:14.607485Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.607485Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "d5922ac1-e462-4125-9aa1-2a1445ab7cd5", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-21T19:08:14.705957742Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}, "created_at": "2025-12-21T19:08:14.705959Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.705959Z", "description": null, "subnet_type": "Lan"}]	[{"id": "5e73eeff-633b-4e27-b46c-2516fe3c56cc", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "442052b8-77ba-4555-a644-978756d2f59f", "bindings": [{"id": "033c5bfc-e2a8-40f6-a29f-7ab63a2bba7e", "type": "Port", "port_id": "cbc258f8-6ab2-4182-ab88-a6e17f766f03", "interface_id": "4c842596-4857-4a4e-9d5b-7dee9af062cf"}], "created_at": "2025-12-21T19:08:14.607545Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.607545Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "51f3653f-624e-45dd-b155-b8aa0d18a0ba", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "4d9409c1-27f3-4f2d-b05b-9bb301f1e734", "bindings": [{"id": "a41df70f-bc1a-444e-87b7-65dc88d6eda0", "type": "Port", "port_id": "d82bb391-483c-4082-b67d-0cd2ade51811", "interface_id": "c06d74b1-e4d9-4f93-8d1b-7d1461e4c2b3"}], "created_at": "2025-12-21T19:08:14.607552Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.607552Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "e62dab93-def0-4b05-b15e-3540ac203b5e", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "2fd1c191-44d9-46e5-b381-c0ab4b61fae9", "bindings": [{"id": "a39d9b85-1b73-464d-a32c-83c6d89de0ae", "type": "Port", "port_id": "f1e08575-1d63-4172-974a-937a2e8a6c75", "interface_id": "38dc7e4a-c8b0-47d0-974d-272f1ed6257d"}], "created_at": "2025-12-21T19:08:14.607558Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.607558Z", "virtualization": null, "service_definition": "Client"}, {"id": "6cb4d4bd-75ff-4000-91aa-813b847d23d5", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-21T19:08:14.799208743Z", "type": "SelfReport", "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321"}]}, "host_id": "c797de77-ddd8-44a6-a0f0-6b822f54964d", "bindings": [{"id": "fe661c83-f013-45bd-b1dc-82a5d8251b8b", "type": "Port", "port_id": "61f6ad52-d5c9-46cd-a596-fbb234159881", "interface_id": "af26d84c-2c52-4359-8de8-120f1c49c94a"}], "created_at": "2025-12-21T19:08:14.799209Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:14.799209Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "95ee8028-4155-4bc0-983f-a108ff82c648", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:08:51.441429749Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "354aa8bc-18c7-4bad-ac60-031aa1b17c44", "bindings": [{"id": "0ddc2390-377c-42d3-9175-a34affa99120", "type": "Port", "port_id": "4bee84ea-104d-4b3b-9078-730b83a678a4", "interface_id": "9f392aff-9905-4652-ac22-aa64940a149d"}], "created_at": "2025-12-21T19:08:51.441448Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:08:51.441448Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "e79300f9-b686-4350-aa8e-43f14c0ba814", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:00.085340408Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "354aa8bc-18c7-4bad-ac60-031aa1b17c44", "bindings": [{"id": "897bb084-ae42-4a21-bfd8-ae2a37e3d9db", "type": "Port", "port_id": "5c057fe3-ed55-4361-93c4-6c9331ad3689", "interface_id": "9f392aff-9905-4652-ac22-aa64940a149d"}], "created_at": "2025-12-21T19:09:00.085359Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:00.085359Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "7e81d59c-da9e-42b9-9fd8-b3931f91ded3", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:11.053718132Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "b3df6c99-1b71-47d6-8f5d-978a01a540f3", "bindings": [{"id": "bc27f0a8-9c65-4f8b-8963-ccc83276e2c7", "type": "Port", "port_id": "9ed049a5-aef3-46ca-9209-cacda7b42b4c", "interface_id": "3471001d-e72d-45a6-a32b-73374f049b2c"}], "created_at": "2025-12-21T19:09:11.053734Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:11.053734Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "9a883c40-0fe9-4503-93d8-685275d7c43b", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:29.027142931Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "2c86d5ca-20a1-44b3-8c46-75d8fa619fff", "bindings": [{"id": "d007f13c-6210-4d35-add5-63c58f0d5501", "type": "Port", "port_id": "174c4832-19ca-4130-aad5-29d0e1a67846", "interface_id": "e3a28629-67f3-4493-9347-72882e5770fc"}], "created_at": "2025-12-21T19:09:29.027159Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:29.027159Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "dd7df6ce-32a7-436e-950a-7ab3152a9ff8", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:40.917325470Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ce73f081-d503-42a6-a6bd-5d3e83b3168f", "bindings": [{"id": "0e2822c2-d0c4-499d-a2e5-3d2aa872b029", "type": "Port", "port_id": "a74aaec9-1d95-4a14-90ea-9c2776c03570", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}], "created_at": "2025-12-21T19:09:40.917343Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:40.917343Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "a5359903-b094-4f60-a59f-b0996a0002cf", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-21T19:09:45.972917321Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ce73f081-d503-42a6-a6bd-5d3e83b3168f", "bindings": [{"id": "18aa55e8-704b-410d-9848-b55e943668a2", "type": "Port", "port_id": "5cb7bb3c-8449-4d25-bbc5-fad8e4f46de4", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}], "created_at": "2025-12-21T19:09:45.972937Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:45.972937Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "112968ec-2704-4a50-baef-5f47341a0ea0", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:49.587911281Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ce73f081-d503-42a6-a6bd-5d3e83b3168f", "bindings": [{"id": "d79994ba-514c-48e2-8ff9-50c2020e5ae9", "type": "Port", "port_id": "96221f44-ecb8-4f0b-899e-20878856d168", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}], "created_at": "2025-12-21T19:09:49.587928Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:49.587928Z", "virtualization": null, "service_definition": "SSH"}, {"id": "9d64583d-ddbf-422d-aa08-3968a8ceceed", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-21T19:09:49.588549346Z", "type": "Network", "daemon_id": "c2a3b1da-3b12-40fc-898b-1596134f9321", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "ce73f081-d503-42a6-a6bd-5d3e83b3168f", "bindings": [{"id": "f5c5a923-347b-42fd-b3e1-9c946c02dfdc", "type": "Port", "port_id": "01b48048-77be-4c77-bccb-22364016e2c7", "interface_id": "92d5e54d-c2e4-40b4-a1a5-c65dedf08f88"}], "created_at": "2025-12-21T19:09:49.588558Z", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:49.588558Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "9a448273-1b58-4f2b-88ab-a42e2f58255a", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-21T19:09:49.623698Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "9d8082d2-4a21-487b-b979-1960492f343d", "updated_at": "2025-12-21T19:09:49.623698Z", "description": null, "service_bindings": []}]	t	2025-12-21 19:08:14.631748+00	f	\N	\N	{0b479848-2c0d-47e5-8fde-b09211835111,babfe252-966d-4ad1-bd60-5747c1c1ec42}	{9939ed0d-8a40-4c91-b361-0bc69197cc89}	{861eb3aa-5268-4c3a-a38a-5683e4d7672b}	{a7f2214d-8443-43e9-ab3d-e79d5f19c120}	\N	2025-12-21 19:08:14.627776+00	2025-12-21 19:09:50.540674+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
e6822269-2081-42c3-83a2-c924650b7b0c	2025-12-21 19:08:14.6021+00	2025-12-21 19:08:14.6021+00	$argon2id$v=19$m=19456,t=2,p=1$bWGI4LJwgeV6g0mC8WWT1A$E+JSyczREjTl4TVUOqQCUVVTUqFHMgH/A0YlbodBSmo	\N	\N	\N	user@gmail.com	b864789e-059d-4d32-b2d9-cf10f0901b62	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
_bzsV1_OaZCuJQBUHnXs9Q	\\x93c410f5ec751e540025ae9069ce5f57ecbcfd81a7757365725f6964d92465363832323236392d323038312d343263332d383361322d63393234363530623762306399cd07ea1413080ece2f0353e9000000	2026-01-20 19:08:14.788747+00
CH6DyPf6sI8g-USZ6I8QHQ	\\x93c4101d108fe89944f9208fb0faf7c8837e0882a7757365725f6964d92465363832323236392d323038312d343263332d383361322d633932343635306237623063ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92466616263303934302d383730332d343536382d396337362d373234626633373338383235a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea14130932ce09c2929d000000	2026-01-20 19:09:50.163746+00
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

\unrestrict p0aS8K4yEqQB3SMpqx3qWja674loTRLhiA6Snfb0LpuIiHeO0R8I464tcbmja6F

