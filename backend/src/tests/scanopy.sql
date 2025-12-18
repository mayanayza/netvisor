--
-- PostgreSQL database dump
--

\restrict f5aVGNvAQbVqBP0CY0PF7i5GcjTcxeHoQfSkRgPnn566u1zhZZmGmsQTfKJLswD

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
20251006215000	users	2025-12-18 19:36:08.50218+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3451136
20251006215100	networks	2025-12-18 19:36:08.506676+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5192924
20251006215151	create hosts	2025-12-18 19:36:08.512257+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4245351
20251006215155	create subnets	2025-12-18 19:36:08.516837+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4210036
20251006215201	create groups	2025-12-18 19:36:08.521409+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4313719
20251006215204	create daemons	2025-12-18 19:36:08.526043+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4579447
20251006215212	create services	2025-12-18 19:36:08.53097+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5336302
20251029193448	user-auth	2025-12-18 19:36:08.536627+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5879318
20251030044828	daemon api	2025-12-18 19:36:08.542788+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1563835
20251030170438	host-hide	2025-12-18 19:36:08.544637+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1046959
20251102224919	create discovery	2025-12-18 19:36:08.54601+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11114381
20251106235621	normalize-daemon-cols	2025-12-18 19:36:08.557409+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1728313
20251107034459	api keys	2025-12-18 19:36:08.559421+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8069154
20251107222650	oidc-auth	2025-12-18 19:36:08.567788+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26843231
20251110181948	orgs-billing	2025-12-18 19:36:08.594942+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10833666
20251113223656	group-enhancements	2025-12-18 19:36:08.606112+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1028964
20251117032720	daemon-mode	2025-12-18 19:36:08.607426+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1096341
20251118143058	set-default-plan	2025-12-18 19:36:08.608808+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1123942
20251118225043	save-topology	2025-12-18 19:36:08.610217+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8776989
20251123232748	network-permissions	2025-12-18 19:36:08.619311+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2776954
20251125001342	billing-updates	2025-12-18 19:36:08.622403+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	904305
20251128035448	org-onboarding-status	2025-12-18 19:36:08.623586+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1397194
20251129180942	nfs-consolidate	2025-12-18 19:36:08.625274+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1173565
20251206052641	discovery-progress	2025-12-18 19:36:08.626732+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1564647
20251206202200	plan-fix	2025-12-18 19:36:08.628577+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	903570
20251207061341	daemon-url	2025-12-18 19:36:08.62975+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	2399779
20251210045929	tags	2025-12-18 19:36:08.632456+00	t	\\xe3dde83d39f8552b5afcdc1493cddfeffe077751bf55472032bc8b35fc8fc2a2caa3b55b4c2354ace7de03c3977982db	8790223
20251210175035	terms	2025-12-18 19:36:08.641645+00	t	\\xe47f0cf7aba1bffa10798bede953da69fd4bfaebf9c75c76226507c558a3595c6bfc6ac8920d11398dbdf3b762769992	969042
20251213025048	hash-keys	2025-12-18 19:36:08.64292+00	t	\\xfc7cbb8ce61f0c225322297f7459dcbe362242b9001c06cb874b7f739cea7ae888d8f0cfaed6623bcbcb9ec54c8cd18b	9618513
20251214050638	scanopy	2025-12-18 19:36:08.652841+00	t	\\x0108bb39832305f024126211710689adc48d973ff66e5e59ff49468389b75c1ff95d1fbbb7bdb50e33ec1333a1f29ea6	1446252
20251215215724	topo-scanopy-fix	2025-12-18 19:36:08.654578+00	t	\\xed88a4b71b3c9b61d46322b5053362e5a25a9293cd3c420c9df9fcaeb3441254122b8a18f58c297f535c842b8a8b0a38	788275
20251217153736	category rename	2025-12-18 19:36:08.65566+00	t	\\x03af7ec905e11a77e25038a3c272645da96014da7c50c585a25cea3f9a7579faba3ff45114a5e589d144c9550ba42421	1715984
20251218053111	invite-persistence	2025-12-18 19:36:08.657661+00	t	\\x21d12f48b964acfd600f88e70ceb14abd9cf2a8a10db2eae2a6d8f44cf7d20749f93293631e6123e92b7c3c1793877c2	5217490
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled, tags) FROM stdin;
6cf7effb-4fc1-4901-bce3-b2ef4e1cc098	eb705b0f32c4975407a85753077b90cad3f711a4941d12664419f6dba49eeaf1	bfd334f7-829d-4d8d-a7f4-68864335224c	Integrated Daemon API Key	2025-12-18 19:36:10.873132+00	2025-12-18 19:37:43.066151+00	2025-12-18 19:37:43.06544+00	\N	t	{}
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name, tags) FROM stdin;
d371c109-7218-4f51-a557-238195176be4	bfd334f7-829d-4d8d-a7f4-68864335224c	0e202d4f-095f-494f-91eb-23f9b4430b09	2025-12-18 19:36:10.88501+00	2025-12-18 19:37:25.861494+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["8f7b02ac-7de2-4db1-b6b1-8376ee84f863"]}	2025-12-18 19:37:25.862021+00	"Push"	http://172.25.0.4:60073	scanopy-daemon	{}
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at, tags) FROM stdin;
8e70bb85-d93b-455f-9f65-123295655827	bfd334f7-829d-4d8d-a7f4-68864335224c	d371c109-7218-4f51-a557-238195176be4	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09"}	Self Report	2025-12-18 19:36:10.959891+00	2025-12-18 19:36:10.959891+00	{}
ffea4c66-088e-48ba-87da-58bac7f98196	bfd334f7-829d-4d8d-a7f4-68864335224c	d371c109-7218-4f51-a557-238195176be4	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-18 19:36:10.966535+00	2025-12-18 19:36:10.966535+00	{}
3f305a7c-04fd-4713-9b05-5eacf2b70e9b	bfd334f7-829d-4d8d-a7f4-68864335224c	d371c109-7218-4f51-a557-238195176be4	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "session_id": "cab977c5-0a51-4867-a538-d06f1751beb5", "started_at": "2025-12-18T19:36:10.966142108Z", "finished_at": "2025-12-18T19:36:11.049426886Z", "discovery_type": {"type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09"}}}	{"type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09"}	Self Report	2025-12-18 19:36:10.966142+00	2025-12-18 19:36:11.052976+00	{}
a46315c5-d634-403b-8173-afeca8724ba4	bfd334f7-829d-4d8d-a7f4-68864335224c	d371c109-7218-4f51-a557-238195176be4	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "session_id": "beb4f5ef-5268-4c56-94d2-0ce90631f9cc", "started_at": "2025-12-18T19:36:11.063715550Z", "finished_at": "2025-12-18T19:37:43.063439851Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-18 19:36:11.063715+00	2025-12-18 19:37:43.06569+00	{}
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style, tags) FROM stdin;
6f8e8d55-45b6-4a48-b493-6d77f80f6972	bfd334f7-829d-4d8d-a7f4-68864335224c		\N	{"group_type": "RequestPath", "service_bindings": []}	2025-12-18 19:37:43.078973+00	2025-12-18 19:37:43.078973+00	{"type": "System"}		"SmoothStep"	{}
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden, tags) FROM stdin;
30b7d6c7-9798-4394-91e6-307323f9f693	bfd334f7-829d-4d8d-a7f4-68864335224c	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "6f77178e-df3d-4d72-9e13-850d6f3a73ec"}	[{"id": "e0db481b-9a20-40d4-9773-2d05985c691f", "name": "Internet", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "ip_address": "1.1.1.1", "mac_address": null}]	{26fc22e6-5041-47df-9676-6775cd897ce7}	[{"id": "47ebf60c-ed2d-439c-a6a8-dca311ea4190", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-18 19:36:10.847351+00	2025-12-18 19:36:10.856723+00	f	{}
aaa0c073-44e8-4086-8e9d-5f60f41602b9	bfd334f7-829d-4d8d-a7f4-68864335224c	Google.com	\N	\N	{"type": "ServiceBinding", "config": "530f4c56-d07a-461c-81e5-6d8494364707"}	[{"id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206", "name": "Internet", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "ip_address": "203.0.113.180", "mac_address": null}]	{c72c3bb3-5569-4dc7-9ef5-cfe1c9535dc1}	[{"id": "f477cf8a-5206-46bf-b945-3f5513a58c0c", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-18 19:36:10.847357+00	2025-12-18 19:36:10.861936+00	f	{}
a5e9c623-6a94-408c-abce-82d99ba695df	bfd334f7-829d-4d8d-a7f4-68864335224c	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "186404d6-11c8-49c3-909e-a111064cc271"}	[{"id": "fba3c55d-9788-477d-8190-a318c5616bde", "name": "Remote Network", "subnet_id": "8ee89a55-d695-40bb-9962-f3165fccf5f9", "ip_address": "203.0.113.89", "mac_address": null}]	{32276e4c-9a5d-4420-8a67-91ede250e6b9}	[{"id": "e8929014-dd71-4d7b-811d-4581d12c2bed", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-18 19:36:10.847363+00	2025-12-18 19:36:10.865887+00	f	{}
32166301-453e-456a-8bb8-7fe4a857a0e6	bfd334f7-829d-4d8d-a7f4-68864335224c	scanopy-server-1.scanopy_scanopy-dev	scanopy-server-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "9d58601b-8d5c-4265-9cb3-23991979bafa", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.3", "mac_address": "4E:2F:9E:83:34:2B"}]	{965908a8-83e5-4307-bb9e-b6c3d689990a}	[{"id": "34957fa3-e733-4a0e-a3ab-696fb135ae9a", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:56.919464168Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 19:36:56.919465+00	2025-12-18 19:37:10.963324+00	f	{}
0e202d4f-095f-494f-91eb-23f9b4430b09	bfd334f7-829d-4d8d-a7f4-68864335224c	scanopy-daemon	742954dc7bec	Scanopy daemon	{"type": "None"}	[{"id": "0bdb5543-52c4-4eac-a93d-dca7f263ba2b", "name": "eth0", "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.4", "mac_address": "F6:A2:53:2B:B6:3C"}]	{578a2c64-f4ad-41d5-a2bf-ab7e1cb49a65}	[{"id": "6ea1f3d4-61b8-43b4-8e33-02777c0e5b25", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:11.035202907Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}	null	2025-12-18 19:36:10.881356+00	2025-12-18 19:36:11.047529+00	f	{}
42d27cc0-9b5f-498b-be18-b75f10ab74f1	bfd334f7-829d-4d8d-a7f4-68864335224c	scanopy-postgres-dev-1.scanopy_scanopy-dev	scanopy-postgres-dev-1.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "18d92e4e-656b-45d6-b761-d98bc990187c", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.6", "mac_address": "42:0F:E7:56:0F:79"}]	{debd0dbb-59ef-4e63-8fc2-a11ff23cd526}	[{"id": "45ac17db-b01b-4e99-bc26-5e8324c081e8", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:42.698611024Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 19:36:42.698613+00	2025-12-18 19:36:56.833759+00	f	{}
0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0	bfd334f7-829d-4d8d-a7f4-68864335224c	homeassistant-discovery.scanopy_scanopy-dev	homeassistant-discovery.scanopy_scanopy-dev	\N	{"type": "Hostname"}	[{"id": "29f72539-f3a3-4955-a81d-da04f9874e91", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.5", "mac_address": "4E:CB:33:3D:AF:0F"}]	{aa30b67e-b8d8-4ba2-8dd7-bd8d41e454a4,5ecdb731-c70d-417c-9f57-87107c0c4242}	[{"id": "2a4c51f3-ea6d-48ae-b366-e04cf068ccd5", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ee07a912-9b77-4b5f-8083-e3fd8175916b", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:37:10.954136704Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 19:37:10.954139+00	2025-12-18 19:37:25.010641+00	f	{}
52774508-12b6-446b-92a5-8abca9add16a	bfd334f7-829d-4d8d-a7f4-68864335224c	runnervmh13bl	runnervmh13bl	\N	{"type": "Hostname"}	[{"id": "e125a04e-a61f-41ba-9dd3-cd452e573505", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.1", "mac_address": "8A:95:7B:B9:6F:6E"}]	{8888fafa-60d6-437e-9f1c-e2ad1461bb9e,9add90ea-c0c4-472e-a090-4be714f78567,341bf39e-754d-4bfa-8adc-76f4450012d0,0a6fe07b-3de2-447f-aa55-95ed7e214370}	[{"id": "8e354978-c3ef-4bf9-acfb-af16b31e43e7", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "19b8b2fa-2962-4339-9cfd-fc87e29f73bb", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a4980797-3c1f-488f-99c9-be513f219fbb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "0ce40dac-7508-4d30-a726-559a590ff39b", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:37:29.055801583Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-18 19:37:29.055804+00	2025-12-18 19:37:43.05743+00	f	{}
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
bfd334f7-829d-4d8d-a7f4-68864335224c	My Network	2025-12-18 19:36:10.845925+00	2025-12-18 19:36:10.845925+00	f	ad2e51eb-1ab4-4f01-a393-08030090ce32	{}
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
ad2e51eb-1ab4-4f01-a393-08030090ce32	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "trial_days": 0}	active	2025-12-18 19:36:10.83911+00	2025-12-18 19:37:43.860677+00	["OnboardingModalCompleted", "FirstDaemonRegistered", "FirstApiKeyCreated"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source, tags) FROM stdin;
26fc22e6-5041-47df-9676-6775cd897ce7	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.847353+00	2025-12-18 19:36:10.847353+00	Cloudflare DNS	30b7d6c7-9798-4394-91e6-307323f9f693	[{"id": "6f77178e-df3d-4d72-9e13-850d6f3a73ec", "type": "Port", "port_id": "47ebf60c-ed2d-439c-a6a8-dca311ea4190", "interface_id": "e0db481b-9a20-40d4-9773-2d05985c691f"}]	"Dns Server"	null	{"type": "System"}	{}
c72c3bb3-5569-4dc7-9ef5-cfe1c9535dc1	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.847358+00	2025-12-18 19:36:10.847358+00	Google.com	aaa0c073-44e8-4086-8e9d-5f60f41602b9	[{"id": "530f4c56-d07a-461c-81e5-6d8494364707", "type": "Port", "port_id": "f477cf8a-5206-46bf-b945-3f5513a58c0c", "interface_id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206"}]	"Web Service"	null	{"type": "System"}	{}
32276e4c-9a5d-4420-8a67-91ede250e6b9	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.847364+00	2025-12-18 19:36:10.847364+00	Mobile Device	a5e9c623-6a94-408c-abce-82d99ba695df	[{"id": "186404d6-11c8-49c3-909e-a111064cc271", "type": "Port", "port_id": "e8929014-dd71-4d7b-811d-4581d12c2bed", "interface_id": "fba3c55d-9788-477d-8190-a318c5616bde"}]	"Client"	null	{"type": "System"}	{}
578a2c64-f4ad-41d5-a2bf-ab7e1cb49a65	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:11.035224+00	2025-12-18 19:36:11.035224+00	Scanopy Daemon	0e202d4f-095f-494f-91eb-23f9b4430b09	[{"id": "dc1bc4fc-3094-4b21-a803-5f865fbe3d94", "type": "Port", "port_id": "6ea1f3d4-61b8-43b4-8e33-02777c0e5b25", "interface_id": "0bdb5543-52c4-4eac-a93d-dca7f263ba2b"}]	"Scanopy Daemon"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-18T19:36:11.035224017Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}	{}
debd0dbb-59ef-4e63-8fc2-a11ff23cd526	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:56.819065+00	2025-12-18 19:36:56.819065+00	PostgreSQL	42d27cc0-9b5f-498b-be18-b75f10ab74f1	[{"id": "5189a3d7-2b4e-47b5-9b6f-dd68d9abb65a", "type": "Port", "port_id": "45ac17db-b01b-4e99-bc26-5e8324c081e8", "interface_id": "18d92e4e-656b-45d6-b761-d98bc990187c"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:36:56.819047529Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
965908a8-83e5-4307-bb9e-b6c3d689990a	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:06.760063+00	2025-12-18 19:37:06.760063+00	Scanopy Server	32166301-453e-456a-8bb8-7fe4a857a0e6	[{"id": "350c0b4a-c21e-4769-99be-59f406197712", "type": "Port", "port_id": "34957fa3-e733-4a0e-a3ab-696fb135ae9a", "interface_id": "9d58601b-8d5c-4265-9cb3-23991979bafa"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:06.760044055Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
aa30b67e-b8d8-4ba2-8dd7-bd8d41e454a4	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:22.20635+00	2025-12-18 19:37:22.20635+00	Home Assistant	0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0	[{"id": "ac8f6096-2df0-492b-a4ae-e74cfb95758e", "type": "Port", "port_id": "2a4c51f3-ea6d-48ae-b366-e04cf068ccd5", "interface_id": "29f72539-f3a3-4955-a81d-da04f9874e91"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:22.206330346Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
5ecdb731-c70d-417c-9f57-87107c0c4242	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:24.998748+00	2025-12-18 19:37:24.998748+00	Unclaimed Open Ports	0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0	[{"id": "4b6c093a-5631-4176-aa12-9a38cb965c2a", "type": "Port", "port_id": "ee07a912-9b77-4b5f-8083-e3fd8175916b", "interface_id": "29f72539-f3a3-4955-a81d-da04f9874e91"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:24.998728943Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
341bf39e-754d-4bfa-8adc-76f4450012d0	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:43.041176+00	2025-12-18 19:37:43.041176+00	SSH	52774508-12b6-446b-92a5-8abca9add16a	[{"id": "1b4b011d-242f-40f4-b52e-14cd5fe972ae", "type": "Port", "port_id": "a4980797-3c1f-488f-99c9-be513f219fbb", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:43.041158255Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
8888fafa-60d6-437e-9f1c-e2ad1461bb9e	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:38.849069+00	2025-12-18 19:37:38.849069+00	Scanopy Server	52774508-12b6-446b-92a5-8abca9add16a	[{"id": "d18a6d5e-bf52-485f-99c6-fc83c2bf5f9a", "type": "Port", "port_id": "8e354978-c3ef-4bf9-acfb-af16b31e43e7", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}]	"Scanopy Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:38.849050763Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
9add90ea-c0c4-472e-a090-4be714f78567	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:40.254205+00	2025-12-18 19:37:40.254205+00	Home Assistant	52774508-12b6-446b-92a5-8abca9add16a	[{"id": "9e50065a-5c61-422b-a7fd-fad1077392ab", "type": "Port", "port_id": "19b8b2fa-2962-4339-9cfd-fc87e29f73bb", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:40.254190349Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
0a6fe07b-3de2-447f-aa55-95ed7e214370	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:37:43.041395+00	2025-12-18 19:37:43.041395+00	Unclaimed Open Ports	52774508-12b6-446b-92a5-8abca9add16a	[{"id": "1d853919-a0b7-45aa-a80c-5a857be38ea0", "type": "Port", "port_id": "0ce40dac-7508-4d30-a726-559a590ff39b", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:43.041386011Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	{}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source, tags) FROM stdin;
4b67e5ea-d1de-4f9c-ad07-98efb13531e4	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.847303+00	2025-12-18 19:36:10.847303+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}	{}
8ee89a55-d695-40bb-9962-f3165fccf5f9	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.847307+00	2025-12-18 19:36:10.847307+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}	{}
8f7b02ac-7de2-4db1-b6b1-8376ee84f863	bfd334f7-829d-4d8d-a7f4-68864335224c	2025-12-18 19:36:10.966294+00	2025-12-18 19:36:10.966294+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:10.966292169Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}	{}
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tags (id, organization_id, name, description, created_at, updated_at, color) FROM stdin;
2fa12a62-3ca2-49fa-98a9-f846719c52f5	ad2e51eb-1ab4-4f01-a393-08030090ce32	New Tag	\N	2025-12-18 19:37:43.08612+00	2025-12-18 19:37:43.08612+00	yellow
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at, tags) FROM stdin;
480576d8-381c-4463-873e-899ed7f65b67	bfd334f7-829d-4d8d-a7f4-68864335224c	My Topology	[]	[{"id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "8ee89a55-d695-40bb-9962-f3165fccf5f9", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "fba3c55d-9788-477d-8190-a318c5616bde", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a5e9c623-6a94-408c-abce-82d99ba695df", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "8ee89a55-d695-40bb-9962-f3165fccf5f9", "interface_id": "fba3c55d-9788-477d-8190-a318c5616bde"}, {"id": "e0db481b-9a20-40d4-9773-2d05985c691f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "30b7d6c7-9798-4394-91e6-307323f9f693", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "interface_id": "e0db481b-9a20-40d4-9773-2d05985c691f"}, {"id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206", "size": {"x": 250, "y": 100}, "header": null, "host_id": "aaa0c073-44e8-4086-8e9d-5f60f41602b9", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "interface_id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "30b7d6c7-9798-4394-91e6-307323f9f693", "name": "Cloudflare DNS", "tags": [], "ports": [{"id": "47ebf60c-ed2d-439c-a6a8-dca311ea4190", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "6f77178e-df3d-4d72-9e13-850d6f3a73ec"}, "hostname": null, "services": ["26fc22e6-5041-47df-9676-6775cd897ce7"], "created_at": "2025-12-18T19:36:10.847351Z", "interfaces": [{"id": "e0db481b-9a20-40d4-9773-2d05985c691f", "name": "Internet", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.856723Z", "description": null, "virtualization": null}, {"id": "aaa0c073-44e8-4086-8e9d-5f60f41602b9", "name": "Google.com", "tags": [], "ports": [{"id": "f477cf8a-5206-46bf-b945-3f5513a58c0c", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "530f4c56-d07a-461c-81e5-6d8494364707"}, "hostname": null, "services": ["c72c3bb3-5569-4dc7-9ef5-cfe1c9535dc1"], "created_at": "2025-12-18T19:36:10.847357Z", "interfaces": [{"id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206", "name": "Internet", "subnet_id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "ip_address": "203.0.113.180", "mac_address": null}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.861936Z", "description": null, "virtualization": null}, {"id": "a5e9c623-6a94-408c-abce-82d99ba695df", "name": "Mobile Device", "tags": [], "ports": [{"id": "e8929014-dd71-4d7b-811d-4581d12c2bed", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "186404d6-11c8-49c3-909e-a111064cc271"}, "hostname": null, "services": ["32276e4c-9a5d-4420-8a67-91ede250e6b9"], "created_at": "2025-12-18T19:36:10.847363Z", "interfaces": [{"id": "fba3c55d-9788-477d-8190-a318c5616bde", "name": "Remote Network", "subnet_id": "8ee89a55-d695-40bb-9962-f3165fccf5f9", "ip_address": "203.0.113.89", "mac_address": null}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.865887Z", "description": "A mobile device connecting from a remote network", "virtualization": null}, {"id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "name": "scanopy-daemon", "tags": [], "ports": [{"id": "6ea1f3d4-61b8-43b4-8e33-02777c0e5b25", "type": "Custom", "number": 60073, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:11.035202907Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}, "target": {"type": "None"}, "hostname": "742954dc7bec", "services": ["578a2c64-f4ad-41d5-a2bf-ab7e1cb49a65"], "created_at": "2025-12-18T19:36:10.881356Z", "interfaces": [{"id": "0bdb5543-52c4-4eac-a93d-dca7f263ba2b", "name": "eth0", "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.4", "mac_address": "F6:A2:53:2B:B6:3C"}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:11.047529Z", "description": "Scanopy daemon", "virtualization": null}, {"id": "42d27cc0-9b5f-498b-be18-b75f10ab74f1", "name": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "45ac17db-b01b-4e99-bc26-5e8324c081e8", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:42.698611024Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-postgres-dev-1.scanopy_scanopy-dev", "services": ["debd0dbb-59ef-4e63-8fc2-a11ff23cd526"], "created_at": "2025-12-18T19:36:42.698613Z", "interfaces": [{"id": "18d92e4e-656b-45d6-b761-d98bc990187c", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.6", "mac_address": "42:0F:E7:56:0F:79"}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:56.833759Z", "description": null, "virtualization": null}, {"id": "32166301-453e-456a-8bb8-7fe4a857a0e6", "name": "scanopy-server-1.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "34957fa3-e733-4a0e-a3ab-696fb135ae9a", "type": "Custom", "number": 60072, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:56.919464168Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "scanopy-server-1.scanopy_scanopy-dev", "services": ["965908a8-83e5-4307-bb9e-b6c3d689990a"], "created_at": "2025-12-18T19:36:56.919465Z", "interfaces": [{"id": "9d58601b-8d5c-4265-9cb3-23991979bafa", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.3", "mac_address": "4E:2F:9E:83:34:2B"}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:10.963324Z", "description": null, "virtualization": null}, {"id": "0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0", "name": "homeassistant-discovery.scanopy_scanopy-dev", "tags": [], "ports": [{"id": "2a4c51f3-ea6d-48ae-b366-e04cf068ccd5", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ee07a912-9b77-4b5f-8083-e3fd8175916b", "type": "Custom", "number": 18555, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:37:10.954136704Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "homeassistant-discovery.scanopy_scanopy-dev", "services": ["aa30b67e-b8d8-4ba2-8dd7-bd8d41e454a4", "5ecdb731-c70d-417c-9f57-87107c0c4242"], "created_at": "2025-12-18T19:37:10.954139Z", "interfaces": [{"id": "29f72539-f3a3-4955-a81d-da04f9874e91", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.5", "mac_address": "4E:CB:33:3D:AF:0F"}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:25.010641Z", "description": null, "virtualization": null}, {"id": "52774508-12b6-446b-92a5-8abca9add16a", "name": "runnervmh13bl", "tags": [], "ports": [{"id": "8e354978-c3ef-4bf9-acfb-af16b31e43e7", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "19b8b2fa-2962-4339-9cfd-fc87e29f73bb", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a4980797-3c1f-488f-99c9-be513f219fbb", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "0ce40dac-7508-4d30-a726-559a590ff39b", "type": "Custom", "number": 5435, "protocol": "Tcp"}], "hidden": false, "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:37:29.055801583Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "target": {"type": "Hostname"}, "hostname": "runnervmh13bl", "services": ["8888fafa-60d6-437e-9f1c-e2ad1461bb9e", "9add90ea-c0c4-472e-a090-4be714f78567", "341bf39e-754d-4bfa-8adc-76f4450012d0", "0a6fe07b-3de2-447f-aa55-95ed7e214370"], "created_at": "2025-12-18T19:37:29.055804Z", "interfaces": [{"id": "e125a04e-a61f-41ba-9dd3-cd452e573505", "name": null, "subnet_id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "ip_address": "172.25.0.1", "mac_address": "8A:95:7B:B9:6F:6E"}], "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:43.057430Z", "description": null, "virtualization": null}]	[{"id": "4b67e5ea-d1de-4f9c-ad07-98efb13531e4", "cidr": "0.0.0.0/0", "name": "Internet", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-18T19:36:10.847303Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.847303Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "8ee89a55-d695-40bb-9962-f3165fccf5f9", "cidr": "0.0.0.0/0", "name": "Remote Network", "tags": [], "source": {"type": "System"}, "created_at": "2025-12-18T19:36:10.847307Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.847307Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "8f7b02ac-7de2-4db1-b6b1-8376ee84f863", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "tags": [], "source": {"type": "Discovery", "metadata": [{"date": "2025-12-18T19:36:10.966292169Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}, "created_at": "2025-12-18T19:36:10.966294Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.966294Z", "description": null, "subnet_type": "Lan"}]	[{"id": "26fc22e6-5041-47df-9676-6775cd897ce7", "name": "Cloudflare DNS", "tags": [], "source": {"type": "System"}, "host_id": "30b7d6c7-9798-4394-91e6-307323f9f693", "bindings": [{"id": "6f77178e-df3d-4d72-9e13-850d6f3a73ec", "type": "Port", "port_id": "47ebf60c-ed2d-439c-a6a8-dca311ea4190", "interface_id": "e0db481b-9a20-40d4-9773-2d05985c691f"}], "created_at": "2025-12-18T19:36:10.847353Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.847353Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "c72c3bb3-5569-4dc7-9ef5-cfe1c9535dc1", "name": "Google.com", "tags": [], "source": {"type": "System"}, "host_id": "aaa0c073-44e8-4086-8e9d-5f60f41602b9", "bindings": [{"id": "530f4c56-d07a-461c-81e5-6d8494364707", "type": "Port", "port_id": "f477cf8a-5206-46bf-b945-3f5513a58c0c", "interface_id": "3d6a1f9b-a2ee-454e-9e35-8ddc6a833206"}], "created_at": "2025-12-18T19:36:10.847358Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.847358Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "32276e4c-9a5d-4420-8a67-91ede250e6b9", "name": "Mobile Device", "tags": [], "source": {"type": "System"}, "host_id": "a5e9c623-6a94-408c-abce-82d99ba695df", "bindings": [{"id": "186404d6-11c8-49c3-909e-a111064cc271", "type": "Port", "port_id": "e8929014-dd71-4d7b-811d-4581d12c2bed", "interface_id": "fba3c55d-9788-477d-8190-a318c5616bde"}], "created_at": "2025-12-18T19:36:10.847364Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:10.847364Z", "virtualization": null, "service_definition": "Client"}, {"id": "578a2c64-f4ad-41d5-a2bf-ab7e1cb49a65", "name": "Scanopy Daemon", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Scanopy Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-18T19:36:11.035224017Z", "type": "SelfReport", "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "daemon_id": "d371c109-7218-4f51-a557-238195176be4"}]}, "host_id": "0e202d4f-095f-494f-91eb-23f9b4430b09", "bindings": [{"id": "dc1bc4fc-3094-4b21-a803-5f865fbe3d94", "type": "Port", "port_id": "6ea1f3d4-61b8-43b4-8e33-02777c0e5b25", "interface_id": "0bdb5543-52c4-4eac-a93d-dca7f263ba2b"}], "created_at": "2025-12-18T19:36:11.035224Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:11.035224Z", "virtualization": null, "service_definition": "Scanopy Daemon"}, {"id": "debd0dbb-59ef-4e63-8fc2-a11ff23cd526", "name": "PostgreSQL", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:36:56.819047529Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "42d27cc0-9b5f-498b-be18-b75f10ab74f1", "bindings": [{"id": "5189a3d7-2b4e-47b5-9b6f-dd68d9abb65a", "type": "Port", "port_id": "45ac17db-b01b-4e99-bc26-5e8324c081e8", "interface_id": "18d92e4e-656b-45d6-b761-d98bc990187c"}], "created_at": "2025-12-18T19:36:56.819065Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:36:56.819065Z", "virtualization": null, "service_definition": "PostgreSQL"}, {"id": "965908a8-83e5-4307-bb9e-b6c3d689990a", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:06.760044055Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "32166301-453e-456a-8bb8-7fe4a857a0e6", "bindings": [{"id": "350c0b4a-c21e-4769-99be-59f406197712", "type": "Port", "port_id": "34957fa3-e733-4a0e-a3ab-696fb135ae9a", "interface_id": "9d58601b-8d5c-4265-9cb3-23991979bafa"}], "created_at": "2025-12-18T19:37:06.760063Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:06.760063Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "aa30b67e-b8d8-4ba2-8dd7-bd8d41e454a4", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:22.206330346Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0", "bindings": [{"id": "ac8f6096-2df0-492b-a4ae-e74cfb95758e", "type": "Port", "port_id": "2a4c51f3-ea6d-48ae-b366-e04cf068ccd5", "interface_id": "29f72539-f3a3-4955-a81d-da04f9874e91"}], "created_at": "2025-12-18T19:37:22.206350Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:22.206350Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "5ecdb731-c70d-417c-9f57-87107c0c4242", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:24.998728943Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "0bcd5ce4-80c6-4d7b-9f48-2a20d1f2f7f0", "bindings": [{"id": "4b6c093a-5631-4176-aa12-9a38cb965c2a", "type": "Port", "port_id": "ee07a912-9b77-4b5f-8083-e3fd8175916b", "interface_id": "29f72539-f3a3-4955-a81d-da04f9874e91"}], "created_at": "2025-12-18T19:37:24.998748Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:24.998748Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}, {"id": "8888fafa-60d6-437e-9f1c-e2ad1461bb9e", "name": "Scanopy Server", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"scanopy\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:38.849050763Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "52774508-12b6-446b-92a5-8abca9add16a", "bindings": [{"id": "d18a6d5e-bf52-485f-99c6-fc83c2bf5f9a", "type": "Port", "port_id": "8e354978-c3ef-4bf9-acfb-af16b31e43e7", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}], "created_at": "2025-12-18T19:37:38.849069Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:38.849069Z", "virtualization": null, "service_definition": "Scanopy Server"}, {"id": "9add90ea-c0c4-472e-a090-4be714f78567", "name": "Home Assistant", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-18T19:37:40.254190349Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "52774508-12b6-446b-92a5-8abca9add16a", "bindings": [{"id": "9e50065a-5c61-422b-a7fd-fad1077392ab", "type": "Port", "port_id": "19b8b2fa-2962-4339-9cfd-fc87e29f73bb", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}], "created_at": "2025-12-18T19:37:40.254205Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:40.254205Z", "virtualization": null, "service_definition": "Home Assistant"}, {"id": "341bf39e-754d-4bfa-8adc-76f4450012d0", "name": "SSH", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:43.041158255Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "52774508-12b6-446b-92a5-8abca9add16a", "bindings": [{"id": "1b4b011d-242f-40f4-b52e-14cd5fe972ae", "type": "Port", "port_id": "a4980797-3c1f-488f-99c9-be513f219fbb", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}], "created_at": "2025-12-18T19:37:43.041176Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:43.041176Z", "virtualization": null, "service_definition": "SSH"}, {"id": "0a6fe07b-3de2-447f-aa55-95ed7e214370", "name": "Unclaimed Open Ports", "tags": [], "source": {"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-18T19:37:43.041386011Z", "type": "Network", "daemon_id": "d371c109-7218-4f51-a557-238195176be4", "subnet_ids": null, "host_naming_fallback": "BestService"}]}, "host_id": "52774508-12b6-446b-92a5-8abca9add16a", "bindings": [{"id": "1d853919-a0b7-45aa-a80c-5a857be38ea0", "type": "Port", "port_id": "0ce40dac-7508-4d30-a726-559a590ff39b", "interface_id": "e125a04e-a61f-41ba-9dd3-cd452e573505"}], "created_at": "2025-12-18T19:37:43.041395Z", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:43.041395Z", "virtualization": null, "service_definition": "Unclaimed Open Ports"}]	[{"id": "6f8e8d55-45b6-4a48-b493-6d77f80f6972", "name": "", "tags": [], "color": "", "source": {"type": "System"}, "created_at": "2025-12-18T19:37:43.078973Z", "edge_style": "SmoothStep", "group_type": "RequestPath", "network_id": "bfd334f7-829d-4d8d-a7f4-68864335224c", "updated_at": "2025-12-18T19:37:43.078973Z", "description": null, "service_bindings": []}]	t	2025-12-18 19:36:10.870377+00	f	\N	\N	{d18c66e3-0fba-4a97-96f0-c0394e01aae9,a2227ffc-d682-4ee5-a4e7-86f19acc1a27}	{1177809c-7d50-4b19-89f6-5a7a92b7f799}	{07515e9c-1c62-4c5e-a2a0-64b92ee20fcb}	{9fc3cb14-6947-478d-9713-40139aac374e}	\N	2025-12-18 19:36:10.866603+00	2025-12-18 19:37:43.938531+00	{}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids, tags, terms_accepted_at) FROM stdin;
12a9df61-81c5-4f1f-97b9-a9786de62c1f	2025-12-18 19:36:10.841973+00	2025-12-18 19:36:10.841973+00	$argon2id$v=19$m=19456,t=2,p=1$cMSJcR+E5+Yaet7/X6ZvXg$JbQB78zgxvgM5dF4JbXVBXzS1XPAjvWf4hWMOhAHcNU	\N	\N	\N	user@gmail.com	ad2e51eb-1ab4-4f01-a393-08030090ce32	Owner	{}	{}	\N
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
XDe95HnzE-5TuPcr7vslOA	\\x93c4103825fbee2bf7b853ee13f379e4bd375c81a7757365725f6964d92431326139646636312d383163352d346631662d393762392d61393738366465363263316699cd07ea1113240ace3a038b45000000	2026-01-17 19:36:10.97331+00
98gYGvY7d-6fbxjd00rEvQ	\\x93c410bdc44ad3dd186f9fee773bf61a18c8f782a7757365725f6964d92431326139646636312d383163352d346631662d393762392d613937383664653632633166ad70656e64696e675f736574757083a86e6574776f726b739182a46e616d65aa4d79204e6574776f726baa6e6574776f726b5f6964d92433383535663664362d643966382d346534342d396539632d363164366239656239643664a86f72675f6e616d65af4d79204f7267616e697a6174696f6ea9736565645f64617461c399cd07ea1113252bce2559cd1f000000	2026-01-17 19:37:43.626642+00
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

\unrestrict f5aVGNvAQbVqBP0CY0PF7i5GcjTcxeHoQfSkRgPnn566u1zhZZmGmsQTfKJLswD

