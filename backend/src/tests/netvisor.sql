--
-- PostgreSQL database dump
--

\restrict DpS834dYdaGDBbai7BKY9T9sjbf9rFdKfJHBAocwIS1pqbTLVM6HQsHWKNrj5ek

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
20251006215000	users	2025-12-06 23:18:45.157834+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	1763959
20251006215100	networks	2025-12-06 23:18:45.160079+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	1745750
20251006215151	create hosts	2025-12-06 23:18:45.161986+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1189000
20251006215155	create subnets	2025-12-06 23:18:45.163324+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1097459
20251006215201	create groups	2025-12-06 23:18:45.164569+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1189958
20251006215204	create daemons	2025-12-06 23:18:45.165903+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	1062125
20251006215212	create services	2025-12-06 23:18:45.167102+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	1193250
20251029193448	user-auth	2025-12-06 23:18:45.168448+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	6217041
20251030044828	daemon api	2025-12-06 23:18:45.174813+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	536541
20251030170438	host-hide	2025-12-06 23:18:45.175493+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	560334
20251102224919	create discovery	2025-12-06 23:18:45.176192+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	4117417
20251106235621	normalize-daemon-cols	2025-12-06 23:18:45.180487+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	574958
20251107034459	api keys	2025-12-06 23:18:45.181203+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	3468041
20251107222650	oidc-auth	2025-12-06 23:18:45.184825+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	10010250
20251110181948	orgs-billing	2025-12-06 23:18:45.194984+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	2931583
20251113223656	group-enhancements	2025-12-06 23:18:45.198067+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	346209
20251117032720	daemon-mode	2025-12-06 23:18:45.198529+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	322083
20251118143058	set-default-plan	2025-12-06 23:18:45.198967+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	535750
20251118225043	save-topology	2025-12-06 23:18:45.199618+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	2428125
20251123232748	network-permissions	2025-12-06 23:18:45.202228+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	1023208
20251125001342	billing-updates	2025-12-06 23:18:45.203407+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	364834
20251128035448	org-onboarding-status	2025-12-06 23:18:45.203901+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	440334
20251129180942	nfs-consolidate	2025-12-06 23:18:45.204469+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	372667
20251206052641	discovery-progress	2025-12-06 23:18:45.204956+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	473042
20251206202200	plan-fix	2025-12-06 23:18:45.205549+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	299333
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
79cec96b-e843-40df-9895-1ee188e6c5c6	759be785b2bf490e86dc685b774609d2	34ebd746-32fb-4650-a6bf-029b5af6af44	Integrated Daemon API Key	2025-12-06 23:18:47.842281+00	2025-12-06 23:19:35.489793+00	2025-12-06 23:19:35.489499+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
8a0f70f1-7ddb-4174-8c38-53923cf78041	34ebd746-32fb-4650-a6bf-029b5af6af44	e5415714-8e53-4274-833c-87af366995ce	"172.25.0.4"	60073	2025-12-06 23:18:47.88438+00	2025-12-06 23:19:22.24613+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["6d807387-5aa2-438c-9d42-94febf1b5671"]}	2025-12-06 23:19:22.246609+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
ee324a1c-67df-43c7-9a4b-8cb033906090	34ebd746-32fb-4650-a6bf-029b5af6af44	8a0f70f1-7ddb-4174-8c38-53923cf78041	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce"}	Self Report @ 172.25.0.4	2025-12-06 23:18:47.887157+00	2025-12-06 23:18:47.887157+00
b4d2dc1c-a3fc-4ba6-8cb3-429a18ed98a8	34ebd746-32fb-4650-a6bf-029b5af6af44	8a0f70f1-7ddb-4174-8c38-53923cf78041	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-12-06 23:18:47.889832+00	2025-12-06 23:18:47.889832+00
869ebd2f-04c6-4082-868c-c31355e62e05	34ebd746-32fb-4650-a6bf-029b5af6af44	8a0f70f1-7ddb-4174-8c38-53923cf78041	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "session_id": "801eb05f-d065-4851-bd96-f5bfdd43ff4e", "started_at": "2025-12-06T23:18:47.889700467Z", "finished_at": "2025-12-06T23:18:47.929599676Z", "discovery_type": {"type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce"}}}	{"type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce"}	Discovery Run	2025-12-06 23:18:47.8897+00	2025-12-06 23:18:47.930797+00
6e8a0226-66ca-4b3c-8745-d5b202e0e262	34ebd746-32fb-4650-a6bf-029b5af6af44	8a0f70f1-7ddb-4174-8c38-53923cf78041	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "session_id": "a13c1548-5cb8-4b13-8ee3-9ecdfdbe902c", "started_at": "2025-12-06T23:18:47.935383509Z", "finished_at": "2025-12-06T23:19:35.488713586Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-12-06 23:18:47.935383+00	2025-12-06 23:19:35.489585+00
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
4b5529e3-a032-423e-960f-a1963848a93e	34ebd746-32fb-4650-a6bf-029b5af6af44	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "cbfb6ea3-147f-4e45-8758-585be874bbc1"}	[{"id": "39ab7297-976d-40b6-a398-d0231ac5b4be", "name": "Internet", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "ip_address": "1.1.1.1", "mac_address": null}]	{b4ebf19f-04ad-489e-849e-0b84fedd3510}	[{"id": "16135f33-12e3-4bdb-90b8-0f58e6d67bc2", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-06 23:18:47.833551+00	2025-12-06 23:18:47.836673+00	f
b6b23361-4100-4b06-a02f-47f3a7549664	34ebd746-32fb-4650-a6bf-029b5af6af44	Google.com	\N	\N	{"type": "ServiceBinding", "config": "4d120faa-505e-44b0-ae29-ea37ae760abe"}	[{"id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd", "name": "Internet", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "ip_address": "203.0.113.141", "mac_address": null}]	{4aade4e1-9193-421a-93f4-b6ca199ecc4c}	[{"id": "9aee459f-23a5-4546-9f87-42702533170f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 23:18:47.833554+00	2025-12-06 23:18:47.838305+00	f
1d43cd6b-9fb4-47ca-b7b1-e585b5290136	34ebd746-32fb-4650-a6bf-029b5af6af44	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "221b58fc-3b74-4a10-bad5-ae0ea07e1f24"}	[{"id": "0c6d523e-c561-4ef6-9060-0a2334051f4d", "name": "Remote Network", "subnet_id": "f860018d-c3a2-4990-873c-5cb7a83db340", "ip_address": "203.0.113.246", "mac_address": null}]	{a2d42806-86e5-4e59-8ed2-6bd224097e30}	[{"id": "33b0a032-e291-42f8-9a90-1ae122bc050f", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 23:18:47.833556+00	2025-12-06 23:18:47.839686+00	f
a3d16aa5-3b63-443e-aa58-e8521b74a0f0	34ebd746-32fb-4650-a6bf-029b5af6af44	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "189b130e-004d-4227-b448-8cf48f132813", "name": null, "subnet_id": "6d807387-5aa2-438c-9d42-94febf1b5671", "ip_address": "172.25.0.3", "mac_address": "96:5F:BA:3A:B9:8A"}]	{e54aa657-4787-4543-89af-2b3552ad5e2c}	[{"id": "49749c85-0411-4e7d-81a3-79d2ba32a6ac", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:19:05.523717753Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 23:19:05.523719+00	2025-12-06 23:19:13.534082+00	f
e5415714-8e53-4274-833c-87af366995ce	34ebd746-32fb-4650-a6bf-029b5af6af44	172.25.0.4	f33c9dbe0380	NetVisor daemon	{"type": "None"}	[{"id": "60fe21d2-1e06-4b3e-abad-af237eacad48", "name": "eth0", "subnet_id": "6d807387-5aa2-438c-9d42-94febf1b5671", "ip_address": "172.25.0.4", "mac_address": "AA:97:87:4E:44:32"}]	{edf55f4d-4016-480a-8da5-7bfdcbddbb45}	[{"id": "28bc10ba-e5c8-48d2-957c-6e9553ab88df", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:18:47.895968426Z", "type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041"}]}	null	2025-12-06 23:18:47.849404+00	2025-12-06 23:18:47.928595+00	f
136d0ded-af76-47a6-abe9-56f89916ec61	34ebd746-32fb-4650-a6bf-029b5af6af44	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "67716bab-1ef0-452f-826c-b60cce5c13d7", "name": null, "subnet_id": "6d807387-5aa2-438c-9d42-94febf1b5671", "ip_address": "172.25.0.6", "mac_address": "82:AF:21:78:9D:B9"}]	{6d94390b-6025-4d55-a376-3d8982d07d21}	[{"id": "d93e1fa0-91ea-45f2-a20a-818bd319e2ea", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:18:57.244416680Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 23:18:57.244423+00	2025-12-06 23:19:05.509873+00	f
21939888-4d0d-4e56-8a2e-89461633165f	34ebd746-32fb-4650-a6bf-029b5af6af44	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "a519c9cf-926f-42cc-9365-0c517a65c4e5", "name": null, "subnet_id": "6d807387-5aa2-438c-9d42-94febf1b5671", "ip_address": "172.25.0.5", "mac_address": "12:89:F3:9C:5E:2E"}]	{21f74fc1-ad1e-4445-a5ad-4fedc662a0b6}	[{"id": "9b8cb953-6b28-4924-8c63-e0c3775eccd8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "db1eb0e3-125f-4cf9-8fa2-357e08ac6633", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:19:13.532025007Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 23:19:13.532027+00	2025-12-06 23:19:21.424078+00	f
050785f1-c60b-4425-ae9b-0bc6a0ec2fef	34ebd746-32fb-4650-a6bf-029b5af6af44	Home Assistant	\N	\N	{"type": "None"}	[{"id": "f828fbe8-0fb2-4b78-b4ee-197e98478500", "name": null, "subnet_id": "6d807387-5aa2-438c-9d42-94febf1b5671", "ip_address": "172.25.0.1", "mac_address": "F6:0E:CE:FB:33:77"}]	{31b66bb4-6d8a-413d-87e0-fa5b352673e2,008ec16f-73c7-4950-8a0d-1fa9c1897a5f,d1a50e49-b449-4b1c-9d8b-17146fce9587,d896a068-7b8a-4832-9512-6970416ae50b}	[{"id": "d45e9d03-8e4e-4f9c-b57b-bd93f4d6fd43", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "dd6b50d6-1823-4131-a7fe-834401ef93eb", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "2d5a37b9-c283-41a1-a07a-634a645011e2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}, {"id": "85295fd8-aba2-4e89-a25c-c067a7708f04", "type": "Custom", "number": 111, "protocol": "Tcp"}, {"id": "88372568-d0e4-417d-871c-104e309d78a4", "type": "Custom", "number": 5435, "protocol": "Tcp"}, {"id": "c7b54557-240f-4e07-a62a-86030c5aa6d3", "type": "Custom", "number": 55875, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:19:27.542070055Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 23:19:27.542081+00	2025-12-06 23:19:35.486333+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
34ebd746-32fb-4650-a6bf-029b5af6af44	My Network	2025-12-06 23:18:47.832984+00	2025-12-06 23:18:47.832984+00	f	d9f919eb-be9a-46c1-8ece-260b080e8c63
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
d9f919eb-be9a-46c1-8ece-260b080e8c63	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-06 23:18:45.246832+00	2025-12-06 23:18:47.886676+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
b4ebf19f-04ad-489e-849e-0b84fedd3510	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.833552+00	2025-12-06 23:18:47.833552+00	Cloudflare DNS	4b5529e3-a032-423e-960f-a1963848a93e	[{"id": "cbfb6ea3-147f-4e45-8758-585be874bbc1", "type": "Port", "port_id": "16135f33-12e3-4bdb-90b8-0f58e6d67bc2", "interface_id": "39ab7297-976d-40b6-a398-d0231ac5b4be"}]	"Dns Server"	null	{"type": "System"}
4aade4e1-9193-421a-93f4-b6ca199ecc4c	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.833554+00	2025-12-06 23:18:47.833554+00	Google.com	b6b23361-4100-4b06-a02f-47f3a7549664	[{"id": "4d120faa-505e-44b0-ae29-ea37ae760abe", "type": "Port", "port_id": "9aee459f-23a5-4546-9f87-42702533170f", "interface_id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd"}]	"Web Service"	null	{"type": "System"}
a2d42806-86e5-4e59-8ed2-6bd224097e30	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.833557+00	2025-12-06 23:18:47.833557+00	Mobile Device	1d43cd6b-9fb4-47ca-b7b1-e585b5290136	[{"id": "221b58fc-3b74-4a10-bad5-ae0ea07e1f24", "type": "Port", "port_id": "33b0a032-e291-42f8-9a90-1ae122bc050f", "interface_id": "0c6d523e-c561-4ef6-9060-0a2334051f4d"}]	"Client"	null	{"type": "System"}
edf55f4d-4016-480a-8da5-7bfdcbddbb45	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.895989+00	2025-12-06 23:18:47.895989+00	NetVisor Daemon API	e5415714-8e53-4274-833c-87af366995ce	[{"id": "780d2aec-655e-4325-b0ab-64d979e79b31", "type": "Port", "port_id": "28bc10ba-e5c8-48d2-957c-6e9553ab88df", "interface_id": "60fe21d2-1e06-4b3e-abad-af237eacad48"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-06T23:18:47.895986342Z", "type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041"}]}
6d94390b-6025-4d55-a376-3d8982d07d21	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:05.498221+00	2025-12-06 23:19:05.498221+00	PostgreSQL	136d0ded-af76-47a6-abe9-56f89916ec61	[{"id": "3bee2798-9505-4958-8c99-cf43d4dc1cf5", "type": "Port", "port_id": "d93e1fa0-91ea-45f2-a20a-818bd319e2ea", "interface_id": "67716bab-1ef0-452f-826c-b60cce5c13d7"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T23:19:05.498207878Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
e54aa657-4787-4543-89af-2b3552ad5e2c	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:12.739307+00	2025-12-06 23:19:12.739307+00	NetVisor Server API	a3d16aa5-3b63-443e-aa58-e8521b74a0f0	[{"id": "614efacd-c43d-4c94-ab2b-50bb42dc3832", "type": "Port", "port_id": "49749c85-0411-4e7d-81a3-79d2ba32a6ac", "interface_id": "189b130e-004d-4227-b448-8cf48f132813"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T23:19:12.739281423Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
21f74fc1-ad1e-4445-a5ad-4fedc662a0b6	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:21.420286+00	2025-12-06 23:19:21.420286+00	Unclaimed Open Ports	21939888-4d0d-4e56-8a2e-89461633165f	[{"id": "3e3e9b86-65f1-46a3-98fc-c62ec5487310", "type": "Interface", "interface_id": "a519c9cf-926f-42cc-9365-0c517a65c4e5"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T23:19:21.420280344Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d1a50e49-b449-4b1c-9d8b-17146fce9587	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:35.481019+00	2025-12-06 23:19:35.481019+00	PostgreSQL	050785f1-c60b-4425-ae9b-0bc6a0ec2fef	[{"id": "c4ad43b3-6606-4798-8fca-f846417010ce", "type": "Port", "port_id": "2d5a37b9-c283-41a1-a07a-634a645011e2", "interface_id": "f828fbe8-0fb2-4b78-b4ee-197e98478500"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T23:19:35.481013003Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
008ec16f-73c7-4950-8a0d-1fa9c1897a5f	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:34.69862+00	2025-12-06 23:19:34.69862+00	NetVisor Server API	050785f1-c60b-4425-ae9b-0bc6a0ec2fef	[{"id": "41f07de0-f727-4e50-ab20-ba879dedcb45", "type": "Port", "port_id": "dd6b50d6-1823-4131-a7fe-834401ef93eb", "interface_id": "f828fbe8-0fb2-4b78-b4ee-197e98478500"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T23:19:34.698612586Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
31b66bb4-6d8a-413d-87e0-fa5b352673e2	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:28.359777+00	2025-12-06 23:19:28.359777+00	Home Assistant	050785f1-c60b-4425-ae9b-0bc6a0ec2fef	[{"id": "74738b24-e873-42b7-8412-5442f4d6d262", "type": "Port", "port_id": "d45e9d03-8e4e-4f9c-b57b-bd93f4d6fd43", "interface_id": "f828fbe8-0fb2-4b78-b4ee-197e98478500"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T23:19:28.359771041Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d896a068-7b8a-4832-9512-6970416ae50b	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:19:35.481118+00	2025-12-06 23:19:35.481118+00	Unclaimed Open Ports	050785f1-c60b-4425-ae9b-0bc6a0ec2fef	[{"id": "eec49859-610a-4166-9bce-b77038c38eb3", "type": "Interface", "interface_id": "f828fbe8-0fb2-4b78-b4ee-197e98478500"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T23:19:35.481116461Z", "type": "Network", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.833515+00	2025-12-06 23:18:47.833515+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
f860018d-c3a2-4990-873c-5cb7a83db340	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.833517+00	2025-12-06 23:18:47.833517+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
6d807387-5aa2-438c-9d42-94febf1b5671	34ebd746-32fb-4650-a6bf-029b5af6af44	2025-12-06 23:18:47.890018+00	2025-12-06 23:18:47.890018+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-06T23:18:47.890009676Z", "type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
5d019572-6164-4c8a-9c83-fe7495ebf514	34ebd746-32fb-4650-a6bf-029b5af6af44	My Topology	[]	[{"id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "f860018d-c3a2-4990-873c-5cb7a83db340", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "39ab7297-976d-40b6-a398-d0231ac5b4be", "size": {"x": 250, "y": 100}, "header": null, "host_id": "4b5529e3-a032-423e-960f-a1963848a93e", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "interface_id": "39ab7297-976d-40b6-a398-d0231ac5b4be"}, {"id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd", "size": {"x": 250, "y": 100}, "header": null, "host_id": "b6b23361-4100-4b06-a02f-47f3a7549664", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "interface_id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd"}, {"id": "0c6d523e-c561-4ef6-9060-0a2334051f4d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "1d43cd6b-9fb4-47ca-b7b1-e585b5290136", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f860018d-c3a2-4990-873c-5cb7a83db340", "interface_id": "0c6d523e-c561-4ef6-9060-0a2334051f4d"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "4b5529e3-a032-423e-960f-a1963848a93e", "name": "Cloudflare DNS", "ports": [{"id": "16135f33-12e3-4bdb-90b8-0f58e6d67bc2", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "cbfb6ea3-147f-4e45-8758-585be874bbc1"}, "hostname": null, "services": ["b4ebf19f-04ad-489e-849e-0b84fedd3510"], "created_at": "2025-12-06T23:18:47.833551Z", "interfaces": [{"id": "39ab7297-976d-40b6-a398-d0231ac5b4be", "name": "Internet", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.836673Z", "description": null, "virtualization": null}, {"id": "b6b23361-4100-4b06-a02f-47f3a7549664", "name": "Google.com", "ports": [{"id": "9aee459f-23a5-4546-9f87-42702533170f", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "4d120faa-505e-44b0-ae29-ea37ae760abe"}, "hostname": null, "services": ["4aade4e1-9193-421a-93f4-b6ca199ecc4c"], "created_at": "2025-12-06T23:18:47.833554Z", "interfaces": [{"id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd", "name": "Internet", "subnet_id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "ip_address": "203.0.113.141", "mac_address": null}], "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.838305Z", "description": null, "virtualization": null}, {"id": "1d43cd6b-9fb4-47ca-b7b1-e585b5290136", "name": "Mobile Device", "ports": [{"id": "33b0a032-e291-42f8-9a90-1ae122bc050f", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "221b58fc-3b74-4a10-bad5-ae0ea07e1f24"}, "hostname": null, "services": ["a2d42806-86e5-4e59-8ed2-6bd224097e30"], "created_at": "2025-12-06T23:18:47.833556Z", "interfaces": [{"id": "0c6d523e-c561-4ef6-9060-0a2334051f4d", "name": "Remote Network", "subnet_id": "f860018d-c3a2-4990-873c-5cb7a83db340", "ip_address": "203.0.113.246", "mac_address": null}], "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.839686Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "3f5c9bd1-d1a7-4783-8dec-9ff285fabf3b", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-06T23:18:47.833515Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.833515Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "f860018d-c3a2-4990-873c-5cb7a83db340", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-06T23:18:47.833517Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.833517Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "6d807387-5aa2-438c-9d42-94febf1b5671", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-06T23:18:47.890009676Z", "type": "SelfReport", "host_id": "e5415714-8e53-4274-833c-87af366995ce", "daemon_id": "8a0f70f1-7ddb-4174-8c38-53923cf78041"}]}, "created_at": "2025-12-06T23:18:47.890018Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.890018Z", "description": null, "subnet_type": "Lan"}]	[{"id": "b4ebf19f-04ad-489e-849e-0b84fedd3510", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "4b5529e3-a032-423e-960f-a1963848a93e", "bindings": [{"id": "cbfb6ea3-147f-4e45-8758-585be874bbc1", "type": "Port", "port_id": "16135f33-12e3-4bdb-90b8-0f58e6d67bc2", "interface_id": "39ab7297-976d-40b6-a398-d0231ac5b4be"}], "created_at": "2025-12-06T23:18:47.833552Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.833552Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "4aade4e1-9193-421a-93f4-b6ca199ecc4c", "name": "Google.com", "source": {"type": "System"}, "host_id": "b6b23361-4100-4b06-a02f-47f3a7549664", "bindings": [{"id": "4d120faa-505e-44b0-ae29-ea37ae760abe", "type": "Port", "port_id": "9aee459f-23a5-4546-9f87-42702533170f", "interface_id": "fc3d7e52-75d8-488e-8fbe-a326b90e43fd"}], "created_at": "2025-12-06T23:18:47.833554Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.833554Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "a2d42806-86e5-4e59-8ed2-6bd224097e30", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "1d43cd6b-9fb4-47ca-b7b1-e585b5290136", "bindings": [{"id": "221b58fc-3b74-4a10-bad5-ae0ea07e1f24", "type": "Port", "port_id": "33b0a032-e291-42f8-9a90-1ae122bc050f", "interface_id": "0c6d523e-c561-4ef6-9060-0a2334051f4d"}], "created_at": "2025-12-06T23:18:47.833557Z", "network_id": "34ebd746-32fb-4650-a6bf-029b5af6af44", "updated_at": "2025-12-06T23:18:47.833557Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-06 23:18:47.841099+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-06 23:18:47.839942+00	2025-12-06 23:19:21.451683+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
960b4e9d-c2fa-474f-bb88-710dfc706696	2025-12-06 23:18:45.247776+00	2025-12-06 23:18:47.824915+00	$argon2id$v=19$m=19456,t=2,p=1$yio0WSzQbRrNXSBVBVRQeg$jPfipTrWx9euxekq8o9SfK0e+0TDehrHlkJ/tEoINgE	\N	\N	\N	user@gmail.com	d9f919eb-be9a-46c1-8ece-260b080e8c63	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
ZWN6EjXZN-aiQvF1Iigo-g	\\x93c410fa28282275f142a2e637d935127a636581a7757365725f6964d92439363062346539642d633266612d343734662d626238382d37313064666337303636393699cd07ea0517122fce31408355000000	2026-01-05 23:18:47.826311+00
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

\unrestrict DpS834dYdaGDBbai7BKY9T9sjbf9rFdKfJHBAocwIS1pqbTLVM6HQsHWKNrj5ek

