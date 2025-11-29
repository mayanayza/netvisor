--
-- PostgreSQL database dump
--

\restrict F2vK3XunDnw8taQgbeH4yB2qVwoNSLM7voZayvZSYMAqumGJHhEGvwl21Hw3zbP

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
20251006215000	users	2025-11-29 23:22:33.513552+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3773210
20251006215100	networks	2025-11-29 23:22:33.518097+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4050629
20251006215151	create hosts	2025-11-29 23:22:33.522512+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3986346
20251006215155	create subnets	2025-11-29 23:22:33.526836+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3793991
20251006215201	create groups	2025-11-29 23:22:33.531001+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	4087696
20251006215204	create daemons	2025-11-29 23:22:33.535466+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4178303
20251006215212	create services	2025-11-29 23:22:33.540071+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5062710
20251029193448	user-auth	2025-11-29 23:22:33.545452+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3839596
20251030044828	daemon api	2025-11-29 23:22:33.549605+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1547754
20251030170438	host-hide	2025-11-29 23:22:33.55146+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1099114
20251102224919	create discovery	2025-11-29 23:22:33.552842+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9927472
20251106235621	normalize-daemon-cols	2025-11-29 23:22:33.563099+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1787388
20251107034459	api keys	2025-11-29 23:22:33.565187+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7716871
20251107222650	oidc-auth	2025-11-29 23:22:33.573261+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	22153939
20251110181948	orgs-billing	2025-11-29 23:22:33.595777+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11045672
20251113223656	group-enhancements	2025-11-29 23:22:33.60716+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	2161791
20251117032720	daemon-mode	2025-11-29 23:22:33.60965+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1307560
20251118143058	set-default-plan	2025-11-29 23:22:33.611273+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1217272
20251118225043	save-topology	2025-11-29 23:22:33.612781+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	9230954
20251123232748	network-permissions	2025-11-29 23:22:33.622381+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2814028
20251125001342	billing-updates	2025-11-29 23:22:33.625505+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	942925
20251128035448	org-onboarding-status	2025-11-29 23:22:33.626731+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1436027
20251129180942	nfs-consolidate	2025-11-29 23:22:33.628453+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1276753
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
58bb3384-7942-4567-88f3-027a8c54f543	9dbb30bc36654500aa882ec96ed3d10e	b973c09c-1c96-4efd-a957-a13fe38237c0	Integrated Daemon API Key	2025-11-29 23:22:36.592295+00	2025-11-29 23:23:30.335728+00	2025-11-29 23:23:30.334762+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
bb297910-ddc1-490d-b816-ef23ca839191	b973c09c-1c96-4efd-a957-a13fe38237c0	3ac282b1-5d35-463c-bb37-5d955c02d902	"172.25.0.4"	60073	2025-11-29 23:22:36.688512+00	2025-11-29 23:22:36.68851+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8"]}	2025-11-29 23:22:36.766892+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
9776dfd7-0ff1-4852-97a1-104c7bc09ae8	b973c09c-1c96-4efd-a957-a13fe38237c0	bb297910-ddc1-490d-b816-ef23ca839191	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902"}	Self Report @ 172.25.0.4	2025-11-29 23:22:36.698942+00	2025-11-29 23:22:36.698942+00
486e5bd7-3377-464f-bf53-f67d762742b5	b973c09c-1c96-4efd-a957-a13fe38237c0	bb297910-ddc1-490d-b816-ef23ca839191	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-29 23:22:36.708831+00	2025-11-29 23:22:36.708831+00
374e2280-058d-406f-a7be-c61bc0460d17	b973c09c-1c96-4efd-a957-a13fe38237c0	bb297910-ddc1-490d-b816-ef23ca839191	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "processed": 1, "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "session_id": "624e0449-fbda-43c4-9fd3-b1c29938e5ca", "started_at": "2025-11-29T23:22:36.708432637Z", "finished_at": "2025-11-29T23:22:36.780545194Z", "discovery_type": {"type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902"}	Discovery Run	2025-11-29 23:22:36.708432+00	2025-11-29 23:22:36.783048+00
269bda68-72ae-45f0-8866-620babf31ffd	b973c09c-1c96-4efd-a957-a13fe38237c0	bb297910-ddc1-490d-b816-ef23ca839191	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "processed": 12, "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "session_id": "6976fa1b-593e-402a-a970-1a9fcb0d763f", "started_at": "2025-11-29T23:22:36.794288273Z", "finished_at": "2025-11-29T23:23:30.332796206Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-29 23:22:36.794288+00	2025-11-29 23:23:30.335117+00
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
e564561d-88fd-41cd-ac58-0e2ba9b66bd2	b973c09c-1c96-4efd-a957-a13fe38237c0	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "b2aad216-5d75-48ed-a54b-a6a0fa0b1cf4"}	[{"id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f", "name": "Internet", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "ip_address": "1.1.1.1", "mac_address": null}]	{5202dd68-3391-425c-ba4d-450f74905107}	[{"id": "6e20051b-7d59-4c96-8ec7-7d21b7967bfd", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-29 23:22:36.566876+00	2025-11-29 23:22:36.575926+00	f
a1803165-62e2-4963-a37e-86249eee0efc	b973c09c-1c96-4efd-a957-a13fe38237c0	Google.com	\N	\N	{"type": "ServiceBinding", "config": "46c87dbd-7452-40b0-ad5b-4dba25975bb1"}	[{"id": "17873443-bb94-4a83-859b-7ded06fccd0f", "name": "Internet", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "ip_address": "203.0.113.16", "mac_address": null}]	{bed65b7a-6f6c-4e2a-a01d-499afdac8174}	[{"id": "69282c32-670c-44ea-8a89-7f4a778a7c1d", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-29 23:22:36.566885+00	2025-11-29 23:22:36.581122+00	f
57c82c33-5a65-4d05-9bee-6751e1a8cf2e	b973c09c-1c96-4efd-a957-a13fe38237c0	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "07f04e36-fddc-4875-9918-913a20a2e963"}	[{"id": "b8ea1093-5ea8-4611-b284-b148c81bc770", "name": "Remote Network", "subnet_id": "398f7931-2dd0-4beb-8269-a255ce747f84", "ip_address": "203.0.113.175", "mac_address": null}]	{805ac58d-1270-4b4f-93b7-e4b7a3db4068}	[{"id": "5c440ff6-4489-47b3-a160-fee19cd135ab", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-29 23:22:36.566892+00	2025-11-29 23:22:36.585208+00	f
ea6633f7-b46e-4491-98ca-0d6c0978bddb	b973c09c-1c96-4efd-a957-a13fe38237c0	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "7fde6641-978a-47ee-9306-6a57b13612b3", "name": null, "subnet_id": "8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8", "ip_address": "172.25.0.3", "mac_address": "E2:5E:79:44:8B:C8"}]	{29a2a8bd-0860-4364-a6a5-5048df0c8673}	[{"id": "219174b4-8c0d-4795-b830-5fad276d647b", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T23:22:38.952958440Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 23:22:38.952961+00	2025-11-29 23:22:53.862767+00	f
a9ba3d93-bce8-49f1-89c6-7ea8ebdbeae8	b973c09c-1c96-4efd-a957-a13fe38237c0	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "99c19595-2c47-43b7-9ba8-edcd7a52689b", "name": null, "subnet_id": "8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8", "ip_address": "172.25.0.6", "mac_address": "F6:33:2E:24:EC:49"}]	{ab387e10-28f1-487a-9780-3b9aed9eadbe}	[{"id": "245e7e54-7c27-46e2-a988-1cf9bbba0b80", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T23:22:54.026308789Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 23:22:54.026311+00	2025-11-29 23:23:08.973625+00	f
3ac282b1-5d35-463c-bb37-5d955c02d902	b973c09c-1c96-4efd-a957-a13fe38237c0	172.25.0.4	82a3d157bbab	NetVisor daemon	{"type": "None"}	[{"id": "bce798f9-d515-4597-99d7-c499ef5fb84b", "name": "eth0", "subnet_id": "8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8", "ip_address": "172.25.0.4", "mac_address": "3A:CE:D8:6B:07:E3"}]	{60a3f820-5146-41a6-bdba-b84a06226d05,a89d4de2-794f-41a9-8dfc-54d729c0ddfe}	[{"id": "ebf978d9-bcda-4086-9254-6be45bbe146d", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T23:22:38.896252737Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-29T23:22:36.768742598Z", "type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191"}]}	null	2025-11-29 23:22:36.601487+00	2025-11-29 23:22:38.904987+00	f
03605206-f2dc-48db-9072-5e8ad4eb2254	b973c09c-1c96-4efd-a957-a13fe38237c0	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "ce61af50-4be9-4a31-9479-a3f6dff64656", "name": null, "subnet_id": "8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8", "ip_address": "172.25.0.1", "mac_address": "02:8D:80:27:FE:0B"}]	{7bd4d0d3-a935-45e0-b98b-9a3852485694,c257137f-4e51-4c59-8279-030580f0666f}	[{"id": "d2b0ca1e-9259-4882-95f3-c243f5bd6e81", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ff03ae86-ee69-4e2b-8f2c-8cbda68f95ac", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "160ddc6f-9a16-4e5e-86c4-6d1e618380fe", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T23:23:15.129114234Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 23:23:15.129117+00	2025-11-29 23:23:30.330344+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
b973c09c-1c96-4efd-a957-a13fe38237c0	My Network	2025-11-29 23:22:36.565566+00	2025-11-29 23:22:36.565566+00	f	38d48741-b969-4dd5-b22f-38a2dcf66d5e
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
38d48741-b969-4dd5-b22f-38a2dcf66d5e	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-29 23:22:33.686104+00	2025-11-29 23:22:36.698035+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
5202dd68-3391-425c-ba4d-450f74905107	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.566879+00	2025-11-29 23:22:36.566879+00	Cloudflare DNS	e564561d-88fd-41cd-ac58-0e2ba9b66bd2	[{"id": "b2aad216-5d75-48ed-a54b-a6a0fa0b1cf4", "type": "Port", "port_id": "6e20051b-7d59-4c96-8ec7-7d21b7967bfd", "interface_id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f"}]	"Dns Server"	null	{"type": "System"}
bed65b7a-6f6c-4e2a-a01d-499afdac8174	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.566887+00	2025-11-29 23:22:36.566887+00	Google.com	a1803165-62e2-4963-a37e-86249eee0efc	[{"id": "46c87dbd-7452-40b0-ad5b-4dba25975bb1", "type": "Port", "port_id": "69282c32-670c-44ea-8a89-7f4a778a7c1d", "interface_id": "17873443-bb94-4a83-859b-7ded06fccd0f"}]	"Web Service"	null	{"type": "System"}
805ac58d-1270-4b4f-93b7-e4b7a3db4068	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.566893+00	2025-11-29 23:22:36.566893+00	Mobile Device	57c82c33-5a65-4d05-9bee-6751e1a8cf2e	[{"id": "07f04e36-fddc-4875-9918-913a20a2e963", "type": "Port", "port_id": "5c440ff6-4489-47b3-a160-fee19cd135ab", "interface_id": "b8ea1093-5ea8-4611-b284-b148c81bc770"}]	"Client"	null	{"type": "System"}
60a3f820-5146-41a6-bdba-b84a06226d05	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.768759+00	2025-11-29 23:22:38.903859+00	NetVisor Daemon API	3ac282b1-5d35-463c-bb37-5d955c02d902	[{"id": "abe4aced-af0a-4102-8b8d-7b12d0ad86ae", "type": "Port", "port_id": "ebf978d9-bcda-4086-9254-6be45bbe146d", "interface_id": "bce798f9-d515-4597-99d7-c499ef5fb84b"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-29T23:22:38.896748354Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-29T23:22:36.768758077Z", "type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191"}]}
29a2a8bd-0860-4364-a6a5-5048df0c8673	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:49.392211+00	2025-11-29 23:22:49.392211+00	NetVisor Server API	ea6633f7-b46e-4491-98ca-0d6c0978bddb	[{"id": "ac4dcda6-d4ea-4f8e-82b6-e18ab3002554", "type": "Port", "port_id": "219174b4-8c0d-4795-b830-5fad276d647b", "interface_id": "7fde6641-978a-47ee-9306-6a57b13612b3"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T23:22:49.392203064Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ab387e10-28f1-487a-9780-3b9aed9eadbe	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:23:08.963875+00	2025-11-29 23:23:08.963875+00	PostgreSQL	a9ba3d93-bce8-49f1-89c6-7ea8ebdbeae8	[{"id": "54b56739-bb24-4713-8510-b2be267203de", "type": "Port", "port_id": "245e7e54-7c27-46e2-a988-1cf9bbba0b80", "interface_id": "99c19595-2c47-43b7-9ba8-edcd7a52689b"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-29T23:23:08.963866457Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
c257137f-4e51-4c59-8279-030580f0666f	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:23:25.811699+00	2025-11-29 23:23:25.811699+00	NetVisor Server API	03605206-f2dc-48db-9072-5e8ad4eb2254	[{"id": "226d38a0-7f9b-4f41-94d5-53b9d8a99e83", "type": "Port", "port_id": "ff03ae86-ee69-4e2b-8f2c-8cbda68f95ac", "interface_id": "ce61af50-4be9-4a31-9479-a3f6dff64656"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T23:23:25.811691051Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7bd4d0d3-a935-45e0-b98b-9a3852485694	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:23:23.518276+00	2025-11-29 23:23:23.518276+00	Home Assistant	03605206-f2dc-48db-9072-5e8ad4eb2254	[{"id": "2ab4cf16-09d1-40bc-a1f4-34187eb55bac", "type": "Port", "port_id": "d2b0ca1e-9259-4882-95f3-c243f5bd6e81", "interface_id": "ce61af50-4be9-4a31-9479-a3f6dff64656"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T23:23:23.518269347Z", "type": "Network", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.566818+00	2025-11-29 23:22:36.566818+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
398f7931-2dd0-4beb-8269-a255ce747f84	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.566821+00	2025-11-29 23:22:36.566821+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8	b973c09c-1c96-4efd-a957-a13fe38237c0	2025-11-29 23:22:36.70861+00	2025-11-29 23:22:36.70861+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-29T23:22:36.708608352Z", "type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
a6eaa033-9eb2-40a5-b1e6-1e8ba58be54d	b973c09c-1c96-4efd-a957-a13fe38237c0	My Topology	[]	[{"id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "398f7931-2dd0-4beb-8269-a255ce747f84", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "b8ea1093-5ea8-4611-b284-b148c81bc770", "size": {"x": 250, "y": 100}, "header": null, "host_id": "57c82c33-5a65-4d05-9bee-6751e1a8cf2e", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "398f7931-2dd0-4beb-8269-a255ce747f84", "interface_id": "b8ea1093-5ea8-4611-b284-b148c81bc770"}, {"id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "e564561d-88fd-41cd-ac58-0e2ba9b66bd2", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "interface_id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f"}, {"id": "17873443-bb94-4a83-859b-7ded06fccd0f", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a1803165-62e2-4963-a37e-86249eee0efc", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "interface_id": "17873443-bb94-4a83-859b-7ded06fccd0f"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "e564561d-88fd-41cd-ac58-0e2ba9b66bd2", "name": "Cloudflare DNS", "ports": [{"id": "6e20051b-7d59-4c96-8ec7-7d21b7967bfd", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "b2aad216-5d75-48ed-a54b-a6a0fa0b1cf4"}, "hostname": null, "services": ["5202dd68-3391-425c-ba4d-450f74905107"], "created_at": "2025-11-29T23:22:36.566876Z", "interfaces": [{"id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f", "name": "Internet", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.575926Z", "description": null, "virtualization": null}, {"id": "a1803165-62e2-4963-a37e-86249eee0efc", "name": "Google.com", "ports": [{"id": "69282c32-670c-44ea-8a89-7f4a778a7c1d", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "46c87dbd-7452-40b0-ad5b-4dba25975bb1"}, "hostname": null, "services": ["bed65b7a-6f6c-4e2a-a01d-499afdac8174"], "created_at": "2025-11-29T23:22:36.566885Z", "interfaces": [{"id": "17873443-bb94-4a83-859b-7ded06fccd0f", "name": "Internet", "subnet_id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "ip_address": "203.0.113.16", "mac_address": null}], "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.581122Z", "description": null, "virtualization": null}, {"id": "57c82c33-5a65-4d05-9bee-6751e1a8cf2e", "name": "Mobile Device", "ports": [{"id": "5c440ff6-4489-47b3-a160-fee19cd135ab", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "07f04e36-fddc-4875-9918-913a20a2e963"}, "hostname": null, "services": ["805ac58d-1270-4b4f-93b7-e4b7a3db4068"], "created_at": "2025-11-29T23:22:36.566892Z", "interfaces": [{"id": "b8ea1093-5ea8-4611-b284-b148c81bc770", "name": "Remote Network", "subnet_id": "398f7931-2dd0-4beb-8269-a255ce747f84", "ip_address": "203.0.113.175", "mac_address": null}], "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.585208Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "9f7f44b4-c9f0-4777-aa45-0b6bacfe66e2", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-29T23:22:36.566818Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.566818Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "398f7931-2dd0-4beb-8269-a255ce747f84", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-29T23:22:36.566821Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.566821Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "8f0e67c6-5110-4e41-9bcb-ba6f5af8d7b8", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-29T23:22:36.708608352Z", "type": "SelfReport", "host_id": "3ac282b1-5d35-463c-bb37-5d955c02d902", "daemon_id": "bb297910-ddc1-490d-b816-ef23ca839191"}]}, "created_at": "2025-11-29T23:22:36.708610Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.708610Z", "description": null, "subnet_type": "Lan"}]	[{"id": "5202dd68-3391-425c-ba4d-450f74905107", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "e564561d-88fd-41cd-ac58-0e2ba9b66bd2", "bindings": [{"id": "b2aad216-5d75-48ed-a54b-a6a0fa0b1cf4", "type": "Port", "port_id": "6e20051b-7d59-4c96-8ec7-7d21b7967bfd", "interface_id": "5dd5a3fc-0be2-48ee-9abe-4a55e228c69f"}], "created_at": "2025-11-29T23:22:36.566879Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.566879Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "bed65b7a-6f6c-4e2a-a01d-499afdac8174", "name": "Google.com", "source": {"type": "System"}, "host_id": "a1803165-62e2-4963-a37e-86249eee0efc", "bindings": [{"id": "46c87dbd-7452-40b0-ad5b-4dba25975bb1", "type": "Port", "port_id": "69282c32-670c-44ea-8a89-7f4a778a7c1d", "interface_id": "17873443-bb94-4a83-859b-7ded06fccd0f"}], "created_at": "2025-11-29T23:22:36.566887Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.566887Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "805ac58d-1270-4b4f-93b7-e4b7a3db4068", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "57c82c33-5a65-4d05-9bee-6751e1a8cf2e", "bindings": [{"id": "07f04e36-fddc-4875-9918-913a20a2e963", "type": "Port", "port_id": "5c440ff6-4489-47b3-a160-fee19cd135ab", "interface_id": "b8ea1093-5ea8-4611-b284-b148c81bc770"}], "created_at": "2025-11-29T23:22:36.566893Z", "network_id": "b973c09c-1c96-4efd-a957-a13fe38237c0", "updated_at": "2025-11-29T23:22:36.566893Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-11-29 23:22:36.589598+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-29 23:22:36.585951+00	2025-11-29 23:23:09.096372+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
c9ff2c65-d9d5-42d9-9d90-362183ccdfc9	2025-11-29 23:22:33.688234+00	2025-11-29 23:22:36.545718+00	$argon2id$v=19$m=19456,t=2,p=1$Rd4KU6MBbh/oHosrCSuqaw$EhV/UAXf37d6lbO1GSjrg08c9TCSIG3+JakdFo1lKPQ	\N	\N	\N	user@gmail.com	38d48741-b969-4dd5-b22f-38a2dcf66d5e	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
FTd9Kbx2VZSi0fLVno_OpA	\\x93c410a4ce8f9ed5f2d1a2945576bc297d371581a7757365725f6964d92463396666326336352d643964352d343264392d396439302d33363231383363636466633999cd07e9cd016b171624ce20b1be03000000	2025-12-29 23:22:36.548519+00
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

\unrestrict F2vK3XunDnw8taQgbeH4yB2qVwoNSLM7voZayvZSYMAqumGJHhEGvwl21Hw3zbP

