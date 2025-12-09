--
-- PostgreSQL database dump
--

\restrict 48gfgRVYgwF68ZI805xX2hs7L0AMOkhshYXVQK04Kvhv0ySUAsEL1wQhftlxTQe

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
    created_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    capabilities jsonb DEFAULT '{}'::jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    mode text DEFAULT '"Push"'::text,
    url text NOT NULL,
    name text
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
20251006215000	users	2025-12-09 20:23:59.745472+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2589917
20251006215100	networks	2025-12-09 20:23:59.748604+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3031577
20251006215151	create hosts	2025-12-09 20:23:59.751915+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	2751375
20251006215155	create subnets	2025-12-09 20:23:59.754975+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2794943
20251006215201	create groups	2025-12-09 20:23:59.758057+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2704519
20251006215204	create daemons	2025-12-09 20:23:59.761051+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3097636
20251006215212	create services	2025-12-09 20:23:59.764527+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3511215
20251029193448	user-auth	2025-12-09 20:23:59.768281+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	2663429
20251030044828	daemon api	2025-12-09 20:23:59.771176+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1141579
20251030170438	host-hide	2025-12-09 20:23:59.772701+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	807012
20251102224919	create discovery	2025-12-09 20:23:59.773977+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	6873352
20251106235621	normalize-daemon-cols	2025-12-09 20:23:59.78111+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1423558
20251107034459	api keys	2025-12-09 20:23:59.782937+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	5452380
20251107222650	oidc-auth	2025-12-09 20:23:59.788674+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	15583382
20251110181948	orgs-billing	2025-12-09 20:23:59.804526+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	7384822
20251113223656	group-enhancements	2025-12-09 20:23:59.812239+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	834389
20251117032720	daemon-mode	2025-12-09 20:23:59.813307+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1095996
20251118143058	set-default-plan	2025-12-09 20:23:59.814634+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1007053
20251118225043	save-topology	2025-12-09 20:23:59.815866+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	6246574
20251123232748	network-permissions	2025-12-09 20:23:59.822414+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	1960558
20251125001342	billing-updates	2025-12-09 20:23:59.824619+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	713812
20251128035448	org-onboarding-status	2025-12-09 20:23:59.825579+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1039775
20251129180942	nfs-consolidate	2025-12-09 20:23:59.826834+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	931086
20251206052641	discovery-progress	2025-12-09 20:23:59.827978+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1049485
20251206202200	plan-fix	2025-12-09 20:23:59.82924+00	t	\\x242f6699dbf485cf59a8d1b8cd9d7c43aeef635a9316be815a47e15238c5e4af88efaa0daf885be03572948dc0c9edac	915824
20251207061341	daemon-url	2025-12-09 20:23:59.830468+00	t	\\x01172455c4f2d0d57371d18ef66d2ab3b7a8525067ef8a86945c616982e6ce06f5ea1e1560a8f20dadcd5be2223e6df1	1691539
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
2cd6d7b3-f3b1-4f2a-a8d1-48322aad19c7	e54d4f1badd94af3a0a4af1eb93da184	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	Integrated Daemon API Key	2025-12-09 20:24:02.573317+00	2025-12-09 20:25:29.504716+00	2025-12-09 20:25:29.503935+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, created_at, last_seen, capabilities, updated_at, mode, url, name) FROM stdin;
39fb812a-8aae-4597-90d7-171986fae833	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	0ee12ab7-4c38-49c1-a39d-01324a098dda	2025-12-09 20:24:02.666767+00	2025-12-09 20:25:16.331878+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["7a97731d-4937-4134-9459-43e72341eb1f"]}	2025-12-09 20:25:16.332393+00	"Push"	http://172.25.0.4:60073	netvisor-daemon
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
b3eb0031-252b-4511-8c55-1068db084380	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	39fb812a-8aae-4597-90d7-171986fae833	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda"}	Self Report	2025-12-09 20:24:02.673449+00	2025-12-09 20:24:02.673449+00
e00a9b71-bd22-46b8-9420-1b626a9c80d4	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	39fb812a-8aae-4597-90d7-171986fae833	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-09 20:24:02.679845+00	2025-12-09 20:24:02.679845+00
979d5e9f-e840-45bb-83a1-898d8d1f33e5	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	39fb812a-8aae-4597-90d7-171986fae833	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "session_id": "3d5fe363-2034-4a93-966e-564488dd24d1", "started_at": "2025-12-09T20:24:02.679428951Z", "finished_at": "2025-12-09T20:24:02.716505539Z", "discovery_type": {"type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda"}}}	{"type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda"}	Self Report	2025-12-09 20:24:02.679428+00	2025-12-09 20:24:02.718917+00
462de823-1e83-4d8a-9594-dc8e879b3153	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	39fb812a-8aae-4597-90d7-171986fae833	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "session_id": "44acafd5-b658-4d6c-b8fb-20f76b6962ec", "started_at": "2025-12-09T20:24:02.757059121Z", "finished_at": "2025-12-09T20:25:29.502220052Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Discovery	2025-12-09 20:24:02.757059+00	2025-12-09 20:25:29.504262+00
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
3ecfeba9-366c-463d-8358-544e96d54eda	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "d6c20d8a-352b-4eaf-afb3-8a0bced938a2"}	[{"id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e", "name": "Internet", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "ip_address": "1.1.1.1", "mac_address": null}]	{40187e46-8e21-4a6d-b400-3b0377141ceb}	[{"id": "c0eaf456-a61d-4d95-9b1c-4b1c23b52a90", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-09 20:24:02.550567+00	2025-12-09 20:24:02.558461+00	f
0848e934-6852-4a61-9bcf-c80ea12f66af	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	Google.com	\N	\N	{"type": "ServiceBinding", "config": "41b9352f-9ecf-479a-bc66-4bba5265be37"}	[{"id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b", "name": "Internet", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "ip_address": "203.0.113.7", "mac_address": null}]	{e2926fcb-3f7d-4af8-82f7-3a1ef8c0829a}	[{"id": "41520708-b517-49c6-8891-8f6806039cbf", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-09 20:24:02.550572+00	2025-12-09 20:24:02.563092+00	f
0b1f4ff0-4c64-4a76-8c72-ee87cf226ce0	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "af6e9e70-d743-4933-9ed2-76edf7d1c6ec"}	[{"id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6", "name": "Remote Network", "subnet_id": "888e9055-3c43-4c71-bb56-8e876605c372", "ip_address": "203.0.113.69", "mac_address": null}]	{7d6d02ed-3992-42b6-953f-40727f30756d}	[{"id": "e0f5504b-f7f1-46fa-b2bc-4d43a1a2402d", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-09 20:24:02.550576+00	2025-12-09 20:24:02.566751+00	f
81d871e8-84ee-47cc-91b7-a178c9bab803	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "bdc0455b-eff3-4a0a-bc73-9e2a54938859", "name": null, "subnet_id": "7a97731d-4937-4134-9459-43e72341eb1f", "ip_address": "172.25.0.6", "mac_address": "6E:21:6A:DA:53:40"}]	{5618ba21-400e-4791-b537-172ac4ceae0e}	[{"id": "c887e551-f18e-4427-b5e3-5e05d7e4c45b", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:42.234443896Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 20:24:42.234445+00	2025-12-09 20:24:56.324433+00	f
0ee12ab7-4c38-49c1-a39d-01324a098dda	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	netvisor-daemon	9b5bda84be64	NetVisor daemon	{"type": "None"}	[{"id": "01335985-37bc-4295-9411-6a8c26eee601", "name": "eth0", "subnet_id": "7a97731d-4937-4134-9459-43e72341eb1f", "ip_address": "172.25.0.4", "mac_address": "F2:96:06:83:A8:13"}]	{0d8495a2-f096-4204-9c3f-3de7893620a7}	[{"id": "2eb0e1d0-1d29-4883-97bd-9c3a1c09788b", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:02.698492609Z", "type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833"}]}	null	2025-12-09 20:24:02.581004+00	2025-12-09 20:24:02.713448+00	f
90c0a623-3962-4a5c-9c47-d4eb88fd9ec1	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "56282c0d-150d-4bdb-8e15-7ddd0c5db1e4", "name": null, "subnet_id": "7a97731d-4937-4134-9459-43e72341eb1f", "ip_address": "172.25.0.5", "mac_address": "EA:AB:E8:C3:B3:E8"}]	{590d8df1-3151-4916-aaf2-93af4fc8dd39,d3ba8cb8-5c6f-4187-94fb-2e8fb595c9d8}	[{"id": "81d34984-422f-44ce-b6c6-3dbfd4fa44f4", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "e48b5289-d18c-45a1-be24-dd0df73cbcbe", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:27.978161677Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 20:24:27.978164+00	2025-12-09 20:24:42.215109+00	f
6204071d-1f3d-42f8-b7cb-8398bdb6c250	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "22f232c0-a2dc-4a03-9ad2-86710028555f", "name": null, "subnet_id": "7a97731d-4937-4134-9459-43e72341eb1f", "ip_address": "172.25.0.3", "mac_address": "AA:E0:C3:24:B3:DA"}]	{93ccb3e1-260a-4a95-9558-7e7dc9941d40}	[{"id": "309834d3-c203-45c4-8930-fff6c5a11c50", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:56.329385280Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 20:24:56.329387+00	2025-12-09 20:25:10.76306+00	f
da462412-6c0a-48a7-b48e-43f31c58396f	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "8ae96fb9-347a-4412-a3ce-ca7df6d3cab8", "name": null, "subnet_id": "7a97731d-4937-4134-9459-43e72341eb1f", "ip_address": "172.25.0.1", "mac_address": "0A:11:5D:09:8D:D5"}]	{60f12e6f-d784-428a-b0cc-308c9cf72db0,9311bb2f-aada-4eb5-9b56-4a6d343a5141,37b972ba-15b5-4035-bc64-99903d59fb27,4d32b499-e348-4a83-ba8f-015ce2943d10}	[{"id": "23f8ace9-4236-42f0-bb66-c131de648d67", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "0180ad73-7171-4072-8482-f1e039ea0471", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "de01e867-a4a8-4b0d-a961-96c620bcd4dd", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "900f6191-5bc1-4795-bd11-5178d969f33e", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:25:14.805430631Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-09 20:25:14.805433+00	2025-12-09 20:25:29.496984+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
3a27171e-adfc-4290-8b86-5d6cbc6e2aea	My Network	2025-12-09 20:24:02.549363+00	2025-12-09 20:24:02.549363+00	f	73075209-96e7-413a-b4fb-15b9312beca1
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
73075209-96e7-413a-b4fb-15b9312beca1	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-09 20:23:59.876663+00	2025-12-09 20:24:02.671909+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
40187e46-8e21-4a6d-b400-3b0377141ceb	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.550568+00	2025-12-09 20:24:02.550568+00	Cloudflare DNS	3ecfeba9-366c-463d-8358-544e96d54eda	[{"id": "d6c20d8a-352b-4eaf-afb3-8a0bced938a2", "type": "Port", "port_id": "c0eaf456-a61d-4d95-9b1c-4b1c23b52a90", "interface_id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e"}]	"Dns Server"	null	{"type": "System"}
e2926fcb-3f7d-4af8-82f7-3a1ef8c0829a	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.550573+00	2025-12-09 20:24:02.550573+00	Google.com	0848e934-6852-4a61-9bcf-c80ea12f66af	[{"id": "41b9352f-9ecf-479a-bc66-4bba5265be37", "type": "Port", "port_id": "41520708-b517-49c6-8891-8f6806039cbf", "interface_id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b"}]	"Web Service"	null	{"type": "System"}
7d6d02ed-3992-42b6-953f-40727f30756d	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.550577+00	2025-12-09 20:24:02.550577+00	Mobile Device	0b1f4ff0-4c64-4a76-8c72-ee87cf226ce0	[{"id": "af6e9e70-d743-4933-9ed2-76edf7d1c6ec", "type": "Port", "port_id": "e0f5504b-f7f1-46fa-b2bc-4d43a1a2402d", "interface_id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6"}]	"Client"	null	{"type": "System"}
0d8495a2-f096-4204-9c3f-3de7893620a7	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.698508+00	2025-12-09 20:24:02.698508+00	NetVisor Daemon API	0ee12ab7-4c38-49c1-a39d-01324a098dda	[{"id": "64153be9-dab3-404a-8a24-b6466206d444", "type": "Port", "port_id": "2eb0e1d0-1d29-4883-97bd-9c3a1c09788b", "interface_id": "01335985-37bc-4295-9411-6a8c26eee601"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-09T20:24:02.698507200Z", "type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833"}]}
590d8df1-3151-4916-aaf2-93af4fc8dd39	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:37.269861+00	2025-12-09 20:24:37.269861+00	Home Assistant	90c0a623-3962-4a5c-9c47-d4eb88fd9ec1	[{"id": "df74a3e7-de5a-4314-ad73-1c8d857b4192", "type": "Port", "port_id": "81d34984-422f-44ce-b6c6-3dbfd4fa44f4", "interface_id": "56282c0d-150d-4bdb-8e15-7ddd0c5db1e4"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T20:24:37.269844427Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
d3ba8cb8-5c6f-4187-94fb-2e8fb595c9d8	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:42.193787+00	2025-12-09 20:24:42.193787+00	Unclaimed Open Ports	90c0a623-3962-4a5c-9c47-d4eb88fd9ec1	[{"id": "2de632c8-355d-4858-aa14-11a6e39ff2f8", "type": "Port", "port_id": "e48b5289-d18c-45a1-be24-dd0df73cbcbe", "interface_id": "56282c0d-150d-4bdb-8e15-7ddd0c5db1e4"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T20:24:42.193769318Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
5618ba21-400e-4791-b537-172ac4ceae0e	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:56.314939+00	2025-12-09 20:24:56.314939+00	PostgreSQL	81d871e8-84ee-47cc-91b7-a178c9bab803	[{"id": "02dab224-9fe5-4535-9fd2-54532ce5f6be", "type": "Port", "port_id": "c887e551-f18e-4427-b5e3-5e05d7e4c45b", "interface_id": "bdc0455b-eff3-4a0a-bc73-9e2a54938859"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T20:24:56.314921993Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
93ccb3e1-260a-4a95-9558-7e7dc9941d40	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:25:10.754208+00	2025-12-09 20:25:10.754208+00	Unclaimed Open Ports	6204071d-1f3d-42f8-b7cb-8398bdb6c250	[{"id": "9a90ae4a-25f9-4e1f-9169-43695e4f9746", "type": "Port", "port_id": "309834d3-c203-45c4-8930-fff6c5a11c50", "interface_id": "22f232c0-a2dc-4a03-9ad2-86710028555f"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T20:25:10.754191266Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
60f12e6f-d784-428a-b0cc-308c9cf72db0	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:25:17.759476+00	2025-12-09 20:25:17.759476+00	NetVisor Server API	da462412-6c0a-48a7-b48e-43f31c58396f	[{"id": "57d4ee4c-3704-4f84-b3a3-25e6b6824651", "type": "Port", "port_id": "23f8ace9-4236-42f0-bb66-c131de648d67", "interface_id": "8ae96fb9-347a-4412-a3ce-ca7df6d3cab8"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T20:25:17.759460370Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
9311bb2f-aada-4eb5-9b56-4a6d343a5141	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:25:24.375429+00	2025-12-09 20:25:24.375429+00	Home Assistant	da462412-6c0a-48a7-b48e-43f31c58396f	[{"id": "f2497e59-77ee-45f8-9162-a2a980e23e76", "type": "Port", "port_id": "0180ad73-7171-4072-8482-f1e039ea0471", "interface_id": "8ae96fb9-347a-4412-a3ce-ca7df6d3cab8"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-09T20:25:24.375412222Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
37b972ba-15b5-4035-bc64-99903d59fb27	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:25:29.486312+00	2025-12-09 20:25:29.486312+00	SSH	da462412-6c0a-48a7-b48e-43f31c58396f	[{"id": "05c09209-f5e1-4252-81c4-59b155af18cc", "type": "Port", "port_id": "de01e867-a4a8-4b0d-a961-96c620bcd4dd", "interface_id": "8ae96fb9-347a-4412-a3ce-ca7df6d3cab8"}]	"SSH"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 22/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T20:25:29.486296089Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
4d32b499-e348-4a83-ba8f-015ce2943d10	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:25:29.486843+00	2025-12-09 20:25:29.486843+00	Unclaimed Open Ports	da462412-6c0a-48a7-b48e-43f31c58396f	[{"id": "cedab725-5723-4a4b-a372-9ffe42c17280", "type": "Port", "port_id": "900f6191-5bc1-4795-bd11-5178d969f33e", "interface_id": "8ae96fb9-347a-4412-a3ce-ca7df6d3cab8"}]	"Unclaimed Open Ports"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Has unbound open ports", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-09T20:25:29.486835063Z", "type": "Network", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
3d263018-3d4c-499f-b620-d8d8314e4272	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.550502+00	2025-12-09 20:24:02.550502+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
888e9055-3c43-4c71-bb56-8e876605c372	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.550505+00	2025-12-09 20:24:02.550505+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
7a97731d-4937-4134-9459-43e72341eb1f	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	2025-12-09 20:24:02.679587+00	2025-12-09 20:24:02.679587+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:02.679585408Z", "type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
3f1836ee-909c-44c7-b3a9-ff0074290b23	3a27171e-adfc-4290-8b86-5d6cbc6e2aea	My Topology	[]	[{"id": "3d263018-3d4c-499f-b620-d8d8314e4272", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "888e9055-3c43-4c71-bb56-8e876605c372", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e", "size": {"x": 250, "y": 100}, "header": null, "host_id": "3ecfeba9-366c-463d-8358-544e96d54eda", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "interface_id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e"}, {"id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0848e934-6852-4a61-9bcf-c80ea12f66af", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "interface_id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b"}, {"id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0b1f4ff0-4c64-4a76-8c72-ee87cf226ce0", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "888e9055-3c43-4c71-bb56-8e876605c372", "interface_id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "3ecfeba9-366c-463d-8358-544e96d54eda", "name": "Cloudflare DNS", "ports": [{"id": "c0eaf456-a61d-4d95-9b1c-4b1c23b52a90", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "d6c20d8a-352b-4eaf-afb3-8a0bced938a2"}, "hostname": null, "services": ["40187e46-8e21-4a6d-b400-3b0377141ceb"], "created_at": "2025-12-09T20:24:02.550567Z", "interfaces": [{"id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e", "name": "Internet", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.558461Z", "description": null, "virtualization": null}, {"id": "0848e934-6852-4a61-9bcf-c80ea12f66af", "name": "Google.com", "ports": [{"id": "41520708-b517-49c6-8891-8f6806039cbf", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "41b9352f-9ecf-479a-bc66-4bba5265be37"}, "hostname": null, "services": ["e2926fcb-3f7d-4af8-82f7-3a1ef8c0829a"], "created_at": "2025-12-09T20:24:02.550572Z", "interfaces": [{"id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b", "name": "Internet", "subnet_id": "3d263018-3d4c-499f-b620-d8d8314e4272", "ip_address": "203.0.113.7", "mac_address": null}], "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.563092Z", "description": null, "virtualization": null}, {"id": "0b1f4ff0-4c64-4a76-8c72-ee87cf226ce0", "name": "Mobile Device", "ports": [{"id": "e0f5504b-f7f1-46fa-b2bc-4d43a1a2402d", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "af6e9e70-d743-4933-9ed2-76edf7d1c6ec"}, "hostname": null, "services": ["7d6d02ed-3992-42b6-953f-40727f30756d"], "created_at": "2025-12-09T20:24:02.550576Z", "interfaces": [{"id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6", "name": "Remote Network", "subnet_id": "888e9055-3c43-4c71-bb56-8e876605c372", "ip_address": "203.0.113.69", "mac_address": null}], "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.566751Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "3d263018-3d4c-499f-b620-d8d8314e4272", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-09T20:24:02.550502Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.550502Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "888e9055-3c43-4c71-bb56-8e876605c372", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-09T20:24:02.550505Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.550505Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "7a97731d-4937-4134-9459-43e72341eb1f", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-09T20:24:02.679585408Z", "type": "SelfReport", "host_id": "0ee12ab7-4c38-49c1-a39d-01324a098dda", "daemon_id": "39fb812a-8aae-4597-90d7-171986fae833"}]}, "created_at": "2025-12-09T20:24:02.679587Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.679587Z", "description": null, "subnet_type": "Lan"}]	[{"id": "40187e46-8e21-4a6d-b400-3b0377141ceb", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "3ecfeba9-366c-463d-8358-544e96d54eda", "bindings": [{"id": "d6c20d8a-352b-4eaf-afb3-8a0bced938a2", "type": "Port", "port_id": "c0eaf456-a61d-4d95-9b1c-4b1c23b52a90", "interface_id": "876a4933-6e29-49cb-9f86-bc2b0ff9b00e"}], "created_at": "2025-12-09T20:24:02.550568Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.550568Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "e2926fcb-3f7d-4af8-82f7-3a1ef8c0829a", "name": "Google.com", "source": {"type": "System"}, "host_id": "0848e934-6852-4a61-9bcf-c80ea12f66af", "bindings": [{"id": "41b9352f-9ecf-479a-bc66-4bba5265be37", "type": "Port", "port_id": "41520708-b517-49c6-8891-8f6806039cbf", "interface_id": "35a6f6f7-27d0-4b8b-ad12-f508be394e9b"}], "created_at": "2025-12-09T20:24:02.550573Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.550573Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "7d6d02ed-3992-42b6-953f-40727f30756d", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "0b1f4ff0-4c64-4a76-8c72-ee87cf226ce0", "bindings": [{"id": "af6e9e70-d743-4933-9ed2-76edf7d1c6ec", "type": "Port", "port_id": "e0f5504b-f7f1-46fa-b2bc-4d43a1a2402d", "interface_id": "da7c1cdf-8952-45a5-86dc-50b91f1cfcf6"}], "created_at": "2025-12-09T20:24:02.550577Z", "network_id": "3a27171e-adfc-4290-8b86-5d6cbc6e2aea", "updated_at": "2025-12-09T20:24:02.550577Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-09 20:24:02.570728+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-09 20:24:02.567436+00	2025-12-09 20:25:10.888765+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
8ebed24d-dc3c-4d52-bc09-f260a3858d3f	2025-12-09 20:23:59.878169+00	2025-12-09 20:24:02.45558+00	$argon2id$v=19$m=19456,t=2,p=1$dowX0EhjUmUPrqtFIjkQfg$7iBOPikH2cnVrLSHFCqmJD7by6tevvnhMv7xaH22HaI	\N	\N	\N	user@gmail.com	73075209-96e7-413a-b4fb-15b9312beca1	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
o2X7-GPDwpxAhOAYeKrtHg	\\x93c4101eedaa7818e084409cc2c363f8fb65a381a7757365725f6964d92438656265643234642d646333632d346435322d626330392d66323630613338353864336699cd07ea08141802ce1ff42741000000	2026-01-08 20:24:02.536094+00
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

\unrestrict 48gfgRVYgwF68ZI805xX2hs7L0AMOkhshYXVQK04Kvhv0ySUAsEL1wQhftlxTQe

