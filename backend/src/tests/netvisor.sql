--
-- PostgreSQL database dump
--

\restrict l3SEJ1p0tdZdfP9GCmd3T0aq1eKfmVYPGkhej82ReDVeEDfjsouSMt75h7rMPbL

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
20251006215000	users	2025-11-17 06:45:52.458934+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2824807
20251006215100	networks	2025-11-17 06:45:52.463059+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2993319
20251006215151	create hosts	2025-11-17 06:45:52.466578+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	2954443
20251006215155	create subnets	2025-11-17 06:45:52.469802+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2815603
20251006215201	create groups	2025-11-17 06:45:52.472875+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2733632
20251006215204	create daemons	2025-11-17 06:45:52.475921+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3136974
20251006215212	create services	2025-11-17 06:45:52.479381+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3588491
20251029193448	user-auth	2025-11-17 06:45:52.483308+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	2813230
20251030044828	daemon api	2025-11-17 06:45:52.486423+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1153299
20251030170438	host-hide	2025-11-17 06:45:52.487864+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	815395
20251102224919	create discovery	2025-11-17 06:45:52.488949+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	7218369
20251106235621	normalize-daemon-cols	2025-11-17 06:45:52.496413+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1449888
20251107034459	api keys	2025-11-17 06:45:52.498142+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	5629712
20251107222650	oidc-auth	2025-11-17 06:45:52.504122+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	16692605
20251110181948	orgs-billing	2025-11-17 06:45:52.521421+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	7544385
20251113223656	group-enhancements	2025-11-17 06:45:52.529926+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	863649
20251117032720	daemon-mode	2025-11-17 06:45:52.531004+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1009716
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
fcb930c0-9ef3-4eb4-9dce-b5f17124f703	89c8164149374934bc670e8fed1912ad	6f1b737e-aee6-4f45-b246-261d3816d4f9	Integrated Daemon API Key	2025-11-17 06:45:56.690126+00	2025-11-17 06:46:48.202614+00	2025-11-17 06:46:48.202276+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
f1b5ec0f-15a5-477a-8411-a5cb74057994	6f1b737e-aee6-4f45-b246-261d3816d4f9	b4d1f2ba-7a52-41aa-9270-a8b0c94e4441	"172.25.0.4"	60073	2025-11-17 06:45:56.733398+00	2025-11-17 06:45:56.733396+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a"]}	2025-11-17 06:45:56.749012+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
1e481e40-198f-4234-8d2f-adc6bc561e00	6f1b737e-aee6-4f45-b246-261d3816d4f9	f1b5ec0f-15a5-477a-8411-a5cb74057994	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441"}	Self Report @ 172.25.0.4	2025-11-17 06:45:56.735122+00	2025-11-17 06:45:56.735122+00
9c3dbdf9-cb8b-4d4a-8aa7-06ceff4c6f4f	6f1b737e-aee6-4f45-b246-261d3816d4f9	f1b5ec0f-15a5-477a-8411-a5cb74057994	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 06:45:56.740984+00	2025-11-17 06:45:56.740984+00
e9653aff-7de4-4356-a27d-0c30dd001e3d	6f1b737e-aee6-4f45-b246-261d3816d4f9	f1b5ec0f-15a5-477a-8411-a5cb74057994	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "processed": 1, "network_id": "6f1b737e-aee6-4f45-b246-261d3816d4f9", "session_id": "e1551ead-df46-4550-afb3-10d99928e782", "started_at": "2025-11-17T06:45:56.740602164Z", "finished_at": "2025-11-17T06:45:56.822977640Z", "discovery_type": {"type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441"}	Discovery Run	2025-11-17 06:45:56.740602+00	2025-11-17 06:45:56.824728+00
1c71ac71-b2a7-460a-abf7-ac06a1ca939f	6f1b737e-aee6-4f45-b246-261d3816d4f9	f1b5ec0f-15a5-477a-8411-a5cb74057994	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "processed": 13, "network_id": "6f1b737e-aee6-4f45-b246-261d3816d4f9", "session_id": "e51e2803-b3d1-4bbc-aa46-740295ba5244", "started_at": "2025-11-17T06:45:56.831871292Z", "finished_at": "2025-11-17T06:46:48.201404847Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 06:45:56.831871+00	2025-11-17 06:46:48.202541+00
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
1730f8a1-5556-4690-8648-82925914d827	6f1b737e-aee6-4f45-b246-261d3816d4f9	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "36404e10-4dee-46e9-8d32-62936fefc3a8"}	[{"id": "28023e99-d634-4f43-a983-d3ab9405f663", "name": "Internet", "subnet_id": "a8a3ed94-183c-4853-8bad-6082fcb6bd96", "ip_address": "1.1.1.1", "mac_address": null}]	["f284db8e-4fd0-45c5-bc1b-62a8f8191009"]	[{"id": "1e2904ea-346a-43b6-8294-a24260a783ac", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 06:45:56.673455+00	2025-11-17 06:45:56.681281+00	f
6f498fec-e813-4605-8531-3bc695cbd712	6f1b737e-aee6-4f45-b246-261d3816d4f9	Google.com	\N	\N	{"type": "ServiceBinding", "config": "e43f06e3-7fd0-4c13-bfe8-24fff157cab8"}	[{"id": "a14fd77d-39d5-4b4c-a24b-9517671d454a", "name": "Internet", "subnet_id": "a8a3ed94-183c-4853-8bad-6082fcb6bd96", "ip_address": "203.0.113.244", "mac_address": null}]	["4560266a-ca14-4221-8f96-824ea8c96c60"]	[{"id": "512b52d6-79a5-4584-8363-fefaf36d36f7", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:45:56.67346+00	2025-11-17 06:45:56.685978+00	f
0b1d70c5-ca4c-4a5d-b2d8-285457d0dfc8	6f1b737e-aee6-4f45-b246-261d3816d4f9	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "5ef4ada7-e4f8-4f13-90d2-d60e29ac9da2"}	[{"id": "9e3ed2d9-efa5-490c-a3f1-b3980e36b8b9", "name": "Remote Network", "subnet_id": "33621841-ef06-4fb6-83fd-9b30d658446c", "ip_address": "203.0.113.202", "mac_address": null}]	["d3c662d4-062e-49ae-a962-1a7865a94616"]	[{"id": "14d943a0-0f6e-445f-aaff-c7872be5c404", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:45:56.673464+00	2025-11-17 06:45:56.689402+00	f
2ecc84da-1f64-4fad-b0c2-c92e604ca06e	6f1b737e-aee6-4f45-b246-261d3816d4f9	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "51d6025b-ca7f-4d31-a1a4-be3b35cfa69a", "name": null, "subnet_id": "6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a", "ip_address": "172.25.0.6", "mac_address": "52:4C:5E:F2:64:39"}]	["c4ec3c09-b0df-4a7e-89ca-8e2b82138e3a"]	[{"id": "81a4390d-fbab-43f4-8687-fbfdb0d12841", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:46:13.453409782Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:46:13.453411+00	2025-11-17 06:46:27.820036+00	f
b4d1f2ba-7a52-41aa-9270-a8b0c94e4441	6f1b737e-aee6-4f45-b246-261d3816d4f9	172.25.0.4	1010dff25cd1	NetVisor daemon	{"type": "None"}	[{"id": "cad5e09a-ada7-435f-87cb-99b5add0ceb1", "name": "eth0", "subnet_id": "6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a", "ip_address": "172.25.0.4", "mac_address": "86:BB:43:E7:14:03"}]	["5eb2069d-43e5-4cc8-8c95-1e8ec6b91ad3"]	[{"id": "54848bd0-9aa0-4967-a20b-83e45f34d69b", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:45:56.811283173Z", "type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994"}]}	null	2025-11-17 06:45:56.696768+00	2025-11-17 06:45:56.821006+00	f
382d1f94-c22c-4705-8b1d-89c84cc6a7d3	6f1b737e-aee6-4f45-b246-261d3816d4f9	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "38ad3c7d-36c3-4f10-b8b9-bd0bf7bd1b9c", "name": null, "subnet_id": "6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a", "ip_address": "172.25.0.3", "mac_address": "B6:13:7E:21:99:8C"}]	["ef4eef65-beab-455f-aecc-6a17942d4f40"]	[{"id": "f8539e55-4134-4104-9b91-247ac17bacdb", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:45:58.986625415Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:45:58.986628+00	2025-11-17 06:46:13.343104+00	f
351da4c5-910e-4693-8514-f50a90c62394	6f1b737e-aee6-4f45-b246-261d3816d4f9	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "d5084bf4-b3e1-4767-bc6b-b0a6ccd93fc5", "name": null, "subnet_id": "6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a", "ip_address": "172.25.0.1", "mac_address": "12:77:F6:88:C9:04"}]	["acdce521-5d6a-4331-b697-383648a9f3e6", "8cd2f5e7-5bee-49ac-8a64-4295bfcc90dc"]	[{"id": "c2494ba5-6c87-4410-8a8f-70f07ee59136", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "89b492fe-1398-428b-bf9b-62752f83c65b", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9e943ba9-941e-4906-9a2a-18ffeed3c252", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:46:33.925868995Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:46:33.925871+00	2025-11-17 06:46:48.199354+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
6f1b737e-aee6-4f45-b246-261d3816d4f9	My Network	2025-11-17 06:45:56.672181+00	2025-11-17 06:45:56.672181+00	f	0add3a4c-cf0a-49c2-bd76-c50a573ab707
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
0add3a4c-cf0a-49c2-bd76-c50a573ab707	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 06:45:52.57611+00	2025-11-17 06:45:56.670687+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
f284db8e-4fd0-45c5-bc1b-62a8f8191009	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.673457+00	2025-11-17 06:45:56.673457+00	Cloudflare DNS	1730f8a1-5556-4690-8648-82925914d827	[{"id": "36404e10-4dee-46e9-8d32-62936fefc3a8", "type": "Port", "port_id": "1e2904ea-346a-43b6-8294-a24260a783ac", "interface_id": "28023e99-d634-4f43-a983-d3ab9405f663"}]	"Dns Server"	null	{"type": "System"}
4560266a-ca14-4221-8f96-824ea8c96c60	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.673461+00	2025-11-17 06:45:56.673461+00	Google.com	6f498fec-e813-4605-8531-3bc695cbd712	[{"id": "e43f06e3-7fd0-4c13-bfe8-24fff157cab8", "type": "Port", "port_id": "512b52d6-79a5-4584-8363-fefaf36d36f7", "interface_id": "a14fd77d-39d5-4b4c-a24b-9517671d454a"}]	"Web Service"	null	{"type": "System"}
d3c662d4-062e-49ae-a962-1a7865a94616	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.673465+00	2025-11-17 06:45:56.673465+00	Mobile Device	0b1d70c5-ca4c-4a5d-b2d8-285457d0dfc8	[{"id": "5ef4ada7-e4f8-4f13-90d2-d60e29ac9da2", "type": "Port", "port_id": "14d943a0-0f6e-445f-aaff-c7872be5c404", "interface_id": "9e3ed2d9-efa5-490c-a3f1-b3980e36b8b9"}]	"Client"	null	{"type": "System"}
5eb2069d-43e5-4cc8-8c95-1e8ec6b91ad3	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.811301+00	2025-11-17 06:45:56.811301+00	NetVisor Daemon API	b4d1f2ba-7a52-41aa-9270-a8b0c94e4441	[{"id": "d7f5c813-ddcf-4acb-979e-454449a61c7d", "type": "Port", "port_id": "54848bd0-9aa0-4967-a20b-83e45f34d69b", "interface_id": "cad5e09a-ada7-435f-87cb-99b5add0ceb1"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T06:45:56.811300852Z", "type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994"}]}
ef4eef65-beab-455f-aecc-6a17942d4f40	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:46:01.879678+00	2025-11-17 06:46:01.879678+00	NetVisor Server API	382d1f94-c22c-4705-8b1d-89c84cc6a7d3	[{"id": "32022c32-47fb-48bc-8798-6dd850e49b05", "type": "Port", "port_id": "f8539e55-4134-4104-9b91-247ac17bacdb", "interface_id": "38ad3c7d-36c3-4f10-b8b9-bd0bf7bd1b9c"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:46:01.879671403Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c4ec3c09-b0df-4a7e-89ca-8e2b82138e3a	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:46:27.793826+00	2025-11-17 06:46:27.793826+00	PostgreSQL	2ecc84da-1f64-4fad-b0c2-c92e604ca06e	[{"id": "eed05267-0362-4cdf-971c-9a4bd161402e", "type": "Port", "port_id": "81a4390d-fbab-43f4-8687-fbfdb0d12841", "interface_id": "51d6025b-ca7f-4d31-a1a4-be3b35cfa69a"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T06:46:27.793818634Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
8cd2f5e7-5bee-49ac-8a64-4295bfcc90dc	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:46:43.94774+00	2025-11-17 06:46:43.94774+00	Home Assistant	351da4c5-910e-4693-8514-f50a90c62394	[{"id": "8d07af8f-e92b-4152-8fba-7ea2ac3ce6a4", "type": "Port", "port_id": "89b492fe-1398-428b-bf9b-62752f83c65b", "interface_id": "d5084bf4-b3e1-4767-bc6b-b0a6ccd93fc5"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:46:43.947731863Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
acdce521-5d6a-4331-b697-383648a9f3e6	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:46:36.832128+00	2025-11-17 06:46:36.832128+00	NetVisor Server API	351da4c5-910e-4693-8514-f50a90c62394	[{"id": "e4ede153-ca0c-4564-8c93-8d6abbf8a948", "type": "Port", "port_id": "c2494ba5-6c87-4410-8a8f-70f07ee59136", "interface_id": "d5084bf4-b3e1-4767-bc6b-b0a6ccd93fc5"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:46:36.832120576Z", "type": "Network", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
a8a3ed94-183c-4853-8bad-6082fcb6bd96	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.673406+00	2025-11-17 06:45:56.673406+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
33621841-ef06-4fb6-83fd-9b30d658446c	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.673411+00	2025-11-17 06:45:56.673411+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
6a3d5b6a-0b2d-4f78-a448-d2fff13e7b5a	6f1b737e-aee6-4f45-b246-261d3816d4f9	2025-11-17 06:45:56.740739+00	2025-11-17 06:45:56.740739+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:45:56.740737466Z", "type": "SelfReport", "host_id": "b4d1f2ba-7a52-41aa-9270-a8b0c94e4441", "daemon_id": "f1b5ec0f-15a5-477a-8411-a5cb74057994"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
e1ca3733-b882-4411-a67b-333b9ac38455	2025-11-17 06:45:52.578314+00	2025-11-17 06:45:56.660898+00	$argon2id$v=19$m=19456,t=2,p=1$v3NWAEazfRuGaNAqLjv6jg$kg0G1U24uLr2sfJFkRd6WjPHfWyTIQvbnppqHhGnk68	\N	\N	\N	user@example.com	0add3a4c-cf0a-49c2-bd76-c50a573ab707	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
MisEv4W6FhjjeOTp-_IILg	\\x93c4102e08f2fbe9e478e31816ba85bf042b3281a7757365725f6964d92465316361333733332d623838322d343431312d613637622d33333362396163333834353599cd07e9cd015f062d38ce277aa742000000	2025-12-17 06:45:56.662349+00
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

\unrestrict l3SEJ1p0tdZdfP9GCmd3T0aq1eKfmVYPGkhej82ReDVeEDfjsouSMt75h7rMPbL

