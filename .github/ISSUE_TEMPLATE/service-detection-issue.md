---
name: Service not detected or false positive
about: Report a service that isn't detected but should be, or a false positive (a service you aren't running that was detected)
title: 'Service [NOT DETECTED | FALSE POSITIVE]: SERVICE NAME'
labels: bug
assignees: mayanayza

---

# Basics

**Is a service not being detected, or is this a false positive?**
Not detected / false positive

**What service?**
Service Name

# Service Not Detected

**Is the service present in NetVisor's service definition library?**
Go to the [service definitions directory](SERVICES.md) and check if it's listed there

**Are you running the service in a docker container on the same host as the daemon, or are you running it on the network on a different host?**
Docker on same host / different host on network

**Are you using the default ports for the service, or do you have a custom setup? NetVisor uses the standard ports recommended by documentation for the service to detect it, so if you have a custom setup it won't find it. Docker container port mappings are fine as the docker socket integration uses the container ports, not the mapped host ports, to pattern match**

# False Positive

**Was the service detected through docker, or network scanning? To verify, open the edit modal for the host running the service, go to the services tab, and see if the service has a "Docker" tag**
Choose: Docker / Network Scan

**What are the match details for the service? Click on the service record, scroll to the bottom, and click the match details link, then copy the json**
Insert match details
