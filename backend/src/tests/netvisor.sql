--
-- PostgreSQL database dump
--

\restrict gpEnFSSpbZAbLU7WBQoDT9fPK6RyaxgOlZEUUB52uP1YQhzaTfJUeISJjq8ve0Z

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
20251006215000	users	2025-11-17 04:36:39.15491+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3449888
20251006215100	networks	2025-11-17 04:36:39.159049+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3872874
20251006215151	create hosts	2025-11-17 04:36:39.163256+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3769058
20251006215155	create subnets	2025-11-17 04:36:39.167413+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	4053123
20251006215201	create groups	2025-11-17 04:36:39.171824+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3789827
20251006215204	create daemons	2025-11-17 04:36:39.17597+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4249513
20251006215212	create services	2025-11-17 04:36:39.180709+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4712985
20251029193448	user-auth	2025-11-17 04:36:39.185734+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3728772
20251030044828	daemon api	2025-11-17 04:36:39.189795+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1521686
20251030170438	host-hide	2025-11-17 04:36:39.191622+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1064605
20251102224919	create discovery	2025-11-17 04:36:39.192975+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9664701
20251106235621	normalize-daemon-cols	2025-11-17 04:36:39.202981+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1748673
20251107034459	api keys	2025-11-17 04:36:39.205016+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7096154
20251107222650	oidc-auth	2025-11-17 04:36:39.212423+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20491631
20251110181948	orgs-billing	2025-11-17 04:36:39.235661+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	9995294
20251113223656	group-enhancements	2025-11-17 04:36:39.245998+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1149936
20251117032720	daemon-mode	2025-11-17 04:36:39.247466+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1107285
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
d76a34fc-ef2c-4c4c-860f-e12dc99ab055	4a16a7a73aa24812a150c5fb812b793f	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	Integrated Daemon API Key	2025-11-17 04:36:43.38959+00	2025-11-17 04:37:35.474524+00	2025-11-17 04:37:35.47415+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
610f04d5-aa1b-4062-92bc-7112459ddef8	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	72bf3cf4-e3a0-4dd2-8c84-11a38b514eea	"172.25.0.4"	60073	2025-11-17 04:36:43.43986+00	2025-11-17 04:36:43.439859+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["8d390524-4e34-49fb-9d2c-27cef910b596"]}	2025-11-17 04:36:43.457205+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
6f44b1c1-c05d-45e2-afac-9c3075558f6c	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	610f04d5-aa1b-4062-92bc-7112459ddef8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea"}	Self Report @ 172.25.0.4	2025-11-17 04:36:43.441383+00	2025-11-17 04:36:43.441383+00
543e1527-7db4-4483-a01b-22f2aed5fa59	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	610f04d5-aa1b-4062-92bc-7112459ddef8	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 04:36:43.44738+00	2025-11-17 04:36:43.44738+00
9613361f-f264-4e66-8aac-9cce5b287ef0	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	610f04d5-aa1b-4062-92bc-7112459ddef8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "processed": 1, "network_id": "5e5e8bef-f567-497b-b6d4-1ac4e181f3ec", "session_id": "225c6fab-a4f3-461f-83cf-a21693f8f892", "started_at": "2025-11-17T04:36:43.447054027Z", "finished_at": "2025-11-17T04:36:43.521932586Z", "discovery_type": {"type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea"}	Discovery Run	2025-11-17 04:36:43.447054+00	2025-11-17 04:36:43.524022+00
f3705511-8593-4323-9f54-d137b50168df	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	610f04d5-aa1b-4062-92bc-7112459ddef8	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "processed": 12, "network_id": "5e5e8bef-f567-497b-b6d4-1ac4e181f3ec", "session_id": "43732e4f-c46b-4732-932e-cdfd901602b5", "started_at": "2025-11-17T04:36:43.533289643Z", "finished_at": "2025-11-17T04:37:35.473251980Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 04:36:43.533289+00	2025-11-17 04:37:35.474456+00
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
55011269-a1bf-40b0-ad88-955888267901	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "299d3964-ac7d-4c72-b3bf-abaca742dc62"}	[{"id": "0bf1ba7c-bd92-4047-972e-380481ff9f51", "name": "Internet", "subnet_id": "0e8bf873-43f0-43ae-a598-e9c5a4c07fae", "ip_address": "1.1.1.1", "mac_address": null}]	["de312135-0fa9-4171-889a-a87c12c326b7"]	[{"id": "a66e11f7-fd01-474f-a0b2-25650c5f45c9", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 04:36:43.371851+00	2025-11-17 04:36:43.380593+00	f
60b008fe-b465-4e29-b6ea-8feda5925e7e	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	Google.com	\N	\N	{"type": "ServiceBinding", "config": "edd671e4-85a1-41ae-a47e-56b8764d7a02"}	[{"id": "afd3d296-9897-413e-a36a-c034bc71d8f1", "name": "Internet", "subnet_id": "0e8bf873-43f0-43ae-a598-e9c5a4c07fae", "ip_address": "203.0.113.91", "mac_address": null}]	["36070fa6-1037-4190-8507-7913ba33877e"]	[{"id": "1a74a33b-d630-4c91-9955-d7f8eeb81066", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 04:36:43.371861+00	2025-11-17 04:36:43.385285+00	f
18640ab1-d17a-4118-84b3-e63d477aed19	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "71527720-4844-4308-8be1-e09ed36d3d1c"}	[{"id": "f33bb2be-6aed-4c82-8618-ca149a191db2", "name": "Remote Network", "subnet_id": "a550ba0c-eb9b-4fbc-9f2b-ce195bef7b27", "ip_address": "203.0.113.98", "mac_address": null}]	["53291e0e-26ff-4afe-b789-0ac1e2c7b144"]	[{"id": "3486783b-feba-4900-b12c-55503e8653cc", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 04:36:43.371869+00	2025-11-17 04:36:43.388862+00	f
78589cdd-f445-408f-b28c-92ad8cac00c2	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1d65ac0c-6930-40ff-92ab-53ac0e98d880", "name": null, "subnet_id": "8d390524-4e34-49fb-9d2c-27cef910b596", "ip_address": "172.25.0.5", "mac_address": "FA:B8:B9:6C:69:61"}]	["0c6c152a-60a3-4550-9367-881205ca6805"]	[{"id": "5e4f9606-08ed-4fa8-93f4-1ee36520d623", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:36:45.749158477Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:36:45.749159+00	2025-11-17 04:37:00.248954+00	f
abb3400e-2dc5-4a4b-a47d-becce1843a7e	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "392d06ca-75be-4e0b-8859-c8c8bc43763a", "name": null, "subnet_id": "8d390524-4e34-49fb-9d2c-27cef910b596", "ip_address": "172.25.0.6", "mac_address": "46:57:AB:DD:69:7F"}]	["51e3f25a-dd65-4ef2-ab55-bbd9ec783c7a"]	[{"id": "07a84df9-fa92-44df-81e7-adb687716ea8", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:37:00.379467355Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:37:00.379468+00	2025-11-17 04:37:14.912892+00	f
72bf3cf4-e3a0-4dd2-8c84-11a38b514eea	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	172.25.0.4	dad2394533de	NetVisor daemon	{"type": "None"}	[{"id": "f11b6c50-1d1a-40a6-89a4-e5401c2aca97", "name": "eth0", "subnet_id": "8d390524-4e34-49fb-9d2c-27cef910b596", "ip_address": "172.25.0.4", "mac_address": "12:D4:F1:04:E2:7D"}]	["fa27c756-56f8-4e9f-9173-965266188d53", "ba3b9f9e-b48c-450c-8f18-4a963ea18ccc"]	[{"id": "d1100cc7-6102-46b4-aafc-a224bc6fa05a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:36:45.737510823Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-17T04:36:43.512274435Z", "type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8"}]}	null	2025-11-17 04:36:43.396996+00	2025-11-17 04:36:45.755903+00	f
e4695557-4b76-4074-a654-b32e5db9ccd9	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "148597e9-c7fb-459f-8b00-faa7d2834427", "name": null, "subnet_id": "8d390524-4e34-49fb-9d2c-27cef910b596", "ip_address": "172.25.0.1", "mac_address": "2A:02:0B:C1:18:70"}]	["dbfa47a2-0796-48df-be94-6812ce141971", "5df0cc92-9d18-41f4-8928-0510d0e742a8"]	[{"id": "b7818b3c-e6fe-4f22-9060-5f04b1ad14fd", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "60ba8062-bd4f-41b6-9dab-09d95faa27db", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "2205df48-8431-4f33-98e2-1bebaacdff69", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:37:21.041524625Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:37:21.041527+00	2025-11-17 04:37:35.47117+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	My Network	2025-11-17 04:36:43.370392+00	2025-11-17 04:36:43.370392+00	f	e82659dd-fed2-47bd-aacb-04f396c0e55b
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
e82659dd-fed2-47bd-aacb-04f396c0e55b	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 04:36:39.302244+00	2025-11-17 04:36:43.368787+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
de312135-0fa9-4171-889a-a87c12c326b7	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.371854+00	2025-11-17 04:36:43.371854+00	Cloudflare DNS	55011269-a1bf-40b0-ad88-955888267901	[{"id": "299d3964-ac7d-4c72-b3bf-abaca742dc62", "type": "Port", "port_id": "a66e11f7-fd01-474f-a0b2-25650c5f45c9", "interface_id": "0bf1ba7c-bd92-4047-972e-380481ff9f51"}]	"Dns Server"	null	{"type": "System"}
36070fa6-1037-4190-8507-7913ba33877e	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.371863+00	2025-11-17 04:36:43.371863+00	Google.com	60b008fe-b465-4e29-b6ea-8feda5925e7e	[{"id": "edd671e4-85a1-41ae-a47e-56b8764d7a02", "type": "Port", "port_id": "1a74a33b-d630-4c91-9955-d7f8eeb81066", "interface_id": "afd3d296-9897-413e-a36a-c034bc71d8f1"}]	"Web Service"	null	{"type": "System"}
53291e0e-26ff-4afe-b789-0ac1e2c7b144	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.371871+00	2025-11-17 04:36:43.371871+00	Mobile Device	18640ab1-d17a-4118-84b3-e63d477aed19	[{"id": "71527720-4844-4308-8be1-e09ed36d3d1c", "type": "Port", "port_id": "3486783b-feba-4900-b12c-55503e8653cc", "interface_id": "f33bb2be-6aed-4c82-8618-ca149a191db2"}]	"Client"	null	{"type": "System"}
fa27c756-56f8-4e9f-9173-965266188d53	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.512292+00	2025-11-17 04:36:45.754828+00	NetVisor Daemon API	72bf3cf4-e3a0-4dd2-8c84-11a38b514eea	[{"id": "a2b6fded-41ea-4af5-b7bf-899aad0dce24", "type": "Port", "port_id": "d1100cc7-6102-46b4-aafc-a224bc6fa05a", "interface_id": "f11b6c50-1d1a-40a6-89a4-e5401c2aca97"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T04:36:45.738108297Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-17T04:36:43.512292159Z", "type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8"}]}
0c6c152a-60a3-4550-9367-881205ca6805	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:47.258086+00	2025-11-17 04:36:47.258086+00	Home Assistant	78589cdd-f445-408f-b28c-92ad8cac00c2	[{"id": "d0b74b79-532b-48eb-b0e6-94b07a488d62", "type": "Port", "port_id": "5e4f9606-08ed-4fa8-93f4-1ee36520d623", "interface_id": "1d65ac0c-6930-40ff-92ab-53ac0e98d880"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:36:47.258075397Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
51e3f25a-dd65-4ef2-ab55-bbd9ec783c7a	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:37:14.881103+00	2025-11-17 04:37:14.881103+00	PostgreSQL	abb3400e-2dc5-4a4b-a47d-becce1843a7e	[{"id": "7197268c-d2fe-4759-b940-aa5db4e5fb5b", "type": "Port", "port_id": "07a84df9-fa92-44df-81e7-adb687716ea8", "interface_id": "392d06ca-75be-4e0b-8859-c8c8bc43763a"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T04:37:14.881094748Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
dbfa47a2-0796-48df-be94-6812ce141971	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:37:22.486897+00	2025-11-17 04:37:22.486897+00	Home Assistant	e4695557-4b76-4074-a654-b32e5db9ccd9	[{"id": "71ff1fe9-9242-4d21-a948-6e8f4b6f5661", "type": "Port", "port_id": "b7818b3c-e6fe-4f22-9060-5f04b1ad14fd", "interface_id": "148597e9-c7fb-459f-8b00-faa7d2834427"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:37:22.486886822Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5df0cc92-9d18-41f4-8928-0510d0e742a8	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:37:30.440272+00	2025-11-17 04:37:30.440272+00	NetVisor Server API	e4695557-4b76-4074-a654-b32e5db9ccd9	[{"id": "9a3b9851-644b-4e66-b91a-f1e0d089a60a", "type": "Port", "port_id": "60ba8062-bd4f-41b6-9dab-09d95faa27db", "interface_id": "148597e9-c7fb-459f-8b00-faa7d2834427"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:37:30.440263065Z", "type": "Network", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
0e8bf873-43f0-43ae-a598-e9c5a4c07fae	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.371791+00	2025-11-17 04:36:43.371791+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
a550ba0c-eb9b-4fbc-9f2b-ce195bef7b27	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.371796+00	2025-11-17 04:36:43.371796+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
8d390524-4e34-49fb-9d2c-27cef910b596	5e5e8bef-f567-497b-b6d4-1ac4e181f3ec	2025-11-17 04:36:43.4472+00	2025-11-17 04:36:43.4472+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:36:43.447199420Z", "type": "SelfReport", "host_id": "72bf3cf4-e3a0-4dd2-8c84-11a38b514eea", "daemon_id": "610f04d5-aa1b-4062-92bc-7112459ddef8"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
4df2e3cb-16fc-4b91-97fb-b8810862a40c	2025-11-17 04:36:39.304284+00	2025-11-17 04:36:43.357113+00	$argon2id$v=19$m=19456,t=2,p=1$QWbVSydESHQR/ure6duHVw$yYXy/zJ/kAyF7RodesA6epXLhDSBkbxjJOmper1VUtE	\N	\N	\N	user@example.com	e82659dd-fed2-47bd-aacb-04f396c0e55b	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
Jnh67pyny4WimcHjLk95bw	\\x93c4106f794f2ee3c199a285cba79cee7a782681a7757365725f6964d92434646632653363622d313666632d346239312d393766622d62383831303836326134306399cd07e9cd015f04242bce15614255000000	2025-12-17 04:36:43.358695+00
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

\unrestrict gpEnFSSpbZAbLU7WBQoDT9fPK6RyaxgOlZEUUB52uP1YQhzaTfJUeISJjq8ve0Z

