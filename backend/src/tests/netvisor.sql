--
-- PostgreSQL database dump
--

\restrict VsaM2WpVouZYXS0kOe7M7ypJwBICmf24h2Zlo0Ka9dMO5qyQRsz9dNdpDRpXkHJ

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
20251006215000	users	2025-11-29 15:39:28.958304+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3418251
20251006215100	networks	2025-11-29 15:39:28.962707+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4231293
20251006215151	create hosts	2025-11-29 15:39:28.967312+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3950637
20251006215155	create subnets	2025-11-29 15:39:28.97159+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3605161
20251006215201	create groups	2025-11-29 15:39:28.975514+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3760391
20251006215204	create daemons	2025-11-29 15:39:28.979605+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4132999
20251006215212	create services	2025-11-29 15:39:28.984076+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4701723
20251029193448	user-auth	2025-11-29 15:39:28.989093+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	4415470
20251030044828	daemon api	2025-11-29 15:39:28.993786+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1565481
20251030170438	host-hide	2025-11-29 15:39:28.995641+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1044516
20251102224919	create discovery	2025-11-29 15:39:28.99697+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9465975
20251106235621	normalize-daemon-cols	2025-11-29 15:39:29.00673+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1709822
20251107034459	api keys	2025-11-29 15:39:29.00872+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7825783
20251107222650	oidc-auth	2025-11-29 15:39:29.01684+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21483958
20251110181948	orgs-billing	2025-11-29 15:39:29.038659+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	9879860
20251113223656	group-enhancements	2025-11-29 15:39:29.048855+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	973653
20251117032720	daemon-mode	2025-11-29 15:39:29.050112+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1056829
20251118143058	set-default-plan	2025-11-29 15:39:29.051456+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1172866
20251118225043	save-topology	2025-11-29 15:39:29.052919+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8781774
20251123232748	network-permissions	2025-11-29 15:39:29.062162+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	3472903
20251125001342	billing-updates	2025-11-29 15:39:29.066079+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	972901
20251128035448	org-onboarding-status	2025-11-29 15:39:29.067454+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1447681
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
0e629c45-e97f-48de-adc3-6ba9f907d135	5d06ab40985941e192e589c0cf5875dd	5d554b8d-7787-42b2-b5ee-cdc7625568da	Integrated Daemon API Key	2025-11-29 15:39:31.891002+00	2025-11-29 15:40:24.229829+00	2025-11-29 15:40:24.229+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
57c4afcf-55d0-483f-a64e-974306b9e1cc	5d554b8d-7787-42b2-b5ee-cdc7625568da	baec9973-14f3-446d-a2c0-ae44be3e6ede	"172.25.0.4"	60073	2025-11-29 15:39:32.009156+00	2025-11-29 15:39:32.009154+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["5c39530e-fc06-4b56-83a7-710e43449e51"]}	2025-11-29 15:39:32.038769+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
8276f684-b153-4d1a-8325-26a52a73094c	5d554b8d-7787-42b2-b5ee-cdc7625568da	57c4afcf-55d0-483f-a64e-974306b9e1cc	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede"}	Self Report @ 172.25.0.4	2025-11-29 15:39:32.017113+00	2025-11-29 15:39:32.017113+00
ee06e337-276e-4fc6-a3d4-60a877c89fa0	5d554b8d-7787-42b2-b5ee-cdc7625568da	57c4afcf-55d0-483f-a64e-974306b9e1cc	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-29 15:39:32.023383+00	2025-11-29 15:39:32.023383+00
7835ac7f-ae47-403c-b8ed-f246f3891f50	5d554b8d-7787-42b2-b5ee-cdc7625568da	57c4afcf-55d0-483f-a64e-974306b9e1cc	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "processed": 1, "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "session_id": "b7642586-d6c7-447b-8a54-71b189ec42b1", "started_at": "2025-11-29T15:39:32.023028268Z", "finished_at": "2025-11-29T15:39:32.052471382Z", "discovery_type": {"type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede"}	Discovery Run	2025-11-29 15:39:32.023028+00	2025-11-29 15:39:32.055144+00
fa77676f-df5c-4ec2-b542-d7d07725147c	5d554b8d-7787-42b2-b5ee-cdc7625568da	57c4afcf-55d0-483f-a64e-974306b9e1cc	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "processed": 13, "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "session_id": "bae7be57-6348-46bc-9354-b58becb911c3", "started_at": "2025-11-29T15:39:32.065586710Z", "finished_at": "2025-11-29T15:40:24.227257081Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-29 15:39:32.065586+00	2025-11-29 15:40:24.229298+00
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
c951d34b-1733-4388-8e03-f7e2c4471a89	5d554b8d-7787-42b2-b5ee-cdc7625568da	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "c7bf057e-8275-489e-a84c-3b7c44d42956"}	[{"id": "ac44b108-0174-4eb8-900b-5fe4137d6581", "name": "Internet", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "ip_address": "1.1.1.1", "mac_address": null}]	{e6904472-f02b-4cc3-8c7b-2bc84d201bc7}	[{"id": "132377b4-038a-4efb-a11a-3e2b6bc4a730", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-29 15:39:31.866874+00	2025-11-29 15:39:31.875419+00	f
6351b7a3-e27b-4c5f-b910-b6c00260e446	5d554b8d-7787-42b2-b5ee-cdc7625568da	Google.com	\N	\N	{"type": "ServiceBinding", "config": "d44d83a5-c433-43f6-8dd4-e4f06b4ddede"}	[{"id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a", "name": "Internet", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "ip_address": "203.0.113.188", "mac_address": null}]	{5846e34b-9b42-48fd-8f8b-e3aea8581a1d}	[{"id": "9f58e063-9474-47d8-b1f0-c4cff4d7a718", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-29 15:39:31.866884+00	2025-11-29 15:39:31.880267+00	f
51cc4f5c-20b8-405f-8515-9062cc77a02d	5d554b8d-7787-42b2-b5ee-cdc7625568da	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "2e6cfd44-ba9c-458e-abc5-d4b45cbe9dc9"}	[{"id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf", "name": "Remote Network", "subnet_id": "0107a5a9-8e60-4830-99da-ba90c673b8a2", "ip_address": "203.0.113.179", "mac_address": null}]	{89601e6a-5ca2-4b21-8983-d0c0bc962287}	[{"id": "b70217ce-3eb1-48fc-be7b-763d517d25ec", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-29 15:39:31.866892+00	2025-11-29 15:39:31.884139+00	f
8ac89558-920f-40e7-88ee-fe28f5e3a3bc	5d554b8d-7787-42b2-b5ee-cdc7625568da	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "0045c471-e0d9-41d7-87f9-e069e568d9d0", "name": null, "subnet_id": "5c39530e-fc06-4b56-83a7-710e43449e51", "ip_address": "172.25.0.6", "mac_address": "E2:0A:29:20:8A:A9"}]	{156acd82-64fb-4185-90a2-5832fd6482cf}	[{"id": "e4405252-8c30-47aa-897f-17b3823c49bf", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T15:39:48.814088472Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 15:39:48.81409+00	2025-11-29 15:40:03.4303+00	f
baec9973-14f3-446d-a2c0-ae44be3e6ede	5d554b8d-7787-42b2-b5ee-cdc7625568da	172.25.0.4	214fc81cfc90	NetVisor daemon	{"type": "None"}	[{"id": "ffed61fe-681c-4421-bb19-98e1b74630ab", "name": "eth0", "subnet_id": "5c39530e-fc06-4b56-83a7-710e43449e51", "ip_address": "172.25.0.4", "mac_address": "2E:A2:77:A1:21:A9"}]	{71d49034-2f87-4579-b09b-6115fc9c5c21}	[{"id": "a463b58f-8e0d-4ec4-9ade-e6aa39ffdc9a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T15:39:32.040368490Z", "type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc"}]}	null	2025-11-29 15:39:31.942506+00	2025-11-29 15:39:32.050363+00	f
0fd9c545-80e6-42f0-b8db-842dd9ad2a51	5d554b8d-7787-42b2-b5ee-cdc7625568da	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1ac7b7d7-7eb2-4a2a-bb12-2244e4aa6cf8", "name": null, "subnet_id": "5c39530e-fc06-4b56-83a7-710e43449e51", "ip_address": "172.25.0.5", "mac_address": "0E:09:71:DA:CF:65"}]	{fd744520-ff4a-4c1a-b1f6-2c39f5534739}	[{"id": "de3d0136-aec4-45a6-88cc-0b161dd7b37f", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T15:39:34.231383141Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 15:39:34.231406+00	2025-11-29 15:39:48.653195+00	f
d69f5444-2610-453f-8023-4e17a57615ea	5d554b8d-7787-42b2-b5ee-cdc7625568da	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "31b22afe-dd1c-4846-8dcf-e352916f9554", "name": null, "subnet_id": "5c39530e-fc06-4b56-83a7-710e43449e51", "ip_address": "172.25.0.1", "mac_address": "EE:AE:D6:A9:81:9E"}]	{d3f4fd55-a842-403f-b2a6-a9beb424eabc,a4ad8f6c-d178-4230-9ea4-ab4bb1151766}	[{"id": "06a4cd28-ff5e-475b-a283-434b8ae3e511", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "b5ecfaa6-19de-44ce-b2d6-0a10710c5a8b", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "ddceb0ce-3e6d-4fa3-8627-ceeddc2d9023", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-29T15:40:09.599253994Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-29 15:40:09.599257+00	2025-11-29 15:40:24.225168+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
5d554b8d-7787-42b2-b5ee-cdc7625568da	My Network	2025-11-29 15:39:31.865542+00	2025-11-29 15:39:31.865542+00	f	8a700f98-ebb6-405b-92f0-4bd9b96c8f5b
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
8a700f98-ebb6-405b-92f0-4bd9b96c8f5b	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-29 15:39:29.123915+00	2025-11-29 15:39:32.015606+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
e6904472-f02b-4cc3-8c7b-2bc84d201bc7	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:31.866877+00	2025-11-29 15:39:31.866877+00	Cloudflare DNS	c951d34b-1733-4388-8e03-f7e2c4471a89	[{"id": "c7bf057e-8275-489e-a84c-3b7c44d42956", "type": "Port", "port_id": "132377b4-038a-4efb-a11a-3e2b6bc4a730", "interface_id": "ac44b108-0174-4eb8-900b-5fe4137d6581"}]	"Dns Server"	null	{"type": "System"}
5846e34b-9b42-48fd-8f8b-e3aea8581a1d	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:31.866887+00	2025-11-29 15:39:31.866887+00	Google.com	6351b7a3-e27b-4c5f-b910-b6c00260e446	[{"id": "d44d83a5-c433-43f6-8dd4-e4f06b4ddede", "type": "Port", "port_id": "9f58e063-9474-47d8-b1f0-c4cff4d7a718", "interface_id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a"}]	"Web Service"	null	{"type": "System"}
89601e6a-5ca2-4b21-8983-d0c0bc962287	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:31.866893+00	2025-11-29 15:39:31.866893+00	Mobile Device	51cc4f5c-20b8-405f-8515-9062cc77a02d	[{"id": "2e6cfd44-ba9c-458e-abc5-d4b45cbe9dc9", "type": "Port", "port_id": "b70217ce-3eb1-48fc-be7b-763d517d25ec", "interface_id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf"}]	"Client"	null	{"type": "System"}
71d49034-2f87-4579-b09b-6115fc9c5c21	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:32.040383+00	2025-11-29 15:39:32.040383+00	NetVisor Daemon API	baec9973-14f3-446d-a2c0-ae44be3e6ede	[{"id": "4ea5bdbf-ed65-4cc4-9ec5-feda79f91d83", "type": "Port", "port_id": "a463b58f-8e0d-4ec4-9ade-e6aa39ffdc9a", "interface_id": "ffed61fe-681c-4421-bb19-98e1b74630ab"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-29T15:39:32.040382286Z", "type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc"}]}
fd744520-ff4a-4c1a-b1f6-2c39f5534739	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:40.045439+00	2025-11-29 15:39:40.045439+00	Home Assistant	0fd9c545-80e6-42f0-b8db-842dd9ad2a51	[{"id": "f12b1c07-1210-4327-a028-77edf4ff0e0c", "type": "Port", "port_id": "de3d0136-aec4-45a6-88cc-0b161dd7b37f", "interface_id": "1ac7b7d7-7eb2-4a2a-bb12-2244e4aa6cf8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T15:39:40.045427430Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
156acd82-64fb-4185-90a2-5832fd6482cf	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:40:03.420916+00	2025-11-29 15:40:03.420916+00	PostgreSQL	8ac89558-920f-40e7-88ee-fe28f5e3a3bc	[{"id": "266f04bc-d85e-4a1e-bdec-75e2f1458a13", "type": "Port", "port_id": "e4405252-8c30-47aa-897f-17b3823c49bf", "interface_id": "0045c471-e0d9-41d7-87f9-e069e568d9d0"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-29T15:40:03.420908635Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d3f4fd55-a842-403f-b2a6-a9beb424eabc	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:40:09.599966+00	2025-11-29 15:40:09.599966+00	NetVisor Server API	d69f5444-2610-453f-8023-4e17a57615ea	[{"id": "2ef369ba-5db9-48fa-85c4-42fe9bcabd37", "type": "Port", "port_id": "06a4cd28-ff5e-475b-a283-434b8ae3e511", "interface_id": "31b22afe-dd1c-4846-8dcf-e352916f9554"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T15:40:09.599957632Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
a4ad8f6c-d178-4230-9ea4-ab4bb1151766	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:40:15.476328+00	2025-11-29 15:40:15.476328+00	Home Assistant	d69f5444-2610-453f-8023-4e17a57615ea	[{"id": "07f37fa6-f169-48f7-a501-a501373c87a2", "type": "Port", "port_id": "b5ecfaa6-19de-44ce-b2d6-0a10710c5a8b", "interface_id": "31b22afe-dd1c-4846-8dcf-e352916f9554"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-29T15:40:15.476318951Z", "type": "Network", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
f11181f4-6772-49d8-b2a9-290a4def0f98	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:31.866818+00	2025-11-29 15:39:31.866818+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
0107a5a9-8e60-4830-99da-ba90c673b8a2	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:31.866822+00	2025-11-29 15:39:31.866822+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
5c39530e-fc06-4b56-83a7-710e43449e51	5d554b8d-7787-42b2-b5ee-cdc7625568da	2025-11-29 15:39:32.023179+00	2025-11-29 15:39:32.023179+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-29T15:39:32.023177879Z", "type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
cc8d6c73-c130-4309-9a34-b4f14ec6e6cb	5d554b8d-7787-42b2-b5ee-cdc7625568da	My Topology	[]	[{"id": "0107a5a9-8e60-4830-99da-ba90c673b8a2", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "ac44b108-0174-4eb8-900b-5fe4137d6581", "size": {"x": 250, "y": 100}, "header": null, "host_id": "c951d34b-1733-4388-8e03-f7e2c4471a89", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "interface_id": "ac44b108-0174-4eb8-900b-5fe4137d6581"}, {"id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "6351b7a3-e27b-4c5f-b910-b6c00260e446", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "interface_id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a"}, {"id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf", "size": {"x": 250, "y": 100}, "header": null, "host_id": "51cc4f5c-20b8-405f-8515-9062cc77a02d", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "0107a5a9-8e60-4830-99da-ba90c673b8a2", "interface_id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "c951d34b-1733-4388-8e03-f7e2c4471a89", "name": "Cloudflare DNS", "ports": [{"id": "132377b4-038a-4efb-a11a-3e2b6bc4a730", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "c7bf057e-8275-489e-a84c-3b7c44d42956"}, "hostname": null, "services": ["e6904472-f02b-4cc3-8c7b-2bc84d201bc7"], "created_at": "2025-11-29T15:39:31.866874Z", "interfaces": [{"id": "ac44b108-0174-4eb8-900b-5fe4137d6581", "name": "Internet", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.875419Z", "description": null, "virtualization": null}, {"id": "6351b7a3-e27b-4c5f-b910-b6c00260e446", "name": "Google.com", "ports": [{"id": "9f58e063-9474-47d8-b1f0-c4cff4d7a718", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "d44d83a5-c433-43f6-8dd4-e4f06b4ddede"}, "hostname": null, "services": ["5846e34b-9b42-48fd-8f8b-e3aea8581a1d"], "created_at": "2025-11-29T15:39:31.866884Z", "interfaces": [{"id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a", "name": "Internet", "subnet_id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "ip_address": "203.0.113.188", "mac_address": null}], "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.880267Z", "description": null, "virtualization": null}, {"id": "51cc4f5c-20b8-405f-8515-9062cc77a02d", "name": "Mobile Device", "ports": [{"id": "b70217ce-3eb1-48fc-be7b-763d517d25ec", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "2e6cfd44-ba9c-458e-abc5-d4b45cbe9dc9"}, "hostname": null, "services": ["89601e6a-5ca2-4b21-8983-d0c0bc962287"], "created_at": "2025-11-29T15:39:31.866892Z", "interfaces": [{"id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf", "name": "Remote Network", "subnet_id": "0107a5a9-8e60-4830-99da-ba90c673b8a2", "ip_address": "203.0.113.179", "mac_address": null}], "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.884139Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "f11181f4-6772-49d8-b2a9-290a4def0f98", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-29T15:39:31.866818Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.866818Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "0107a5a9-8e60-4830-99da-ba90c673b8a2", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-29T15:39:31.866822Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.866822Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "5c39530e-fc06-4b56-83a7-710e43449e51", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-29T15:39:32.023177879Z", "type": "SelfReport", "host_id": "baec9973-14f3-446d-a2c0-ae44be3e6ede", "daemon_id": "57c4afcf-55d0-483f-a64e-974306b9e1cc"}]}, "created_at": "2025-11-29T15:39:32.023179Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:32.023179Z", "description": null, "subnet_type": "Lan"}]	[{"id": "e6904472-f02b-4cc3-8c7b-2bc84d201bc7", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "c951d34b-1733-4388-8e03-f7e2c4471a89", "bindings": [{"id": "c7bf057e-8275-489e-a84c-3b7c44d42956", "type": "Port", "port_id": "132377b4-038a-4efb-a11a-3e2b6bc4a730", "interface_id": "ac44b108-0174-4eb8-900b-5fe4137d6581"}], "created_at": "2025-11-29T15:39:31.866877Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.866877Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5846e34b-9b42-48fd-8f8b-e3aea8581a1d", "name": "Google.com", "source": {"type": "System"}, "host_id": "6351b7a3-e27b-4c5f-b910-b6c00260e446", "bindings": [{"id": "d44d83a5-c433-43f6-8dd4-e4f06b4ddede", "type": "Port", "port_id": "9f58e063-9474-47d8-b1f0-c4cff4d7a718", "interface_id": "803c5ed2-3214-489c-8f2c-0742b1c6f32a"}], "created_at": "2025-11-29T15:39:31.866887Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.866887Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "89601e6a-5ca2-4b21-8983-d0c0bc962287", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "51cc4f5c-20b8-405f-8515-9062cc77a02d", "bindings": [{"id": "2e6cfd44-ba9c-458e-abc5-d4b45cbe9dc9", "type": "Port", "port_id": "b70217ce-3eb1-48fc-be7b-763d517d25ec", "interface_id": "4a954f23-cdc7-4dfe-830b-0f62c8e768bf"}], "created_at": "2025-11-29T15:39:31.866893Z", "network_id": "5d554b8d-7787-42b2-b5ee-cdc7625568da", "updated_at": "2025-11-29T15:39:31.866893Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-11-29 15:39:31.888331+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-29 15:39:31.884859+00	2025-11-29 15:40:03.535562+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
e078b40d-b0d0-4469-a98b-92c1f5c4e809	2025-11-29 15:39:29.125877+00	2025-11-29 15:39:31.848083+00	$argon2id$v=19$m=19456,t=2,p=1$hgEAeFPBTePB4KXrZTOdZg$1lkGyXAd16I7XlpFMk9N2GYByuViJxWF9wfl4VPHMtQ	\N	\N	\N	user@gmail.com	8a700f98-ebb6-405b-92f0-4bd9b96c8f5b	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
egvwZbJxJ9ejBWPa9VgNYw	\\x93c410630d58f5da6305a3d72771b265f00b7a81a7757365725f6964d92465303738623430642d623064302d343436392d613938622d39326331663563346538303999cd07e9cd016b0f271fce32b959d1000000	2025-12-29 15:39:31.851007+00
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

\unrestrict VsaM2WpVouZYXS0kOe7M7ypJwBICmf24h2Zlo0Ka9dMO5qyQRsz9dNdpDRpXkHJ

