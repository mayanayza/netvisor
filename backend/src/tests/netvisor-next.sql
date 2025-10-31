--
-- PostgreSQL database dump
--

\restrict hYYQiX8qX4HPILHratXKxhEijfsECSKnV1NIBT8Pi8ODwmWMyILhqXdVh3yiTpZ

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
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_network_id_fkey;
DROP INDEX IF EXISTS public.idx_users_name_lower;
DROP INDEX IF EXISTS public.idx_subnets_network;
DROP INDEX IF EXISTS public.idx_services_network;
DROP INDEX IF EXISTS public.idx_services_host_id;
DROP INDEX IF EXISTS public.idx_hosts_network;
DROP INDEX IF EXISTS public.idx_groups_network;
DROP INDEX IF EXISTS public.idx_daemons_network;
DROP INDEX IF EXISTS public.idx_daemons_api_key_hash;
DROP INDEX IF EXISTS public.idx_daemon_host_id;
ALTER TABLE IF EXISTS ONLY tower_sessions.session DROP CONSTRAINT IF EXISTS session_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.subnets DROP CONSTRAINT IF EXISTS subnets_pkey;
ALTER TABLE IF EXISTS ONLY public.services DROP CONSTRAINT IF EXISTS services_pkey;
ALTER TABLE IF EXISTS ONLY public.networks DROP CONSTRAINT IF EXISTS networks_pkey;
ALTER TABLE IF EXISTS ONLY public.hosts DROP CONSTRAINT IF EXISTS hosts_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.daemons DROP CONSTRAINT IF EXISTS daemons_pkey;
ALTER TABLE IF EXISTS ONLY public._sqlx_migrations DROP CONSTRAINT IF EXISTS _sqlx_migrations_pkey;
DROP TABLE IF EXISTS tower_sessions.session;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.subnets;
DROP TABLE IF EXISTS public.services;
DROP TABLE IF EXISTS public.networks;
DROP TABLE IF EXISTS public.hosts;
DROP TABLE IF EXISTS public.groups;
DROP TABLE IF EXISTS public.daemons;
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
-- Name: daemons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.daemons (
    id uuid NOT NULL,
    network_id uuid NOT NULL,
    host_id uuid NOT NULL,
    ip text NOT NULL,
    port integer NOT NULL,
    registered_at timestamp with time zone NOT NULL,
    last_seen timestamp with time zone NOT NULL,
    api_key text
);


ALTER TABLE public.daemons OWNER TO postgres;

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
    name text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    password_hash text,
    username text
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
20251006215000	users	2025-10-31 15:07:46.798361+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	4676625
20251006215100	networks	2025-10-31 15:07:46.806149+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	4354000
20251006215151	create hosts	2025-10-31 15:07:46.810946+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	3052042
20251006215155	create subnets	2025-10-31 15:07:46.814353+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	8346125
20251006215201	create groups	2025-10-31 15:07:46.822906+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1752042
20251006215204	create daemons	2025-10-31 15:07:46.824861+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	7789292
20251006215212	create services	2025-10-31 15:07:46.833066+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	2453708
20251029193448	user-auth	2025-10-31 15:07:46.835775+00	t	\\xfde8161a8db89d51eeade7517d90a41d560f19645620f2298f78f116219a09728b18e91251ae31e46a47f6942d5a9032	33631125
20251030044828	daemon api	2025-10-31 15:07:46.869635+00	t	\\x181eb3541f51ef5b038b2064660370775d1b364547a214a20dde9c9d4bb95a1c273cd4525ef29e61fa65a3eb4fee0400	736875
20251030170438	host-hide	2025-10-31 15:07:46.870594+00	t	\\x87c6fda7f8456bf610a78e8e98803158caa0e12857c5bab466a5bb0004d41b449004a68e728ca13f17e051f662a15454	600667
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, registered_at, last_seen, api_key) FROM stdin;
eb4370b2-58c6-4e25-90d9-36ec4c9411f8	bb566863-0043-45c1-90ac-e66840531b12	76481c16-2b20-4b11-b83a-06725be2459f	"172.25.0.4"	60073	2025-10-31 15:07:46.984776+00	2025-10-31 15:07:46.984775+00	062d7977d962429998672ca773c11167
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
4fc52405-215c-423f-80ef-484fff2c691d	bb566863-0043-45c1-90ac-e66840531b12	Cloudflare DNS	\N	Cloudflare DNS	{"type": "ServiceBinding", "config": "04d54c0e-7c1a-4df6-afcc-7bcdda6eddb4"}	[{"id": "11b5a77b-60fb-4d48-bedf-3dc356daa740", "name": "Internet", "subnet_id": "c2d74814-aed2-44f1-a622-b0beda26925a", "ip_address": "1.1.1.1", "mac_address": null}]	["8d23aa53-3c63-4ed1-b5c7-3cf264a5898f"]	[{"id": "f201702a-9429-401c-a311-642826b4e968", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-10-31 15:07:46.925496+00	2025-10-31 15:07:46.935719+00	f
c2e9b63a-30ce-48e0-a22d-695b3fa9955d	bb566863-0043-45c1-90ac-e66840531b12	Google.com	google.com	Google.com	{"type": "ServiceBinding", "config": "7b62b2d8-2a33-4fc2-b185-be9da899cb7e"}	[{"id": "bb207873-57c3-4869-8099-b58b6cf32001", "name": "Internet", "subnet_id": "c2d74814-aed2-44f1-a622-b0beda26925a", "ip_address": "203.0.113.39", "mac_address": null}]	["ed3d993b-8068-4d14-907f-30fab9b0fb14"]	[{"id": "f748af71-b5ea-4cac-b219-d9eb2503caa7", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-31 15:07:46.925501+00	2025-10-31 15:07:46.942294+00	f
2d775da7-61d1-427b-85a2-4757f8b36b1e	bb566863-0043-45c1-90ac-e66840531b12	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "7ae8ad87-e734-4974-8e9c-854062f5958b"}	[{"id": "d00cc55b-6375-4f61-8e78-db03d6cbc0ef", "name": "Remote Network", "subnet_id": "a7f5ad6a-9ff6-4e1c-bb19-5e8014f619fb", "ip_address": "203.0.113.97", "mac_address": null}]	["f614de7b-d37d-468a-aff8-a65fc42c5d15"]	[{"id": "3b704a95-5087-4889-bf6d-95b9c2e7ea02", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-31 15:07:46.925503+00	2025-10-31 15:07:46.944758+00	f
76481c16-2b20-4b11-b83a-06725be2459f	bb566863-0043-45c1-90ac-e66840531b12	172.25.0.4	\N	\N	{"type": "None"}	[]	[]	[]	{"type": "Unknown"}	null	2025-10-31 15:07:46.982396+00	2025-10-31 15:07:46.984251+00	f
97eb8c70-d647-4edf-8107-5ab8966b876f	bb566863-0043-45c1-90ac-e66840531b12	NetVisor Daemon API	62f263c51cc8	\N	{"type": "Hostname"}	[{"id": "d63b5a1f-8ace-4aba-85cb-debf6192cd95", "name": null, "subnet_id": "7933abaa-6463-4e61-bdcf-8563b579669a", "ip_address": "172.25.0.4", "mac_address": null}]	["ead9bf18-fa06-419f-9133-7c4ed448417b"]	[{"id": "9d093c47-b579-44b5-9efe-2732d453a65c", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-31T15:07:54.427721969Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}	null	2025-10-31 15:07:54.427729+00	2025-10-31 15:07:54.444012+00	f
8f3aca81-7d80-41ce-8919-fd72ceefed42	bb566863-0043-45c1-90ac-e66840531b12	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "fe1cc8dc-bf58-49bc-b9e1-5be151f47de2", "name": null, "subnet_id": "7933abaa-6463-4e61-bdcf-8563b579669a", "ip_address": "172.25.0.3", "mac_address": "9A:0F:7F:A5:51:EA"}]	["5951b548-db2c-4749-ae38-2542965ac104"]	[{"id": "63aa80c5-4d2d-45d6-9fc5-8ae74257413c", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-31T15:07:54.430898427Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}	null	2025-10-31 15:07:54.430901+00	2025-10-31 15:08:03.899228+00	f
673556a5-4610-44e2-ba56-140e7baf7b93	bb566863-0043-45c1-90ac-e66840531b12	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "ce9e3fa4-52a0-4902-8d36-c6d30262ff1b", "name": null, "subnet_id": "7933abaa-6463-4e61-bdcf-8563b579669a", "ip_address": "172.25.0.5", "mac_address": "96:A1:7E:1B:B7:75"}]	["34e8b19b-9558-4c76-853f-fa6f38f62632"]	[{"id": "e3121d57-6e0f-4355-9cb5-a2f2c1efa9cc", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-31T15:08:03.834541084Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}	null	2025-10-31 15:08:03.834546+00	2025-10-31 15:08:21.99888+00	f
7f6a36f3-4f71-49de-9c34-e38167676354	bb566863-0043-45c1-90ac-e66840531b12	Home Assistant	\N	\N	{"type": "None"}	[{"id": "51bfa9aa-949b-4e39-87c7-dc501eeaf69a", "name": null, "subnet_id": "7933abaa-6463-4e61-bdcf-8563b579669a", "ip_address": "172.25.0.1", "mac_address": "16:0B:E0:06:9E:DE"}]	["3a88eef9-f5b7-4900-bc9a-3e0e88aa9235", "4518b44a-d12c-4880-a324-d345513d9efa"]	[{"id": "b7e2d7a7-0744-4754-b758-75e2cc2eaf43", "type": "Custom", "number": 8123, "protocol": "Tcp"}, {"id": "c8dc9dbe-e6d4-41b1-aee1-0f54b9eca6fe", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-31T15:08:13.023940838Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}	null	2025-10-31 15:08:13.023946+00	2025-10-31 15:08:22.027172+00	f
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
bb566863-0043-45c1-90ac-e66840531b12	My Network	2025-10-31 15:07:46.922474+00	2025-10-31 15:07:46.922476+00	t	9619ecfb-b3ce-46cb-9c40-c789b2bcb692
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
8d23aa53-3c63-4ed1-b5c7-3cf264a5898f	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.925497+00	2025-10-31 15:07:46.935209+00	Cloudflare DNS	4fc52405-215c-423f-80ef-484fff2c691d	[{"id": "04d54c0e-7c1a-4df6-afcc-7bcdda6eddb4", "type": "Port", "port_id": "f201702a-9429-401c-a311-642826b4e968", "interface_id": "11b5a77b-60fb-4d48-bedf-3dc356daa740"}]	"Dns Server"	null	{"type": "System"}
ed3d993b-8068-4d14-907f-30fab9b0fb14	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.925501+00	2025-10-31 15:07:46.941999+00	Google.com	c2e9b63a-30ce-48e0-a22d-695b3fa9955d	[{"id": "7b62b2d8-2a33-4fc2-b185-be9da899cb7e", "type": "Port", "port_id": "f748af71-b5ea-4cac-b219-d9eb2503caa7", "interface_id": "bb207873-57c3-4869-8099-b58b6cf32001"}]	"Web Service"	null	{"type": "System"}
f614de7b-d37d-468a-aff8-a65fc42c5d15	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.925504+00	2025-10-31 15:07:46.944427+00	Mobile Device	2d775da7-61d1-427b-85a2-4757f8b36b1e	[{"id": "7ae8ad87-e734-4974-8e9c-854062f5958b", "type": "Port", "port_id": "3b704a95-5087-4889-bf6d-95b9c2e7ea02", "interface_id": "d00cc55b-6375-4f61-8e78-db03d6cbc0ef"}]	"Client"	null	{"type": "System"}
ead9bf18-fa06-419f-9133-7c4ed448417b	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:54.428374+00	2025-10-31 15:07:54.442759+00	NetVisor Daemon API	97eb8c70-d647-4edf-8107-5ab8966b876f	[{"id": "8017c992-5f12-4a9e-ab64-1751eded56ae", "type": "Port", "port_id": "9d093c47-b579-44b5-9efe-2732d453a65c", "interface_id": "d63b5a1f-8ace-4aba-85cb-debf6192cd95"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-31T15:07:54.428359552Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}
5951b548-db2c-4749-ae38-2542965ac104	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:55.483525+00	2025-10-31 15:08:03.898843+00	NetVisor Server API	8f3aca81-7d80-41ce-8919-fd72ceefed42	[{"id": "290a803b-2e7d-49d9-b410-00cacfcbda03", "type": "Port", "port_id": "63aa80c5-4d2d-45d6-9fc5-8ae74257413c", "interface_id": "fe1cc8dc-bf58-49bc-b9e1-5be151f47de2"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-31T15:07:55.483517761Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}
34e8b19b-9558-4c76-853f-fa6f38f62632	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:08:04.844128+00	2025-10-31 15:08:21.99834+00	Home Assistant	673556a5-4610-44e2-ba56-140e7baf7b93	[{"id": "441403a3-8069-4512-9990-f8684f3ac66b", "type": "Port", "port_id": "e3121d57-6e0f-4355-9cb5-a2f2c1efa9cc", "interface_id": "ce9e3fa4-52a0-4902-8d36-c6d30262ff1b"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-31T15:08:04.844120543Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}
4518b44a-d12c-4880-a324-d345513d9efa	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:08:13.930718+00	2025-10-31 15:08:21.998511+00	NetVisor Server API	7f6a36f3-4f71-49de-9c34-e38167676354	[{"id": "307f7ffe-ba0d-4fd9-91ef-34c4030376c2", "type": "Port", "port_id": "c8dc9dbe-e6d4-41b1-aee1-0f54b9eca6fe", "interface_id": "51bfa9aa-949b-4e39-87c7-dc501eeaf69a"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-31T15:08:13.930717047Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}
3a88eef9-f5b7-4900-bc9a-3e0e88aa9235	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:08:13.930676+00	2025-10-31 15:08:22.026612+00	Home Assistant	7f6a36f3-4f71-49de-9c34-e38167676354	[{"id": "62dc3e66-e291-4c63-afbf-247efe97ec6e", "type": "Port", "port_id": "b7e2d7a7-0744-4754-b758-75e2cc2eaf43", "interface_id": "51bfa9aa-949b-4e39-87c7-dc501eeaf69a"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-31T15:08:13.930660131Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "Network"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
c2d74814-aed2-44f1-a622-b0beda26925a	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.925448+00	2025-10-31 15:07:46.925448+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
a7f5ad6a-9ff6-4e1c-bb19-5e8014f619fb	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.925449+00	2025-10-31 15:07:46.925449+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
7933abaa-6463-4e61-bdcf-8563b579669a	bb566863-0043-45c1-90ac-e66840531b12	2025-10-31 15:07:46.998904+00	2025-10-31 15:07:46.998904+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-10-31T15:07:46.998895757Z", "daemon_id": "eb4370b2-58c6-4e25-90d9-36ec4c9411f8", "discovery_type": "SelfReport"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
9619ecfb-b3ce-46cb-9c40-c789b2bcb692	testuser	2025-10-31 15:07:46.921033+00	2025-10-31 15:07:50.371803+00	$argon2id$v=19$m=19456,t=2,p=1$eoyOH7MfdyKHl9x5hTY1Vw$b6/QwW4kFP2OyhWebFp1ph2ywAHApx9jKvgSzwJ3Hvk	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
r8mQ213bAZv8X8LXNycdFQ	\\x93c410151d2737d7c25ffc9b01db5ddb90c9af81a7757365725f6964d92439363139656366622d623363652d343663622d396334302d63373839623262636236393299cd07e9cd014e0f0732ce16424d7f000000	2025-11-30 15:07:50.373443+00
\.


--
-- Name: _sqlx_migrations _sqlx_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._sqlx_migrations
    ADD CONSTRAINT _sqlx_migrations_pkey PRIMARY KEY (version);


--
-- Name: daemons daemons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_pkey PRIMARY KEY (id);


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
-- Name: idx_daemon_host_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemon_host_id ON public.daemons USING btree (host_id);


--
-- Name: idx_daemons_api_key_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_api_key_hash ON public.daemons USING btree (api_key);


--
-- Name: idx_daemons_network; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_daemons_network ON public.daemons USING btree (network_id);


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
-- Name: idx_users_name_lower; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_users_name_lower ON public.users USING btree (lower(name));


--
-- Name: daemons daemons_network_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.daemons
    ADD CONSTRAINT daemons_network_id_fkey FOREIGN KEY (network_id) REFERENCES public.networks(id) ON DELETE CASCADE;


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

\unrestrict hYYQiX8qX4HPILHratXKxhEijfsECSKnV1NIBT8Pi8ODwmWMyILhqXdVh3yiTpZ

