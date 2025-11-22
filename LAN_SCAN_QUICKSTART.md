# NetVisor LAN Scanning - Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Start NetVisor
```bash
curl -O https://raw.githubusercontent.com/mayanayza/netvisor/main/docker-compose.yml
docker compose up -d
```

### Step 2: Access UI
Open browser: **http://localhost:60072**

### Step 3: Create Account
- Enter email and password (min 12 chars, must have upper, lower, number, special)
- Click Register

### Step 4: Wait for Auto-Discovery
NetVisor automatically starts scanning! Watch progress in **Discover > Sessions**

### Step 5: View Results
After 5-10 minutes:
- **Manage > Hosts** - See discovered devices
- **Topology** - Visualize your network

---

## ✅ What's Already Configured

The default docker-compose.yml is **already set up** for LAN scanning:

✅ **network_mode: host** - Daemon has access to your LAN
✅ **privileged: true** - Can perform network scans
✅ **Auto-detection** - Finds your LAN subnet automatically

**You don't need to change anything for basic LAN scanning!**

---

## 🔍 What Will Be Scanned

If your computer's IP is `192.168.1.100`, NetVisor will scan:
- ✅ All devices on `192.168.1.0/24` (your LAN)
- ✅ Services running on those devices
- ✅ Docker containers (if socket mounted)
- ✅ Network relationships

---

## 🛠️ Common Commands

| Action | Command |
|--------|---------|
| Start | `docker compose up -d` |
| Stop | `docker compose down` |
| View daemon logs | `docker logs netvisor-daemon -f` |
| View server logs | `docker logs netvisor-server -f` |
| Restart | `docker compose restart` |
| Update | `docker compose pull && docker compose up -d` |

---

## 🔧 Verify It's Working

### Check Daemon Detected Your LAN
```bash
docker logs netvisor-daemon | grep subnet
```

Expected output:
```
[INFO] Detected network interface: eth0 - 192.168.1.100/24
[INFO] Will scan subnet: 192.168.1.0/24
```

### Check Discovery Progress
1. Go to **Discover > Sessions**
2. Should see active scan with progress counter
3. Wait for "Completed" status

### Check Results
1. Go to **Manage > Hosts**
2. Should see devices from your LAN
3. Go to **Topology** and click Reload

---

## ⚠️ Troubleshooting

### Only Seeing Docker Networks (not LAN)?

**Check network mode:**
```bash
docker inspect netvisor-daemon | grep -i NetworkMode
```

Should show: `"NetworkMode": "host"`

If not, check your docker-compose.yml:
```yaml
daemon:
  network_mode: host  # Must be present!
```

### Daemon Not Connecting to Server?

**Check server URL:**
```bash
docker logs netvisor-daemon | grep -i "server"
```

Should see successful registration.

**Fix:** Update `NETVISOR_INTEGRATED_DAEMON_URL` in docker-compose.yml:
```yaml
server:
  environment:
    NETVISOR_INTEGRATED_DAEMON_URL: http://172.17.0.1:60073
```

### Permission Denied Errors?

**Ensure privileged mode:**
```yaml
daemon:
  privileged: true
```

Or use capabilities:
```yaml
daemon:
  cap_add:
    - NET_RAW
    - NET_ADMIN
```

### Missing Devices?

**Common reasons:**
1. **Device has firewall** - Blocks port scans
2. **Device is offline** - Turned off during scan
3. **Wrong subnet** - Manually add subnet in UI:
   - **Manage > Subnets > Create Subnet**
   - Enter CIDR (e.g., `192.168.1.0/24`)
   - Run discovery with that subnet

---

## 🎯 Quick Network Detection

### Find Your Network Info

**Your IP address:**
```bash
hostname -I
# Output: 192.168.1.100
```

**Your subnet:**
```bash
ip route | grep default
# Output: default via 192.168.1.1 dev eth0
```

This tells you:
- Your IP: `192.168.1.100`
- Your router: `192.168.1.1`
- Your subnet: `192.168.1.0/24`

**Docker bridge gateway:**
```bash
docker network inspect bridge | grep Gateway
# Output: "Gateway": "172.17.0.1"
```

---

## 📊 Understanding Network Sizes

| CIDR | Number of Hosts | Scan Time |
|------|----------------|-----------|
| /24 | 254 hosts | 5-10 min |
| /23 | 510 hosts | 10-20 min |
| /22 | 1,022 hosts | 20-40 min |
| /16 | 65,534 hosts | Hours |

**Tip:** For /16 networks, use multiple daemons on different subnets.

---

## 🌐 Multiple VLANs?

If you have multiple VLANs (e.g., 192.168.1.0/24 and 192.168.2.0/24):

### Option 1: Deploy Additional Daemon

1. In UI: **Manage > Daemons > Create Daemon**
2. Copy the docker-compose command
3. Run on a host in the other VLAN

### Option 2: Manual Subnet Addition

1. In UI: **Manage > Subnets > Create Subnet**
2. Add the CIDR: `192.168.2.0/24`
3. **Discover > Scheduled > Create Discovery**
4. Select the new subnet

⚠️ **Note:** Without local interface, no MAC addresses or hostnames

---

## 🔒 Security Checklist

- [ ] Change default database password in docker-compose.yml
- [ ] Use strong password for NetVisor account
- [ ] Set up firewall rules (allow 60072 for web access)
- [ ] Keep Docker images updated: `docker compose pull`
- [ ] Enable HTTPS in production (set `NETVISOR_USE_SECURE_SESSION_COOKIES=true`)

---

## 📖 Full Documentation

- **Detailed LAN Scanning Guide:** [DOCKER_LAN_SCANNING.md](DOCKER_LAN_SCANNING.md)
- **Main README:** [README.md](README.md)
- **Ubuntu Native Install:** [UBUNTU_INSTALLATION.md](UBUNTU_INSTALLATION.md)
- **GitHub Issues:** https://github.com/mayanayza/netvisor/issues
- **Discord:** https://discord.gg/b7ffQr8AcZ

---

## 🎉 Success Checklist

After setup, you should have:

- ✅ Web UI accessible at http://localhost:60072
- ✅ Account created and logged in
- ✅ Daemon showing as registered in **Manage > Daemons**
- ✅ Your LAN subnet visible in **Manage > Subnets**
- ✅ Discovered devices in **Manage > Hosts**
- ✅ Network topology showing in **Topology** tab
- ✅ Scheduled discovery running automatically

---

## 💡 Pro Tips

1. **First scan takes longest** - Subsequent scans are faster
2. **Schedule regular scans** - Daily or weekly to track changes
3. **Use Groups** - Organize related services (web app + database)
4. **Consolidate hosts** - Merge duplicate entries for multi-homed hosts
5. **Export topology** - Save network diagrams as PNG
6. **Check service definitions** - NetVisor detects 50+ services automatically

---

## 🆘 Still Having Issues?

1. **Check logs:**
   ```bash
   docker logs netvisor-daemon
   docker logs netvisor-server
   ```

2. **Verify network mode:**
   ```bash
   docker inspect netvisor-daemon | grep NetworkMode
   ```

3. **Test connectivity:**
   ```bash
   docker exec netvisor-daemon curl http://172.17.0.1:60072/api/health
   ```

4. **Get help:**
   - Open issue: https://github.com/mayanayza/netvisor/issues
   - Join Discord: https://discord.gg/b7ffQr8AcZ
   - Read full guide: [DOCKER_LAN_SCANNING.md](DOCKER_LAN_SCANNING.md)

---

**Happy Network Mapping! 🗺️**
