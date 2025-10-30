--
-- PostgreSQL database dump
--

\restrict MqFaxkqdg9uPkUYmGnjQucviwMNv5bNbUCdh2NcXIxTnNrhlm8hmh2RMkyQRR17

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
    api_key_hash text DEFAULT ''::text NOT NULL
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
    updated_at timestamp with time zone NOT NULL
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
20251006215000	users	2025-10-30 06:09:38.639383+00	t	\\x4f13ce14ff67ef0b7145987c7b22b588745bf9fbb7b673450c26a0f2f9a36ef8ca980e456c8d77cfb1b2d7a4577a64d7	2586000
20251006215100	networks	2025-10-30 06:09:38.642946+00	t	\\xeaa5a07a262709f64f0c59f31e25519580c79e2d1a523ce72736848946a34b17dd9adc7498eaf90551af6b7ec6d4e0e3	2733417
20251006215151	create hosts	2025-10-30 06:09:38.64594+00	t	\\x6ec7487074c0724932d21df4cf1ed66645313cf62c159a7179e39cbc261bcb81a24f7933a0e3cf58504f2a90fc5c1962	1757292
20251006215155	create subnets	2025-10-30 06:09:38.647938+00	t	\\xefb5b25742bd5f4489b67351d9f2494a95f307428c911fd8c5f475bfb03926347bdc269bbd048d2ddb06336945b27926	1920334
20251006215201	create groups	2025-10-30 06:09:38.650045+00	t	\\x0a7032bf4d33a0baf020e905da865cde240e2a09dda2f62aa535b2c5d4b26b20be30a3286f1b5192bd94cd4a5dbb5bcd	1543167
20251006215204	create daemons	2025-10-30 06:09:38.651772+00	t	\\xcfea93403b1f9cf9aac374711d4ac72d8a223e3c38a1d2a06d9edb5f94e8a557debac3668271f8176368eadc5105349f	2134917
20251006215212	create services	2025-10-30 06:09:38.654103+00	t	\\xd5b07f82fc7c9da2782a364d46078d7d16b5c08df70cfbf02edcfe9b1b24ab6024ad159292aeea455f15cfd1f4740c1d	2068125
20251029193448	user-auth	2025-10-30 06:09:38.656355+00	t	\\x9d375e2fbdfa10849163d855a8958e8437ad30cf8322f3339491d0c06cd851cf6a60aa2064e432a220c288313204e987	7350417
20251030044828	daemon api	2025-10-30 06:09:38.663874+00	t	\\x4d39889d0d5f779f2cc3eff2ce7dca957444462e8e7c3cbb9a55013805c3d464a73ed2123e57a445e2eaadeabe6b8c13	721875
\.


--
-- Data for Name: daemons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.daemons (id, network_id, host_id, ip, port, registered_at, last_seen, api_key_hash) FROM stdin;
07e4bf70-e2f6-42d6-bfe0-d685566aa7ff	575d1a42-b5ce-402c-aafa-c4a193f699ae	7857a6ac-1ede-4f8b-9a58-454cb3b50e38	"172.25.0.4"	60073	2025-10-30 06:09:38.742589+00	2025-10-30 06:09:38.742587+00	44a8ab82021ae58c21807ee8fe2ed90f11074963e0c99be4d3a7e47788e3a65e
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, network_id, name, description, group_type, created_at, updated_at, source, color) FROM stdin;
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hosts (id, network_id, name, hostname, description, target, interfaces, services, ports, source, virtualization, created_at, updated_at) FROM stdin;
134808a3-5eac-47c5-a330-8596e6339b57	575d1a42-b5ce-402c-aafa-c4a193f699ae	Cloudflare DNS	\N	Cloudflare DNS	{"type": "ServiceBinding", "config": "1b782892-a3a1-45c5-a9f2-d858d6e70e87"}	[{"id": "7b229cdf-7274-458f-b660-234b6709e19f", "name": "Internet", "subnet_id": "c467dc08-49c9-409a-8d43-4ba96f878654", "ip_address": "1.1.1.1", "mac_address": null}]	["f3cb95f6-5faa-474c-90ee-d4c30ef58774"]	[{"id": "5a1b2c4d-e3bd-45df-96a4-41f379ea24f6", "type": "DnsUdp", "number": 53, "protocol": "Udp"}]	{"type": "System"}	null	2025-10-30 06:09:38.704949+00	2025-10-30 06:09:38.712829+00
43f37265-8f68-4415-a191-7ff9adf339d7	575d1a42-b5ce-402c-aafa-c4a193f699ae	Google.com	google.com	Google.com	{"type": "ServiceBinding", "config": "7ebdd1fc-7aee-4a82-9a3c-3e21201cb76c"}	[{"id": "2aa04543-a3c3-4136-ab0a-30743dd28dff", "name": "Internet", "subnet_id": "c467dc08-49c9-409a-8d43-4ba96f878654", "ip_address": "203.0.113.183", "mac_address": null}]	["5a488a91-4e1e-4c77-9450-52a792892dde"]	[{"id": "c4df3ea4-dc45-4d33-9bd7-45509f0ecbb0", "type": "Https", "number": 443, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-30 06:09:38.704953+00	2025-10-30 06:09:38.71584+00
e83a5b38-0dc2-4301-9275-059c8255d80d	575d1a42-b5ce-402c-aafa-c4a193f699ae	Mobile Device	\N	A mobile device connecting from a remote network	{"type": "ServiceBinding", "config": "d7e78734-924e-48cd-b8ff-8aeeae3423e6"}	[{"id": "7bde9546-df05-40c5-bbd8-1f2782e4c98e", "name": "Remote Network", "subnet_id": "2ad3322c-a3ba-42be-b81b-4eed44f711bc", "ip_address": "203.0.113.39", "mac_address": null}]	["89f84273-ced0-4051-99bf-5f343786b0f1"]	[{"id": "a4f2b0f2-4ba9-49ad-9200-16b0205785ba", "type": "Custom", "number": 0, "protocol": "Tcp"}]	{"type": "System"}	null	2025-10-30 06:09:38.704956+00	2025-10-30 06:09:38.718364+00
7857a6ac-1ede-4f8b-9a58-454cb3b50e38	575d1a42-b5ce-402c-aafa-c4a193f699ae	172.25.0.4	\N	\N	{"type": "None"}	[]	[]	[]	{"type": "Unknown"}	null	2025-10-30 06:09:38.737055+00	2025-10-30 06:09:38.739806+00
4987e3bc-fc6f-40ec-bcfc-379dcd3a827f	575d1a42-b5ce-402c-aafa-c4a193f699ae	NetVisor Daemon API	34c99587731b	\N	{"type": "Hostname"}	[{"id": "2bd5b8bf-119a-49fb-8fee-a2e1db5a9be1", "name": null, "subnet_id": "bb417ee0-465f-41b8-9ba4-2a30b4cfd6d6", "ip_address": "172.25.0.4", "mac_address": null}]	["59e7d383-29bf-4e66-b963-da6f99a57aa4"]	[{"id": "d989a541-6e3f-4f27-b6f4-678bc7350815", "type": "Custom", "number": 60073, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T06:09:46.612174793Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}	null	2025-10-30 06:09:46.612183+00	2025-10-30 06:09:46.629245+00
a86bba69-ed1c-4180-9f38-584c210f3fdb	575d1a42-b5ce-402c-aafa-c4a193f699ae	NetVisor Server API	netvisor-server-1.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "c1f24b2b-ea12-45ce-ab4a-a96418017a91", "name": null, "subnet_id": "bb417ee0-465f-41b8-9ba4-2a30b4cfd6d6", "ip_address": "172.25.0.3", "mac_address": "12:28:EA:FC:87:7F"}]	["c4d88a2d-a84e-41d5-8a2f-d4f7d57c65a7"]	[{"id": "53e6efc6-7aad-4c6b-92df-e8470379452b", "type": "Custom", "number": 60072, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T06:09:46.614664210Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}	null	2025-10-30 06:09:46.614666+00	2025-10-30 06:09:55.880667+00
ac30ae5a-7cb2-4df2-a1a5-d2f0ad54538f	575d1a42-b5ce-402c-aafa-c4a193f699ae	Home Assistant	\N	\N	{"type": "None"}	[{"id": "9036bf15-605b-4995-ab83-69d4b18191f5", "name": null, "subnet_id": "bb417ee0-465f-41b8-9ba4-2a30b4cfd6d6", "ip_address": "172.25.0.1", "mac_address": "1A:AA:0E:6D:66:92"}]	["423a6d1a-5cdb-4a64-88a7-696658010029", "215bde22-696f-4dc5-84b3-bf0f684be1f5"]	[{"id": "c01c0be3-9aa4-473e-9b14-1e35bac09e98", "type": "Custom", "number": 60072, "protocol": "Tcp"}, {"id": "243cdf8b-bde6-4a01-8ee9-1b91907b3c3f", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T06:10:04.842785552Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}	null	2025-10-30 06:10:04.842787+00	2025-10-30 06:10:13.966234+00
d687028d-640d-42c4-b228-5b743724614e	575d1a42-b5ce-402c-aafa-c4a193f699ae	Home Assistant	homeassistant-discovery.netvisor_netvisor-dev	\N	{"type": "Hostname"}	[{"id": "4f7baec4-8cb4-4545-834a-184c7af14ee3", "name": null, "subnet_id": "bb417ee0-465f-41b8-9ba4-2a30b4cfd6d6", "ip_address": "172.25.0.5", "mac_address": "22:97:AD:CA:93:27"}]	["bee0a838-9132-4aba-b3ef-856b461c43a5"]	[{"id": "38b38c9c-0371-4ea4-bba9-6c981f61903b", "type": "Custom", "number": 8123, "protocol": "Tcp"}]	{"type": "Discovery", "metadata": [{"date": "2025-10-30T06:09:55.791335547Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}	null	2025-10-30 06:09:55.791338+00	2025-10-30 06:10:13.917169+00
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.networks (id, name, created_at, updated_at, is_default, user_id) FROM stdin;
575d1a42-b5ce-402c-aafa-c4a193f699ae	My Network	2025-10-30 06:09:38.703692+00	2025-10-30 06:09:38.703693+00	t	ac6f4474-5d53-4546-80a7-d21e818e0973
\.


--
-- Data for Name: services; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.services (id, network_id, created_at, updated_at, name, host_id, bindings, service_definition, virtualization, source) FROM stdin;
f3cb95f6-5faa-474c-90ee-d4c30ef58774	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.704951+00	2025-10-30 06:09:38.712241+00	Cloudflare DNS	134808a3-5eac-47c5-a330-8596e6339b57	[{"id": "1b782892-a3a1-45c5-a9f2-d858d6e70e87", "type": "Port", "port_id": "5a1b2c4d-e3bd-45df-96a4-41f379ea24f6", "interface_id": "7b229cdf-7274-458f-b660-234b6709e19f"}]	"Dns Server"	null	{"type": "System"}
5a488a91-4e1e-4c77-9450-52a792892dde	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.704954+00	2025-10-30 06:09:38.715459+00	Google.com	43f37265-8f68-4415-a191-7ff9adf339d7	[{"id": "7ebdd1fc-7aee-4a82-9a3c-3e21201cb76c", "type": "Port", "port_id": "c4df3ea4-dc45-4d33-9bd7-45509f0ecbb0", "interface_id": "2aa04543-a3c3-4136-ab0a-30743dd28dff"}]	"Web Service"	null	{"type": "System"}
89f84273-ced0-4051-99bf-5f343786b0f1	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.704956+00	2025-10-30 06:09:38.71802+00	Mobile Device	e83a5b38-0dc2-4301-9275-059c8255d80d	[{"id": "d7e78734-924e-48cd-b8ff-8aeeae3423e6", "type": "Port", "port_id": "a4f2b0f2-4ba9-49ad-9200-16b0205785ba", "interface_id": "7bde9546-df05-40c5-bbd8-1f2782e4c98e"}]	"Client"	null	{"type": "System"}
59e7d383-29bf-4e66-b963-da6f99a57aa4	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:46.612826+00	2025-10-30 06:09:46.627847+00	NetVisor Daemon API	4987e3bc-fc6f-40ec-bcfc-379dcd3a827f	[{"id": "e9f6e373-b84c-4009-9800-a3ac64fafa53", "type": "Port", "port_id": "d989a541-6e3f-4f27-b6f4-678bc7350815", "interface_id": "2bd5b8bf-119a-49fb-8fee-a2e1db5a9be1"}]	"NetVisor Daemon API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.4:60073/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T06:09:46.612814835Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}
c4d88a2d-a84e-41d5-8a2f-d4f7d57c65a7	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:53.567562+00	2025-10-30 06:09:55.880247+00	NetVisor Server API	a86bba69-ed1c-4180-9f38-584c210f3fdb	[{"id": "dbce147a-6956-4f86-a5b4-fecab5a7e9a2", "type": "Port", "port_id": "53e6efc6-7aad-4c6b-92df-e8470379452b", "interface_id": "c1f24b2b-ea12-45ce-ab4a-a96418017a91"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.3:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T06:09:53.567550630Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}
bee0a838-9132-4aba-b3ef-856b461c43a5	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:10:03.059629+00	2025-10-30 06:10:13.912773+00	Home Assistant	d687028d-640d-42c4-b228-5b743724614e	[{"id": "af73dae1-0360-4ae4-8621-ac82eac4b381", "type": "Port", "port_id": "38b38c9c-0371-4ea4-bba9-6c981f61903b", "interface_id": "4f7baec4-8cb4-4545-834a-184c7af14ee3"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.5:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T06:10:03.059610134Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}
215bde22-696f-4dc5-84b3-bf0f684be1f5	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:10:11.568269+00	2025-10-30 06:10:13.914353+00	NetVisor Server API	ac30ae5a-7cb2-4df2-a1a5-d2f0ad54538f	[{"id": "54fa7d2e-7bf9-40bc-b03b-c3241dfdf6f7", "type": "Port", "port_id": "c01c0be3-9aa4-473e-9b14-1e35bac09e98", "interface_id": "9036bf15-605b-4995-ab83-69d4b18191f5"}]	"NetVisor Server API"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:60072/api/health contained \\"netvisor\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T06:10:11.568261888Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}
423a6d1a-5cdb-4a64-88a7-696658010029	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:10:12.017098+00	2025-10-30 06:10:13.965128+00	Home Assistant	ac30ae5a-7cb2-4df2-a1a5-d2f0ad54538f	[{"id": "81a4e2dc-e190-4619-85c4-25d22d0f7506", "type": "Port", "port_id": "243cdf8b-bde6-4a01-8ee9-1b91907b3c3f", "interface_id": "9036bf15-605b-4995-ab83-69d4b18191f5"}]	"Home Assistant"	null	{"type": "DiscoveryWithMatch", "details": {"reason": {"data": "Response from http://172.25.0.1:8123/auth/authorize contained \\"home assistant\\"", "type": "reason"}, "confidence": "High"}, "metadata": [{"date": "2025-10-30T06:10:12.017091847Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "Network"}]}
\.


--
-- Data for Name: subnets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subnets (id, network_id, created_at, updated_at, cidr, name, description, subnet_type, source) FROM stdin;
c467dc08-49c9-409a-8d43-4ba96f878654	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.704886+00	2025-10-30 06:09:38.704886+00	"0.0.0.0/0"	Internet	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for services running on the internet (e.g., public DNS servers, cloud services, etc.).	"Internet"	{"type": "System"}
2ad3322c-a3ba-42be-b81b-4eed44f711bc	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.704888+00	2025-10-30 06:09:38.704888+00	"0.0.0.0/0"	Remote Network	This subnet uses the 0.0.0.0/0 CIDR as an organizational container for hosts on remote networks (e.g., mobile connections, friend's networks, public WiFi, etc.).	"Remote"	{"type": "System"}
bb417ee0-465f-41b8-9ba4-2a30b4cfd6d6	575d1a42-b5ce-402c-aafa-c4a193f699ae	2025-10-30 06:09:38.74824+00	2025-10-30 06:09:38.74824+00	"172.25.0.0/28"	172.25.0.0/28	\N	"Lan"	{"type": "Discovery", "metadata": [{"date": "2025-10-30T06:09:38.748233512Z", "daemon_id": "07e4bf70-e2f6-42d6-bfe0-d685566aa7ff", "discovery_type": "SelfReport"}]}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, created_at, updated_at, password_hash, username) FROM stdin;
ac6f4474-5d53-4546-80a7-d21e818e0973	testuser	2025-10-30 06:09:38.703039+00	2025-10-30 06:09:42.55747+00	$argon2id$v=19$m=19456,t=2,p=1$tf2n0OhE1utnCBoGLP+3Hg$lv5SxyZv/Gc5TTv2yEw06sLgUiK3lJnsvYaNc2eLHm4	testuser
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: tower_sessions; Owner: postgres
--

COPY tower_sessions.session (id, data, expiry_date) FROM stdin;
QKRANnBIAW6mfy9-IxZWWQ	\\x93c410595616237e2f7fa66e0148703640a44081a7757365725f6964d92461633666343437342d356435332d343534362d383061372d64323165383138653039373399cd07e9cd014d06092ace21526f8f000000	2025-11-29 06:09:42.55905+00
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

CREATE INDEX idx_daemons_api_key_hash ON public.daemons USING btree (api_key_hash);


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

\unrestrict MqFaxkqdg9uPkUYmGnjQucviwMNv5bNbUCdh2NcXIxTnNrhlm8hmh2RMkyQRR17

