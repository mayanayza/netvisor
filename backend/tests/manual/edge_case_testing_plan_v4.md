# Edge Case Testing Plan v4

Additional edge case tests covering gaps identified after v3.

## Prerequisites
- Running backend server
- Valid authentication token
- Test network and subnet created
- For some tests: a second network, daemon API key

---

## 1. Binding ID Stability

Tests to verify that binding IDs remain stable across updates, preserving foreign key relationships (e.g., group_bindings).

### Test 1.1: Service update preserves binding IDs

**Setup:**
1. Create a host with an interface and port
2. Create a service with a port binding
3. Note the binding's ID from the response

**Action:**
Update the service via `PUT /api/services/{id}` changing only the service name (keep same bindings)

**Expected:**
- 200 OK
- Binding ID in response matches the original binding ID

**Verify:**
- Binding ID is unchanged
- `created_at` on binding is preserved
- `updated_at` on binding may be updated

---

### Test 1.2: Service update preserves group membership via binding

**Setup:**
1. Create a host with interface and port
2. Create Service A with a port binding (note binding ID)
3. Create a group
4. Add Service A's binding to the group

**Action:**
Update Service A via `PUT /api/services/{id}` changing the service name (keep same bindings)

**Expected:**
- 200 OK
- Service updated successfully

**Verify:**
- Fetch the group - it still contains Service A's binding
- Binding ID is unchanged
- Group-binding relationship was preserved

---

### Test 1.3: Adding new binding preserves existing binding IDs

**Setup:**
1. Create a host with interface and two ports (port A, port B)
2. Create a service with binding to port A (note binding ID)
3. Add the binding to a group

**Action:**
Update the service to have bindings to BOTH port A and port B

**Expected:**
- 200 OK
- Original binding to port A has same ID
- New binding to port B has a new ID

**Verify:**
- Fetch service - two bindings exist
- Original binding ID unchanged
- Group still contains original binding

---

### Test 1.4: Removing one binding preserves other binding IDs

**Setup:**
1. Create a host with interface and two ports
2. Create a service with bindings to both ports (note both binding IDs)
3. Add binding A to a group

**Action:**
Update the service to remove binding B, keeping only binding A

**Expected:**
- 200 OK
- Binding A still has same ID
- Binding B is removed

**Verify:**
- Service has only one binding
- Binding A's ID is unchanged
- Group still contains binding A

---

## 2. Interface Network Boundary

Tests for interface network_id validation (similar to port validation added in v3 test 3.4).

### Test 2.1: Create interface with mismatched network_id

**Setup:**
1. Create Network A with a subnet
2. Create Network B with Host B

**Action:**
Create an interface on Host B with `network_id` = Network A (but host is on Network B)

**Expected:**
- 400 Bad Request
- Error indicates network mismatch between interface and host

**Verify:**
- Interface was not created
- Error message is clear

---

### Test 2.2: Update interface to different network_id

**Setup:**
1. Create Network A with Host A and an interface
2. Create Network B

**Action:**
Update the interface via `PUT /api/interfaces/{id}` changing `network_id` to Network B

**Expected:**
- 400 Bad Request
- Error indicates network_id cannot differ from host's network

**Verify:**
- Interface network_id unchanged

---

## 3. Subnet Edge Cases

### Test 3.1: Delete subnet with interfaces referencing it

**Setup:**
1. Create a network with a subnet
2. Create a host with an interface on that subnet

**Action:**
Delete the subnet via `DELETE /api/subnets/{id}`

**Expected:**
Either:
- (a) 400/409 error - subnet has interfaces, cannot delete, OR
- (b) Cascade delete - interfaces on subnet are deleted, OR
- (c) Interfaces updated to have null subnet_id

**Verify:**
- Document actual behavior
- If (b) or (c), verify interface state

---

### Test 3.2: Create interface referencing subnet from different network

**Setup:**
1. Create Network A with Subnet A
2. Create Network B with Host B

**Action:**
Create an interface on Host B referencing Subnet A's ID

**Expected:**
- 400 Bad Request
- Error indicates subnet doesn't belong to the host's network

**Verify:**
- Interface was not created

*Note: This may be covered by v3 test 3.1, but explicitly testing the interface creation path*

---

### Test 3.3: Update subnet CIDR when interfaces exist

**Setup:**
1. Create a subnet with CIDR 10.0.0.0/24
2. Create a host with interface IP 10.0.0.50

**Action:**
Update the subnet CIDR to 10.0.1.0/24 (which excludes the existing interface IP)

**Expected:**
Either:
- (a) 400 error - existing interfaces would be outside new CIDR, OR
- (b) Update succeeds (no validation of existing IPs), OR
- (c) Interfaces are updated/removed

**Verify:**
- Document actual behavior
- Check interface state after update

---

### Test 3.4: Create interface with IP outside subnet CIDR

**Setup:**
1. Create a subnet with CIDR 10.0.0.0/24
2. Create a host

**Action:**
Create an interface with IP 10.0.1.50 referencing that subnet

**Expected:**
- 400 Bad Request
- Error indicates IP is not within subnet CIDR

**Verify:**
- Interface was not created

---

## 4. Network Deletion Cascade

### Test 4.1: Delete network with hosts

**Setup:**
1. Create a network
2. Create multiple hosts with interfaces, ports, services

**Action:**
Delete the network via `DELETE /api/networks/{id}`

**Expected:**
Either:
- (a) 400/409 error - network has children, cannot delete, OR
- (b) Cascade delete - all hosts/subnets/services deleted

**Verify:**
- Document actual behavior
- If cascade, verify all children are gone

---

### Test 4.2: Delete network with subnets only (no hosts)

**Setup:**
1. Create a network
2. Create subnets but no hosts

**Action:**
Delete the network

**Expected:**
- Similar to 4.1, document behavior

**Verify:**
- Subnets are deleted or error returned

---

### Test 4.3: Delete network removes user_network_access

**Setup:**
1. Create a network
2. Grant a user access to that network
3. Verify user has network in their accessible networks

**Action:**
Delete the network (assuming cascade is allowed)

**Expected:**
- user_network_access entries for that network are removed
- User's accessible networks list no longer includes it

**Verify:**
- No orphaned user_network_access records
- User can still access other networks

---

## 5. Group Edge Cases

### Test 5.1: Delete group - bindings remain intact

**Setup:**
1. Create a host with service and binding
2. Create a group
3. Add the binding to the group

**Action:**
Delete the group via `DELETE /api/groups/{id}`

**Expected:**
- 200 OK
- Group deleted
- Service and its binding still exist (unaffected)

**Verify:**
- Group returns 404
- Service and binding still exist and are functional

---

### Test 5.2: Same binding in multiple groups

**Setup:**
1. Create a host with service and binding
2. Create Group A and Group B
3. Add the binding to both groups

**Expected:**
- Both operations succeed
- Binding appears in both groups

**Action:**
Fetch both groups

**Verify:**
- Both groups list the same binding
- Binding ID is identical in both

---

### Test 5.3: Delete binding removes from all groups

**Setup:**
1. Create a host with service and binding
2. Add binding to Group A and Group B
3. Verify binding is in both groups

**Action:**
Delete the service (which deletes its bindings)

**Expected:**
- Service deleted
- Binding removed from both groups automatically

**Verify:**
- Fetch Group A - binding not present
- Fetch Group B - binding not present
- Groups still exist

---

### Test 5.4: Group with bindings from multiple services

**Setup:**
1. Create a host with two services, each with a binding
2. Create a group
3. Add both bindings to the group

**Action:**
Fetch the group

**Expected:**
- Group contains both bindings
- Bindings reference different services

**Verify:**
- Group lists both bindings with correct service associations

---

### Test 5.5: Add binding to group when binding doesn't exist

**Setup:**
1. Create a group
2. Generate a random UUID

**Action:**
Add the non-existent binding ID to the group

**Expected:**
- 400 or 404 error
- Error indicates binding not found

**Verify:**
- Group is unchanged

---

### Test 5.6: Add binding from different network to group

**Setup:**
1. Create Network A with host, service, binding
2. Create Network B with a group

**Action:**
Add Network A's binding to Network B's group

**Expected:**
- 400 error - cross-network binding not allowed

**Verify:**
- Group unchanged
- Error message mentions network mismatch

---

## 6. Discovery Edge Cases

### Test 6.1: Discovery with non-existent port_id in binding

**Setup:**
1. Create a host via API with an interface

**Action:**
Send discovery data with a service that has a port binding referencing a non-existent port_id

**Expected:**
Either:
- (a) Binding dropped with warning, service created without it, OR
- (b) Entire service rejected, OR
- (c) 400 error for the discovery request

**Verify:**
- Document actual behavior
- Check if service was created and its bindings

---

### Test 6.2: Discovery with non-existent interface_id in binding

**Setup:**
1. Create a host with a port

**Action:**
Send discovery data with a service that has an interface binding referencing a non-existent interface_id

**Expected:**
- Similar to 6.1, document behavior

**Verify:**
- Check service and binding state

---

### Test 6.3: Discovery for network daemon doesn't have access to

**Setup:**
1. Create Network A
2. Create Network B
3. Create a daemon with access only to Network A

**Action:**
Send discovery data with `network_id` = Network B using the daemon's API key

**Expected:**
- 403 Forbidden
- Daemon cannot discover hosts in networks it doesn't have access to

**Verify:**
- No host created in Network B
- Clear error message

---

### Test 6.4: Discovery with duplicate bindings in same service

**Setup:**
1. Create a host with interface and port

**Action:**
Send discovery data with a service that has the same port binding listed twice

**Expected:**
Either:
- (a) Deduplicated - only one binding saved, OR
- (b) Error about duplicate bindings

**Verify:**
- Service has at most one binding for that port
- No duplicate binding IDs

---

### Test 6.5: Discovery updates binding type (interface to port)

**Setup:**
1. Create a host with interface and port
2. Create a service with an interface binding via API

**Action:**
Send discovery data for the same service but with a port binding instead

**Expected:**
- Service updated
- Interface binding replaced with port binding (or merged?)

**Verify:**
- Document actual behavior
- Check final binding state

---

### Test 6.6: Discovery with service referencing wrong host's port

**Setup:**
1. Create Host A with port
2. Create Host B

**Action:**
Send discovery data for Host B with a service binding to Host A's port_id

**Expected:**
- 400 error or binding dropped
- Service's bindings should only reference its own host's ports

**Verify:**
- Binding was not created or was corrected
- Clear error/warning in logs

---

## 7. Miscellaneous Edge Cases

### Test 7.1: Create entity with explicit UUID that already exists

**Setup:**
1. Create a host, note its ID

**Action:**
Create another host with the same explicit ID in the request body

**Expected:**
- 400 or 409 error - ID already exists

**Verify:**
- Original host unchanged
- No duplicate created

---

### Test 7.2: Update entity to have different ID

**Setup:**
1. Create a host, note its ID

**Action:**
Update the host via `PUT /api/hosts/{id}` with a different ID in the request body

**Expected:**
- ID in body should be ignored (path ID is canonical)
- Or 400 error if IDs don't match

**Verify:**
- Host ID unchanged
- Update applied to correct host

---

### Test 7.3: Bulk delete with duplicate IDs

**Setup:**
1. Create a host

**Action:**
Bulk delete with the same host ID listed multiple times: `{"ids": [host_id, host_id, host_id]}`

**Expected:**
- 200 OK
- Host deleted once
- Response indicates 1 deleted (not 3)

**Verify:**
- Host returns 404
- No errors about duplicate IDs

---

### Test 7.4: Service with binding to port that gets deleted

**Setup:**
1. Create a host with interface and port
2. Create a service with port binding
3. Delete the port directly via `DELETE /api/ports/{id}`

**Expected:**
Either:
- (a) Port deletion blocked - has binding references, OR
- (b) Binding cascade deleted, service remains without binding, OR
- (c) Port deleted, binding becomes orphaned (bad)

**Verify:**
- Document actual behavior
- If (b), verify service exists with empty/updated bindings

---

### Test 7.5: Very long entity names

**Setup:**
None

**Action:**
Create a host with a 10,000 character name

**Expected:**
Either:
- (a) 400 error - name too long, OR
- (b) Truncated and saved, OR
- (c) Accepted as-is

**Verify:**
- Document behavior and any limits

---

### Test 7.6: Unicode and special characters in names

**Setup:**
None

**Action:**
Create entities with names containing:
- Unicode: "服务器-主机-🖥️"
- SQL injection attempt: "Host'; DROP TABLE hosts;--"
- Null bytes: "Host\x00Name"

**Expected:**
- Unicode: Should be accepted
- SQL injection: Should be safely escaped (no SQL error)
- Null bytes: Should be rejected or sanitized

**Verify:**
- Document behavior for each case
- Verify no SQL injection occurred

---

## Test Execution Checklist

| Test ID | Category | Status | Notes |
|---------|----------|--------|-------|
| 1.1 | Binding Stability | | |
| 1.2 | Binding Stability | | |
| 1.3 | Binding Stability | | |
| 1.4 | Binding Stability | | |
| 2.1 | Interface Network | | |
| 2.2 | Interface Network | | |
| 3.1 | Subnet | | |
| 3.2 | Subnet | | |
| 3.3 | Subnet | | |
| 3.4 | Subnet | | |
| 4.1 | Network Cascade | | |
| 4.2 | Network Cascade | | |
| 4.3 | Network Cascade | | |
| 5.1 | Groups | | |
| 5.2 | Groups | | |
| 5.3 | Groups | | |
| 5.4 | Groups | | |
| 5.5 | Groups | | |
| 5.6 | Groups | | |
| 6.1 | Discovery | | |
| 6.2 | Discovery | | |
| 6.3 | Discovery | | |
| 6.4 | Discovery | | |
| 6.5 | Discovery | | |
| 6.6 | Discovery | | |
| 7.1 | Misc | | |
| 7.2 | Misc | | |
| 7.3 | Misc | | |
| 7.4 | Misc | | |
| 7.5 | Misc | | |
| 7.6 | Misc | | |
