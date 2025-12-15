# Scanopy Service Definitions

This document lists all services that Scanopy can automatically discover and identify.

## AdBlock

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/adguard-home.svg" alt="Adguard Home" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Adguard Home</td>
<td style="padding: 12px; color: #d1d5db;">Network-wide ad and tracker blocking</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (All of: (53/udp is open, 53/tcp is open), Endpoint response body from <ip>:80/ contains "AdGuard Home")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pi-hole.svg" alt="Pi-Hole" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Pi-Hole</td>
<td style="padding: 12px; color: #d1d5db;">Network-wide ad blocking DNS service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (53/udp is open, 53/tcp is open), Endpoint response body from <ip>:80/admin contains "pi-hole")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pfsense.svg" alt="pfBlockerNG" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">pfBlockerNG</td>
<td style="padding: 12px; color: #d1d5db;">PfSense package for DNS/IP blocking</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (All of: (53/tcp is open, 53/udp is open), Endpoint response body from <ip>:80/pfblockerng contains "pfblockerng")</code></td>
</tr>
</tbody>
</table>

## Backup

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/backrest-light.svg" alt="BackRest" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">BackRest</td>
<td style="padding: 12px; color: #d1d5db;">Web UI and orchestrator for Restic</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:9898/ contains "BackRest"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/bacula.png" alt="Bacula" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bacula</td>
<td style="padding: 12px; color: #d1d5db;">Network backup solution</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">9101/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/duplicati.svg" alt="Duplicati" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Duplicati</td>
<td style="padding: 12px; color: #d1d5db;">Cross-platform backup client with encryption</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8200/ngax/index.html contains "Duplicati"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox Backup Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Proxmox Backup Server</td>
<td style="padding: 12px; color: #d1d5db;">Encrypted, incremental and deduplicated backups for Proxmox VMs, LXCs, and hosts</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:8007/ contains "proxmox-backup-gui", 8007/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/restic.png" alt="Restic" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Restic</td>
<td style="padding: 12px; color: #d1d5db;">Fast and secure backup program</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (8000/tcp is open, Endpoint response body from <ip>:80/ contains "restic")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/syncthing.svg" alt="Syncthing" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Syncthing</td>
<td style="padding: 12px; color: #d1d5db;">Continuous file synchronization service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/ contains "Syncthing", 22000/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/veeam.svg" alt="Veeam" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Veeam</td>
<td style="padding: 12px; color: #d1d5db;">Backup and replication</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">9392/tcp is open</code></td>
</tr>
</tbody>
</table>

## Collaboration

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/confluence.svg" alt="Confluence" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Confluence</td>
<td style="padding: 12px; color: #d1d5db;">Team collaboration wiki</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8090/ contains "confluence"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jira.svg" alt="Jira" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jira</td>
<td style="padding: 12px; color: #d1d5db;">Project management platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:8080/rest/api/2/serverInfo contains "jira"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mattermost.svg" alt="Mattermost" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Mattermost</td>
<td style="padding: 12px; color: #d1d5db;">Team messaging platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8065/api/v4/system/ping contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radicale.svg" alt="Radicale" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Radicale</td>
<td style="padding: 12px; color: #d1d5db;">Free and Open-Source CalDAV and CardDAV Server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5232/.web/ contains "Radicale Web Interface"</code></td>
</tr>
</tbody>
</table>

## Communication

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/asterisk.png" alt="Asterisk" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Asterisk</td>
<td style="padding: 12px; color: #d1d5db;">PBX and VoIP server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8088/httpstatus contains "asterisk"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freepbx.svg" alt="FreePBX" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">FreePBX</td>
<td style="padding: 12px; color: #d1d5db;">PBX web interface</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/ contains "freepbx", 5060/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jitsi-meet.svg" alt="Jitsi Meet" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jitsi Meet</td>
<td style="padding: 12px; color: #d1d5db;">Video conferencing</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8443/ contains "jitsilogo.png"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mailcow.svg" alt="mailcow" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">mailcow</td>
<td style="padding: 12px; color: #d1d5db;">Open-source mail server suite (Dockerized)</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:443/api/v1/get/status contains "mailcow"</code></td>
</tr>
</tbody>
</table>

## DNS

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bind9</td>
<td style="padding: 12px; color: #d1d5db;">Berkeley Internet Name Domain DNS server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (53/udp is open, 8053/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Dns Server</td>
<td style="padding: 12px; color: #d1d5db;">A generic Dns server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (53/tcp is open, 53/udp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/powerdns.svg" alt="PowerDNS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">PowerDNS</td>
<td style="padding: 12px; color: #d1d5db;">Authoritative DNS server with API</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (53/udp is open, 53/tcp is open, 8081/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unbound.svg" alt="Unbound DNS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Unbound DNS</td>
<td style="padding: 12px; color: #d1d5db;">Recursive DNS resolver with control interface</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (53/udp is open, 8953/tcp is open)</code></td>
</tr>
</tbody>
</table>

## Dashboard

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glance.svg" alt="Glance" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Glance</td>
<td style="padding: 12px; color: #d1d5db;">A self-hosted dashboard that puts all your feeds in one place</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/manifest.json contains "Glance"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/homarr.svg" alt="Homarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Homarr</td>
<td style="padding: 12px; color: #d1d5db;">A sleek, modern dashboard</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">7575/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/webp/homepage.webp" alt="Homepage" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Homepage</td>
<td style="padding: 12px; color: #d1d5db;">A self-hosted dashboard for your homelab</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3000/site.webmanifest contains "Homepage"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jump</td>
<td style="padding: 12px; color: #d1d5db;">A self-hosted startpage and real-time status page</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8123/ contains "Jump"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/linkstack.svg" alt="LinkStack" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">LinkStack</td>
<td style="padding: 12px; color: #d1d5db;">A highly customizable link sharing platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response from <ip> has header "set-cookie" with value "linkstack_session", Endpoint response body from <ip>:8080/ contains "LinkStack")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox Datacenter Manager" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Proxmox Datacenter Manager</td>
<td style="padding: 12px; color: #d1d5db;">A single pane of glass for managing clustered & non-clustered Proxmox nodes</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8443/ contains "pdm-ui_bundle.js"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wireguard.svg" alt="WGDashboard" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">WGDashboard</td>
<td style="padding: 12px; color: #d1d5db;">Wireguard dashboard for visualizing and managing wireguard clients and server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (10086/tcp is open, Not (Subnet is type VpnTunnel))</code></td>
</tr>
</tbody>
</table>

## Database

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apache-cassandra.svg" alt="Cassandra" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Cassandra</td>
<td style="padding: 12px; color: #d1d5db;">Distributed NoSQL database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">9042/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/couchdb.svg" alt="CouchDB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">CouchDB</td>
<td style="padding: 12px; color: #d1d5db;">NoSQL document database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5984/ contains "couchdb"</code></td>
</tr>
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/denodo.svg" alt="CouchDB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Denodo</td>
<td style="padding: 12px; color: #d1d5db;">Data Virtualization</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (9999/tcp (VDP) is open, 9996/tcp (ODBC) is open, 9090/tcp (HTTP) is open, 9099/tcp (Web container) is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/elasticsearch.svg" alt="Elasticsearch" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Elasticsearch</td>
<td style="padding: 12px; color: #d1d5db;">Distributed search and analytics engine</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:9200/ contains "lucene"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/influxdb.svg" alt="InfluxDB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">InfluxDB</td>
<td style="padding: 12px; color: #d1d5db;">Time series database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">8086/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mariadb.svg" alt="MariaDB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MariaDB</td>
<td style="padding: 12px; color: #d1d5db;">MySQL-compatible relational database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft-sql-server-light.svg" alt="Microsoft SQL Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Microsoft SQL Server</td>
<td style="padding: 12px; color: #d1d5db;">Microsoft relational database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">1433/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mongodb.svg" alt="MongoDB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MongoDB</td>
<td style="padding: 12px; color: #d1d5db;">NoSQL document database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">27017/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mysql.svg" alt="MySQL" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MySQL</td>
<td style="padding: 12px; color: #d1d5db;">Open-source relational database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">3306/tcp is open</code></td>
</tr>
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/neo4j.svg" alt="Neo4j" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Neo4j</td>
<td style="padding: 12px; color: #d1d5db;">Graph database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (7474/tcp (WebUI - Secure) is open, 7687/tcp (Bolt) is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/oracle.svg" alt="Oracle Database" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Oracle Database</td>
<td style="padding: 12px; color: #d1d5db;">Enterprise relational database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">1521/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/postgresql.svg" alt="PostgreSQL" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">PostgreSQL</td>
<td style="padding: 12px; color: #d1d5db;">Open-source relational database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">5432/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/redis.svg" alt="Redis" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Redis</td>
<td style="padding: 12px; color: #d1d5db;">In-memory data store and cache</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">6379/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/cadvisor.png" alt="cAdvisor" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">cAdvisor</td>
<td style="padding: 12px; color: #d1d5db;">Graph database</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/api/v1.0/containers/ contains "cAdvisor"</code></td>
</tr>
</tbody>
</table>

## Development

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ansible.svg" alt="AWX" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">AWX</td>
<td style="padding: 12px; color: #d1d5db;">Ansible automation platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:80/api/v2/ contains "awx"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/argo-cd.svg" alt="ArgoCD" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">ArgoCD</td>
<td style="padding: 12px; color: #d1d5db;">GitOps continuous delivery</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/api/version contains "argocd"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/atlassian-bamboo.svg" alt="Bamboo" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bamboo</td>
<td style="padding: 12px; color: #d1d5db;">CI/CD server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8085/ contains "bamboo"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitbucket.svg" alt="Bitbucket Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bitbucket Server</td>
<td style="padding: 12px; color: #d1d5db;">Git repository management</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:7990/ contains "bitbucket"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/drone.png" alt="Drone" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Drone</td>
<td style="padding: 12px; color: #d1d5db;">Container-native CI platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/ contains "drone", Endpoint response body from <ip>:80/api/user contains "")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/github.svg" alt="GitHub" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">GitHub</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted GitHub</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gitlab.svg" alt="GitLab" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">GitLab</td>
<td style="padding: 12px; color: #d1d5db;">DevOps platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response from <ip> has header "content-security-policy" with value "gitlab", Endpoint response body from <ip>:80/ contains "gitlab")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jenkins.svg" alt="Jenkins" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jenkins</td>
<td style="padding: 12px; color: #d1d5db;">Automation server for CI/CD</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "jenkins.io"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ollama-dark.svg" alt="Ollama" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Ollama</td>
<td style="padding: 12px; color: #d1d5db;">An easy way to get up and running with LLMs.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:11434/ contains "Ollama is running"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/spinnaker.svg" alt="Spinnaker" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Spinnaker</td>
<td style="padding: 12px; color: #d1d5db;">Multi-cloud CD platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/teamcity-light.svg" alt="TeamCity" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">TeamCity</td>
<td style="padding: 12px; color: #d1d5db;">CI/CD server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8111/ contains "teamcity"</code></td>
</tr>
</tbody>
</table>

## FileSharing

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/owncloud.svg" alt="ownCloud" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">ownCloud</td>
<td style="padding: 12px; color: #d1d5db;">File sync and share</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/status.php contains "owncloud"</code></td>
</tr>
</tbody>
</table>

## HomeAutomation

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/domoticz.png" alt="Domoticz" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Domoticz</td>
<td style="padding: 12px; color: #d1d5db;">Home automation system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/json.htm contains "domoticz"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/esphome.svg" alt="ESPHome" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">ESPHome</td>
<td style="padding: 12px; color: #d1d5db;">ESP device management</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">6052/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grocy.svg" alt="Grocy" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Grocy</td>
<td style="padding: 12px; color: #d1d5db;">Web-based self-hosted groceries & household management solution</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:80/ contains "grocy.css", Endpoint response body from <ip>:443/ contains "grocy.css")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/home-assistant.svg" alt="Home Assistant" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Home Assistant</td>
<td style="padding: 12px; color: #d1d5db;">Open-source home automation platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8123/ contains "home assistant"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/lubelogger.png" alt="Lubelogger" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Lubelogger</td>
<td style="padding: 12px; color: #d1d5db;">Vehicle Maintenance Records and Fuel Mileage Tracker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "Garage - LubeLogger"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mealie.svg" alt="Mealie" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Mealie</td>
<td style="padding: 12px; color: #d1d5db;">A self-hosted recipe manager and meal planner</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:9000/ contains "Mealie", Endpoint response body from <ip>:9000/ contains "recipe")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/z-wave-js-ui.svg" alt="Z-Wave JS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Z-Wave JS</td>
<td style="padding: 12px; color: #d1d5db;">Z-Wave controller server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8091/health contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zigbee2mqtt.svg" alt="Zigbee2MQTT" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Zigbee2MQTT</td>
<td style="padding: 12px; color: #d1d5db;">Zigbee to MQTT bridge</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "Zigbee2MQTT WindFront"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openhab.svg" alt="openHAB" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">openHAB</td>
<td style="padding: 12px; color: #d1d5db;">Home automation platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/rest/ contains "openhab"</code></td>
</tr>
</tbody>
</table>

## IdentityAndAccess

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/microsoft.svg" alt="Active Directory" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Active Directory</td>
<td style="padding: 12px; color: #d1d5db;">Microsoft directory service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (389/tcp is open, 445/tcp is open, 88/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/authentik.svg" alt="Authentik" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Authentik</td>
<td style="padding: 12px; color: #d1d5db;">A self-hosted, open source identity provider</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:9000/ contains "window.authentik", Endpoint response body from <ip>:9443/ contains "window.authentik")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bitwarden.svg" alt="Bitwarden" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bitwarden</td>
<td style="padding: 12px; color: #d1d5db;">Password manager</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/api/config contains "bitwarden"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freeipa.svg" alt="FreeIPA" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">FreeIPA</td>
<td style="padding: 12px; color: #d1d5db;">Identity management system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:80/ipa/ui contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Kerberos</td>
<td style="padding: 12px; color: #d1d5db;">Kerberos authentication service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">88/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/keycloak.svg" alt="Keycloak" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Keycloak</td>
<td style="padding: 12px; color: #d1d5db;">Identity and access management</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "/keycloak/"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openldap.svg" alt="Open LDAP" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Open LDAP</td>
<td style="padding: 12px; color: #d1d5db;">Generic LDAP directory service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (389/tcp is open, 636/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pocket-id-light.svg" alt="Pocket ID" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Pocket ID</td>
<td style="padding: 12px; color: #d1d5db;">A Simple OIDC provider that uses passkeys for authentication</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:1411/app.webmanifest contains "Pocket ID"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hashicorp-vault.svg" alt="Vault" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Vault</td>
<td style="padding: 12px; color: #d1d5db;">Secrets management</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8200/v1/sys/health contains "vault"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/vaultwarden.svg" alt="Vaultwarden" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Vaultwarden</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted Bitwarden-compatible server, written in Rust</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8000/manifest.json contains "Vaultwarden Web"</code></td>
</tr>
</tbody>
</table>

## IoT

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/alexa.svg" alt="Amazon Echo" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Amazon Echo</td>
<td style="padding: 12px; color: #d1d5db;">Amazon Echo smart speaker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Amazon Technologies Inc., 40317/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/googlecast.svg" alt="Chromecast" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Chromecast</td>
<td style="padding: 12px; color: #d1d5db;">Google Chromecast streaming device</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Google, Inc., 8008/tcp is open, 8009/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Home" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Google Home</td>
<td style="padding: 12px; color: #d1d5db;">Google Home smart speaker or display</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), All of: (8008/tcp is open, 8009/tcp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">IoT</td>
<td style="padding: 12px; color: #d1d5db;">A generic IoT Service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Nest Protect" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Nest Protect</td>
<td style="padding: 12px; color: #d1d5db;">Google Nest smoke and CO detector</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), 11095/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Nest Thermostat" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Nest Thermostat</td>
<td style="padding: 12px; color: #d1d5db;">Google Nest smart thermostat</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), 9543/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/philipshue.svg" alt="Philips Hue Bridge" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Philips Hue Bridge</td>
<td style="padding: 12px; color: #d1d5db;">Philips Hue Bridge for lighting control</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Philips Lighting BV, Endpoint response body from <ip>:80/ contains "hue")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">RTSP Camera</td>
<td style="padding: 12px; color: #d1d5db;">Camera with RTSP Streaming</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">554/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/ring.svg" alt="Ring Doorbell" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Ring Doorbell</td>
<td style="padding: 12px; color: #d1d5db;">Ring video doorbell or security camera</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Amazon Technologies Inc., Any of: (8557/tcp is open, 9998/tcp is open, 19302/tcp is open, 9999/tcp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/roku.svg" alt="Roku Media Player" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Roku Media Player</td>
<td style="padding: 12px; color: #d1d5db;">Roku streaming device or TV</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Roku, Inc, 8060/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/sonos.svg" alt="Sonos Speaker" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Sonos Speaker</td>
<td style="padding: 12px; color: #d1d5db;">Sonos wireless speaker system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Sonos, Inc., Any of: (445/tcp is open, 3445/tcp is open, 1400/tcp is open, 1410/tcp is open, 1843/tcp is open, 3400/tcp is open, 3401/tcp is open, 3500/tcp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tasmota.svg" alt="Tasmota" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Tasmota</td>
<td style="padding: 12px; color: #d1d5db;">ESP device firmware</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
</tbody>
</table>

## Media

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/audiobookshelf.svg" alt="AudioBookShelf" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">AudioBookShelf</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted audiobook and podcast server.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">13378/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/autobrr.svg" alt="Autobrr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Autobrr</td>
<td style="padding: 12px; color: #d1d5db;">The modern autodl-irssi replacement.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">7474/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/bazarr.svg" alt="Bazarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Bazarr</td>
<td style="padding: 12px; color: #d1d5db;">A companion application to Sonarr and Radarr that manages and downloads subtitles</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">6767/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cleanuperr.svg" alt="Cleanuparr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Cleanuparr</td>
<td style="padding: 12px; color: #d1d5db;">Torrent cleanup tool for Sonarr and Radarr</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">11011/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/emby.svg" alt="Emby" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Emby</td>
<td style="padding: 12px; color: #d1d5db;">Personal media server with streaming capabilities</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8096/emby/System/Info/Public contains "Emby"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/huntarr.png" alt="Huntarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Huntarr</td>
<td style="padding: 12px; color: #d1d5db;">Finds missing media and upgrades your existing content.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">9705/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/immich.svg" alt="Immich" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Immich</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted photo and video management solution</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:2283/photos contains "Immich"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyfin.svg" alt="Jellyfin" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jellyfin</td>
<td style="padding: 12px; color: #d1d5db;">Free media server for personal streaming</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/System/Info/Public contains "Jellyfin"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellyseerr.svg" alt="Jellyseerr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jellyseerr</td>
<td style="padding: 12px; color: #d1d5db;">Open source software application for managing requests for your media library.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5055/ contains "Jellyseerr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jellystat.svg" alt="Jellystat" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jellystat</td>
<td style="padding: 12px; color: #d1d5db;">Open source software application for managing requests for your media library.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:3000/ contains "Jellystat", Endpoint response body from <ip>:3000/ contains "Jellyfin stats for the masses")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/karakeep.svg" alt="Karakeep" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Karakeep</td>
<td style="padding: 12px; color: #d1d5db;">The Bookmark Everything App</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3000/manifest.json contains "Karakeep"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/komga.svg" alt="Komga" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Komga</td>
<td style="padding: 12px; color: #d1d5db;">A media server for your comics, mangas, BDs, magazines and eBooks.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:25600/ contains "Komga"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/lidarr.svg" alt="Lidarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Lidarr</td>
<td style="padding: 12px; color: #d1d5db;">A music collection manager for Usenet and BitTorrent users.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8686/Content/manifest.json contains "Lidarr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/memos.png" alt="Memos" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Memos</td>
<td style="padding: 12px; color: #d1d5db;">An open-source, self-hosted note-taking service.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5230/explore contains "Memos"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/overseerr.svg" alt="Overseerr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Overseerr</td>
<td style="padding: 12px; color: #d1d5db;">Open source software application for managing requests for your media library.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:5055/site.webmanifest contains "Overseerr", Not (Endpoint response body from <ip>:5055/ contains "Jellyseerr"))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/plex.svg" alt="Plex Media Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Plex Media Server</td>
<td style="padding: 12px; color: #d1d5db;">Media server for streaming personal content</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:32400/web/index.html contains "Plex", Endpoint response status is between 401 and 401, and response from <ip>:32400 has header "X-Plex-Protocol" with value "1.0")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prowlarr.svg" alt="Prowlarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Prowlarr</td>
<td style="padding: 12px; color: #d1d5db;">The Ultimate Indexer Manager.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3232/Content/Images/Icons/manifest.json contains "Prowlarr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/radarr.svg" alt="Radarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Radarr</td>
<td style="padding: 12px; color: #d1d5db;">A movie collection manager for Usenet and BitTorrent users.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:7878/Content/manifest.json contains "Radarr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sabnzbd.svg" alt="SABnzbd" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">SABnzbd</td>
<td style="padding: 12px; color: #d1d5db;">A NZB Files Downloader.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/Content/manifest.json contains "SABnzbd"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/slskd.svg" alt="Slskd" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Slskd</td>
<td style="padding: 12px; color: #d1d5db;">A modern client-server application for the Soulseek file-sharing network</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:5030/ contains "slskd", Endpoint response body from <ip>:5030/api/v0/session/enabled contains "true")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sonarr.svg" alt="Sonarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Sonarr</td>
<td style="padding: 12px; color: #d1d5db;">A TV collection manager for Usenet and BitTorrent users.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8989/Content/manifest.json contains "Sonarr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tautulli.svg" alt="Tautulli" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Tautulli</td>
<td style="padding: 12px; color: #d1d5db;">Monitor, view analytics, and receive notifications about your Plex Media Server.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8181/ contains "Tautulli"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wizarr.svg" alt="Wizarr" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Wizarr</td>
<td style="padding: 12px; color: #d1d5db;">User invitation and management system for Jellyfin, Plex, Emby etc</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5690/static/manifest.json contains "Wizarr"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qbittorrent.svg" alt="qBittorrent" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">qBittorrent</td>
<td style="padding: 12px; color: #d1d5db;">Cross-platform open-source BitTorrent client</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:8080/ contains "qBittorrent logo", Endpoint response body from <ip>:8090/ contains "qBittorrent logo")</code></td>
</tr>
</tbody>
</table>

## MessageQueue

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">AMQP</td>
<td style="padding: 12px; color: #d1d5db;">Advanced Message Queuing Protocol</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (5672/tcp is open, 5671/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://www.vectorlogo.zone/logos/apache_activemq/apache_activemq-icon.svg" alt="ActiveMQ" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">ActiveMQ</td>
<td style="padding: 12px; color: #d1d5db;">Message broker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8161/admin contains "activemq"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/apachekafka.svg" alt="Kafka" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Kafka</td>
<td style="padding: 12px; color: #d1d5db;">Event streaming platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">9092/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/mqtt.svg" alt="MQTT" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MQTT</td>
<td style="padding: 12px; color: #d1d5db;">Generic MQTT broker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (1883/tcp is open, 8883/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/natsdotio.svg" alt="NATS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">NATS</td>
<td style="padding: 12px; color: #d1d5db;">Cloud-native messaging system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8222/varz contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ntfy.svg" alt="Ntfy" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Ntfy</td>
<td style="padding: 12px; color: #d1d5db;">Simple HTTP-based pub-sub notification service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:80/ contains "ntfy web", Endpoint response body from <ip>:2856/ contains "ntfy web")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rabbitmq.svg" alt="RabbitMQ" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">RabbitMQ</td>
<td style="padding: 12px; color: #d1d5db;">Message broker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:15672/ contains "rabbitmq"</code></td>
</tr>
</tbody>
</table>

## Mobile

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Client</td>
<td style="padding: 12px; color: #d1d5db;">A generic client device that initiates connections to services</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
</tbody>
</table>

## Monitoring

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apc.svg" alt="APC" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">APC</td>
<td style="padding: 12px; color: #d1d5db;">APC Network-Connected UPS</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/ contains "Schneider Electric"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cooler-control.svg" alt="CoolerControl" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">CoolerControl</td>
<td style="padding: 12px; color: #d1d5db;">Monitor temperatures, fan speeds, and power in real time.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:11987/ contains "CoolerControl"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/elastic.svg" alt="Elastic APM" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Elastic APM</td>
<td style="padding: 12px; color: #d1d5db;">Application performance monitoring</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8200/ contains "apm"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/gatus.svg" alt="Gatus" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Gatus</td>
<td style="padding: 12px; color: #d1d5db;">Automated developer-oriented status page</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/manifest.json contains "Gatus"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/glances.svg" alt="Glances" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Glances</td>
<td style="padding: 12px; color: #d1d5db;">An open-source system cross-platform monitoring tool.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:61208/ contains "Glances"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/grafana.svg" alt="Grafana" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Grafana</td>
<td style="padding: 12px; color: #d1d5db;">Analytics and monitoring visualization platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/ contains "grafana.com"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/graylog.svg" alt="Graylog" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Graylog</td>
<td style="padding: 12px; color: #d1d5db;">Security Information and Event Management (SIEM) solution and log analytics platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response from <ip> has header "content-security-policy" with value "graylog", Endpoint response body from <ip>:9000/ contains "Graylog")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/icinga.svg" alt="Icinga" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Icinga</td>
<td style="padding: 12px; color: #d1d5db;">Infrastructure monitoring</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5665/v1 contains "icinga"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jaeger.svg" alt="Jaeger" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jaeger</td>
<td style="padding: 12px; color: #d1d5db;">Distributed tracing system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:16686/ contains "jaeger"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nut.svg" alt="NUT" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">NUT</td>
<td style="padding: 12px; color: #d1d5db;">Network UPS Tools</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">3493/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nagios.svg" alt="Nagios" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Nagios</td>
<td style="padding: 12px; color: #d1d5db;">Infrastructure monitoring</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/nagios contains "nagios"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/netdata.svg" alt="Netdata" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Netdata</td>
<td style="padding: 12px; color: #d1d5db;">Real-time performance monitoring</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:19999/api/v1/info contains "netdata"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/peanut.svg" alt="PeaNUT" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">PeaNUT</td>
<td style="padding: 12px; color: #d1d5db;">A tiny dashboard for Network UPS Tools</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3000/api/v1/info contains "peanut"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/prometheus.svg" alt="Prometheus" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Prometheus</td>
<td style="padding: 12px; color: #d1d5db;">Time-series monitoring and alerting system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:80/metrics contains "Prometheus", Endpoint response body from <ip>:80/graph contains "Prometheus")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pulse.svg" alt="Pulse" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Pulse</td>
<td style="padding: 12px; color: #d1d5db;">Proxmox node/cluster/VM/LXC monitor</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:7655/ contains "Pulse"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sensu.svg" alt="Sensu" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Sensu</td>
<td style="padding: 12px; color: #d1d5db;">Monitoring framework</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:4567/health contains "sensu"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/sentry.svg" alt="Sentry" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Sentry</td>
<td style="padding: 12px; color: #d1d5db;">Error tracking platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:9000/api/0/ contains "sentry"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/splunk.svg" alt="Splunk" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Splunk</td>
<td style="padding: 12px; color: #d1d5db;">Data analytics platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8000/ contains "splunk"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/uptime-kuma.svg" alt="UptimeKuma" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">UptimeKuma</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted uptime monitoring tool</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/ contains "Uptime Kuma"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wazuh.svg" alt="Wazuh" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Wazuh</td>
<td style="padding: 12px; color: #d1d5db;">Security platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:55000/ contains "wazuh"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/zabbix.svg" alt="Zabbix" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Zabbix</td>
<td style="padding: 12px; color: #d1d5db;">Enterprise monitoring solution</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/zabbix contains "zabbix"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Zipkin</td>
<td style="padding: 12px; color: #d1d5db;">Distributed tracing system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:9411/api/v2/services contains ""</code></td>
</tr>
</tbody>
</table>

## NetworkAccess

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Access Point</td>
<td style="padding: 12px; color: #d1d5db;">A generic wireless access point for WiFi connectivity</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://www.vectorlogo.zone/logos/eero/eero-icon.svg" alt="Eero Gateway" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Eero Gateway</td>
<td style="padding: 12px; color: #d1d5db;">Eero device providing routing and gateway services</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to eero Inc, Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://www.vectorlogo.zone/logos/eero/eero-icon.svg" alt="Eero Repeater" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Eero Repeater</td>
<td style="padding: 12px; color: #d1d5db;">Eero device providing mesh network services</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to eero Inc, Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fios.svg" alt="Fios Extender" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Fios Extender</td>
<td style="padding: 12px; color: #d1d5db;">Fios device providing mesh networking services</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/#/login/ contains "fios", Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fios.svg" alt="Fios Gateway" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Fios Gateway</td>
<td style="padding: 12px; color: #d1d5db;">Fios device providing routing and gateway services</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/#/login/ contains "fios", Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Nest repeater" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Google Nest repeater</td>
<td style="padding: 12px; color: #d1d5db;">Google Nest Wifi repeater</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.), Endpoint response body from <ip>:80/ contains "Nest Wifi")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/google-home.svg" alt="Google Nest router" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Google Nest router</td>
<td style="padding: 12px; color: #d1d5db;">Google Nest Wifi router</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (MAC Address belongs to Nest Labs Inc., MAC Address belongs to Google, Inc.), Host IP is a gateway in daemon's routing tables, or ends in .1 or .254., Endpoint response body from <ip>:80/ contains "Nest Wifi")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/tp-link.svg" alt="TP-Link EAP" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">TP-Link EAP</td>
<td style="padding: 12px; color: #d1d5db;">TP-Link EAP wireless access point</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to TP-LINK TECHNOLOGIES CO.,LTD, Endpoint response body from <ip>:80/ contains "tp-link")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unifi.svg" alt="UniFi Controller" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">UniFi Controller</td>
<td style="padding: 12px; color: #d1d5db;">Ubiquiti UniFi network controller</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8443/manage contains "UniFi"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/unifi.svg" alt="Unifi Access Point" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Unifi Access Point</td>
<td style="padding: 12px; color: #d1d5db;">Ubiquiti UniFi wireless access point</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (MAC Address belongs to Ubiquiti Networks Inc, Endpoint response body from <ip>:80/ contains "Unifi")</code></td>
</tr>
</tbody>
</table>

## NetworkCore

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Dhcp Server</td>
<td style="padding: 12px; color: #d1d5db;">A generic Dhcp server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">67/udp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Gateway</td>
<td style="padding: 12px; color: #d1d5db;">A generic gateway</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254., A custom match pattern evaluated at runtime)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">NTP Server</td>
<td style="padding: 12px; color: #d1d5db;">Network Time Protocol server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">123/udp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Remote Desktop</td>
<td style="padding: 12px; color: #d1d5db;">Remote Desktop Protocol (RDP)</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">3389/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">SNMP</td>
<td style="padding: 12px; color: #d1d5db;">Simple Network Management Protocol</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">161/udp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">SSH</td>
<td style="padding: 12px; color: #d1d5db;">Secure Shell remote access</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">22/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Switch</td>
<td style="padding: 12px; color: #d1d5db;">Generic network switch for local area networking</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Not (Host IP is a gateway in daemon's routing tables, or ends in .1 or .254.), All of: (80/tcp is open, 23/tcp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Telnet</td>
<td style="padding: 12px; color: #d1d5db;">Telnet remote access</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">23/tcp is open</code></td>
</tr>
</tbody>
</table>

## NetworkSecurity

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/crowdsec.svg" alt="CrowdSec" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">CrowdSec</td>
<td style="padding: 12px; color: #d1d5db;">Crowdsourced protection against malicious IPs</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 401 and 401, and response body from <ip>:8080/v1/allowlists contains "cookie token is empty"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Firewall</td>
<td style="padding: 12px; color: #d1d5db;">Generic network security appliance</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/fortinet.svg" alt="Fortinet" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Fortinet</td>
<td style="padding: 12px; color: #d1d5db;">Fortinet security appliance</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/login contains "fortinet"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/opnsense.svg" alt="OPNsense" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">OPNsense</td>
<td style="padding: 12px; color: #d1d5db;">Open-source firewall and routing platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (Endpoint response body from <ip>:80/ contains "opnsense", Endpoint response body from <ip>:443/ contains "opnsense"), Any of: (53/tcp is open, 53/udp is open, 22/tcp is open, 123/udp is open, 67/udp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/pfsense.svg" alt="pfSense" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">pfSense</td>
<td style="padding: 12px; color: #d1d5db;">Open-source firewall and router platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (22/tcp is open, Endpoint response body from <ip>:80/ contains "pfsense")</code></td>
</tr>
</tbody>
</table>

## OpenPorts

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Unclaimed Open Ports</td>
<td style="padding: 12px; color: #d1d5db;">Unclaimed open ports. Reassign to the correct service if known.</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">A custom match pattern evaluated at runtime</code></td>
</tr>
</tbody>
</table>

## Printer

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cups.svg" alt="CUPS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">CUPS</td>
<td style="padding: 12px; color: #d1d5db;">Common Unix Printing System</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (631/tcp is open, Endpoint response body from <ip>:80/ contains "CUPS")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/hp.svg" alt="Hp Printer" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Hp Printer</td>
<td style="padding: 12px; color: #d1d5db;">An HP Printer</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Any of: (Endpoint response body from <ip>:80 contains "LaserJet", Endpoint response body from <ip>:80 contains "DeskJet", Endpoint response body from <ip>:80 contains "OfficeJet", Endpoint response body from <ip>:8080 contains "LaserJet", Endpoint response body from <ip>:8080 contains "DeskJet", Endpoint response body from <ip>:8080 contains "OfficeJet"), Any of: (631/tcp is open, 515/tcp is open, 515/udp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Print Server</td>
<td style="padding: 12px; color: #d1d5db;">A generic printing service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (631/tcp is open, 515/tcp is open, 515/udp is open)</code></td>
</tr>
</tbody>
</table>

## ReverseProxy

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/caddy.svg" alt="Caddy" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Caddy</td>
<td style="padding: 12px; color: #d1d5db;">Lightweight & versatile reverse proxy, web & file server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:2019/reverse_proxy/upstreams contains "num_requests"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cloudflare.svg" alt="Cloudflared" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Cloudflared</td>
<td style="padding: 12px; color: #d1d5db;">Cloudflare tunnel daemon</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/metrics contains "cloudflared"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/haproxy.svg" alt="HAProxy" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">HAProxy</td>
<td style="padding: 12px; color: #d1d5db;">Load balancer and proxy</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8404/stats contains "haproxy"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/kong.svg" alt="Kong" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Kong</td>
<td style="padding: 12px; color: #d1d5db;">API gateway</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8001/ contains "kong"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nginx-proxy-manager.svg" alt="Nginx Proxy Manager" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Nginx Proxy Manager</td>
<td style="padding: 12px; color: #d1d5db;">Web-based Nginx proxy management interface</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80 contains "nginx proxy manager"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/traefik.svg" alt="Traefik" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Traefik</td>
<td style="padding: 12px; color: #d1d5db;">Modern reverse proxy and load balancer</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/dashboard contains "traefik"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://www.vectorlogo.zone/logos/tyk/tyk-icon.svg" alt="Tyk" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Tyk</td>
<td style="padding: 12px; color: #d1d5db;">API gateway</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:8080/hello contains "tyk"</code></td>
</tr>
</tbody>
</table>

## Scanopy

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png" alt="Scanopy Daemon" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Scanopy Daemon</td>
<td style="padding: 12px; color: #d1d5db;">Automatically discover and visually document network infrastructure</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:60073/api/health contains "scanopy"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/scanopy/website@main/static/scanopy-logo.png" alt="Scanopy Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Scanopy Server</td>
<td style="padding: 12px; color: #d1d5db;">Automatically discover and visually document network infrastructure</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:60072/api/health contains "scanopy"</code></td>
</tr>
</tbody>
</table>

## Storage

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/ceph.svg" alt="Ceph" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Ceph</td>
<td style="padding: 12px; color: #d1d5db;">Distributed storage</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "ceph dashboard"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">FTP Server</td>
<td style="padding: 12px; color: #d1d5db;">Generic FTP file sharing service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">21/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/filezilla.svg" alt="FileZilla Server" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">FileZilla Server</td>
<td style="padding: 12px; color: #d1d5db;">FTP server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (21/tcp is open, 14147/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/minio.svg" alt="MinIO" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MinIO</td>
<td style="padding: 12px; color: #d1d5db;">Object storage</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:9000/minio/health/live contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">NFS</td>
<td style="padding: 12px; color: #d1d5db;">Generic network file system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">2049/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/netbootxyz.svg" alt="Netbootxyz" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Netbootxyz</td>
<td style="padding: 12px; color: #d1d5db;">PXE Boot Server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:61208/ contains "Netbootxyz"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openmediavault.svg" alt="OpenMediaVault" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">OpenMediaVault</td>
<td style="padding: 12px; color: #d1d5db;">Debian-based NAS solution</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (445/tcp is open, Endpoint response body from <ip>:80/ contains "openmediavault")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/qnap.svg" alt="QNAP NAS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">QNAP NAS</td>
<td style="padding: 12px; color: #d1d5db;">QNAP network attached storage system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (21/tcp is open, Any of: (Endpoint response body from <ip>:80/ contains "QNAP", Endpoint response body from <ip>:8080/ contains "QNAP"))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Samba</td>
<td style="padding: 12px; color: #d1d5db;">Generic SMB file server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">445/tcp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/seafile.svg" alt="Seafile" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Seafile</td>
<td style="padding: 12px; color: #d1d5db;">File hosting platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8000/api2/ping contains "seafile"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/synology.svg" alt="Synology DSM" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Synology DSM</td>
<td style="padding: 12px; color: #d1d5db;">Synology DiskStation Manager NAS system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Endpoint response body from <ip>:80/ contains "synology", 21/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/truenas.svg" alt="TrueNAS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">TrueNAS</td>
<td style="padding: 12px; color: #d1d5db;">Open-source network attached storage system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (445/tcp is open, Endpoint response body from <ip>:80/ contains "TrueNAS")</code></td>
</tr>
</tbody>
</table>

## VPN

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openvpn.svg" alt="OpenVPN" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">OpenVPN</td>
<td style="padding: 12px; color: #d1d5db;">OpenVPN server</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">1194/udp is open</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wireguard.svg" alt="WireGuard" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">WireGuard</td>
<td style="padding: 12px; color: #d1d5db;">WireGuard VPN</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">51820/udp is open</code></td>
</tr>
</tbody>
</table>

## Virtualization

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Docker</td>
<td style="padding: 12px; color: #d1d5db;">Docker</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker Container" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Docker Container</td>
<td style="padding: 12px; color: #d1d5db;">A generic docker container</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (Service is running in a docker container, A custom match pattern evaluated at runtime)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/docker.svg" alt="Docker Swarm" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Docker Swarm</td>
<td style="padding: 12px; color: #d1d5db;">Docker native clustering and orchestration</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (2377/tcp is open, 7946/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/kubernetes.svg" alt="Kubernetes" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Kubernetes</td>
<td style="padding: 12px; color: #d1d5db;">Container orchestration platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (6443/tcp is open, Any of: (10250/tcp is open, 10259/tcp is open, 10257/tcp is open, 10256/tcp is open))</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nomad.svg" alt="Nomad" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Nomad</td>
<td style="padding: 12px; color: #d1d5db;">Workload orchestration</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:4646/v1/status/leader contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/openshift.svg" alt="OpenShift" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">OpenShift</td>
<td style="padding: 12px; color: #d1d5db;">Enterprise Kubernetes</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:6443/healthz contains "openshift"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/portainer.svg" alt="Portainer" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Portainer</td>
<td style="padding: 12px; color: #d1d5db;">Container management web interface</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:9443/#!/auth contains "portainer.io", Endpoint response body from <ip>:9000/ contains "portainer.io")</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/proxmox.svg" alt="Proxmox VE" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Proxmox VE</td>
<td style="padding: 12px; color: #d1d5db;">Open-source virtualization management platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (Endpoint response body from <ip>:8006/ contains "proxmox", 8006/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rancher.svg" alt="Rancher" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Rancher</td>
<td style="padding: 12px; color: #d1d5db;">Kubernetes management</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/v3 contains "rancher"</code></td>
</tr>
</tbody>
</table>

## Web

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/actual-budget.svg" alt="Actual Budget" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Actual Budget</td>
<td style="padding: 12px; color: #d1d5db;">A local-first personal finance app</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:5006/manifest.webmanifest contains "@actual-app/web"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://simpleicons.org/icons/bigbluebutton.svg" alt="BigBlueButton" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">BigBlueButton</td>
<td style="padding: 12px; color: #d1d5db;">Web conferencing system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response status is between 200 and 300, and response body from <ip>:80/bigbluebutton/api contains ""</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/discourse.svg" alt="Discourse" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Discourse</td>
<td style="padding: 12px; color: #d1d5db;">Discussion platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/srv/status contains "discourse"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/freshrss.svg" alt="FreshRSS" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">FreshRSS</td>
<td style="padding: 12px; color: #d1d5db;">A free, self-hostable news aggregator</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/themes/manifest.json contains "FreshRSS feed aggregator"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/ghost.png" alt="Ghost" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Ghost</td>
<td style="padding: 12px; color: #d1d5db;">Publishing platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:2368/ contains "ghost"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/jotty.svg" alt="Jotty" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Jotty</td>
<td style="padding: 12px; color: #d1d5db;">A simple, self-hosted app for your checklists and notes</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3000/site.webmanifest contains "jotty"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/metube.svg" alt="MeTube" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">MeTube</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted YouTube downloader</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8081/manifest.webmanifest contains "MeTube"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nextcloud.svg" alt="NextCloud" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">NextCloud</td>
<td style="padding: 12px; color: #d1d5db;">Self-hosted cloud storage and collaboration platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/core/css/server.css contains "Nextcloud GmbH"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/open-webui-light.svg" alt="Open WebUI" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Open WebUI</td>
<td style="padding: 12px; color: #d1d5db;">Open, extensible, user-friendly interface for AI</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/manifest.json contains "Open WebUI"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/paperless-ngx.svg" alt="Paperless-NGX" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Paperless-NGX</td>
<td style="padding: 12px; color: #d1d5db;">Community-supported document management system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8000/static/frontend/en-US/manifest.webmanifest contains "Paperless-ngx"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/rocket-chat.svg" alt="Rocket.Chat" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Rocket.Chat</td>
<td style="padding: 12px; color: #d1d5db;">Team communication platform</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:3000/api/info contains "rocket"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">SIP Server</td>
<td style="padding: 12px; color: #d1d5db;">Session initiation protocol</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Any of: (5060/tcp is open, 5061/tcp is open)</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/apache-tomcat.svg" alt="Tomcat" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Tomcat</td>
<td style="padding: 12px; color: #d1d5db;">Java servlet container</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:8080/ contains "apache tomcat"</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Web Service</td>
<td style="padding: 12px; color: #d1d5db;">A generic web service</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">No match pattern provided</code></td>
</tr>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;"><img src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/wordpress.svg" alt="WordPress" width="32" height="32" /></td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">WordPress</td>
<td style="padding: 12px; color: #d1d5db;">Content management system</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">Endpoint response body from <ip>:80/ contains "wp-content"</code></td>
</tr>
</tbody>
</table>

## Workstation

<table style="background-color: #1a1d29; border-collapse: collapse; width: 100%;">
<thead>
<tr style="background-color: #1f2937; border-bottom: 2px solid #374151;">
<th width="60" style="padding: 12px; text-align: center; color: #e5e7eb; font-weight: 600;">Logo</th>
<th width="200" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Name</th>
<th width="300" style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Description</th>
<th style="padding: 12px; text-align: left; color: #e5e7eb; font-weight: 600;">Discovery Pattern</th>
</tr>
</thead>
<tbody>
<tr style="border-bottom: 1px solid #374151;">
<td align="center" style="padding: 12px; color: #d1d5db;">—</td>
<td style="padding: 12px; color: #f3f4f6; font-weight: 500;">Workstation</td>
<td style="padding: 12px; color: #d1d5db;">Desktop computer for productivity work</td>
<td style="padding: 12px;"><code style="background-color: #374151; color: #e5e7eb; padding: 2px 6px; border-radius: 3px; font-size: 0.875em;">All of: (3389/tcp is open, 445/tcp is open)</code></td>
</tr>
</tbody>
</table>

