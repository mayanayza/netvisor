--
-- PostgreSQL database dump
--

\restrict WHNbxOKuN3Xlq6Oeb2cV5rt9mfq4SE7l1IP3Gl7fDrORCuqg9zY4YJlSgoW5Qge

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
20251006215000	users	2025-11-18 00:03:41.533365+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2287292
20251006215100	networks	2025-11-18 00:03:41.536119+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4380750
20251006215151	create hosts	2025-11-18 00:03:41.540708+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1721583
20251006215155	create subnets	2025-11-18 00:03:41.542588+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2197958
20251006215201	create groups	2025-11-18 00:03:41.544945+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2130958
20251006215204	create daemons	2025-11-18 00:03:41.547259+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	2193834
20251006215212	create services	2025-11-18 00:03:41.549628+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	2080709
20251029193448	user-auth	2025-11-18 00:03:41.551886+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	2749084
20251030044828	daemon api	2025-11-18 00:03:41.554795+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	627916
20251030170438	host-hide	2025-11-18 00:03:41.555586+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	533833
20251102224919	create discovery	2025-11-18 00:03:41.556284+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	7678625
20251106235621	normalize-daemon-cols	2025-11-18 00:03:41.56415+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	747333
20251107034459	api keys	2025-11-18 00:03:41.565061+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	4344708
20251107222650	oidc-auth	2025-11-18 00:03:41.569609+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	11108500
20251110181948	orgs-billing	2025-11-18 00:09:01.489572+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	24461292
20251113223656	group-enhancements	2025-11-18 00:09:01.514844+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1368459
20251117032720	daemon-mode	2025-11-18 00:09:01.516576+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1186917
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
b02deb3a-fa39-47dc-a093-7d648565e8cc	c1a9c96bd11a40a0934c577a8da34b14	f8138211-9e6c-46d2-9ca1-62604249128d	Integrated Daemon API Key	2025-11-18 14:26:00.512315+00	2025-11-18 14:26:40.140836+00	2025-11-18 14:26:40.140504+00	\N	t
659b14e2-0305-487e-abb7-f80105bd6a80	c7f2d4cc94864724a4e8af8568d67848	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	Integrated Daemon API Key	2025-11-18 00:03:41.615323+00	2025-11-18 00:04:12.73107+00	2025-11-18 00:04:12.731028+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
72b8c7bf-3145-47a4-bfac-5b353f2837db	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	cd775c2a-1eef-4616-b5e6-6d7aadb6328b	"192.168.65.3"	60073	2025-11-18 00:03:41.638193+00	2025-11-18 00:03:41.638193+00	{"has_docker_socket": true, "interfaced_subnet_ids": ["95317b60-ba99-4056-b1c0-022f58b60097"]}	2025-11-18 00:03:41.649809+00	"Push"
5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931	f8138211-9e6c-46d2-9ca1-62604249128d	d005a6c3-d60f-4a83-b79f-300aa6d643ae	"172.25.0.4"	60073	2025-11-18 14:26:00.555154+00	2025-11-18 14:26:00.555147+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8"]}	2025-11-18 14:26:00.566705+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
21161f47-f513-4757-aa98-af80fa2eae49	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	72b8c7bf-3145-47a4-bfac-5b353f2837db	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b"}	Self Report @ 192.168.65.3	2025-11-18 00:03:41.638987+00	2025-11-18 00:03:41.638987+00
b1f281ce-e91a-4bf5-bf9f-740877fb5ea7	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	72b8c7bf-3145-47a4-bfac-5b353f2837db	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "host_naming_fallback": "BestService"}	Docker @ 192.168.65.3	2025-11-18 00:03:41.642217+00	2025-11-18 00:03:41.642217+00
010868e2-c688-4c66-9c6c-e9d5b69968b2	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	72b8c7bf-3145-47a4-bfac-5b353f2837db	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 192.168.65.3	2025-11-18 00:03:41.643365+00	2025-11-18 00:03:41.643365+00
c1967cbb-ba19-4198-95a6-31adcb87b87d	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	72b8c7bf-3145-47a4-bfac-5b353f2837db	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "processed": 1, "network_id": "9d87811c-0b4c-4449-8ae8-1c7a6f252c59", "session_id": "58aca635-89d7-4bc5-8846-7729419d1e35", "started_at": "2025-11-18T00:03:41.642173263Z", "finished_at": "2025-11-18T00:03:41.656417180Z", "discovery_type": {"type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b"}	Discovery Run	2025-11-18 00:03:41.642173+00	2025-11-18 00:03:41.656642+00
c8967910-41f2-41a8-b4a1-6d60b9aaa8b6	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	72b8c7bf-3145-47a4-bfac-5b353f2837db	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "processed": 3, "network_id": "9d87811c-0b4c-4449-8ae8-1c7a6f252c59", "session_id": "56fef2fa-3dbf-4ab8-9f80-22c78a0736ed", "started_at": "2025-11-18T00:03:41.703719388Z", "finished_at": "2025-11-18T00:03:52.139966587Z", "discovery_type": {"type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "host_naming_fallback": "BestService"}, "total_to_process": 3}}	{"type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "host_naming_fallback": "BestService"}	Discovery Run	2025-11-18 00:03:41.703719+00	2025-11-18 00:03:52.140304+00
e02a20a2-984e-45da-868e-5eb93743d56c	f8138211-9e6c-46d2-9ca1-62604249128d	5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae"}	Self Report @ 172.25.0.4	2025-11-18 14:26:00.556502+00	2025-11-18 14:26:00.556502+00
9b20bcb9-15e0-446d-9c48-e97b39eb4693	f8138211-9e6c-46d2-9ca1-62604249128d	5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-18 14:26:00.560596+00	2025-11-18 14:26:00.560596+00
8096b2ba-24f5-423f-81da-97c8ecf06739	f8138211-9e6c-46d2-9ca1-62604249128d	5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "processed": 1, "network_id": "f8138211-9e6c-46d2-9ca1-62604249128d", "session_id": "76f82119-fc71-4493-a3f9-fd624305188f", "started_at": "2025-11-18T14:26:00.560339464Z", "finished_at": "2025-11-18T14:26:00.628734173Z", "discovery_type": {"type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae"}	Discovery Run	2025-11-18 14:26:00.560339+00	2025-11-18 14:26:00.629791+00
4f12c637-e426-4540-ad09-d22fd6938299	f8138211-9e6c-46d2-9ca1-62604249128d	5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "processed": 12, "network_id": "f8138211-9e6c-46d2-9ca1-62604249128d", "session_id": "cd943f43-89d5-4bae-9cd4-49601bee23af", "started_at": "2025-11-18T14:26:00.633439173Z", "finished_at": "2025-11-18T14:26:40.139847011Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-18 14:26:00.633439+00	2025-11-18 14:26:40.140809+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color, edge_style) FROM stdin;
77c63594-39d3-4200-b93b-7e255c2b27d6	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	1	\N	{"group_type": "RequestPath", "service_bindings": ["2d9b16c2-0a35-43b6-91a6-b88d8b717937"]}	2025-11-18 00:04:01.727115+00	2025-11-18 00:04:01.727115+00	{"type": "Manual"}	rose	"SmoothStep"
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
c9ece604-d614-4855-bc26-c4adbc7cf5bf	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "9ff40468-36bc-4f93-8517-c7be0f47e0d9"}	[{"id": "7c37bde3-d3e8-4d84-9026-d00dc7b2b8e2", "name": "Internet", "subnet_id": "9621c20e-1123-4782-89e2-36c48039de6e", "ip_address": "1.1.1.1", "mac_address": null}]	["1b8a9a8d-ccc1-4a2b-8d67-98db36ed72ab"]	[{"id": "7914a771-e556-4658-b0ba-5a4f61263b26", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-18 00:03:41.59899+00	2025-11-18 00:03:41.608766+00	f
239a541f-cfbb-47a3-b42b-b53257f68cfb	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	Google.com	\N	\N	{"type": "ServiceBinding", "config": "ef985e15-c481-498c-9131-bacf5ea38df2"}	[{"id": "ac3aeb2c-2db5-4b40-986f-fd29a97ee267", "name": "Internet", "subnet_id": "9621c20e-1123-4782-89e2-36c48039de6e", "ip_address": "203.0.113.165", "mac_address": null}]	["cd4f3225-1ec6-4da8-8214-c56a1ce54191"]	[{"id": "477c6152-a568-43fe-b706-37d11457bb44", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-18 00:03:41.598996+00	2025-11-18 00:03:41.61193+00	f
9e6bee31-f7e3-4f95-9f99-f5cd039bc410	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "0195888d-f68f-4dd8-baaf-a4f87e97df30"}	[{"id": "c6658ccd-5394-455f-bb5e-dc501badccda", "name": "Remote Network", "subnet_id": "a3bbf0bd-086e-4291-89b5-eb6680c1b137", "ip_address": "203.0.113.138", "mac_address": null}]	["1d285bea-899e-42c0-8618-d23123d83df1"]	[{"id": "d0fef08e-360c-4fc3-b868-d77ea31984a9", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-18 00:03:41.598998+00	2025-11-18 00:03:41.614899+00	f
cd775c2a-1eef-4616-b5e6-6d7aadb6328b	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	192.168.65.3	docker-desktop	NetVisor daemon	{"type": "None"}	[{"id": "cad5fe90-5fdb-4efe-bd10-d19ee5bc2dab", "name": "eth0", "subnet_id": "95317b60-ba99-4056-b1c0-022f58b60097", "ip_address": "192.168.65.3", "mac_address": "F2:3C:5F:F8:BF:4D"}, {"id": "d90a76c6-436c-4804-a0f1-52bec852c9bf", "name": "services1", "subnet_id": "95317b60-ba99-4056-b1c0-022f58b60097", "ip_address": "192.168.65.6", "mac_address": "42:1C:14:00:64:E5"}, {"id": "c34553fe-22bc-459b-8694-179b28da2e24", "name": "netvisor_netvisor", "subnet_id": "566426f1-7294-49a7-9a75-0aca331793e6", "ip_address": "172.31.0.2", "mac_address": "C6:FC:0F:89:DF:82"}, {"id": "0885358a-1f09-4081-a1a7-21e1e51df73f", "name": "docker0", "subnet_id": "9465b234-7aab-4d47-9971-730fbbcdfec1", "ip_address": "172.17.0.1", "mac_address": "BE:4A:1B:D3:A1:88"}, {"id": "87e5150e-d064-4b10-b156-18a549d75cae", "name": "br-9628b29e0ec1", "subnet_id": "566426f1-7294-49a7-9a75-0aca331793e6", "ip_address": "172.31.0.1", "mac_address": "86:80:5F:5A:4B:40"}, {"id": "7e534ddd-8f5b-4a0f-88cd-cb10686e11c9", "name": "netvisor_netvisor", "subnet_id": "566426f1-7294-49a7-9a75-0aca331793e6", "ip_address": "172.31.0.3", "mac_address": "5A:25:22:3A:5D:66"}]	["d859eeaa-0abb-4caf-a568-af0de36f9269", "efdbc2bb-0252-4821-a149-a48c8b88b7d2", "a9ca87b3-1d69-42d5-bd47-4c1347ffe849", "61a792c1-a2fb-43a0-86d7-1a80430baa7b", "7b8e7e62-b29b-4277-9b25-59275ac15e16", "98a10ed4-21c3-446f-8eb7-a3508a054eda", "4b3f8709-1fc2-423b-90e2-f885f0d06f01"]	[{"id": "5ec2312e-b06f-4029-af10-d73da37ab02e", "type": "Custom", "number": 60073, "protocol": "Tcp"}, {"id": "11e41ce5-1d63-44d7-8bf4-ff8cc44bdccb", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:58.385568049Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:49.219180836Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:46.130610084Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:41.770284513Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:41.704378680Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:41.650803597Z", "type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db"}]}	null	2025-11-18 00:03:41.626372+00	2025-11-18 00:03:58.396925+00	f
0e42e14b-ccd1-4296-9fa3-725ed5f16a75	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "e7e4e3b4-4172-4708-b1f2-4812884af864", "name": null, "subnet_id": "95317b60-ba99-4056-b1c0-022f58b60097", "ip_address": "192.168.65.254", "mac_address": "5A:94:EF:E4:0C:DD"}]	["98887096-6410-4ba3-862e-d9d3680b91ff"]	[{"id": "ffd342cd-8cee-4ec0-8c14-57611ab7080e", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:55.627426506Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-18 00:03:55.627426+00	2025-11-18 00:03:58.393008+00	f
360a3ada-1cc1-4069-b0b9-2952ff7cc948	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	192.168.65.7	\N	\N	{"type": "None"}	[{"id": "a6f1f589-74fc-4ca5-aa38-abdd814ee58b", "name": null, "subnet_id": "95317b60-ba99-4056-b1c0-022f58b60097", "ip_address": "192.168.65.7", "mac_address": "2A:AE:EB:45:20:28"}]	["8b32c144-df3d-45bd-b030-27ccadeeb5d7"]	[{"id": "ac32745a-0e2c-4b75-a999-2238a43b7153", "type": "DnsTcp", "number": 53, "protocol": "Tcp"}, {"id": "9996f83d-170f-410a-9c5f-fd8ed346a465", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:52.542268504Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-18 00:03:52.54227+00	2025-11-18 00:03:55.467866+00	f
dc6e1a47-876d-4279-add5-de9b17fdcf13	f8138211-9e6c-46d2-9ca1-62604249128d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "1abae944-cc9e-49d7-be25-0a9f5f8e9d08"}	[{"id": "a64a5b31-6820-488c-9f7d-437c8523066e", "name": "Internet", "subnet_id": "1fda39c9-50b9-4220-8f0b-7a7883a8fb51", "ip_address": "1.1.1.1", "mac_address": null}]	["01fe1823-f840-447f-8f06-34ba42a05d27"]	[{"id": "53d836b0-c2f2-4c83-a108-02f48561ed26", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-18 14:26:00.502211+00	2025-11-18 14:26:00.508648+00	f
d12d91f9-5f8f-4c75-8e21-bf81d29f2dfc	f8138211-9e6c-46d2-9ca1-62604249128d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "46380992-59be-4690-a32a-26ddcdeddf89"}	[{"id": "d33fb825-8d1c-4388-bb7e-ff12e653da83", "name": "Internet", "subnet_id": "1fda39c9-50b9-4220-8f0b-7a7883a8fb51", "ip_address": "203.0.113.24", "mac_address": null}]	["7d25d600-9a2c-49a2-9241-a347bfbd70e4"]	[{"id": "cf4317a1-c1fe-4421-88b7-f5d373c79367", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-18 14:26:00.502219+00	2025-11-18 14:26:00.510571+00	f
f54bd391-f764-45e1-a0af-fb9cb1faf866	f8138211-9e6c-46d2-9ca1-62604249128d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "285eb44f-6ac2-4b50-a58e-1af4a2c95bad"}	[{"id": "a2f723dd-776e-4853-a0ba-4271af4cae68", "name": "Remote Network", "subnet_id": "38163127-d618-4d0c-93a9-fb16f41b1cb1", "ip_address": "203.0.113.74", "mac_address": null}]	["f0c6a60d-41cf-4b5c-9016-00c3b67bf7e1"]	[{"id": "a47ed054-371e-49fd-b421-926b07e93c7f", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-18 14:26:00.502221+00	2025-11-18 14:26:00.512006+00	f
80cd569a-0d22-44fa-a5fb-3f689f462fbe	f8138211-9e6c-46d2-9ca1-62604249128d	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "28cd9c3b-eefa-4d3b-9abb-c83527bd6d00", "name": null, "subnet_id": "8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8", "ip_address": "172.25.0.3", "mac_address": "1A:39:06:9C:50:68"}]	["8ea2a0e4-e14e-427f-9bd6-7209f1b1d7ef"]	[{"id": "7f18db01-2acc-4e50-9645-31f26b732fc9", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T14:26:02.766466174Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-18 14:26:02.766468+00	2025-11-18 14:26:12.135338+00	f
8c9d200d-3ccf-4bde-aee3-268c699be46a	f8138211-9e6c-46d2-9ca1-62604249128d	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "9e364443-7c47-44d0-b477-7b10971c7185", "name": null, "subnet_id": "8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8", "ip_address": "172.25.0.6", "mac_address": "2E:68:FB:10:CF:4D"}]	["87135afc-e88d-4388-8c27-702d1414de24"]	[{"id": "98733a1c-485d-484d-ad3c-4301878bff8e", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T14:26:12.174800928Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-18 14:26:12.174803+00	2025-11-18 14:26:21.476783+00	f
d005a6c3-d60f-4a83-b79f-300aa6d643ae	f8138211-9e6c-46d2-9ca1-62604249128d	172.25.0.4	6401219c8c5f	NetVisor daemon	{"type": "None"}	[{"id": "e3d7824f-dea6-4edb-ae7e-04a3a7528550", "name": "eth0", "subnet_id": "8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8", "ip_address": "172.25.0.4", "mac_address": "52:36:01:D8:03:80"}]	["05f5e3b9-8b58-428d-b139-d6337d25bc4f", "569b37fe-3cdb-42b0-a699-e35359f375dd"]	[{"id": "4c9506eb-20b9-4460-90e7-feecb44c9b3e", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T14:26:02.731833091Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-18T14:26:00.623436548Z", "type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931"}]}	null	2025-11-18 14:26:00.523292+00	2025-11-18 14:26:02.740772+00	f
af9a8f3c-880a-4e83-801b-56c749585e4b	f8138211-9e6c-46d2-9ca1-62604249128d	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "0e96bb5a-83aa-4926-8102-f401d56b2f1f", "name": null, "subnet_id": "8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8", "ip_address": "172.25.0.1", "mac_address": "C6:6F:8F:F3:9B:5C"}]	["6d83bd6c-c7ef-4d6f-b788-16e694e921e7", "ae27b532-bd3c-4136-927f-172907a49460"]	[{"id": "1880b249-24b8-4aa5-a4e0-094e403a507e", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "ca07f035-f53c-4804-9b0d-6e4edacfecc0", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-18T14:26:29.600738047Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-18 14:26:29.600741+00	2025-11-18 14:26:40.137651+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
9d87811c-0b4c-4449-8ae8-1c7a6f252c59	My Network	2025-11-18 00:03:41.598158+00	2025-11-18 00:03:41.598158+00	t	11b279b2-2caa-4b66-a3dc-f3d5d33b5c04
f8138211-9e6c-46d2-9ca1-62604249128d	My Network	2025-11-18 14:26:00.501569+00	2025-11-18 14:26:00.501569+00	f	c11ae96a-f7e4-404c-8873-39fa9e2b6985
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
11b279b2-2caa-4b66-a3dc-f3d5d33b5c04	My Organization	\N	\N	\N	2025-11-18 00:09:01.489572+00	2025-11-18 00:09:01.489572+00	t
c11ae96a-f7e4-404c-8873-39fa9e2b6985	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-18 14:26:00.482537+00	2025-11-18 14:26:00.501041+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
1b8a9a8d-ccc1-4a2b-8d67-98db36ed72ab	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.598994+00	2025-11-18 00:03:41.60805+00	Cloudflare DNS	c9ece604-d614-4855-bc26-c4adbc7cf5bf	[{"id": "9ff40468-36bc-4f93-8517-c7be0f47e0d9", "type": "Port", "port_id": "7914a771-e556-4658-b0ba-5a4f61263b26", "interface_id": "7c37bde3-d3e8-4d84-9026-d00dc7b2b8e2"}]	"Dns Server"	null	{"type": "System"}
cd4f3225-1ec6-4da8-8214-c56a1ce54191	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.598997+00	2025-11-18 00:03:41.611535+00	Google.com	239a541f-cfbb-47a3-b42b-b53257f68cfb	[{"id": "ef985e15-c481-498c-9131-bacf5ea38df2", "type": "Port", "port_id": "477c6152-a568-43fe-b706-37d11457bb44", "interface_id": "ac3aeb2c-2db5-4b40-986f-fd29a97ee267"}]	"Web Service"	null	{"type": "System"}
1d285bea-899e-42c0-8618-d23123d83df1	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.598998+00	2025-11-18 00:03:41.614494+00	Mobile Device	9e6bee31-f7e3-4f95-9f99-f5cd039bc410	[{"id": "0195888d-f68f-4dd8-baaf-a4f87e97df30", "type": "Port", "port_id": "d0fef08e-360c-4fc3-b868-d77ea31984a9", "interface_id": "c6658ccd-5394-455f-bb5e-dc501badccda"}]	"Client"	null	{"type": "System"}
efdbc2bb-0252-4821-a149-a48c8b88b7d2	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.704376+00	2025-11-18 00:03:58.395747+00	Docker	cd775c2a-1eef-4616-b5e6-6d7aadb6328b	[]	"Docker"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Docker daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-18T00:03:41.704376180Z", "type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db"}]}
87135afc-e88d-4388-8c27-702d1414de24	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:21.463212+00	2025-11-18 14:26:21.463212+00	PostgreSQL	8c9d200d-3ccf-4bde-aee3-268c699be46a	[{"id": "289edc10-afdc-48da-a016-b22c46885247", "type": "Port", "port_id": "98733a1c-485d-484d-ad3c-4301878bff8e", "interface_id": "9e364443-7c47-44d0-b477-7b10971c7185"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-18T14:26:21.463198377Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ae27b532-bd3c-4136-927f-172907a49460	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:36.345949+00	2025-11-18 14:26:36.345949+00	Home Assistant	af9a8f3c-880a-4e83-801b-56c749585e4b	[{"id": "4106d134-1be0-4943-95b6-c995cc99d882", "type": "Port", "port_id": "ca07f035-f53c-4804-9b0d-6e4edacfecc0", "interface_id": "0e96bb5a-83aa-4926-8102-f401d56b2f1f"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-18T14:26:36.345945926Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
6d83bd6c-c7ef-4d6f-b788-16e694e921e7	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:36.34579+00	2025-11-18 14:26:36.34579+00	NetVisor Server API	af9a8f3c-880a-4e83-801b-56c749585e4b	[{"id": "3479aecf-6f5a-4286-ac77-cbf5e0586566", "type": "Port", "port_id": "1880b249-24b8-4aa5-a4e0-094e403a507e", "interface_id": "0e96bb5a-83aa-4926-8102-f401d56b2f1f"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-18T14:26:36.345769134Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
8b32c144-df3d-45bd-b030-27ccadeeb5d7	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:55.462023+00	2025-11-18 00:03:55.467431+00	Dns Server	360a3ada-1cc1-4069-b0b9-2952ff7cc948	[{"id": "cff09680-f2a4-4161-8efd-233c9af9e44b", "type": "Port", "port_id": "ac32745a-0e2c-4b75-a999-2238a43b7153", "interface_id": "a6f1f589-74fc-4ca5-aa38-abdd814ee58b"}, {"id": "2d9b16c2-0a35-43b6-91a6-b88d8b717937", "type": "Port", "port_id": "9996f83d-170f-410a-9c5f-fd8ed346a465", "interface_id": "a6f1f589-74fc-4ca5-aa38-abdd814ee58b"}]	"Dns Server"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": ["Any of", [{"data": "Port 53/tcp is open but is used in other service match patterns", "type": "reason"}, {"data": "Port 53/udp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-18T00:03:55.462020756Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
61a792c1-a2fb-43a0-86d7-1a80430baa7b	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:49.137073+00	2025-11-18 00:03:58.395495+00	netvisor-postgres-1	cd775c2a-1eef-4616-b5e6-6d7aadb6328b	[{"id": "66c7acf9-9f4c-45d0-aad0-c68cb87c312e", "type": "Interface", "interface_id": "c34553fe-22bc-459b-8694-179b28da2e24"}]	"Docker Container"	{"type": "Docker", "details": {"service_id": "efdbc2bb-0252-4821-a149-a48c8b88b7d2", "container_id": "b5a97aaaf5b85baf3e0623093510c92fbd520605cb4b75b2cb40f4263666b28c", "container_name": "netvisor-postgres-1"}}	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": ["All of", [{"data": "Service is running in docker container", "type": "reason"}, {"data": "No other services with this container's ID have been matched", "type": "reason"}]], "type": "container"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-18T00:03:49.137060461Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}]}
d859eeaa-0abb-4caf-a568-af0de36f9269	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.651094+00	2025-11-18 00:03:58.395595+00	NetVisor Daemon API	cd775c2a-1eef-4616-b5e6-6d7aadb6328b	[{"id": "8782f860-52ac-4c58-ba9d-35846e8a10c8", "type": "Port", "port_id": "5ec2312e-b06f-4029-af10-d73da37ab02e", "interface_id": "cad5fe90-5fdb-4efe-bd10-d19ee5bc2dab"}, {"id": "0a5d082b-a1f0-4093-be37-668afc2d4120", "type": "Port", "port_id": "5ec2312e-b06f-4029-af10-d73da37ab02e", "interface_id": "d90a76c6-436c-4804-a0f1-52bec852c9bf"}]	"NetVisor Daemon API"	{"type": "Docker", "details": {"service_id": "efdbc2bb-0252-4821-a149-a48c8b88b7d2", "container_id": "f3d95ff23b8db35bee96dd1bab7691f6e693976952b0ce5bc58c3880be89c42a", "container_name": "netvisor-daemon"}}	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-18T00:03:55.627230506Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:42.968719541Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:41.650812847Z", "type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db"}]}
98887096-6410-4ba3-862e-d9d3680b91ff	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:56.456093+00	2025-11-18 00:03:58.392315+00	NetVisor Server API	0e42e14b-ccd1-4296-9fa3-725ed5f16a75	[{"id": "1b6fa161-acce-47bf-a00a-b0c83de52a50", "type": "Port", "port_id": "ffd342cd-8cee-4ec0-8c14-57611ab7080e", "interface_id": "e7e4e3b4-4172-4708-b1f2-4812884af864"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://192.168.65.254:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-18T00:03:56.456091964Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7b8e7e62-b29b-4277-9b25-59275ac15e16	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:50.142542+00	2025-11-18 00:03:58.395453+00	NetVisor Server API	cd775c2a-1eef-4616-b5e6-6d7aadb6328b	[{"id": "2ecb978d-7054-449d-9711-47fb51b3903b", "type": "Port", "port_id": "11e41ce5-1d63-44d7-8bf4-ff8cc44bdccb", "interface_id": "7e534ddd-8f5b-4a0f-88cd-cb10686e11c9"}, {"id": "d82f809b-fdad-4657-a8e0-7a43755427fb", "type": "Port", "port_id": "11e41ce5-1d63-44d7-8bf4-ff8cc44bdccb", "interface_id": "cad5fe90-5fdb-4efe-bd10-d19ee5bc2dab"}, {"id": "4842f8c8-7f63-47ea-a22b-8f8e23f11b69", "type": "Port", "port_id": "11e41ce5-1d63-44d7-8bf4-ff8cc44bdccb", "interface_id": "d90a76c6-436c-4804-a0f1-52bec852c9bf"}]	"NetVisor Server API"	{"type": "Docker", "details": {"service_id": "efdbc2bb-0252-4821-a149-a48c8b88b7d2", "container_id": "bf9432c679cef9caf2b4ff808c3c72fc88135c091f5adcb7f6ad19fa584ed34b", "container_name": "netvisor-server-1"}}	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://0.0.0.0:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-18T00:03:55.627224256Z", "type": "Network", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-18T00:03:50.142540711Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}]}
01fe1823-f840-447f-8f06-34ba42a05d27	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.502215+00	2025-11-18 14:26:00.502215+00	Cloudflare DNS	dc6e1a47-876d-4279-add5-de9b17fdcf13	[{"id": "1abae944-cc9e-49d7-be25-0a9f5f8e9d08", "type": "Port", "port_id": "53d836b0-c2f2-4c83-a108-02f48561ed26", "interface_id": "a64a5b31-6820-488c-9f7d-437c8523066e"}]	"Dns Server"	null	{"type": "System"}
7d25d600-9a2c-49a2-9241-a347bfbd70e4	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.502219+00	2025-11-18 14:26:00.502219+00	Google.com	d12d91f9-5f8f-4c75-8e21-bf81d29f2dfc	[{"id": "46380992-59be-4690-a32a-26ddcdeddf89", "type": "Port", "port_id": "cf4317a1-c1fe-4421-88b7-f5d373c79367", "interface_id": "d33fb825-8d1c-4388-bb7e-ff12e653da83"}]	"Web Service"	null	{"type": "System"}
f0c6a60d-41cf-4b5c-9016-00c3b67bf7e1	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.502222+00	2025-11-18 14:26:00.502222+00	Mobile Device	f54bd391-f764-45e1-a0af-fb9cb1faf866	[{"id": "285eb44f-6ac2-4b50-a58e-1af4a2c95bad", "type": "Port", "port_id": "a47ed054-371e-49fd-b421-926b07e93c7f", "interface_id": "a2f723dd-776e-4853-a0ba-4271af4cae68"}]	"Client"	null	{"type": "System"}
05f5e3b9-8b58-428d-b139-d6337d25bc4f	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.623447+00	2025-11-18 14:26:02.739815+00	NetVisor Daemon API	d005a6c3-d60f-4a83-b79f-300aa6d643ae	[{"id": "20776608-9584-46a3-9bfd-1c41970801a0", "type": "Port", "port_id": "4c9506eb-20b9-4460-90e7-feecb44c9b3e", "interface_id": "e3d7824f-dea6-4edb-ae7e-04a3a7528550"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-18T14:26:02.732627549Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-18T14:26:00.623446340Z", "type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931"}]}
8ea2a0e4-e14e-427f-9bd6-7209f1b1d7ef	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:08.43878+00	2025-11-18 14:26:08.43878+00	NetVisor Server API	80cd569a-0d22-44fa-a5fb-3f689f462fbe	[{"id": "5fdfb535-724b-4826-bf5b-96ef190cc4f9", "type": "Port", "port_id": "7f18db01-2acc-4e50-9645-31f26b732fc9", "interface_id": "28cd9c3b-eefa-4d3b-9abb-c83527bd6d00"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-18T14:26:08.438766385Z", "type": "Network", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
9621c20e-1123-4782-89e2-36c48039de6e	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.598976+00	2025-11-18 00:03:41.598976+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
a3bbf0bd-086e-4291-89b5-eb6680c1b137	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.598978+00	2025-11-18 00:03:41.598978+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
95317b60-ba99-4056-b1c0-022f58b60097	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.642827+00	2025-11-18 00:03:41.642827+00	"192.168.65.0/24"	192.168.65.0/24	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:41.642823722Z", "type": "SelfReport", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db"}]}
566426f1-7294-49a7-9a75-0aca331793e6	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.719234+00	2025-11-18 00:03:41.719234+00	"172.31.0.0/16"	netvisor_netvisor	\N	"DockerBridge"	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:41.719234305Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}]}
9465b234-7aab-4d47-9971-730fbbcdfec1	9d87811c-0b4c-4449-8ae8-1c7a6f252c59	2025-11-18 00:03:41.717119+00	2025-11-18 00:03:41.717119+00	"172.17.0.0/16"	172.17.0.0/16	\N	"DockerBridge"	{"type": "Discovery", "metadata": [{"date": "2025-11-18T00:03:41.717119472Z", "type": "Docker", "host_id": "cd775c2a-1eef-4616-b5e6-6d7aadb6328b", "daemon_id": "72b8c7bf-3145-47a4-bfac-5b353f2837db", "host_naming_fallback": "BestService"}]}
1fda39c9-50b9-4220-8f0b-7a7883a8fb51	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.50216+00	2025-11-18 14:26:00.50216+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
38163127-d618-4d0c-93a9-fb16f41b1cb1	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.502162+00	2025-11-18 14:26:00.502162+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
8d4a6cd2-c42d-452d-a7da-ac2b57ad24e8	f8138211-9e6c-46d2-9ca1-62604249128d	2025-11-18 14:26:00.560783+00	2025-11-18 14:26:00.560783+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-18T14:26:00.560777923Z", "type": "SelfReport", "host_id": "d005a6c3-d60f-4a83-b79f-300aa6d643ae", "daemon_id": "5d3c8080-8a4a-4d94-b7a5-06fbe7ffb931"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
cb5d5936-0bf9-41cc-8325-84e2a7078602	2025-11-18 00:03:41.597545+00	2025-11-18 00:03:54.725277+00	$argon2id$v=19$m=19456,t=2,p=1$HHFkG/7KixxQYg+ac8FW3g$Pnx9D/f5YidfUMInxQVChixxvynOcJ8vD6somtboToo	\N	\N	\N	test@test.com	11b279b2-2caa-4b66-a3dc-f3d5d33b5c04	Owner
0a0ee0a8-4f09-415b-95b9-6031c683b7f5	2025-11-18 14:26:00.485506+00	2025-11-18 14:26:00.485506+00	$argon2id$v=19$m=19456,t=2,p=1$1t+V45SLHSRsK3JBXDvJBQ$fS5a4aPKedFONNqsmwOa6FL2RFeNIuMuw4pCpRsRMig	\N	\N	\N	user@example.com	c11ae96a-f7e4-404c-8873-39fa9e2b6985	Owner
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
UAyDo6o9xnmc_RDUQK8B5g	\\x93c410e601af40d410fd9c79c63daaa3830c5081a7757365725f6964d92463623564353933362d306266392d343163632d383332352d38346532613730373836303299cd07e9cd0160000336ce2b4eed70000000	2025-12-18 00:03:54.726592+00
sjpIBZTNC1NEIciKv8CsYg	\\x93c41062acc0bf8ac82144530bcd9405483ab281a7757365725f6964d92463623564353933362d306266392d343163632d383332352d38346532613730373836303299cd07e9cd0160000b21ce0ff51540000000	2025-12-18 00:11:33.26772+00
EEkmjUGE-RRPWxtDhc6r1g	\\x93c410d6abce85431b5b4f14f984418d26491081a7757365725f6964d92430613065653061382d346630392d343135622d393562392d36303331633638336237663599cd07e9cd01600e1a00ce1d155f29000000	2025-12-18 14:26:00.487939+00
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

\unrestrict WHNbxOKuN3Xlq6Oeb2cV5rt9mfq4SE7l1IP3Gl7fDrORCuqg9zY4YJlSgoW5Qge

