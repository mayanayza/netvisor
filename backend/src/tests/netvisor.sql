--
-- PostgreSQL database dump
--

\restrict MyKRMO5qap9sn56g55pvnii2xqIH9zo3armcSKlGtj5TsP9o5IJXJbz4ZIjUXeN

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
    services jsonb,
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
20251006215000	users	2025-11-19 21:09:03.62449+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3555540
20251006215100	networks	2025-11-19 21:09:03.628727+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3908426
20251006215151	create hosts	2025-11-19 21:09:03.632989+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3816616
20251006215155	create subnets	2025-11-19 21:09:03.637143+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	6252800
20251006215201	create groups	2025-11-19 21:09:03.644086+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4164262
20251006215204	create daemons	2025-11-19 21:09:03.648606+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4117065
20251006215212	create services	2025-11-19 21:09:03.653265+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5088433
20251029193448	user-auth	2025-11-19 21:09:03.658773+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3951156
20251030044828	daemon api	2025-11-19 21:09:03.663058+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1497559
20251030170438	host-hide	2025-11-19 21:09:03.665314+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1134632
20251102224919	create discovery	2025-11-19 21:09:03.666822+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9270729
20251106235621	normalize-daemon-cols	2025-11-19 21:09:03.676635+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1862668
20251107034459	api keys	2025-11-19 21:09:03.679003+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7231062
20251107222650	oidc-auth	2025-11-19 21:09:03.686747+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20484609
20251110181948	orgs-billing	2025-11-19 21:09:03.707883+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10096106
20251113223656	group-enhancements	2025-11-19 21:09:03.718355+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1127076
20251117032720	daemon-mode	2025-11-19 21:09:03.71988+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1150241
20251118143058	set-default-plan	2025-11-19 21:09:03.721374+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1186940
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
fb5ddc38-f4e7-4236-9cb8-9b52d2f1c966	c13021e952d14a84a32c88bd6c9f5a35	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	Integrated Daemon API Key	2025-11-19 21:09:06.782132+00	2025-11-19 21:10:14.075217+00	2025-11-19 21:10:14.074884+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
cb822b21-406f-4ec8-8a2d-293086c05e79	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	7071d28a-2b9b-402f-ad86-d6a4a9265a4b	"172.25.0.4"	60073	2025-11-19 21:09:06.834694+00	2025-11-19 21:09:06.834693+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["4681595e-cadc-497a-a83a-1c647ab02251"]}	2025-11-19 21:09:06.85269+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
19c79f28-4ae2-4dd5-bc7c-197e8bf14ac6	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	cb822b21-406f-4ec8-8a2d-293086c05e79	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b"}	Self Report @ 172.25.0.4	2025-11-19 21:09:06.836608+00	2025-11-19 21:09:06.836608+00
1312c192-6db4-4795-b4f3-152bdf6e0dc3	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	cb822b21-406f-4ec8-8a2d-293086c05e79	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-19 21:09:06.84288+00	2025-11-19 21:09:06.84288+00
7df967b7-b4fc-436b-9730-51d93c3e4fcf	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	cb822b21-406f-4ec8-8a2d-293086c05e79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "processed": 1, "network_id": "a1be6f02-adbd-47b0-9705-f7cd5e5725c9", "session_id": "92e6da9b-7538-4cf7-8b53-ec64d65729f5", "started_at": "2025-11-19T21:09:06.842573117Z", "finished_at": "2025-11-19T21:09:06.938837010Z", "discovery_type": {"type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b"}	Discovery Run	2025-11-19 21:09:06.842573+00	2025-11-19 21:09:06.940525+00
52954fef-718e-4e65-ba67-ac7fcdc68026	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	cb822b21-406f-4ec8-8a2d-293086c05e79	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "processed": 11, "network_id": "a1be6f02-adbd-47b0-9705-f7cd5e5725c9", "session_id": "6d5db346-ed1c-440d-8525-49dad64274c5", "started_at": "2025-11-19T21:09:06.949909313Z", "finished_at": "2025-11-19T21:10:14.074109263Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-19 21:09:06.949909+00	2025-11-19 21:10:14.075136+00
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
2e7ca6ba-343e-46bf-b70f-7fb3e0b421dc	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "b4da9cfe-0e9d-4428-b0a0-c6bcf3901a45"}	[{"id": "1b67d353-09f5-4c3d-a3ea-ccb3fec9df97", "name": "Internet", "subnet_id": "c2ac5b0a-65e2-478c-8c1f-7308986e63f4", "ip_address": "1.1.1.1", "mac_address": null}]	["0acb2c51-b646-49f2-9f27-a102b7df07c1"]	[{"id": "ec05fe6c-733d-4237-98fc-105297c723e3", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-19 21:09:06.76319+00	2025-11-19 21:09:06.772253+00	f
6c87b2ec-6cf3-42a5-9d99-df1cae523800	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	Google.com	\N	\N	{"type": "ServiceBinding", "config": "f2e65830-b346-4325-843a-5d9d8b9e0acc"}	[{"id": "26c46456-73bd-4112-8662-586fd3302492", "name": "Internet", "subnet_id": "c2ac5b0a-65e2-478c-8c1f-7308986e63f4", "ip_address": "203.0.113.73", "mac_address": null}]	["6e97e905-7fe0-40e2-b496-be8fa0366566"]	[{"id": "2371c794-2b9f-414b-83f8-ce1415923854", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 21:09:06.763197+00	2025-11-19 21:09:06.777361+00	f
d8f0cb6a-c469-49a3-ae2a-adcecde00143	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "fc48e41c-cf81-45eb-aacf-a88b96c77e21"}	[{"id": "7a0fd0d3-aec3-4e0f-977e-b0dbd7bd7ecf", "name": "Remote Network", "subnet_id": "04f685ce-3e1d-4c68-8d17-c9cf2d2169c7", "ip_address": "203.0.113.29", "mac_address": null}]	["1587038c-6ec3-4c24-91d4-19975ff5e5d8"]	[{"id": "76d38981-a2d7-4a34-95dc-b74326b6300c", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 21:09:06.763202+00	2025-11-19 21:09:06.781135+00	f
7071d28a-2b9b-402f-ad86-d6a4a9265a4b	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	172.25.0.4	3c94e804101f	NetVisor daemon	{"type": "None"}	[{"id": "530b4938-6e8e-4711-a6c1-9c7c5df56e98", "name": "eth0", "subnet_id": "4681595e-cadc-497a-a83a-1c647ab02251", "ip_address": "172.25.0.4", "mac_address": "46:C4:3E:B6:8B:7A"}]	["2cbb1e05-ecf3-4e23-a498-30c9da55fdfa", "6aa3f722-9b35-4f37-a0d3-8887a625d729"]	[{"id": "ec053ab0-d2bb-4057-a0ef-69be6144c628", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:23.471315339Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T21:09:06.854514719Z", "type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79"}]}	null	2025-11-19 21:09:06.789924+00	2025-11-19 21:09:23.481533+00	f
543badba-6922-4ea4-98c5-21208b514387	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "577f31fd-15a9-4a05-8298-84a8468745d2", "name": null, "subnet_id": "4681595e-cadc-497a-a83a-1c647ab02251", "ip_address": "172.25.0.6", "mac_address": "D6:27:FB:87:17:40"}]	["6f54be6a-a301-4eda-a58a-0ceac0ab3e94"]	[{"id": "cf7c722a-436a-42bf-be1f-91cae1fd5217", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:23.473082669Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 21:09:23.473083+00	2025-11-19 21:09:51.788838+00	f
7506acfb-0415-4a4d-9363-ae0116d8b175	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "293732f5-baaa-45c0-aa79-3a740fe2e264", "name": null, "subnet_id": "4681595e-cadc-497a-a83a-1c647ab02251", "ip_address": "172.25.0.3", "mac_address": "8E:A6:A8:1A:45:CA"}]	["b74e2272-e484-4418-b674-46eaecf34371"]	[{"id": "8af0eed6-31de-4365-843f-832ca8abd93a", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:09.028627353Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 21:09:09.02863+00	2025-11-19 21:09:23.253872+00	f
0f630d59-fd47-47e6-964b-eb8389fe09c6	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "097c6486-7e89-4f9d-a9ec-74dec118e021", "name": null, "subnet_id": "4681595e-cadc-497a-a83a-1c647ab02251", "ip_address": "172.25.0.5", "mac_address": "EE:ED:7C:AD:81:C9"}]	["08875b2e-8288-4baa-8b3e-c6f505615ae5"]	[{"id": "6622c748-f93b-418b-9039-a80d0a53a9c6", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:37.636535299Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 21:09:37.636536+00	2025-11-19 21:09:51.897038+00	f
c8b1a2ad-fe1f-4af1-bf31-54c611e3d74e	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "36f836f6-f247-40d1-bb71-c5030c8c1886", "name": null, "subnet_id": "4681595e-cadc-497a-a83a-1c647ab02251", "ip_address": "172.25.0.1", "mac_address": "A2:64:C5:C2:2E:5A"}]	["3d74baf2-41c2-4579-909a-b254f56ea389", "7a9d926a-b894-463d-a015-e43b8458cc79"]	[{"id": "a73f14b4-5171-4e95-92bb-2e15d6e400d1", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "99ac1f5d-332b-4dff-8a31-8f54844dc78b", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "cbbc8d11-8797-4bd5-8453-9480fdbd49f3", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:59.940443170Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 21:09:59.940445+00	2025-11-19 21:10:14.072064+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
a1be6f02-adbd-47b0-9705-f7cd5e5725c9	My Network	2025-11-19 21:09:06.761859+00	2025-11-19 21:09:06.761859+00	f	25d71b1c-d081-461f-ac3a-b778e5dd2fee
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
25d71b1c-d081-461f-ac3a-b778e5dd2fee	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-19 21:09:03.777406+00	2025-11-19 21:09:06.760308+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
0acb2c51-b646-49f2-9f27-a102b7df07c1	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.763192+00	2025-11-19 21:09:06.763192+00	Cloudflare DNS	2e7ca6ba-343e-46bf-b70f-7fb3e0b421dc	[{"id": "b4da9cfe-0e9d-4428-b0a0-c6bcf3901a45", "type": "Port", "port_id": "ec05fe6c-733d-4237-98fc-105297c723e3", "interface_id": "1b67d353-09f5-4c3d-a3ea-ccb3fec9df97"}]	"Dns Server"	null	{"type": "System"}
6e97e905-7fe0-40e2-b496-be8fa0366566	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.763198+00	2025-11-19 21:09:06.763198+00	Google.com	6c87b2ec-6cf3-42a5-9d99-df1cae523800	[{"id": "f2e65830-b346-4325-843a-5d9d8b9e0acc", "type": "Port", "port_id": "2371c794-2b9f-414b-83f8-ce1415923854", "interface_id": "26c46456-73bd-4112-8662-586fd3302492"}]	"Web Service"	null	{"type": "System"}
1587038c-6ec3-4c24-91d4-19975ff5e5d8	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.763203+00	2025-11-19 21:09:06.763203+00	Mobile Device	d8f0cb6a-c469-49a3-ae2a-adcecde00143	[{"id": "fc48e41c-cf81-45eb-aacf-a88b96c77e21", "type": "Port", "port_id": "76d38981-a2d7-4a34-95dc-b74326b6300c", "interface_id": "7a0fd0d3-aec3-4e0f-977e-b0dbd7bd7ecf"}]	"Client"	null	{"type": "System"}
b74e2272-e484-4418-b674-46eaecf34371	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:16.881428+00	2025-11-19 21:09:16.881428+00	NetVisor Server API	7506acfb-0415-4a4d-9363-ae0116d8b175	[{"id": "ea2e7c12-599d-4cc8-b7f7-b7e763b75c09", "type": "Port", "port_id": "8af0eed6-31de-4365-843f-832ca8abd93a", "interface_id": "293732f5-baaa-45c0-aa79-3a740fe2e264"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T21:09:16.881410337Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
2cbb1e05-ecf3-4e23-a498-30c9da55fdfa	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.85453+00	2025-11-19 21:09:23.479594+00	NetVisor Daemon API	7071d28a-2b9b-402f-ad86-d6a4a9265a4b	[{"id": "bb6337ce-014e-4fa3-a937-b5bbb82eea0f", "type": "Port", "port_id": "ec053ab0-d2bb-4057-a0ef-69be6144c628", "interface_id": "530b4938-6e8e-4711-a6c1-9c7c5df56e98"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-19T21:09:23.472006385Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T21:09:06.854529778Z", "type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79"}]}
6f54be6a-a301-4eda-a58a-0ceac0ab3e94	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:37.635718+00	2025-11-19 21:09:37.635718+00	PostgreSQL	543badba-6922-4ea4-98c5-21208b514387	[{"id": "a21c6a3e-a686-48fe-8e92-c920091105d3", "type": "Port", "port_id": "cf7c722a-436a-42bf-be1f-91cae1fd5217", "interface_id": "577f31fd-15a9-4a05-8298-84a8468745d2"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-19T21:09:37.635710874Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
08875b2e-8288-4baa-8b3e-c6f505615ae5	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:43.317768+00	2025-11-19 21:09:43.317768+00	Home Assistant	0f630d59-fd47-47e6-964b-eb8389fe09c6	[{"id": "940dd28c-cfd9-49ad-b8c7-9c8acc33bf33", "type": "Port", "port_id": "6622c748-f93b-418b-9039-a80d0a53a9c6", "interface_id": "097c6486-7e89-4f9d-a9ec-74dec118e021"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T21:09:43.317758108Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7a9d926a-b894-463d-a015-e43b8458cc79	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:10:07.729116+00	2025-11-19 21:10:07.729116+00	NetVisor Server API	c8b1a2ad-fe1f-4af1-bf31-54c611e3d74e	[{"id": "c1f9c4d8-9c3c-47da-abbf-0197b6ec3a95", "type": "Port", "port_id": "99ac1f5d-332b-4dff-8a31-8f54844dc78b", "interface_id": "36f836f6-f247-40d1-bb71-c5030c8c1886"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T21:10:07.729106741Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
3d74baf2-41c2-4579-909a-b254f56ea389	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:10:05.582832+00	2025-11-19 21:10:05.582832+00	Home Assistant	c8b1a2ad-fe1f-4af1-bf31-54c611e3d74e	[{"id": "102be572-b653-4d4d-ab91-bafc20e88b63", "type": "Port", "port_id": "a73f14b4-5171-4e95-92bb-2e15d6e400d1", "interface_id": "36f836f6-f247-40d1-bb71-c5030c8c1886"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T21:10:05.582822345Z", "type": "Network", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
c2ac5b0a-65e2-478c-8c1f-7308986e63f4	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.763099+00	2025-11-19 21:09:06.763099+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
04f685ce-3e1d-4c68-8d17-c9cf2d2169c7	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.763104+00	2025-11-19 21:09:06.763104+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
4681595e-cadc-497a-a83a-1c647ab02251	a1be6f02-adbd-47b0-9705-f7cd5e5725c9	2025-11-19 21:09:06.842707+00	2025-11-19 21:09:06.842707+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-19T21:09:06.842706565Z", "type": "SelfReport", "host_id": "7071d28a-2b9b-402f-ad86-d6a4a9265a4b", "daemon_id": "cb822b21-406f-4ec8-8a2d-293086c05e79"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
d6b2831f-c70a-413b-bdcd-6668a84f3ebd	2025-11-19 21:09:03.779243+00	2025-11-19 21:09:06.747737+00	$argon2id$v=19$m=19456,t=2,p=1$kQlWmFddRyF8zN4G2E9x/Q$0gbsFGzfHnVCbpkujAlf2sjXwWo6kJQEavvwxHDfgAQ	\N	\N	\N	user@example.com	25d71b1c-d081-461f-ac3a-b778e5dd2fee	Owner
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
d7QvXa8gZ0k6TWMhRR7vrg	\\x93c410aeef1e4521634d3a496720af5d2fb47781a7757365725f6964d92464366232383331662d633730612d343133622d626463642d36363638613834663365626499cd07e9cd0161150906ce2cacac90000000	2025-12-19 21:09:06.749513+00
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
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict MyKRMO5qap9sn56g55pvnii2xqIH9zo3armcSKlGtj5TsP9o5IJXJbz4ZIjUXeN

