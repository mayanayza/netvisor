--
-- PostgreSQL database dump
--

\restrict jHmmw0cye83hU4jUO6qqUzUXuIXfgT65XVSQlLuiW2W9ejVy3SJJLwFdfWwQkDe

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
20251006215000	users	2025-11-17 06:59:38.843391+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3545098
20251006215100	networks	2025-11-17 06:59:38.847661+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3918438
20251006215151	create hosts	2025-11-17 06:59:38.851923+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3905343
20251006215155	create subnets	2025-11-17 06:59:38.856205+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3800487
20251006215201	create groups	2025-11-17 06:59:38.860368+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3840161
20251006215204	create daemons	2025-11-17 06:59:38.864603+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4333805
20251006215212	create services	2025-11-17 06:59:38.869253+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	5573797
20251029193448	user-auth	2025-11-17 06:59:38.875123+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3766673
20251030044828	daemon api	2025-11-17 06:59:38.879172+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1796605
20251030170438	host-hide	2025-11-17 06:59:38.88126+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1180280
20251102224919	create discovery	2025-11-17 06:59:38.882714+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9866686
20251106235621	normalize-daemon-cols	2025-11-17 06:59:38.8929+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1770134
20251107034459	api keys	2025-11-17 06:59:38.894977+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7975906
20251107222650	oidc-auth	2025-11-17 06:59:38.90328+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21573168
20251110181948	orgs-billing	2025-11-17 06:59:38.925211+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	11798785
20251113223656	group-enhancements	2025-11-17 06:59:38.937419+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1072037
20251117032720	daemon-mode	2025-11-17 06:59:38.938785+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1137299
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
a0aa4b15-aed1-4f93-b389-de570fcbbe7d	9b958e6b1b4a44b6bdd7920a4b86e9ab	22a997ff-3635-4693-87d8-7e5de31cef68	Integrated Daemon API Key	2025-11-17 06:59:42.60822+00	2025-11-17 07:00:36.815967+00	2025-11-17 07:00:36.815603+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
5d4ecaa2-0db8-4742-b195-76b8752c49e0	22a997ff-3635-4693-87d8-7e5de31cef68	6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3	"172.25.0.4"	60073	2025-11-17 06:59:42.660072+00	2025-11-17 06:59:42.660071+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["b8f91ccb-fbdb-413f-aef8-2eb730b08748"]}	2025-11-17 06:59:42.714423+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
888b27ab-58db-4067-869d-ad3456cda086	22a997ff-3635-4693-87d8-7e5de31cef68	5d4ecaa2-0db8-4742-b195-76b8752c49e0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3"}	Self Report @ 172.25.0.4	2025-11-17 06:59:42.661858+00	2025-11-17 06:59:42.661858+00
f18d28b4-15bd-42ca-b38e-75235725b4dc	22a997ff-3635-4693-87d8-7e5de31cef68	5d4ecaa2-0db8-4742-b195-76b8752c49e0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 06:59:42.668129+00	2025-11-17 06:59:42.668129+00
557134e4-c699-4b25-9dc1-f2bcb4cfc916	22a997ff-3635-4693-87d8-7e5de31cef68	5d4ecaa2-0db8-4742-b195-76b8752c49e0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "processed": 1, "network_id": "22a997ff-3635-4693-87d8-7e5de31cef68", "session_id": "25db596d-3f56-4a41-ac61-6bbd7ac55a72", "started_at": "2025-11-17T06:59:42.667795373Z", "finished_at": "2025-11-17T06:59:42.726518839Z", "discovery_type": {"type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3"}	Discovery Run	2025-11-17 06:59:42.667795+00	2025-11-17 06:59:42.728333+00
aeca351b-15de-4e73-9282-c0283204f39b	22a997ff-3635-4693-87d8-7e5de31cef68	5d4ecaa2-0db8-4742-b195-76b8752c49e0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "processed": 13, "network_id": "22a997ff-3635-4693-87d8-7e5de31cef68", "session_id": "3d919d0b-a351-447f-bde7-335f31de2c80", "started_at": "2025-11-17T06:59:42.737572714Z", "finished_at": "2025-11-17T07:00:36.814608429Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 06:59:42.737572+00	2025-11-17 07:00:36.815896+00
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
8bc6885b-7041-4e32-925a-fd2b2c2ee0f0	22a997ff-3635-4693-87d8-7e5de31cef68	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "59cc0098-6899-46e6-8be3-ed52095eb17d"}	[{"id": "b5587d2f-347c-4409-b941-33cb72ce62c8", "name": "Internet", "subnet_id": "ad8531b9-b7fc-4021-ad55-7e26f3a4b96f", "ip_address": "1.1.1.1", "mac_address": null}]	["2596da5d-eff6-4877-9578-2ac7f24c87b9"]	[{"id": "cef36a67-17d3-4c7f-9509-165316604267", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 06:59:42.589349+00	2025-11-17 06:59:42.599329+00	f
47ba0c25-aed1-49ca-8830-611a2c3601ec	22a997ff-3635-4693-87d8-7e5de31cef68	Google.com	\N	\N	{"type": "ServiceBinding", "config": "e56352c7-a493-4d8e-8fe6-3175459db473"}	[{"id": "1270abbe-ccc3-4d6d-8c77-d2211812f186", "name": "Internet", "subnet_id": "ad8531b9-b7fc-4021-ad55-7e26f3a4b96f", "ip_address": "203.0.113.181", "mac_address": null}]	["b5e44081-2fd9-4638-87b3-dc8a3817b33d"]	[{"id": "e1dbdeab-fb86-40e2-b82e-09a662fe4d05", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:59:42.589356+00	2025-11-17 06:59:42.603882+00	f
e10b6932-96ad-44c9-9026-04df51d82c52	22a997ff-3635-4693-87d8-7e5de31cef68	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "c3aff766-45dc-4908-afe6-208b8f67cc00"}	[{"id": "0dcd8b60-d26b-4362-87f3-987c00f41073", "name": "Remote Network", "subnet_id": "860f6d2f-4970-45a4-a654-31e09eea82c3", "ip_address": "203.0.113.70", "mac_address": null}]	["5a418ee0-71bb-4885-afdb-f90bc8966cc2"]	[{"id": "38cfd809-e63c-4574-8117-b7127f2adb6f", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 06:59:42.589361+00	2025-11-17 06:59:42.607451+00	f
b2b9a22f-f662-415d-b752-435eef12b949	22a997ff-3635-4693-87d8-7e5de31cef68	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "82851a26-4081-4133-a397-3c6fd3f2a5de", "name": null, "subnet_id": "b8f91ccb-fbdb-413f-aef8-2eb730b08748", "ip_address": "172.25.0.6", "mac_address": "1A:F0:96:8C:84:45"}]	["eb4f6b60-a2c4-4873-b844-a3b798f8a20c"]	[{"id": "11b68d97-89db-4fc3-8280-a9bcee8fcd58", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:00:00.281928150Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 07:00:00.28193+00	2025-11-17 07:00:15.546214+00	f
6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3	22a997ff-3635-4693-87d8-7e5de31cef68	172.25.0.4	e51bd5d0ec3c	NetVisor daemon	{"type": "None"}	[{"id": "9d90afbf-8e3c-4998-8d43-6169d486cc5b", "name": "eth0", "subnet_id": "b8f91ccb-fbdb-413f-aef8-2eb730b08748", "ip_address": "172.25.0.4", "mac_address": "F2:F5:1D:32:92:69"}]	["dd30e7a4-310f-489a-b121-6bf54bd5c80f"]	[{"id": "53524a27-c22e-4918-aa3f-da2d4df76a7d", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:59:42.716770788Z", "type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0"}]}	null	2025-11-17 06:59:42.615915+00	2025-11-17 06:59:42.724384+00	f
ff3786e7-d53d-4c46-9075-820a8b32d6ac	22a997ff-3635-4693-87d8-7e5de31cef68	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "e4bb23be-5732-42cc-b575-076addd7b537", "name": null, "subnet_id": "b8f91ccb-fbdb-413f-aef8-2eb730b08748", "ip_address": "172.25.0.3", "mac_address": "FA:19:71:25:9B:C0"}]	["99f6b5d2-5593-4561-9d1f-c6c099510f6c"]	[{"id": "41d534ab-ca3b-430e-85bf-4bc276c777ca", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:59:44.949874240Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 06:59:44.949877+00	2025-11-17 07:00:00.163662+00	f
9a3f5b4e-edcd-46da-8b42-8d50194122c2	22a997ff-3635-4693-87d8-7e5de31cef68	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "8150a5c6-b02f-4f37-bf59-57038fb4c1d0", "name": null, "subnet_id": "b8f91ccb-fbdb-413f-aef8-2eb730b08748", "ip_address": "172.25.0.1", "mac_address": "5A:AE:7B:2D:6A:19"}]	["ab686f9e-152a-4e4c-a17b-2089031e5c0f", "8769cbe8-4067-45ae-ae54-97e17edbf03d"]	[{"id": "7a206083-e4ab-425d-a852-652dc2739a71", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "91de8fbc-2f48-426f-af39-bdb7c658c444", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "8874cdd2-2ffa-4e5f-ba78-9639580f23c3", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T07:00:21.697197607Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 07:00:21.6972+00	2025-11-17 07:00:36.812442+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
22a997ff-3635-4693-87d8-7e5de31cef68	My Network	2025-11-17 06:59:42.587975+00	2025-11-17 06:59:42.587975+00	f	f740af95-cd23-4a54-8901-9277c765a8db
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
f740af95-cd23-4a54-8901-9277c765a8db	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 06:59:38.994932+00	2025-11-17 06:59:42.586475+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
2596da5d-eff6-4877-9578-2ac7f24c87b9	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.589351+00	2025-11-17 06:59:42.589351+00	Cloudflare DNS	8bc6885b-7041-4e32-925a-fd2b2c2ee0f0	[{"id": "59cc0098-6899-46e6-8be3-ed52095eb17d", "type": "Port", "port_id": "cef36a67-17d3-4c7f-9509-165316604267", "interface_id": "b5587d2f-347c-4409-b941-33cb72ce62c8"}]	"Dns Server"	null	{"type": "System"}
b5e44081-2fd9-4638-87b3-dc8a3817b33d	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.589357+00	2025-11-17 06:59:42.589357+00	Google.com	47ba0c25-aed1-49ca-8830-611a2c3601ec	[{"id": "e56352c7-a493-4d8e-8fe6-3175459db473", "type": "Port", "port_id": "e1dbdeab-fb86-40e2-b82e-09a662fe4d05", "interface_id": "1270abbe-ccc3-4d6d-8c77-d2211812f186"}]	"Web Service"	null	{"type": "System"}
5a418ee0-71bb-4885-afdb-f90bc8966cc2	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.589362+00	2025-11-17 06:59:42.589362+00	Mobile Device	e10b6932-96ad-44c9-9026-04df51d82c52	[{"id": "c3aff766-45dc-4908-afe6-208b8f67cc00", "type": "Port", "port_id": "38cfd809-e63c-4574-8117-b7127f2adb6f", "interface_id": "0dcd8b60-d26b-4362-87f3-987c00f41073"}]	"Client"	null	{"type": "System"}
dd30e7a4-310f-489a-b121-6bf54bd5c80f	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.716794+00	2025-11-17 06:59:42.716794+00	NetVisor Daemon API	6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3	[{"id": "88f72301-10b4-4449-8781-ea972b542c2f", "type": "Port", "port_id": "53524a27-c22e-4918-aa3f-da2d4df76a7d", "interface_id": "9d90afbf-8e3c-4998-8d43-6169d486cc5b"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T06:59:42.716793300Z", "type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0"}]}
99f6b5d2-5593-4561-9d1f-c6c099510f6c	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:48.060789+00	2025-11-17 06:59:48.060789+00	NetVisor Server API	ff3786e7-d53d-4c46-9075-820a8b32d6ac	[{"id": "6a4be1cc-9c14-4ea1-910e-d2d674b08e20", "type": "Port", "port_id": "41d534ab-ca3b-430e-85bf-4bc276c777ca", "interface_id": "e4bb23be-5732-42cc-b575-076addd7b537"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T06:59:48.060780175Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
eb4f6b60-a2c4-4873-b844-a3b798f8a20c	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 07:00:15.537175+00	2025-11-17 07:00:15.537175+00	PostgreSQL	b2b9a22f-f662-415d-b752-435eef12b949	[{"id": "6521023d-f66c-4d41-a6e9-50138af1519d", "type": "Port", "port_id": "11b68d97-89db-4fc3-8280-a9bcee8fcd58", "interface_id": "82851a26-4081-4133-a397-3c6fd3f2a5de"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T07:00:15.537168473Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
8769cbe8-4067-45ae-ae54-97e17edbf03d	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 07:00:32.374026+00	2025-11-17 07:00:32.374026+00	Home Assistant	9a3f5b4e-edcd-46da-8b42-8d50194122c2	[{"id": "eab87510-4441-4dec-8d1a-37ef2b08db51", "type": "Port", "port_id": "91de8fbc-2f48-426f-af39-bdb7c658c444", "interface_id": "8150a5c6-b02f-4f37-bf59-57038fb4c1d0"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T07:00:32.374016360Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
ab686f9e-152a-4e4c-a17b-2089031e5c0f	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 07:00:24.729044+00	2025-11-17 07:00:24.729044+00	NetVisor Server API	9a3f5b4e-edcd-46da-8b42-8d50194122c2	[{"id": "cb450678-0553-4816-9751-8f67ddb37dca", "type": "Port", "port_id": "7a206083-e4ab-425d-a852-652dc2739a71", "interface_id": "8150a5c6-b02f-4f37-bf59-57038fb4c1d0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T07:00:24.729035606Z", "type": "Network", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
ad8531b9-b7fc-4021-ad55-7e26f3a4b96f	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.589249+00	2025-11-17 06:59:42.589249+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
860f6d2f-4970-45a4-a654-31e09eea82c3	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.589254+00	2025-11-17 06:59:42.589254+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
b8f91ccb-fbdb-413f-aef8-2eb730b08748	22a997ff-3635-4693-87d8-7e5de31cef68	2025-11-17 06:59:42.667977+00	2025-11-17 06:59:42.667977+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T06:59:42.667976091Z", "type": "SelfReport", "host_id": "6cc7c3c4-247d-44ac-8f51-917dd2a1b5b3", "daemon_id": "5d4ecaa2-0db8-4742-b195-76b8752c49e0"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
06e7c766-128a-41e8-b769-5a0b7c985cce	2025-11-17 06:59:38.997112+00	2025-11-17 06:59:42.574959+00	$argon2id$v=19$m=19456,t=2,p=1$Qy6fI2gRJx4oXI2hT2CoFQ$mDxyIvsFvwP5TLwU+Qjrle9pZWl9P+3lPVe/GdHwlfE	\N	\N	\N	user@example.com	f740af95-cd23-4a54-8901-9277c765a8db	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
qYCEwV8uE432lV54YV0ZAw	\\x93c41003195d61785e95f68d132e5fc18480a981a7757365725f6964d92430366537633736362d313238612d343165382d623736392d35613062376339383563636599cd07e9cd015f063b2ace225d0dc7000000	2025-12-17 06:59:42.576523+00
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

\unrestrict jHmmw0cye83hU4jUO6qqUzUXuIXfgT65XVSQlLuiW2W9ejVy3SJJLwFdfWwQkDe

