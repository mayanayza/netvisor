--
-- PostgreSQL database dump
--

\restrict 2icdMN2u98KJq9ixPOWMpgkgBecbnETSjQ32T0omwe8TrqmdRj8kh4heyCbGDUg

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
20251006215000	users	2025-11-24 04:26:53.552663+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	3513199
20251006215100	networks	2025-11-24 04:26:53.557227+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4598065
20251006215151	create hosts	2025-11-24 04:26:53.56341+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3847073
20251006215155	create subnets	2025-11-24 04:26:53.567596+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3733170
20251006215201	create groups	2025-11-24 04:26:53.571688+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	3960855
20251006215204	create daemons	2025-11-24 04:26:53.575995+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	4089746
20251006215212	create services	2025-11-24 04:26:53.58043+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	4945875
20251029193448	user-auth	2025-11-24 04:26:53.585688+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	5876913
20251030044828	daemon api	2025-11-24 04:26:53.591839+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	1466158
20251030170438	host-hide	2025-11-24 04:26:53.593586+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	1084675
20251102224919	create discovery	2025-11-24 04:26:53.595017+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	10971595
20251106235621	normalize-daemon-cols	2025-11-24 04:26:53.606287+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1739728
20251107034459	api keys	2025-11-24 04:26:53.608307+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	8250978
20251107222650	oidc-auth	2025-11-24 04:26:53.616869+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	26482124
20251110181948	orgs-billing	2025-11-24 04:26:53.643659+00	t	\\x5bbea7a2dfc9d00213bd66b473289ddd66694eff8a4f3eaab937c985b64c5f8c3ad2d64e960afbb03f335ac6766687aa	11280141
20251113223656	group-enhancements	2025-11-24 04:26:53.655316+00	t	\\xbe0699486d85df2bd3edc1f0bf4f1f096d5b6c5070361702c4d203ec2bb640811be88bb1979cfe51b40805ad84d1de65	1075187
20251117032720	daemon-mode	2025-11-24 04:26:53.656689+00	t	\\xdd0d899c24b73d70e9970e54b2c748d6b6b55c856ca0f8590fe990da49cc46c700b1ce13f57ff65abd6711f4bd8a6481	1196641
20251118143058	set-default-plan	2025-11-24 04:26:53.658225+00	t	\\xd19142607aef84aac7cfb97d60d29bda764d26f513f2c72306734c03cec2651d23eee3ce6cacfd36ca52dbddc462f917	1194500
20251118225043	save-topology	2025-11-24 04:26:53.659728+00	t	\\x011a594740c69d8d0f8b0149d49d1b53cfbf948b7866ebd84403394139cb66a44277803462846b06e762577adc3e61a3	8897038
20251123232748	network-permissions	2025-11-24 04:26:53.668991+00	t	\\x161be7ae5721c06523d6488606f1a7b1f096193efa1183ecdd1c2c9a4a9f4cad4884e939018917314aaf261d9a3f97ae	2922363
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
3845464e-cd2d-4542-a684-5eb1b13d2edb	4670f5b7ada1411599dfd152fa81e081	df280671-1bd9-48f4-9d4b-8cd38cc21efe	Integrated Daemon API Key	2025-11-24 04:26:57.260511+00	2025-11-24 04:27:49.844182+00	2025-11-24 04:27:49.84341+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at, mode) FROM stdin;
16a42580-092a-4701-94c2-ed3089813bae	df280671-1bd9-48f4-9d4b-8cd38cc21efe	bc639506-2d1d-4a31-b2b1-43ddcdaf64c5	"172.25.0.4"	60073	2025-11-24 04:26:57.349015+00	2025-11-24 04:26:57.349014+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["734c2166-2836-454b-a251-2b4fe2332bd8"]}	2025-11-24 04:26:57.36907+00	"Push"
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
1ffaca42-8f60-40f0-8f54-9fe0bd8f7db2	df280671-1bd9-48f4-9d4b-8cd38cc21efe	16a42580-092a-4701-94c2-ed3089813bae	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5"}	Self Report @ 172.25.0.4	2025-11-24 04:26:57.350936+00	2025-11-24 04:26:57.350936+00
754283dc-a8a3-4c79-9bb1-f02bde6d2106	df280671-1bd9-48f4-9d4b-8cd38cc21efe	16a42580-092a-4701-94c2-ed3089813bae	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-24 04:26:57.358335+00	2025-11-24 04:26:57.358335+00
fa8a01ac-6d3e-42cb-a842-ce43acba600a	df280671-1bd9-48f4-9d4b-8cd38cc21efe	16a42580-092a-4701-94c2-ed3089813bae	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "processed": 1, "network_id": "df280671-1bd9-48f4-9d4b-8cd38cc21efe", "session_id": "2c1e887c-40ea-4e6e-89f0-6dc43ab1d6c2", "started_at": "2025-11-24T04:26:57.357846079Z", "finished_at": "2025-11-24T04:26:57.379781668Z", "discovery_type": {"type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5"}	Discovery Run	2025-11-24 04:26:57.357846+00	2025-11-24 04:26:57.381098+00
ef951a8a-cf7a-45f4-b003-5715a9b525ab	df280671-1bd9-48f4-9d4b-8cd38cc21efe	16a42580-092a-4701-94c2-ed3089813bae	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "processed": 12, "network_id": "df280671-1bd9-48f4-9d4b-8cd38cc21efe", "session_id": "c4e00511-5ced-48ce-8d61-499c09b3edf8", "started_at": "2025-11-24T04:26:57.387678579Z", "finished_at": "2025-11-24T04:27:49.842451577Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-24 04:26:57.387678+00	2025-11-24 04:27:49.843681+00
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
8a11e946-affe-4979-a374-087b78ee9cfc	df280671-1bd9-48f4-9d4b-8cd38cc21efe	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "10521b30-eb72-4120-9d6d-12d8ccb0f11f"}	[{"id": "c29446f0-22d9-47a1-aa1c-3bcb8383dc2c", "name": "Internet", "subnet_id": "e5ad4339-a89a-4d7a-8a99-277626e3288d", "ip_address": "1.1.1.1", "mac_address": null}]	{d62785d9-d4f8-4d4c-bfb5-8361e94f4569}	[{"id": "1cf106b7-240c-46f0-9145-aad15becaf36", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-24 04:26:57.241211+00	2025-11-24 04:26:57.250485+00	f
d2fb498b-8204-4710-82d2-5ddafc957ae3	df280671-1bd9-48f4-9d4b-8cd38cc21efe	Google.com	\N	\N	{"type": "ServiceBinding", "config": "2134c7cd-3147-4a1a-b906-709b67adb305"}	[{"id": "277f1ac5-e4fa-4207-9c72-b446dfd7219f", "name": "Internet", "subnet_id": "e5ad4339-a89a-4d7a-8a99-277626e3288d", "ip_address": "203.0.113.109", "mac_address": null}]	{da25f419-8056-4d34-8ff0-78f0d8946f30}	[{"id": "0b27ba6f-f8a3-45cc-b2d9-d0223a2c9168", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-24 04:26:57.241218+00	2025-11-24 04:26:57.255765+00	f
8479064a-743d-4166-a923-c31d44291811	df280671-1bd9-48f4-9d4b-8cd38cc21efe	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "91884dc0-6355-43e9-8ec8-8aaeb8cc3350"}	[{"id": "5d9966d6-efe7-44a5-8df8-8181541d1fa1", "name": "Remote Network", "subnet_id": "b00fd73f-99ca-4579-a1aa-0a289fcf9cd6", "ip_address": "203.0.113.35", "mac_address": null}]	{fb654912-12a0-42cb-ae9a-e1289a571e71}	[{"id": "d4f47257-ef94-44ba-995c-1241a2f8612a", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-24 04:26:57.241223+00	2025-11-24 04:26:57.259653+00	f
ebbd8ced-3cc3-4551-911e-e3c580d6c999	df280671-1bd9-48f4-9d4b-8cd38cc21efe	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "7bfc4a9d-5087-4af1-a761-87dfc8bbe9ac", "name": null, "subnet_id": "734c2166-2836-454b-a251-2b4fe2332bd8", "ip_address": "172.25.0.3", "mac_address": "3E:F1:AB:71:A9:5D"}]	{73a32db2-a9fe-49a2-a518-79d70890a122}	[{"id": "5fa396ef-3e13-475b-b5fc-21998e3bb397", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-24T04:26:59.572641335Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-24 04:26:59.572642+00	2025-11-24 04:27:14.293868+00	f
cf4fc865-4ff4-4dc4-b11c-4a6b7470f57b	df280671-1bd9-48f4-9d4b-8cd38cc21efe	netvisor-postgres-dev-1.netvisor_netvisor-dev	netvisor-postgres-dev-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ed406074-f11f-484d-80fe-0ac0998ae2af", "name": null, "subnet_id": "734c2166-2836-454b-a251-2b4fe2332bd8", "ip_address": "172.25.0.6", "mac_address": "3E:DB:6B:15:23:E5"}]	{0170c751-a0a0-42f1-a3d3-f462dda4b579}	[{"id": "8d6d289a-1dbc-42fd-b586-191a559238b1", "type": "PostgreSQL", "number": 5432, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-24T04:27:14.433767240Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-24 04:27:14.433768+00	2025-11-24 04:27:29.117961+00	f
bc639506-2d1d-4a31-b2b1-43ddcdaf64c5	df280671-1bd9-48f4-9d4b-8cd38cc21efe	172.25.0.4	1be0dd8d0683	NetVisor daemon	{"type": "None"}	[{"id": "dd3aa9dc-2452-4ea3-bf41-332f33bace70", "name": "eth0", "subnet_id": "734c2166-2836-454b-a251-2b4fe2332bd8", "ip_address": "172.25.0.4", "mac_address": "86:0C:10:71:56:67"}]	{3de287e0-cdc3-48e7-94d3-90d816686fce,72beb43b-dc1d-4f7e-b4ce-42597eaceeea}	[{"id": "39824cb0-12f9-43ab-bb90-04d0e4a9457a", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-24T04:26:59.510604951Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-24T04:26:57.370894305Z", "type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae"}]}	null	2025-11-24 04:26:57.26792+00	2025-11-24 04:26:59.526192+00	f
88b238dd-e868-4adf-a0be-926ced2be02a	df280671-1bd9-48f4-9d4b-8cd38cc21efe	runnervmg1sw1	runnervmg1sw1	\N	{"type": "Hostname"}	[{"id": "10b69312-cabb-4e2e-8443-77634f820ee4", "name": null, "subnet_id": "734c2166-2836-454b-a251-2b4fe2332bd8", "ip_address": "172.25.0.1", "mac_address": "4E:B0:D3:9B:63:4D"}]	{1ce643d7-2bb7-459a-86ad-47a0590c3a38,85008e5b-7be7-4c17-b4e8-3c2c5dda6130}	[{"id": "b2276bfb-50e1-4c0a-b01c-f7d8fda68c5a", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "082353ff-96ce-4737-a599-15ee1463c28c", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "378d1a92-2264-4624-bdbd-ba887600c66f", "type": "Ssh", "number": 22, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-24T04:27:35.259341853Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-24 04:27:35.259345+00	2025-11-24 04:27:49.840258+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, organization_id) FROM stdin;
df280671-1bd9-48f4-9d4b-8cd38cc21efe	My Network	2025-11-24 04:26:57.237759+00	2025-11-24 04:26:57.237759+00	f	3c5386e3-5a57-471a-9352-f995d48687eb
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, stripe_customer_id, plan, plan_status, created_at, updated_at, is_onboarded) FROM stdin;
3c5386e3-5a57-471a-9352-f995d48687eb	My Organization	\N	{"type": "Community", "price": {"rate": "Month", "cents": 0}, "trial_days": 0}	\N	2025-11-24 04:26:53.727511+00	2025-11-24 04:26:57.236543+00	t
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
d62785d9-d4f8-4d4c-bfb5-8361e94f4569	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.241213+00	2025-11-24 04:26:57.241213+00	Cloudflare DNS	8a11e946-affe-4979-a374-087b78ee9cfc	[{"id": "10521b30-eb72-4120-9d6d-12d8ccb0f11f", "type": "Port", "port_id": "1cf106b7-240c-46f0-9145-aad15becaf36", "interface_id": "c29446f0-22d9-47a1-aa1c-3bcb8383dc2c"}]	"Dns Server"	null	{"type": "System"}
da25f419-8056-4d34-8ff0-78f0d8946f30	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.241219+00	2025-11-24 04:26:57.241219+00	Google.com	d2fb498b-8204-4710-82d2-5ddafc957ae3	[{"id": "2134c7cd-3147-4a1a-b906-709b67adb305", "type": "Port", "port_id": "0b27ba6f-f8a3-45cc-b2d9-d0223a2c9168", "interface_id": "277f1ac5-e4fa-4207-9c72-b446dfd7219f"}]	"Web Service"	null	{"type": "System"}
fb654912-12a0-42cb-ae9a-e1289a571e71	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.241224+00	2025-11-24 04:26:57.241224+00	Mobile Device	8479064a-743d-4166-a923-c31d44291811	[{"id": "91884dc0-6355-43e9-8ec8-8aaeb8cc3350", "type": "Port", "port_id": "d4f47257-ef94-44ba-995c-1241a2f8612a", "interface_id": "5d9966d6-efe7-44a5-8df8-8181541d1fa1"}]	"Client"	null	{"type": "System"}
3de287e0-cdc3-48e7-94d3-90d816686fce	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.370908+00	2025-11-24 04:26:59.524743+00	NetVisor Daemon API	bc639506-2d1d-4a31-b2b1-43ddcdaf64c5	[{"id": "5f97b469-e169-4edd-98b0-804084c81f97", "type": "Port", "port_id": "39824cb0-12f9-43ab-bb90-04d0e4a9457a", "interface_id": "dd3aa9dc-2452-4ea3-bf41-332f33bace70"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "NetVisor Daemon self-report", "type": "reason"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-24T04:26:59.511112639Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-24T04:26:57.370907650Z", "type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae"}]}
73a32db2-a9fe-49a2-a518-79d70890a122	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:27:04.699299+00	2025-11-24 04:27:04.699299+00	NetVisor Server API	ebbd8ced-3cc3-4551-911e-e3c580d6c999	[{"id": "a2dce5dc-147a-412a-82ea-033fae51f66c", "type": "Port", "port_id": "5fa396ef-3e13-475b-b5fc-21998e3bb397", "interface_id": "7bfc4a9d-5087-4af1-a761-87dfc8bbe9ac"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.3:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-24T04:27:04.699291817Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
0170c751-a0a0-42f1-a3d3-f462dda4b579	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:27:29.086916+00	2025-11-24 04:27:29.086916+00	PostgreSQL	cf4fc865-4ff4-4dc4-b11c-4a6b7470f57b	[{"id": "d28ff730-88f9-4cb9-a9a1-60aaf97f9540", "type": "Port", "port_id": "8d6d289a-1dbc-42fd-b586-191a559238b1", "interface_id": "ed406074-f11f-484d-80fe-0ac0998ae2af"}]	"PostgreSQL"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["Generic service", [{"data": "Port 5432/tcp is open but is used in other service match patterns", "type": "reason"}]], "type": "container"}, "confidence": "NotApplicable"}, "metadata": [{"date": "2025-11-24T04:27:29.086905795Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
1ce643d7-2bb7-459a-86ad-47a0590c3a38	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:27:35.260039+00	2025-11-24 04:27:35.260039+00	Home Assistant	88b238dd-e868-4adf-a0be-926ced2be02a	[{"id": "1850ba13-89da-4fce-a37f-da94f28ab8fd", "type": "Port", "port_id": "b2276bfb-50e1-4c0a-b01c-f7d8fda68c5a", "interface_id": "10b69312-cabb-4e2e-8443-77634f820ee4"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:8123/ contained \\"home assistant\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-24T04:27:35.260029920Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
85008e5b-7be7-4c17-b4e8-3c2c5dda6130	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:27:40.382975+00	2025-11-24 04:27:40.382975+00	NetVisor Server API	88b238dd-e868-4adf-a0be-926ced2be02a	[{"id": "50f84469-30fc-4b01-b695-874fd822dbbf", "type": "Port", "port_id": "082353ff-96ce-4737-a599-15ee1463c28c", "interface_id": "10b69312-cabb-4e2e-8443-77634f820ee4"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response for 172.25.0.1:60072/api/health contained \\"netvisor\\" in body", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-24T04:27:40.382966277Z", "type": "Network", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
e5ad4339-a89a-4d7a-8a99-277626e3288d	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.241162+00	2025-11-24 04:26:57.241162+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
b00fd73f-99ca-4579-a1aa-0a289fcf9cd6	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.241166+00	2025-11-24 04:26:57.241166+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
734c2166-2836-454b-a251-2b4fe2332bd8	df280671-1bd9-48f4-9d4b-8cd38cc21efe	2025-11-24 04:26:57.358046+00	2025-11-24 04:26:57.358046+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-24T04:26:57.358044469Z", "type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae"}]}
\.


--
-- Data for Name: topologies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.topologies (id, network_id, name, edges, nodes, options, hosts, subnets, services, groups, is_stale, last_refreshed, is_locked, locked_at, locked_by, removed_hosts, removed_services, removed_subnets, removed_groups, parent_id, created_at, updated_at) FROM stdin;
96e1ce35-a656-4a12-8760-947492191dac	df280671-1bd9-48f4-9d4b-8cd38cc21efe	My Topology	[]	[]	{"local": {"no_fade_edges": false, "hide_edge_types": [], "left_zone_title": "Infrastructure", "hide_resize_handles": false}, "request": {"hide_ports": false, "hide_service_categories": [], "show_gateway_in_left_zone": true, "group_docker_bridges_by_host": false, "left_zone_service_categories": ["DNS", "ReverseProxy"], "hide_vm_title_on_docker_container": false}}	[]	[{"id": "e5ad4339-a89a-4d7a-8a99-277626e3288d", "cidr": "0.0.0.0/0", "name": "Internet", "source": {"type": "System"}, "created_at": "2025-11-24T04:26:57.241162Z", "network_id": "df280671-1bd9-48f4-9d4b-8cd38cc21efe", "updated_at": "2025-11-24T04:26:57.241162Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).", "subnet_type": "Internet"}, {"id": "b00fd73f-99ca-4579-a1aa-0a289fcf9cd6", "cidr": "0.0.0.0/0", "name": "Remote Network", "source": {"type": "System"}, "created_at": "2025-11-24T04:26:57.241166Z", "network_id": "df280671-1bd9-48f4-9d4b-8cd38cc21efe", "updated_at": "2025-11-24T04:26:57.241166Z", "description": "This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).", "subnet_type": "Remote"}, {"id": "734c2166-2836-454b-a251-2b4fe2332bd8", "cidr": "172.25.0.0/28", "name": "172.25.0.0/28", "source": {"type": "Discovery", "metadata": [{"date": "2025-11-24T04:26:57.358044469Z", "type": "SelfReport", "host_id": "bc639506-2d1d-4a31-b2b1-43ddcdaf64c5", "daemon_id": "16a42580-092a-4701-94c2-ed3089813bae"}]}, "created_at": "2025-11-24T04:26:57.358046Z", "network_id": "df280671-1bd9-48f4-9d4b-8cd38cc21efe", "updated_at": "2025-11-24T04:26:57.358046Z", "description": null, "subnet_type": "Lan"}]	[]	[]	t	2025-11-24 04:26:57.238883+00	f	\N	\N	{}	{}	{}	{}	\N	2025-11-24 04:26:57.238884+00	2025-11-24 04:27:29.125788+00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email, organization_id, permissions, network_ids) FROM stdin;
5913b099-52aa-482c-b929-3ea4d9ce48da	2025-11-24 04:26:53.729877+00	2025-11-24 04:26:57.224562+00	$argon2id$v=19$m=19456,t=2,p=1$dH6wt6m10IHGexyC+XZFwg$9jRfAB3XmBlLAL69CXoipQrQ4ppH18eF7PCKntyLyUY	\N	\N	\N	user@example.com	3c5386e3-5a57-471a-9352-f995d48687eb	Owner	{}
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
XtgXDyq9RVgleRY8q_-1ww	\\x93c410c3b5ffab3c1679255845bd2a0f17d85e81a7757365725f6964d92435393133623039392d353261612d343832632d623932392d33656134643963653438646199cd07e9cd0166041a39ce0d7b49b6000000	2025-12-24 04:26:57.226183+00
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

\unrestrict 2icdMN2u98KJq9ixPOWMpgkgBecbnETSjQ32T0omwe8TrqmdRj8kh4heyCbGDUg

