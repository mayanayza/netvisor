# Edge Case Testing Plan v2

This document outlines additional edge case tests for host/port/interface/service interactions.

## Prerequisites
- Running backend server
- Valid authentication token
- Test network and subnet created

---

## 1. Deletion Cascade Behavior

### Test 1.1: Delete interface with port bindings referencing it

**Setup:**
1. Create a host with an interface
2. Create a port on the host
3. Create a service with a port binding on the specific interface (`interface_id` set)

**Action:**
Delete the interface via `DELETE /api/interfaces/{interface_id}`

**Expected:**
Either:
- (a) Deletion blocked with 400/409 error explaining bindings exist, OR
- (b) Bindings automatically update to `interface_id: None` (all-interfaces), OR
- (c) Bindings referencing that interface are deleted

**Verify:**
- Check HTTP status code
- If deletion succeeded, fetch the service and check its bindings

---

### Test 1.2: Delete port with service bindings

**Setup:**
1. Create a host with an interface
2. Create a port (e.g., 443/tcp) on the host
3. Create a service with a port binding to that port

**Action:**
Delete the port via `DELETE /api/ports/{port_id}`

**Expected:**
Either:
- (a) Deletion blocked with 400/409 error explaining service bindings exist, OR
- (b) Service bindings referencing that port are automatically deleted

**Verify:**
- Check HTTP status code
- If deletion succeeded, fetch the service and verify bindings are gone/updated

---

### Test 1.3: Delete host with children (interfaces, ports, services)

**Setup:**
1. Create a host
2. Add interfaces, ports, and services with bindings

**Action:**
Delete the host via `DELETE /api/hosts/{host_id}`

**Expected:**
- All children (interfaces, ports, services, bindings) are cascade deleted
- No orphaned records remain

**Verify:**
- Host deletion returns 200
- Fetching the host returns 404
- Fetching any child entity returns 404

---

## 2. Cross-Entity Validation

### Test 2.1: Create binding referencing port from different host

**Setup:**
1. Create Host A with a port (443/tcp)
2. Create Host B with an interface

**Action:**
Create a service on Host B with a port binding referencing Host A's port_id

**Expected:**
- 400 Bad Request with error message indicating port doesn't belong to the service's host

**Verify:**
- Check HTTP status is 400
- Error message mentions port/host mismatch

---

### Test 2.2: Create binding referencing interface from different host

**Setup:**
1. Create Host A with an interface
2. Create Host B

**Action:**
Create a service on Host B with an interface binding referencing Host A's interface_id

**Expected:**
- 400 Bad Request with error message indicating interface doesn't belong to the service's host

**Verify:**
- Check HTTP status is 400
- Error message mentions interface/host mismatch

---

### Test 2.3: Update service to different host - bindings validation

**Setup:**
1. Create Host A with interface and port
2. Create a service on Host A with a port binding
3. Create Host B (no matching port)

**Action:**
Update the service's `host_id` to Host B via `PUT /api/services/{id}`

**Expected:**
Either:
- (a) 400 error - bindings reference ports/interfaces not on new host, OR
- (b) Service moved but bindings are dropped/invalidated with warning, OR
- (c) Update blocked entirely (services can't change hosts)

**Verify:**
- Check response status and message
- If succeeded, verify service's bindings state

---

### Test 2.4: Create binding referencing non-existent port

**Setup:**
1. Create a host with an interface

**Action:**
Create a service with a port binding referencing a random UUID that doesn't exist

**Expected:**
- 400 Bad Request with error indicating port not found

**Verify:**
- Check HTTP status is 400

---

### Test 2.5: Create binding referencing non-existent interface

**Setup:**
1. Create a host

**Action:**
Create a service with an interface binding referencing a random UUID that doesn't exist

**Expected:**
- 400 Bad Request with error indicating interface not found

**Verify:**
- Check HTTP status is 400

---

## 3. Consolidation Edge Cases

### Test 3.1: Consolidate hosts with same service but different bindings

**Setup:**
1. Create Host A with interface-A, port 443
2. Create service "Web Server" on Host A bound to port 443 on interface-A
3. Create Host B with interface-B, port 443, port 8080
4. Create service "Web Server" (same name + definition) on Host B bound to port 8080

**Action:**
Consolidate Host A into Host B via `POST /api/hosts/{host_b_id}/consolidate`

**Expected:**
- Services are deduplicated (only one "Web Server" remains)
- Bindings are merged or destination's bindings are preserved
- Document actual behavior

**Verify:**
- Only one service named "Web Server" exists on Host B
- Check which bindings are present (443? 8080? both?)

---

### Test 3.2: Consolidate host with itself

**Setup:**
1. Create a host

**Action:**
Consolidate the host with itself via `POST /api/hosts/{host_id}/consolidate` with `other_host_id` = same host_id

**Expected:**
- 400 Bad Request with clear error message

**Verify:**
- Check HTTP status is 400
- Error message indicates cannot consolidate host with itself

---

### Test 3.3: Consolidate hosts from different networks

**Setup:**
1. Create Network A with Host A
2. Create Network B with Host B

**Action:**
Consolidate Host A into Host B

**Expected:**
- 400 Bad Request with error indicating hosts must be in the same network

**Verify:**
- Check HTTP status is 400
- Error message mentions network mismatch

---

### Test 3.4: Consolidate with conflicting ports on different interfaces

**Setup:**
1. Create Host A with interface-A (10.0.0.1), port 443 on interface-A
2. Create Host B with interface-B (10.0.0.2), port 443 on interface-B
3. Both ports are 443/tcp but bound to different interfaces

**Action:**
Consolidate Host A into Host B

**Expected:**
- Port conflict is resolved (either merged or one takes precedence)
- Bindings are correctly remapped
- No duplicate 443/tcp ports on destination

**Verify:**
- Check destination host has exactly one 443/tcp port
- Services from source have their bindings updated to use destination's port

---

### Test 3.5: Consolidate transfers interface with same IP but different subnet

**Setup:**
1. Create Subnet-1 (10.0.0.0/24) and Subnet-2 (10.0.1.0/24)
2. Create Host A with interface on Subnet-1, IP 10.0.0.50
3. Create Host B with interface on Subnet-2, IP 10.0.1.50

**Action:**
Consolidate Host A into Host B

**Expected:**
- Interface from Host A is transferred to Host B (different subnet, so no conflict)
- Host B now has two interfaces

**Verify:**
- Host B has both interfaces
- Original interface IDs are preserved or properly remapped

---

## 4. Discovery Race Conditions

### Test 4.1: Simultaneous discovery calls for same host

**Setup:**
1. Create a host with known interface (MAC address)

**Action:**
Send two discovery requests simultaneously (within ~100ms) for the same host:
- Discovery 1: Finds service "SSH" on port 22
- Discovery 2: Finds service "HTTP" on port 80

**Expected:**
- Both discoveries complete without error
- Host ends up with both services
- No duplicate hosts created
- No data corruption

**Verify:**
- Check host has both SSH and HTTP services
- Only one host exists with that MAC address
- No database constraint violations in logs

---

### Test 4.2: Discovery while manual service update in progress

**Setup:**
1. Create a host via discovery with service "Web Server"
2. Start a manual update to rename service to "Apache Web Server"

**Action:**
While the update is processing, send a discovery that finds "Web Server" again

**Expected:**
- One operation wins based on locking
- Final state is consistent (either the rename stuck or discovery overwrote it)
- No errors or data corruption

**Verify:**
- Service exists in a valid state
- No duplicate services

---

### Test 4.3: Discovery updates service while consolidation is running

**Setup:**
1. Create Host A with service "Database"
2. Create Host B
3. Start consolidating Host A into Host B

**Action:**
While consolidation is running, send discovery for Host A with updated service info

**Expected:**
- Operations are serialized via locking
- Final state is consistent
- Either consolidation completes first (service moved to B) or discovery updates first

**Verify:**
- No errors
- Service is in a consistent state on either host

---

## 5. Binding Conflict Scenarios

### Test 5.1: Service with mixed Interface and Port bindings

**Setup:**
1. Create a host with two interfaces and a port

**Action:**
Create a service with:
- One `Interface` binding to interface-1
- One `Port` binding to the port on interface-2

**Expected:**
- Should this be allowed? Document behavior.
- If allowed, both bindings should be saved
- If not allowed, clear error message

**Verify:**
- Check response status
- If created, verify both bindings exist on the service

---

### Test 5.2: Discovery adds binding conflicting with manual binding

**Setup:**
1. Create a host with interface and port 443
2. Manually create service "Web" with an Interface binding (not port binding)

**Action:**
Discovery finds service "Web" with a Port binding on all interfaces (interface_id: null)

**Expected:**
- Conflict detected between Interface binding and Port binding on all interfaces
- Either:
  - (a) Discovery binding rejected, manual binding preserved
  - (b) Discovery binding wins, manual binding removed
  - (c) Error logged but both kept (inconsistent state)

**Verify:**
- Check service bindings after discovery
- Document which binding "wins"

---

### Test 5.3: Add all-interfaces port binding when specific interface binding exists (manual API)

**Setup:**
1. Create a host with interface and port 443
2. Create service with port binding on specific interface

**Action:**
Via API, add another binding to the same service: port 443 with `interface_id: null`

**Expected:**
- The all-interfaces binding should supersede the specific binding
- Only one binding remains (the all-interfaces one)

**Verify:**
- Service has exactly one binding for port 443
- That binding has `interface_id: null`

---

### Test 5.4: Add specific interface binding when all-interfaces binding exists

**Setup:**
1. Create a host with interface and port 443
2. Create service with port binding on all interfaces (`interface_id: null`)

**Action:**
Via API, add another binding to the same service: port 443 with specific `interface_id`

**Expected:**
- The specific binding is redundant (covered by all-interfaces)
- Either rejected or silently ignored

**Verify:**
- Service still has only the all-interfaces binding
- No duplicate bindings

---

## 6. Additional Edge Cases

### Test 6.1: Create service with empty bindings array

**Setup:**
1. Create a host

**Action:**
Create a service with `bindings: []`

**Expected:**
- Service created successfully with no bindings
- This is valid (service exists but not bound to specific ports/interfaces)

**Verify:**
- Service exists
- `bindings` array is empty

---

### Test 6.2: Update service to remove all bindings

**Setup:**
1. Create a host with port
2. Create service with port binding

**Action:**
Update service with `bindings: []`

**Expected:**
- All bindings removed
- Service still exists

**Verify:**
- Service exists with empty bindings array

---

### Test 6.3: Maximum bindings per service

**Setup:**
1. Create a host with 20 interfaces and 20 ports

**Action:**
Create a service with bindings to all 40 entities

**Expected:**
- Either succeeds (if no limit) or returns clear error about limit

**Verify:**
- Document behavior and any limits

---

### Test 6.4: Duplicate binding in same request

**Setup:**
1. Create a host with interface and port

**Action:**
Create a service with bindings array containing the same port binding twice

**Expected:**
- Either:
  - (a) Deduplicated automatically (only one binding saved)
  - (b) 400 error indicating duplicate binding

**Verify:**
- Check response
- If created, verify only one binding exists

---

## Test Execution Checklist

| Test ID | Category | Status | Notes |
|---------|----------|--------|-------|
| 1.1 | Deletion | | |
| 1.2 | Deletion | | |
| 1.3 | Deletion | | |
| 2.1 | Validation | | |
| 2.2 | Validation | | |
| 2.3 | Validation | | |
| 2.4 | Validation | | |
| 2.5 | Validation | | |
| 3.1 | Consolidation | | |
| 3.2 | Consolidation | | |
| 3.3 | Consolidation | | |
| 3.4 | Consolidation | | |
| 3.5 | Consolidation | | |
| 4.1 | Concurrency | | |
| 4.2 | Concurrency | | |
| 4.3 | Concurrency | | |
| 5.1 | Bindings | | |
| 5.2 | Bindings | | |
| 5.3 | Bindings | | |
| 5.4 | Bindings | | |
| 6.1 | Misc | | |
| 6.2 | Misc | | |
| 6.3 | Misc | | |
| 6.4 | Misc | | |
