--
-- PostgreSQL database dump
--

\restrict OyHJwGlF1m5muVQCaB84mLbuOXzkNHZGInlbaxIaNvwatPYGpC80p6c89E0n1Dn

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

ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_host_id_fkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.discovery DROP CONSTRAINT IF EXISTS discovery_daemon_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
ALTER TABLE IF EXISTS ONLY public.api_keys DROP CONSTRAINT IF EXISTS api_keys_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_oidc_provider_subject;
DROP INDEX IF EXISTS public.idx_users_email_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
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
20251006215000	users	2025-11-08 20:34:19.295782+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	6097583
20251006215100	networks	2025-11-08 20:34:19.304061+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4337459
20251006215151	create hosts	2025-11-08 20:34:19.308678+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	2000125
20251006215155	create subnets	2025-11-08 20:34:19.310922+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	3503167
20251006215201	create groups	2025-11-08 20:34:19.314833+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	2740208
20251006215204	create daemons	2025-11-08 20:34:19.317709+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	3210292
20251006215212	create services	2025-11-08 20:34:19.321343+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	3187292
20251029193448	user-auth	2025-11-08 20:34:19.324724+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	14600875
20251030044828	daemon api	2025-11-08 20:34:19.339491+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	639417
20251030170438	host-hide	2025-11-08 20:34:19.340277+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	480375
20251102224919	create discovery	2025-11-08 20:34:19.340906+00	t	\\xb32a04abb891aba48f92a059fae7341442355ca8e4af5d109e28e2a4f79ee8e11b2a8f40453b7f6725c2dd6487f26573	5955958
20251106235621	normalize-daemon-cols	2025-11-08 20:34:19.347012+00	t	\\x5b137118d506e2708097c432358bf909265b3cf3bacd662b02e2c81ba589a9e0100631c7801cffd9c57bb10a6674fb3b	582291
20251107034459	api keys	2025-11-08 20:34:19.347779+00	t	\\x3133ec043c0c6e25b6e55f7da84cae52b2a72488116938a2c669c8512c2efe72a74029912bcba1f2a2a0a8b59ef01dde	5429208
20251107222650	oidc-auth	2025-11-08 20:34:19.353405+00	t	\\xd349750e0298718cbcd98eaff6e152b3fb45c3d9d62d06eedeb26c75452e9ce1af65c3e52c9f2de4bd532939c2f31096	12588459
\.


--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_keys (id, key, network_id, name, created_at, updated_at, last_used, expires_at, is_enabled) FROM stdin;
de7c726d-106a-42bc-af04-6ddf7537262f	2f46c70ebe954a7da70fd7b6c13beb96	6da3caff-c772-413c-97d6-24c9d15281ab	Integrated Daemon API Key	2025-11-08 20:34:19.425784+00	2025-11-08 20:35:26.689023+00	2025-11-08 20:35:26.685487+00	\N	t
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, created_at, last_seen, capabilities, updated_at) FROM stdin;
6157f68a-50db-4045-9b94-d9715e7adce9	6da3caff-c772-413c-97d6-24c9d15281ab	4e04f3fa-034c-40b7-a547-3462c2dc8fae	"172.25.0.4"	60073	2025-11-08 20:34:19.483305+00	2025-11-08 20:34:19.483304+00	{"has_docker_socket": false, "interfaced_subnet_ids": ["2eb09447-ca29-43e9-942b-7c55a4b3921c"]}	2025-11-08 20:34:19.493116+00
\.


--
-- Data for Name: discovery; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.discovery (id, network_id, daemon_id, run_type, discovery_type, name, created_at, updated_at) FROM stdin;
18827cb0-469f-48da-bc11-b26a331663ca	6da3caff-c772-413c-97d6-24c9d15281ab	6157f68a-50db-4045-9b94-d9715e7adce9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae"}	Self Report @ 172.25.0.4	2025-11-08 20:34:19.483963+00	2025-11-08 20:34:19.483963+00
b39e05c2-3b25-4dc9-b50e-48653e4c0ca5	6da3caff-c772-413c-97d6-24c9d15281ab	6157f68a-50db-4045-9b94-d9715e7adce9	{"type": "Scheduled", "enabled": true, "last_run": null, "cron_schedule": "0 0 0 * * *"}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Network Scan @ 172.25.0.4	2025-11-08 20:34:19.487198+00	2025-11-08 20:34:19.487198+00
bcb0fc7d-0192-4133-bb6a-28b33646f038	6da3caff-c772-413c-97d6-24c9d15281ab	6157f68a-50db-4045-9b94-d9715e7adce9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "processed": 1, "network_id": "6da3caff-c772-413c-97d6-24c9d15281ab", "session_id": "1240fa2d-e5be-4a00-b362-34c4b69f31e5", "started_at": "2025-11-08T20:34:19.487079090Z", "finished_at": "2025-11-08T20:34:19.498969632Z", "discovery_type": {"type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae"}, "total_to_process": 1}}	{"type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae"}	Discovery Run	2025-11-08 20:34:19.487079+00	2025-11-08 20:34:19.499453+00
ffa23467-90cd-4d83-a35c-30795c91e7c3	6da3caff-c772-413c-97d6-24c9d15281ab	6157f68a-50db-4045-9b94-d9715e7adce9	{"type": "Historical", "results": {"error": null, "phase": "Complete", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "processed": 12, "network_id": "6da3caff-c772-413c-97d6-24c9d15281ab", "session_id": "4c262c4c-eb8a-47e6-be3b-297836b59f5f", "started_at": "2025-11-08T20:34:19.506499799Z", "finished_at": "2025-11-08T20:35:26.639742636Z", "discovery_type": {"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}, "total_to_process": 16}}	{"type": "Network", "subnet_ids": null, "host_naming_fallback": "BestService"}	Discovery Run	2025-11-08 20:34:19.506499+00	2025-11-08 20:35:26.688674+00
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at, hidden) FROM stdin;
2d5ef120-3721-4c6e-82b5-83a78f535706	6da3caff-c772-413c-97d6-24c9d15281ab	Cloudflare DNS	\N	\N	{"type": "ServiceBinding", "config": "dec9d1ab-b666-40cb-8d14-654a265a7c35"}	[{"id": "00feed89-bcdb-442e-a735-75bc5cba709d", "name": "Internet", "subnet_id": "1b7119ae-9b65-40d6-98dc-e35407240635", "ip_address": "1.1.1.1", "mac_address": null}]	["6de2446e-45ca-4165-95e3-9640b934294f"]	[{"id": "4bb72b22-7c54-4b65-ac21-6ecc5651bd68", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-11-08 20:34:19.410515+00	2025-11-08 20:34:19.417594+00	f
506a9862-714e-444b-bbe6-6a215187994b	6da3caff-c772-413c-97d6-24c9d15281ab	Google.com	\N	\N	{"type": "ServiceBinding", "config": "df028430-48f5-4e63-8b98-f9664bf0ad84"}	[{"id": "d6f36ca9-e4e2-4438-8b4c-f19c6dd75d9e", "name": "Internet", "subnet_id": "1b7119ae-9b65-40d6-98dc-e35407240635", "ip_address": "203.0.113.217", "mac_address": null}]	["93a5d952-4790-4249-bffc-d3427a23e95b"]	[{"id": "352729c9-3ad5-4bf8-855f-8b7361d43b0a", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 20:34:19.41052+00	2025-11-08 20:34:19.420646+00	f
d9163714-50c0-4475-bf6f-736ea5a70178	6da3caff-c772-413c-97d6-24c9d15281ab	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "dfaba881-e84d-4a5e-8e99-aef423e29587"}	[{"id": "3d83e5e4-aa31-4980-9d30-71a1a789c5c3", "name": "Remote Network", "subnet_id": "bc96fe5e-8b06-48e2-a74f-43346c4a8f4b", "ip_address": "203.0.113.174", "mac_address": null}]	["1ea74035-6492-49fe-b613-c93726ecb3d5"]	[{"id": "f4118c71-e628-48b9-be50-c1745d0053d0", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-11-08 20:34:19.410522+00	2025-11-08 20:34:19.425375+00	f
37aae152-5374-4b52-9252-7471bb1c6acb	6da3caff-c772-413c-97d6-24c9d15281ab	netvisor-server-1.netvisor_netvisor-dev	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "cd21a96e-e260-4a14-bd28-0a8a6c5ae169", "name": null, "subnet_id": "2eb09447-ca29-43e9-942b-7c55a4b3921c", "ip_address": "172.25.0.3", "mac_address": "D2:CA:F0:17:7D:66"}]	["9dcef035-7591-4854-80e5-18c83e0fe843"]	[{"id": "98008b39-5359-4aea-b43a-d4ddefd053ff", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:34:23.553639217Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:34:23.553643+00	2025-11-08 20:34:33.312206+00	f
ca1c031c-5e2a-483b-a8e8-3af9e42d9110	6da3caff-c772-413c-97d6-24c9d15281ab	homeassistant-discovery.netvisor_netvisor-dev	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "97e16e8c-f17b-4fac-81ab-1e5b018fbea0", "name": null, "subnet_id": "2eb09447-ca29-43e9-942b-7c55a4b3921c", "ip_address": "172.25.0.5", "mac_address": "52:14:1F:52:4A:8D"}]	["8f113c82-6572-4765-9260-3c0b921859b1"]	[{"id": "c984cfed-e9e7-4b8e-9e97-7ffe036289e2", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:34:33.259285555Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:34:33.259286+00	2025-11-08 20:34:42.333031+00	f
4e04f3fa-034c-40b7-a547-3462c2dc8fae	6da3caff-c772-413c-97d6-24c9d15281ab	172.25.0.4	56357de64c4c	NetVisor daemon	{"type": "None"}	[{"id": "224d34a6-24f0-48d5-9533-8e0cba506bac", "name": "eth0", "subnet_id": "2eb09447-ca29-43e9-942b-7c55a4b3921c", "ip_address": "172.25.0.4", "mac_address": "82:93:81:2E:8E:F2"}]	["7dda57d9-23bb-4566-8b88-dac590ffe791", "3d87a8bb-e987-40d4-98ab-3a5b1fd7be11"]	[{"id": "a9eb87bb-1df8-4098-9b4d-999cb1bdc7dd", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:34:23.550635676Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T20:34:19.493855507Z", "type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9"}]}	null	2025-11-08 20:34:19.447121+00	2025-11-08 20:34:23.570115+00	f
abf410b4-b5ac-4a13-a9e2-2293092ac974	6da3caff-c772-413c-97d6-24c9d15281ab	NetVisor Server API	\N	\N	{"type": "None"}	[{"id": "8911b885-12d8-4c42-b5b7-0a9f5e641ae0", "name": null, "subnet_id": "2eb09447-ca29-43e9-942b-7c55a4b3921c", "ip_address": "172.25.0.1", "mac_address": "AA:F5:86:07:85:2C"}]	["38356603-bf1a-4a43-9a22-4d33bbb65ca0", "7ff4179b-a5d4-4a84-a619-73cecc7eee25"]	[{"id": "89edda74-c4e8-43f6-9e96-c9c602cdf5ce", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "0ed13c51-d531-462e-a72b-f03b2ad43fc6", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:34:42.327080837Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}	null	2025-11-08 20:34:42.327084+00	2025-11-08 20:34:52.22652+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
6da3caff-c772-413c-97d6-24c9d15281ab	My Network	2025-11-08 20:34:19.40925+00	2025-11-08 20:34:19.40925+00	t	6289f8ac-3773-4d87-92d7-31e2757e328b
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
6de2446e-45ca-4165-95e3-9640b934294f	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.410517+00	2025-11-08 20:34:19.417097+00	Cloudflare DNS	2d5ef120-3721-4c6e-82b5-83a78f535706	[{"id": "dec9d1ab-b666-40cb-8d14-654a265a7c35", "type": "Port", "port_id": "4bb72b22-7c54-4b65-ac21-6ecc5651bd68", "interface_id": "00feed89-bcdb-442e-a735-75bc5cba709d"}]	"Dns Server"	null	{"type": "System"}
93a5d952-4790-4249-bffc-d3427a23e95b	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.41052+00	2025-11-08 20:34:19.420077+00	Google.com	506a9862-714e-444b-bbe6-6a215187994b	[{"id": "df028430-48f5-4e63-8b98-f9664bf0ad84", "type": "Port", "port_id": "352729c9-3ad5-4bf8-855f-8b7361d43b0a", "interface_id": "d6f36ca9-e4e2-4438-8b4c-f19c6dd75d9e"}]	"Web Service"	null	{"type": "System"}
1ea74035-6492-49fe-b613-c93726ecb3d5	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.410522+00	2025-11-08 20:34:19.424868+00	Mobile Device	d9163714-50c0-4475-bf6f-736ea5a70178	[{"id": "dfaba881-e84d-4a5e-8e99-aef423e29587", "type": "Port", "port_id": "f4118c71-e628-48b9-be50-c1745d0053d0", "interface_id": "3d83e5e4-aa31-4980-9d30-71a1a789c5c3"}]	"Client"	null	{"type": "System"}
8f113c82-6572-4765-9260-3c0b921859b1	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:36.050615+00	2025-11-08 20:34:42.332616+00	Home Assistant	ca1c031c-5e2a-483b-a8e8-3af9e42d9110	[{"id": "98604816-783e-4c55-9a22-95e366286445", "type": "Port", "port_id": "c984cfed-e9e7-4b8e-9e97-7ffe036289e2", "interface_id": "97e16e8c-f17b-4fac-81ab-1e5b018fbea0"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:34:36.050589417Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7dda57d9-23bb-4566-8b88-dac590ffe791	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.493877+00	2025-11-08 20:34:23.568204+00	NetVisor Daemon API	4e04f3fa-034c-40b7-a547-3462c2dc8fae	[{"id": "72403c52-598a-4425-8358-a780d97b493f", "type": "Port", "port_id": "a9eb87bb-1df8-4098-9b4d-999cb1bdc7dd", "interface_id": "224d34a6-24f0-48d5-9533-8e0cba506bac"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": ["NetVisor Daemon self-report", [{"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, {"data": "NetVisor Daemon self-report", "type": "reason"}]], "type": "container"}, "confidence": "Certain"}, "metadata": [{"date": "2025-11-08T20:34:23.551056509Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}, {"date": "2025-11-08T20:34:19.493870799Z", "type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9"}]}
9dcef035-7591-4854-80e5-18c83e0fe843	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:26.554831+00	2025-11-08 20:34:33.311684+00	NetVisor Server API	37aae152-5374-4b52-9252-7471bb1c6acb	[{"id": "d590d2a5-0b16-4b5e-ae58-81dd9398fcf1", "type": "Port", "port_id": "98008b39-5359-4aea-b43a-d4ddefd053ff", "interface_id": "cd21a96e-e260-4a14-bd28-0a8a6c5ae169"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:34:26.554820594Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
38356603-bf1a-4a43-9a22-4d33bbb65ca0	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:45.261425+00	2025-11-08 20:34:52.194369+00	NetVisor Server API	abf410b4-b5ac-4a13-a9e2-2293092ac974	[{"id": "a614f28b-f71a-47b5-a73f-21185ea6ae31", "type": "Port", "port_id": "89edda74-c4e8-43f6-9e96-c9c602cdf5ce", "interface_id": "8911b885-12d8-4c42-b5b7-0a9f5e641ae0"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:34:45.261407505Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
7ff4179b-a5d4-4a84-a619-73cecc7eee25	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:45.261522+00	2025-11-08 20:34:52.225983+00	Home Assistant	abf410b4-b5ac-4a13-a9e2-2293092ac974	[{"id": "985c79f7-cdba-4197-92aa-c3134fdea586", "type": "Port", "port_id": "0ed13c51-d531-462e-a72b-f03b2ad43fc6", "interface_id": "8911b885-12d8-4c42-b5b7-0a9f5e641ae0"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-11-08T20:34:45.261518380Z", "type": "Network", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9", "subnet_ids": null, "host_naming_fallback": "BestService"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
1b7119ae-9b65-40d6-98dc-e35407240635	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.410421+00	2025-11-08 20:34:19.410421+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
bc96fe5e-8b06-48e2-a74f-43346c4a8f4b	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.410424+00	2025-11-08 20:34:19.410424+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
2eb09447-ca29-43e9-942b-7c55a4b3921c	6da3caff-c772-413c-97d6-24c9d15281ab	2025-11-08 20:34:19.488523+00	2025-11-08 20:34:19.488523+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-11-08T20:34:19.488514632Z", "type": "SelfReport", "host_id": "4e04f3fa-034c-40b7-a547-3462c2dc8fae", "daemon_id": "6157f68a-50db-4045-9b94-d9715e7adce9"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, created_at, updated_at, password_hash, oidc_provider, oidc_subject, oidc_linked_at, email) FROM stdin;
6289f8ac-3773-4d87-92d7-31e2757e328b	2025-11-08 20:34:19.408607+00	2025-11-08 20:34:21.927062+00	$argon2id$v=19$m=19456,t=2,p=1$p1CwdL2oJxckLV5E0R2X+g$93oDaq8dEpJKVGl+5gGegQ+AGmscAeX/uPxfu2XJwRM	\N	\N	\N	user@example.com
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
HajPbCIG3pF_ukFms6qb2w	\\x93c410db9baab36641ba7f91de06226ccfa81d81a7757365725f6964d92436323839663861632d333737332d346438372d393264372d33316532373537653332386299cd07e9cd0156142215ce376adf10000000	2025-12-08 20:34:21.92975+00
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

\unrestrict OyHJwGlF1m5muVQCaB84mLbuOXzkNHZGInlbaxIaNvwatPYGpC80p6c89E0n1Dn

