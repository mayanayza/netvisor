--
-- PostgreSQL database dump
--

\restrict P4aNdOclbXjXflyD8aWAfZQxzkKXg6BqOCpR212VxzxsPOgEyuJWc9gR53X9ak2

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
20251006215000	users	2025-11-26 04:57:28.15846+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3764408
20251006215100	networks	2025-11-26 04:57:28.163627+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	5017522
20251006215151	create hosts	2025-11-26 04:57:28.169057+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4051614
20251006215155	create subnets	2025-11-26 04:57:28.173486+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4214177
20251006215201	create groups	2025-11-26 04:57:28.178062+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4296430
20251006215204	create daemons	2025-11-26 04:57:28.182779+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4656702
20251006215212	create services	2025-11-26 04:57:28.187862+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5363370
20251029193448	user-auth	2025-11-26 04:57:28.193579+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4954858
20251030044828	daemon api	2025-11-26 04:57:28.198881+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1743300
20251030170438	host-hide	2025-11-26 04:57:28.200932+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1197473
20251102224919	create discovery	2025-11-26 04:57:28.202495+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9780415
20251106235621	normalize-daemon-cols	2025-11-26 04:57:28.212617+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1752677
20251107034459	api keys	2025-11-26 04:57:28.214733+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8546093
20251107222650	oidc-auth	2025-11-26 04:57:28.223631+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26588141
20251110181948	orgs-billing	2025-11-26 04:57:28.250611+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10479358
20251113223656	group-enhancements	2025-11-26 04:57:28.261559+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1190730
20251117032720	daemon-mode	2025-11-26 04:57:28.263002+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1143391
20251118143058	set-default-plan	2025-11-26 04:57:28.264481+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1350569
20251118225043	save-topology	2025-11-26 04:57:28.266302+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	11948770
20251123232748	network-permissions	2025-11-26 04:57:28.278646+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3058662
20251125001342	billing-updates	2025-11-26 04:57:28.282011+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	923582
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
50d9329c-448b-4543-b8d8-86108ceb360c	1f6e939a15a74cf987edf6e3acf3e91b	77968622-7cec-4106-8008-20f96c253cf4	Integrated Daemon API Key	2025-11-26 04:57:31.487831+00	2025-11-26 04:58:27.428697+00	2025-11-26 04:58:27.427873+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
d5f2bc6b-d747-4e8e-a599-c837e6af9d3a	77968622-7cec-4106-8008-20f96c253cf4	a1aa7881-a6b8-462c-b3b6-86e39dc296f8	"172.25.0.4"	60073	2025-11-26 04:57:31.575008+00	2025-11-26 04:57:31.575007+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["815d6c4c-bf9f-4296-a0f6-647ac7b40fcc"]}	2025-11-26 04:57:31.641091+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
30cf1d01-bed0-46d5-ace4-97a1bf698772	77968622-7cec-4106-8008-20f96c253cf4	d5f2bc6b-d747-4e8e-a599-c837e6af9d3a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8"}	Self Report @ 172.25.0.4	2025-11-26 04:57:31.577035+00	2025-11-26 04:57:31.577035+00
60cb3d7f-8b9f-4fe5-91da-8940f61dd2f5	77968622-7cec-4106-8008-20f96c253cf4	d5f2bc6b-d747-4e8e-a599-c837e6af9d3a	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-26 04:57:31.584242+00	2025-11-26 04:57:31.584242+00
c04937c9-e310-4206-854b-b37bdf3f448e	77968622-7cec-4106-8008-20f96c253cf4	d5f2bc6b-d747-4e8e-a599-c837e6af9d3a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "processed": 1, "network_id": "77968622-7cec-4106-8008-20f96c253cf4", "session_id": "94af8c0c-4b5c-4fd3-8dd7-33c8d9c7080e", "started_at": "2025-11-26T04:57:31.583587535Z", "finished_at": "2025-11-26T04:57:31.653124162Z", "discovery_type": {"type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8"}	Discovery Run	2025-11-26 04:57:31.583587+00	2025-11-26 04:57:31.654366+00
d3a1d156-2a1d-408c-935f-282c2aff88cf	77968622-7cec-4106-8008-20f96c253cf4	d5f2bc6b-d747-4e8e-a599-c837e6af9d3a	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "processed": 13, "network_id": "77968622-7cec-4106-8008-20f96c253cf4", "session_id": "25813d5e-ab0b-4e77-a907-f54403cf01a0", "started_at": "2025-11-26T04:57:31.665631634Z", "finished_at": "2025-11-26T04:58:27.426935859Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-26 04:57:31.665631+00	2025-11-26 04:58:27.428133+00
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
5bdec2d5-bf9f-464f-8c91-bd03d5a6b4bc	77968622-7cec-4106-8008-20f96c253cf4	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "1e77fcba-5a1b-4589-b844-433153c22100"}	[{"id": "ba417bf4-c1c3-471b-a85b-0eecb6849a69", "name": "Internet", "subnet_id": "c7b7d0b9-725e-405b-9dca-1a07253b6a3f", "ip_address": "1.1.1.1", "mac_address": null}]	{4f219965-0819-44c4-931b-ec6e23924819}	[{"id": "d227590d-cfb1-4f0d-be5b-17c553bd9231", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-26 04:57:31.467606+00	2025-11-26 04:57:31.477271+00	f
aa407d1b-1603-4be9-bfdc-9910ba205499	77968622-7cec-4106-8008-20f96c253cf4	Google.com	\N	\N	{"type": "ServiceBinding", "config": "3e81de40-22a6-493b-872c-cc872be3a665"}	[{"id": "5b2c0ab0-ff9b-42ae-8b79-cf6a7b4a8eba", "name": "Internet", "subnet_id": "c7b7d0b9-725e-405b-9dca-1a07253b6a3f", "ip_address": "203.0.113.135", "mac_address": null}]	{2d475497-10ac-4ccd-b399-96dcabdd5d2f}	[{"id": "5ab7ba11-181f-4dcb-9af8-6aa73636a207", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 04:57:31.467617+00	2025-11-26 04:57:31.482767+00	f
b9706070-4e57-45ec-8e6f-3cbf9f90cef2	77968622-7cec-4106-8008-20f96c253cf4	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "20c430af-50f0-4ab7-a9bc-502826fa4915"}	[{"id": "18430697-1ec2-4801-a04d-45d606fb56b4", "name": "Remote Network", "subnet_id": "8b4f02d1-250a-4643-9e59-17cd1fd6a762", "ip_address": "203.0.113.118", "mac_address": null}]	{a1afebc2-30da-430e-afb2-fdda2cfe2e68}	[{"id": "27e7e4b2-6bd5-46a6-a7d8-07a61604b945", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 04:57:31.467623+00	2025-11-26 04:57:31.487001+00	f
2899fa39-0c16-4933-97cf-65fb12ddd9c3	77968622-7cec-4106-8008-20f96c253cf4	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "a034f78f-b3e5-4cf4-b77b-975fcffa55ec", "name": null, "subnet_id": "815d6c4c-bf9f-4296-a0f6-647ac7b40fcc", "ip_address": "172.25.0.6", "mac_address": "A2:EA:B0:12:29:07"}]	{f53db48f-f0a4-48a3-91fb-340ab345e501}	[{"id": "46bf53d6-67db-4dd5-9c22-e9af3f2b73f2", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T04:57:49.124394436Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 04:57:49.124397+00	2025-11-26 04:58:04.189119+00	f
a1aa7881-a6b8-462c-b3b6-86e39dc296f8	77968622-7cec-4106-8008-20f96c253cf4	172.25.0.4	a396a43f3d58	NetVisor daemon	{"type": "None"}	[{"id": "bd01c3b6-2833-43db-9a47-52644e28cb9a", "name": "eth0", "subnet_id": "815d6c4c-bf9f-4296-a0f6-647ac7b40fcc", "ip_address": "172.25.0.4", "mac_address": "9A:A2:94:34:89:D4"}]	{e9b63027-5e7c-4ae3-9bc9-2a59cb6c1879}	[{"id": "168ceae1-edb9-4d8e-b51f-56e29cd1dd32", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T04:57:31.643014704Z", "type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a"}]}	null	2025-11-26 04:57:31.49562+00	2025-11-26 04:57:31.651331+00	f
07b54ac2-f4d5-4046-8c65-c831fedb7a0c	77968622-7cec-4106-8008-20f96c253cf4	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "922fbb16-0bff-4b81-a32b-7e107732782f", "name": null, "subnet_id": "815d6c4c-bf9f-4296-a0f6-647ac7b40fcc", "ip_address": "172.25.0.5", "mac_address": "72:05:8B:3E:BF:00"}]	{e6958fa3-145c-4385-a05c-9a0e7764de53}	[{"id": "4d6a73ba-d246-4b5b-be87-cca85ff18b91", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T04:57:33.781271506Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 04:57:33.781274+00	2025-11-26 04:57:48.951825+00	f
5958a81b-7637-4679-9c4d-b3ec962796c6	77968622-7cec-4106-8008-20f96c253cf4	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "e52c6e7a-43f9-494f-8ee5-a0527057e17c", "name": null, "subnet_id": "815d6c4c-bf9f-4296-a0f6-647ac7b40fcc", "ip_address": "172.25.0.1", "mac_address": "06:ED:A0:00:2D:7C"}]	{c9fb3653-f301-48b9-a1dc-894183e31d03,faef899d-026b-40d7-80fa-824b86041696}	[{"id": "3f06b394-7015-4b52-96f0-a9c09b960ece", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9c867248-facf-4131-9cd0-368504d8777a", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "96ed0eca-ac7a-407a-ba08-c417dcb5ac63", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T04:58:12.357196528Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 04:58:12.357199+00	2025-11-26 04:58:27.42482+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
77968622-7cec-4106-8008-20f96c253cf4	My Network	2025-11-26 04:57:31.463875+00	2025-11-26 04:57:31.463875+00	f	45871a9a-30a6-4bd6-a1fb-062191accbee
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
45871a9a-30a6-4bd6-a1fb-062191accbee	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-26 04:57:28.33868+00	2025-11-26 04:57:31.462593+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
4f219965-0819-44c4-931b-ec6e23924819	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.467609+00	2025-11-26 04:57:31.467609+00	Cloudflare DNS	5bdec2d5-bf9f-464f-8c91-bd03d5a6b4bc	[{"id": "1e77fcba-5a1b-4589-b844-433153c22100", "type": "Port", "port_id": "d227590d-cfb1-4f0d-be5b-17c553bd9231", "interface_id": "ba417bf4-c1c3-471b-a85b-0eecb6849a69"}]	"Dns Server"	null	{"type": "System"}
2d475497-10ac-4ccd-b399-96dcabdd5d2f	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.467619+00	2025-11-26 04:57:31.467619+00	Google.com	aa407d1b-1603-4be9-bfdc-9910ba205499	[{"id": "3e81de40-22a6-493b-872c-cc872be3a665", "type": "Port", "port_id": "5ab7ba11-181f-4dcb-9af8-6aa73636a207", "interface_id": "5b2c0ab0-ff9b-42ae-8b79-cf6a7b4a8eba"}]	"Web Service"	null	{"type": "System"}
a1afebc2-30da-430e-afb2-fdda2cfe2e68	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.467625+00	2025-11-26 04:57:31.467625+00	Mobile Device	b9706070-4e57-45ec-8e6f-3cbf9f90cef2	[{"id": "20c430af-50f0-4ab7-a9bc-502826fa4915", "type": "Port", "port_id": "27e7e4b2-6bd5-46a6-a7d8-07a61604b945", "interface_id": "18430697-1ec2-4801-a04d-45d606fb56b4"}]	"Client"	null	{"type": "System"}
e9b63027-5e7c-4ae3-9bc9-2a59cb6c1879	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.643031+00	2025-11-26 04:57:31.643031+00	NetVisor Daemon API	a1aa7881-a6b8-462c-b3b6-86e39dc296f8	[{"id": "07d36844-4997-4c20-970e-a7263b5619f8", "type": "Port", "port_id": "168ceae1-edb9-4d8e-b51f-56e29cd1dd32", "interface_id": "bd01c3b6-2833-43db-9a47-52644e28cb9a"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-26T04:57:31.643030504Z", "type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a"}]}
e6958fa3-145c-4385-a05c-9a0e7764de53	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:36.856858+00	2025-11-26 04:57:36.856858+00	Home Assistant	07b54ac2-f4d5-4046-8c65-c831fedb7a0c	[{"id": "17e107fa-47bf-49b0-8be2-949eeb7edb4f", "type": "Port", "port_id": "4d6a73ba-d246-4b5b-be87-cca85ff18b91", "interface_id": "922fbb16-0bff-4b81-a32b-7e107732782f"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T04:57:36.856850081Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
f53db48f-f0a4-48a3-91fb-340ab345e501	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:58:04.171984+00	2025-11-26 04:58:04.171984+00	PostgreSQL	2899fa39-0c16-4933-97cf-65fb12ddd9c3	[{"id": "08431b24-a6b9-483a-ba82-9f89814fc80f", "type": "Port", "port_id": "46bf53d6-67db-4dd5-9c22-e9af3f2b73f2", "interface_id": "a034f78f-b3e5-4cf4-b77b-975fcffa55ec"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-26T04:58:04.171977057Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
faef899d-026b-40d7-80fa-824b86041696	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:58:15.429694+00	2025-11-26 04:58:15.429694+00	NetVisor Server API	5958a81b-7637-4679-9c4d-b3ec962796c6	[{"id": "501997ab-b8ee-4342-b4fc-d9c8f2b174c2", "type": "Port", "port_id": "9c867248-facf-4131-9cd0-368504d8777a", "interface_id": "e52c6e7a-43f9-494f-8ee5-a0527057e17c"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T04:58:15.429688607Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c9fb3653-f301-48b9-a1dc-894183e31d03	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:58:15.428526+00	2025-11-26 04:58:15.428526+00	Home Assistant	5958a81b-7637-4679-9c4d-b3ec962796c6	[{"id": "a6382fa3-0de9-4ecc-9f7f-b3c979541e61", "type": "Port", "port_id": "3f06b394-7015-4b52-96f0-a9c09b960ece", "interface_id": "e52c6e7a-43f9-494f-8ee5-a0527057e17c"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T04:58:15.428517495Z", "type": "Network", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
c7b7d0b9-725e-405b-9dca-1a07253b6a3f	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.467549+00	2025-11-26 04:57:31.467549+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
8b4f02d1-250a-4643-9e59-17cd1fd6a762	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.467554+00	2025-11-26 04:57:31.467554+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
815d6c4c-bf9f-4296-a0f6-647ac7b40fcc	77968622-7cec-4106-8008-20f96c253cf4	2025-11-26 04:57:31.583741+00	2025-11-26 04:57:31.583741+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-26T04:57:31.583739829Z", "type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
dca28d83-6460-445d-aac2-fb9085775f8a	77968622-7cec-4106-8008-20f96c253cf4	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "c7b7d0b9-725e-405b-9dca-1a07253b6a3f", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-26T04:57:31.467549Z", "network_id": "77968622-7cec-4106-8008-20f96c253cf4", "updated_at": "2025-11-26T04:57:31.467549Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "8b4f02d1-250a-4643-9e59-17cd1fd6a762", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-26T04:57:31.467554Z", "network_id": "77968622-7cec-4106-8008-20f96c253cf4", "updated_at": "2025-11-26T04:57:31.467554Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "815d6c4c-bf9f-4296-a0f6-647ac7b40fcc", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-26T04:57:31.583739829Z", "type": "SelfReport", "host_id": "a1aa7881-a6b8-462c-b3b6-86e39dc296f8", "daemon_id": "d5f2bc6b-d747-4e8e-a599-c837e6af9d3a"}]}, "created_at": "2025-11-26T04:57:31.583741Z", "network_id": "77968622-7cec-4106-8008-20f96c253cf4", "updated_at": "2025-11-26T04:57:31.583741Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-26 04:57:31.465165+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-26 04:57:31.465166+00	2025-11-26 04:58:04.343183+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
85910400-5b5a-4ffd-81f7-e1418f1e6070	2025-11-26 04:57:28.340651+00	2025-11-26 04:57:31.450368+00	$argon2id$v=19$m=19456,t=2,p=1$Y2biUDT0jEAapif4y0CyDA$6hbToHCwnnylTnlf9tb63+EXZD69aYw7cwZHRLlm+cE	\N	\N	\N	user@example.com	45871a9a-30a6-4bd6-a1fb-062191accbee	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
5mx2zi54GymmbykpXbcCgw	\\x93c4108302b75d29296fa6291b782ece766ce681a7757365725f6964d92438353931303430302d356235612d346666642d383166372d65313431386631653630373099cd07e9cd016804391fce1af1a611000000	2025-12-26 04:57:31.452044+00
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

\unrestrict P4aNdOclbXjXflyD8aWAfZQxzkKXg6BqOCpR212VxzxsPOgEyuJWc9gR53X9ak2

