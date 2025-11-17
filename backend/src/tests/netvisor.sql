--
-- PostgreSQL database dump
--

\restrict Q9g02hmlM4eb2eGLxCiTUJ3VyGardmXsSFVb5rBiDvUajWlWItFIFYp3YBuhGFV

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
    updated_at timestamp with time zone DEFAULT now() NOT NULL
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
20251006215000	users	2025-11-17 02:17:35.430284+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3483844
20251006215100	networks	2025-11-17 02:17:35.43446+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3834137
20251006215151	create hosts	2025-11-17 02:17:35.43866+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3851509
20251006215155	create subnets	2025-11-17 02:17:35.442875+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3687143
20251006215201	create groups	2025-11-17 02:17:35.446935+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3792640
20251006215204	create daemons	2025-11-17 02:17:35.45108+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4296569
20251006215212	create services	2025-11-17 02:17:35.455736+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4711642
20251029193448	user-auth	2025-11-17 02:17:35.460828+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3575845
20251030044828	daemon api	2025-11-17 02:17:35.464748+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1529622
20251030170438	host-hide	2025-11-17 02:17:35.466574+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1098327
20251102224919	create discovery	2025-11-17 02:17:35.467965+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9262435
20251106235621	normalize-daemon-cols	2025-11-17 02:17:35.477531+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1729795
20251107034459	api keys	2025-11-17 02:17:35.479557+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7329522
20251107222650	oidc-auth	2025-11-17 02:17:35.487195+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21031724
20251110181948	orgs-billing	2025-11-17 02:17:35.508545+00	t	\\x258402b31e856f2c8acb1f1222eba03a95e9a8178ac614b01d1ccf43618a0178f5a65b7d067a001e35b7e8cd5749619f	10279391
20251113223656	group-enhancements	2025-11-17 02:17:35.519158+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1027575
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
ffba730c-04d0-473a-9b69-e0cd67faf185	47c05d918d4843aaa900bcb1623585f4	71cb7e09-5aa2-4f92-8be4-82d29040de69	Integrated Daemon API Key	2025-11-17 02:17:38.665468+00	2025-11-17 02:18:32.269426+00	2025-11-17 02:18:32.269095+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
2f1adbf6-d761-47a2-9d03-ca4160915538	71cb7e09-5aa2-4f92-8be4-82d29040de69	811074a1-d751-4895-89a4-7f29fd7e6f93	"172.25.0.4"	60073	2025-11-17 02:17:38.71703+00	2025-11-17 02:17:38.717029+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232"]}	2025-11-17 02:17:38.733275+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
e8742ee4-d6fc-4794-ba6e-4adf32685c90	71cb7e09-5aa2-4f92-8be4-82d29040de69	2f1adbf6-d761-47a2-9d03-ca4160915538	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93"}	Self Report @ 172.25.0.4	2025-11-17 02:17:38.718652+00	2025-11-17 02:17:38.718652+00
daa0f034-422d-4db8-a3d5-56f15449cc8f	71cb7e09-5aa2-4f92-8be4-82d29040de69	2f1adbf6-d761-47a2-9d03-ca4160915538	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-17 02:17:38.724068+00	2025-11-17 02:17:38.724068+00
e9307d1f-5419-4fbf-8bc9-eb8e30bc833b	71cb7e09-5aa2-4f92-8be4-82d29040de69	2f1adbf6-d761-47a2-9d03-ca4160915538	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "processed": 1, "network_id": "71cb7e09-5aa2-4f92-8be4-82d29040de69", "session_id": "56d51476-e754-48cb-b924-dc5cfadbb209", "started_at": "2025-11-17T02:17:38.723746615Z", "finished_at": "2025-11-17T02:17:38.779321076Z", "discovery_type": {"type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93"}	Discovery Run	2025-11-17 02:17:38.723746+00	2025-11-17 02:17:38.780795+00
5bad367e-9035-47b1-8279-e896c471aa41	71cb7e09-5aa2-4f92-8be4-82d29040de69	2f1adbf6-d761-47a2-9d03-ca4160915538	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "processed": 13, "network_id": "71cb7e09-5aa2-4f92-8be4-82d29040de69", "session_id": "d7e0d658-017b-4fc2-9385-bdda1b499dce", "started_at": "2025-11-17T02:17:38.787995195Z", "finished_at": "2025-11-17T02:18:32.268286877Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-17 02:17:38.787995+00	2025-11-17 02:18:32.269345+00
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
9cfefacc-dca0-4686-8dc8-dc607fc8c6fa	71cb7e09-5aa2-4f92-8be4-82d29040de69	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "cbd28939-3fac-4955-8315-359526d3e860"}	[{"id": "2e125260-4bef-485b-9c58-aa38e75c8dd3", "name": "Internet", "subnet_id": "27c53d33-b49c-4b4a-b55d-555b7659b34d", "ip_address": "1.1.1.1", "mac_address": null}]	["3e965646-c235-48ad-b9a6-8357ab843401"]	[{"id": "d0f96d5f-0f83-426f-b560-25512b5059e4", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-17 02:17:38.647522+00	2025-11-17 02:17:38.656403+00	f
f19267c6-7766-4289-bb37-de6a823547bf	71cb7e09-5aa2-4f92-8be4-82d29040de69	Google.com	\N	\N	{"type": "ServiceBinding", "config": "af71a8bb-3f1e-40a2-9560-ce887f46b3cf"}	[{"id": "9d797655-5b79-41d9-9387-c1e75013ea61", "name": "Internet", "subnet_id": "27c53d33-b49c-4b4a-b55d-555b7659b34d", "ip_address": "203.0.113.227", "mac_address": null}]	["a098a7f7-ac8c-421c-b8ae-0800238d0f5a"]	[{"id": "f246fddd-c9be-4510-8c04-111275b65cf1", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 02:17:38.647537+00	2025-11-17 02:17:38.661145+00	f
89db522c-6e33-4839-8f6f-0fb95e4e12d3	71cb7e09-5aa2-4f92-8be4-82d29040de69	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "5ae87be4-9d85-428e-8638-ad15be2eeeb0"}	[{"id": "9b5bc0c1-de34-415e-8103-923286383af7", "name": "Remote Network", "subnet_id": "8a5549a9-b92e-4802-baa3-243150acb782", "ip_address": "203.0.113.218", "mac_address": null}]	["1737662f-7607-411a-a80a-3d2e4db17af3"]	[{"id": "68e8fac9-c190-4436-92e8-1fe60f4dec93", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-17 02:17:38.647545+00	2025-11-17 02:17:38.664726+00	f
d636cde5-dc24-44e0-a84a-d71ab93c9374	71cb7e09-5aa2-4f92-8be4-82d29040de69	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "77bd6642-a9f8-496c-b661-af81cdc0d420", "name": null, "subnet_id": "ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232", "ip_address": "172.25.0.6", "mac_address": "92:51:8B:FC:44:BB"}]	["7fc3a271-8818-40f2-ad59-918d6b960bc3"]	[{"id": "e208ee18-ce2f-4515-aece-2ff6820eb387", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T02:17:55.743865992Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 02:17:55.743868+00	2025-11-17 02:18:10.174126+00	f
811074a1-d751-4895-89a4-7f29fd7e6f93	71cb7e09-5aa2-4f92-8be4-82d29040de69	172.25.0.4	8a87151a0f68	NetVisor daemon	{"type": "None"}	[{"id": "be7554f3-481f-4614-8a85-ffcb4f771891", "name": "eth0", "subnet_id": "ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232", "ip_address": "172.25.0.4", "mac_address": "96:1B:83:72:47:F7"}]	["496f6ed4-5c27-4275-ac7c-f5e3b9814c01"]	[{"id": "8ddd8a5e-78bd-4768-a9db-1f65b2fa8d6d", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T02:17:38.735130234Z", "type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538"}]}	null	2025-11-17 02:17:38.673169+00	2025-11-17 02:17:38.777105+00	f
65e76d3b-c2ca-4b10-91f0-253007db4703	71cb7e09-5aa2-4f92-8be4-82d29040de69	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8032eda5-294f-4eb0-8406-fd3dcfdcabff", "name": null, "subnet_id": "ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232", "ip_address": "172.25.0.3", "mac_address": "02:9C:C8:DF:E2:43"}]	["8dab8d7a-a13d-458d-8c57-c5bbed46bb14"]	[{"id": "8e4d2b99-b64d-448b-b7ea-026122118881", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T02:17:40.934631215Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 02:17:40.934634+00	2025-11-17 02:17:55.577692+00	f
94974170-dcea-4735-bba0-ff16b678a483	71cb7e09-5aa2-4f92-8be4-82d29040de69	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "bac26c73-c50c-4935-8377-2d90d7648e51", "name": null, "subnet_id": "ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232", "ip_address": "172.25.0.1", "mac_address": "A6:AC:20:31:DC:26"}]	["43de0249-a90e-49df-84a6-c01a66bb9afb", "f4e7134c-9629-45d6-aef4-4763e0a20134"]	[{"id": "15821f09-b378-4e56-9980-4dd89d1876f8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "9523db94-23d9-44ba-bb73-528be15e2b12", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "33ae2e75-0a19-430e-a97d-f1e4cb66f6d4", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-17T02:18:18.305117734Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-17 02:18:18.30512+00	2025-11-17 02:18:32.266266+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
71cb7e09-5aa2-4f92-8be4-82d29040de69	My Network	2025-11-17 02:17:38.646134+00	2025-11-17 02:17:38.646134+00	f	fea957e6-5c75-4e6d-acd1-4c58ae3642f8
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
fea957e6-5c75-4e6d-acd1-4c58ae3642f8	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	null	2025-11-17 02:17:35.574365+00	2025-11-17 02:17:38.644483+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
3e965646-c235-48ad-b9a6-8357ab843401	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.647526+00	2025-11-17 02:17:38.647526+00	Cloudflare DNS	9cfefacc-dca0-4686-8dc8-dc607fc8c6fa	[{"id": "cbd28939-3fac-4955-8315-359526d3e860", "type": "Port", "port_id": "d0f96d5f-0f83-426f-b560-25512b5059e4", "interface_id": "2e125260-4bef-485b-9c58-aa38e75c8dd3"}]	"Dns Server"	null	{"type": "System"}
a098a7f7-ac8c-421c-b8ae-0800238d0f5a	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.647539+00	2025-11-17 02:17:38.647539+00	Google.com	f19267c6-7766-4289-bb37-de6a823547bf	[{"id": "af71a8bb-3f1e-40a2-9560-ce887f46b3cf", "type": "Port", "port_id": "f246fddd-c9be-4510-8c04-111275b65cf1", "interface_id": "9d797655-5b79-41d9-9387-c1e75013ea61"}]	"Web Service"	null	{"type": "System"}
1737662f-7607-411a-a80a-3d2e4db17af3	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.647547+00	2025-11-17 02:17:38.647547+00	Mobile Device	89db522c-6e33-4839-8f6f-0fb95e4e12d3	[{"id": "5ae87be4-9d85-428e-8638-ad15be2eeeb0", "type": "Port", "port_id": "68e8fac9-c190-4436-92e8-1fe60f4dec93", "interface_id": "9b5bc0c1-de34-415e-8103-923286383af7"}]	"Client"	null	{"type": "System"}
496f6ed4-5c27-4275-ac7c-f5e3b9814c01	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.735148+00	2025-11-17 02:17:38.735148+00	NetVisor Daemon API	811074a1-d751-4895-89a4-7f29fd7e6f93	[{"id": "5105ba4a-0c23-4e6b-a1e8-739378601f0c", "type": "Port", "port_id": "8ddd8a5e-78bd-4768-a9db-1f65b2fa8d6d", "interface_id": "be7554f3-481f-4614-8a85-ffcb4f771891"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-17T02:17:38.735147346Z", "type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538"}]}
8dab8d7a-a13d-458d-8c57-c5bbed46bb14	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:43.919623+00	2025-11-17 02:17:43.919623+00	NetVisor Server API	65e76d3b-c2ca-4b10-91f0-253007db4703	[{"id": "aed28a9c-fe43-4cdf-a05b-5a0eedc79b5e", "type": "Port", "port_id": "8e4d2b99-b64d-448b-b7ea-026122118881", "interface_id": "8032eda5-294f-4eb0-8406-fd3dcfdcabff"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T02:17:43.919615605Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7fc3a271-8818-40f2-ad59-918d6b960bc3	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:18:10.14391+00	2025-11-17 02:18:10.14391+00	PostgreSQL	d636cde5-dc24-44e0-a84a-d71ab93c9374	[{"id": "b0e2f2df-5756-4b71-8fe6-765203c5facf", "type": "Port", "port_id": "e208ee18-ce2f-4515-aece-2ff6820eb387", "interface_id": "77bd6642-a9f8-496c-b661-af81cdc0d420"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-17T02:18:10.143903261Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
f4e7134c-9629-45d6-aef4-4763e0a20134	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:18:21.072288+00	2025-11-17 02:18:21.072288+00	NetVisor Server API	94974170-dcea-4735-bba0-ff16b678a483	[{"id": "0fc2f4bf-d7a7-4db7-bcc3-9923f736ef9c", "type": "Port", "port_id": "9523db94-23d9-44ba-bb73-528be15e2b12", "interface_id": "bac26c73-c50c-4935-8377-2d90d7648e51"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T02:18:21.072282184Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
43de0249-a90e-49df-84a6-c01a66bb9afb	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:18:20.383149+00	2025-11-17 02:18:20.383149+00	Home Assistant	94974170-dcea-4735-bba0-ff16b678a483	[{"id": "33305891-88b6-406d-ad64-75c94accac03", "type": "Port", "port_id": "15821f09-b378-4e56-9980-4dd89d1876f8", "interface_id": "bac26c73-c50c-4935-8377-2d90d7648e51"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-17T02:18:20.383140372Z", "type": "Network", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
27c53d33-b49c-4b4a-b55d-555b7659b34d	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.647451+00	2025-11-17 02:17:38.647451+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
8a5549a9-b92e-4802-baa3-243150acb782	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.647455+00	2025-11-17 02:17:38.647455+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
ad511e14-b9a8-4fbb-8f7f-bf7a4a42f232	71cb7e09-5aa2-4f92-8be4-82d29040de69	2025-11-17 02:17:38.723901+00	2025-11-17 02:17:38.723901+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-17T02:17:38.723900261Z", "type": "SelfReport", "host_id": "811074a1-d751-4895-89a4-7f29fd7e6f93", "daemon_id": "2f1adbf6-d761-47a2-9d03-ca4160915538"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions) FROM stdin;
bbd7651a-c19f-4801-b5a6-e81ce8a83816	2025-11-17 02:17:35.576465+00	2025-11-17 02:17:38.633043+00	$argon2id$v=19$m=19456,t=2,p=1$XMy37p2OZWo82gI7jTJYHA$f2vaCu+SBxgbYthZlv+L8rbOKJYeEAraiaYpwJqLEHE	\N	\N	\N	user@example.com	fea957e6-5c75-4e6d-acd1-4c58ae3642f8	"Owner"
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
19MSd943ZOlqW2-ge6lU1A	\\x93c410d454a97ba06f5b6ae96437de7712d3d781a7757365725f6964d92462626437363531612d633139662d343830312d623561362d65383163653861383338313699cd07e9cd015f021126ce25d5090b000000	2025-12-17 02:17:38.634718+00
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

\unrestrict Q9g02hmlM4eb2eGLxCiTUJ3VyGardmXsSFVb5rBiDvUajWlWItFIFYp3YBuhGFV

