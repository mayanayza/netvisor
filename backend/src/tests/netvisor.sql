--
-- PostgreSQL database dump
--

\restrict iT1L5Xfu7uX8R7DBaYH8wyZJM8XMSgKaqFOpXGfCFJRoXlLxXBHbY4EydMBB7jt

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
    permissions text DEFAULT 'Member'::text NOT NULL
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
20251006215000	users	2025-11-22 05:43:48.457668+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4725095
20251006215100	networks	2025-11-22 05:43:48.463753+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4870373
20251006215151	create hosts	2025-11-22 05:43:48.468989+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4550465
20251006215155	create subnets	2025-11-22 05:43:48.47397+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4713851
20251006215201	create groups	2025-11-22 05:43:48.479135+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	6298983
20251006215204	create daemons	2025-11-22 05:43:48.485844+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4807546
20251006215212	create services	2025-11-22 05:43:48.491035+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5889097
20251029193448	user-auth	2025-11-22 05:43:48.497286+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	7823826
20251030044828	daemon api	2025-11-22 05:43:48.505447+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1668178
20251030170438	host-hide	2025-11-22 05:43:48.507434+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1203209
20251102224919	create discovery	2025-11-22 05:43:48.509024+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	11800605
20251106235621	normalize-daemon-cols	2025-11-22 05:43:48.521173+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1865677
20251107034459	api keys	2025-11-22 05:43:48.523447+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8372329
20251107222650	oidc-auth	2025-11-22 05:43:48.532248+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	28884420
20251110181948	orgs-billing	2025-11-22 05:43:48.561771+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11642928
20251113223656	group-enhancements	2025-11-22 05:43:48.573825+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1138748
20251117032720	daemon-mode	2025-11-22 05:43:48.575551+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1219840
20251118143058	set-default-plan	2025-11-22 05:43:48.577211+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1264734
20251118225043	save-topology	2025-11-22 05:43:48.578761+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9338796
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
a5f847c2-c702-4407-87ef-b6518527fffe	ca1f36a8fe5c4958b608375891f41661	169c1636-c0f2-4883-950c-6d3a40053110	Integrated Daemon API Key	2025-11-22 05:43:51.674319+00	2025-11-22 05:44:45.056692+00	2025-11-22 05:44:45.055948+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
1dd07be9-cbe2-446c-877d-6df902e372fb	169c1636-c0f2-4883-950c-6d3a40053110	d69fac63-ee47-40a2-a09a-773d45109cc4	"172.25.0.4"	60073	2025-11-22 05:43:51.726152+00	2025-11-22 05:43:51.726151+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["a54ff32d-28fe-49c8-b699-225be914a185"]}	2025-11-22 05:43:51.770662+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
10f87675-c882-4b8d-b8eb-8f2f3ed03351	169c1636-c0f2-4883-950c-6d3a40053110	1dd07be9-cbe2-446c-877d-6df902e372fb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4"}	Self Report @ 172.25.0.4	2025-11-22 05:43:51.727754+00	2025-11-22 05:43:51.727754+00
8df26956-2c78-4300-9638-e5fded47dcde	169c1636-c0f2-4883-950c-6d3a40053110	1dd07be9-cbe2-446c-877d-6df902e372fb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-22 05:43:51.73562+00	2025-11-22 05:43:51.73562+00
773ad504-5482-43f5-8b52-e30b303f0bbd	169c1636-c0f2-4883-950c-6d3a40053110	1dd07be9-cbe2-446c-877d-6df902e372fb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "processed": 1, "network_id": "169c1636-c0f2-4883-950c-6d3a40053110", "session_id": "9cfbdcf5-cb3d-48a5-8dbb-d639953c06d2", "started_at": "2025-11-22T05:43:51.735152452Z", "finished_at": "2025-11-22T05:43:51.784747423Z", "discovery_type": {"type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4"}	Discovery Run	2025-11-22 05:43:51.735152+00	2025-11-22 05:43:51.786976+00
8f1b33fa-d696-4b1a-a02e-28a604b2542d	169c1636-c0f2-4883-950c-6d3a40053110	1dd07be9-cbe2-446c-877d-6df902e372fb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "processed": 13, "network_id": "169c1636-c0f2-4883-950c-6d3a40053110", "session_id": "53554442-a32e-4750-9f1c-289fbb9a8d9d", "started_at": "2025-11-22T05:43:51.795758416Z", "finished_at": "2025-11-22T05:44:45.055039140Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-22 05:43:51.795758+00	2025-11-22 05:44:45.056201+00
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
cc22b055-17cc-4b32-b485-0297aefbe854	169c1636-c0f2-4883-950c-6d3a40053110	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "637ed9c5-6538-4b29-8c02-17c20c6c4eea"}	[{"id": "9cbf8a2a-3789-4af3-896b-3796556ad10f", "name": "Internet", "subnet_id": "eab7b1b7-69ac-41c3-bf72-2a3dfcd899a5", "ip_address": "1.1.1.1", "mac_address": null}]	{9819289a-fb18-4d18-bd8a-14f5e5c41223}	[{"id": "8884a744-70f2-49a1-bf64-f82a5144469e", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-22 05:43:51.654082+00	2025-11-22 05:43:51.66396+00	f
fb413bb0-3f0b-4995-8021-fb71331c650d	169c1636-c0f2-4883-950c-6d3a40053110	Google.com	\N	\N	{"type": "ServiceBinding", "config": "84a39a44-f283-47a0-b197-14bc9c4e0b21"}	[{"id": "abf254c9-2111-4718-b14a-1ff5060d518c", "name": "Internet", "subnet_id": "eab7b1b7-69ac-41c3-bf72-2a3dfcd899a5", "ip_address": "203.0.113.66", "mac_address": null}]	{a15873fd-ab98-4f5f-8714-741b74d8edf1}	[{"id": "dbc87c22-f23f-43ce-a43a-db8acd111c68", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-22 05:43:51.654089+00	2025-11-22 05:43:51.669393+00	f
80578e78-ccd8-460a-a681-71e9fdfbd729	169c1636-c0f2-4883-950c-6d3a40053110	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "61700bf0-a593-4d73-90f8-ef795c9f9b0b"}	[{"id": "aa9e7988-50b4-445a-85b8-4ebb21e912d8", "name": "Remote Network", "subnet_id": "7fd63fdb-9b7e-4711-9fa7-7acfbcc1453f", "ip_address": "203.0.113.20", "mac_address": null}]	{41cc388e-6eac-45b5-a492-360fcca36c53}	[{"id": "12388c3a-670f-4385-ab63-6e2d6c48d968", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-22 05:43:51.654094+00	2025-11-22 05:43:51.67345+00	f
d38f346e-d180-423e-aa51-08d1ecf79c6c	169c1636-c0f2-4883-950c-6d3a40053110	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "459ef547-3027-4b2c-9fd0-4bf5aba88ec2", "name": null, "subnet_id": "a54ff32d-28fe-49c8-b699-225be914a185", "ip_address": "172.25.0.6", "mac_address": "1E:99:71:B6:32:8E"}]	{9684901c-4ccf-4ea8-9617-59e6ceccba40}	[{"id": "67c96777-50f7-4444-9e9b-e2a399d0bc51", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-22T05:44:09.072864461Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-22 05:44:09.072867+00	2025-11-22 05:44:24.066996+00	f
d69fac63-ee47-40a2-a09a-773d45109cc4	169c1636-c0f2-4883-950c-6d3a40053110	172.25.0.4	9c153bc0e8ec	NetVisor daemon	{"type": "None"}	[{"id": "4acc6696-ac08-46d4-81e8-d8e57df434f1", "name": "eth0", "subnet_id": "a54ff32d-28fe-49c8-b699-225be914a185", "ip_address": "172.25.0.4", "mac_address": "E6:6B:9A:05:11:B8"}]	{9a18439a-8621-4039-ad8a-4795e29ee17f}	[{"id": "60af8fbd-f774-4aba-ac11-52ec112c1fa8", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-22T05:43:51.772709379Z", "type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb"}]}	null	2025-11-22 05:43:51.681919+00	2025-11-22 05:43:51.782439+00	f
581da0e8-37c8-41a8-8e18-065fe49d4e5c	169c1636-c0f2-4883-950c-6d3a40053110	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "d0928414-0bfe-42b7-9986-8739466663a6", "name": null, "subnet_id": "a54ff32d-28fe-49c8-b699-225be914a185", "ip_address": "172.25.0.3", "mac_address": "A2:F2:C9:5A:E2:5A"}]	{38c64825-56d2-4de4-a88b-4c0e9f0afb6a}	[{"id": "25675680-50a4-4671-9527-0465f3ec0a5a", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-22T05:43:54.028085368Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-22 05:43:54.028088+00	2025-11-22 05:44:08.96515+00	f
71a8ccad-cec6-4772-87ec-ed2a3c4a696c	169c1636-c0f2-4883-950c-6d3a40053110	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "3b8d6a32-3795-4966-b370-d5142fe1d905", "name": null, "subnet_id": "a54ff32d-28fe-49c8-b699-225be914a185", "ip_address": "172.25.0.1", "mac_address": "02:61:5D:F5:91:4C"}]	{afbd2a53-af6c-43ec-be62-1d0dba17baad,3149002a-62d1-4990-81f3-db22dc820d8a}	[{"id": "3b0c68d3-e04e-43bb-8769-7aac77cfbfc4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "796485cb-db71-40ec-972d-3de1fd1383a9", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "8409d0b4-4a4e-4247-90b9-2183a9cebebc", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-22T05:44:30.205810658Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-22 05:44:30.205813+00	2025-11-22 05:44:45.0524+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
169c1636-c0f2-4883-950c-6d3a40053110	My Network	2025-11-22 05:43:51.650161+00	2025-11-22 05:43:51.650161+00	f	8148c683-bf5c-49be-83f3-63511dfa27aa
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
8148c683-bf5c-49be-83f3-63511dfa27aa	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	\N	2025-11-22 05:43:48.645519+00	2025-11-22 05:43:51.648848+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
9819289a-fb18-4d18-bd8a-14f5e5c41223	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.654084+00	2025-11-22 05:43:51.654084+00	Cloudflare DNS	cc22b055-17cc-4b32-b485-0297aefbe854	[{"id": "637ed9c5-6538-4b29-8c02-17c20c6c4eea", "type": "Port", "port_id": "8884a744-70f2-49a1-bf64-f82a5144469e", "interface_id": "9cbf8a2a-3789-4af3-896b-3796556ad10f"}]	"Dns Server"	null	{"type": "System"}
a15873fd-ab98-4f5f-8714-741b74d8edf1	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.65409+00	2025-11-22 05:43:51.65409+00	Google.com	fb413bb0-3f0b-4995-8021-fb71331c650d	[{"id": "84a39a44-f283-47a0-b197-14bc9c4e0b21", "type": "Port", "port_id": "dbc87c22-f23f-43ce-a43a-db8acd111c68", "interface_id": "abf254c9-2111-4718-b14a-1ff5060d518c"}]	"Web Service"	null	{"type": "System"}
41cc388e-6eac-45b5-a492-360fcca36c53	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.654095+00	2025-11-22 05:43:51.654095+00	Mobile Device	80578e78-ccd8-460a-a681-71e9fdfbd729	[{"id": "61700bf0-a593-4d73-90f8-ef795c9f9b0b", "type": "Port", "port_id": "12388c3a-670f-4385-ab63-6e2d6c48d968", "interface_id": "aa9e7988-50b4-445a-85b8-4ebb21e912d8"}]	"Client"	null	{"type": "System"}
9a18439a-8621-4039-ad8a-4795e29ee17f	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.772735+00	2025-11-22 05:43:51.772735+00	NetVisor Daemon API	d69fac63-ee47-40a2-a09a-773d45109cc4	[{"id": "151fb392-edd0-4c0b-9a00-a25e9f92d6bc", "type": "Port", "port_id": "60af8fbd-f774-4aba-ac11-52ec112c1fa8", "interface_id": "4acc6696-ac08-46d4-81e8-d8e57df434f1"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-22T05:43:51.772734477Z", "type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb"}]}
38c64825-56d2-4de4-a88b-4c0e9f0afb6a	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:44:08.945444+00	2025-11-22 05:44:08.945444+00	NetVisor Server API	581da0e8-37c8-41a8-8e18-065fe49d4e5c	[{"id": "562962ec-dc4e-47f6-9ba7-8b84f14190dc", "type": "Port", "port_id": "25675680-50a4-4671-9527-0465f3ec0a5a", "interface_id": "d0928414-0bfe-42b7-9986-8739466663a6"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-22T05:44:08.945437540Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
9684901c-4ccf-4ea8-9617-59e6ceccba40	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:44:24.056871+00	2025-11-22 05:44:24.056871+00	PostgreSQL	d38f346e-d180-423e-aa51-08d1ecf79c6c	[{"id": "1aa0f9f8-f0b7-40c6-84d4-e6580e9ec166", "type": "Port", "port_id": "67c96777-50f7-4444-9e9b-e2a399d0bc51", "interface_id": "459ef547-3027-4b2c-9fd0-4bf5aba88ec2"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-22T05:44:24.056862405Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
afbd2a53-af6c-43ec-be62-1d0dba17baad	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:44:33.206717+00	2025-11-22 05:44:33.206717+00	Home Assistant	71a8ccad-cec6-4772-87ec-ed2a3c4a696c	[{"id": "a9832b55-53b1-4b11-90b8-698370a00a39", "type": "Port", "port_id": "3b0c68d3-e04e-43bb-8769-7aac77cfbfc4", "interface_id": "3b8d6a32-3795-4966-b370-d5142fe1d905"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-22T05:44:33.206707395Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
3149002a-62d1-4990-81f3-db22dc820d8a	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:44:45.043523+00	2025-11-22 05:44:45.043523+00	NetVisor Server API	71a8ccad-cec6-4772-87ec-ed2a3c4a696c	[{"id": "0e159ad3-d0ba-453a-b6f5-c7d2ab1b7f06", "type": "Port", "port_id": "796485cb-db71-40ec-972d-3de1fd1383a9", "interface_id": "3b8d6a32-3795-4966-b370-d5142fe1d905"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-22T05:44:45.043513742Z", "type": "Network", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
eab7b1b7-69ac-41c3-bf72-2a3dfcd899a5	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.654028+00	2025-11-22 05:43:51.654028+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
7fd63fdb-9b7e-4711-9fa7-7acfbcc1453f	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.654032+00	2025-11-22 05:43:51.654032+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
a54ff32d-28fe-49c8-b699-225be914a185	169c1636-c0f2-4883-950c-6d3a40053110	2025-11-22 05:43:51.735331+00	2025-11-22 05:43:51.735331+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-22T05:43:51.735330925Z", "type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
37e49910-6ad8-4590-9989-5f19882aabd0	169c1636-c0f2-4883-950c-6d3a40053110	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "eab7b1b7-69ac-41c3-bf72-2a3dfcd899a5", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-22T05:43:51.654028Z", "network_id": "169c1636-c0f2-4883-950c-6d3a40053110", "updated_at": "2025-11-22T05:43:51.654028Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "7fd63fdb-9b7e-4711-9fa7-7acfbcc1453f", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-22T05:43:51.654032Z", "network_id": "169c1636-c0f2-4883-950c-6d3a40053110", "updated_at": "2025-11-22T05:43:51.654032Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "a54ff32d-28fe-49c8-b699-225be914a185", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-22T05:43:51.735330925Z", "type": "SelfReport", "host_id": "d69fac63-ee47-40a2-a09a-773d45109cc4", "daemon_id": "1dd07be9-cbe2-446c-877d-6df902e372fb"}]}, "created_at": "2025-11-22T05:43:51.735331Z", "network_id": "169c1636-c0f2-4883-950c-6d3a40053110", "updated_at": "2025-11-22T05:43:51.735331Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-22 05:43:51.651516+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-22 05:43:51.651517+00	2025-11-22 05:44:24.245248+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
c0dfd3a6-71a4-40be-9694-4bd8b12eeaf9	2025-11-22 05:43:48.647634+00	2025-11-22 05:43:51.636455+00	$argon2id$v=19$m=19456,t=2,p=1$ULnH/etDLj/4aaRNUn+fOg$Ajdiy/fFuyioHESksEL/8kw2qntnq7ZunASWZa/w+BE	\N	\N	\N	user@example.com	8148c683-bf5c-49be-83f3-63511dfa27aa	Owner
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
ZxIARZNWIDiyDqEB6JRfwg	\\x93c410c25f94e801a10eb2382056934500126781a7757365725f6964d92463306466643361362d373161342d343062652d393639342d34626438623132656561663999cd07e9cd0164052b33ce260943cb000000	2025-12-22 05:43:51.638141+00
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

\unrestrict iT1L5Xfu7uX8R7DBaYH8wyZJM8XMSgKaqFOpXGfCFJRoXlLxXBHbY4EydMBB7jt

