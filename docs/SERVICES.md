# NetVisor Service Definitions

This document lists all services that NetVisor can automatically discover and identify.

## AdBlock

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/adguard-home.svg" alt="Adguard Home" width="32" height="32" /></td>
<td>Adguard Home</td>
<td>Network-wide ad and tracker blocking</td>
<td><code>All of: (All of: (53/udp is open, 53/tcp is open), Endpoint response body from <ip>:80/ contains AdGuard Home)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg" alt="Pi-Hole" width="32" height="32" /></td>
<td>Pi-Hole</td>
<td>Network-wide ad blocking DNS service</td>
<td><code>All of: (Any of: (53/udp is open, 53/tcp is open), Endpoint response body from <ip>:80/admin contains pi-hole)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pfsense.svg" alt="pfBlockerNG" width="32" height="32" /></td>
<td>pfBlockerNG</td>
<td>PfSense package for DNS/IP blocking</td>
<td><code>All of: (All of: (53/tcp is open, 53/udp is open), Endpoint response body from <ip>:80/pfblockerng contains pfblockerng)</code></td>
</tr>
</tbody>
</table>

## Backup

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/backrest-light.svg" alt="BackRest" width="32" height="32" /></td>
<td>BackRest</td>
<td>Web UI and orchestrator for Restic</td>
<td><code>Endpoint response body from <ip>:9898/ contains BackRest</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/bacula.png" alt="Bacula" width="32" height="32" /></td>
<td>Bacula</td>
<td>Network backup solution</td>
<td><code>9101/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/duplicati.svg" alt="Duplicati" width="32" height="32" /></td>
<td>Duplicati</td>
<td>Cross-platform backup client with encryption</td>
<td><code>Endpoint response body from <ip>:8200/ngax/index.html contains Duplicati</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox Backup Server" width="32" height="32" /></td>
<td>Proxmox Backup Server</td>
<td>Encrypted, incremental and deduplicated backups for Proxmox VMs, LXCs, and hosts</td>
<td><code>Any of: (Endpoint response body from <ip>:8007/ contains proxmox-backup-gui, 8007/tcp is open)</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Restic</td>
<td>Fast and secure backup program</td>
<td><code>All of: (8000/tcp is open, Endpoint response body from <ip>:80/ contains restic)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/syncthing.svg" alt="Syncthing" width="32" height="32" /></td>
<td>Syncthing</td>
<td>Continuous file synchronization service</td>
<td><code>All of: (Endpoint response body from <ip>:80/ contains Syncthing, 22000/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/veeam.svg" alt="Veeam" width="32" height="32" /></td>
<td>Veeam</td>
<td>Backup and replication</td>
<td><code>9392/tcp is open</code></td>
</tr>
</tbody>
</table>

## Collaboration

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/confluence.svg" alt="Confluence" width="32" height="32" /></td>
<td>Confluence</td>
<td>Team collaboration wiki</td>
<td><code>Endpoint response body from <ip>:8090/ contains confluence</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Jira</td>
<td>Project management platform</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:8080/rest/api/2/serverInfo contains jira</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mattermost.svg" alt="Mattermost" width="32" height="32" /></td>
<td>Mattermost</td>
<td>Team messaging platform</td>
<td><code>Endpoint response body from <ip>:8065/api/v4/system/ping contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radicale.svg" alt="Radicale" width="32" height="32" /></td>
<td>Radicale</td>
<td>Free and Open-Source CalDAV and CardDAV Server</td>
<td><code>Endpoint response body from <ip>:5232/.web/ contains Radicale Web Interface</code></td>
</tr>
</tbody>
</table>

## Communication

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/asterisk.png" alt="Asterisk" width="32" height="32" /></td>
<td>Asterisk</td>
<td>PBX and VoIP server</td>
<td><code>Endpoint response body from <ip>:8088/httpstatus contains asterisk</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freepbx.svg" alt="FreePBX" width="32" height="32" /></td>
<td>FreePBX</td>
<td>PBX web interface</td>
<td><code>All of: (Endpoint response body from <ip>:80/ contains freepbx, 5060/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jitsi-meet.svg" alt="Jitsi Meet" width="32" height="32" /></td>
<td>Jitsi Meet</td>
<td>Video conferencing</td>
<td><code>Endpoint response body from <ip>:8443/ contains jitsilogo.png</code></td>
</tr>
</tbody>
</table>

## DNS

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">—</td>
<td>Bind9</td>
<td>Berkeley Internet Name Domain DNS server</td>
<td><code>All of: (53/udp is open, 8053/tcp is open)</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Dns Server</td>
<td>A generic Dns server</td>
<td><code>Any of: (53/tcp is open, 53/udp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/powerdns.svg" alt="PowerDNS" width="32" height="32" /></td>
<td>PowerDNS</td>
<td>Authoritative DNS server with API</td>
<td><code>All of: (53/udp is open, 53/tcp is open, 8081/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unbound.svg" alt="Unbound DNS" width="32" height="32" /></td>
<td>Unbound DNS</td>
<td>Recursive DNS resolver with control interface</td>
<td><code>All of: (53/udp is open, 8953/tcp is open)</code></td>
</tr>
</tbody>
</table>

## Dashboard

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glance.svg" alt="Glance" width="32" height="32" /></td>
<td>Glance</td>
<td>A self-hosted dashboard that puts all your feeds in one place</td>
<td><code>Endpoint response body from <ip>:8080/manifest.json contains Glance</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/homarr.svg" alt="Homarr" width="32" height="32" /></td>
<td>Homarr</td>
<td>A sleek, modern dashboard</td>
<td><code>7575/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/webp/homepage.webp" alt="Homepage" width="32" height="32" /></td>
<td>Homepage</td>
<td>A self-hosted dashboard for your homelab</td>
<td><code>Endpoint response body from <ip>:3000/site.webmanifest contains Homepage</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Jump</td>
<td>A self-hosted startpage and real-time status page</td>
<td><code>Endpoint response body from <ip>:8123/ contains Jump</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/linkstack.svg" alt="LinkStack" width="32" height="32" /></td>
<td>LinkStack</td>
<td>A highly customizable link sharing platform</td>
<td><code>All of: (Endpoint response from <ip> has header set-cookie with value linkstack_session, Endpoint response body from <ip>:8080/ contains LinkStack)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox Datacenter Manager" width="32" height="32" /></td>
<td>Proxmox Datacenter Manager</td>
<td>A single pane of glass for managing clustered & non-clustered Proxmox nodes</td>
<td><code>Endpoint response body from <ip>:8443/ contains pdm-ui_bundle.js</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wireguard.svg" alt="WGDashboard" width="32" height="32" /></td>
<td>WGDashboard</td>
<td>Wireguard dashboard for visualizing and managing wireguard clients and server</td>
<td><code>All of: (10086/tcp is open, Not (Subnet is type VpnTunnel))</code></td>
</tr>
</tbody>
</table>

## Database

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apache-cassandra.svg" alt="Cassandra" width="32" height="32" /></td>
<td>Cassandra</td>
<td>Distributed NoSQL database</td>
<td><code>9042/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/couchdb.svg" alt="CouchDB" width="32" height="32" /></td>
<td>CouchDB</td>
<td>NoSQL document database</td>
<td><code>Endpoint response body from <ip>:5984/ contains couchdb</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/influxdb.svg" alt="InfluxDB" width="32" height="32" /></td>
<td>InfluxDB</td>
<td>Time series database</td>
<td><code>8086/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mariadb.svg" alt="MariaDB" width="32" height="32" /></td>
<td>MariaDB</td>
<td>MySQL-compatible relational database</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft-sql-server-light.svg" alt="Microsoft SQL Server" width="32" height="32" /></td>
<td>Microsoft SQL Server</td>
<td>Microsoft relational database</td>
<td><code>1433/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mongodb.svg" alt="MongoDB" width="32" height="32" /></td>
<td>MongoDB</td>
<td>NoSQL document database</td>
<td><code>27017/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mysql.svg" alt="MySQL" width="32" height="32" /></td>
<td>MySQL</td>
<td>Open-source relational database</td>
<td><code>3306/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/oracle.svg" alt="Oracle Database" width="32" height="32" /></td>
<td>Oracle Database</td>
<td>Enterprise relational database</td>
<td><code>1521/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/postgresql.svg" alt="PostgreSQL" width="32" height="32" /></td>
<td>PostgreSQL</td>
<td>Open-source relational database</td>
<td><code>5432/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/redis.svg" alt="Redis" width="32" height="32" /></td>
<td>Redis</td>
<td>In-memory data store and cache</td>
<td><code>6379/tcp is open</code></td>
</tr>
</tbody>
</table>

## Development

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ansible.svg" alt="AWX" width="32" height="32" /></td>
<td>AWX</td>
<td>Ansible automation platform</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:80/api/v2/ contains awx</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/argo-cd.svg" alt="ArgoCD" width="32" height="32" /></td>
<td>ArgoCD</td>
<td>GitOps continuous delivery</td>
<td><code>Endpoint response body from <ip>:8080/api/version contains argocd</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/atlassian-bamboo.svg" alt="Bamboo" width="32" height="32" /></td>
<td>Bamboo</td>
<td>CI/CD server</td>
<td><code>Endpoint response body from <ip>:8085/ contains bamboo</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitbucket.svg" alt="Bitbucket Server" width="32" height="32" /></td>
<td>Bitbucket Server</td>
<td>Git repository management</td>
<td><code>Endpoint response body from <ip>:7990/ contains bitbucket</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/drone.png" alt="Drone" width="32" height="32" /></td>
<td>Drone</td>
<td>Container-native CI platform</td>
<td><code>All of: (Endpoint response body from <ip>:80/ contains drone, Endpoint response body from <ip>:80/api/user contains )</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/github.svg" alt="GitHub" width="32" height="32" /></td>
<td>GitHub</td>
<td>Self-hosted GitHub</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gitlab.svg" alt="GitLab" width="32" height="32" /></td>
<td>GitLab</td>
<td>DevOps platform</td>
<td><code>All of: (Endpoint response from <ip> has header content-security-policy with value gitlab, Endpoint response body from <ip>:80/ contains gitlab)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jenkins.svg" alt="Jenkins" width="32" height="32" /></td>
<td>Jenkins</td>
<td>Automation server for CI/CD</td>
<td><code>Endpoint response body from <ip>:8080/ contains jenkins.io</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ollama-dark.svg" alt="Ollama" width="32" height="32" /></td>
<td>Ollama</td>
<td>An easy way to get up and running with LLMs.</td>
<td><code>Endpoint response body from <ip>:11434/ contains Ollama is running</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/spinnaker.svg" alt="Spinnaker" width="32" height="32" /></td>
<td>Spinnaker</td>
<td>Multi-cloud CD platform</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/teamcity-light.svg" alt="TeamCity" width="32" height="32" /></td>
<td>TeamCity</td>
<td>CI/CD server</td>
<td><code>Endpoint response body from <ip>:8111/ contains teamcity</code></td>
</tr>
</tbody>
</table>

## FileSharing

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/owncloud.svg" alt="ownCloud" width="32" height="32" /></td>
<td>ownCloud</td>
<td>File sync and share</td>
<td><code>Endpoint response body from <ip>:80/status.php contains owncloud</code></td>
</tr>
</tbody>
</table>

## HomeAutomation

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/domoticz.png" alt="Domoticz" width="32" height="32" /></td>
<td>Domoticz</td>
<td>Home automation system</td>
<td><code>Endpoint response body from <ip>:8080/json.htm contains domoticz</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/esphome.svg" alt="ESPHome" width="32" height="32" /></td>
<td>ESPHome</td>
<td>ESP device management</td>
<td><code>6052/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grocy.svg" alt="Grocy" width="32" height="32" /></td>
<td>Grocy</td>
<td>Web-based self-hosted groceries & household management solution</td>
<td><code>Any of: (Endpoint response body from <ip>:80/ contains grocy.css, Endpoint response body from <ip>:443/ contains grocy.css)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg" alt="Home Assistant" width="32" height="32" /></td>
<td>Home Assistant</td>
<td>Open-source home automation platform</td>
<td><code>Endpoint response body from <ip>:8123/ contains home assistant</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/lubelogger.png" alt="Lubelogger" width="32" height="32" /></td>
<td>Lubelogger</td>
<td>Vehicle Maintenance Records and Fuel Mileage Tracker</td>
<td><code>Endpoint response body from <ip>:8080/ contains Garage - LubeLogger</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mealie.svg" alt="Mealie" width="32" height="32" /></td>
<td>Mealie</td>
<td>A self-hosted recipe manager and meal planner</td>
<td><code>All of: (Endpoint response body from <ip>:9000/ contains Mealie, Endpoint response body from <ip>:9000/ contains recipe)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/z-wave-js-ui.svg" alt="Z-Wave JS" width="32" height="32" /></td>
<td>Z-Wave JS</td>
<td>Z-Wave controller server</td>
<td><code>Endpoint response body from <ip>:8091/health contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zigbee2mqtt.svg" alt="Zigbee2MQTT" width="32" height="32" /></td>
<td>Zigbee2MQTT</td>
<td>Zigbee to MQTT bridge</td>
<td><code>Endpoint response body from <ip>:8080/ contains Zigbee2MQTT WindFront</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openhab.svg" alt="openHAB" width="32" height="32" /></td>
<td>openHAB</td>
<td>Home automation platform</td>
<td><code>Endpoint response body from <ip>:8080/rest/ contains openhab</code></td>
</tr>
</tbody>
</table>

## IdentityAndAccess

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft.svg" alt="Active Directory" width="32" height="32" /></td>
<td>Active Directory</td>
<td>Microsoft directory service</td>
<td><code>All of: (389/tcp is open, 445/tcp is open, 88/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/authentik.svg" alt="Authentik" width="32" height="32" /></td>
<td>Authentik</td>
<td>A self-hosted, open source identity provider</td>
<td><code>Any of: (Endpoint response body from <ip>:9000/ contains window.authentik, Endpoint response body from <ip>:9443/ contains window.authentik)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitwarden.svg" alt="Bitwarden" width="32" height="32" /></td>
<td>Bitwarden</td>
<td>Password manager</td>
<td><code>Endpoint response body from <ip>:80/api/config contains bitwarden</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freeipa.svg" alt="FreeIPA" width="32" height="32" /></td>
<td>FreeIPA</td>
<td>Identity management system</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:80/ipa/ui contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/keycloak.svg" alt="Keycloak" width="32" height="32" /></td>
<td>Keycloak</td>
<td>Identity and access management</td>
<td><code>Endpoint response body from <ip>:8080/ contains /keycloak/</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openldap.svg" alt="Open LDAP" width="32" height="32" /></td>
<td>Open LDAP</td>
<td>Generic LDAP directory service</td>
<td><code>389/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pocket-id-light.svg" alt="Pocket ID" width="32" height="32" /></td>
<td>Pocket ID</td>
<td>A Simple OIDC provider that uses passkeys for authentication</td>
<td><code>Endpoint response body from <ip>:1411/app.webmanifest contains Pocket ID</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hashicorp-vault.svg" alt="Vault" width="32" height="32" /></td>
<td>Vault</td>
<td>Secrets management</td>
<td><code>Endpoint response body from <ip>:8200/v1/sys/health contains vault</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/vaultwarden.svg" alt="Vaultwarden" width="32" height="32" /></td>
<td>Vaultwarden</td>
<td>Self-hosted Bitwarden-compatible server, written in Rust</td>
<td><code>Endpoint response body from <ip>:8000/manifest.json contains Vaultwarden Web</code></td>
</tr>
</tbody>
</table>

## IoT

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/alexa.svg" alt="Amazon Echo" width="32" height="32" /></td>
<td>Amazon Echo</td>
<td>Amazon Echo smart speaker</td>
<td><code>All of: (MAC Address belongs to Amazon Technologies Inc., 40317/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/googlecast.svg" alt="Chromecast" width="32" height="32" /></td>
<td>Chromecast</td>
<td>Google Chromecast streaming device</td>
<td><code>All of: (MAC Address belongs to Google, Inc., 8008/tcp is open, 8009/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Home" width="32" height="32" /></td>
<td>Google Home</td>
<td>Google Home smart speaker or display</td>
<td><code>All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), All of: (8008/tcp is open, 8009/tcp is open))</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>IoT</td>
<td>A generic IoT Service</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Nest Protect" width="32" height="32" /></td>
<td>Nest Protect</td>
<td>Google Nest smoke and CO detector</td>
<td><code>All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), 11095/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Nest Thermostat" width="32" height="32" /></td>
<td>Nest Thermostat</td>
<td>Google Nest smart thermostat</td>
<td><code>All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), 9543/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/philipshue.svg" alt="Philips Hue Bridge" width="32" height="32" /></td>
<td>Philips Hue Bridge</td>
<td>Philips Hue Bridge for lighting control</td>
<td><code>All of: (MAC Address belongs to Philips Lighting BV, Endpoint response body from <ip>:80/ contains hue)</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>RTSP Camera</td>
<td>Camera with RTSP Streaming</td>
<td><code>554/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/ring.svg" alt="Ring Doorbell" width="32" height="32" /></td>
<td>Ring Doorbell</td>
<td>Ring video doorbell or security camera</td>
<td><code>All of: (MAC Address belongs to Amazon Technologies Inc., Any of: (8557/tcp is open, 9998/tcp is open, 19302/tcp is open, 9999/tcp is open))</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/roku.svg" alt="Roku Media Player" width="32" height="32" /></td>
<td>Roku Media Player</td>
<td>Roku streaming device or TV</td>
<td><code>All of: (MAC Address belongs to Roku, Inc, 8060/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/sonos.svg" alt="Sonos Speaker" width="32" height="32" /></td>
<td>Sonos Speaker</td>
<td>Sonos wireless speaker system</td>
<td><code>All of: (MAC Address belongs to Sonos, Inc., Any of: (445/tcp is open, 3445/tcp is open, 1400/tcp is open, 1410/tcp is open, 1843/tcp is open, 3400/tcp is open, 3401/tcp is open, 3500/tcp is open))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tasmota.svg" alt="Tasmota" width="32" height="32" /></td>
<td>Tasmota</td>
<td>ESP device firmware</td>
<td><code>No match pattern provided</code></td>
</tr>
</tbody>
</table>

## Media

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/audiobookshelf.svg" alt="AudioBookShelf" width="32" height="32" /></td>
<td>AudioBookShelf</td>
<td>Self-hosted audiobook and podcast server.</td>
<td><code>13378/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/autobrr.svg" alt="Autobrr" width="32" height="32" /></td>
<td>Autobrr</td>
<td>The modern autodl-irssi replacement.</td>
<td><code>7474/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg" alt="Bazarr" width="32" height="32" /></td>
<td>Bazarr</td>
<td>A companion application to Sonarr and Radarr that manages and downloads subtitles</td>
<td><code>6767/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cleanuperr.svg" alt="Cleanuparr" width="32" height="32" /></td>
<td>Cleanuparr</td>
<td>Torrent cleanup tool for Sonarr and Radarr</td>
<td><code>11011/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/emby.svg" alt="Emby" width="32" height="32" /></td>
<td>Emby</td>
<td>Personal media server with streaming capabilities</td>
<td><code>Endpoint response body from <ip>:8096/emby/System/Info/Public contains Emby</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/huntarr.png" alt="Huntarr" width="32" height="32" /></td>
<td>Huntarr</td>
<td>Finds missing media and upgrades your existing content.</td>
<td><code>9705/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg" alt="Immich" width="32" height="32" /></td>
<td>Immich</td>
<td>Self-hosted photo and video management solution</td>
<td><code>Endpoint response body from <ip>:2283/photos contains Immich</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg" alt="Jellyfin" width="32" height="32" /></td>
<td>Jellyfin</td>
<td>Free media server for personal streaming</td>
<td><code>Endpoint response body from <ip>:80/System/Info/Public contains Jellyfin</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyseerr.svg" alt="Jellyseerr" width="32" height="32" /></td>
<td>Jellyseerr</td>
<td>Open source software application for managing requests for your media library.</td>
<td><code>Endpoint response body from <ip>:5055/ contains Jellyseerr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellystat.svg" alt="Jellystat" width="32" height="32" /></td>
<td>Jellystat</td>
<td>Open source software application for managing requests for your media library.</td>
<td><code>All of: (Endpoint response body from <ip>:3000/ contains Jellystat, Endpoint response body from <ip>:3000/ contains Jellyfin stats for the masses)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/karakeep.svg" alt="Karakeep" width="32" height="32" /></td>
<td>Karakeep</td>
<td>The Bookmark Everything App</td>
<td><code>Endpoint response body from <ip>:3000/manifest.json contains Karakeep</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/komga.svg" alt="Komga" width="32" height="32" /></td>
<td>Komga</td>
<td>A media server for your comics, mangas, BDs, magazines and eBooks.</td>
<td><code>Endpoint response body from <ip>:25600/ contains Komga</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/lidarr.svg" alt="Lidarr" width="32" height="32" /></td>
<td>Lidarr</td>
<td>A music collection manager for Usenet and BitTorrent users.</td>
<td><code>Endpoint response body from <ip>:8686/Content/manifest.json contains Lidarr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/memos.png" alt="Memos" width="32" height="32" /></td>
<td>Memos</td>
<td>An open-source, self-hosted note-taking service.</td>
<td><code>Endpoint response body from <ip>:5230/explore contains Memos</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/overseerr.svg" alt="Overseerr" width="32" height="32" /></td>
<td>Overseerr</td>
<td>Open source software application for managing requests for your media library.</td>
<td><code>All of: (Endpoint response body from <ip>:5055/site.webmanifest contains Overseerr, Not (Endpoint response body from <ip>:5055/ contains Jellyseerr))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/plex.svg" alt="Plex Media Server" width="32" height="32" /></td>
<td>Plex Media Server</td>
<td>Media server for streaming personal content</td>
<td><code>Any of: (Endpoint response body from <ip>:32400/web/index.html contains Plex, Endpoint response status is between 401 and 401, and response from <ip>:32400 has header X-Plex-Protocol with value 1.0)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg" alt="Prowlarr" width="32" height="32" /></td>
<td>Prowlarr</td>
<td>The Ultimate Indexer Manager.</td>
<td><code>Endpoint response body from <ip>:3232/Content/Images/Icons/manifest.json contains Prowlarr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg" alt="Radarr" width="32" height="32" /></td>
<td>Radarr</td>
<td>A movie collection manager for Usenet and BitTorrent users.</td>
<td><code>Endpoint response body from <ip>:7878/Content/manifest.json contains Radarr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sabnzbd.svg" alt="SABnzbd" width="32" height="32" /></td>
<td>SABnzbd</td>
<td>A NZB Files Downloader.</td>
<td><code>Endpoint response body from <ip>:8080/Content/manifest.json contains SABnzbd</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/slskd.svg" alt="Slskd" width="32" height="32" /></td>
<td>Slskd</td>
<td>A modern client-server application for the Soulseek file-sharing network</td>
<td><code>All of: (Endpoint response body from <ip>:5030/ contains slskd, Endpoint response body from <ip>:5030/api/v0/session/enabled contains true)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg" alt="Sonarr" width="32" height="32" /></td>
<td>Sonarr</td>
<td>A TV collection manager for Usenet and BitTorrent users.</td>
<td><code>Endpoint response body from <ip>:8989/Content/manifest.json contains Sonarr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tautulli.svg" alt="Tautulli" width="32" height="32" /></td>
<td>Tautulli</td>
<td>Monitor, view analytics, and receive notifications about your Plex Media Server.</td>
<td><code>Endpoint response body from <ip>:8181/ contains Tautulli</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wizarr.svg" alt="Wizarr" width="32" height="32" /></td>
<td>Wizarr</td>
<td>User invitation and management system for Jellyfin, Plex, Emby etc</td>
<td><code>Endpoint response body from <ip>:5690/static/manifest.json contains Wizarr</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qbittorrent.svg" alt="qBittorrent" width="32" height="32" /></td>
<td>qBittorrent</td>
<td>Cross-platform open-source BitTorrent client</td>
<td><code>Any of: (Endpoint response body from <ip>:8080/ contains qBittorrent logo, Endpoint response body from <ip>:8090/ contains qBittorrent logo)</code></td>
</tr>
</tbody>
</table>

## MessageQueue

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://www.vectorlogo.zone/logos/apache_activemq/apache_activemq-icon.svg" alt="ActiveMQ" width="32" height="32" /></td>
<td>ActiveMQ</td>
<td>Message broker</td>
<td><code>Endpoint response body from <ip>:8161/admin contains activemq</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/apachekafka.svg" alt="Kafka" width="32" height="32" /></td>
<td>Kafka</td>
<td>Event streaming platform</td>
<td><code>9092/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mqtt.svg" alt="MQTT" width="32" height="32" /></td>
<td>MQTT</td>
<td>Generic MQTT broker</td>
<td><code>Any of: (1883/tcp is open, 8883/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/natsdotio.svg" alt="NATS" width="32" height="32" /></td>
<td>NATS</td>
<td>Cloud-native messaging system</td>
<td><code>Endpoint response body from <ip>:8222/varz contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ntfy.svg" alt="Ntfy" width="32" height="32" /></td>
<td>Ntfy</td>
<td>Simple HTTP-based pub-sub notification service</td>
<td><code>Any of: (Endpoint response body from <ip>:80/ contains ntfy web, Endpoint response body from <ip>:2856/ contains ntfy web)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rabbitmq.svg" alt="RabbitMQ" width="32" height="32" /></td>
<td>RabbitMQ</td>
<td>Message broker</td>
<td><code>Endpoint response body from <ip>:15672/ contains rabbitmq</code></td>
</tr>
</tbody>
</table>

## Mobile

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">—</td>
<td>Client</td>
<td>A generic client device that initiates connections to services</td>
<td><code>No match pattern provided</code></td>
</tr>
</tbody>
</table>

## Monitoring

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apc.svg" alt="APC" width="32" height="32" /></td>
<td>APC</td>
<td>APC Network-Connected UPS</td>
<td><code>Endpoint response body from <ip>:80/ contains Schneider Electric</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cooler-control.svg" alt="CoolerControl" width="32" height="32" /></td>
<td>CoolerControl</td>
<td>Monitor temperatures, fan speeds, and power in real time.</td>
<td><code>Endpoint response body from <ip>:11987/ contains CoolerControl</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/elastic.svg" alt="Elastic APM" width="32" height="32" /></td>
<td>Elastic APM</td>
<td>Application performance monitoring</td>
<td><code>Endpoint response body from <ip>:8200/ contains apm</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gatus.svg" alt="Gatus" width="32" height="32" /></td>
<td>Gatus</td>
<td>Automated developer-oriented status page</td>
<td><code>Endpoint response body from <ip>:8080/manifest.json contains Gatus</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glances.svg" alt="Glances" width="32" height="32" /></td>
<td>Glances</td>
<td>An open-source system cross-platform monitoring tool.</td>
<td><code>Endpoint response body from <ip>:61208/ contains Glances</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grafana.svg" alt="Grafana" width="32" height="32" /></td>
<td>Grafana</td>
<td>Analytics and monitoring visualization platform</td>
<td><code>Endpoint response body from <ip>:80/ contains grafana.com</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/graylog.svg" alt="Graylog" width="32" height="32" /></td>
<td>Graylog</td>
<td>Security Information and Event Management (SIEM) solution and log analytics platform</td>
<td><code>All of: (Endpoint response from <ip> has header content-security-policy with value graylog, Endpoint response body from <ip>:9000/ contains Graylog)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/icinga.svg" alt="Icinga" width="32" height="32" /></td>
<td>Icinga</td>
<td>Infrastructure monitoring</td>
<td><code>Endpoint response body from <ip>:5665/v1 contains icinga</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jaeger.svg" alt="Jaeger" width="32" height="32" /></td>
<td>Jaeger</td>
<td>Distributed tracing system</td>
<td><code>Endpoint response body from <ip>:16686/ contains jaeger</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nut.svg" alt="NUT" width="32" height="32" /></td>
<td>NUT</td>
<td>Network UPS Tools</td>
<td><code>3493/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nagios.svg" alt="Nagios" width="32" height="32" /></td>
<td>Nagios</td>
<td>Infrastructure monitoring</td>
<td><code>Endpoint response body from <ip>:80/nagios contains nagios</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/netdata.svg" alt="Netdata" width="32" height="32" /></td>
<td>Netdata</td>
<td>Real-time performance monitoring</td>
<td><code>Endpoint response body from <ip>:19999/api/v1/info contains netdata</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/peanut.svg" alt="PeaNUT" width="32" height="32" /></td>
<td>PeaNUT</td>
<td>A tiny dashboard for Network UPS Tools</td>
<td><code>Endpoint response body from <ip>:3000/api/v1/info contains peanut</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prometheus.svg" alt="Prometheus" width="32" height="32" /></td>
<td>Prometheus</td>
<td>Time-series monitoring and alerting system</td>
<td><code>Any of: (Endpoint response body from <ip>:80/metrics contains Prometheus, Endpoint response body from <ip>:80/graph contains Prometheus)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pulse.svg" alt="Pulse" width="32" height="32" /></td>
<td>Pulse</td>
<td>Proxmox node/cluster/VM/LXC monitor</td>
<td><code>Endpoint response body from <ip>:7655/ contains Pulse</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sensu.svg" alt="Sensu" width="32" height="32" /></td>
<td>Sensu</td>
<td>Monitoring framework</td>
<td><code>Endpoint response body from <ip>:4567/health contains sensu</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sentry.svg" alt="Sentry" width="32" height="32" /></td>
<td>Sentry</td>
<td>Error tracking platform</td>
<td><code>Endpoint response body from <ip>:9000/api/0/ contains sentry</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/splunk.svg" alt="Splunk" width="32" height="32" /></td>
<td>Splunk</td>
<td>Data analytics platform</td>
<td><code>Endpoint response body from <ip>:8000/ contains splunk</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/uptime-kuma.svg" alt="UptimeKuma" width="32" height="32" /></td>
<td>UptimeKuma</td>
<td>Self-hosted uptime monitoring tool</td>
<td><code>Endpoint response body from <ip>:80/ contains Uptime Kuma</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wazuh.svg" alt="Wazuh" width="32" height="32" /></td>
<td>Wazuh</td>
<td>Security platform</td>
<td><code>Endpoint response body from <ip>:55000/ contains wazuh</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zabbix.svg" alt="Zabbix" width="32" height="32" /></td>
<td>Zabbix</td>
<td>Enterprise monitoring solution</td>
<td><code>Endpoint response body from <ip>:80/zabbix contains zabbix</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Zipkin</td>
<td>Distributed tracing system</td>
<td><code>Endpoint response body from <ip>:9411/api/v2/services contains </code></td>
</tr>
</tbody>
</table>

## Netvisor

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="/logos/netvisor-logo.png" alt="NetVisor Daemon API" width="32" height="32" /></td>
<td>NetVisor Daemon API</td>
<td>NetVisor Daemon API for network scanning</td>
<td><code>Endpoint response body from <ip>:60073/api/health contains netvisor</code></td>
</tr>
<tr>
<td align="center"><img src="/logos/netvisor-logo.png" alt="NetVisor Server API" width="32" height="32" /></td>
<td>NetVisor Server API</td>
<td>NetVisor Server API for network management</td>
<td><code>Endpoint response body from <ip>:60072/api/health contains netvisor</code></td>
</tr>
</tbody>
</table>

## NetworkAccess

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">—</td>
<td>Access Point</td>
<td>A generic wireless access point for WiFi connectivity</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://www.vectorlogo.zone/logos/eero/eero-icon.svg" alt="Eero Gateway" width="32" height="32" /></td>
<td>Eero Gateway</td>
<td>Eero device providing routing and gateway services</td>
<td><code>All of: (MAC Address belongs to eero Inc, Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.)</code></td>
</tr>
<tr>
<td align="center"><img src="https://www.vectorlogo.zone/logos/eero/eero-icon.svg" alt="Eero Repeater" width="32" height="32" /></td>
<td>Eero Repeater</td>
<td>Eero device providing mesh network services</td>
<td><code>All of: (MAC Address belongs to eero Inc, Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fios.svg" alt="Fios Extender" width="32" height="32" /></td>
<td>Fios Extender</td>
<td>Fios device providing mesh networking services</td>
<td><code>All of: (Endpoint response body from <ip>:80/#/login/ contains fios, Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fios.svg" alt="Fios Gateway" width="32" height="32" /></td>
<td>Fios Gateway</td>
<td>Fios device providing routing and gateway services</td>
<td><code>All of: (Endpoint response body from <ip>:80/#/login/ contains fios, Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Nest repeater" width="32" height="32" /></td>
<td>Google Nest repeater</td>
<td>Google Nest Wifi repeater</td>
<td><code>All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.), Endpoint response body from <ip>:80/ contains Nest Wifi)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Nest router" width="32" height="32" /></td>
<td>Google Nest router</td>
<td>Google Nest Wifi router</td>
<td><code>All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), Host IP is a gateway in daemon's routing tables, or ends in .1 or .254., Endpoint response body from <ip>:80/ contains Nest Wifi)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tp-link.svg" alt="TP-Link EAP" width="32" height="32" /></td>
<td>TP-Link EAP</td>
<td>TP-Link EAP wireless access point</td>
<td><code>All of: (MAC Address belongs to TP-LINK TECHNOLOGIES CO.,LTD, Endpoint response body from <ip>:80/ contains tp-link)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unifi.svg" alt="UniFi Controller" width="32" height="32" /></td>
<td>UniFi Controller</td>
<td>Ubiquiti UniFi network controller</td>
<td><code>Endpoint response body from <ip>:8443/manage contains UniFi</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unifi.svg" alt="Unifi Access Point" width="32" height="32" /></td>
<td>Unifi Access Point</td>
<td>Ubiquiti UniFi wireless access point</td>
<td><code>All of: (MAC Address belongs to Ubiquiti Networks Inc, Endpoint response body from <ip>:80/ contains Unifi)</code></td>
</tr>
</tbody>
</table>

## NetworkCore

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">—</td>
<td>Dhcp Server</td>
<td>A generic Dhcp server</td>
<td><code>67/udp is open</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Gateway</td>
<td>A generic gateway</td>
<td><code>All of: (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254., A custom match pattern evaluated at runtime)</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Switch</td>
<td>Generic network switch for local area networking</td>
<td><code>All of: (Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.), All of: (80/tcp is open, 23/tcp is open))</code></td>
</tr>
</tbody>
</table>

## NetworkSecurity

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/crowdsec.svg" alt="CrowdSec" width="32" height="32" /></td>
<td>CrowdSec</td>
<td>Crowdsourced protection against malicious IPs</td>
<td><code>Endpoint response status is between 401 and 401, and response body from <ip>:8080/v1/allowlists contains cookie token is empty</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Firewall</td>
<td>Generic network security appliance</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fortinet.svg" alt="Fortinet" width="32" height="32" /></td>
<td>Fortinet</td>
<td>Fortinet security appliance</td>
<td><code>Endpoint response body from <ip>:80/login contains fortinet</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/opnsense.svg" alt="OPNsense" width="32" height="32" /></td>
<td>OPNsense</td>
<td>Open-source firewall and routing platform</td>
<td><code>All of: (Any of: (Endpoint response body from <ip>:80/ contains opnsense, Endpoint response body from <ip>:443/ contains opnsense), Any of: (53/tcp is open, 53/udp is open, 22/tcp is open, 123/udp is open, 67/udp is open))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pfsense.svg" alt="pfSense" width="32" height="32" /></td>
<td>pfSense</td>
<td>Open-source firewall and router platform</td>
<td><code>All of: (22/tcp is open, Endpoint response body from <ip>:80/ contains pfsense)</code></td>
</tr>
</tbody>
</table>

## Printer

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cups.svg" alt="CUPS" width="32" height="32" /></td>
<td>CUPS</td>
<td>Common Unix Printing System</td>
<td><code>All of: (631/tcp is open, Endpoint response body from <ip>:80/ contains CUPS)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hp.svg" alt="Hp Printer" width="32" height="32" /></td>
<td>Hp Printer</td>
<td>An HP Printer</td>
<td><code>All of: (Any of: (Endpoint response body from <ip>:80 contains LaserJet, Endpoint response body from <ip>:80 contains DeskJet, Endpoint response body from <ip>:80 contains OfficeJet, Endpoint response body from <ip>:8080 contains LaserJet, Endpoint response body from <ip>:8080 contains DeskJet, Endpoint response body from <ip>:8080 contains OfficeJet), Any of: (631/tcp is open, 515/tcp is open, 515/udp is open))</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Print Server</td>
<td>A generic printing service</td>
<td><code>Any of: (631/tcp is open, 515/tcp is open, 515/udp is open)</code></td>
</tr>
</tbody>
</table>

## ReverseProxy

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/caddy.svg" alt="Caddy" width="32" height="32" /></td>
<td>Caddy</td>
<td>Lightweight & versatile reverse proxy, web & file server</td>
<td><code>Endpoint response body from <ip>:2019/reverse_proxy/upstreams contains num_requests</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cloudflare.svg" alt="Cloudflared" width="32" height="32" /></td>
<td>Cloudflared</td>
<td>Cloudflare tunnel daemon</td>
<td><code>Endpoint response body from <ip>:80/metrics contains cloudflared</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/haproxy.svg" alt="HAProxy" width="32" height="32" /></td>
<td>HAProxy</td>
<td>Load balancer and proxy</td>
<td><code>Endpoint response body from <ip>:8404/stats contains haproxy</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/kong.svg" alt="Kong" width="32" height="32" /></td>
<td>Kong</td>
<td>API gateway</td>
<td><code>Endpoint response body from <ip>:8001/ contains kong</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nginx-proxy-manager.svg" alt="Nginx Proxy Manager" width="32" height="32" /></td>
<td>Nginx Proxy Manager</td>
<td>Web-based Nginx proxy management interface</td>
<td><code>Endpoint response body from <ip>:80 contains nginx proxy manager</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik.svg" alt="Traefik" width="32" height="32" /></td>
<td>Traefik</td>
<td>Modern reverse proxy and load balancer</td>
<td><code>Endpoint response body from <ip>:80/dashboard contains traefik</code></td>
</tr>
<tr>
<td align="center"><img src="https://www.vectorlogo.zone/logos/tyk/tyk-icon.svg" alt="Tyk" width="32" height="32" /></td>
<td>Tyk</td>
<td>API gateway</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:8080/hello contains tyk</code></td>
</tr>
</tbody>
</table>

## Storage

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ceph.svg" alt="Ceph" width="32" height="32" /></td>
<td>Ceph</td>
<td>Distributed storage</td>
<td><code>Endpoint response body from <ip>:8080/ contains ceph dashboard</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>FTP Server</td>
<td>Generic FTP file sharing service</td>
<td><code>21/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/filezilla.svg" alt="FileZilla Server" width="32" height="32" /></td>
<td>FileZilla Server</td>
<td>FTP server</td>
<td><code>All of: (21/tcp is open, 14147/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/minio.svg" alt="MinIO" width="32" height="32" /></td>
<td>MinIO</td>
<td>Object storage</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:9000/minio/health/live contains </code></td>
</tr>
<tr>
<td align="center">—</td>
<td>NFS</td>
<td>Generic network file system</td>
<td><code>2049/tcp is open</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Nas Device</td>
<td>A generic network storage devices</td>
<td><code>2049/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/netbootxyz.svg" alt="Netbootxyz" width="32" height="32" /></td>
<td>Netbootxyz</td>
<td>PXE Boot Server</td>
<td><code>Endpoint response body from <ip>:61208/ contains Netbootxyz</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openmediavault.svg" alt="OpenMediaVault" width="32" height="32" /></td>
<td>OpenMediaVault</td>
<td>Debian-based NAS solution</td>
<td><code>All of: (445/tcp is open, Endpoint response body from <ip>:80/ contains openmediavault)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qnap.svg" alt="QNAP NAS" width="32" height="32" /></td>
<td>QNAP NAS</td>
<td>QNAP network attached storage system</td>
<td><code>All of: (21/tcp is open, Any of: (Endpoint response body from <ip>:80/ contains QNAP, Endpoint response body from <ip>:8080/ contains QNAP))</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Samba</td>
<td>Generic SMB file server</td>
<td><code>445/tcp is open</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/seafile.svg" alt="Seafile" width="32" height="32" /></td>
<td>Seafile</td>
<td>File hosting platform</td>
<td><code>Endpoint response body from <ip>:8000/api2/ping contains seafile</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/synology.svg" alt="Synology DSM" width="32" height="32" /></td>
<td>Synology DSM</td>
<td>Synology DiskStation Manager NAS system</td>
<td><code>All of: (Endpoint response body from <ip>:80/ contains synology, 21/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/truenas.svg" alt="TrueNAS" width="32" height="32" /></td>
<td>TrueNAS</td>
<td>Open-source network attached storage system</td>
<td><code>All of: (445/tcp is open, Endpoint response body from <ip>:80/ contains TrueNAS)</code></td>
</tr>
</tbody>
</table>

## Virtualization

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker" width="32" height="32" /></td>
<td>Docker</td>
<td>Docker</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker Container" width="32" height="32" /></td>
<td>Docker Container</td>
<td>A generic docker container</td>
<td><code>All of: (Service is running in a docker container, A custom match pattern evaluated at runtime)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker Swarm" width="32" height="32" /></td>
<td>Docker Swarm</td>
<td>Docker native clustering and orchestration</td>
<td><code>All of: (2377/tcp is open, 7946/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/kubernetes.svg" alt="Kubernetes" width="32" height="32" /></td>
<td>Kubernetes</td>
<td>Container orchestration platform</td>
<td><code>All of: (6443/tcp is open, Any of: (10250/tcp is open, 10259/tcp is open, 10257/tcp is open, 10256/tcp is open))</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nomad.svg" alt="Nomad" width="32" height="32" /></td>
<td>Nomad</td>
<td>Workload orchestration</td>
<td><code>Endpoint response body from <ip>:4646/v1/status/leader contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openshift.svg" alt="OpenShift" width="32" height="32" /></td>
<td>OpenShift</td>
<td>Enterprise Kubernetes</td>
<td><code>Endpoint response body from <ip>:6443/healthz contains openshift</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/portainer.svg" alt="Portainer" width="32" height="32" /></td>
<td>Portainer</td>
<td>Container management web interface</td>
<td><code>Any of: (Endpoint response body from <ip>:9443/#!/auth contains portainer.io, Endpoint response body from <ip>:9000/ contains portainer.io)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox VE" width="32" height="32" /></td>
<td>Proxmox VE</td>
<td>Open-source virtualization management platform</td>
<td><code>Any of: (Endpoint response body from <ip>:8006/ contains proxmox, 8006/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rancher.svg" alt="Rancher" width="32" height="32" /></td>
<td>Rancher</td>
<td>Kubernetes management</td>
<td><code>Endpoint response body from <ip>:80/v3 contains rancher</code></td>
</tr>
</tbody>
</table>

## Web

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/actual-budget.svg" alt="Actual Budget" width="32" height="32" /></td>
<td>Actual Budget</td>
<td>A local-first personal finance app</td>
<td><code>Endpoint response body from <ip>:5006/manifest.webmanifest contains @actual-app/web</code></td>
</tr>
<tr>
<td align="center"><img src="https://simpleicons.org/icons/bigbluebutton.svg" alt="BigBlueButton" width="32" height="32" /></td>
<td>BigBlueButton</td>
<td>Web conferencing system</td>
<td><code>Endpoint response status is between 200 and 300, and response body from <ip>:80/bigbluebutton/api contains </code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/discourse.svg" alt="Discourse" width="32" height="32" /></td>
<td>Discourse</td>
<td>Discussion platform</td>
<td><code>Endpoint response body from <ip>:80/srv/status contains discourse</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freshrss.svg" alt="FreshRSS" width="32" height="32" /></td>
<td>FreshRSS</td>
<td>A free, self-hostable news aggregator</td>
<td><code>Endpoint response body from <ip>:80/themes/manifest.json contains FreshRSS feed aggregator</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ghost.png" alt="Ghost" width="32" height="32" /></td>
<td>Ghost</td>
<td>Publishing platform</td>
<td><code>Endpoint response body from <ip>:2368/ contains ghost</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jotty.svg" alt="Jotty" width="32" height="32" /></td>
<td>Jotty</td>
<td>A simple, self-hosted app for your checklists and notes</td>
<td><code>Endpoint response body from <ip>:3000/site.webmanifest contains jotty</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/metube.svg" alt="MeTube" width="32" height="32" /></td>
<td>MeTube</td>
<td>Self-hosted YouTube downloader</td>
<td><code>Endpoint response body from <ip>:8081/manifest.webmanifest contains MeTube</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nextcloud.svg" alt="NextCloud" width="32" height="32" /></td>
<td>NextCloud</td>
<td>Self-hosted cloud storage and collaboration platform</td>
<td><code>Endpoint response body from <ip>:80/core/css/server.css contains Nextcloud GmbH</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/open-webui-light.svg" alt="Open WebUI" width="32" height="32" /></td>
<td>Open WebUI</td>
<td>Open, extensible, user-friendly interface for AI</td>
<td><code>Endpoint response body from <ip>:8080/manifest.json contains Open WebUI</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg" alt="Paperless-NGX" width="32" height="32" /></td>
<td>Paperless-NGX</td>
<td>Community-supported document management system</td>
<td><code>Endpoint response body from <ip>:8000/static/frontend/en-US/manifest.webmanifest contains Paperless-ngx</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rocket-chat.svg" alt="Rocket.Chat" width="32" height="32" /></td>
<td>Rocket.Chat</td>
<td>Team communication platform</td>
<td><code>Endpoint response body from <ip>:3000/api/info contains rocket</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>SIP Server</td>
<td>Session initiation protocol</td>
<td><code>Any of: (5060/tcp is open, 5061/tcp is open)</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apache-tomcat.svg" alt="Tomcat" width="32" height="32" /></td>
<td>Tomcat</td>
<td>Java servlet container</td>
<td><code>Endpoint response body from <ip>:8080/ contains apache tomcat</code></td>
</tr>
<tr>
<td align="center">—</td>
<td>Web Service</td>
<td>A generic web service</td>
<td><code>No match pattern provided</code></td>
</tr>
<tr>
<td align="center"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wordpress.svg" alt="WordPress" width="32" height="32" /></td>
<td>WordPress</td>
<td>Content management system</td>
<td><code>Endpoint response body from <ip>:80/ contains wp-content</code></td>
</tr>
</tbody>
</table>

## Workstation

<table>
<thead>
<tr>
<th width="60">Logo</th>
<th width="200">Name</th>
<th width="300">Description</th>
<th>Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center">—</td>
<td>Workstation</td>
<td>Desktop computer for productivity work</td>
<td><code>All of: (3389/tcp is open, 445/tcp is open)</code></td>
</tr>
</tbody>
</table>

