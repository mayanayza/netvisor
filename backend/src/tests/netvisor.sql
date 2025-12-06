--
-- PostgreSQL database dump
--

\restrict QgV8i3UZgb6U5gXKUhMSOb3ftti4IiLQeIgKfUUNjeg6J1xIWiDXJgWkxHWpWtH

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
20251006215000	users	2025-12-06 17:15:09.739281+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3548095
20251006215100	networks	2025-12-06 17:15:09.743554+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3791998
20251006215151	create hosts	2025-12-06 17:15:09.747689+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	4959929
20251006215155	create subnets	2025-12-06 17:15:09.753011+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3660004
20251006215201	create groups	2025-12-06 17:15:09.757057+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3825520
20251006215204	create daemons	2025-12-06 17:15:09.761199+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4074974
20251006215212	create services	2025-12-06 17:15:09.765629+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4786005
20251029193448	user-auth	2025-12-06 17:15:09.770774+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3768381
20251030044828	daemon api	2025-12-06 17:15:09.774847+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1662204
20251030170438	host-hide	2025-12-06 17:15:09.776801+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1166361
20251102224919	create discovery	2025-12-06 17:15:09.778296+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10380729
20251106235621	normalize-daemon-cols	2025-12-06 17:15:09.78903+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1917849
20251107034459	api keys	2025-12-06 17:15:09.791252+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7862957
20251107222650	oidc-auth	2025-12-06 17:15:09.799498+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	20231653
20251110181948	orgs-billing	2025-12-06 17:15:09.820074+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10287265
20251113223656	group-enhancements	2025-12-06 17:15:09.830694+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1029987
20251117032720	daemon-mode	2025-12-06 17:15:09.831998+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1113883
20251118143058	set-default-plan	2025-12-06 17:15:09.833394+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1142667
20251118225043	save-topology	2025-12-06 17:15:09.834817+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8969744
20251123232748	network-permissions	2025-12-06 17:15:09.844109+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2630776
20251125001342	billing-updates	2025-12-06 17:15:09.84707+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	899104
20251128035448	org-onboarding-status	2025-12-06 17:15:09.848268+00	t	\\x1d7a7e9bf23b5078250f31934d1bc47bbaf463ace887e7746af30946e843de41badfc2b213ed64912a18e07b297663d8	1377864
20251129180942	nfs-consolidate	2025-12-06 17:15:09.849923+00	t	\\xb38f41d30699a475c2b967f8e43156f3b49bb10341bddbde01d9fb5ba805f6724685e27e53f7e49b6c8b59e29c74f98e	1239487
20251206052641	discovery-progress	2025-12-06 17:15:09.851438+00	t	\\x9d433b7b8c58d0d5437a104497e5e214febb2d1441a3ad7c28512e7497ed14fb9458e0d4ff786962a59954cb30da1447	1551688
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
7a327e3b-dfe9-41cb-ba4d-6c181c060363	05bc585f1ae842e280af8ccb6182fdd8	477e48df-6cc7-41aa-bdab-354c628a7ede	Integrated Daemon API Key	2025-12-06 17:15:12.929679+00	2025-12-06 17:16:50.678698+00	2025-12-06 17:16:50.677928+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
06007b32-664f-4275-a57c-14175a02d2cf	477e48df-6cc7-41aa-bdab-354c628a7ede	7a717835-95aa-4637-b159-7ad86d8a6992	"172.25.0.4"	60073	2025-12-06 17:15:12.989378+00	2025-12-06 17:16:28.239949+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["f0bb3f3f-b56b-44ce-b7e0-631556d6d09c"]}	2025-12-06 17:16:28.240486+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
cd16d09d-3fe1-4d16-8469-17d66190b0cb	477e48df-6cc7-41aa-bdab-354c628a7ede	06007b32-664f-4275-a57c-14175a02d2cf	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992"}	Self Report @ 172.25.0.4	2025-12-06 17:15:12.99581+00	2025-12-06 17:15:12.99581+00
86a433ea-20f0-41d0-90b7-a8b2f2671d32	477e48df-6cc7-41aa-bdab-354c628a7ede	06007b32-664f-4275-a57c-14175a02d2cf	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-12-06 17:15:13.002977+00	2025-12-06 17:15:13.002977+00
796ae730-ac27-4daa-a7b1-9b1a69db41ca	477e48df-6cc7-41aa-bdab-354c628a7ede	06007b32-664f-4275-a57c-14175a02d2cf	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "session_id": "0ee3a77b-508d-4231-863e-bb986b1eb814", "started_at": "2025-12-06T17:15:13.002570999Z", "finished_at": "2025-12-06T17:15:13.098362381Z", "discovery_type": {"type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992"}}}	{"type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992"}	Discovery Run	2025-12-06 17:15:13.00257+00	2025-12-06 17:15:13.10134+00
6bb6f0ea-7da2-4105-9f7b-4343877ec091	477e48df-6cc7-41aa-bdab-354c628a7ede	06007b32-664f-4275-a57c-14175a02d2cf	{"type": "Historical", "results": {"error": null, "phase": "Complete", "progress": 100, "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "session_id": "6e10eb15-5519-4804-996c-fed12972468c", "started_at": "2025-12-06T17:15:13.116555443Z", "finished_at": "2025-12-06T17:16:50.675666123Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-12-06 17:15:13.116555+00	2025-12-06 17:16:50.678189+00
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
5b7a1567-0e03-493f-8690-81c3943bfd01	477e48df-6cc7-41aa-bdab-354c628a7ede	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "cc2a5bff-363b-4812-8332-fff28d47f7b5"}	[{"id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a", "name": "Internet", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "ip_address": "1.1.1.1", "mac_address": null}]	{8ccfa78b-0e06-4fd6-bfa3-bcf6968273c4}	[{"id": "f546e2f9-cda4-4e05-bd82-469c16e10bae", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-12-06 17:15:12.901064+00	2025-12-06 17:15:12.91415+00	f
fe37feeb-00d4-44a8-8c9e-1414cfa059a0	477e48df-6cc7-41aa-bdab-354c628a7ede	Google.com	\N	\N	{"type": "ServiceBinding", "config": "51acacb7-1a26-48e7-833c-2077aae213f9"}	[{"id": "b18863f4-8d83-44cb-94c7-a343e0221e45", "name": "Internet", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "ip_address": "203.0.113.82", "mac_address": null}]	{5d30a3ea-04c8-4570-8f12-72e74e18ea72}	[{"id": "d81e3d86-8085-49a4-9144-e902d7a6a3b6", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 17:15:12.901072+00	2025-12-06 17:15:12.918904+00	f
0da1a694-b8b5-4030-b6b3-4f449dfbd92e	477e48df-6cc7-41aa-bdab-354c628a7ede	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "24e76635-1b6d-4904-b1f0-6d4a9a143562"}	[{"id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c", "name": "Remote Network", "subnet_id": "7595bebd-cd0e-4d31-8688-cbe9c5c72163", "ip_address": "203.0.113.235", "mac_address": null}]	{c459c829-de4d-4f76-ba5a-a8b407a710a3}	[{"id": "197fdf3e-51a9-402e-8159-5d01cef9f8f5", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-12-06 17:15:12.90108+00	2025-12-06 17:15:12.922664+00	f
d06c7ccc-b6f8-4784-bffb-08fb9a0bb2b4	477e48df-6cc7-41aa-bdab-354c628a7ede	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "9272458f-180e-46aa-b917-87ec8aa572b9", "name": null, "subnet_id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "ip_address": "172.25.0.6", "mac_address": "16:F1:2F:06:E7:44"}]	{bcfb17dc-e3ea-4c59-a636-20606796a813}	[{"id": "284c5a4c-e254-4c6c-9300-13ec962151b8", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:16:00.584771760Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 17:16:00.584775+00	2025-12-06 17:16:15.244039+00	f
7a717835-95aa-4637-b159-7ad86d8a6992	477e48df-6cc7-41aa-bdab-354c628a7ede	172.25.0.4	e5a01fb6bd63	NetVisor daemon	{"type": "None"}	[{"id": "c02042d4-9a27-4bd2-92ed-91ff8505b364", "name": "eth0", "subnet_id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "ip_address": "172.25.0.4", "mac_address": "0A:65:D8:31:17:7B"}]	{04b22dbb-b11b-4d54-9bf9-2dbcd355e644}	[{"id": "66d3519c-5af9-41d1-acd3-5c2bed2bdce2", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:15:13.085743977Z", "type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf"}]}	null	2025-12-06 17:15:12.985228+00	2025-12-06 17:15:13.096598+00	f
89aaf323-8ed1-4f61-af98-4262f2111cce	477e48df-6cc7-41aa-bdab-354c628a7ede	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c3b4e1ec-a024-4fc3-b9d1-dd7c1ce58e1e", "name": null, "subnet_id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "ip_address": "172.25.0.5", "mac_address": "5A:6E:36:6B:25:F8"}]	{403e714c-e992-4843-bf28-6f8cba50e27a}	[{"id": "34194a91-fc36-4dc6-9307-5a992a075413", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "770bc69b-fc62-462b-9d75-60b21f3da9ab", "type": "Custom", "number": 18555, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:15:45.790768936Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 17:15:45.790772+00	2025-12-06 17:16:00.521348+00	f
71552760-8f76-4f06-9933-356cd443a008	477e48df-6cc7-41aa-bdab-354c628a7ede	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "74d0321a-3d4b-49ae-92a4-0639c83ffc51", "name": null, "subnet_id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "ip_address": "172.25.0.3", "mac_address": "CE:4C:E2:EC:E2:99"}]	{}	[{"id": "ed9ec92c-d4a9-484e-b010-9fcdc2eabe47", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:16:15.241628532Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 17:16:15.241631+00	2025-12-06 17:16:29.97893+00	f
02bd369f-20f7-4a29-9d53-690addfe0bd8	477e48df-6cc7-41aa-bdab-354c628a7ede	runnervmoqczp	runnervmoqczp	\N	{"type": "Hostname"}	[{"id": "76aa31ed-076b-483f-8f4f-96d243138c02", "name": null, "subnet_id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "ip_address": "172.25.0.1", "mac_address": "52:BD:51:07:6A:C9"}]	{3b790d1a-9544-4157-a43e-0531143ced24,fe3265b2-ea0f-4723-bff0-8d1ba7c4501e}	[{"id": "28cb693d-c00b-47f5-893a-bfddd80b0614", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "3d1217f0-019f-4e94-bcf2-4f6082246206", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "b3fd49c6-b42c-4475-8fb7-1c07bb6183e6", "type": "Ssh", "number": 22, "protocol": "Tcp"}, {"id": "92c84a62-f600-42cc-875b-b4b8d4337a28", "type": "Custom", "number": 5435, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:16:36.022918853Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-12-06 17:16:36.022922+00	2025-12-06 17:16:50.669938+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
477e48df-6cc7-41aa-bdab-354c628a7ede	My Network	2025-12-06 17:15:12.899728+00	2025-12-06 17:15:12.899728+00	f	c9dda75c-784f-45c5-8a76-35ce8ea564aa
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, onboarding) FROM stdin;
c9dda75c-784f-45c5-8a76-35ce8ea564aa	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-12-06 17:15:09.908099+00	2025-12-06 17:15:12.994279+00	["OnboardingModalCompleted", "FirstDaemonRegistered"]
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
8ccfa78b-0e06-4fd6-bfa3-bcf6968273c4	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:12.901066+00	2025-12-06 17:15:12.901066+00	Cloudflare DNS	5b7a1567-0e03-493f-8690-81c3943bfd01	[{"id": "cc2a5bff-363b-4812-8332-fff28d47f7b5", "type": "Port", "port_id": "f546e2f9-cda4-4e05-bd82-469c16e10bae", "interface_id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a"}]	"Dns Server"	null	{"type": "System"}
5d30a3ea-04c8-4570-8f12-72e74e18ea72	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:12.901074+00	2025-12-06 17:15:12.901074+00	Google.com	fe37feeb-00d4-44a8-8c9e-1414cfa059a0	[{"id": "51acacb7-1a26-48e7-833c-2077aae213f9", "type": "Port", "port_id": "d81e3d86-8085-49a4-9144-e902d7a6a3b6", "interface_id": "b18863f4-8d83-44cb-94c7-a343e0221e45"}]	"Web Service"	null	{"type": "System"}
c459c829-de4d-4f76-ba5a-a8b407a710a3	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:12.901082+00	2025-12-06 17:15:12.901082+00	Mobile Device	0da1a694-b8b5-4030-b6b3-4f449dfbd92e	[{"id": "24e76635-1b6d-4904-b1f0-6d4a9a143562", "type": "Port", "port_id": "197fdf3e-51a9-402e-8159-5d01cef9f8f5", "interface_id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c"}]	"Client"	null	{"type": "System"}
04b22dbb-b11b-4d54-9bf9-2dbcd355e644	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:13.085766+00	2025-12-06 17:15:13.085766+00	NetVisor Daemon API	7a717835-95aa-4637-b159-7ad86d8a6992	[{"id": "ecd5efe4-713b-4678-848f-21d8d1b5525e", "type": "Port", "port_id": "66d3519c-5af9-41d1-acd3-5c2bed2bdce2", "interface_id": "c02042d4-9a27-4bd2-92ed-91ff8505b364"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-12-06T17:15:13.085765156Z", "type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf"}]}
403e714c-e992-4843-bf28-6f8cba50e27a	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:16:00.508474+00	2025-12-06 17:16:00.508474+00	Home Assistant	89aaf323-8ed1-4f61-af98-4262f2111cce	[{"id": "783c0d37-fbf1-4b05-b759-f12ef5bcc35f", "type": "Port", "port_id": "34194a91-fc36-4dc6-9307-5a992a075413", "interface_id": "c3b4e1ec-a024-4fc3-b9d1-dd7c1ce58e1e"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T17:16:00.508454233Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
bcfb17dc-e3ea-4c59-a636-20606796a813	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:16:15.229193+00	2025-12-06 17:16:15.229193+00	PostgreSQL	d06c7ccc-b6f8-4784-bffb-08fb9a0bb2b4	[{"id": "f277600a-a123-41de-87f0-22d205c97312", "type": "Port", "port_id": "284c5a4c-e254-4c6c-9300-13ec962151b8", "interface_id": "9272458f-180e-46aa-b917-87ec8aa572b9"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-12-06T17:16:15.229178269Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
3b790d1a-9544-4157-a43e-0531143ced24	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:16:49.925499+00	2025-12-06 17:16:49.925499+00	NetVisor Server API	02bd369f-20f7-4a29-9d53-690addfe0bd8	[{"id": "b8134a4e-5a85-4bcf-8e57-ce3338cf3f81", "type": "Port", "port_id": "28cb693d-c00b-47f5-893a-bfddd80b0614", "interface_id": "76aa31ed-076b-483f-8f4f-96d243138c02"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T17:16:49.925478438Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
fe3265b2-ea0f-4723-bff0-8d1ba7c4501e	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:16:50.657283+00	2025-12-06 17:16:50.657283+00	Home Assistant	02bd369f-20f7-4a29-9d53-690addfe0bd8	[{"id": "c2fd8b42-fd09-43c6-b3b3-b32ed54c7816", "type": "Port", "port_id": "3d1217f0-019f-4e94-bcf2-4f6082246206", "interface_id": "76aa31ed-076b-483f-8f4f-96d243138c02"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-12-06T17:16:50.657263259Z", "type": "Network", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
c0569d21-9ca4-4afc-a5d2-a274664b5512	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:12.900997+00	2025-12-06 17:15:12.900997+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
7595bebd-cd0e-4d31-8688-cbe9c5c72163	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:12.901+00	2025-12-06 17:15:12.901+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
f0bb3f3f-b56b-44ce-b7e0-631556d6d09c	477e48df-6cc7-41aa-bdab-354c628a7ede	2025-12-06 17:15:13.002746+00	2025-12-06 17:15:13.002746+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-12-06T17:15:13.002744652Z", "type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
5e37d19a-ad89-436d-b3a5-c234e81b1c6c	477e48df-6cc7-41aa-bdab-354c628a7ede	My Topology	[]	[{"id": "7595bebd-cd0e-4d31-8688-cbe9c5c72163", "size": {"x": 350, "y": 200}, "header": null, "position": {"x": 950, "y": 125}, "node_type": "SubnetNode", "infra_width": 0}, {"id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "size": {"x": 700, "y": 200}, "header": null, "position": {"x": 125, "y": 125}, "node_type": "SubnetNode", "infra_width": 350}, {"id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c", "size": {"x": 250, "y": 100}, "header": null, "host_id": "0da1a694-b8b5-4030-b6b3-4f449dfbd92e", "is_infra": false, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "7595bebd-cd0e-4d31-8688-cbe9c5c72163", "interface_id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c"}, {"id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a", "size": {"x": 250, "y": 100}, "header": null, "host_id": "5b7a1567-0e03-493f-8690-81c3943bfd01", "is_infra": true, "position": {"x": 50, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "interface_id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a"}, {"id": "b18863f4-8d83-44cb-94c7-a343e0221e45", "size": {"x": 250, "y": 100}, "header": null, "host_id": "fe37feeb-00d4-44a8-8c9e-1414cfa059a0", "is_infra": false, "position": {"x": 400, "y": 50}, "node_type": "InterfaceNode", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "interface_id": "b18863f4-8d83-44cb-94c7-a343e0221e45"}]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[{"id": "5b7a1567-0e03-493f-8690-81c3943bfd01", "name": "Cloudflare DNS", "ports": [{"id": "f546e2f9-cda4-4e05-bd82-469c16e10bae", "type": "DnsUdp", "number": 53, "protocol": "Udp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "cc2a5bff-363b-4812-8332-fff28d47f7b5"}, "hostname": null, "services": ["8ccfa78b-0e06-4fd6-bfa3-bcf6968273c4"], "created_at": "2025-12-06T17:15:12.901064Z", "interfaces": [{"id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a", "name": "Internet", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "ip_address": "1.1.1.1", "mac_address": null}], "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.914150Z", "description": null, "virtualization": null}, {"id": "fe37feeb-00d4-44a8-8c9e-1414cfa059a0", "name": "Google.com", "ports": [{"id": "d81e3d86-8085-49a4-9144-e902d7a6a3b6", "type": "Https", "number": 443, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "51acacb7-1a26-48e7-833c-2077aae213f9"}, "hostname": null, "services": ["5d30a3ea-04c8-4570-8f12-72e74e18ea72"], "created_at": "2025-12-06T17:15:12.901072Z", "interfaces": [{"id": "b18863f4-8d83-44cb-94c7-a343e0221e45", "name": "Internet", "subnet_id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "ip_address": "203.0.113.82", "mac_address": null}], "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.918904Z", "description": null, "virtualization": null}, {"id": "0da1a694-b8b5-4030-b6b3-4f449dfbd92e", "name": "Mobile Device", "ports": [{"id": "197fdf3e-51a9-402e-8159-5d01cef9f8f5", "type": "Custom", "number": 0, "protocol": "Tcp"}], "hidden": false, "source": {"type": "System"}, "target": {"type": "ServiceBinding", "config": "24e76635-1b6d-4904-b1f0-6d4a9a143562"}, "hostname": null, "services": ["c459c829-de4d-4f76-ba5a-a8b407a710a3"], "created_at": "2025-12-06T17:15:12.901080Z", "interfaces": [{"id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c", "name": "Remote Network", "subnet_id": "7595bebd-cd0e-4d31-8688-cbe9c5c72163", "ip_address": "203.0.113.235", "mac_address": null}], "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.922664Z", "description": "A mobile device connecting from a remote network", "virtualization": null}]	[{"id": "c0569d21-9ca4-4afc-a5d2-a274664b5512", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-12-06T17:15:12.900997Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.900997Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "7595bebd-cd0e-4d31-8688-cbe9c5c72163", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-12-06T17:15:12.901Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.901Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "f0bb3f3f-b56b-44ce-b7e0-631556d6d09c", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-12-06T17:15:13.002744652Z", "type": "SelfReport", "host_id": "7a717835-95aa-4637-b159-7ad86d8a6992", "daemon_id": "06007b32-664f-4275-a57c-14175a02d2cf"}]}, "created_at": "2025-12-06T17:15:13.002746Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:13.002746Z", "description": null, "subnet_type": "Lan"}]	[{"id": "8ccfa78b-0e06-4fd6-bfa3-bcf6968273c4", "name": "Cloudflare DNS", "source": {"type": "System"}, "host_id": "5b7a1567-0e03-493f-8690-81c3943bfd01", "bindings": [{"id": "cc2a5bff-363b-4812-8332-fff28d47f7b5", "type": "Port", "port_id": "f546e2f9-cda4-4e05-bd82-469c16e10bae", "interface_id": "49d1ad3f-0201-4232-ad45-5b16ed30f74a"}], "created_at": "2025-12-06T17:15:12.901066Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.901066Z", "virtualization": null, "service_definition": "Dns Server"}, {"id": "5d30a3ea-04c8-4570-8f12-72e74e18ea72", "name": "Google.com", "source": {"type": "System"}, "host_id": "fe37feeb-00d4-44a8-8c9e-1414cfa059a0", "bindings": [{"id": "51acacb7-1a26-48e7-833c-2077aae213f9", "type": "Port", "port_id": "d81e3d86-8085-49a4-9144-e902d7a6a3b6", "interface_id": "b18863f4-8d83-44cb-94c7-a343e0221e45"}], "created_at": "2025-12-06T17:15:12.901074Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.901074Z", "virtualization": null, "service_definition": "Web Service"}, {"id": "c459c829-de4d-4f76-ba5a-a8b407a710a3", "name": "Mobile Device", "source": {"type": "System"}, "host_id": "0da1a694-b8b5-4030-b6b3-4f449dfbd92e", "bindings": [{"id": "24e76635-1b6d-4904-b1f0-6d4a9a143562", "type": "Port", "port_id": "197fdf3e-51a9-402e-8159-5d01cef9f8f5", "interface_id": "6a1bbac6-dd38-47e7-8e2a-8a1f71670d8c"}], "created_at": "2025-12-06T17:15:12.901082Z", "network_id": "477e48df-6cc7-41aa-bdab-354c628a7ede", "updated_at": "2025-12-06T17:15:12.901082Z", "virtualization": null, "service_definition": "Client"}]	[]	t	2025-12-06 17:15:12.926913+00	f	\N	\N	{}	{}	{}	{}	\N	2025-12-06 17:15:12.92335+00	2025-12-06 17:16:50.721892+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
cf22c9d1-439e-4d73-874a-752c823b927d	2025-12-06 17:15:09.910082+00	2025-12-06 17:15:12.882925+00	$argon2id$v=19$m=19456,t=2,p=1$JVVebY0VasEoyx8GlTvBgg$yzZK3ikmXFE96WdHgHRC64WmG596AGFgpOZnlZufHDw	\N	\N	\N	user@gmail.com	c9dda75c-784f-45c5-8a76-35ce8ea564aa	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
Ci9tDqAAOve52xibzq-gNw	\\x93c41037a0afce9b18dbb9f73a00a00e6d2f0a81a7757365725f6964d92463663232633964312d343339652d346437332d383734612d37353263383233623932376499cd07ea05110f0cce34c9e165000000	2026-01-05 17:15:12.885645+00
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

\unrestrict QgV8i3UZgb6U5gXKUhMSOb3ftti4IiLQeIgKfUUNjeg6J1xIWiDXJgWkxHWpWtH

