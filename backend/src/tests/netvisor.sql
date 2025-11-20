--
-- PostgreSQL database dump
--

\restrict lAZKgSAeM5hq62C1gqi2XwedG103NUJLKDgNJYiEQyRVHgLbbzWsShfqwVIjEzP

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
20251006215000	users	2025-11-19 23:32:54.300542+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3390316
20251006215100	networks	2025-11-19 23:32:54.30461+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3713737
20251006215151	create hosts	2025-11-19 23:32:54.308648+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3762878
20251006215155	create subnets	2025-11-19 23:32:54.312737+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3564590
20251006215201	create groups	2025-11-19 23:32:54.316652+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3708206
20251006215204	create daemons	2025-11-19 23:32:54.320694+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4278937
20251006215212	create services	2025-11-19 23:32:54.32532+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4883509
20251029193448	user-auth	2025-11-19 23:32:54.330535+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3470214
20251030044828	daemon api	2025-11-19 23:32:54.334316+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1676323
20251030170438	host-hide	2025-11-19 23:32:54.336288+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1076640
20251102224919	create discovery	2025-11-19 23:32:54.337666+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9268893
20251106235621	normalize-daemon-cols	2025-11-19 23:32:54.347274+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	2522124
20251107034459	api keys	2025-11-19 23:32:54.350094+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	10725899
20251107222650	oidc-auth	2025-11-19 23:32:54.36118+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20024548
20251110181948	orgs-billing	2025-11-19 23:32:54.381546+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10027372
20251113223656	group-enhancements	2025-11-19 23:32:54.391931+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	993434
20251117032720	daemon-mode	2025-11-19 23:32:54.393217+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1093611
20251118143058	set-default-plan	2025-11-19 23:32:54.394615+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1264388
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
d0e5e6b5-e66b-48bd-8c0c-26b5247ac930	0e065bb45698437d8f85d3c11cde6626	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	Integrated Daemon API Key	2025-11-19 23:32:57.127527+00	2025-11-19 23:34:04.51201+00	2025-11-19 23:34:04.511636+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
62c6aac2-3f4c-41e7-a741-d0be2d8c0db0	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	7196b058-3317-4da1-a13e-09e60d5cc77c	"172.25.0.4"	60073	2025-11-19 23:32:57.179357+00	2025-11-19 23:32:57.179355+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933"]}	2025-11-19 23:32:57.197292+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
d8d9b387-25f8-4d1f-8b7e-406ffefbbc83	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	62c6aac2-3f4c-41e7-a741-d0be2d8c0db0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c"}	Self Report @ 172.25.0.4	2025-11-19 23:32:57.180718+00	2025-11-19 23:32:57.180718+00
aa979531-b8a5-4328-9eb1-1f89eabee4bf	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	62c6aac2-3f4c-41e7-a741-d0be2d8c0db0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-19 23:32:57.187198+00	2025-11-19 23:32:57.187198+00
dfb94381-7591-43b8-80a9-f955d78adffc	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	62c6aac2-3f4c-41e7-a741-d0be2d8c0db0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "processed": 1, "network_id": "f94407b3-bad9-4338-bbfc-7ad5cb0c039a", "session_id": "e64dc3d6-7b23-4440-9b9d-1255129bb1d4", "started_at": "2025-11-19T23:32:57.186849674Z", "finished_at": "2025-11-19T23:32:57.243744495Z", "discovery_type": {"type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c"}	Discovery Run	2025-11-19 23:32:57.186849+00	2025-11-19 23:32:57.245121+00
12a9c028-f621-49cb-9502-ac54d1469ade	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	62c6aac2-3f4c-41e7-a741-d0be2d8c0db0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "processed": 11, "network_id": "f94407b3-bad9-4338-bbfc-7ad5cb0c039a", "session_id": "807e651e-0783-421d-9f47-359d5e1db5f0", "started_at": "2025-11-19T23:32:57.252659275Z", "finished_at": "2025-11-19T23:34:04.510764904Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-19 23:32:57.252659+00	2025-11-19 23:34:04.511941+00
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
c1584db9-398b-4eaf-99f1-601481685fcf	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "7f6f10ee-a546-4b63-885b-dc4ba3852ac2"}	[{"id": "0da9276e-38f0-4cd2-9ec2-d829d3a47fc7", "name": "Internet", "subnet_id": "af6fe772-b27b-4aa9-bea2-9cdff1d452f4", "ip_address": "1.1.1.1", "mac_address": null}]	["beefc1ab-f7d3-475c-bacb-55c1e2497548"]	[{"id": "3dbee162-0264-4bdd-870b-c55537e2fd4d", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-19 23:32:57.109555+00	2025-11-19 23:32:57.118236+00	f
1ed19ab2-8571-4866-8294-e878d2b72490	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	Google.com	\N	\N	{"type": "ServiceBinding", "config": "e7f3eb32-56a8-4e89-8a8f-be208de56fe3"}	[{"id": "f58135c7-8cd8-483d-9598-19a21aa387af", "name": "Internet", "subnet_id": "af6fe772-b27b-4aa9-bea2-9cdff1d452f4", "ip_address": "203.0.113.221", "mac_address": null}]	["0b16f609-0a4b-4c34-ba35-7361238d04c2"]	[{"id": "0fdf3e3e-9427-4f9c-bc51-e72d497d8b21", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 23:32:57.109561+00	2025-11-19 23:32:57.123063+00	f
c966e55e-1d55-45ba-9834-4913a01d97c3	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "fe66aebf-7c08-4412-a17e-5343518e3b47"}	[{"id": "58c8bff4-cff6-4fa9-9c69-c2152a8237f8", "name": "Remote Network", "subnet_id": "97a944fb-691b-4109-bcc0-c559d282133c", "ip_address": "203.0.113.8", "mac_address": null}]	["8dd44f7b-c5e9-4b5b-bda0-2ec8a24a5d51"]	[{"id": "bb49dd89-3d8f-4f06-bcd1-7f58eacb5dcc", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-19 23:32:57.109566+00	2025-11-19 23:32:57.126768+00	f
37f494eb-eec7-48f6-a466-1ddf7b965300	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c2c0c2b9-b6ef-4324-860e-eb4023dcd0c2", "name": null, "subnet_id": "f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933", "ip_address": "172.25.0.5", "mac_address": "32:5B:68:7A:33:86"}]	["ab847e05-4db2-43b5-bc80-c8c4b2e280bd"]	[{"id": "5d713bf4-24d7-4c5e-a33b-f2825d427dd0", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:33:14.173425530Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 23:33:14.173428+00	2025-11-19 23:33:28.843367+00	f
9b3dcca7-c0b2-4b50-9bdc-5050ccf00d0d	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1b4c4739-c0e6-4a0b-a1fd-c43cbde68610", "name": null, "subnet_id": "f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933", "ip_address": "172.25.0.6", "mac_address": "C6:67:1C:A0:F1:40"}]	["2f06a2aa-5ff7-4724-9c12-afe70799ddc4"]	[{"id": "6464217a-c686-402d-9a7d-782e5373e1e5", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:33:28.964846546Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 23:33:28.964848+00	2025-11-19 23:33:43.605204+00	f
452b8825-df24-4cff-a34a-9a665be361da	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "20473b35-d764-4bf7-b04d-f5c150cf0809", "name": null, "subnet_id": "f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933", "ip_address": "172.25.0.3", "mac_address": "3E:1C:F4:AD:D6:76"}]	["be06478c-8e68-486e-b3d9-4556f302cbf2"]	[{"id": "7dc1169e-8843-4967-8adb-0acfb2097542", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:32:59.483076353Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 23:32:59.483079+00	2025-11-19 23:33:28.836141+00	f
7196b058-3317-4da1-a13e-09e60d5cc77c	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	172.25.0.4	51afe52ff83c	NetVisor daemon	{"type": "None"}	[{"id": "d64dd9a2-5754-4155-8a4d-b8e92d2b05ea", "name": "eth0", "subnet_id": "f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933", "ip_address": "172.25.0.4", "mac_address": "AA:D9:C9:5D:EA:7C"}]	["0a899c93-e5bb-4946-a7d3-2f6515fa6a84", "f9349ce3-029a-4bb6-80be-11a655edebd9"]	[{"id": "6f00174f-9d7b-425b-a485-97ef386b13e4", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:33:28.828039811Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T23:32:57.198827308Z", "type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0"}]}	null	2025-11-19 23:32:57.134954+00	2025-11-19 23:33:28.964742+00	f
f42af7f7-70df-4d6b-bffa-50036f9ca2f6	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "b88b0983-8764-4cba-8f05-7beca2a6c8f3", "name": null, "subnet_id": "f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933", "ip_address": "172.25.0.1", "mac_address": "5E:BC:E8:72:DC:DF"}]	["51dd2367-719d-487f-b8f4-13e080201e06", "36e28abf-480f-4bef-979e-f0f4787a3ea7"]	[{"id": "baec9eb9-9de4-42f3-afcd-90394a238f66", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "175145cf-b572-48e2-bb7f-dbb6794a41e7", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "18a94eec-8ffb-48ce-b1df-91823c9416b5", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:33:49.758874400Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-19 23:33:49.758877+00	2025-11-19 23:34:04.508326+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
f94407b3-bad9-4338-bbfc-7ad5cb0c039a	My Network	2025-11-19 23:32:57.108153+00	2025-11-19 23:32:57.108153+00	f	3ad46102-4f4d-416b-a29b-02929af141f9
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
3ad46102-4f4d-416b-a29b-02929af141f9	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-19 23:32:54.45019+00	2025-11-19 23:32:57.106667+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
beefc1ab-f7d3-475c-bacb-55c1e2497548	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.109557+00	2025-11-19 23:32:57.109557+00	Cloudflare DNS	c1584db9-398b-4eaf-99f1-601481685fcf	[{"id": "7f6f10ee-a546-4b63-885b-dc4ba3852ac2", "type": "Port", "port_id": "3dbee162-0264-4bdd-870b-c55537e2fd4d", "interface_id": "0da9276e-38f0-4cd2-9ec2-d829d3a47fc7"}]	"Dns Server"	null	{"type": "System"}
0b16f609-0a4b-4c34-ba35-7361238d04c2	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.109562+00	2025-11-19 23:32:57.109562+00	Google.com	1ed19ab2-8571-4866-8294-e878d2b72490	[{"id": "e7f3eb32-56a8-4e89-8a8f-be208de56fe3", "type": "Port", "port_id": "0fdf3e3e-9427-4f9c-bc51-e72d497d8b21", "interface_id": "f58135c7-8cd8-483d-9598-19a21aa387af"}]	"Web Service"	null	{"type": "System"}
8dd44f7b-c5e9-4b5b-bda0-2ec8a24a5d51	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.109568+00	2025-11-19 23:32:57.109568+00	Mobile Device	c966e55e-1d55-45ba-9834-4913a01d97c3	[{"id": "fe66aebf-7c08-4412-a17e-5343518e3b47", "type": "Port", "port_id": "bb49dd89-3d8f-4f06-bcd1-7f58eacb5dcc", "interface_id": "58c8bff4-cff6-4fa9-9c69-c2152a8237f8"}]	"Client"	null	{"type": "System"}
be06478c-8e68-486e-b3d9-4556f302cbf2	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:33:03.967735+00	2025-11-19 23:33:03.967735+00	NetVisor Server API	452b8825-df24-4cff-a34a-9a665be361da	[{"id": "a8855bb6-c323-4257-aec8-98f0ac1d624c", "type": "Port", "port_id": "7dc1169e-8843-4967-8adb-0acfb2097542", "interface_id": "20473b35-d764-4bf7-b04d-f5c150cf0809"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T23:33:03.967725548Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ab847e05-4db2-43b5-bc80-c8c4b2e280bd	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:33:28.82684+00	2025-11-19 23:33:28.82684+00	Home Assistant	37f494eb-eec7-48f6-a466-1ddf7b965300	[{"id": "2ccdbf0a-afc0-4b9d-a003-72073427374e", "type": "Port", "port_id": "5d713bf4-24d7-4c5e-a33b-f2825d427dd0", "interface_id": "c2c0c2b9-b6ef-4324-860e-eb4023dcd0c2"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T23:33:28.826830967Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
0a899c93-e5bb-4946-a7d3-2f6515fa6a84	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.198842+00	2025-11-19 23:33:28.963604+00	NetVisor Daemon API	7196b058-3317-4da1-a13e-09e60d5cc77c	[{"id": "41807ed9-b8c3-4913-b87f-ae278b41796a", "type": "Port", "port_id": "6f00174f-9d7b-425b-a485-97ef386b13e4", "interface_id": "d64dd9a2-5754-4155-8a4d-b8e92d2b05ea"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-19T23:33:28.828505906Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-19T23:32:57.198841074Z", "type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0"}]}
2f06a2aa-5ff7-4724-9c12-afe70799ddc4	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:33:43.596871+00	2025-11-19 23:33:43.596871+00	PostgreSQL	9b3dcca7-c0b2-4b50-9bdc-5050ccf00d0d	[{"id": "60d12f22-c4fc-4a87-8bf1-d182ea0d0c75", "type": "Port", "port_id": "6464217a-c686-402d-9a7d-782e5373e1e5", "interface_id": "1b4c4739-c0e6-4a0b-a1fd-c43cbde68610"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-19T23:33:43.596861453Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
36e28abf-480f-4bef-979e-f0f4787a3ea7	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:34:04.500524+00	2025-11-19 23:34:04.500524+00	Home Assistant	f42af7f7-70df-4d6b-bffa-50036f9ca2f6	[{"id": "aea0def9-a8cd-4cdd-a76e-a7c16958ed4b", "type": "Port", "port_id": "175145cf-b572-48e2-bb7f-dbb6794a41e7", "interface_id": "b88b0983-8764-4cba-8f05-7beca2a6c8f3"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T23:34:04.500514477Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
51dd2367-719d-487f-b8f4-13e080201e06	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:33:54.154381+00	2025-11-19 23:33:54.154381+00	NetVisor Server API	f42af7f7-70df-4d6b-bffa-50036f9ca2f6	[{"id": "a04f4c13-f58b-4052-9b23-ca717a445a70", "type": "Port", "port_id": "baec9eb9-9de4-42f3-afcd-90394a238f66", "interface_id": "b88b0983-8764-4cba-8f05-7beca2a6c8f3"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-19T23:33:54.154371621Z", "type": "Network", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
af6fe772-b27b-4aa9-bea2-9cdff1d452f4	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.109487+00	2025-11-19 23:32:57.109487+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
97a944fb-691b-4109-bcc0-c559d282133c	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.109492+00	2025-11-19 23:32:57.109492+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
f9f59dd7-2e67-4e82-aa8b-3d9d5d2e5933	f94407b3-bad9-4338-bbfc-7ad5cb0c039a	2025-11-19 23:32:57.187036+00	2025-11-19 23:32:57.187036+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-19T23:32:57.187034588Z", "type": "SelfReport", "host_id": "7196b058-3317-4da1-a13e-09e60d5cc77c", "daemon_id": "62c6aac2-3f4c-41e7-a741-d0be2d8c0db0"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
239a134c-0972-4dfc-a10f-3444b123274d	2025-11-19 23:32:54.452081+00	2025-11-19 23:32:57.09543+00	$argon2id$v=19$m=19456,t=2,p=1$dshwmj4/NJa9HtNMU5+97g$DvuKqyxJjID2O6Va7x75k1/Zm2j2sT89f3mI4xYhzBM	\N	\N	\N	user@example.com	3ad46102-4f4d-416b-a29b-02929af141f9	Owner
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
WzPPyVr6bc0V9Jym1f3GSA	\\x93c41048c6fdd5a69cf415cd6dfa5ac9cf335b81a7757365725f6964d92432333961313334632d303937322d346466632d613130662d33343434623132333237346499cd07e9cd0161172039ce05c6c1d3000000	2025-12-19 23:32:57.096911+00
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

\unrestrict lAZKgSAeM5hq62C1gqi2XwedG103NUJLKDgNJYiEQyRVHgLbbzWsShfqwVIjEzP

