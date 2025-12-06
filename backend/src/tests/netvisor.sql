--
-- PostgreSQL database dump
--

\restrict EApbjVwwT5nnfneMft3bg3H6TxceKbRVz7d6d0LftCN01bdWMHgLVhicVklgNIm

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
    is_enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.api_keys OWNER TO postgres;

--
-- Name: daemons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daemons (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    ip text NOT NULL,
    port integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text
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
    updated_at timestamp with time zone NOT NULL
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
    edge_style text DEFAULT '"SmoothStep"'::text
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
    hidden boolean DEFAULT false
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
    organization_id uuid NOT NULL
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
    source jsonb NOT NULL
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
    source jsonb NOT NULL
);


ALTER TABLE public.subnets OWNER TO postgres;

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
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
    network_ids uuid[] DEFAULT '{}'::uuid[] NOT NULL
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
20251006215000	users	2025-12-06 07:30:12.013111+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3552426
20251006215100	networks	2025-12-06 07:30:12.017684+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4322261
20251006215151	create hosts	2025-12-06 07:30:12.022364+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3873254
20251006215155	create subnets	2025-12-06 07:30:12.026628+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3862584
20251006215201	create groups	2025-12-06 07:30:12.030865+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3996274
20251006215204	create daemons	2025-12-06 07:30:12.035283+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4333322
20251006215212	create services	2025-12-06 07:30:12.039986+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4952737
20251029193448	user-auth	2025-12-06 07:30:12.045302+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5352432
20251030044828	daemon api	2025-12-06 07:30:12.05099+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1549400
20251030170438	host-hide	2025-12-06 07:30:12.053016+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1256074
20251102224919	create discovery	2025-12-06 07:30:12.054716+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9865068
20251106235621	normalize-daemon-cols	2025-12-06 07:30:12.06499+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2207118
20251107034459	api keys	2025-12-06 07:30:12.067678+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7513040
20251107222650	oidc-auth	2025-12-06 07:30:12.075606+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20631179
20251110181948	orgs-billing	2025-12-06 07:30:12.096787+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10135956
20251113223656	group-enhancements	2025-12-06 07:30:12.107531+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1236314
20251117032720	daemon-mode	2025-12-06 07:30:12.109202+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1331124
20251118143058	set-default-plan	2025-12-06 07:30:12.110925+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1383991
20251118225043	save-topology	2025-12-06 07:30:12.112823+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9688139
20251123232748	network-permissions	2025-12-06 07:30:12.122952+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2992792
20251125001342	billing-updates	2025-12-06 07:30:12.126294+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	975660
20251128035448	org-onboarding-status	2025-12-06 07:30:12.127653+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1546334
20251129180942	nfs-consolidate	2025-12-06 07:30:12.129509+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1329409
20251206052641	discovery-progress	2025-12-06 07:30:12.131168+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1553287
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
854c78b4-30cb-446c-8bce-1a9ae0d1e322	c29776c3ea2b48dca54f1a2a6e5366f5	6c294f36-83cd-45bc-8a68-818a013d1a91	Integrated Daemon API Key	2025-12-06 07:30:14.919001+00	2025-12-06 07:31:50.144899+00	2025-12-06 07:31:50.143915+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
cfc04116-67a8-4827-a026-c20c8015d7dd	6c294f36-83cd-45bc-8a68-818a013d1a91	8afa46ba-6bae-4432-b130-d898d7eb19b6	"172.25.0.4"	60073	2025-12-06 07:30:15.044822+00	2025-12-06 07:31:29.247654+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["8ce6d095-6f7f-4467-a319-e7842f8d9c0f"]}	2025-12-06 07:31:29.248488+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
96acebeb-37d8-4efc-a59e-0e4ddfab1575	6c294f36-83cd-45bc-8a68-818a013d1a91	cfc04116-67a8-4827-a026-c20c8015d7dd	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6"}	Self Report @ 172.25.0.4	2025-12-06 07:30:15.05458+00	2025-12-06 07:30:15.05458+00
9d744a3a-2b5c-4f7f-bbd4-fd17f76ac823	6c294f36-83cd-45bc-8a68-818a013d1a91	cfc04116-67a8-4827-a026-c20c8015d7dd	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-12-06 07:30:15.061265+00	2025-12-06 07:30:15.061265+00
8e842417-99df-458e-9a2e-645fccedf47e	6c294f36-83cd-45bc-8a68-818a013d1a91	cfc04116-67a8-4827-a026-c20c8015d7dd	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "session_id": "616e121a-8ed6-40de-856d-6fbdf4586a33", "started_at": "2025-12-06T07:30:15.060840269Z", "finished_at": "2025-12-06T07:30:15.200646516Z", "discovery_type": {"type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6"}}}	{"type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6"}	Discovery Run	2025-12-06 07:30:15.06084+00	2025-12-06 07:30:15.204939+00
6ec52d17-1383-4d07-8377-e56b571443de	6c294f36-83cd-45bc-8a68-818a013d1a91	cfc04116-67a8-4827-a026-c20c8015d7dd	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "session_id": "fc1daa06-7f86-42e2-93e8-51f5ba37ae06", "started_at": "2025-12-06T07:30:15.218118101Z", "finished_at": "2025-12-06T07:31:50.141911546Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-12-06 07:30:15.218118+00	2025-12-06 07:31:50.144251+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
eaa4689d-43e5-4a39-b191-d861e2aae48d	6c294f36-83cd-45bc-8a68-818a013d1a91	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "738b032a-4f68-455c-8a39-a2bed5e65167"}	[{"id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23", "name": "Internet", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "ip_address": "1.1.1.1", "mac_address": null}]	{72a4167c-949e-49c4-9eaf-0bdfdf73b21c}	[{"id": "bbf1c6bd-e490-439e-9d63-c952eb7f6825", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-06 07:30:14.894653+00	2025-12-06 07:30:14.903455+00	f
ef756091-c7a1-4f21-9d41-f455c240a61e	6c294f36-83cd-45bc-8a68-818a013d1a91	Google.com	\N	\N	{"type": "ServiceBinding", "config": "3cd4a5fd-c13e-487b-9585-c98640523d78"}	[{"id": "654da526-2b8e-446d-85f2-a207af94a728", "name": "Internet", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "ip_address": "203.0.113.13", "mac_address": null}]	{5dbfdaa3-7b42-4838-a31e-08cccf61c76a}	[{"id": "584a2318-273a-4146-80df-16004fc9b721", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 07:30:14.894663+00	2025-12-06 07:30:14.908224+00	f
a633e7f9-11d7-4751-b18f-37f935b87e61	6c294f36-83cd-45bc-8a68-818a013d1a91	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "3a641c29-a786-430c-8240-983ad4373586"}	[{"id": "19b4eb94-e106-4208-b578-61230230a0df", "name": "Remote Network", "subnet_id": "4724ca2a-1670-4373-929a-3648996e43c4", "ip_address": "203.0.113.155", "mac_address": null}]	{f1e9a812-dc75-4a61-ade8-54eb2de74164}	[{"id": "0b112576-5b5b-46ba-9b2f-257ab0e4025d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 07:30:14.89467+00	2025-12-06 07:30:14.912162+00	f
525a03e3-3f8f-4322-ab9b-d96cf16487ca	6c294f36-83cd-45bc-8a68-818a013d1a91	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "786bd0cd-9db5-4118-869a-7e44e184e04d", "name": null, "subnet_id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "ip_address": "172.25.0.6", "mac_address": "D2:2E:FD:37:04:C1"}]	{5ae5a516-32fd-4cca-8268-d38f15a720c8}	[{"id": "e2f06893-05e7-4c01-9fb9-2e59f99bcc6c", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:31:00.645123694Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 07:31:00.645126+00	2025-12-06 07:31:15.177256+00	f
8afa46ba-6bae-4432-b130-d898d7eb19b6	6c294f36-83cd-45bc-8a68-818a013d1a91	172.25.0.4	0281cec69476	NetVisor daemon	{"type": "None"}	[{"id": "4383dfd5-2f12-4f72-a47c-6802fc76dfee", "name": "eth0", "subnet_id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "ip_address": "172.25.0.4", "mac_address": "22:8A:7F:E3:42:F7"}]	{507b0cf4-3e75-41ed-beb1-8cf4c819dfbd}	[{"id": "b4f0959c-2cbd-42bf-95ed-7eb55ed76f5f", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:30:15.183675493Z", "type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd"}]}	null	2025-12-06 07:30:15.00586+00	2025-12-06 07:30:15.198238+00	f
e3379ef8-f7df-466e-a3f0-fa4ceef726d7	6c294f36-83cd-45bc-8a68-818a013d1a91	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "430f4a1c-5c77-4b50-b080-5f35904b1c47", "name": null, "subnet_id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "ip_address": "172.25.0.3", "mac_address": "32:7B:72:EB:F1:E3"}]	{306e6ca1-73db-41db-9bf6-0abe8f87f567}	[{"id": "75e6975c-185b-4315-9667-15fb9702e15f", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:30:46.125835763Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 07:30:46.125838+00	2025-12-06 07:31:00.581663+00	f
8965eca5-b55b-4e42-a503-d6f6cb6c2f1f	6c294f36-83cd-45bc-8a68-818a013d1a91	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "30ef9225-3430-4242-a036-5142f169ab55", "name": null, "subnet_id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "ip_address": "172.25.0.5", "mac_address": "3E:96:F6:C2:21:6C"}]	{}	[{"id": "1ac1a454-586e-4e0b-8972-f7293ed3a92e", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "325e7224-0ed4-41d0-a986-ff1f66acbde0", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:31:15.175619007Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 07:31:15.175622+00	2025-12-06 07:31:29.694379+00	f
6ab15a94-ed0c-4335-9b87-5a55b7c0ee3f	6c294f36-83cd-45bc-8a68-818a013d1a91	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "f9e05160-5250-4254-bba9-d02edc188ade", "name": null, "subnet_id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "ip_address": "172.25.0.1", "mac_address": "C2:A7:76:BE:14:DE"}]	{4fbbbc9d-7208-46d1-8f6f-24c629524c9b,6f1d501d-dd2c-453c-862a-c62604a116e6}	[{"id": "8a44ccbb-cd06-465c-ad20-26158fbd0453", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "9f14262a-f31a-4618-8032-7b93e0e7e62c", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "7beddda9-c145-449c-b80c-e9e08cf8c8c8", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "d1549a22-9940-48ee-b154-c1507e4c73d7", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:31:35.735162416Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 07:31:35.735165+00	2025-12-06 07:31:50.136659+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
6c294f36-83cd-45bc-8a68-818a013d1a91	My Network	2025-12-06 07:30:14.893304+00	2025-12-06 07:30:14.893304+00	f	6c84eeb4-bc7f-42f9-9a4e-bf00478c7925
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
6c84eeb4-bc7f-42f9-9a4e-bf00478c7925	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-06 07:30:12.189253+00	2025-12-06 07:30:15.052882+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
72a4167c-949e-49c4-9eaf-0bdfdf73b21c	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:14.894656+00	2025-12-06 07:30:14.894656+00	Cloudflare DNS	eaa4689d-43e5-4a39-b191-d861e2aae48d	[{"id": "738b032a-4f68-455c-8a39-a2bed5e65167", "type": "Port", "port_id": "bbf1c6bd-e490-439e-9d63-c952eb7f6825", "interface_id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23"}]	"Dns Server"	null	{"type": "System"}
5dbfdaa3-7b42-4838-a31e-08cccf61c76a	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:14.894665+00	2025-12-06 07:30:14.894665+00	Google.com	ef756091-c7a1-4f21-9d41-f455c240a61e	[{"id": "3cd4a5fd-c13e-487b-9585-c98640523d78", "type": "Port", "port_id": "584a2318-273a-4146-80df-16004fc9b721", "interface_id": "654da526-2b8e-446d-85f2-a207af94a728"}]	"Web Service"	null	{"type": "System"}
f1e9a812-dc75-4a61-ade8-54eb2de74164	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:14.894672+00	2025-12-06 07:30:14.894672+00	Mobile Device	a633e7f9-11d7-4751-b18f-37f935b87e61	[{"id": "3a641c29-a786-430c-8240-983ad4373586", "type": "Port", "port_id": "0b112576-5b5b-46ba-9b2f-257ab0e4025d", "interface_id": "19b4eb94-e106-4208-b578-61230230a0df"}]	"Client"	null	{"type": "System"}
507b0cf4-3e75-41ed-beb1-8cf4c819dfbd	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:15.183696+00	2025-12-06 07:30:15.183696+00	NetVisor Daemon API	8afa46ba-6bae-4432-b130-d898d7eb19b6	[{"id": "d5a9a16d-739a-40cb-81ab-6d1951c1b4e8", "type": "Port", "port_id": "b4f0959c-2cbd-42bf-95ed-7eb55ed76f5f", "interface_id": "4383dfd5-2f12-4f72-a47c-6802fc76dfee"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-06T07:30:15.183696011Z", "type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd"}]}
306e6ca1-73db-41db-9bf6-0abe8f87f567	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:53.417869+00	2025-12-06 07:30:53.417869+00	NetVisor Server API	e3379ef8-f7df-466e-a3f0-fa4ceef726d7	[{"id": "af05750f-71e0-456d-82ed-ea7de3fdcdd5", "type": "Port", "port_id": "75e6975c-185b-4315-9667-15fb9702e15f", "interface_id": "430f4a1c-5c77-4b50-b080-5f35904b1c47"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T07:30:53.417851289Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5ae5a516-32fd-4cca-8268-d38f15a720c8	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:31:15.162151+00	2025-12-06 07:31:15.162151+00	PostgreSQL	525a03e3-3f8f-4322-ab9b-d96cf16487ca	[{"id": "311c7e57-1738-4305-9b56-641f8e7493ce", "type": "Port", "port_id": "e2f06893-05e7-4c01-9fb9-2e59f99bcc6c", "interface_id": "786bd0cd-9db5-4118-869a-7e44e184e04d"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T07:31:15.162136233Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
4fbbbc9d-7208-46d1-8f6f-24c629524c9b	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:31:42.917467+00	2025-12-06 07:31:42.917467+00	NetVisor Server API	6ab15a94-ed0c-4335-9b87-5a55b7c0ee3f	[{"id": "1cf3e016-496d-48ed-886c-df87844f4a6c", "type": "Port", "port_id": "8a44ccbb-cd06-465c-ad20-26158fbd0453", "interface_id": "f9e05160-5250-4254-bba9-d02edc188ade"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T07:31:42.917447847Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
6f1d501d-dd2c-453c-862a-c62604a116e6	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:31:50.123788+00	2025-12-06 07:31:50.123788+00	Home Assistant	6ab15a94-ed0c-4335-9b87-5a55b7c0ee3f	[{"id": "4236bf0b-e8e4-47da-8b4e-198e96211e3a", "type": "Port", "port_id": "9f14262a-f31a-4618-8032-7b93e0e7e62c", "interface_id": "f9e05160-5250-4254-bba9-d02edc188ade"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T07:31:50.123768888Z", "type": "Network", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
b8145d91-8059-403c-ac36-22e6a87258d1	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:14.894591+00	2025-12-06 07:30:14.894591+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
4724ca2a-1670-4373-929a-3648996e43c4	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:14.894601+00	2025-12-06 07:30:14.894601+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
8ce6d095-6f7f-4467-a319-e7842f8d9c0f	6c294f36-83cd-45bc-8a68-818a013d1a91	2025-12-06 07:30:15.061021+00	2025-12-06 07:30:15.061021+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-06T07:30:15.061019182Z", "type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
ab843381-ae08-4c5a-82cc-112f0986e21e	6c294f36-83cd-45bc-8a68-818a013d1a91	My Topology	[]	[{"id": "b8145d91-8059-403c-ac36-22e6a87258d1", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "4724ca2a-1670-4373-929a-3648996e43c4", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23", "size": {"x": 250, "y": 100}, "header": null, "host_id": "eaa4689d-43e5-4a39-b191-d861e2aae48d", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "interface_id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23"}, {"id": "654da526-2b8e-446d-85f2-a207af94a728", "size": {"x": 250, "y": 100}, "header": null, "host_id": "ef756091-c7a1-4f21-9d41-f455c240a61e", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "interface_id": "654da526-2b8e-446d-85f2-a207af94a728"}, {"id": "19b4eb94-e106-4208-b578-61230230a0df", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a633e7f9-11d7-4751-b18f-37f935b87e61", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "4724ca2a-1670-4373-929a-3648996e43c4", "interface_id": "19b4eb94-e106-4208-b578-61230230a0df"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "eaa4689d-43e5-4a39-b191-d861e2aae48d", "name": "Cloudflare DNS", "ports": [{"id": "bbf1c6bd-e490-439e-9d63-c952eb7f6825", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "738b032a-4f68-455c-8a39-a2bed5e65167"}, "hostname": null, "services": ["72a4167c-949e-49c4-9eaf-0bdfdf73b21c"], "created_at": "2025-12-06T07:30:14.894653Z", "interfaces": [{"id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23", "name": "Internet", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.903455Z", "description": null, "virtualization": null}, {"id": "ef756091-c7a1-4f21-9d41-f455c240a61e", "name": "Google.com", "ports": [{"id": "584a2318-273a-4146-80df-16004fc9b721", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3cd4a5fd-c13e-487b-9585-c98640523d78"}, "hostname": null, "services": ["5dbfdaa3-7b42-4838-a31e-08cccf61c76a"], "created_at": "2025-12-06T07:30:14.894663Z", "interfaces": [{"id": "654da526-2b8e-446d-85f2-a207af94a728", "name": "Internet", "subnet_id": "b8145d91-8059-403c-ac36-22e6a87258d1", "ip_address": "203.0.113.13", "mac_address": null}], "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.908224Z", "description": null, "virtualization": null}, {"id": "a633e7f9-11d7-4751-b18f-37f935b87e61", "name": "Mobile Device", "ports": [{"id": "0b112576-5b5b-46ba-9b2f-257ab0e4025d", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3a641c29-a786-430c-8240-983ad4373586"}, "hostname": null, "services": ["f1e9a812-dc75-4a61-ade8-54eb2de74164"], "created_at": "2025-12-06T07:30:14.894670Z", "interfaces": [{"id": "19b4eb94-e106-4208-b578-61230230a0df", "name": "Remote Network", "subnet_id": "4724ca2a-1670-4373-929a-3648996e43c4", "ip_address": "203.0.113.155", "mac_address": null}], "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.912162Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "b8145d91-8059-403c-ac36-22e6a87258d1", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-06T07:30:14.894591Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.894591Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "4724ca2a-1670-4373-929a-3648996e43c4", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-06T07:30:14.894601Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.894601Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "8ce6d095-6f7f-4467-a319-e7842f8d9c0f", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-06T07:30:15.061019182Z", "type": "SelfReport", "host_id": "8afa46ba-6bae-4432-b130-d898d7eb19b6", "daemon_id": "cfc04116-67a8-4827-a026-c20c8015d7dd"}]}, "created_at": "2025-12-06T07:30:15.061021Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:15.061021Z", "description": null, "subnet_type": "Lan"}]	[{"id": "72a4167c-949e-49c4-9eaf-0bdfdf73b21c", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "eaa4689d-43e5-4a39-b191-d861e2aae48d", "bindings": [{"id": "738b032a-4f68-455c-8a39-a2bed5e65167", "type": "Port", "port_id": "bbf1c6bd-e490-439e-9d63-c952eb7f6825", "interface_id": "bcfcadf8-3d91-4b39-9df1-6865b7a59a23"}], "created_at": "2025-12-06T07:30:14.894656Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.894656Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5dbfdaa3-7b42-4838-a31e-08cccf61c76a", "name": "Google.com", "source": {"type": "System"}, "host_id": "ef756091-c7a1-4f21-9d41-f455c240a61e", "bindings": [{"id": "3cd4a5fd-c13e-487b-9585-c98640523d78", "type": "Port", "port_id": "584a2318-273a-4146-80df-16004fc9b721", "interface_id": "654da526-2b8e-446d-85f2-a207af94a728"}], "created_at": "2025-12-06T07:30:14.894665Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.894665Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "f1e9a812-dc75-4a61-ade8-54eb2de74164", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "a633e7f9-11d7-4751-b18f-37f935b87e61", "bindings": [{"id": "3a641c29-a786-430c-8240-983ad4373586", "type": "Port", "port_id": "0b112576-5b5b-46ba-9b2f-257ab0e4025d", "interface_id": "19b4eb94-e106-4208-b578-61230230a0df"}], "created_at": "2025-12-06T07:30:14.894672Z", "network_id": "6c294f36-83cd-45bc-8a68-818a013d1a91", "updated_at": "2025-12-06T07:30:14.894672Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-06 07:30:14.916284+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-06 07:30:14.912859+00	2025-12-06 07:31:50.19963+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
65ad976b-0af0-4c1f-a6a9-c077c7f64772	2025-12-06 07:30:12.191264+00	2025-12-06 07:30:14.876299+00	$argon2id$v=19$m=19456,t=2,p=1$1vOyYcrnXLajse/lDxMdYw$+QNR5w8vPa1N0LtUbGR0cRBudZ6g6zenVU4QyA4SOko	\N	\N	\N	user@gmail.com	6c84eeb4-bc7f-42f9-9a4e-bf00478c7925	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
bNMUc2Xy5ASU48zahXA2FQ	\\x93c41015367085dacce39404e4f2657314d36c81a7757365725f6964d92436356164393736622d306166302d346331662d613661392d63303737633766363437373299cd07ea05071e0ece34678b43000000	2026-01-05 07:30:14.879201+00
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

\unrestrict EApbjVwwT5nnfneMft3bg3H6TxceKbRVz7d6d0LftCN01bdWMHgLVhicVklgNIm

