--
-- PostgreSQL database dump
--

\restrict ilnpc7s4L4PuZDxtmxLn47LEFt0SgdzIrNGX9UZqmPS44iCENycvLaQfmIQUqCe

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
    is_onboarded boolean
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
20251006215000	users	2025-11-26 16:01:21.106085+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3415625
20251006215100	networks	2025-11-26 16:01:21.110187+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3793942
20251006215151	create hosts	2025-11-26 16:01:21.114294+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3803810
20251006215155	create subnets	2025-11-26 16:01:21.118433+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3786488
20251006215201	create groups	2025-11-26 16:01:21.122548+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3724131
20251006215204	create daemons	2025-11-26 16:01:21.126599+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4218435
20251006215212	create services	2025-11-26 16:01:21.131186+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4885001
20251029193448	user-auth	2025-11-26 16:01:21.138761+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3564643
20251030044828	daemon api	2025-11-26 16:01:21.142601+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1497559
20251030170438	host-hide	2025-11-26 16:01:21.144416+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1108772
20251102224919	create discovery	2025-11-26 16:01:21.145933+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9408376
20251106235621	normalize-daemon-cols	2025-11-26 16:01:21.155638+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1750622
20251107034459	api keys	2025-11-26 16:01:21.157815+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7176685
20251107222650	oidc-auth	2025-11-26 16:01:21.165353+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	25475469
20251110181948	orgs-billing	2025-11-26 16:01:21.191227+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10080642
20251113223656	group-enhancements	2025-11-26 16:01:21.201657+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1050233
20251117032720	daemon-mode	2025-11-26 16:01:21.20308+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1132801
20251118143058	set-default-plan	2025-11-26 16:01:21.20457+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1247556
20251118225043	save-topology	2025-11-26 16:01:21.206236+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9017526
20251123232748	network-permissions	2025-11-26 16:01:21.215672+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2676173
20251125001342	billing-updates	2025-11-26 16:01:21.218666+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	936863
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
9b575915-bd59-4d3a-968d-96a7d87e984d	040d02ee499f42d39e682b23a6a9146a	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	Integrated Daemon API Key	2025-11-26 16:01:24.974352+00	2025-11-26 16:02:32.044071+00	2025-11-26 16:02:32.043232+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
96b6f0ac-7d76-499a-8ec8-2acdec49133e	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	b70e0411-641e-425c-a1b5-f9a4548586ed	"172.25.0.4"	60073	2025-11-26 16:01:25.025346+00	2025-11-26 16:01:25.025345+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["6cc922e0-33d0-498c-b9ec-c6e8b1485558"]}	2025-11-26 16:01:25.044666+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
0bc0afa9-782f-475d-8242-b5728023d6cb	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	96b6f0ac-7d76-499a-8ec8-2acdec49133e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed"}	Self Report @ 172.25.0.4	2025-11-26 16:01:25.027051+00	2025-11-26 16:01:25.027051+00
e119507e-e29c-4a2d-97bb-45f5d3260db9	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	96b6f0ac-7d76-499a-8ec8-2acdec49133e	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-26 16:01:25.033616+00	2025-11-26 16:01:25.033616+00
b3f0a594-e982-4730-a48f-8e201878f76d	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	96b6f0ac-7d76-499a-8ec8-2acdec49133e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "processed": 1, "network_id": "421cbc3e-153d-48d8-a3f0-060fc0b3ebd5", "session_id": "ce3ec553-0803-4819-a81c-500fe943c8fa", "started_at": "2025-11-26T16:01:25.033165419Z", "finished_at": "2025-11-26T16:01:25.054492691Z", "discovery_type": {"type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed"}	Discovery Run	2025-11-26 16:01:25.033165+00	2025-11-26 16:01:25.08789+00
1ec1a772-1fec-48ec-b79f-02e1bdc4dd19	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	96b6f0ac-7d76-499a-8ec8-2acdec49133e	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "processed": 11, "network_id": "421cbc3e-153d-48d8-a3f0-060fc0b3ebd5", "session_id": "9669c972-fc48-4055-b5dd-481952af8855", "started_at": "2025-11-26T16:01:25.107919929Z", "finished_at": "2025-11-26T16:02:32.042362292Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-26 16:01:25.107919+00	2025-11-26 16:02:32.043497+00
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
60f11702-d6d2-4740-bec6-02aa76c655fe	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "eb166ebe-28f4-4e0a-8710-d284f5407db4"}	[{"id": "4ae679fc-5d0f-4721-988a-3c46ef544b52", "name": "Internet", "subnet_id": "0df07dcc-6d3f-42db-87ae-be8bfff1dd63", "ip_address": "1.1.1.1", "mac_address": null}]	{38928849-40c5-43f4-85fe-7309a2c191ff}	[{"id": "9e828768-38f2-4314-995b-300eb66c0a6c", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-26 16:01:24.949109+00	2025-11-26 16:01:24.958807+00	f
023c8b13-47c2-4c73-bbfd-69fd2f17b843	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	Google.com	\N	\N	{"type": "ServiceBinding", "config": "d0a7ec92-893b-448e-b24c-33417075c259"}	[{"id": "b7f62f73-a202-4da2-8053-ed6697fa3dce", "name": "Internet", "subnet_id": "0df07dcc-6d3f-42db-87ae-be8bfff1dd63", "ip_address": "203.0.113.40", "mac_address": null}]	{d3f92b79-1e91-4558-b64e-c89b9c3ed194}	[{"id": "fad42b72-ce0f-4d44-9a2f-009e1d11317f", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 16:01:24.949116+00	2025-11-26 16:01:24.963975+00	f
3e1ea7bc-1045-4099-8d31-305a207da7ae	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "b0bdc43f-7550-4aed-85c8-916f5ba7a61b"}	[{"id": "3635dae8-ce5a-4f4e-98bb-f8ce7ac36ca0", "name": "Remote Network", "subnet_id": "f19bdbb9-a3e4-4097-b480-ab87ab4ecc39", "ip_address": "203.0.113.173", "mac_address": null}]	{076093e5-3530-406c-b592-f287e1969a00}	[{"id": "54c5b26b-8723-4a09-8643-6263ace244fe", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 16:01:24.949121+00	2025-11-26 16:01:24.973441+00	f
e21d31da-a027-424d-ab4e-a5870dace7fe	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "77347aa0-472e-4dc5-bc2d-cf7860d5afdf", "name": null, "subnet_id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "ip_address": "172.25.0.5", "mac_address": "A2:B5:61:56:E6:1F"}]	{bb726feb-f20e-4bce-9ac8-4e28ef1178e3}	[{"id": "fd4fe127-ce12-4a87-9603-1d60f092fafe", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:27.335841842Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:01:27.335845+00	2025-11-26 16:01:41.970042+00	f
aeac70ad-45ba-4ee6-9836-d0c8b5533e3e	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "2e2ce6b4-e3d2-451a-a9e2-b7e91d3b248b", "name": null, "subnet_id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "ip_address": "172.25.0.3", "mac_address": "8A:CD:7B:ED:63:2A"}]	{584f1d9b-0b83-4adb-aa78-37c7403a9009}	[{"id": "46c982de-d7fd-46ff-9dd5-9c97e0d0caff", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:41.962819423Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:01:41.962822+00	2025-11-26 16:01:56.724961+00	f
b70e0411-641e-425c-a1b5-f9a4548586ed	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	172.25.0.4	ab424a053abe	NetVisor daemon	{"type": "None"}	[{"id": "df31dfb8-bc73-4542-b4b9-2fdfccb45d84", "name": "eth0", "subnet_id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "ip_address": "172.25.0.4", "mac_address": "FA:7A:1C:48:6D:DE"}]	{577502a7-cf79-4050-9a6a-f04f1566c824,853045de-6786-417b-9140-37052e6dc09a}	[{"id": "86c2d0f5-ffce-47ed-8271-3e73d993b7e4", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:27.267814859Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-26T16:01:25.046469311Z", "type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e"}]}	null	2025-11-26 16:01:24.981786+00	2025-11-26 16:01:27.280746+00	f
60b10615-f004-4867-b934-01c245365ce4	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "f7eef3e4-f994-48e7-8c3a-7e50fb5a152f", "name": null, "subnet_id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "ip_address": "172.25.0.6", "mac_address": "C6:FE:EF:96:39:E9"}]	{9e26e524-81ac-4dfe-b337-b1174648d17c}	[{"id": "1f344d38-d77b-4e53-967d-4384827e1023", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:56.823376542Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:01:56.823379+00	2025-11-26 16:02:11.593022+00	f
871be5d3-13a2-41d2-b389-0ffccd854f2b	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "89775dfc-0e9e-4689-bf07-7d680efaa447", "name": null, "subnet_id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "ip_address": "172.25.0.1", "mac_address": "E6:C6:91:4D:22:9B"}]	{e994d3da-bbc3-45b0-a03f-ef2eb7467ec9,266f6e0a-4e8f-4523-96ec-6eecb7ff734e}	[{"id": "fe8aa8c4-b4f2-4ab7-9edb-b3920cb929d8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "b4e8d4ec-f308-4a20-aaa9-242809af30d1", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "5f15dbdd-1f1e-4b10-a0b2-cad079015a88", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:02:17.635461042Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:02:17.635464+00	2025-11-26 16:02:32.040071+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	My Network	2025-11-26 16:01:24.945559+00	2025-11-26 16:01:24.945559+00	f	7996a122-7a09-45a2-a74b-f2c4afd89dd8
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
7996a122-7a09-45a2-a74b-f2c4afd89dd8	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-26 16:01:21.274137+00	2025-11-26 16:01:24.944367+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
38928849-40c5-43f4-85fe-7309a2c191ff	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:24.949111+00	2025-11-26 16:01:24.949111+00	Cloudflare DNS	60f11702-d6d2-4740-bec6-02aa76c655fe	[{"id": "eb166ebe-28f4-4e0a-8710-d284f5407db4", "type": "Port", "port_id": "9e828768-38f2-4314-995b-300eb66c0a6c", "interface_id": "4ae679fc-5d0f-4721-988a-3c46ef544b52"}]	"Dns Server"	null	{"type": "System"}
d3f92b79-1e91-4558-b64e-c89b9c3ed194	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:24.949117+00	2025-11-26 16:01:24.949117+00	Google.com	023c8b13-47c2-4c73-bbfd-69fd2f17b843	[{"id": "d0a7ec92-893b-448e-b24c-33417075c259", "type": "Port", "port_id": "fad42b72-ce0f-4d44-9a2f-009e1d11317f", "interface_id": "b7f62f73-a202-4da2-8053-ed6697fa3dce"}]	"Web Service"	null	{"type": "System"}
076093e5-3530-406c-b592-f287e1969a00	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:24.949123+00	2025-11-26 16:01:24.949123+00	Mobile Device	3e1ea7bc-1045-4099-8d31-305a207da7ae	[{"id": "b0bdc43f-7550-4aed-85c8-916f5ba7a61b", "type": "Port", "port_id": "54c5b26b-8723-4a09-8643-6263ace244fe", "interface_id": "3635dae8-ce5a-4f4e-98bb-f8ce7ac36ca0"}]	"Client"	null	{"type": "System"}
577502a7-cf79-4050-9a6a-f04f1566c824	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:25.046488+00	2025-11-26 16:01:27.279369+00	NetVisor Daemon API	b70e0411-641e-425c-a1b5-f9a4548586ed	[{"id": "d4f917e9-ec32-4ca0-a6f1-5cb4e3a2e21b", "type": "Port", "port_id": "86c2d0f5-ffce-47ed-8271-3e73d993b7e4", "interface_id": "df31dfb8-bc73-4542-b4b9-2fdfccb45d84"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-26T16:01:27.268505360Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-26T16:01:25.046487655Z", "type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e"}]}
bb726feb-f20e-4bce-9ac8-4e28ef1178e3	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:30.322801+00	2025-11-26 16:01:30.322801+00	Home Assistant	e21d31da-a027-424d-ab4e-a5870dace7fe	[{"id": "e9275fa9-d605-49ff-bfb3-21fd3736e443", "type": "Port", "port_id": "fd4fe127-ce12-4a87-9603-1d60f092fafe", "interface_id": "77347aa0-472e-4dc5-bc2d-cf7860d5afdf"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:01:30.322792544Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
584f1d9b-0b83-4adb-aa78-37c7403a9009	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:44.929083+00	2025-11-26 16:01:44.929083+00	NetVisor Server API	aeac70ad-45ba-4ee6-9836-d0c8b5533e3e	[{"id": "717e0d96-1b76-4485-97df-dae0e98279c0", "type": "Port", "port_id": "46c982de-d7fd-46ff-9dd5-9c97e0d0caff", "interface_id": "2e2ce6b4-e3d2-451a-a9e2-b7e91d3b248b"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:01:44.929074583Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
9e26e524-81ac-4dfe-b337-b1174648d17c	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:02:11.481323+00	2025-11-26 16:02:11.481323+00	PostgreSQL	60b10615-f004-4867-b934-01c245365ce4	[{"id": "13105523-d45b-4075-bf78-a1389fc47ef1", "type": "Port", "port_id": "1f344d38-d77b-4e53-967d-4384827e1023", "interface_id": "f7eef3e4-f994-48e7-8c3a-7e50fb5a152f"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-26T16:02:11.481315552Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
e994d3da-bbc3-45b0-a03f-ef2eb7467ec9	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:02:20.563221+00	2025-11-26 16:02:20.563221+00	Home Assistant	871be5d3-13a2-41d2-b389-0ffccd854f2b	[{"id": "8a4d53cb-062a-4cb8-8f33-ce346422f1ab", "type": "Port", "port_id": "fe8aa8c4-b4f2-4ab7-9edb-b3920cb929d8", "interface_id": "89775dfc-0e9e-4689-bf07-7d680efaa447"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:02:20.563211342Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
266f6e0a-4e8f-4523-96ec-6eecb7ff734e	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:02:20.564402+00	2025-11-26 16:02:20.564402+00	NetVisor Server API	871be5d3-13a2-41d2-b389-0ffccd854f2b	[{"id": "6ecda44c-8271-4ea7-ac42-20e4ec7a4c8d", "type": "Port", "port_id": "b4e8d4ec-f308-4a20-aaa9-242809af30d1", "interface_id": "89775dfc-0e9e-4689-bf07-7d680efaa447"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:02:20.564395142Z", "type": "Network", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
0df07dcc-6d3f-42db-87ae-be8bfff1dd63	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:24.949042+00	2025-11-26 16:01:24.949042+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
f19bdbb9-a3e4-4097-b480-ab87ab4ecc39	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:24.949046+00	2025-11-26 16:01:24.949046+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
6cc922e0-33d0-498c-b9ec-c6e8b1485558	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	2025-11-26 16:01:25.033327+00	2025-11-26 16:01:25.033327+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:25.033325488Z", "type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
db4b4c8c-b743-427b-9ab0-e6a6d33f0c00	421cbc3e-153d-48d8-a3f0-060fc0b3ebd5	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "0df07dcc-6d3f-42db-87ae-be8bfff1dd63", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-26T16:01:24.949042Z", "network_id": "421cbc3e-153d-48d8-a3f0-060fc0b3ebd5", "updated_at": "2025-11-26T16:01:24.949042Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "f19bdbb9-a3e4-4097-b480-ab87ab4ecc39", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-26T16:01:24.949046Z", "network_id": "421cbc3e-153d-48d8-a3f0-060fc0b3ebd5", "updated_at": "2025-11-26T16:01:24.949046Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "6cc922e0-33d0-498c-b9ec-c6e8b1485558", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-26T16:01:25.033325488Z", "type": "SelfReport", "host_id": "b70e0411-641e-425c-a1b5-f9a4548586ed", "daemon_id": "96b6f0ac-7d76-499a-8ec8-2acdec49133e"}]}, "created_at": "2025-11-26T16:01:25.033327Z", "network_id": "421cbc3e-153d-48d8-a3f0-060fc0b3ebd5", "updated_at": "2025-11-26T16:01:25.033327Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-26 16:01:24.946656+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-26 16:01:24.946657+00	2025-11-26 16:02:32.082798+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
a2e75490-6732-444b-8d37-5df19aac4715	2025-11-26 16:01:21.276064+00	2025-11-26 16:01:24.932004+00	$argon2id$v=19$m=19456,t=2,p=1$5MIm3IptncLGu5L4HFcKqg$IYN5GhEbExuMquhuer8RqerkZaZxx0HCnAppNwtzg1k	\N	\N	\N	user@example.com	7996a122-7a09-45a2-a74b-f2c4afd89dd8	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
n2gDHiGZIXT5XDTZ9eV9IQ	\\x93c410217de5f5d9345cf9742199211e03689f81a7757365725f6964d92461326537353439302d363733322d343434622d386433372d35646631396161633437313599cd07e9cd0168100118ce37a5de52000000	2025-12-26 16:01:24.933617+00
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

\unrestrict ilnpc7s4L4PuZDxtmxLn47LEFt0SgdzIrNGX9UZqmPS44iCENycvLaQfmIQUqCe

