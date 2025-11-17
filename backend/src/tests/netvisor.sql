--
-- PostgreSQL database dump
--

\restrict ag2Rel8zl01JfcYU4pIjlZ50MA4tnoCBNIxIlrTq9xshEbqEionC4GjaGOTLbJi

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
20251006215000	users	2025-11-17 04:58:26.778894+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3564676
20251006215100	networks	2025-11-17 04:58:26.783145+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3797971
20251006215151	create hosts	2025-11-17 04:58:26.787268+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3773156
20251006215155	create subnets	2025-11-17 04:58:26.791377+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3699808
20251006215201	create groups	2025-11-17 04:58:26.795457+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3760291
20251006215204	create daemons	2025-11-17 04:58:26.799519+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4446420
20251006215212	create services	2025-11-17 04:58:26.804337+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4752201
20251029193448	user-auth	2025-11-17 04:58:26.80943+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3846441
20251030044828	daemon api	2025-11-17 04:58:26.813561+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1524633
20251030170438	host-hide	2025-11-17 04:58:26.815374+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1113416
20251102224919	create discovery	2025-11-17 04:58:26.816765+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9636989
20251106235621	normalize-daemon-cols	2025-11-17 04:58:26.826901+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1754492
20251107034459	api keys	2025-11-17 04:58:26.828998+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7189785
20251107222650	oidc-auth	2025-11-17 04:58:26.836515+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20507828
20251110181948	orgs-billing	2025-11-17 04:58:26.857327+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	10341653
20251113223656	group-enhancements	2025-11-17 04:58:26.86801+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1030833
20251117032720	daemon-mode	2025-11-17 04:58:26.869332+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1062251
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
bd55bf26-a793-4d0b-9d6d-eb9a13b13565	136bc033683848f2bc3223e98f654a99	9b348e89-0d33-4762-a51e-30aa78854300	Integrated Daemon API Key	2025-11-17 04:58:30.675971+00	2025-11-17 04:59:39.921966+00	2025-11-17 04:59:39.921664+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
13ffaf9c-fd03-45b2-9476-7d07c4e72919	9b348e89-0d33-4762-a51e-30aa78854300	b2367ff4-a350-42e5-b365-07819ee20c7b	"172.25.0.4"	60073	2025-11-17 04:58:30.728366+00	2025-11-17 04:58:30.728365+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["2d577d04-07e2-4d52-8def-1b6d12076a9c"]}	2025-11-17 04:58:30.747801+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
2dab3e05-7203-4056-9725-0fec75552d13	9b348e89-0d33-4762-a51e-30aa78854300	13ffaf9c-fd03-45b2-9476-7d07c4e72919	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b"}	Self Report @ 172.25.0.4	2025-11-17 04:58:30.730298+00	2025-11-17 04:58:30.730298+00
d004e480-2f5a-40ac-bef3-d7ddd1d3d2ed	9b348e89-0d33-4762-a51e-30aa78854300	13ffaf9c-fd03-45b2-9476-7d07c4e72919	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 04:58:30.736826+00	2025-11-17 04:58:30.736826+00
176f90e4-1321-41ee-9c98-1534336d5c8d	9b348e89-0d33-4762-a51e-30aa78854300	13ffaf9c-fd03-45b2-9476-7d07c4e72919	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "processed": 1, "network_id": "9b348e89-0d33-4762-a51e-30aa78854300", "session_id": "effe8820-edb1-4294-9585-a445e58fb3c4", "started_at": "2025-11-17T04:58:30.736528591Z", "finished_at": "2025-11-17T04:58:30.794969201Z", "discovery_type": {"type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b"}	Discovery Run	2025-11-17 04:58:30.736528+00	2025-11-17 04:58:30.796439+00
95e6057d-1a03-40eb-a475-63152df14035	9b348e89-0d33-4762-a51e-30aa78854300	13ffaf9c-fd03-45b2-9476-7d07c4e72919	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "processed": 12, "network_id": "9b348e89-0d33-4762-a51e-30aa78854300", "session_id": "2a365d27-f6a7-4a4e-ae91-af227db70fdb", "started_at": "2025-11-17T04:58:30.807081752Z", "finished_at": "2025-11-17T04:59:39.920808889Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 04:58:30.807081+00	2025-11-17 04:59:39.921913+00
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
bb5fb148-5f14-4551-81c4-01a63d7f0316	9b348e89-0d33-4762-a51e-30aa78854300	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "8be66ab8-4f53-47cf-9524-f81aafd4d338"}	[{"id": "ade187d8-80be-4b5c-88c7-510e702bc1c0", "name": "Internet", "subnet_id": "b70de46b-02db-4249-a610-01f859cdd9fd", "ip_address": "1.1.1.1", "mac_address": null}]	["6489b284-9b89-4bcc-8c21-86ebf5007f71"]	[{"id": "f3592aed-6d31-42b5-9f2a-3d9879223387", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 04:58:30.656669+00	2025-11-17 04:58:30.66615+00	f
f3080649-c76f-4e4a-b5a0-d6aff6d417a4	9b348e89-0d33-4762-a51e-30aa78854300	Google.com	\N	\N	{"type": "ServiceBinding", "config": "e27a2724-954c-474f-b1ab-186b9fb07332"}	[{"id": "d016e4f4-c3fa-41d9-ae98-46a4568d2132", "name": "Internet", "subnet_id": "b70de46b-02db-4249-a610-01f859cdd9fd", "ip_address": "203.0.113.163", "mac_address": null}]	["a98996de-823f-4a92-9059-0a184fa633a4"]	[{"id": "ef6c6c4a-7dde-4702-bc95-3f30deb4083c", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 04:58:30.656679+00	2025-11-17 04:58:30.671171+00	f
a5134d74-f0a6-4151-8930-266d113e3b1d	9b348e89-0d33-4762-a51e-30aa78854300	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "6da4575c-7d4d-408b-a46d-62534952a9fe"}	[{"id": "5c8a825c-6b5d-4479-a221-6458c040fc39", "name": "Remote Network", "subnet_id": "488befe9-b5bb-4f36-afe9-301389dc875f", "ip_address": "203.0.113.38", "mac_address": null}]	["78d67465-c7a4-4e95-aeff-feaa26a7959c"]	[{"id": "cb5c4431-96da-41bf-852b-cd6cc1b32e70", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 04:58:30.656687+00	2025-11-17 04:58:30.675103+00	f
64e20e4a-456f-4148-99a9-a536e5cbc376	9b348e89-0d33-4762-a51e-30aa78854300	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "95097b7a-1aeb-469e-b5ce-145a48c77d8d", "name": null, "subnet_id": "2d577d04-07e2-4d52-8def-1b6d12076a9c", "ip_address": "172.25.0.3", "mac_address": "EE:BE:8C:A9:C8:76"}]	["5c62e792-c723-446d-a35b-c8d3046e4168"]	[{"id": "7cb87b51-0e14-469c-9ce8-00f4e8e3e9d5", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:58:47.729623154Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:58:47.729625+00	2025-11-17 04:59:17.195896+00	f
b2367ff4-a350-42e5-b365-07819ee20c7b	9b348e89-0d33-4762-a51e-30aa78854300	172.25.0.4	650979f60543	NetVisor daemon	{"type": "None"}	[{"id": "a5e77c9f-fee5-476b-8649-f90abca81b69", "name": "eth0", "subnet_id": "2d577d04-07e2-4d52-8def-1b6d12076a9c", "ip_address": "172.25.0.4", "mac_address": "3A:F2:54:35:E1:C0"}]	["ccbfd048-4bd8-4ace-8077-5586cb6769d3"]	[{"id": "91e00da8-65d9-4969-87b9-ae3a0f47b130", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:58:30.749591732Z", "type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919"}]}	null	2025-11-17 04:58:30.683773+00	2025-11-17 04:58:30.792864+00	f
f78f2895-a1fa-42f2-81b1-3c478fd0415c	9b348e89-0d33-4762-a51e-30aa78854300	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "2df76ca1-2371-49a7-8667-4a4812331885", "name": null, "subnet_id": "2d577d04-07e2-4d52-8def-1b6d12076a9c", "ip_address": "172.25.0.5", "mac_address": "2E:1E:E4:B9:A7:DC"}]	["4de890f8-ddc0-4a01-a347-c6c4632b6d69"]	[{"id": "f3e3c680-473f-4ccf-b0ec-e70eb7129636", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:58:32.902239029Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:58:32.902243+00	2025-11-17 04:58:47.558526+00	f
6daeea56-34d3-488b-a4bd-bc705818b841	9b348e89-0d33-4762-a51e-30aa78854300	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "f405f688-5cc2-4ecc-8e67-b1103a32bcad", "name": null, "subnet_id": "2d577d04-07e2-4d52-8def-1b6d12076a9c", "ip_address": "172.25.0.6", "mac_address": "12:FF:69:CF:C8:BE"}]	["107bb0bb-1d71-4477-90b2-5b5ce6d99ed1"]	[{"id": "9bf71e98-98bc-4829-a6c4-c80464c8bf1a", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:59:02.575571332Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:59:02.575573+00	2025-11-17 04:59:17.218204+00	f
cb3b1855-6abf-4ae3-a5e2-fea650bdee27	9b348e89-0d33-4762-a51e-30aa78854300	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "dc25db6f-b3f5-49c9-b5b9-99f5a44ab4fe", "name": null, "subnet_id": "2d577d04-07e2-4d52-8def-1b6d12076a9c", "ip_address": "172.25.0.1", "mac_address": "E6:D6:3A:81:C1:84"}]	["61e6c5f5-498b-4d14-8659-2a3ecf6e8f42", "ba3922d3-74b6-4ebe-a11a-29318b59be49"]	[{"id": "f8a235a1-ddc3-4726-9dba-4b3b863a9ffb", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "33c6d4d4-58de-44d0-9576-49f97fffe6de", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "347667de-2020-45dd-9fa9-be3efd4fc1e4", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:59:25.348674863Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 04:59:25.348678+00	2025-11-17 04:59:39.918833+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
9b348e89-0d33-4762-a51e-30aa78854300	My Network	2025-11-17 04:58:30.654954+00	2025-11-17 04:58:30.654954+00	f	e926ee82-f9f6-4cc3-84e6-7139512c836a
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
e926ee82-f9f6-4cc3-84e6-7139512c836a	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 04:58:26.924549+00	2025-11-17 04:58:30.653217+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
6489b284-9b89-4bcc-8c21-86ebf5007f71	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.656672+00	2025-11-17 04:58:30.656672+00	Cloudflare DNS	bb5fb148-5f14-4551-81c4-01a63d7f0316	[{"id": "8be66ab8-4f53-47cf-9524-f81aafd4d338", "type": "Port", "port_id": "f3592aed-6d31-42b5-9f2a-3d9879223387", "interface_id": "ade187d8-80be-4b5c-88c7-510e702bc1c0"}]	"Dns Server"	null	{"type": "System"}
a98996de-823f-4a92-9059-0a184fa633a4	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.656681+00	2025-11-17 04:58:30.656681+00	Google.com	f3080649-c76f-4e4a-b5a0-d6aff6d417a4	[{"id": "e27a2724-954c-474f-b1ab-186b9fb07332", "type": "Port", "port_id": "ef6c6c4a-7dde-4702-bc95-3f30deb4083c", "interface_id": "d016e4f4-c3fa-41d9-ae98-46a4568d2132"}]	"Web Service"	null	{"type": "System"}
78d67465-c7a4-4e95-aeff-feaa26a7959c	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.656688+00	2025-11-17 04:58:30.656688+00	Mobile Device	a5134d74-f0a6-4151-8930-266d113e3b1d	[{"id": "6da4575c-7d4d-408b-a46d-62534952a9fe", "type": "Port", "port_id": "cb5c4431-96da-41bf-852b-cd6cc1b32e70", "interface_id": "5c8a825c-6b5d-4479-a221-6458c040fc39"}]	"Client"	null	{"type": "System"}
ccbfd048-4bd8-4ace-8077-5586cb6769d3	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.749608+00	2025-11-17 04:58:30.749608+00	NetVisor Daemon API	b2367ff4-a350-42e5-b365-07819ee20c7b	[{"id": "495f1ef5-a368-4df6-9734-4e313156096b", "type": "Port", "port_id": "91e00da8-65d9-4969-87b9-ae3a0f47b130", "interface_id": "a5e77c9f-fee5-476b-8649-f90abca81b69"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T04:58:30.749607842Z", "type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919"}]}
4de890f8-ddc0-4a01-a347-c6c4632b6d69	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:34.453551+00	2025-11-17 04:58:34.453551+00	Home Assistant	f78f2895-a1fa-42f2-81b1-3c478fd0415c	[{"id": "7ab96ebf-7ea3-4467-9314-95b4cb2169c2", "type": "Port", "port_id": "f3e3c680-473f-4ccf-b0ec-e70eb7129636", "interface_id": "2df76ca1-2371-49a7-8667-4a4812331885"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:58:34.453543440Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5c62e792-c723-446d-a35b-c8d3046e4168	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:57.377355+00	2025-11-17 04:58:57.377355+00	NetVisor Server API	64e20e4a-456f-4148-99a9-a536e5cbc376	[{"id": "4dc6f4b6-e705-480b-a462-eb71204cbfda", "type": "Port", "port_id": "7cb87b51-0e14-469c-9ce8-00f4e8e3e9d5", "interface_id": "95097b7a-1aeb-469e-b5ce-145a48c77d8d"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:58:57.377345837Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
107bb0bb-1d71-4477-90b2-5b5ce6d99ed1	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:59:17.187615+00	2025-11-17 04:59:17.187615+00	PostgreSQL	6daeea56-34d3-488b-a4bd-bc705818b841	[{"id": "4e860513-07a4-4372-ae1a-9294af0c193b", "type": "Port", "port_id": "9bf71e98-98bc-4829-a6c4-c80464c8bf1a", "interface_id": "f405f688-5cc2-4ecc-8e67-b1103a32bcad"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T04:59:17.187608060Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
61e6c5f5-498b-4d14-8659-2a3ecf6e8f42	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:59:26.886726+00	2025-11-17 04:59:26.886726+00	Home Assistant	cb3b1855-6abf-4ae3-a5e2-fea650bdee27	[{"id": "757f58e2-48bc-41ea-9e92-72e3cfdb7ca9", "type": "Port", "port_id": "f8a235a1-ddc3-4726-9dba-4b3b863a9ffb", "interface_id": "dc25db6f-b3f5-49c9-b5b9-99f5a44ab4fe"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:59:26.886718532Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ba3922d3-74b6-4ebe-a11a-29318b59be49	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:59:34.904458+00	2025-11-17 04:59:34.904458+00	NetVisor Server API	cb3b1855-6abf-4ae3-a5e2-fea650bdee27	[{"id": "e807974a-971c-49a0-8719-0bfbf6a2afe5", "type": "Port", "port_id": "33c6d4d4-58de-44d0-9576-49f97fffe6de", "interface_id": "dc25db6f-b3f5-49c9-b5b9-99f5a44ab4fe"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T04:59:34.904448175Z", "type": "Network", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
b70de46b-02db-4249-a610-01f859cdd9fd	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.656591+00	2025-11-17 04:58:30.656591+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
488befe9-b5bb-4f36-afe9-301389dc875f	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.656596+00	2025-11-17 04:58:30.656596+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
2d577d04-07e2-4d52-8def-1b6d12076a9c	9b348e89-0d33-4762-a51e-30aa78854300	2025-11-17 04:58:30.736687+00	2025-11-17 04:58:30.736687+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T04:58:30.736686165Z", "type": "SelfReport", "host_id": "b2367ff4-a350-42e5-b365-07819ee20c7b", "daemon_id": "13ffaf9c-fd03-45b2-9476-7d07c4e72919"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
9dda9d8b-01fc-40c3-ae2b-cf8fb66df59c	2025-11-17 04:58:26.926713+00	2025-11-17 04:58:30.641232+00	$argon2id$v=19$m=19456,t=2,p=1$10uHUQeD+1Z1XEbqKsIBWA$1cSs1twsWvpXZNU8gRzk8Kj4uqAVDj4vvXMrplDfKxY	\N	\N	\N	user@example.com	e926ee82-f9f6-4cc3-84e6-7139512c836a	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
bI5AaAj4hFcCDUoso6-Rvw	\\x93c410bf91afa32c4a0d025784f80868408e6c81a7757365725f6964d92439646461396438622d303166632d343063332d616532622d63663866623636646635396399cd07e9cd015f043a1ece264fa395000000	2025-12-17 04:58:30.642753+00
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

\unrestrict ag2Rel8zl01JfcYU4pIjlZ50MA4tnoCBNIxIlrTq9xshEbqEionC4GjaGOTLbJi

