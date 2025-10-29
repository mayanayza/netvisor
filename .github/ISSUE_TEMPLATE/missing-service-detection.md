---
name: Missing service detection
about: Report a service not being detected on your network (ie - you're running Home
  Assistant, and NetVisor isn't matching it to a host on your network)
title: 'Missing service detection: SERVICE NAME'
labels: bug
assignees: mayanayza

---

**What service isn't being detected?**
Service name

**Is the service present in NetVisor's service definition library?**
Go to https://github.com/mayanayza/netvisor/tree/main/backend/src/server/services/definitions and check if it's listed there

**Are you running the service in a docker container on the same host as the daemon, or are you running it on the network on a different host?**
Docker on same host / different host on network

**Are you using the default ports for the service, or do you have a custom setup? NetVisor uses the standard ports recommended by documentation for the service to detect it, so if you have a custom setup it won't find it. Docker container port mappings are fine as the docker socket integration uses the container ports, not the mapped host ports, to pattern match**
