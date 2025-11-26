--
-- PostgreSQL database dump
--

\restrict sxUsLyc8WDu1tDGZhBndWRMd2SzBATHJ82q0TnUmMlmCER7TJwRThO7ldmbnbVq

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
20251006215000	users	2025-11-26 17:05:38.735806+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3534033
20251006215100	networks	2025-11-26 17:05:38.740008+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	3835492
20251006215151	create hosts	2025-11-26 17:05:38.7442+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3975133
20251006215155	create subnets	2025-11-26 17:05:38.748507+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3805045
20251006215201	create groups	2025-11-26 17:05:38.752678+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3818931
20251006215204	create daemons	2025-11-26 17:05:38.756837+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4091260
20251006215212	create services	2025-11-26 17:05:38.761321+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4770320
20251029193448	user-auth	2025-11-26 17:05:38.766416+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	3563702
20251030044828	daemon api	2025-11-26 17:05:38.770312+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1555138
20251030170438	host-hide	2025-11-26 17:05:38.772136+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1090449
20251102224919	create discovery	2025-11-26 17:05:38.773537+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	9495295
20251106235621	normalize-daemon-cols	2025-11-26 17:05:38.783368+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1733732
20251107034459	api keys	2025-11-26 17:05:38.785489+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	7279411
20251107222650	oidc-auth	2025-11-26 17:05:38.793105+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	21080627
20251110181948	orgs-billing	2025-11-26 17:05:38.814527+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	10416387
20251113223656	group-enhancements	2025-11-26 17:05:38.825391+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1131245
20251117032720	daemon-mode	2025-11-26 17:05:38.826767+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1104736
20251118143058	set-default-plan	2025-11-26 17:05:38.828152+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1333463
20251118225043	save-topology	2025-11-26 17:05:38.82978+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8804042
20251123232748	network-permissions	2025-11-26 17:05:38.838963+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2780118
20251125001342	billing-updates	2025-11-26 17:05:38.842059+00	t	\\xa235d153d95aeb676e3310a52ccb69dfbd7ca36bba975d5bbca165ceeec7196da12119f23597ea5276c364f90f23db1e	926312
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
ab8db3a3-ff00-410a-aeb9-232fbb7e62c8	f5a90eeff4b54953beb05936c17df2ad	501894ed-0a93-48e1-9664-5e58cba35a7d	Integrated Daemon API Key	2025-11-26 17:05:42.268228+00	2025-11-26 17:06:35.057403+00	2025-11-26 17:06:35.056658+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
4e8279d5-0322-4070-a119-5d0355da6bc0	501894ed-0a93-48e1-9664-5e58cba35a7d	5f803267-7b9f-445e-ad94-6c7fa8094335	"172.25.0.4"	60073	2025-11-26 17:05:42.321341+00	2025-11-26 17:05:42.32134+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["b3a4c558-10f6-4648-8cbb-e227a8b27ca8"]}	2025-11-26 17:05:42.387039+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
02eb2905-5c87-46a9-ad55-9b73fc34ad3e	501894ed-0a93-48e1-9664-5e58cba35a7d	4e8279d5-0322-4070-a119-5d0355da6bc0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335"}	Self Report @ 172.25.0.4	2025-11-26 17:05:42.367797+00	2025-11-26 17:05:42.367797+00
6ac5575e-14a3-4bcc-9e08-16062125be4e	501894ed-0a93-48e1-9664-5e58cba35a7d	4e8279d5-0322-4070-a119-5d0355da6bc0	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-26 17:05:42.375246+00	2025-11-26 17:05:42.375246+00
7c0b39e5-f563-49b1-aa2c-ca75494082e2	501894ed-0a93-48e1-9664-5e58cba35a7d	4e8279d5-0322-4070-a119-5d0355da6bc0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "processed": 1, "network_id": "501894ed-0a93-48e1-9664-5e58cba35a7d", "session_id": "3936a1b6-6494-4bf3-830c-ee1d3386dc06", "started_at": "2025-11-26T17:05:42.374690690Z", "finished_at": "2025-11-26T17:05:42.399699761Z", "discovery_type": {"type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335"}	Discovery Run	2025-11-26 17:05:42.37469+00	2025-11-26 17:05:42.401246+00
b74df6f6-020b-455e-b9d7-9329b4a577fc	501894ed-0a93-48e1-9664-5e58cba35a7d	4e8279d5-0322-4070-a119-5d0355da6bc0	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "processed": 13, "network_id": "501894ed-0a93-48e1-9664-5e58cba35a7d", "session_id": "9a2e54cb-499a-4c63-ad02-f994d7ca8057", "started_at": "2025-11-26T17:05:42.409497989Z", "finished_at": "2025-11-26T17:06:35.055792637Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-26 17:05:42.409497+00	2025-11-26 17:06:35.056898+00
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
417a3176-6e31-45db-ba93-7dc874445494	501894ed-0a93-48e1-9664-5e58cba35a7d	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "0b306565-6c10-49ff-ae4e-fe5d919275ba"}	[{"id": "4f7be2cd-c28d-4aa8-adcd-d65afe27dfd1", "name": "Internet", "subnet_id": "449e87d2-9813-4977-8323-9a34e8d97ed9", "ip_address": "1.1.1.1", "mac_address": null}]	{dce93390-8c2e-448e-8efe-a7a8d00911bf}	[{"id": "ace21b98-ce66-44c1-b444-2f3de2ccb740", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-26 17:05:42.248013+00	2025-11-26 17:05:42.257816+00	f
dd2f6ad2-5cd0-46dd-b651-468acc36af78	501894ed-0a93-48e1-9664-5e58cba35a7d	Google.com	\N	\N	{"type": "ServiceBinding", "config": "106fcde0-a229-451f-84db-0fd73402310f"}	[{"id": "b104df04-3bf7-4f03-90c9-9f28f36c13b6", "name": "Internet", "subnet_id": "449e87d2-9813-4977-8323-9a34e8d97ed9", "ip_address": "203.0.113.63", "mac_address": null}]	{ed4a0fb0-74cb-4a86-ac32-2c99054db3e0}	[{"id": "f5d8fbf5-b263-496e-ba09-234f17a97a5e", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 17:05:42.248019+00	2025-11-26 17:05:42.263286+00	f
787228db-d3c8-438a-8397-d194ccfa0d71	501894ed-0a93-48e1-9664-5e58cba35a7d	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "482f6552-77ee-4289-b544-97fa7377ba13"}	[{"id": "3c22f12c-c544-4e51-9a51-d275205dc17f", "name": "Remote Network", "subnet_id": "075efd90-56a5-48f0-9c28-7876540f2334", "ip_address": "203.0.113.153", "mac_address": null}]	{0824ac78-8177-43ea-8682-45c0d1d75f60}	[{"id": "6ca308b7-3a22-4045-86eb-f79012097bc7", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-26 17:05:42.248025+00	2025-11-26 17:05:42.267425+00	f
e8b11220-a008-4be7-b7fa-e14b6094a380	501894ed-0a93-48e1-9664-5e58cba35a7d	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "8f204a6c-9806-4f4e-8d6c-34da79e6ca0a", "name": null, "subnet_id": "b3a4c558-10f6-4648-8cbb-e227a8b27ca8", "ip_address": "172.25.0.6", "mac_address": "36:A2:0C:B5:29:3C"}]	{0f0f0772-5b1a-495b-9717-796ef3e0f925}	[{"id": "5286e9e6-1659-4400-bf1b-a84fa3c1f2f0", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T17:05:59.745036700Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 17:05:59.745038+00	2025-11-26 17:06:14.555649+00	f
5f803267-7b9f-445e-ad94-6c7fa8094335	501894ed-0a93-48e1-9664-5e58cba35a7d	172.25.0.4	180a71c62349	NetVisor daemon	{"type": "None"}	[{"id": "9f19fdd8-9560-461a-bd3f-49d05fa45b04", "name": "eth0", "subnet_id": "b3a4c558-10f6-4648-8cbb-e227a8b27ca8", "ip_address": "172.25.0.4", "mac_address": "62:4A:3E:13:52:C8"}]	{5439f4b0-e4b8-4166-beee-a73c7912d048}	[{"id": "6435ecbd-78ac-4373-bb60-fcf7281bd080", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T17:05:42.389177376Z", "type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0"}]}	null	2025-11-26 17:05:42.275841+00	2025-11-26 17:05:42.397523+00	f
adca6594-52df-4112-99c3-fdff84b63c93	501894ed-0a93-48e1-9664-5e58cba35a7d	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "7919faed-6fb2-40c5-9633-d11d8a59c0c4", "name": null, "subnet_id": "b3a4c558-10f6-4648-8cbb-e227a8b27ca8", "ip_address": "172.25.0.5", "mac_address": "3E:7A:F7:52:4F:59"}]	{65283407-39a6-4d48-8691-09ce7f789635}	[{"id": "b576d976-769c-48db-b575-60be2f3cf2db", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T17:05:44.622208544Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 17:05:44.622211+00	2025-11-26 17:05:59.612131+00	f
84979b49-1907-47d4-bf3f-200d8bd29084	501894ed-0a93-48e1-9664-5e58cba35a7d	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "958404aa-fd46-4d7b-b11b-0475fec6e789", "name": null, "subnet_id": "b3a4c558-10f6-4648-8cbb-e227a8b27ca8", "ip_address": "172.25.0.1", "mac_address": "3E:7B:34:CF:98:AA"}]	{33d69359-4409-40de-9008-e6d080dc4628,2163fdd3-5005-45b0-af78-0c7c73da2246}	[{"id": "8f150ae6-c434-4b08-bec9-058e46ca91e8", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "f1a2ec28-ef98-4ecd-8660-8c1ff765d446", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "206983cd-d6d4-4975-8d7f-2409931674ca", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-26T17:06:20.690316910Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-26 17:06:20.69032+00	2025-11-26 17:06:35.053669+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
501894ed-0a93-48e1-9664-5e58cba35a7d	My Network	2025-11-26 17:05:42.244346+00	2025-11-26 17:05:42.244346+00	f	1ce4ed19-d5f6-40bf-974c-ca75621b90e4
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
1ce4ed19-d5f6-40bf-974c-ca75621b90e4	My Organization	\N	{"rate": "Month", "type": "Community", "base_cents": 0, "seat_cents": null, "trial_days": 0, "network_cents": null, "included_seats": null, "included_networks": null}	\N	2025-11-26 17:05:38.898047+00	2025-11-26 17:05:42.243113+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
dce93390-8c2e-448e-8efe-a7a8d00911bf	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.248015+00	2025-11-26 17:05:42.248015+00	Cloudflare DNS	417a3176-6e31-45db-ba93-7dc874445494	[{"id": "0b306565-6c10-49ff-ae4e-fe5d919275ba", "type": "Port", "port_id": "ace21b98-ce66-44c1-b444-2f3de2ccb740", "interface_id": "4f7be2cd-c28d-4aa8-adcd-d65afe27dfd1"}]	"Dns Server"	null	{"type": "System"}
ed4a0fb0-74cb-4a86-ac32-2c99054db3e0	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.248021+00	2025-11-26 17:05:42.248021+00	Google.com	dd2f6ad2-5cd0-46dd-b651-468acc36af78	[{"id": "106fcde0-a229-451f-84db-0fd73402310f", "type": "Port", "port_id": "f5d8fbf5-b263-496e-ba09-234f17a97a5e", "interface_id": "b104df04-3bf7-4f03-90c9-9f28f36c13b6"}]	"Web Service"	null	{"type": "System"}
0824ac78-8177-43ea-8682-45c0d1d75f60	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.248026+00	2025-11-26 17:05:42.248026+00	Mobile Device	787228db-d3c8-438a-8397-d194ccfa0d71	[{"id": "482f6552-77ee-4289-b544-97fa7377ba13", "type": "Port", "port_id": "6ca308b7-3a22-4045-86eb-f79012097bc7", "interface_id": "3c22f12c-c544-4e51-9a51-d275205dc17f"}]	"Client"	null	{"type": "System"}
5439f4b0-e4b8-4166-beee-a73c7912d048	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.389197+00	2025-11-26 17:05:42.389197+00	NetVisor Daemon API	5f803267-7b9f-445e-ad94-6c7fa8094335	[{"id": "9f1a5d67-a622-4928-b9e6-d98024f609e9", "type": "Port", "port_id": "6435ecbd-78ac-4373-bb60-fcf7281bd080", "interface_id": "9f19fdd8-9560-461a-bd3f-49d05fa45b04"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-26T17:05:42.389196953Z", "type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0"}]}
65283407-39a6-4d48-8691-09ce7f789635	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:47.67728+00	2025-11-26 17:05:47.67728+00	Home Assistant	adca6594-52df-4112-99c3-fdff84b63c93	[{"id": "c91bb931-d880-431a-9af4-a97391dc600a", "type": "Port", "port_id": "b576d976-769c-48db-b575-60be2f3cf2db", "interface_id": "7919faed-6fb2-40c5-9633-d11d8a59c0c4"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.5:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T17:05:47.677268333Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
0f0f0772-5b1a-495b-9717-796ef3e0f925	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:06:14.525836+00	2025-11-26 17:06:14.525836+00	PostgreSQL	e8b11220-a008-4be7-b7fa-e14b6094a380	[{"id": "521ef815-7a51-4542-8102-4d0933e3b5b4", "type": "Port", "port_id": "5286e9e6-1659-4400-bf1b-a84fa3c1f2f0", "interface_id": "8f204a6c-9806-4f4e-8d6c-34da79e6ca0a"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-26T17:06:14.525829085Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
33d69359-4409-40de-9008-e6d080dc4628	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:06:23.615753+00	2025-11-26 17:06:23.615753+00	Home Assistant	84979b49-1907-47d4-bf3f-200d8bd29084	[{"id": "8dc49fcd-4992-45ad-a11c-7fb0552c1194", "type": "Port", "port_id": "8f150ae6-c434-4b08-bec9-058e46ca91e8", "interface_id": "958404aa-fd46-4d7b-b11b-0475fec6e789"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T17:06:23.615743537Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
2163fdd3-5005-45b0-af78-0c7c73da2246	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:06:23.616918+00	2025-11-26 17:06:23.616918+00	NetVisor Server API	84979b49-1907-47d4-bf3f-200d8bd29084	[{"id": "16ba88ef-d73a-4c6f-a5a4-745110008357", "type": "Port", "port_id": "f1a2ec28-ef98-4ecd-8660-8c1ff765d446", "interface_id": "958404aa-fd46-4d7b-b11b-0475fec6e789"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-26T17:06:23.616913903Z", "type": "Network", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
449e87d2-9813-4977-8323-9a34e8d97ed9	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.247967+00	2025-11-26 17:05:42.247967+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
075efd90-56a5-48f0-9c28-7876540f2334	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.247971+00	2025-11-26 17:05:42.247971+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
b3a4c558-10f6-4648-8cbb-e227a8b27ca8	501894ed-0a93-48e1-9664-5e58cba35a7d	2025-11-26 17:05:42.374848+00	2025-11-26 17:05:42.374848+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-26T17:05:42.374847002Z", "type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
e1fa1cb5-f8d6-4da1-889c-3f1561be0dc2	501894ed-0a93-48e1-9664-5e58cba35a7d	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "449e87d2-9813-4977-8323-9a34e8d97ed9", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-26T17:05:42.247967Z", "network_id": "501894ed-0a93-48e1-9664-5e58cba35a7d", "updated_at": "2025-11-26T17:05:42.247967Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "075efd90-56a5-48f0-9c28-7876540f2334", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-26T17:05:42.247971Z", "network_id": "501894ed-0a93-48e1-9664-5e58cba35a7d", "updated_at": "2025-11-26T17:05:42.247971Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "b3a4c558-10f6-4648-8cbb-e227a8b27ca8", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-26T17:05:42.374847002Z", "type": "SelfReport", "host_id": "5f803267-7b9f-445e-ad94-6c7fa8094335", "daemon_id": "4e8279d5-0322-4070-a119-5d0355da6bc0"}]}, "created_at": "2025-11-26T17:05:42.374848Z", "network_id": "501894ed-0a93-48e1-9664-5e58cba35a7d", "updated_at": "2025-11-26T17:05:42.374848Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-26 17:05:42.245629+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-26 17:05:42.245631+00	2025-11-26 17:06:35.1036+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
8fe05279-6620-43ed-9c79-055e4293e5b4	2025-11-26 17:05:38.899994+00	2025-11-26 17:05:42.230608+00	$argon2id$v=19$m=19456,t=2,p=1$ESPOa/bu182mkcbKU9bQjQ$2UopePqr0kU4VPjBQaERlyFIp6Y/OfLMmZFOO8omRTg	\N	\N	\N	user@example.com	1ce4ed19-d5f6-40bf-974c-ca75621b90e4	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
iR-NmIaOB_llDusYggFyQw	\\x93c4104372018218eb0e65f9078e86988d1f8981a7757365725f6964d92438666530353237392d363632302d343365642d396337392d30353565343239336535623499cd07e9cd016811052ace0dd7e18d000000	2025-12-26 17:05:42.232251+00
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

\unrestrict sxUsLyc8WDu1tDGZhBndWRMd2SzBATHJ82q0TnUmMlmCER7TJwRThO7ldmbnbVq

