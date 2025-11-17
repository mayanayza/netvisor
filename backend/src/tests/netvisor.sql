--
-- PostgreSQL database dump
--

\restrict 5Tnh8pajTxW6r9WNUFbgPET8OYR5aIQLMVcvLugThUe5hgbllwbcaLUp3mb1eNO

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
    plan jsonb,
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
20251006215000	users	2025-11-17 19:39:44.411434+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3438404
20251006215100	networks	2025-11-17 19:39:44.415566+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3983658
20251006215151	create hosts	2025-11-17 19:39:44.419884+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3804722
20251006215155	create subnets	2025-11-17 19:39:44.424055+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3675860
20251006215201	create groups	2025-11-17 19:39:44.428081+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3960635
20251006215204	create daemons	2025-11-17 19:39:44.432387+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4271868
20251006215212	create services	2025-11-17 19:39:44.437015+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4705412
20251029193448	user-auth	2025-11-17 19:39:44.442056+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3552549
20251030044828	daemon api	2025-11-17 19:39:44.445895+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1487713
20251030170438	host-hide	2025-11-17 19:39:44.447675+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1118209
20251102224919	create discovery	2025-11-17 19:39:44.449098+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9548864
20251106235621	normalize-daemon-cols	2025-11-17 19:39:44.459163+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1745356
20251107034459	api keys	2025-11-17 19:39:44.461199+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7489638
20251107222650	oidc-auth	2025-11-17 19:39:44.469013+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20888229
20251110181948	orgs-billing	2025-11-17 19:39:44.490229+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	10244941
20251113223656	group-enhancements	2025-11-17 19:39:44.500802+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1018693
20251117032720	daemon-mode	2025-11-17 19:39:44.502101+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1073646
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
4f6eff55-5fb3-4163-8c4a-7a1f410a5c5a	0980001d609b4be3b34704e7ef86bff4	6736afc8-9e9a-41a6-9072-4a32eff1e653	Integrated Daemon API Key	2025-11-17 19:39:47.230537+00	2025-11-17 19:40:40.08832+00	2025-11-17 19:40:40.087954+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
28a3ba02-66d2-40ba-b7e2-678ceee92a4b	6736afc8-9e9a-41a6-9072-4a32eff1e653	ea02214b-b082-4d37-8f0d-6afae00bcf5e	"172.25.0.4"	60073	2025-11-17 19:39:47.283256+00	2025-11-17 19:39:47.283255+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["bdba1488-91a4-45b0-98b3-98d7a2335119"]}	2025-11-17 19:39:47.302266+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
54816a16-1b93-46c3-b147-08ff22ab7a71	6736afc8-9e9a-41a6-9072-4a32eff1e653	28a3ba02-66d2-40ba-b7e2-678ceee92a4b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e"}	Self Report @ 172.25.0.4	2025-11-17 19:39:47.284865+00	2025-11-17 19:39:47.284865+00
0e54e7ce-0473-4aec-bb61-810c70b7a7db	6736afc8-9e9a-41a6-9072-4a32eff1e653	28a3ba02-66d2-40ba-b7e2-678ceee92a4b	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 19:39:47.290962+00	2025-11-17 19:39:47.290962+00
ff9ff51d-cd04-499c-8317-1072610933aa	6736afc8-9e9a-41a6-9072-4a32eff1e653	28a3ba02-66d2-40ba-b7e2-678ceee92a4b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "processed": 1, "network_id": "6736afc8-9e9a-41a6-9072-4a32eff1e653", "session_id": "12d4b413-7209-44b1-bc37-f655edb209dc", "started_at": "2025-11-17T19:39:47.290600109Z", "finished_at": "2025-11-17T19:39:47.355345964Z", "discovery_type": {"type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e"}	Discovery Run	2025-11-17 19:39:47.2906+00	2025-11-17 19:39:47.356935+00
3be9433c-9eeb-4e19-b8d7-d877180b87a5	6736afc8-9e9a-41a6-9072-4a32eff1e653	28a3ba02-66d2-40ba-b7e2-678ceee92a4b	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "processed": 13, "network_id": "6736afc8-9e9a-41a6-9072-4a32eff1e653", "session_id": "76728423-f9bf-4e03-8e54-dacc8482a524", "started_at": "2025-11-17T19:39:47.365798584Z", "finished_at": "2025-11-17T19:40:40.087079462Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 19:39:47.365798+00	2025-11-17 19:40:40.088243+00
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
0418221d-314d-4c11-92aa-b95e48c34b07	6736afc8-9e9a-41a6-9072-4a32eff1e653	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "ea6b005c-062a-408f-a4a4-e2a2090a39be"}	[{"id": "b352cf30-fdf3-4a16-aadc-93b8e62f9d14", "name": "Internet", "subnet_id": "f0905ffc-4caf-4d15-9ac1-e23aac5d06e3", "ip_address": "1.1.1.1", "mac_address": null}]	["e0055335-1638-43a6-a379-446ae45c3ab8"]	[{"id": "f83eb838-33dc-4695-9bf8-57f59ea93470", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 19:39:47.211129+00	2025-11-17 19:39:47.221104+00	f
4692e1d6-4364-4aa2-867a-c0f38c1849bb	6736afc8-9e9a-41a6-9072-4a32eff1e653	Google.com	\N	\N	{"type": "ServiceBinding", "config": "8722d40c-f456-45c5-89b0-bfcffba63f0a"}	[{"id": "8f0ae152-9f86-4935-976c-e511b8b52f02", "name": "Internet", "subnet_id": "f0905ffc-4caf-4d15-9ac1-e23aac5d06e3", "ip_address": "203.0.113.126", "mac_address": null}]	["6141ed36-faf7-4711-a0af-969988cfa4d4"]	[{"id": "2f211d52-a12c-40d4-8317-c0fe773ca9d9", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 19:39:47.21114+00	2025-11-17 19:39:47.226131+00	f
cbb7b38d-f8ce-409d-867f-986fb41965ad	6736afc8-9e9a-41a6-9072-4a32eff1e653	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "6ee2b14c-05a1-4d5e-9cf0-689db46e2ee2"}	[{"id": "9fe18667-3523-4fe1-819c-e5f836b6c53d", "name": "Remote Network", "subnet_id": "c1f6c316-280b-4a5c-aea7-96297e27df2d", "ip_address": "203.0.113.188", "mac_address": null}]	["8ad5fbe8-8755-409d-8142-8f9515c90fa4"]	[{"id": "7540cf96-69a0-461a-bb1d-6d88cedad8da", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 19:39:47.211148+00	2025-11-17 19:39:47.229814+00	f
b179ff13-3c94-4726-8eea-2cdbf84361d4	6736afc8-9e9a-41a6-9072-4a32eff1e653	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "f7cd0a6c-5e6d-4f2d-9eee-fd903961fb47", "name": null, "subnet_id": "bdba1488-91a4-45b0-98b3-98d7a2335119", "ip_address": "172.25.0.6", "mac_address": "E2:C4:6C:7C:81:82"}]	["b6c795d9-c34b-4ea2-a10e-d4c6f4107b59"]	[{"id": "10f17580-3d07-44dd-a2b3-804cfc9f644e", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T19:40:04.527126563Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 19:40:04.527128+00	2025-11-17 19:40:19.239912+00	f
ea02214b-b082-4d37-8f0d-6afae00bcf5e	6736afc8-9e9a-41a6-9072-4a32eff1e653	172.25.0.4	835ada1e853d	NetVisor daemon	{"type": "None"}	[{"id": "d0f77d90-9a69-4e7a-9b44-e5da72234ba1", "name": "eth0", "subnet_id": "bdba1488-91a4-45b0-98b3-98d7a2335119", "ip_address": "172.25.0.4", "mac_address": "52:5D:9E:7A:FC:98"}]	["070d118e-7664-46b6-bf1e-7f308b7828e4"]	[{"id": "568fbd50-fcb2-4c13-9b76-56d749e32ec5", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T19:39:47.304268254Z", "type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b"}]}	null	2025-11-17 19:39:47.238593+00	2025-11-17 19:39:47.353456+00	f
1d0b766d-6e05-4622-b844-35f225f06eef	6736afc8-9e9a-41a6-9072-4a32eff1e653	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "38eed4a8-5fc4-4ba5-82a1-41d9a27010e8", "name": null, "subnet_id": "bdba1488-91a4-45b0-98b3-98d7a2335119", "ip_address": "172.25.0.3", "mac_address": "2E:82:E4:0E:F6:39"}]	["f270c574-4e72-45c4-9269-81415d8dbea1"]	[{"id": "f50699ba-baeb-4ee9-aa27-ce4c0640b361", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T19:39:49.573650201Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 19:39:49.573653+00	2025-11-17 19:40:04.384674+00	f
bd9b4c7d-8c04-4cf1-bc95-ac1686040429	6736afc8-9e9a-41a6-9072-4a32eff1e653	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "54661eea-92af-4e55-934d-7855d16cde90", "name": null, "subnet_id": "bdba1488-91a4-45b0-98b3-98d7a2335119", "ip_address": "172.25.0.1", "mac_address": "62:BC:24:84:9A:79"}]	["046b5f57-fefb-4382-8fbb-4a03c44b12cc", "5aaa2bfa-7024-4f63-9ba4-08b5fc36e0f5"]	[{"id": "17058966-f421-44fd-aa26-c75564c15b9a", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "57490585-84be-4297-8e33-e64538a15999", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "a2f4639e-11d7-40d0-b36e-8968a4496ea4", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T19:40:25.402160433Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 19:40:25.402163+00	2025-11-17 19:40:40.084843+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
6736afc8-9e9a-41a6-9072-4a32eff1e653	My Network	2025-11-17 19:39:47.209634+00	2025-11-17 19:39:47.209634+00	f	25cb98f6-147c-4b89-b5ad-b2676afd3d05
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
25cb98f6-147c-4b89-b5ad-b2676afd3d05	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 19:39:44.55714+00	2025-11-17 19:39:47.207965+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
e0055335-1638-43a6-a379-446ae45c3ab8	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.211132+00	2025-11-17 19:39:47.211132+00	Cloudflare DNS	0418221d-314d-4c11-92aa-b95e48c34b07	[{"id": "ea6b005c-062a-408f-a4a4-e2a2090a39be", "type": "Port", "port_id": "f83eb838-33dc-4695-9bf8-57f59ea93470", "interface_id": "b352cf30-fdf3-4a16-aadc-93b8e62f9d14"}]	"Dns Server"	null	{"type": "System"}
6141ed36-faf7-4711-a0af-969988cfa4d4	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.211142+00	2025-11-17 19:39:47.211142+00	Google.com	4692e1d6-4364-4aa2-867a-c0f38c1849bb	[{"id": "8722d40c-f456-45c5-89b0-bfcffba63f0a", "type": "Port", "port_id": "2f211d52-a12c-40d4-8317-c0fe773ca9d9", "interface_id": "8f0ae152-9f86-4935-976c-e511b8b52f02"}]	"Web Service"	null	{"type": "System"}
8ad5fbe8-8755-409d-8142-8f9515c90fa4	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.21115+00	2025-11-17 19:39:47.21115+00	Mobile Device	cbb7b38d-f8ce-409d-867f-986fb41965ad	[{"id": "6ee2b14c-05a1-4d5e-9cf0-689db46e2ee2", "type": "Port", "port_id": "7540cf96-69a0-461a-bb1d-6d88cedad8da", "interface_id": "9fe18667-3523-4fe1-819c-e5f836b6c53d"}]	"Client"	null	{"type": "System"}
070d118e-7664-46b6-bf1e-7f308b7828e4	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.304294+00	2025-11-17 19:39:47.304294+00	NetVisor Daemon API	ea02214b-b082-4d37-8f0d-6afae00bcf5e	[{"id": "d2ce0ddc-531f-4610-b191-7d123b707d7f", "type": "Port", "port_id": "568fbd50-fcb2-4c13-9b76-56d749e32ec5", "interface_id": "d0f77d90-9a69-4e7a-9b44-e5da72234ba1"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T19:39:47.304293512Z", "type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b"}]}
f270c574-4e72-45c4-9269-81415d8dbea1	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:54.813678+00	2025-11-17 19:39:54.813678+00	NetVisor Server API	1d0b766d-6e05-4622-b844-35f225f06eef	[{"id": "32ae42ca-d8b6-4107-b173-7783b35236c2", "type": "Port", "port_id": "f50699ba-baeb-4ee9-aa27-ce4c0640b361", "interface_id": "38eed4a8-5fc4-4ba5-82a1-41d9a27010e8"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T19:39:54.813668970Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
b6c795d9-c34b-4ea2-a10e-d4c6f4107b59	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:40:19.231891+00	2025-11-17 19:40:19.231891+00	PostgreSQL	b179ff13-3c94-4726-8eea-2cdbf84361d4	[{"id": "754cc21d-37f2-42dd-82d2-9488c06e777c", "type": "Port", "port_id": "10f17580-3d07-44dd-a2b3-804cfc9f644e", "interface_id": "f7cd0a6c-5e6d-4f2d-9eee-fd903961fb47"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T19:40:19.231883879Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5aaa2bfa-7024-4f63-9ba4-08b5fc36e0f5	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:40:40.075038+00	2025-11-17 19:40:40.075038+00	Home Assistant	bd9b4c7d-8c04-4cf1-bc95-ac1686040429	[{"id": "58f83b80-cd0e-401c-a1a2-8c6685df6182", "type": "Port", "port_id": "57490585-84be-4297-8e33-e64538a15999", "interface_id": "54661eea-92af-4e55-934d-7855d16cde90"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T19:40:40.075028426Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
046b5f57-fefb-4382-8fbb-4a03c44b12cc	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:40:30.518303+00	2025-11-17 19:40:30.518303+00	NetVisor Server API	bd9b4c7d-8c04-4cf1-bc95-ac1686040429	[{"id": "c5c660d2-2fec-454d-8f42-89b8fe5d57b3", "type": "Port", "port_id": "17058966-f421-44fd-aa26-c75564c15b9a", "interface_id": "54661eea-92af-4e55-934d-7855d16cde90"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T19:40:30.518292903Z", "type": "Network", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
f0905ffc-4caf-4d15-9ac1-e23aac5d06e3	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.211066+00	2025-11-17 19:39:47.211066+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
c1f6c316-280b-4a5c-aea7-96297e27df2d	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.211071+00	2025-11-17 19:39:47.211071+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
bdba1488-91a4-45b0-98b3-98d7a2335119	6736afc8-9e9a-41a6-9072-4a32eff1e653	2025-11-17 19:39:47.290777+00	2025-11-17 19:39:47.290777+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T19:39:47.290775528Z", "type": "SelfReport", "host_id": "ea02214b-b082-4d37-8f0d-6afae00bcf5e", "daemon_id": "28a3ba02-66d2-40ba-b7e2-678ceee92a4b"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
41c2355b-58dc-48ce-a164-57a5f19a705d	2025-11-17 19:39:44.559186+00	2025-11-17 19:39:47.195966+00	$argon2id$v=19$m=19456,t=2,p=1$KlandEoFyYiwt8ncCXaEFg$sfu5Vy/cHtx/ojTyI/g7We3AaS/uT6CYahdDqDnLGys	\N	\N	\N	user@example.com	25cb98f6-147c-4b89-b5ad-b2676afd3d05	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
Be6ylwuQgWjkCzXHdnnnbw	\\x93c4106fe77976c7350be46881900b97b2ee0581a7757365725f6964d92434316332333535622d353864632d343863652d613136342d35376135663139613730356499cd07e9cd015f13272fce0bc760b7000000	2025-12-17 19:39:47.197615+00
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

\unrestrict 5Tnh8pajTxW6r9WNUFbgPET8OYR5aIQLMVcvLugThUe5hgbllwbcaLUp3mb1eNO

