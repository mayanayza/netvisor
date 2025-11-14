--
-- PostgreSQL database dump
--

\restrict OngrekleCFGWJ1fY89j8P0R2vpXYK1jLXDBlzUNMtSfnQnWK3t2kz5hOnrrr3BK

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

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
    color text NOT NULL
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
    user_id uuid NOT NULL
);


ALTER TABLE public.networks OWNER TO postgres;

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
    email text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

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
20251006215000	users	2025-11-13 21:48:49.679441+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2939667
20251006215100	networks	2025-11-13 21:48:49.683+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2772583
20251006215151	create hosts	2025-11-13 21:48:49.68612+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	2471417
20251006215155	create subnets	2025-11-13 21:48:49.688889+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	2462458
20251006215201	create groups	2025-11-13 21:48:49.691673+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2540208
20251006215204	create daemons	2025-11-13 21:48:49.694425+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	2180334
20251006215212	create services	2025-11-13 21:48:49.696925+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	2891125
20251029193448	user-auth	2025-11-13 21:48:49.700096+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	2051709
20251030044828	daemon api	2025-11-13 21:48:49.702398+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	962458
20251030170438	host-hide	2025-11-13 21:48:49.703608+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	868459
20251102224919	create discovery	2025-11-13 21:48:49.704792+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	5242042
20251106235621	normalize-daemon-cols	2025-11-13 21:48:49.710229+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	1012583
20251107034459	api keys	2025-11-13 21:48:49.711459+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	3277500
20251107222650	oidc-auth	2025-11-13 21:48:49.71494+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	8573250
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
28d045d0-0428-4c25-8a07-013b9ae89f05	1bc6696d9ea34fa0b349a4772bc18fd1	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	Integrated Daemon API Key	2025-11-13 21:48:49.787498+00	2025-11-13 21:48:49.787498+00	\N	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color) FROM stdin;
60000000-0000-0000-0000-000000000001	10000000-0000-0000-0000-000000000001	Media Stack	Media server and management tools	{"group_type": "HubAndSpoke", "service_bindings": ["50000000-0000-0000-0000-000000000003", "50000000-0000-0000-0000-000000000004", "50000000-0000-0000-0000-000000000005", "50000000-0000-0000-0000-000000000006"]}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	{"type": "System"}	blue
60000000-0000-0000-0000-000000000002	10000000-0000-0000-0000-000000000001	Monitoring Stack	Metrics collection and visualization	{"group_type": "HubAndSpoke", "service_bindings": ["50000000-0000-0000-0000-000000000008", "50000000-0000-0000-0000-000000000009"]}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	{"type": "System"}	orange
60000000-0000-0000-0000-000000000003	10000000-0000-0000-0000-000000000001	Home Assistant Access	Web access to Home Assistant through reverse proxy	{"group_type": "RequestPath", "service_bindings": ["50000000-0000-0000-0000-000000000015", "50000000-0000-0000-0000-000000000013", "50000000-0000-0000-0000-000000000007"]}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	{"type": "System"}	green
60000000-0000-0000-0000-000000000004	10000000-0000-0000-0000-000000000001	DNS Resolution	DNS query path through Pi-hole to upstream resolver	{"group_type": "RequestPath", "service_bindings": ["50000000-0000-0000-0000-000000000015", "50000000-0000-0000-0000-000000000012", "50000000-0000-0000-0000-000000000020"]}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	{"type": "System"}	purple
60000000-0000-0000-0000-000000000005	10000000-0000-0000-0000-000000000001	Smart Home Hub	Home Assistant controlling smart home devices	{"group_type": "HubAndSpoke", "service_bindings": ["50000000-0000-0000-0000-000000000007", "50000000-0000-0000-0000-000000000016", "50000000-0000-0000-0000-000000000017", "50000000-0000-0000-0000-000000000018"]}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	{"type": "System"}	cyan
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
95ce7c79-6add-495b-8697-ed5428afc187	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "357a29fb-7e01-452e-ac42-5692ff4e6320"}	[{"id": "0699cc89-4fd3-4ac8-8122-7d6ce24e0355", "name": "Internet", "subnet_id": "d39dabc5-b28c-491d-b009-f4c05c78a1d5", "ip_address": "1.1.1.1", "mac_address": null}]	["f7c8f9ef-3610-4d4c-beef-bbe773078eb3"]	[{"id": "c9326e0d-1768-4236-a37b-ffdd65cc4f94", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-13 21:48:49.775651+00	2025-11-13 21:48:49.781668+00	f
8547708c-d0e4-4bba-8a02-032eaa0827a4	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	Google.com	\N	\N	{"type": "ServiceBinding", "config": "ff53a6dc-d2a5-42d1-b488-d387d4faec24"}	[{"id": "f25a78ca-3c30-441e-9823-83d2e2d62446", "name": "Internet", "subnet_id": "d39dabc5-b28c-491d-b009-f4c05c78a1d5", "ip_address": "203.0.113.1", "mac_address": null}]	["fd1562e7-39fd-4feb-9c2d-82c1f60f31a7"]	[{"id": "ebba9c39-598f-4eb4-a6f7-0761a85b537b", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 21:48:49.775668+00	2025-11-13 21:48:49.784894+00	f
8335e44f-9a6d-417d-a8c2-bafeea83debd	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "e70a0344-d42f-4f83-aef4-605f509b51c6"}	[{"id": "647744e7-ddf7-42e7-9609-df77f32f1c17", "name": "Remote Network", "subnet_id": "9337d667-b4d9-473a-8be2-06324c344cd4", "ip_address": "203.0.113.103", "mac_address": null}]	["c5044829-72d9-49b8-a446-a43040ae2c84"]	[{"id": "06bac886-3906-4dd0-a6bb-3dbddf1d46ef", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-13 21:48:49.775673+00	2025-11-13 21:48:49.787089+00	f
30000000-0000-0000-0000-000000000001	10000000-0000-0000-0000-000000000001	proxmox-host	proxmox.local	Proxmox VE hypervisor	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000001"}	[{"id": "31000000-0000-0000-0000-000000000001", "name": "vmbr0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.10", "mac_address": "52:54:00:12:34:01"}]	["40000000-0000-0000-0000-000000000001"]	[{"id": "32000000-0000-0000-0000-000000000001", "type": "Https", "number": 8006, "protocol": "Tcp"}]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000002	10000000-0000-0000-0000-000000000001	docker-host	docker.local	Docker container host	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000002"}	[{"id": "31000000-0000-0000-0000-000000000002", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.20", "mac_address": "52:54:00:12:34:02"}]	["40000000-0000-0000-0000-000000000002"]	[{"id": "32000000-0000-0000-0000-000000000002", "type": "Custom", "number": 2375, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Proxmox", "details": {"vm_id": "100", "vm_name": "docker-host", "service_id": "40000000-0000-0000-0000-000000000001"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000003	10000000-0000-0000-0000-000000000001	plex	\N	Plex Media Server	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000003"}	[{"id": "31000000-0000-0000-0000-000000000003", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000004", "ip_address": "172.18.0.10", "mac_address": "02:42:ac:12:00:0a"}]	["40000000-0000-0000-0000-000000000003"]	[{"id": "32000000-0000-0000-0000-000000000003", "type": "Custom", "number": 32400, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "plex-cnt", "container_name": "plex"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000004	10000000-0000-0000-0000-000000000001	sonarr	\N	TV show management	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000004"}	[{"id": "31000000-0000-0000-0000-000000000004", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000004", "ip_address": "172.18.0.11", "mac_address": "02:42:ac:12:00:0b"}]	["40000000-0000-0000-0000-000000000004"]	[{"id": "32000000-0000-0000-0000-000000000004", "type": "Http", "number": 8989, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "sonarr-cnt", "container_name": "sonarr"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000005	10000000-0000-0000-0000-000000000001	radarr	\N	Movie management	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000005"}	[{"id": "31000000-0000-0000-0000-000000000005", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000004", "ip_address": "172.18.0.12", "mac_address": "02:42:ac:12:00:0c"}]	["40000000-0000-0000-0000-000000000005"]	[{"id": "32000000-0000-0000-0000-000000000005", "type": "Http", "number": 7878, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "radarr-cnt", "container_name": "radarr"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000006	10000000-0000-0000-0000-000000000001	prowlarr	\N	Indexer manager	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000006"}	[{"id": "31000000-0000-0000-0000-000000000006", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000004", "ip_address": "172.18.0.13", "mac_address": "02:42:ac:12:00:0d"}]	["40000000-0000-0000-0000-000000000006"]	[{"id": "32000000-0000-0000-0000-000000000006", "type": "Http", "number": 9696, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "prowlarr-cnt", "container_name": "prowlarr"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000007	10000000-0000-0000-0000-000000000001	homeassistant	\N	Home automation hub	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000007"}	[{"id": "31000000-0000-0000-0000-000000000007", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000005", "ip_address": "172.17.0.10", "mac_address": "02:42:ac:11:00:0a"}]	["40000000-0000-0000-0000-000000000007"]	[{"id": "32000000-0000-0000-0000-000000000007", "type": "Http", "number": 8123, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "ha-cnt", "container_name": "homeassistant"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000008	10000000-0000-0000-0000-000000000001	grafana	\N	Metrics dashboard	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000008"}	[{"id": "31000000-0000-0000-0000-000000000008", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000005", "ip_address": "172.17.0.11", "mac_address": "02:42:ac:11:00:0b"}]	["40000000-0000-0000-0000-000000000008"]	[{"id": "32000000-0000-0000-0000-000000000008", "type": "Http", "number": 3000, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "grafana-cnt", "container_name": "grafana"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000009	10000000-0000-0000-0000-000000000001	prometheus	\N	Metrics collection	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000009"}	[{"id": "31000000-0000-0000-0000-000000000009", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000005", "ip_address": "172.17.0.12", "mac_address": "02:42:ac:11:00:0c"}]	["40000000-0000-0000-0000-000000000009"]	[{"id": "32000000-0000-0000-0000-000000000009", "type": "Http", "number": 9090, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "prom-cnt", "container_name": "prometheus"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000010	10000000-0000-0000-0000-000000000001	portainer	\N	Docker management UI	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000010"}	[{"id": "31000000-0000-0000-0000-000000000010", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000005", "ip_address": "172.17.0.13", "mac_address": "02:42:ac:11:00:0d"}]	["40000000-0000-0000-0000-000000000010"]	[{"id": "32000000-0000-0000-0000-000000000010", "type": "Http9000", "number": 9000, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "portainer-cnt", "container_name": "portainer"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000011	10000000-0000-0000-0000-000000000001	nas-server	nas.local	Synology NAS	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000011"}	[{"id": "31000000-0000-0000-0000-000000000011", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.30", "mac_address": "52:54:00:12:34:03"}]	["40000000-0000-0000-0000-000000000011"]	[{"id": "32000000-0000-0000-0000-000000000011", "type": "Http", "number": 5000, "protocol": "Tcp"}]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000012	10000000-0000-0000-0000-000000000001	pihole-server	pihole.local	DNS and ad blocking	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000012"}	[{"id": "31000000-0000-0000-0000-000000000012", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.40", "mac_address": "52:54:00:12:34:04"}]	["40000000-0000-0000-0000-000000000012"]	[{"id": "32000000-0000-0000-0000-000000000012", "type": "DnsUdp", "number": 53, "protocol": "Udp"}, {"id": "32000000-0000-0000-0000-000000000013", "type": "Http", "number": 80, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Proxmox", "details": {"vm_id": "101", "vm_name": "pihole", "service_id": "40000000-0000-0000-0000-000000000001"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000013	10000000-0000-0000-0000-000000000001	reverse-proxy	proxy.local	Nginx Proxy Manager	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000013"}	[{"id": "31000000-0000-0000-0000-000000000013", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.50", "mac_address": "52:54:00:12:34:05"}]	["40000000-0000-0000-0000-000000000013"]	[{"id": "32000000-0000-0000-0000-000000000014", "type": "HttpAlt", "number": 81, "protocol": "Tcp"}]	{"type": "System"}	{"type": "Proxmox", "details": {"vm_id": "102", "vm_name": "nginx-proxy", "service_id": "40000000-0000-0000-0000-000000000001"}}	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000014	10000000-0000-0000-0000-000000000001	pfsense-router	pfsense.local	Firewall and router	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000014"}	[{"id": "31000000-0000-0000-0000-000000000014", "name": "LAN", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.1", "mac_address": "52:54:00:12:34:fe"}, {"id": "31000000-0000-0000-0000-000000000015", "name": "IoT", "subnet_id": "20000000-0000-0000-0000-000000000002", "ip_address": "192.168.10.1", "mac_address": "52:54:00:12:34:ff"}, {"id": "31000000-0000-0000-0000-000000000016", "name": "Guest", "subnet_id": "20000000-0000-0000-0000-000000000003", "ip_address": "192.168.20.1", "mac_address": "52:54:00:12:35:00"}]	["40000000-0000-0000-0000-000000000014"]	[{"id": "32000000-0000-0000-0000-000000000015", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000015	10000000-0000-0000-0000-000000000001	workstation	desktop.local	Main desktop computer	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000015"}	[{"id": "31000000-0000-0000-0000-000000000017", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000001", "ip_address": "192.168.1.100", "mac_address": "52:54:00:12:34:64"}]	["40000000-0000-0000-0000-000000000015"]	[]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000016	10000000-0000-0000-0000-000000000001	hue-bridge	\N	Smart lighting hub	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000016"}	[{"id": "31000000-0000-0000-0000-000000000018", "name": "eth0", "subnet_id": "20000000-0000-0000-0000-000000000002", "ip_address": "192.168.10.10", "mac_address": "00:17:88:01:02:03"}]	["40000000-0000-0000-0000-000000000016"]	[{"id": "32000000-0000-0000-0000-000000000016", "type": "Http", "number": 80, "protocol": "Tcp"}]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000017	10000000-0000-0000-0000-000000000001	google-home	\N	Smart speaker	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000017"}	[{"id": "31000000-0000-0000-0000-000000000019", "name": "wlan0", "subnet_id": "20000000-0000-0000-0000-000000000002", "ip_address": "192.168.10.20", "mac_address": "54:60:09:01:02:03"}]	["40000000-0000-0000-0000-000000000017"]	[]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000018	10000000-0000-0000-0000-000000000001	nest-thermostat	\N	Smart thermostat	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000018"}	[{"id": "31000000-0000-0000-0000-000000000020", "name": "wlan0", "subnet_id": "20000000-0000-0000-0000-000000000002", "ip_address": "192.168.10.30", "mac_address": "18:b4:30:01:02:03"}]	["40000000-0000-0000-0000-000000000018"]	[]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000019	10000000-0000-0000-0000-000000000001	guest-device	\N	Guest device	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000019"}	[{"id": "31000000-0000-0000-0000-000000000021", "name": "wlan0", "subnet_id": "20000000-0000-0000-0000-000000000003", "ip_address": "192.168.20.100", "mac_address": "aa:bb:cc:dd:ee:01"}]	["40000000-0000-0000-0000-000000000019"]	[]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000020	10000000-0000-0000-0000-000000000001	cloudflare-dns	\N	Public DNS resolver	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000020"}	[{"id": "31000000-0000-0000-0000-000000000022", "name": "Internet", "subnet_id": "20000000-0000-0000-0000-000000000007", "ip_address": "1.1.1.1", "mac_address": null}]	["40000000-0000-0000-0000-000000000020"]	[{"id": "32000000-0000-0000-0000-000000000017", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
30000000-0000-0000-0000-000000000021	10000000-0000-0000-0000-000000000001	mobile-device	\N	Smartphone via VPN	{"type": "ServiceBinding", "config": "50000000-0000-0000-0000-000000000021"}	[{"id": "31000000-0000-0000-0000-000000000023", "name": "Remote", "subnet_id": "20000000-0000-0000-0000-000000000008", "ip_address": "203.0.113.100", "mac_address": null}]	["40000000-0000-0000-0000-000000000021"]	[]	{"type": "System"}	\N	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
4c2c3553-fcd2-4e58-96bc-e63c60f6623b	My Network	2025-11-13 21:48:49.774312+00	2025-11-13 21:48:49.774312+00	t	7f16c887-bc4f-4f6f-9c04-4c1dde2d40e2
10000000-0000-0000-0000-000000000001	Sophisticated Homelab	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	t	10000000-0000-0000-0000-000000000000
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
f7c8f9ef-3610-4d4c-beef-bbe773078eb3	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	2025-11-13 21:48:49.775664+00	2025-11-13 21:48:49.775664+00	Cloudflare DNS	95ce7c79-6add-495b-8697-ed5428afc187	[{"id": "357a29fb-7e01-452e-ac42-5692ff4e6320", "type": "Port", "port_id": "c9326e0d-1768-4236-a37b-ffdd65cc4f94", "interface_id": "0699cc89-4fd3-4ac8-8122-7d6ce24e0355"}]	"Dns Server"	null	{"type": "System"}
fd1562e7-39fd-4feb-9c2d-82c1f60f31a7	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	2025-11-13 21:48:49.775669+00	2025-11-13 21:48:49.775669+00	Google.com	8547708c-d0e4-4bba-8a02-032eaa0827a4	[{"id": "ff53a6dc-d2a5-42d1-b488-d387d4faec24", "type": "Port", "port_id": "ebba9c39-598f-4eb4-a6f7-0761a85b537b", "interface_id": "f25a78ca-3c30-441e-9823-83d2e2d62446"}]	"Web Service"	null	{"type": "System"}
c5044829-72d9-49b8-a446-a43040ae2c84	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	2025-11-13 21:48:49.775674+00	2025-11-13 21:48:49.775674+00	Mobile Device	8335e44f-9a6d-417d-a8c2-bafeea83debd	[{"id": "e70a0344-d42f-4f83-aef4-605f509b51c6", "type": "Port", "port_id": "06bac886-3906-4dd0-a6bb-3dbddf1d46ef", "interface_id": "647744e7-ddf7-42e7-9609-df77f32f1c17"}]	"Client"	null	{"type": "System"}
40000000-0000-0000-0000-000000000001	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Proxmox VE	30000000-0000-0000-0000-000000000001	[{"id": "50000000-0000-0000-0000-000000000001", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000001", "interface_id": "31000000-0000-0000-0000-000000000001"}]	Proxmox	\N	{"type": "System"}
40000000-0000-0000-0000-000000000002	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Docker	30000000-0000-0000-0000-000000000002	[{"id": "50000000-0000-0000-0000-000000000002", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000002", "interface_id": "31000000-0000-0000-0000-000000000002"}]	Docker	\N	{"type": "System"}
40000000-0000-0000-0000-000000000003	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Plex Media Server	30000000-0000-0000-0000-000000000003	[{"id": "50000000-0000-0000-0000-000000000003", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000003", "interface_id": "31000000-0000-0000-0000-000000000003"}]	Plex Media Server	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "plex-cnt", "container_name": "plex"}}	{"type": "System"}
40000000-0000-0000-0000-000000000004	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Sonarr	30000000-0000-0000-0000-000000000004	[{"id": "50000000-0000-0000-0000-000000000004", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000004", "interface_id": "31000000-0000-0000-0000-000000000004"}]	Sonarr	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "sonarr-cnt", "container_name": "sonarr"}}	{"type": "System"}
40000000-0000-0000-0000-000000000005	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Radarr	30000000-0000-0000-0000-000000000005	[{"id": "50000000-0000-0000-0000-000000000005", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000005", "interface_id": "31000000-0000-0000-0000-000000000005"}]	Radarr	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "radarr-cnt", "container_name": "radarr"}}	{"type": "System"}
40000000-0000-0000-0000-000000000006	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Prowlarr	30000000-0000-0000-0000-000000000006	[{"id": "50000000-0000-0000-0000-000000000006", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000006", "interface_id": "31000000-0000-0000-0000-000000000006"}]	Prowlarr	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "prowlarr-cnt", "container_name": "prowlarr"}}	{"type": "System"}
40000000-0000-0000-0000-000000000007	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Home Assistant	30000000-0000-0000-0000-000000000007	[{"id": "50000000-0000-0000-0000-000000000007", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000007", "interface_id": "31000000-0000-0000-0000-000000000007"}]	Home Assistant	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "ha-cnt", "container_name": "homeassistant"}}	{"type": "System"}
40000000-0000-0000-0000-000000000008	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Grafana	30000000-0000-0000-0000-000000000008	[{"id": "50000000-0000-0000-0000-000000000008", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000008", "interface_id": "31000000-0000-0000-0000-000000000008"}]	Grafana	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "grafana-cnt", "container_name": "grafana"}}	{"type": "System"}
40000000-0000-0000-0000-000000000009	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Prometheus	30000000-0000-0000-0000-000000000009	[{"id": "50000000-0000-0000-0000-000000000009", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000009", "interface_id": "31000000-0000-0000-0000-000000000009"}]	Prometheus	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "prom-cnt", "container_name": "prometheus"}}	{"type": "System"}
40000000-0000-0000-0000-000000000010	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Portainer	30000000-0000-0000-0000-000000000010	[{"id": "50000000-0000-0000-0000-000000000010", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000010", "interface_id": "31000000-0000-0000-0000-000000000010"}]	Portainer	{"type": "Docker", "details": {"service_id": "40000000-0000-0000-0000-000000000002", "container_id": "portainer-cnt", "container_name": "portainer"}}	{"type": "System"}
40000000-0000-0000-0000-000000000011	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Synology DSM	30000000-0000-0000-0000-000000000011	[{"id": "50000000-0000-0000-0000-000000000011", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000011", "interface_id": "31000000-0000-0000-0000-000000000011"}]	Synology	\N	{"type": "System"}
40000000-0000-0000-0000-000000000012	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Pi-Hole	30000000-0000-0000-0000-000000000012	[{"id": "50000000-0000-0000-0000-000000000012", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000012", "interface_id": "31000000-0000-0000-0000-000000000012"}]	Pi-Hole	\N	{"type": "System"}
40000000-0000-0000-0000-000000000013	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Nginx Proxy Manager	30000000-0000-0000-0000-000000000013	[{"id": "50000000-0000-0000-0000-000000000013", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000014", "interface_id": "31000000-0000-0000-0000-000000000013"}]	Nginx Proxy Manager	\N	{"type": "System"}
40000000-0000-0000-0000-000000000014	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	pfSense	30000000-0000-0000-0000-000000000014	[{"id": "50000000-0000-0000-0000-000000000014", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000015", "interface_id": "31000000-0000-0000-0000-000000000014"}]	pfSense	\N	{"type": "System"}
40000000-0000-0000-0000-000000000015	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Workstation	30000000-0000-0000-0000-000000000015	[{"id": "50000000-0000-0000-0000-000000000015", "type": "Interface", "interface_id": "31000000-0000-0000-0000-000000000017"}]	Workstation	\N	{"type": "System"}
40000000-0000-0000-0000-000000000016	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Philips Hue Bridge	30000000-0000-0000-0000-000000000016	[{"id": "50000000-0000-0000-0000-000000000016", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000016", "interface_id": "31000000-0000-0000-0000-000000000018"}]	Philips Hue Bridge	\N	{"type": "System"}
40000000-0000-0000-0000-000000000017	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Google Home	30000000-0000-0000-0000-000000000017	[{"id": "50000000-0000-0000-0000-000000000017", "type": "Interface", "interface_id": "31000000-0000-0000-0000-000000000019"}]	Google Home	\N	{"type": "System"}
40000000-0000-0000-0000-000000000018	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Nest Thermostat	30000000-0000-0000-0000-000000000018	[{"id": "50000000-0000-0000-0000-000000000018", "type": "Interface", "interface_id": "31000000-0000-0000-0000-000000000020"}]	Nest Thermostat	\N	{"type": "System"}
40000000-0000-0000-0000-000000000019	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Client	30000000-0000-0000-0000-000000000019	[{"id": "50000000-0000-0000-0000-000000000019", "type": "Interface", "interface_id": "31000000-0000-0000-0000-000000000021"}]	Client	\N	{"type": "System"}
40000000-0000-0000-0000-000000000020	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Cloudflare DNS	30000000-0000-0000-0000-000000000020	[{"id": "50000000-0000-0000-0000-000000000020", "type": "Port", "port_id": "32000000-0000-0000-0000-000000000017", "interface_id": "31000000-0000-0000-0000-000000000022"}]	Dns Server	\N	{"type": "System"}
40000000-0000-0000-0000-000000000021	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	Mobile Client	30000000-0000-0000-0000-000000000021	[{"id": "50000000-0000-0000-0000-000000000021", "type": "Interface", "interface_id": "31000000-0000-0000-0000-000000000023"}]	Client	\N	{"type": "System"}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
d39dabc5-b28c-491d-b009-f4c05c78a1d5	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	2025-11-13 21:48:49.775574+00	2025-11-13 21:48:49.775574+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
9337d667-b4d9-473a-8be2-06324c344cd4	4c2c3553-fcd2-4e58-96bc-e63c60f6623b	2025-11-13 21:48:49.775576+00	2025-11-13 21:48:49.775576+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
20000000-0000-0000-0000-000000000001	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	192.168.1.0/24	Main LAN	Primary home network	Lan	{"type": "System"}
20000000-0000-0000-0000-000000000002	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	192.168.10.0/24	IoT VLAN	Smart home devices	Lan	{"type": "System"}
20000000-0000-0000-0000-000000000003	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	192.168.20.0/24	Guest Network	Guest WiFi	Guest	{"type": "System"}
20000000-0000-0000-0000-000000000004	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	172.18.0.0/16	docker-media	Docker media stack network	DockerBridge	{"type": "System"}
20000000-0000-0000-0000-000000000005	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	172.17.0.0/16	docker0	Docker default bridge	DockerBridge	{"type": "System"}
20000000-0000-0000-0000-000000000006	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	192.168.100.0/24	VPN Network	WireGuard VPN clients	Vpn	{"type": "System"}
20000000-0000-0000-0000-000000000007	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	0.0.0.0/0	Internet	External services	Internet	{"type": "System"}
20000000-0000-0000-0000-000000000008	10000000-0000-0000-0000-000000000001	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	0.0.0.0/0	Remote Network	Remote devices	Remote	{"type": "System"}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
7f16c887-bc4f-4f6f-9c04-4c1dde2d40e2	2025-11-13 21:48:49.773483+00	2025-11-13 21:48:49.773483+00	\N	\N	\N	\N	efd9a9b5-64d4-4f32-90a1-8439656bfa37@netvisor.io
10000000-0000-0000-0000-000000000000	2025-01-01 00:00:00+00	2025-01-01 00:00:00+00	$argon2i$v=19$m=16,t=2,p=1$YlhLQ0pHWnFuQ1BhMk9xUQ$XHNym8chDbftc9sEUHdVOg	\N	\N	\N	test@test.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
BA9O-3X7JgVoTnJDvh6R9Q	\\x93c410f5911ebe43724e680526fb75fb4e0f0481a7757365725f6964d92431303030303030302d303030302d303030302d303030302d30303030303030303030303099cd07e9cd015b153117ce3400b2c8000000	2025-12-13 21:49:23.872461+00
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
-- Name: networks networks_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- PostgreSQL database dump complete
--

\unrestrict OngrekleCFGWJ1fY89j8P0R2vpXYK1jLXDBlzUNMtSfnQnWK3t2kz5hOnrrr3BK

