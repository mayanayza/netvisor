# Edge Case Testing Plan v3

Additional edge case tests for host/port/interface/service interactions.

## Prerequisites
- Running backend server
- Valid authentication token
- Test network and subnet created
- For some tests: a second network

---

## 1. Optimistic Locking

### Test 1.1: Host update with correct expected_updated_at

**Setup:**
1. Create a host
2. Note the `updated_at` timestamp from the response

**Action:**
Update the host via `PUT /api/hosts/{id}` with `expected_updated_at` set to the noted timestamp

**Expected:**
- 200 OK
- Host updated successfully

**Verify:**
- Host reflects the changes
- `updated_at` has been updated to a new value

---

### Test 1.2: Host update with stale expected_updated_at

**Setup:**
1. Create a host
2. Note the `updated_at` timestamp
3. Update the host (without expected_updated_at) to change its `updated_at`

**Action:**
Update the host via `PUT /api/hosts/{id}` with `expected_updated_at` set to the OLD timestamp

**Expected:**
- 400 Bad Request
- Error message indicates the host was modified

**Verify:**
- Host was NOT updated with the stale request's changes
- Error message mentions "was modified by another process"

---

### Test 1.3: Host update without expected_updated_at (no locking)

**Setup:**
1. Create a host

**Action:**
Update the host via `PUT /api/hosts/{id}` WITHOUT the `expected_updated_at` field

**Expected:**
- 200 OK
- Update succeeds (no locking enforced when field is omitted)

**Verify:**
- Host reflects the changes

---

## 2. Bulk Delete Cascade

### Test 2.1: Bulk delete hosts with children

**Setup:**
1. Create Host A with interfaces, ports, and services with bindings
2. Create Host B with interfaces, ports, and services with bindings
3. Note all entity IDs

**Action:**
Bulk delete both hosts via `DELETE /api/hosts/bulk` with body `{ "ids": [host_a_id, host_b_id] }`

**Expected:**
- 200 OK
- Both hosts deleted

**Verify:**
- Fetching either host returns 404
- Fetching any interface from either host returns 404
- Fetching any port from either host returns 404
- Fetching any service from either host returns 404
- No orphaned bindings in database

---

### Test 2.2: Bulk delete with one invalid ID

**Setup:**
1. Create a host
2. Generate a random UUID that doesn't exist

**Action:**
Bulk delete with body `{ "ids": [valid_host_id, non_existent_id] }`

**Expected:**
Either:
- (a) 404 error - one or more hosts not found, OR
- (b) Partial success - valid host deleted, error for invalid ID, OR
- (c) 200 OK - deletes what exists, ignores missing

**Verify:**
- Document actual behavior
- If partial success, verify valid host was deleted

---

### Test 2.3: Bulk delete empty array

**Setup:**
None

**Action:**
Bulk delete with body `{ "ids": [] }`

**Expected:**
- 200 OK (no-op) or 400 Bad Request

**Verify:**
- Document actual behavior

---

## 3. Network Boundary Enforcement

### Test 3.1: Create interface on subnet from different network

**Setup:**
1. Create Network A with Subnet A
2. Create Network B with Host B
3. Note Subnet A's ID

**Action:**
Create an interface on Host B referencing Subnet A's ID

**Expected:**
- 400 Bad Request
- Error indicates subnet doesn't belong to the host's network

**Verify:**
- Interface was not created
- Error message is clear about network mismatch

---

### Test 3.2: Create service with host_id from different network

**Setup:**
1. Create Network A with Host A
2. Create Network B

**Action:**
Create a service with `network_id` = Network B but `host_id` = Host A

**Expected:**
- 400 Bad Request
- Error indicates host/network mismatch

**Verify:**
- Service was not created

---

### Test 3.3: Update service to reference host from different network

**Setup:**
1. Create Network A with Host A and a service on Host A
2. Create Network B with Host B

**Action:**
Update the service to change `host_id` to Host B (keeping original network_id)

**Expected:**
- 400 Bad Request
- Error indicates host/network mismatch

**Verify:**
- Service was not updated

---

### Test 3.4: Create port referencing host from different network

**Setup:**
1. Create Network A with Host A
2. Create Network B

**Action:**
Create a port with `host_id` = Host A but `network_id` = Network B

**Expected:**
- 400 Bad Request or port created with correct network_id (auto-corrected)

**Verify:**
- Document actual behavior
- If created, verify network_id matches host's network

---

## 4. Service Groups

### Test 4.1: Delete service that belongs to a group

**Setup:**
1. Create a host with a service
2. Create a group
3. Add the service to the group

**Action:**
Delete the service via `DELETE /api/services/{id}`

**Expected:**
- 200 OK
- Service deleted
- Group still exists but no longer references the service

**Verify:**
- Service returns 404
- Group exists and its service list doesn't include the deleted service

---

### Test 4.2: Consolidate host with grouped services

**Setup:**
1. Create Host A with Service A in Group X
2. Create Host B with Service B in Group X (same group)

**Action:**
Consolidate Host A into Host B

**Expected:**
- 200 OK
- Services are handled (deduplicated or merged)
- Group X still contains the appropriate services

**Verify:**
- Only Host B exists
- Group X is intact and contains the correct services

---

### Test 4.3: Delete host with grouped services

**Setup:**
1. Create a host with a service
2. Add the service to a group

**Action:**
Delete the host via `DELETE /api/hosts/{id}`

**Expected:**
- 200 OK
- Host and service deleted
- Group still exists but no longer references the deleted service

**Verify:**
- Host returns 404
- Service returns 404
- Group exists without the deleted service

---

## 5. Empty Host Consolidation

### Test 5.1: Consolidate empty host into host with children

**Setup:**
1. Create Host A with no interfaces, ports, or services
2. Create Host B with interfaces, ports, and services

**Action:**
Consolidate Host A into Host B

**Expected:**
- 200 OK
- Host A deleted
- Host B unchanged (nothing to merge)

**Verify:**
- Host A returns 404
- Host B has same children as before

---

### Test 5.2: Consolidate host with children into empty host

**Setup:**
1. Create Host A with interfaces, ports, and services
2. Create Host B with no children

**Action:**
Consolidate Host A into Host B

**Expected:**
- 200 OK
- Host A deleted
- Host B now has all of Host A's children

**Verify:**
- Host A returns 404
- Host B has all the interfaces, ports, and services that were on Host A

---

## 6. Port Protocol Edge Cases

### Test 6.1: Same port number, different protocols

**Setup:**
1. Create a host

**Action:**
Create two ports on the same host:
- Port 53 TCP
- Port 53 UDP

**Expected:**
- Both ports created successfully (they are distinct)

**Verify:**
- Host has two ports: 53/TCP and 53/UDP
- Each has a unique ID

---

### Test 6.2: Duplicate port same protocol rejected

**Setup:**
1. Create a host
2. Create port 443 TCP

**Action:**
Create another port 443 TCP on the same host

**Expected:**
- 400 Bad Request or 409 Conflict
- Error indicates duplicate port

**Verify:**
- Only one 443/TCP port exists on the host

---

### Test 6.3: Service bindings to same port number different protocols

**Setup:**
1. Create a host with port 53/TCP and port 53/UDP
2. Create a DNS service

**Action:**
Add bindings for both ports to the DNS service

**Expected:**
- 200 OK
- Service has two port bindings

**Verify:**
- Service has bindings to both 53/TCP and 53/UDP

---

## 7. MAC Address Handling

### Test 7.1: Two interfaces with same MAC on same host

**Setup:**
1. Create a host with an interface having MAC "AA:BB:CC:DD:EE:FF"

**Action:**
Create another interface on the same host with the same MAC address

**Expected:**
Either:
- (a) 400 Bad Request - duplicate MAC on same host, OR
- (b) Allowed (MACs only need to be unique per physical NIC, not per interface)

**Verify:**
- Document actual behavior

---

### Test 7.2: Discovery with MAC matching existing host

**Setup:**
1. Create Host A with interface having MAC "AA:BB:CC:DD:EE:FF"

**Action:**
Send discovery data for a "new" host with an interface having the same MAC

**Expected:**
- Discovery should match to existing Host A (not create duplicate)
- Data merged via upsert

**Verify:**
- Only one host exists with that MAC
- Host A was updated with discovery data

---

### Test 7.3: Interfaces with null MAC addresses

**Setup:**
1. Create a host

**Action:**
Create two interfaces on the same host, both with `mac_address: null`

**Expected:**
- Both interfaces created (null MACs don't conflict)

**Verify:**
- Host has two interfaces, both with null MAC

---

## Test Execution Checklist

| Test ID | Category | Status | Notes |
|---------|----------|--------|-------|
| 1.1 | Optimistic Locking | | |
| 1.2 | Optimistic Locking | | |
| 1.3 | Optimistic Locking | | |
| 2.1 | Bulk Delete | | |
| 2.2 | Bulk Delete | | |
| 2.3 | Bulk Delete | | |
| 3.1 | Network Boundary | | |
| 3.2 | Network Boundary | | |
| 3.3 | Network Boundary | | |
| 3.4 | Network Boundary | | |
| 4.1 | Service Groups | | |
| 4.2 | Service Groups | | |
| 4.3 | Service Groups | | |
| 5.1 | Empty Consolidation | | |
| 5.2 | Empty Consolidation | | |
| 6.1 | Port Protocols | | |
| 6.2 | Port Protocols | | |
| 6.3 | Port Protocols | | |
| 7.1 | MAC Address | | |
| 7.2 | MAC Address | | |
| 7.3 | MAC Address | | |
