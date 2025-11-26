--
-- PostgreSQL database dump
--

\restrict 28Qm3hKGoxipO52N82I0Wyr9Noj82XKDUld1kv1bsXpftKQKhbzD0Y55mEeKJ1N

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
20251006215000	users	2025-11-26 16:46:15.553497+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2633047
20251006215100	networks	2025-11-26 16:46:15.556879+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2839833
20251006215151	create hosts	2025-11-26 16:46:15.560031+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3301105
20251006215155	create subnets	2025-11-26 16:46:15.563634+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3428276
20251006215201	create groups	2025-11-26 16:46:15.567422+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2994788
20251006215204	create daemons	2025-11-26 16:46:15.570739+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3118695
20251006215212	create services	2025-11-26 16:46:15.574225+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3669117
20251029193448	user-auth	2025-11-26 16:46:15.578241+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	2858963
20251030044828	daemon api	2025-11-26 16:46:15.584148+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1344416
20251030170438	host-hide	2025-11-26 16:46:15.585731+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	908267
20251102224919	create discovery	2025-11-26 16:46:15.586868+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	7609129
20251106235621	normalize-daemon-cols	2025-11-26 16:46:15.594789+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1841075
20251107034459	api keys	2025-11-26 16:46:15.596938+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	5571541
20251107222650	oidc-auth	2025-11-26 16:46:15.602872+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	17382009
20251110181948	orgs-billing	2025-11-26 16:46:15.620914+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	8471042
20251113223656	group-enhancements	2025-11-26 16:46:15.629369+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	816618
20251117032720	daemon-mode	2025-11-26 16:46:15.630407+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	824999
20251118143058	set-default-plan	2025-11-26 16:46:15.631455+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	924731
20251118225043	save-topology	2025-11-26 16:46:15.632736+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	6549601
20251123232748	network-permissions	2025-11-26 16:46:15.639467+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2196061
20251125001342	billing-updates	2025-11-26 16:46:15.641894+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	766062
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
8632593e-1aac-4b41-9ff9-2767874f2bab	479c5f6c6bc2463bbd75b5e6c9e96e36	d4b7da07-885f-40ad-9c23-2d5c9fd137df	Integrated Daemon API Key	2025-11-26 16:46:18.823968+00	2025-11-26 16:47:13.010554+00	2025-11-26 16:47:13.009771+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
8f6124e8-634b-4f9d-9bb2-043ffa358b97	d4b7da07-885f-40ad-9c23-2d5c9fd137df	86c9df57-ffa9-4395-af52-7aac9f49ce54	"172.25.0.4"	60073	2025-11-26 16:46:18.867574+00	2025-11-26 16:46:18.867572+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["bcf3af42-f028-4649-86c8-48fd6f6b7718"]}	2025-11-26 16:46:18.885439+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
ff0b7f00-a476-45c8-9598-c3d6f624797c	d4b7da07-885f-40ad-9c23-2d5c9fd137df	8f6124e8-634b-4f9d-9bb2-043ffa358b97	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54"}	Self Report @ 172.25.0.4	2025-11-26 16:46:18.868824+00	2025-11-26 16:46:18.868824+00
9939277b-d1e5-45e9-b95b-20410b49e1b8	d4b7da07-885f-40ad-9c23-2d5c9fd137df	8f6124e8-634b-4f9d-9bb2-043ffa358b97	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-26 16:46:18.875669+00	2025-11-26 16:46:18.875669+00
926eb924-d42b-4ced-9631-a5a73fbca43a	d4b7da07-885f-40ad-9c23-2d5c9fd137df	8f6124e8-634b-4f9d-9bb2-043ffa358b97	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "processed": 1, "network_id": "d4b7da07-885f-40ad-9c23-2d5c9fd137df", "session_id": "bad699b1-643e-40f2-9aa9-6cae7a309b2f", "started_at": "2025-11-26T16:46:18.875135300Z", "finished_at": "2025-11-26T16:46:18.932097010Z", "discovery_type": {"type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54"}	Discovery Run	2025-11-26 16:46:18.875135+00	2025-11-26 16:46:18.934307+00
a8885516-ff8e-499b-9527-f250dd9ffffe	d4b7da07-885f-40ad-9c23-2d5c9fd137df	8f6124e8-634b-4f9d-9bb2-043ffa358b97	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "processed": 12, "network_id": "d4b7da07-885f-40ad-9c23-2d5c9fd137df", "session_id": "24ad6387-ff73-419f-8bc0-c07208aaf0fa", "started_at": "2025-11-26T16:46:18.944220121Z", "finished_at": "2025-11-26T16:47:13.008787414Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-26 16:46:18.94422+00	2025-11-26 16:47:13.010062+00
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
d89dfa9c-cc69-468e-ba86-c3b23e1ac639	d4b7da07-885f-40ad-9c23-2d5c9fd137df	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "c4c1784d-9aa5-4380-9c0c-ad3c24b58431"}	[{"id": "19870b5b-2829-4cc6-bf39-ef1ed3db7b79", "name": "Internet", "subnet_id": "a69838b4-2fce-40d6-aa1e-f224b1e4530d", "ip_address": "1.1.1.1", "mac_address": null}]	{e79ccf74-59a1-49b4-bcd4-e27312aea150}	[{"id": "f974dc9c-db20-41b1-9a28-2bc596d6ff46", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-26 16:46:18.806465+00	2025-11-26 16:46:18.81454+00	f
0c24f1e9-8109-4a6b-b515-045f31a6da00	d4b7da07-885f-40ad-9c23-2d5c9fd137df	Google.com	\N	\N	{"type": "ServiceBinding", "config": "b99af0e1-6358-48c4-8f76-ed9be1f7c95a"}	[{"id": "8515d8f1-108c-40f9-a0b8-88da765d6558", "name": "Internet", "subnet_id": "a69838b4-2fce-40d6-aa1e-f224b1e4530d", "ip_address": "203.0.113.110", "mac_address": null}]	{af4411ab-edcf-4f21-8bd8-35c6ac406e22}	[{"id": "4915ca25-c7ea-489b-a29f-bc4f7d717076", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 16:46:18.806471+00	2025-11-26 16:46:18.819349+00	f
e1837364-fbff-421d-970a-cef15431ba8f	d4b7da07-885f-40ad-9c23-2d5c9fd137df	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "7cc6e66e-1cec-4d9a-bdf6-61739a61b2b4"}	[{"id": "d2b50520-57bf-4301-b65e-c6feefdff0c8", "name": "Remote Network", "subnet_id": "5e0c91b0-7af2-450c-801e-80a13477ad9a", "ip_address": "203.0.113.183", "mac_address": null}]	{7a7e2d41-c2d7-49de-99db-0a29c223b97b}	[{"id": "8c27e4bf-5b82-4165-8afb-b9cc46130d80", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 16:46:18.806475+00	2025-11-26 16:46:18.823211+00	f
86c9df57-ffa9-4395-af52-7aac9f49ce54	d4b7da07-885f-40ad-9c23-2d5c9fd137df	172.25.0.4	816712a33df6	NetVisor daemon	{"type": "None"}	[{"id": "524e2a89-4f41-4f40-8236-796ef5ca7d0f", "name": "eth0", "subnet_id": "bcf3af42-f028-4649-86c8-48fd6f6b7718", "ip_address": "172.25.0.4", "mac_address": "EE:51:7B:04:CC:5C"}]	{3dfcb8b5-744f-4b58-928a-c84c0090677e,5eda3480-0b67-4116-bc52-c54a545e1739}	[{"id": "079ef927-8196-479c-988b-31674fbb06b2", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:36.405689800Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-26T16:46:18.921639109Z", "type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97"}]}	null	2025-11-26 16:46:18.830664+00	2025-11-26 16:46:36.419584+00	f
02c7ee48-1964-42ac-81d2-457658725ff6	d4b7da07-885f-40ad-9c23-2d5c9fd137df	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "03cb54b6-d880-49d4-9f8a-f2e41d5f4d19", "name": null, "subnet_id": "bcf3af42-f028-4649-86c8-48fd6f6b7718", "ip_address": "172.25.0.6", "mac_address": "AE:15:53:00:EF:E4"}]	{34f9b9d3-ccf7-45cc-bd87-2623d4a8037a}	[{"id": "96c46a89-155b-4a40-83b2-69292fb78ee1", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:36.510969345Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:46:36.51097+00	2025-11-26 16:46:51.726667+00	f
fcd16265-eac7-4c2d-8544-467e50d7254f	d4b7da07-885f-40ad-9c23-2d5c9fd137df	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "cf11912e-ba4e-41c6-b107-d7e030ee33b4", "name": null, "subnet_id": "bcf3af42-f028-4649-86c8-48fd6f6b7718", "ip_address": "172.25.0.3", "mac_address": "5E:CF:73:F6:42:08"}]	{ea741f6f-4ee3-4210-bc05-af7a29dbf359}	[{"id": "732189e3-f539-469e-886b-3f4aa5a98a82", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:21.145698044Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:46:21.1457+00	2025-11-26 16:46:36.414671+00	f
d54d0c47-6307-4d58-88ed-64a50497b50a	d4b7da07-885f-40ad-9c23-2d5c9fd137df	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "2cfac93e-474a-458f-b79e-759597e70fea", "name": null, "subnet_id": "bcf3af42-f028-4649-86c8-48fd6f6b7718", "ip_address": "172.25.0.1", "mac_address": "46:57:B1:A2:46:65"}]	{ebebe015-987d-4f37-a4e6-78aabd2bf31d,364843ad-6473-4fdb-98a4-146256bf27b2}	[{"id": "1dc22edf-ea3c-40b3-ab17-cdbf9f2dbe49", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "cd493944-82db-425c-96f0-a09d90ba37bc", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "b2f68882-0704-4cce-979f-6ab88ed3fc3f", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:57.867122782Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 16:46:57.867125+00	2025-11-26 16:47:13.006414+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
d4b7da07-885f-40ad-9c23-2d5c9fd137df	My Network	2025-11-26 16:46:18.803284+00	2025-11-26 16:46:18.803284+00	f	805b5a22-d930-4d13-ac50-dd56e0affed5
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
805b5a22-d930-4d13-ac50-dd56e0affed5	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-26 16:46:15.688693+00	2025-11-26 16:46:18.80206+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
e79ccf74-59a1-49b4-bcd4-e27312aea150	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.806467+00	2025-11-26 16:46:18.806467+00	Cloudflare DNS	d89dfa9c-cc69-468e-ba86-c3b23e1ac639	[{"id": "c4c1784d-9aa5-4380-9c0c-ad3c24b58431", "type": "Port", "port_id": "f974dc9c-db20-41b1-9a28-2bc596d6ff46", "interface_id": "19870b5b-2829-4cc6-bf39-ef1ed3db7b79"}]	"Dns Server"	null	{"type": "System"}
af4411ab-edcf-4f21-8bd8-35c6ac406e22	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.806472+00	2025-11-26 16:46:18.806472+00	Google.com	0c24f1e9-8109-4a6b-b515-045f31a6da00	[{"id": "b99af0e1-6358-48c4-8f76-ed9be1f7c95a", "type": "Port", "port_id": "4915ca25-c7ea-489b-a29f-bc4f7d717076", "interface_id": "8515d8f1-108c-40f9-a0b8-88da765d6558"}]	"Web Service"	null	{"type": "System"}
7a7e2d41-c2d7-49de-99db-0a29c223b97b	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.806476+00	2025-11-26 16:46:18.806476+00	Mobile Device	e1837364-fbff-421d-970a-cef15431ba8f	[{"id": "7cc6e66e-1cec-4d9a-bdf6-61739a61b2b4", "type": "Port", "port_id": "8c27e4bf-5b82-4165-8afb-b9cc46130d80", "interface_id": "d2b50520-57bf-4301-b65e-c6feefdff0c8"}]	"Client"	null	{"type": "System"}
ea741f6f-4ee3-4210-bc05-af7a29dbf359	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:24.23941+00	2025-11-26 16:46:24.23941+00	NetVisor Server API	fcd16265-eac7-4c2d-8544-467e50d7254f	[{"id": "6a09e5e0-6ae5-48ab-ae6d-ba85ef8bc2fa", "type": "Port", "port_id": "732189e3-f539-469e-886b-3f4aa5a98a82", "interface_id": "cf11912e-ba4e-41c6-b107-d7e030ee33b4"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:46:24.239401409Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
3dfcb8b5-744f-4b58-928a-c84c0090677e	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.921656+00	2025-11-26 16:46:36.418436+00	NetVisor Daemon API	86c9df57-ffa9-4395-af52-7aac9f49ce54	[{"id": "ca73776b-cc73-4669-954f-52c912d3a1ce", "type": "Port", "port_id": "079ef927-8196-479c-988b-31674fbb06b2", "interface_id": "524e2a89-4f41-4f40-8236-796ef5ca7d0f"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-26T16:46:36.406350023Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-26T16:46:18.921655563Z", "type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97"}]}
34f9b9d3-ccf7-45cc-bd87-2623d4a8037a	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:51.71777+00	2025-11-26 16:46:51.71777+00	PostgreSQL	02c7ee48-1964-42ac-81d2-457658725ff6	[{"id": "ded3ff4a-ad96-498c-b5ac-6146f2a99973", "type": "Port", "port_id": "96c46a89-155b-4a40-83b2-69292fb78ee1", "interface_id": "03cb54b6-d880-49d4-9f8a-f2e41d5f4d19"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-26T16:46:51.717762326Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ebebe015-987d-4f37-a4e6-78aabd2bf31d	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:47:00.921447+00	2025-11-26 16:47:00.921447+00	Home Assistant	d54d0c47-6307-4d58-88ed-64a50497b50a	[{"id": "9541deba-fc78-405d-a023-f45684403fd0", "type": "Port", "port_id": "1dc22edf-ea3c-40b3-ab17-cdbf9f2dbe49", "interface_id": "2cfac93e-474a-458f-b79e-759597e70fea"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:47:00.921437097Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
364843ad-6473-4fdb-98a4-146256bf27b2	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:47:00.922481+00	2025-11-26 16:47:00.922481+00	NetVisor Server API	d54d0c47-6307-4d58-88ed-64a50497b50a	[{"id": "0cabc1d2-eb80-4f1f-93d3-5de8a7e24b5c", "type": "Port", "port_id": "cd493944-82db-425c-96f0-a09d90ba37bc", "interface_id": "2cfac93e-474a-458f-b79e-759597e70fea"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T16:47:00.922477271Z", "type": "Network", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
a69838b4-2fce-40d6-aa1e-f224b1e4530d	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.806415+00	2025-11-26 16:46:18.806415+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
5e0c91b0-7af2-450c-801e-80a13477ad9a	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.806418+00	2025-11-26 16:46:18.806418+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
bcf3af42-f028-4649-86c8-48fd6f6b7718	d4b7da07-885f-40ad-9c23-2d5c9fd137df	2025-11-26 16:46:18.875282+00	2025-11-26 16:46:18.875282+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:18.875280737Z", "type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
e170e39e-1c60-4aea-bcf1-a79cb35f7dd1	d4b7da07-885f-40ad-9c23-2d5c9fd137df	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "a69838b4-2fce-40d6-aa1e-f224b1e4530d", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-26T16:46:18.806415Z", "network_id": "d4b7da07-885f-40ad-9c23-2d5c9fd137df", "updated_at": "2025-11-26T16:46:18.806415Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "5e0c91b0-7af2-450c-801e-80a13477ad9a", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-26T16:46:18.806418Z", "network_id": "d4b7da07-885f-40ad-9c23-2d5c9fd137df", "updated_at": "2025-11-26T16:46:18.806418Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "bcf3af42-f028-4649-86c8-48fd6f6b7718", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-26T16:46:18.875280737Z", "type": "SelfReport", "host_id": "86c9df57-ffa9-4395-af52-7aac9f49ce54", "daemon_id": "8f6124e8-634b-4f9d-9bb2-043ffa358b97"}]}, "created_at": "2025-11-26T16:46:18.875282Z", "network_id": "d4b7da07-885f-40ad-9c23-2d5c9fd137df", "updated_at": "2025-11-26T16:46:18.875282Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-26 16:46:18.804474+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-26 16:46:18.804475+00	2025-11-26 16:46:51.894234+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
0ac7f584-7489-4d57-aa96-13cc7f0c196a	2025-11-26 16:46:15.690624+00	2025-11-26 16:46:18.790649+00	$argon2id$v=19$m=19456,t=2,p=1$rsA2GxYF2wFP8k5MhWEgfg$/nA56unuo/srdiIJerYVPG2poMuOpdI09X5hNiDCgV4	\N	\N	\N	user@example.com	805b5a22-d930-4d13-ac50-dd56e0affed5	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
RlVleoqMKOV36OBGgKzKfw	\\x93c4107fcaac8046e0e877e5288c8a7a65554681a7757365725f6964d92430616337663538342d373438392d346435372d616139362d31336363376630633139366199cd07e9cd0168102e12ce2f357924000000	2025-12-26 16:46:18.792033+00
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

\unrestrict 28Qm3hKGoxipO52N82I0Wyr9Noj82XKDUld1kv1bsXpftKQKhbzD0Y55mEeKJ1N

