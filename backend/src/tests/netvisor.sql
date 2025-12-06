--
-- PostgreSQL database dump
--

\restrict uVSwFoKoYGgXcGuzkQ2Gq0qo04ZhDlRKHO5jLbTo6hH5ZSAe9H1crjuzZAqo4Iw

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
20251006215000	users	2025-12-06 21:35:54.912332+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3543586
20251006215100	networks	2025-12-06 21:35:54.9166+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3818827
20251006215151	create hosts	2025-12-06 21:35:54.921354+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3949998
20251006215155	create subnets	2025-12-06 21:35:54.925652+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3761026
20251006215201	create groups	2025-12-06 21:35:54.929802+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3808976
20251006215204	create daemons	2025-12-06 21:35:54.934022+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4332229
20251006215212	create services	2025-12-06 21:35:54.938719+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4979188
20251029193448	user-auth	2025-12-06 21:35:54.944016+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3626224
20251030044828	daemon api	2025-12-06 21:35:54.948002+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1646431
20251030170438	host-hide	2025-12-06 21:35:54.950004+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1175345
20251102224919	create discovery	2025-12-06 21:35:54.951596+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9589874
20251106235621	normalize-daemon-cols	2025-12-06 21:35:54.961549+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1819712
20251107034459	api keys	2025-12-06 21:35:54.963705+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8452455
20251107222650	oidc-auth	2025-12-06 21:35:54.972619+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20331811
20251110181948	orgs-billing	2025-12-06 21:35:54.993307+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10207653
20251113223656	group-enhancements	2025-12-06 21:35:55.004009+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1315625
20251117032720	daemon-mode	2025-12-06 21:35:55.005748+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1160515
20251118143058	set-default-plan	2025-12-06 21:35:55.007192+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1188116
20251118225043	save-topology	2025-12-06 21:35:55.008678+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8907949
20251123232748	network-permissions	2025-12-06 21:35:55.01798+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2904451
20251125001342	billing-updates	2025-12-06 21:35:55.021207+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	891740
20251128035448	org-onboarding-status	2025-12-06 21:35:55.022377+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1472379
20251129180942	nfs-consolidate	2025-12-06 21:35:55.024187+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1193837
20251206052641	discovery-progress	2025-12-06 21:35:55.025662+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1400303
20251206202200	plan-fix	2025-12-06 21:35:55.027349+00	t	\\xe1bfa644a807fae288a303a434b51bc08fbce322018b12387335f1aa0d53d32ae0958e37cd24ea0486fa5a0812aca33c	1085944
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
20dca7aa-a489-461f-92b9-30e30c7f4031	b5831a8b0ef241e289bf596979a91b4f	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	Integrated Daemon API Key	2025-12-06 21:35:58.219923+00	2025-12-06 21:37:33.429755+00	2025-12-06 21:37:33.428972+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
24b3f945-07d8-414d-8dbe-3eb3efe2ffcb	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	f06053be-5f01-42e6-a764-3e4040abaa9f	"172.25.0.4"	60073	2025-12-06 21:35:58.272595+00	2025-12-06 21:37:14.102894+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["dac9933f-348f-4aa9-bdb9-2ecfe7044545"]}	2025-12-06 21:37:14.103797+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
942db465-9b1a-45a7-abc6-8221e0909d6e	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	24b3f945-07d8-414d-8dbe-3eb3efe2ffcb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f"}	Self Report @ 172.25.0.4	2025-12-06 21:35:58.279641+00	2025-12-06 21:35:58.279641+00
63d84a17-be97-45c6-a8b2-651353fea61a	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	24b3f945-07d8-414d-8dbe-3eb3efe2ffcb	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-12-06 21:35:58.286724+00	2025-12-06 21:35:58.286724+00
ee215db0-548e-4c0b-bd22-ef1d9fdf3d25	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	24b3f945-07d8-414d-8dbe-3eb3efe2ffcb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "session_id": "093d237a-b0b5-4964-a86e-f2b21bb3a623", "started_at": "2025-12-06T21:35:58.286321083Z", "finished_at": "2025-12-06T21:35:58.392401483Z", "discovery_type": {"type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f"}}}	{"type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f"}	Discovery Run	2025-12-06 21:35:58.286321+00	2025-12-06 21:35:58.396175+00
98143c88-70eb-4ce9-88d2-e470e0d683fb	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	24b3f945-07d8-414d-8dbe-3eb3efe2ffcb	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "session_id": "095de0d2-0b2b-4d85-beb3-66e12aecb507", "started_at": "2025-12-06T21:35:58.410133905Z", "finished_at": "2025-12-06T21:37:33.426849117Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-12-06 21:35:58.410133+00	2025-12-06 21:37:33.42921+00
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
3394a23d-4a1b-47b2-89b0-4c834e32601b	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "8079d6b9-6dd1-4d23-8d1e-f0203857b5b8"}	[{"id": "e92421bc-8cb8-48dd-9420-ef6480c46111", "name": "Internet", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "ip_address": "1.1.1.1", "mac_address": null}]	{0d80b056-4878-41ec-bca9-64e508b293a2}	[{"id": "5fa84013-db8b-4560-a720-02cca9948754", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-06 21:35:58.194022+00	2025-12-06 21:35:58.203627+00	f
a78d46f5-afd4-440c-ba15-689b3a15e1bc	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	Google.com	\N	\N	{"type": "ServiceBinding", "config": "066dfbc6-c7c4-46c1-bc5d-d4aa8343b760"}	[{"id": "cac53afc-068c-4547-a9c2-edb82a102f8d", "name": "Internet", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "ip_address": "203.0.113.102", "mac_address": null}]	{8ebe4e58-a99f-4d71-87b9-d9c7558b8c28}	[{"id": "b8344445-ccdd-4815-b069-f1c99117ac00", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 21:35:58.194028+00	2025-12-06 21:35:58.208692+00	f
e1ac2199-8e4d-4ce7-8db9-2f4761211d69	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "3d913ca9-1edf-476b-97b0-e67c45e04cb4"}	[{"id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66", "name": "Remote Network", "subnet_id": "a54eadae-84b1-431e-a041-d8cfa238b206", "ip_address": "203.0.113.110", "mac_address": null}]	{e1d21f6b-2e1a-4094-9ae6-55670cbfa5fa}	[{"id": "fe15be9a-c728-41fd-869c-b25ddc08ae6c", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 21:35:58.194034+00	2025-12-06 21:35:58.21284+00	f
2c8a980f-c40d-4726-97ab-bc4ef7379dfc	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "2da10592-6277-4411-9d5c-876e6505c0e2", "name": null, "subnet_id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "ip_address": "172.25.0.6", "mac_address": "56:D6:8B:F8:DE:B8"}]	{413f36ee-2aa5-4cf2-a238-fb04446b760d}	[{"id": "eb6d5a14-22d1-4c68-b9cc-570b275be963", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:36:44.652188882Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 21:36:44.65219+00	2025-12-06 21:36:58.921599+00	f
f06053be-5f01-42e6-a764-3e4040abaa9f	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	172.25.0.4	665accb109de	NetVisor daemon	{"type": "None"}	[{"id": "1b636572-738c-4fb1-a7ae-e32a8559478f", "name": "eth0", "subnet_id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "ip_address": "172.25.0.4", "mac_address": "22:B6:82:8D:4C:84"}]	{7b248b68-d15b-468f-91f6-a6bdc9fb60c7}	[{"id": "f7997ceb-8907-447e-937d-dde3b5657f7e", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:35:58.370226580Z", "type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb"}]}	null	2025-12-06 21:35:58.269797+00	2025-12-06 21:35:58.389005+00	f
ab3e2de1-0e28-435f-a3ba-b8334561c416	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "1410fcf8-234c-4da7-bc29-542e04f30c1b", "name": null, "subnet_id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "ip_address": "172.25.0.3", "mac_address": "5A:3F:48:2B:ED:7F"}]	{346e1c4a-06f7-4a4c-a90b-9f6f961c9a6e}	[{"id": "6e6c01a4-4d94-40f9-bd9a-025ed6e35626", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:36:30.227299924Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 21:36:30.227302+00	2025-12-06 21:36:44.582226+00	f
ceed04bf-e2a5-4249-ba25-ced7bd5a4812	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8affd717-7b2d-43c1-aa21-79036d738e98", "name": null, "subnet_id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "ip_address": "172.25.0.5", "mac_address": "D2:26:5E:9B:D9:C6"}]	{}	[{"id": "8476f1f6-0217-4a52-ba19-3f89a85f7bfa", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c69c10f8-dd1a-41e1-883a-fd51ac0837e6", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:36:58.913621627Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 21:36:58.913623+00	2025-12-06 21:37:13.170372+00	f
b667e4a5-b0aa-4305-a6b6-c121fd9b3b46	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "9eb771e8-5552-420c-80f1-9c4f8e7acc84", "name": null, "subnet_id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "ip_address": "172.25.0.1", "mac_address": "1E:86:FC:3E:48:FE"}]	{cfbf8238-c136-40e4-a3eb-30b37c1bf760,2d3f32e7-bb68-46c6-a366-c6d6bb4e9dd2}	[{"id": "e262adbd-9fbd-45df-8e4d-c5f61c17e6aa", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "62f11d13-348f-49d9-b83f-4472a4c0c988", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "89592df1-e9f4-410a-b125-748d36c59627", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "833fba02-8b98-4d52-8eb0-e54f735306e4", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:37:19.211209810Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 21:37:19.211212+00	2025-12-06 21:37:33.420553+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
ed6b0f6f-d24f-4e5d-8913-964c4309cc14	My Network	2025-12-06 21:35:58.192752+00	2025-12-06 21:35:58.192752+00	f	ef47eb4c-4e15-460e-8796-23c62e17a3b9
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
ef47eb4c-4e15-460e-8796-23c62e17a3b9	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-06 21:35:55.08319+00	2025-12-06 21:35:58.278476+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
0d80b056-4878-41ec-bca9-64e508b293a2	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.194023+00	2025-12-06 21:35:58.194023+00	Cloudflare DNS	3394a23d-4a1b-47b2-89b0-4c834e32601b	[{"id": "8079d6b9-6dd1-4d23-8d1e-f0203857b5b8", "type": "Port", "port_id": "5fa84013-db8b-4560-a720-02cca9948754", "interface_id": "e92421bc-8cb8-48dd-9420-ef6480c46111"}]	"Dns Server"	null	{"type": "System"}
8ebe4e58-a99f-4d71-87b9-d9c7558b8c28	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.194029+00	2025-12-06 21:35:58.194029+00	Google.com	a78d46f5-afd4-440c-ba15-689b3a15e1bc	[{"id": "066dfbc6-c7c4-46c1-bc5d-d4aa8343b760", "type": "Port", "port_id": "b8344445-ccdd-4815-b069-f1c99117ac00", "interface_id": "cac53afc-068c-4547-a9c2-edb82a102f8d"}]	"Web Service"	null	{"type": "System"}
e1d21f6b-2e1a-4094-9ae6-55670cbfa5fa	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.194036+00	2025-12-06 21:35:58.194036+00	Mobile Device	e1ac2199-8e4d-4ce7-8db9-2f4761211d69	[{"id": "3d913ca9-1edf-476b-97b0-e67c45e04cb4", "type": "Port", "port_id": "fe15be9a-c728-41fd-869c-b25ddc08ae6c", "interface_id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66"}]	"Client"	null	{"type": "System"}
7b248b68-d15b-468f-91f6-a6bdc9fb60c7	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.370249+00	2025-12-06 21:35:58.370249+00	NetVisor Daemon API	f06053be-5f01-42e6-a764-3e4040abaa9f	[{"id": "8de18d21-dc85-4fd3-976e-f2e435db4b13", "type": "Port", "port_id": "f7997ceb-8907-447e-937d-dde3b5657f7e", "interface_id": "1b636572-738c-4fb1-a7ae-e32a8559478f"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-06T21:35:58.370248361Z", "type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb"}]}
346e1c4a-06f7-4a4c-a90b-9f6f961c9a6e	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:36:43.863751+00	2025-12-06 21:36:43.863751+00	NetVisor Server API	ab3e2de1-0e28-435f-a3ba-b8334561c416	[{"id": "d02bf7b7-2de1-47ec-ba6f-a40a9d160d14", "type": "Port", "port_id": "6e6c01a4-4d94-40f9-bd9a-025ed6e35626", "interface_id": "1410fcf8-234c-4da7-bc29-542e04f30c1b"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T21:36:43.863734685Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
413f36ee-2aa5-4cf2-a238-fb04446b760d	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:36:58.910797+00	2025-12-06 21:36:58.910797+00	PostgreSQL	2c8a980f-c40d-4726-97ab-bc4ef7379dfc	[{"id": "fe7cf9ef-e863-4a16-928a-a8620ced6f94", "type": "Port", "port_id": "eb6d5a14-22d1-4c68-b9cc-570b275be963", "interface_id": "2da10592-6277-4411-9d5c-876e6505c0e2"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T21:36:58.910779282Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
cfbf8238-c136-40e4-a3eb-30b37c1bf760	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:37:32.686941+00	2025-12-06 21:37:32.686941+00	NetVisor Server API	b667e4a5-b0aa-4305-a6b6-c121fd9b3b46	[{"id": "b4ae5a79-4fb1-44c6-85e3-07d2b604dec4", "type": "Port", "port_id": "e262adbd-9fbd-45df-8e4d-c5f61c17e6aa", "interface_id": "9eb771e8-5552-420c-80f1-9c4f8e7acc84"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T21:37:32.686922274Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
2d3f32e7-bb68-46c6-a366-c6d6bb4e9dd2	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:37:33.407893+00	2025-12-06 21:37:33.407893+00	Home Assistant	b667e4a5-b0aa-4305-a6b6-c121fd9b3b46	[{"id": "7c180ed7-35d8-4be9-a522-827d55699e73", "type": "Port", "port_id": "62f11d13-348f-49d9-b83f-4472a4c0c988", "interface_id": "9eb771e8-5552-420c-80f1-9c4f8e7acc84"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T21:37:33.407875198Z", "type": "Network", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
887161a3-8ba9-457e-867f-94f103ae0d96	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.193972+00	2025-12-06 21:35:58.193972+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
a54eadae-84b1-431e-a041-d8cfa238b206	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.193977+00	2025-12-06 21:35:58.193977+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
dac9933f-348f-4aa9-bdb9-2ecfe7044545	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	2025-12-06 21:35:58.2865+00	2025-12-06 21:35:58.2865+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-06T21:35:58.286498335Z", "type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
3c666494-223c-4911-9268-1b0513dd8adb	ed6b0f6f-d24f-4e5d-8913-964c4309cc14	My Topology	[]	[{"id": "a54eadae-84b1-431e-a041-d8cfa238b206", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "887161a3-8ba9-457e-867f-94f103ae0d96", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "e92421bc-8cb8-48dd-9420-ef6480c46111", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3394a23d-4a1b-47b2-89b0-4c834e32601b", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "interface_id": "e92421bc-8cb8-48dd-9420-ef6480c46111"}, {"id": "cac53afc-068c-4547-a9c2-edb82a102f8d", "size": {"x": 250, "y": 100}, "header": null, "host_id": "a78d46f5-afd4-440c-ba15-689b3a15e1bc", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "interface_id": "cac53afc-068c-4547-a9c2-edb82a102f8d"}, {"id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66", "size": {"x": 250, "y": 100}, "header": null, "host_id": "e1ac2199-8e4d-4ce7-8db9-2f4761211d69", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "a54eadae-84b1-431e-a041-d8cfa238b206", "interface_id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "3394a23d-4a1b-47b2-89b0-4c834e32601b", "name": "Cloudflare DNS", "ports": [{"id": "5fa84013-db8b-4560-a720-02cca9948754", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "8079d6b9-6dd1-4d23-8d1e-f0203857b5b8"}, "hostname": null, "services": ["0d80b056-4878-41ec-bca9-64e508b293a2"], "created_at": "2025-12-06T21:35:58.194022Z", "interfaces": [{"id": "e92421bc-8cb8-48dd-9420-ef6480c46111", "name": "Internet", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.203627Z", "description": null, "virtualization": null}, {"id": "a78d46f5-afd4-440c-ba15-689b3a15e1bc", "name": "Google.com", "ports": [{"id": "b8344445-ccdd-4815-b069-f1c99117ac00", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "066dfbc6-c7c4-46c1-bc5d-d4aa8343b760"}, "hostname": null, "services": ["8ebe4e58-a99f-4d71-87b9-d9c7558b8c28"], "created_at": "2025-12-06T21:35:58.194028Z", "interfaces": [{"id": "cac53afc-068c-4547-a9c2-edb82a102f8d", "name": "Internet", "subnet_id": "887161a3-8ba9-457e-867f-94f103ae0d96", "ip_address": "203.0.113.102", "mac_address": null}], "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.208692Z", "description": null, "virtualization": null}, {"id": "e1ac2199-8e4d-4ce7-8db9-2f4761211d69", "name": "Mobile Device", "ports": [{"id": "fe15be9a-c728-41fd-869c-b25ddc08ae6c", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "3d913ca9-1edf-476b-97b0-e67c45e04cb4"}, "hostname": null, "services": ["e1d21f6b-2e1a-4094-9ae6-55670cbfa5fa"], "created_at": "2025-12-06T21:35:58.194034Z", "interfaces": [{"id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66", "name": "Remote Network", "subnet_id": "a54eadae-84b1-431e-a041-d8cfa238b206", "ip_address": "203.0.113.110", "mac_address": null}], "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.212840Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "887161a3-8ba9-457e-867f-94f103ae0d96", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-06T21:35:58.193972Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.193972Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "a54eadae-84b1-431e-a041-d8cfa238b206", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-06T21:35:58.193977Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.193977Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "dac9933f-348f-4aa9-bdb9-2ecfe7044545", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-06T21:35:58.286498335Z", "type": "SelfReport", "host_id": "f06053be-5f01-42e6-a764-3e4040abaa9f", "daemon_id": "24b3f945-07d8-414d-8dbe-3eb3efe2ffcb"}]}, "created_at": "2025-12-06T21:35:58.286500Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.286500Z", "description": null, "subnet_type": "Lan"}]	[{"id": "0d80b056-4878-41ec-bca9-64e508b293a2", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "3394a23d-4a1b-47b2-89b0-4c834e32601b", "bindings": [{"id": "8079d6b9-6dd1-4d23-8d1e-f0203857b5b8", "type": "Port", "port_id": "5fa84013-db8b-4560-a720-02cca9948754", "interface_id": "e92421bc-8cb8-48dd-9420-ef6480c46111"}], "created_at": "2025-12-06T21:35:58.194023Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.194023Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "8ebe4e58-a99f-4d71-87b9-d9c7558b8c28", "name": "Google.com", "source": {"type": "System"}, "host_id": "a78d46f5-afd4-440c-ba15-689b3a15e1bc", "bindings": [{"id": "066dfbc6-c7c4-46c1-bc5d-d4aa8343b760", "type": "Port", "port_id": "b8344445-ccdd-4815-b069-f1c99117ac00", "interface_id": "cac53afc-068c-4547-a9c2-edb82a102f8d"}], "created_at": "2025-12-06T21:35:58.194029Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.194029Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "e1d21f6b-2e1a-4094-9ae6-55670cbfa5fa", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "e1ac2199-8e4d-4ce7-8db9-2f4761211d69", "bindings": [{"id": "3d913ca9-1edf-476b-97b0-e67c45e04cb4", "type": "Port", "port_id": "fe15be9a-c728-41fd-869c-b25ddc08ae6c", "interface_id": "f54d8178-cd0f-4d8e-ab9f-532596bf4b66"}], "created_at": "2025-12-06T21:35:58.194036Z", "network_id": "ed6b0f6f-d24f-4e5d-8913-964c4309cc14", "updated_at": "2025-12-06T21:35:58.194036Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-06 21:35:58.217223+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-06 21:35:58.213606+00	2025-12-06 21:37:33.495424+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
95e7c520-2e35-47fe-a354-78536196266b	2025-12-06 21:35:55.085069+00	2025-12-06 21:35:58.174728+00	$argon2id$v=19$m=19456,t=2,p=1$fhoyAheRaNEDru6xmxStbQ$S4+XQuwzTM8xCDV5sv205TdmZ+U9njGJasJ9SZbewSM	\N	\N	\N	user@gmail.com	ef47eb4c-4e15-460e-8796-23c62e17a3b9	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
6zcgaVvRfTIxk9eB3ZLR4w	\\x93c410e3d192dd81d79331327dd15b692037eb81a7757365725f6964d92439356537633532302d326533352d343766652d613335342d37383533363139363236366299cd07ea0515233ace0a9333ff000000	2026-01-05 21:35:58.177419+00
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

\unrestrict uVSwFoKoYGgXcGuzkQ2Gq0qo04ZhDlRKHO5jLbTo6hH5ZSAe9H1crjuzZAqo4Iw

